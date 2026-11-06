from flask import Flask, abort, render_template, request
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

# Route For University Profiles.
@app.route("/university/<int:uID>")
def university(uID):

    # Connect to the database
    connection = get_connection()
    
    try:
        with connection.cursor() as cursor:
            # Fetch the university data entity based on the provided UniversityID
            numRowsAffected = cursor.execute( "Select * from University WHERE uID = %s", (uID,))
            university = cursor.fetchone()

            #Fetch all teams associated with the university
            numRowsAffected = cursor.execute( "SELECT t.tID, t.tName, t.tSkillLevel, g.gtName FROM Team AS t JOIN GameTitle AS g ON t.gtID = g.gtID WHERE t.uID = %s ORDER BY g.gtName, t.tName", (uID,))
            teams = cursor.fetchall()

            #Fetch all active players associated with the university's teams
            cursor.execute("""
                SELECT
                    tm.aUID,
                    tm.gamerTag,
                    tm.bio,
                    tm.major,
                    au.auFirstName,
                    au.auLastName,
                    t.tName,
                    gt.gtName,
                    tms.tmsTeamRole
                FROM TeamMember AS tm
                JOIN TeamMembership AS tms
                    ON tm.aUID = tms.aUID
                JOIN TeamSeason AS ts
                    ON tms.sID = ts.sID
                JOIN Team AS t
                    ON ts.tID = t.tID
                JOIN GameTitle AS gt
                    ON t.gtID = gt.gtID
                JOIN AccountUser AS au
                    ON tm.aUID = au.aUID
                WHERE t.uID = %s
                ORDER BY gt.gtName, t.tName, tm.gamerTag
            """, (uID,))
            activePlayers = cursor.fetchall()

            #fetch all university updates associated with the university
            cursor.execute("SELECT * FROM UniversityUpdate WHERE uID = %s ORDER BY uuDatePosted DESC", (uID,))
            universityUpdates = cursor.fetchall()
    finally:
        connection.close()

    #Verify if the university data entity was found
    if university is None:
        abort(404, description= (f"University with ID '{uID}' not found.") ) #Display a 404 error if the university data entity was not found

    return render_template("university.html", currentUniversity=university, teams=teams, activePlayers=activePlayers, updates=universityUpdates)

# Route for University Profile Results
@app.route("/search/")
def search_university():
    # Get the search query from the request arguments
    uName = request.args.get("q", "").strip()

    # Connect to the database
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            # Query the database for the university data entity based on the provided UniversityName
            cursor.execute("Select * from University WHERE uName LIKE %s", (f"%{uName}%",))
            universities = cursor.fetchall()
    finally:
        connection.close()

    # Verify if the university data entity was found
    if universities is None or len(universities) == 0:
        abort(404, description=(f"University with name '{uName}' not found. University may not be listed in the hub."))  # Display a 404 error if the university data entity was not found

    return render_template("university_results.html", universities=universities, searchQuery=uName)

# Route for the Join Hub page
@app.route("/join")
def join():
    return render_template("join.html")

#Keep below all routes for the main application entry point
#Alternative to running app through CLI command in terminal: python -m flask --app app run --debug
if __name__ == "__main__":
    app.run(debug=True)

