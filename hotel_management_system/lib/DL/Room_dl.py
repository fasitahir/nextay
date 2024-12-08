# room_dl.py
from flask import Blueprint, request, jsonify
import DB_config as db
import os
from dotenv import load_dotenv
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from lib.BL.room import Room, getRoomStatusCode, parseDate
import lib.BL.room as roomFunctions
from datetime import datetime
import logging


# Create a Flask blueprint
app = Blueprint('room_dl', __name__)
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# Database configuration
config = db.Configration.get_instance()
connection = config.get_connection()
cursor = connection.cursor()

@app.route('/room', methods=['POST'])
def add_room():
    try:
        data = request.json
        required_fields = [
            'room_type', 'price_per_day', 'room_area', 'floor_number',
            'max_occupancy', 'bed_type', 'room_status', 'amenities', 'added_by'
        ]
        if not all(key in data for key in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        room_status_code = getRoomStatusCode(data['room_status'])

        room = Room(
            room_type=data['room_type'],
            price_per_day=data['price_per_day'],
            room_area=data['room_area'],
            floor_number=data['floor_number'],
            max_occupancy=data['max_occupancy'],
            bed_type=data['bed_type'],
            room_status=room_status_code,
            amenities=data['amenities'],
            added_by=data['added_by'],
            updated_by=None
        )

        cursor.execute("""
            INSERT INTO Rooms 
            (RoomType, PricePerDay, RoomArea, FloorNumber, MaxOccupancy, BedType, RoomStatus, ImageId, LastCleaned, LastMaintenanceDate, AddedBy, UpdatedBy)
            OUTPUT INSERTED.RoomID
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            room.room_type, room.price_per_day, room.room_area, room.floor_number,
            room.max_occupancy, room.bed_type, room.room_status, None, None, None,
            room.added_by, room.updated_by
        ))

        room_id = cursor.fetchone()[0]
        print(f"Inserted RoomID: {room_id}")

        for amenity in room.amenities:
            cursor.execute("""
                INSERT INTO Amenities (RoomID, Name)
                VALUES (?, ?)
            """, (room_id, amenity))

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
            WHERE R.RoomStatus != 24
        """)
        rooms = cursor.fetchall()

        # If no rooms found, return a message
        if not rooms:
            return jsonify({'message': 'No rooms found'}), 404

        room_list = []
        for room in rooms:
            # Fetch amenities for each room
            cursor.execute("SELECT Name FROM Amenities WHERE RoomId = ?", (room[0],))
            amenities = [amenity[0] for amenity in cursor.fetchall()]

            # Debug: print fetched amenities for the current room
            print(f"Room {room[0]} amenities: {amenities}")

            room_list.append({
                'id': room[0],
                'room_type': room[1],
                'price_per_day': room[2],
                'room_area': room[3],
                'floor_number': room[4],
                'max_occupancy': room[5],
                'bed_type': room[6],
                'room_status': room[7],
                'image_id': room[8],
                'last_cleaned': room[9].strftime("%Y-%m-%d") if room[9] else None,
                'last_maintenance_date': room[10].strftime("%Y-%m-%d") if room[10] else None,
                'amenities': amenities  # Include amenities in the response
            })

        return jsonify(room_list), 200
    except Exception as e:
        print(f"Error fetching rooms: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/room/<int:room_id>', methods=['PUT'])
def update_room(room_id):
    if request.method == 'OPTIONS':
        return jsonify({'message': 'CORS preflight response'}), 200

    try:
        data = request.json
        print(f"Updating room {room_id} with data: {data}")

        # At least one field should be present
        updatable_fields = [
            'room_type', 'price_per_day', 'room_area', 'floor_number',
            'max_occupancy', 'bed_type', 'room_status',
            'last_cleaned', 'last_maintenance_date',
            'amenities', 'updated_by'
        ]
        if not any(key in data for key in updatable_fields):
            return jsonify({'error': 'No fields to update'}), 400

        # Extract the updated room data
        fields = []
        values = []

        if 'room_type' in data:
            fields.append("RoomType = ?")
            values.append(data['room_type'])
        if 'price_per_day' in data:
            fields.append("PricePerDay = ?")
            values.append(data['price_per_day'])
        if 'room_area' in data:
            fields.append("RoomArea = ?")
            values.append(data['room_area'])
        if 'floor_number' in data:
            fields.append("FloorNumber = ?")
            values.append(data['floor_number'])
        if 'max_occupancy' in data:
            fields.append("MaxOccupancy = ?")
            values.append(data['max_occupancy'])
        if 'bed_type' in data:
            fields.append("BedType = ?")
            values.append(data['bed_type'])
        if 'room_status' in data:
            fields.append("RoomStatus = ?")
            values.append(getRoomStatusCode(data['room_status']))
        if 'last_cleaned' in data:
            fields.append("LastCleaned = ?")
            values.append(parseDate(data['last_cleaned']))
        if 'last_maintenance_date' in data:
            fields.append("LastMaintenanceDate = ?")
            values.append(parseDate(data['last_maintenance_date']))
        if 'updated_by' in data:
            fields.append("UpdatedBy = ?")
            values.append(data['updated_by'])

        if fields:
            update_query = f"UPDATE Rooms SET {', '.join(fields)} WHERE RoomID = ?"
            values.append(room_id)
            cursor.execute(update_query, tuple(values))
            connection.commit()

        # Update Amenities if provided
        if 'amenities' in data:
            cursor.execute("DELETE FROM Amenities WHERE RoomId = ?", (room_id,))
            for amenity in data['amenities']:
                cursor.execute("INSERT INTO Amenities (RoomId, Name) VALUES (?, ?)", (room_id, amenity))
            connection.commit()

        return jsonify({'message': 'Room updated successfully!'}), 200
    except Exception as e:
        print(f"Error updating room: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/room/<int:room_id>', methods=['DELETE'])
def delete_room(room_id):
    try:
        # Get the employee ID from the request headers or query parameters
        updated_by = request.args.get('updated_by')
        
        # Get the code for "Deleted" status from your lookup table
        cursor.execute("SELECT Id FROM Lookup WHERE Value = 'False' AND Category = 'Status'")
        deleted_status = cursor.fetchone()
        
        if not deleted_status:
            return jsonify({'error': 'Deleted status not found in lookup table'}), 400
            
        deleted_status_id = deleted_status[0]
        
        # Update the room status to "Deleted" instead of actually deleting
        cursor.execute("""
            UPDATE Rooms 
            SET RoomStatus = ?, UpdatedBy = ? 
            WHERE RoomID = ? AND RoomStatus != ?
        """, (deleted_status_id, updated_by, room_id, deleted_status_id))
        
        if cursor.rowcount == 0:
            return jsonify({'error': 'Room not found or already deleted'}), 404
            
        connection.commit()
        return jsonify({'message': 'Room deleted (soft delete) successfully!'}), 200
        
    except Exception as e:
        print(f"Error deleting room: {e}")
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    
@app.route('/rooms/<int:room_id>/checkin', methods=['PUT'])
def check_in_room(room_id):
    try:
        logging.info(f"Checking in room with ID: {room_id}")
        cursor.execute("UPDATE Rooms SET RoomStatus = 2 WHERE RoomID = ?", (room_id,))
        connection.commit()
        logging.info("Room checked in successfully")
        return jsonify({'message': 'Room checked in successfully'}), 200
    except Exception as e:
        logging.error(f"Error checking in room: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/rooms/<int:room_id>/clean', methods=['PUT'])
def clean_room(room_id):
    try:
        logging.info(f"Cleaning room with ID: {room_id}")
        cursor.execute("UPDATE Rooms SET RoomStatus = 1 WHERE RoomID = ?", (room_id,))
        connection.commit()
        logging.info("Room cleaned successfully")
        return jsonify({'message': 'Room cleaned successfully'}), 200
    except Exception as e:
        logging.error(f"Error cleaning room: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/rooms/<int:room_id>/checkout', methods=['PUT'])
def check_out_room(room_id):
    try:
        logging.info(f"Checking out room with ID: {room_id}")
        cursor.execute("UPDATE Rooms SET RoomStatus = 3 WHERE RoomID = ?", (room_id,))
        connection.commit()
        logging.info("Room checked out successfully")
        return jsonify({'message': 'Room checked out successfully'}), 200
    except Exception as e:
        logging.error(f"Error checking out room: {e}")
        return jsonify({'error': str(e)}), 500
