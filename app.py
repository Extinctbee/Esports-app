from flask import Flask, abort, render_template, redirect, url_for, request
from db import get_connection

app = Flask(__name__)

# Enable only for local demonstrations.
app.config["DEMO_MODE"] = True

# Default route to display the home page
@app.route("/")
def home():

    # Connect to the database
    connection = get_connection()

    try:
        with connection.cursor() as cursor:

            
            # Execute a simple query to check the connection
            cursor.execute("Select * from University LIMIT 10")
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
    search = request.args.get("q", "").strip()
    searchPattern = f"%{search}%"

    # Connect to the database
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            # Query the database for the university data entity based on the provided UniversityName

            cursor.execute("""
                SELECT u.*
                FROM University AS u
                WHERE
                    u.uName LIKE %s
                    OR u.uState LIKE %s
                    OR u.uCity LIKE %s
                    OR EXISTS (
                        SELECT 1
                        FROM Team AS t
                        JOIN GameTitle AS g ON t.gtID = g.gtID
                        WHERE t.uID = u.uID
                        AND g.gtName LIKE %s
                    )
                ORDER BY u.uName
            """, (
                searchPattern,
                searchPattern,
                searchPattern,
                searchPattern
            ))
    finally:
        connection.close()

    universities = cursor.fetchall()

    # Verify if the university data entity was found
    if universities is None or len(universities) == 0:
        abort(404, description=(f"University with name/state/city/gametitles '{search}' not found. University may not be listed in the hub."))  # Display a 404 error if the university data entity was not found

    return render_template("university_results.html", universities=universities, searchQuery=search)

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

            #Fetch all team events
            numRowsAffected = cursor.execute("Select * from TeamSeasonMatches Where tID = %s AND mStartDate >= CURDATE()", (tID,))
            teamSchedule = cursor.fetchall()

            #Fetch all teams seasons
            numRowsAffected = cursor.execute("Select * from TeamSeason where tID = %s", (tID,))
            teamsSeasons = cursor.fetchall()
    finally:
        connection.close()

    #Verify if the team data entity was found
    if team is None:
        abort(404, description=(f"Team with ID '{tID}' not found."))  # Display a 404 error if the team data entity was not found

    return render_template("team.html", currentTeam=team, players=players, currentUniversity=teamUniversity, teamSchedule = teamSchedule, teamsSeasons = teamsSeasons)

# Route for a specific team's season page
@app.route("/team/season/<int:sID>")
def teamSeason(sID):
    connection = get_connection()

    try:
        with connection.cursor() as cursor:

            # Get the selected season
            cursor.execute(
                "SELECT * FROM TeamSeason WHERE sID = %s",
                (sID,)
            )
            currentSeason = cursor.fetchone()

            if currentSeason is None:
                abort(404)

            # Get the team and its game title
            cursor.execute("""
                SELECT t.*, g.gtName
                FROM Team AS t
                JOIN GameTitle AS g ON t.gtID = g.gtID
                WHERE t.tID = %s
            """, (currentSeason["tID"],))
            currentTeam = cursor.fetchone()

            # Get the university for the shared sidebar
            cursor.execute(
                "SELECT * FROM University WHERE uID = %s",
                (currentTeam["uID"],)
            )
            currentUniversity = cursor.fetchone()

            # Get this season's players
            cursor.execute(
                "SELECT * FROM PlayerSeasons WHERE sID = %s",
                (sID,)
            )
            players = cursor.fetchall()

            # Get ALL matches for this season
            cursor.execute("""
                SELECT *
                FROM TeamSeasonMatches
                WHERE sID = %s
                ORDER BY mStartDate ASC
            """, (sID,))
            teamSchedule = cursor.fetchall()

    finally:
        connection.close()

    return render_template(
        "team_season.html",
        currentSeason=currentSeason,
        currentTeam=currentTeam,
        currentUniversity=currentUniversity,
        players=players,
        teamSchedule=teamSchedule
    )


# Route for the Join Hub page
@app.route("/join", methods=["GET", "POST"])
def join():

    if request.method == "POST":
        firstName = request.form.get("first_name", "").strip()
        lastName = request.form.get("last_name", "").strip()
        email = request.form.get("email", "").strip()
        password = request.form.get("password_request", "").strip()

        universityName = request.form.get("university_name", "").strip()
        universityState = request.form.get("university_state", "").strip()
        universityCity = request.form.get("university_city", "").strip()

        # Basic server-side validation.
        if not all((firstName, lastName, email,
                    universityName, universityState, universityCity)):
            abort(400, "All fields are required.")

        connection = get_connection()

        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO UniversityProfileAccountRequest (
                        uarFirstName,
                        uarLastName,
                        uarEmail,
                        uarHashPass,
                        uarUniversityName,
                        uarState,
                        uarCity
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (
                    firstName,
                    lastName,
                    email,
                    password,
                    universityName,
                    universityState,
                    universityCity
                ))

            connection.commit()

        except Exception:
            connection.rollback()
            raise

        finally:
            connection.close()

        # Redirect to the site's homepage after successful insertion.
        return redirect("/?request_submitted=1")


    
    return render_template("join.html", demo_mode=app.config.get("DEMO_MODE", False))

@app.route("/demo/verify-university-requests", methods=["POST"])
def force_verify_requests():

    # Never expose this action to regular website visitors.
    if (not app.config.get("DEMO_MODE")
            or request.remote_addr not in ("127.0.0.1", "::1")):
        abort(403)

    connection = get_connection()

    try:
        with connection.cursor() as cursor:

            # Find requests awaiting approval.
            cursor.execute("""
                SELECT uarID, uarUniversityName, uarState, uarCity
                FROM UniversityProfileAccountRequest
                WHERE uarStatus = 'Pending'
                FOR UPDATE
            """)
            pendingRequests = cursor.fetchall()

            for universityRequest in pendingRequests:

                # Generate a university profile if it doesn't already exist.
                cursor.execute("""
                    INSERT INTO University (uName, uState, uCity)
                    VALUES (%s, %s, %s)
                    ON DUPLICATE KEY UPDATE uID = uID
                """, (
                    universityRequest["uarUniversityName"],
                    universityRequest["uarState"],
                    universityRequest["uarCity"]
                ))

                # Mark the request as processed.
                cursor.execute("""
                    UPDATE UniversityProfileAccountRequest
                    SET uarStatus = 'Approved'
                    WHERE uarID = %s
                """, (universityRequest["uarID"],))

        connection.commit()

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()

    return redirect(url_for("join", approved=len(pendingRequests)))

#Keep below all routes for the main application entry point
#Alternative to running app through CLI command in terminal: python -m flask --app app run --debug
if __name__ == "__main__":
    app.run(debug=True)

