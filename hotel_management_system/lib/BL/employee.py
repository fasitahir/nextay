from datetime import datetime

class Employee:
    def __init__(self, first_name, last_name, email, cnic, phone_number, salary, username, password, designation, shift, dob, isActive = 23, addedBy = None, updatedBy = None, profilePicture = None, isPaid = 24, promotionId = None, promotionDate = None):
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.cnic = cnic
        self.phone_number = phone_number
        self.salary = salary
        self.username = username
        self.password = password
        self.designation = designation
        self.shift = ShiftCode(shift)
        self.dob = dob if dob else datetime.now()  # Optional, current date if not provided
        self.isActive = isActive
        self.addedBy = addedBy
        self.updatedBy = updatedBy
        self.profilePicture = profilePicture
        self.isPaid = isPaid
        self.promotionId = promotionId
        self.promotionDate = promotionDate


def ShiftCode(shift):
    if shift == 'Morning':
        return 20
    elif shift == 'Afternoon':
        return 21
    elif shift == 'Night':
        return 22
    else:
        return 0
        
        
class User:
    def __init__(self, employeeId, username, password):
        self.employeeId = employeeId
        self.username = username
        self.password = password

class Designation:
    def __init__(self,employeeId , position, promotionId=None, promotionDate=None ):
        self.employeeId = employeeId
        self.promotionId = promotionId
        self.promotionDate = promotionDate
        self.position = getPositionCode(position)
    
def getPositionCode(position):
    if position == 'Manager':
        return 16
    elif position == 'Staff':
        return 15
    elif position == 'Finance Manager':
        return 17
    elif position == 'Janitor':
        return 19
    elif position == 'Chef':
        return 18
    else:
        return 0
