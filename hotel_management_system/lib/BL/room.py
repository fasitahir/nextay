from datetime import datetime

class Room:
    def __init__(
        self, room_type, price_per_day, room_area, floor_number,
        max_occupancy, bed_type, room_status, image_id,
        last_cleaned, last_maintenance_date, 
        added_by=None, updated_by=None
    ):
        self.room_type = room_type
        self.price_per_day = price_per_day
        self.room_area = room_area
        self.floor_number = floor_number
        self.max_occupancy = max_occupancy
        self.bed_type = bed_type
        self.room_status = getRoomStatusCode(room_status)
        self.image_id = image_id
        self.last_cleaned = parseDate(last_cleaned)
        self.last_maintenance_date = parseDate(last_maintenance_date)
        self.added_by = added_by  # Should be set based on the current user
        self.updated_by = updated_by  # Should be set based on the current user

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

def getRoomStatus(status_code):
    code_mapping = {
        1: 'Available',
        2: 'Occupied',
        3: 'Under Maintenance',
        4: 'Reserved',
        99: 'Deleted'
    }
    return code_mapping.get(status_code, 'Unknown')
