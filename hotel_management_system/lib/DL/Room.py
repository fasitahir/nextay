class Rooms:
    def __init__(self, room_type, room_status, room_price, room_area, floor_number, max_occupancy, bed_type, last_cleaned, last_maintenance, room_id, check_in_time=None, check_out_time=None):
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
        self.check_in_time = check_in_time
        self.check_out_time = check_out_time

    def needCleaning(self):
        need = False
        if self.room_status == 3:
            need = True
            return need
        else:
            return need
        
    def statusIntoString(self):
        if self.room_status == 1:
            return "Available"
        elif self.room_status == 2:
            return "Occupied"
        elif self.room_status == 3:
            return "Dirty"
        else:
            return "Unknown"
        