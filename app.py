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
            cursor.execute("Select * from University")
            rows = cursor.fetchall()

        universites = rows
    finally:
        connection.close()

    return render_template("index.html", universites=universites)

# Route For University Proifles.
@app.route("/university/<int:uID>")
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

# Route for the Join Hub page
@app.route("/join")
def join():
    return render_template("join.html")
if __name__ == "__main__":
    app.run(debug=True)

#Example Route
@app.route("/post_update", methods=["POST"])
def post_update():
    # Connect to the database
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            # Example query to insert a new university update
            cursor.execute(
                "INSERT INTO UniversityUpdate (uID, staffAuID, uuTitle, uuInfo) VALUES (%s, %s, %s, %s)",
                (1, 1, "New Update Title", "Details of the update.")
            )
            connection.commit()
    finally:
        connection.close()

    return "Update posted successfully."