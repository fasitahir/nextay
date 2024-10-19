from flask import Blueprint, request, jsonify
import DB_config as db
from datetime import datetime
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
import lib.BL.employee as employeeFunctions 

# Create a Flask blueprint for salary operations
app = Blueprint('salary', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

# Route to fetch all employees with their details (for display in the Flutter UI)
@app.route('/employee_data', methods=['GET'])
def get_employees():
    try:
        cursor.execute("""
        SELECT e.Id, e.FirstName, e.LastName, e.SalaryAmount, e.ContactNo, e.IsPaid, l.value
        FROM Employee e
        INNER JOIN EmployeeDesignation d ON e.Id = d.EmployeeId
        join Lookup l on d.Position=l.Id
                       

        """)
        
        employees = cursor.fetchall()
        employee_list = []
        
        for emp in employees:
            employee_list.append({
                'id': emp[0],
                'first_name': emp[1],
                'last_name': emp[2],
                'salary': float(emp[3]),
                'contact': emp[4],
                'is_paid': emp[5],
                'Position': emp[6],
            })
        
        return jsonify(employee_list), 200
    
    except Exception as e:
        print(f"Error fetching employees: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/pay_salary', methods=['POST'])
def pay_salary():
    data = request.get_json()

    try:
        # Extract data from the request
        employee_id = data['employee_id']
        salary = data['salary']
        incentive = data.get('incentive', None)
        incentive_description = data.get('incentive_description', None)
        pay_date = data['pay_date']
        paid_by = None

        # Convert pay_date to datetime object
        pay_date = datetime.strptime(pay_date, '%Y-%m-%d').date()

        # Update Employee table to set is_paid to 23
        cursor.execute("""
        UPDATE Employee
        SET IsPaid = 23
        WHERE Id = ?
        """, (employee_id,))

        # Insert salary record into the Salary table
        cursor.execute("""
        INSERT INTO Salary (EmployeeId, PayDate, Incentive, IncentiveDescription, IncrementDate, Paidby)
        VALUES (?, ?, ?, ?, NULL, ?)
        """, (employee_id, pay_date, incentive, incentive_description, paid_by))

        # Commit the transaction
        connection.commit()

        return jsonify({'message': 'Salary paid successfully!'}), 201

    except Exception as e:
        print(f"Error paying salary: {e}")
        connection.rollback()  # Rollback in case of error
        return jsonify({'error': str(e)}), 500