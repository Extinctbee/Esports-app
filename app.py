from flask import Flask, abort, render_template
from db import get_connection

app = Flask(__name__)

# Default route to display the home page
@app.route("/")
def home():

    # Connect to the database
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            # Execute a simple query to check the connection
            cursor.execute("SHOW TABLES;")
            rows = cursor.fetchall()

        tableNames = [next(iter(row.values())) for row in rows]
    finally:
        connection.close()

    return render_template("index.html", tableNames=tableNames)

# Route For University Proifles.
@app.route("/University/<int:uID>")
def university(uID):

    # Connect to the database
    connection = get_connection()
    
    try:
        with connection.cursor() as cursor:
            # Query the database for the university data entity based on the provided UniversityName
            numRowsAffected = cursor.execute( "Select * from University WHERE uID = %s", (uID,))

            # Fetch the university data entity from the query result
            university = cursor.fetchone()
    finally:
        connection.close()

    #Verify if the university data entity was found
    if university is None:
        abort(404, description= (f"University with ID '{uID}' not found.") ) #Display a 404 error if the university data entity was not found

    return render_template("university.html", currentUniversity=university)