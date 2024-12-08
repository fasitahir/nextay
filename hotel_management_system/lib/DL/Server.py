# server.py
from flask import Flask
from flask_cors import CORS
import DB_config as db
import os
from dotenv import load_dotenv




from Room_dl import app as rooms_app
from Login import app as login_app
from employee_dl import app as employee_app
from Add_Feedback_dl import app as feedback_app
from ViewFeedback_dl import app as view_feedback_app
from Salary_dl import app as salary_app
from Room_dl import app as room_app
from promotion_dl import app as promotion_app
from Expense import app as expense_app
from customer_dl import app as customer_app

# Initialize the main Flask app
app = Flask(__name__)

CORS(app)
# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()

# Register blueprints for login and feedback
app.register_blueprint(login_app, url_prefix='/')
app.register_blueprint(employee_app, url_prefix='/')
app.register_blueprint(feedback_app, url_prefix='/')
app.register_blueprint(view_feedback_app, url_prefix='/')
app.register_blueprint(salary_app, url_prefix='/')
app.register_blueprint(room_app, url_prefix='/')
app.register_blueprint(promotion_app, url_prefix='/')
app.register_blueprint(expense_app,url_prefix='/')
app.register_blueprint(customer_app,url_prefix='/')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=os.getenv('PORT'))
