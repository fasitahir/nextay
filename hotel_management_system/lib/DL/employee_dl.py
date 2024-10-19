from flask import Blueprint, request, jsonify
import DB_config as db
import os
from dotenv import load_dotenv
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from lib.BL.employee import Employee, User, Designation
from datetime import datetime

# Create a Flask blueprint
app = Blueprint('employee_dl', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

@app.route('/employee', methods=['POST'])
def add_employee():
    try:
        data = request.json
        print(f"Received data: {data}")  # Log incoming data

        # Check if all required fields are present
        required_fields = ['first_name', 'last_name', 'email', 'cnic', 'phone_number', 'salary', 'username', 'password', 'designation', 'shift']
        if not all(key in data for key in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        # Extract the employee data
        first_name = data['first_name']
        last_name = data['last_name']
        email = data['email']
        cnic = data['cnic']
        phone_number = data['phone_number']
        salary = data['salary']
        username = data['username']
        password = data['password']
        designation = data['designation']
        shift = data['shift']
        dob = data.get('dob', datetime.now())



        # Create Employee object
        employee = Employee(first_name, last_name, email, cnic, phone_number, salary, username, password, designation, shift, dob)
        # Insert employee into the database
        cursor.execute(
            """INSERT INTO Employee (FirstName, LastName, CNIC,  ContactNo, Email, ProfilePhoto, DOB, Shift, IsActive, SalaryAmount, Ispaid, Addedby, Updatedby) 
            OUTPUT INSERTED.Id
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?)""",
            (employee.first_name, employee.last_name,employee.cnic , employee.phone_number,employee.email, employee.profilePicture, employee.dob, employee.shift, employee.isActive, employee.salary, employee.isPaid, employee.addedBy, employee.updatedBy)
        
        )
        employeeId = cursor.fetchone()[0]

        user = User(employeeId, username, password)
        cursor.execute("""
        INSERT INTO Users
        (EmployeeID, Username, Password) 
        VALUES (?, ?, ?)
        """, 
        (employeeId, user.username, user.password)
        )

        designationObj = Designation(employeeId, designation)
        cursor.execute("""
        INSERT INTO EmployeeDesignation
        (EmployeeId, Position,  PromotionDate) 
        VALUES (?, ?, ?)
        """, 
        (designationObj.employeeId, designationObj.position, designationObj.promotionDate)
        )

        connection.commit()


        return jsonify({'message': 'Employee added successfully!'}), 201
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
