from flask import Flask, Blueprint, jsonify
import json
import DB_config as db
from Room import Rooms
from flask_cors import CORS

app = Blueprint('rooms',__name__)
CORS(app, resources={r"/": {"origins": ""}}, methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

def read_Data():
    cursor.execute("SELECT * FROM Rooms")
    rows = cursor.fetchall()
    rooms = []
    for row in rows:
        room = Rooms(row[1], row[2], row[5], row[6], row[7], row[8], row[9], row[3] ,row[10], row[0])
        rooms.append(room)

    rooms_list = [
        {
            "id": room.room_id,
            "type": room.room_type,
            "status": room.statusIntoString(),
            "last_cleaned": room.last_cleaned,
            "needCleaning": room.needCleaning(),
            "price_per_day": room.room_price,
            "room_area": room.room_area,
            "floor_number": room.floor_number,
            "max_occupancy": room.max_occupancy,
            "bed_type": room.bed_type,
            "last_maintenance_date": room.last_maintenance,
        }
        for room in rooms
    ]

    return rooms_list

@app.route('/')
def home():
    return "Welcome to the Hotel Management API! Use /rooms to access room data."

@app.route('/rooms')
def get_rooms():
    data = read_Data()
    return data


@app.route('/rooms/<int:room_id>/checkin', methods=['PUT'])
def check_in_room(room_id):
    try:
        print(f"Attempting to check in room with ID: {room_id}")  # Debug info
        cursor.execute("UPDATE Rooms SET RoomStatus = 2 WHERE RoomID = ?", (room_id,))
        connection.commit()
        print("Room checked in successfully")
        return jsonify({'message': 'Room checked in successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")  # Debugging the error
        return jsonify({'error': str(e)}), 500



@app.route('/rooms/<int:room_id>/clean', methods=['PUT'])
def clean_room(room_id):
    try:
        # Debugging info
        print(f"Attempting to clean room with ID: {room_id}")
        
        # Update the RoomStatus for the given room_id
        cursor.execute("UPDATE Rooms SET RoomStatus = 1 WHERE RoomID = ?", (room_id,))
        connection.commit()
        
        print("Room cleaned successfully")
        return jsonify({'message': 'Room cleaned successfully'}), 200
    except Exception as e:
        # Debugging the error
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/rooms/<int:room_id>/checkout', methods=['PUT'])
def check_out_room(room_id):
    try:
        # Debugging info
        print(f"Attempting to check out room with ID: {room_id}")
        
        # Update the RoomStatus for the given room_id
        cursor.execute("UPDATE Rooms SET RoomStatus = 3 WHERE RoomID = ?", (room_id,))
        connection.commit()
        
        print("Room checked out successfully")
        return jsonify({'message': 'Room checked out successfully'}), 200
    except Exception as e:
        # Debugging the error
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '_main_':
    app.run(debug=True, host='0.0.0.0', port='5000')