from flask import Blueprint, request, jsonify
import pyodbc
import logging
import DB_config as db
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
from lib.BL.Login_BL import Login

# Initialize the blueprint
app = Blueprint('login', __name__)

# Configure logging
logging.basicConfig(level=logging.INFO)

# Database configuration: Singleton instance for managing connections
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

# Login route
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        username = data['Username']
        provided_password = data['Password']

        # Query to fetch user details based on username
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

            login_instance = Login(username, provided_password)

            if login_instance.authenticate(stored_password):
                login_instance.set_employee_details(employee_id, position)

                return jsonify({
                    'message': 'Login successful',
                    'redirect_url': login_instance.redirect_user(),
                    'Username': username,
                    'Position': position,
                    'EmployeeID': employee_id
                }), 200
            else:
                return jsonify({'error': 'Incorrect password'}), 401
        else:
            return jsonify({'error': 'User not found'}), 404

    except Exception as e:
        logging.error(f"Error during login: {e}")
        return jsonify({'error': 'An error occurred during login.'}), 500

# Password reset route
@app.route('/reset_password', methods=['POST'])
def reset_password():
    try:
        data = request.json
        email = data['email']
        new_password = data['new_password']

        if not email:
            return jsonify({"error": "Email is required"}), 400
        if not new_password:
            return jsonify({"error": "New password is required"}), 400

        query = "SELECT * FROM Users WHERE Username = ?"
        cursor.execute(query, (email,))
        user = cursor.fetchone()

        if user:
            update_query = "UPDATE Users SET Password = ? WHERE Username = ?"
            cursor.execute(update_query, (new_password, email))
            connection.commit()

            return jsonify({"message": "Password reset successful"}), 200
        else:
            return jsonify({"error": "User not found"}), 404

    except Exception as e:
        logging.error(f"Error during password reset: {e}")
        return jsonify({'error': 'An error occurred during password reset.'}), 500