from flask import Flask, jsonify
import json
import DB_config as db
from Room import Rooms
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

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

if __name__ == '__main__':
    app.run(debug=True)
