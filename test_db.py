#Test Script To Check Database Connection
#Use ' python test_db.py ' to run this script in a terminal while flask app is running.
#To run the flask app, use ' python -m flask -app run --debug ' in a terminal first, THEN run this script in a separate terminal.

from db import get_connection

connection = get_connection()

try:
    with connection.cursor() as cursor:
        cursor.execute("SELECT DATABASE() AS db_name")
        result = cursor.fetchone()
        print("Connected to:", result["db_name"])
finally:
    connection.close()