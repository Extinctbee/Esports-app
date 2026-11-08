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
            cursor.execute("Select * from UniversityPlayers WHERE uID = %s  ORDER BY gtName, tName, gamerTag", (uID,))
            activePlayers = cursor.fetchall()

            #fetch all university updates associated with the university
            cursor.execute("SELECT * FROM UniversityUpdate WHERE uID = %s ORDER BY uuDatePosted DESC", (uID,))
            universityUpdates = cursor.fetchall()

            #fetch overall university schedule for the university and all associated teams
            cursor.execute("SELECT * FROM UniversitySchedule WHERE uID = %s ORDER BY startDate DESC", (uID,))
            universitySchedule = cursor.fetchall()
    finally:
        connection.close()

    #Verify if the university data entity was found
    if university is None:
        abort(404, description= (f"University with ID '{uID}' not found.") ) #Display a 404 error if the university data entity was not found

    return render_template("university.html", currentUniversity=university, teams=teams, activePlayers=activePlayers, updates=universityUpdates, universitySchedule=universitySchedule)

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

# Route for the Player pages
@app.route("/player/<int:auID>")
def player(auID):
    # Implementation for player profile page
    # Connect to the database
    connection = get_connection()

    #Grab the palyer data entity based on the provided auID
    try:
        with connection.cursor() as cursor:
            # Fetch the player data entity based on the provided auID
            numRowsAffected = cursor.execute("SELECT * FROM TeamMember WHERE auID = %s", (auID,))
            player = cursor.fetchone()

            #Fetch all teams associated with the player
            numRowsAffected = cursor.execute("""
                SELECT t.tID, t.tName, t.tSkillLevel, g.gtName
                FROM Team AS t
                JOIN GameTitle AS g ON t.gtID = g.gtID
                JOIN TeamSeason AS ts ON t.tID = ts.tID
                JOIN TeamMembership AS tm ON ts.sID = tm.sID
                WHERE tm.auID = %s
                ORDER BY g.gtName, t.tName
            """, (auID,))
            teams = cursor.fetchall()

            numRowsAffected = cursor.execute("SELECT uID FROM universityPlayers where auID = %s", (auID,))
            universityID = cursor.fetchone()

            numRowsAffected = cursor.execute("SELECT * FROM University WHERE uID = %s", (universityID['uID'],)) if universityID else None
            playerUniversity = cursor.fetchone()

            numRowsAffected = cursor.execute("SELECT * FROM GamerConnections WHERE auID = %s", (auID,))
            gamerConnections = cursor.fetchall()
    finally:
        connection.close()

    #Verify tables queuries
    if player is None:
        abort(404, description=(f"Player with ID '{auID}' not found."))  # Display a 404 error if the player data entity was not found
    elif teams is None:
        abort(404, description=(f"Teams associated with player ID '{auID}' not found."))  # Display a 404 error if the teams data entity was not found
    elif playerUniversity is None:
        abort(404, description=(f"University '{universityID}' associated with player ID '{auID}' not found."))  # Display a 404 error if the university data entity was not found
    #else:
       # print(f"Player ID: {aUID}, Player: {player}, Teams: {teams}, University: {playerUniversity}")
    

    return render_template("player.html", currentPlayer=player, teams=teams, currentUniversity=playerUniversity, gamerConnections=gamerConnections)

# Route for the Team pages
@app.route("/team/<int:tID>")
def team(tID):
    # Connect to the database
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            # Fetch the team data entity based on the provided tID
            numRowsAffected = cursor.execute("SELECT * FROM Team WHERE tID = %s", (tID,))
            team = cursor.fetchone()

            #Fetch all players associated with the team
            numRowsAffected = cursor.execute("Select * From UniversityPlayers where tID = %s", (tID,))
            players = cursor.fetchall()

            #Fetch the university associated with the team
            numRowsAffected = cursor.execute("SELECT uID FROM Team WHERE tID = %s", (tID,))
            universityID = cursor.fetchone()
            numRowsAffected = cursor.execute("SELECT * FROM University WHERE uID = %s", (universityID['uID'],)) if universityID else None
            teamUniversity = cursor.fetchone()
    finally:
        connection.close()

    #Verify if the team data entity was found
    if team is None:
        abort(404, description=(f"Team with ID '{tID}' not found."))  # Display a 404 error if the team data entity was not found

    return render_template("team.html", currentTeam=team, players=players, currentUniversity=teamUniversity)

# Route for the Join Hub page
@app.route("/join")
def join():
    return render_template("join.html")

#Keep below all routes for the main application entry point
#Alternative to running app through CLI command in terminal: python -m flask --app app run --debug
if __name__ == "__main__":
    app.run(debug=True)

