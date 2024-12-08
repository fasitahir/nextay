# feedback.py
from flask import Blueprint, request, jsonify
import DB_config as db
from lib.BL.Feedback import Feedback
from datetime import datetime

# Create a Flask blueprint
app = Blueprint('feedback_dl', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

@app.route('/feedback', methods=['POST'])
def submit_feedback():
    try:
        data = request.json
        print(f"Received data: {data}")  # Log incoming data

        # Check if all required fields are present
        if not all(key in data for key in ['customerName', 'Feedback', 'Rating', 'Type']):
            return jsonify({'error': 'Missing required fields'}), 400

        customer_name = data['customerName']
        feedback_text = data['Feedback']
        rating = data['Rating']
        feedback_type_name = data['Type']
        # Retrieve customer ID based on the provided name
        cursor.execute("SELECT CustomerID FROM Customer WHERE FirstName = ?", (customer_name))
        customer = cursor.fetchone()
        if customer:
            customer_id = customer[0]

            # Retrieve the type ID from the FeedbackTypeLookup table
            cursor.execute("SELECT Id FROM Lookup WHERE Value = ?", (feedback_type_name,))
            feedback_type = cursor.fetchone()

            if feedback_type:
                feedback_type_id = feedback_type[0]

                feedback = Feedback(customer_id, feedback_text, rating, feedback_type_id)

                # Insert feedback into the database with DateSubmitted and Status
                cursor.execute(
                    "INSERT INTO Feedback (CustomerId, Feedback, Rating, Type, DateSubmitted) VALUES (?, ?, ?, ?, ?)",
                    (feedback.CustomerId, feedback.Feedback, feedback.Rating, feedback.Type, feedback.DateSubmitted)
                )
                connection.commit()
                return jsonify({'message': 'Feedback submitted successfully!'}), 201
            else:
                return jsonify({'error': 'Invalid feedback type!'}), 400
        else:
            return jsonify({'error': 'Customer not found!'}), 404
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
