# lib/BL/room.py
from datetime import datetime

def getRoomStatusCode(status):
    status_mapping = {
        'Available': 1,
        'Occupied': 2,
        'Under Maintenance': 3,
        'Reserved': 4,
        'Deleted': 99  # Example code for deleted status
    }
    return status_mapping.get(status, 0)  # Returns 0 if status is unknown

def parseDate(date_str):
    try:
        return datetime.fromisoformat(date_str)
    except ValueError:
        return datetime.now()  # Default to current date if parsing fails

def formatDate(date):
    return date.strftime("%Y-%m-%d") if date else None

class Room:
    def __init__(self, room_type, price_per_day, room_area, floor_number, max_occupancy, bed_type, room_status,
                 last_cleaned=None, last_maintenance_date=None, amenities=[], added_by=None, updated_by=None):
        self.room_type = room_type
        self.price_per_day = price_per_day
        self.room_area = room_area
        self.floor_number = floor_number
        self.max_occupancy = max_occupancy
        self.bed_type = bed_type
        self.room_status = room_status
        self.last_cleaned = parseDate(last_cleaned) if last_cleaned else None
        self.last_maintenance_date = parseDate(last_maintenance_date) if last_maintenance_date else None
        self.amenities = amenities
        self.added_by = added_by
        self.updated_by = updated_by
