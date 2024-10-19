# server.py
from flask import Flask
from flask_cors import CORS
import DB_config as db
import os
from dotenv import load_dotenv



from Rooms_dl import app as rooms_app
from Login import app as login_app
from employee_dl import app as employee_app
# Initialize the main Flask app
app = Flask(__name__)
CORS(app)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()

# Register blueprints for login and feedback
app.register_blueprint(rooms_app, url_prefix='/')
app.register_blueprint(login_app, url_prefix='/')
app.register_blueprint(employee_app, url_prefix='/')



if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=os.getenv('PORT'))
