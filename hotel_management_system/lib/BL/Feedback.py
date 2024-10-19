# feedback.py
from datetime import datetime

class Feedback:
    def __init__(self, CustomerId, Feedback, Rating, Type, DateSubmitted=None, Status="Pending"):
        self.CustomerId = CustomerId
        self.Feedback = Feedback
        self.Rating = Rating
        self.Type = Type
        self.DateSubmitted =  datetime.now()
        self.Status = Status
