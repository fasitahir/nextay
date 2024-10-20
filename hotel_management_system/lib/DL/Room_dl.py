from flask import Blueprint, request, jsonify
import DB_config as db
import os
from dotenv import load_dotenv
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from lib.BL.room import Room, getRoomStatusCode, parseDate
import lib.BL.room as roomFunctions
from datetime import datetime

# Create a Flask blueprint
app = Blueprint('room_dl', __name__)

# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

@app.route('/room', methods=['POST'])
def add_room():
    try:
        data = request.json
        print(f"Received data: {data}")  # Log incoming data

        # Check if all required fields are present
        required_fields = [
            'room_type', 'price_per_day', 'room_area', 'floor_number',
            'max_occupancy', 'bed_type', 'room_status', 'image_id',
            'last_cleaned', 'last_maintenance_date'
        ]
        if not all(key in data for key in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        # Extract the room data
        room = Room(
            room_type=data['room_type'],
            price_per_day=data['price_per_day'],
            room_area=data['room_area'],
            floor_number=data['floor_number'],
            max_occupancy=data['max_occupancy'],
            bed_type=data['bed_type'],
            room_status=data['room_status'],
            image_id=data['image_id'],
            last_cleaned=data['last_cleaned'],
            last_maintenance_date=data['last_maintenance_date']
        )

        # Insert room into the database
        cursor.execute(
            """INSERT INTO Rooms 
            (RoomType, PricePerDay, RoomArea, FloorNumber, MaxOccupancy, BedType, RoomStatus, ImageId, LastCleaned, LastMaintenanceDate, Addedby, Updatedby)
            OUTPUT INSERTED.RoomID
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                room.room_type, room.price_per_day, room.room_area, room.floor_number,
                room.max_occupancy, room.bed_type, room.room_status, room.image_id,
                room.last_cleaned, room.last_maintenance_date, room.added_by, room.updated_by
            )
        )
        room_id = cursor.fetchone()[0]

        connection.commit()

        return jsonify({'message': 'Room added successfully!', 'room_id': room_id}), 201
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/rooms', methods=['GET'])
def get_rooms():
    try:
        cursor.execute(""" 
            SELECT R.RoomID, RoomType, PricePerDay, RoomArea, FloorNumber, 
                   MaxOccupancy, BedType, l.Value as RoomStatus, ImageId, 
                   LastCleaned, LastMaintenanceDate 
            FROM Rooms R
            LEFT JOIN Lookup l ON l.Id = R.RoomStatus
        """)
        rooms = cursor.fetchall()

        room_list = []
        for room in rooms:
            room_list.append({
                'room_id': room[0],
                'room_type': room[1],
                'price_per_day': room[2],
                'room_area': room[3],
                'floor_number': room[4],
                'max_occupancy': room[5],
                'bed_type': room[6],
                'room_status': room[7],
                'image_id': room[8],
                'last_cleaned': room[9].strftime("%Y-%m-%d") if room[9] else None,
                'last_maintenance_date': room[10].strftime("%Y-%m-%d") if room[10] else None
            })

        return jsonify(room_list), 200
    except Exception as e:
        print(f"Error fetching rooms: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/room/<int:room_id>', methods=['PUT'])
def update_room(room_id):
    if request.method == 'OPTIONS':
        # Handle CORS preflight request
        return jsonify({'message': 'CORS preflight response'}), 200

    try:
        data = request.json
        print(f"Updating room {room_id} with data: {data}")

        # Check if required fields are present
        required_fields = ['room_type', 'price_per_day']
        if not all(key in data for key in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        # Extract the updated room data
        room_type = data.get('room_type')
        price_per_day = data.get('price_per_day')
        room_area = data.get('room_area')
        floor_number = data.get('floor_number')
        max_occupancy = data.get('max_occupancy')
        bed_type = data.get('bed_type')
        room_status = data.get('room_status')
        image_id = data.get('image_id')
        last_cleaned = data.get('last_cleaned')
        last_maintenance_date = data.get('last_maintenance_date')
        updated_by = data.get('updated_by', None)

        # Build the update statement dynamically
        fields = []
        values = []

        if room_type is not None:
            fields.append("RoomType = ?")
            values.append(room_type)
        if price_per_day is not None:
            fields.append("PricePerDay = ?")
            values.append(price_per_day)
        if room_area is not None:
            fields.append("RoomArea = ?")
            values.append(room_area)
        if floor_number is not None:
            fields.append("FloorNumber = ?")
            values.append(floor_number)
        if max_occupancy is not None:
            fields.append("MaxOccupancy = ?")
            values.append(max_occupancy)
        if bed_type is not None:
            fields.append("BedType = ?")
            values.append(bed_type)
        if room_status is not None:
            fields.append("RoomStatus = ?")
            values.append(getRoomStatusCode(room_status))
        if image_id is not None:
            fields.append("ImageId = ?")
            values.append(image_id)
        if last_cleaned is not None:
            fields.append("LastCleaned = ?")
            values.append(parseDate(last_cleaned))
        if last_maintenance_date is not None:
            fields.append("LastMaintenanceDate = ?")
            values.append(parseDate(last_maintenance_date))
        
        # Update 'UpdatedBy' field
        if updated_by is not None:
            fields.append("UpdatedBy = ?")
            values.append(updated_by)

        if not fields:
            return jsonify({'error': 'No fields to update'}), 400

        # Create the update query
        update_query = f"UPDATE Rooms SET {', '.join(fields)} WHERE RoomID = ?"
        values.append(room_id)

        cursor.execute(update_query, tuple(values))
        connection.commit()

        return jsonify({'message': 'Room updated successfully!'}), 200
    except Exception as e:
        print(f"Error updating room: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/room/<int:room_id>', methods=['DELETE'])
def delete_room(room_id):
    try:
        deleted_status_id = 99  # Example ID for 'Deleted' status
        cursor.execute(
            """UPDATE Rooms 
               SET RoomStatus = ?, Updatedby = ? 
               WHERE RoomID = ?""",
            (deleted_status_id, None, room_id)
        )

        connection.commit()

        return jsonify({'message': 'Room deleted (soft delete) successfully!'}), 200
    except Exception as e:
        print(f"Error deleting room: {e}")
        return jsonify({'error': str(e)}), 500
