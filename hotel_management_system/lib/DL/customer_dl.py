from flask import Blueprint, request, jsonify
from flask_cors import CORS
import DB_config as db
from datetime import datetime
import logging

app = Blueprint('customer_dl', __name__)

# Configure CORS with additional options
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept"]
    }
})


# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

# Add error handler for the blueprint
@app.errorhandler(Exception)
def handle_error(error):
    logging.error(f"An error occurred: {str(error)}")
    return jsonify({
        'error': 'An internal server error occurred',
        'details': str(error)
    }), 500

@app.route('/customer', methods=['POST'])
def add_customer():
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400

        required_fields = [
            'first_name', 'last_name', 'email', 'phone_number',
            'address', 'dob', 'nationality', 'id_type'
        ]
        
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            return jsonify({
                'error': 'Missing required fields',
                'missing_fields': missing_fields
            }), 400

        # Validate date format
        try:
            parsed_dob = datetime.fromisoformat(data['dob'].replace('Z', '+00:00'))
        except ValueError:
            return jsonify({'error': 'Invalid date format for dob'}), 400

        # Insert the customer data
        cursor.execute("""
            INSERT INTO CustomerTable 
            (FirstName, LastName, Email, PhoneNumber, Address, DOB, 
             Nationality, IDType, BookingHistory Preferences, LastStayDate)
            OUTPUT INSERTED.CustomerID
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            data['first_name'],
            data['last_name'],
            data['email'],
            data['phone_number'],
            data['address'],
            parsed_dob,
            data['nationality'],
            data['id_type'],
            None,
            data.get('preferences'),
            None  # LastStayDate will be updated when they check out
        ))

        customer_id = cursor.fetchone()[0]
        connection.commit()
        
        return jsonify({
            'message': 'Customer added successfully!',
            'customer_id': customer_id
        }), 201

    except Exception as e:
        connection.rollback()
        raise

@app.route('/customer/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    cursor.execute("""
        SELECT CustomerID, FirstName, LastName, Email, PhoneNumber,
               Address, DOB, Nationality, IDType, Preferences, LastStayDate
        FROM Customers
        WHERE CustomerID = ?
    """, (customer_id,))
    
    customer = cursor.fetchone()
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404

    return jsonify({
        'customer_id': customer[0],
        'first_name': customer[1],
        'last_name': customer[2],
        'email': customer[3],
        'phone_number': customer[4],
        'address': customer[5],
        'dob': customer[6].isoformat() if customer[6] else None,
        'nationality': customer[7],
        'id_type': customer[8],
        'preferences': customer[9],
        'last_stay_date': customer[10].isoformat() if customer[10] else None
    }), 200
@app.route('/customer/<int:customer_id>', methods=['PUT'])
def update_customer(customer_id):
    try:
        data = request.json
        updatable_fields = [
            'first_name', 'last_name', 'email', 'phone_number',
            'address', 'nationality', 'id_type', 'preferences'
        ]
        
        if not any(key in data for key in updatable_fields):
            return jsonify({'error': 'No fields to update'}), 400

        # Build the update query dynamically
        update_parts = []
        values = []
        for field in updatable_fields:
            if field in data:
                update_parts.append(f"{field.title().replace('_', '')} = ?")
                values.append(data[field])

        if update_parts:
            values.append(customer_id)
            query = f"UPDATE Customers SET {', '.join(update_parts)} WHERE CustomerID = ?"
            cursor.execute(query, tuple(values))
            connection.commit()

        return jsonify({'message': 'Customer updated successfully!'}), 200

    except Exception as e:
        print(f"Error: {e}")
        connection.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/customers', methods=['GET'])
def get_all_customers():
    try:
        cursor.execute("""
            SELECT CustomerID, FirstName, LastName, Email, PhoneNumber,
                   Address, DOB, Nationality, IDType, Preferences, LastStayDate
            FROM Customers
        """)
        
        customers = cursor.fetchall()
        customer_list = []
        
        for customer in customers:
            customer_list.append({
                'customer_id': customer[0],
                'first_name': customer[1],
                'last_name': customer[2],
                'email': customer[3],
                'phone_number': customer[4],
                'address': customer[5],
                'dob': customer[6].isoformat() if customer[6] else None,
                'nationality': customer[7],
                'id_type': customer[8],
                'preferences': customer[9],
                'last_stay_date': customer[10].isoformat() if customer[10] else None
            })

        return jsonify(customer_list), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500