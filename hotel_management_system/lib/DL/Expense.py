from flask import Blueprint, request, jsonify
import DB_config as db
from datetime import datetime
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
import lib.BL.employee as employeeFunctions 

# Create a Flask blueprint for expense operations
app = Blueprint('expense', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

@app.route('/add_expense', methods=['POST'])
def Add_Expense():
    data = request.get_json()  # Extract the JSON data sent in the request
    
    try:
        # Extract the values from the incoming request data
        amount = data.get('amount')  # Amount entered by the user
        category = data.get('category')  # Category selected by the user
        description = data.get('description')  # Description entered by the user
        date_str = data.get('date')  # Date entered by the user (in string format)

        # Validate the input data
        if not amount or not category or not description or not date_str:
            return jsonify({'error': 'Missing required fields'}), 400

        # Convert the date string into a datetime object
        try:
            pay_date = datetime.strptime(date_str, '%d/%m/%Y')  # Assuming the format is DD/MM/YYYY
        except ValueError:
            return jsonify({'error': 'Invalid date format, expected DD/MM/YYYY'}), 400

        # Check if the expense already exists for the given category and date
        cursor.execute("""
            SELECT COUNT(*)
            FROM Expense E
            WHERE Category = ? AND E.Date = ?
        """, (category, pay_date))

        count = cursor.fetchone()[0]
        print(f"Category: {category}, Pay Date: {pay_date}, Existing Record Count: {count}")

        if count == 0:
            # Insert new expense record if no record exists for this category and date
            note = f'{description}'
            cursor.execute("""
                INSERT INTO Expense (Date, Category, Amount, Notes)
                VALUES (?, ?, ?, ?)
            """, (pay_date, category, amount, note))

        elif count == 1:
            # Update existing record if one already exists for this category and date
            cursor.execute("""
                SELECT Notes
                FROM Expense
                WHERE Category = ? AND Date = ?
            """, (category, pay_date))
            existing_notes = cursor.fetchone()[0]
            new_notes = existing_notes + ', ' + description

            # Update the expense with the new amount and concatenated notes
            cursor.execute("""
                UPDATE Expense
                SET Amount = Amount + ?, Notes = ?
                WHERE Category = ? AND Date = ?
            """, (amount, new_notes, category, pay_date))

        # Commit the transaction to the database
        connection.commit()

        return jsonify({'message': 'Expense added successfully!'}), 201

    except Exception as e:
        print(f"Error adding expense: {e}")
        connection.rollback()  # Rollback in case of error
        return jsonify({'error': str(e)}), 500





@app.route('/get_expenses', methods=['GET'])
def Get_Expenses():
    try:
    
    
        
        cursor.execute("SELECT * FROM Expense") 

        expenses = cursor.fetchall()
        print(expenses)

        # If no expenses found, return a message
        if not expenses:
            return jsonify({'message': 'No expenses found'}), 404

        # Format the result into a list of dictionaries
        expense_list = []
        for expense in expenses:
            expense_list.append({
                'ExpenseID': expense[0],
                'Date': expense[1].strftime('%Y-%m-%d'),  # Convert datetime to string format
                'Category': expense[2],
                'Amount': float(expense[3]),
                'Notes': expense[4]
            })
        print(expense_list)    

        return jsonify({'expenses': expense_list}), 200

    except Exception as e:
        print(f"Error fetching expenses: {e}")
        return jsonify({'error': str(e)}), 500
