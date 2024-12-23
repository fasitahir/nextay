from dotenv import load_dotenv
import os
import pyodbc

load_dotenv(dotenv_path='environment.env')


class Configration:
    _instance = None

    def __init__(self):
        self.connect_str = (
            'DRIVER={ODBC Driver 17 for SQL Server};'
            f'SERVER={os.getenv("AZURE_SQL_SERVER")};'
            f'DATABASE={os.getenv("AZURE_SQL_DATABASE")};'
            f'UID={os.getenv("AZURE_SQL_USERNAME")};'
            f'PWD={os.getenv("AZURE_SQL_PASSWORD")};'
        )
        try:
            self.connection = pyodbc.connect(self.connect_str)
            print("Connection successful!")
        except pyodbc.Error as ex:
            print(f"Error: {ex}")
            self.connection = None

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
    
    def get_connection(self):
        return self.connection


# Create an instance to check connection
config = Configration()

# Test the connection by running a simple query
if config.get_connection():
    cursor = config.get_connection().cursor()
    try:
        cursor.execute("SELECT * FROM Employee")  # Simple query to test the connection
        print("Connection is working!")
    except Exception as e:
        print(f"Error during query execution: {e}")