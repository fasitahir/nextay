class Rooms:
    def __init__(self, room_type, room_status, room_price, room_area, floor_number, max_occupancy, bed_type, last_cleaned=None, last_maintenance=None, room_id=None):
        self.room_type = room_type
        self.room_status = room_status
        self.room_price = room_price
        self.room_area = room_area
        self.floor_number = floor_number
        self.max_occupancy = max_occupancy
        self.bed_type = bed_type
        self.last_cleaned = last_cleaned
        self.last_maintenance = last_maintenance
        self.room_id = room_id