from flask import Blueprint, request, jsonify
from flask_cors import CORS
import DB_config as db
import pyodbc  # Ensure you have this imported

# Create a Flask blueprint
app = Blueprint('view_feedback', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()  # Open a new connection for each request
cursor = connection.cursor()

# Enable CORS for the blueprint
CORS(app, resources={r"/*": {"origins": "*"}})

# Fetch feedbacks and join with Customer table to get customer name and Lookup table for feedback type
@app.route('/get-feedbacks', methods=['GET'])
def get_feedbacks():

    try:

        # SQL query to join Feedback and Lookup table on Type
        query = """
        SELECT CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName, 
               L.Value AS FeedbackType, 
               F.Feedback, 
               F.Rating, 
               F.FeedbackID AS FeedbackId
        FROM Feedback F
        JOIN Customer C ON F.CustomerId = C.CustomerID
        JOIN Lookup L ON F.Type = L.Id  -- Joining with Lookup table
        WHERE L.Category = 'FeedBackType'  -- Ensure we're filtering by the correct category
        """
        cursor.execute(query)
        feedbacks = cursor.fetchall()

        # Prepare response data
        feedback_list = [
            {
                'customerName': feedback[0],  # CustomerName (concatenated)
                'feedbackType': feedback[1],   # Feedback Type fetched from Lookup
                'feedback': feedback[2],        # Feedback text
                'rating': feedback[3],          # Rating
                'feedbackId': feedback[4]       # Feedback ID
            }
            for feedback in feedbacks
        ]

        return jsonify({'feedbacks': feedback_list}), 200

    except Exception as e:
        print(f"Error fetching feedbacks: {e}")
        return jsonify({'error': str(e)}), 500

# Flask app entry point
if __name__ == '__main__':
    from flask import Flask
    app_instance = Flask(__name__)
    app_instance.register_blueprint(app, url_prefix='/feedback')  # Use a URL prefix for organization

    # Debugging and auto-reload are enabled for development purposes
    app_instance.run(host='0.0.0.0', port=5000, debug=True)
