from flask import Blueprint, request, jsonify

import sys
import os

import DB_config as db

# Add the root directory (project's root) to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from lib.BL.Login_BL import Login

# Create a Flask blueprint
app = Blueprint('login', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

@app.route('/login', methods=['POST'])
def login():
    try:
        print("Login request received")
        data = request.json
        username = data['Username']  # Get the username from the request
        provided_password = data['Password']

        # Check the Users table for the provided username and join with Employee_Designation and Promotions to get the position
        query = """
        SELECT u.EmployeeID, u.Password, p.Value
        FROM Users u 
        JOIN EmployeeDesignation ed ON u.EmployeeID = ed.EmployeeId
        JOIN Lookup p ON ed.Position = p.Id 
        WHERE u.Username = ?
        """
        cursor.execute(query, (username,))
        result = cursor.fetchone()

        if result:
            employee_id, stored_password, position = result
            
            # Create a Login instance
            login_instance = Login(username, provided_password)

            # Authenticate the user
            if login_instance.authenticate(stored_password):
                # Set employee details including the employee ID and position
                login_instance.set_employee_details(employee_id, position)

                # Return user details with redirect URL
                return jsonify({
                    'message': 'Login successful',
                    'redirect_url': login_instance.redirect_user(),
                    'Username': username,
                    'Position': position,
                }), 200
            else:
                return jsonify({'error': 'Incorrect password'}), 401
        else:
            return jsonify({'error': 'User not found'}), 404

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
