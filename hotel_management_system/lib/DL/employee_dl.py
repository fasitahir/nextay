from flask import Blueprint, request, jsonify
import DB_config as db
import os
from dotenv import load_dotenv
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from lib.BL.employee import Employee, User, Designation
import lib.BL.employee as employeeFunctions
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
        required_fields = ['first_name',  'email', 'cnic', 'phone_number','dob' ,'salary','shift' ,'username', 'password', 'designation', 'shift']
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
        dob = data.get('dob')
        addedBy = data.get('addedBy')


        # Create Employee object
        employee = Employee(first_name, last_name, email, cnic, phone_number, salary, username, password, designation, shift, dob, addedBy)
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
    

@app.route('/employees', methods=['GET'])
def get_employees():
    try:
        cursor.execute("SELECT E.Id, FirstName, LastName, Email, l.Value as Shift, l2.Value as Role FROM Employee E JOIN Lookup l ON l.Id = E.Shift JOIN EmployeeDesignation ED ON ED.EmployeeId = E.Id JOIN Lookup l2 ON ED.Position = l2.Id WHERE isActive != 24")
        employees = cursor.fetchall()

        employee_list = []
        for emp in employees:
            employee_list.append({
                'id': emp[0],
                'first_name': emp[1],
                'last_name': emp[2],
                'email': emp[3],
                'shift': emp[4],
                'role': emp[5]
            })

        return jsonify(employee_list), 200
    except Exception as e:
        print(f"Error fetching employees: {e}")
        return jsonify({'error': str(e)}), 500



@app.route('/employee/<int:employee_id>', methods=['PUT'])
def update_employee(employee_id):
    try:
        data = request.json
        print(f"Updating employee {employee_id} with data: {data}")

        # Check if all required fields are present
        required_fields = ['first_name', 'last_name', 'email', 'shift', 'role']
        if not all(key in data for key in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        # Extract the updated employee data
        first_name = data['first_name']
        last_name = data['last_name']
        email = data['email']
        shift = employeeFunctions.ShiftCode(data['shift'])
        print(f"Role: {data['role']}")
        role = employeeFunctions.getPositionCode(data['role'])
        username = data['username']
        password = data['password']
        updatedBy = data.get('updatedBy')
        updatedDate = datetime.now()
        # Update employee information in the Employee table
        cursor.execute(
            """UPDATE Employee 
               SET FirstName=?, LastName=?, Email=?, Shift=?, Updatedby=? 
               WHERE Id=?""",
            (first_name, last_name, email, shift, updatedBy ,employee_id)
        )

        if role != 0:
            # Update employee role in the EmployeeDesignation table
            cursor.execute(
                """UPDATE EmployeeDesignation 
                SET Position=? 
                WHERE EmployeeId=?""",
                (role, employee_id)
            )

        # Update user credentials in the Users table
        if username and password:
            cursor.execute(
                """UPDATE Users 
                SET Username=?, Password=?, UpdateDate=?
                WHERE EmployeeID=?""",
                (username, password,updatedDate ,employee_id)
            )

        # Commit the changes to the database
        connection.commit()

        return jsonify({'message': 'Employee updated successfully!'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
    

@app.route('/employee/<int:employee_id>', methods=['DELETE'])
def delete_employee(employee_id):
    try:
        # Set isActive to 24 to mark employee as deleted
        cursor.execute(
            """UPDATE Employee 
               SET IsActive=? 
               WHERE Id=?""",
            (24, employee_id)
        )

        # Commit the changes to the database
        connection.commit()

        return jsonify({'message': 'Employee deleted (soft delete) successfully!'}), 200
    except Exception as e:
        print(f"Error deleting employee: {e}")
        return jsonify({'error': str(e)}), 500
