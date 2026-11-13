from flask import Flask, abort, config, render_template, redirect, url_for, request, g, session
import os
from werkzeug.security import check_password_hash
from db import get_connection

app = Flask(__name__)

# Enable only for local demonstrations.
app.config["DEMO_MODE"] = True

# Load user details before requests
@app.before_request
def load_logged_in_user():
    #Clear g configs
    g.user = None
    g.userRoles = []
    g.player = None
    g.playerRoles = []

    # grab the current account logged in
    auID = session.get("auID")

    # no user logged in current session
    if auID is None: 
        return

    # connecto to fetch
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            #Get core account user info
            cursor.execute(
                "SELECT auID, auFirstName, auLastName, auEmail "
                "FROM AccountUser WHERE auID = %s",
                (auID,)
            )
            g.user = cursor.fetchone()

            if(g.user): 
                # Get all university affiliations and roles
                cursor.execute("""
                    SELECT *
                    FROM AccountUniversityRoles
                    WHERE auID = %s
                    AND uID IS NOT NULL
                    ORDER BY uName
                """, (auID,))
                g.userRoles = cursor.fetchall()

                # Get team member information, if this account is a TeamMember
                cursor.execute("""
                SELECT
                    tm.auID,
                    tm.gamerTag,
                    tm.bio,
                    tm.major,
                    gc.discordUser,
                    gc.epicGamesUser,
                    gc.riotGamesUser,
                    gc.steamUser,
                    gc.twitchUser
                FROM TeamMember AS tm
                LEFT JOIN GamerConnections AS gc
                    ON tm.auID = gc.auID
                WHERE tm.auID = %s
                """, (auID,))

                g.player = cursor.fetchone()

                cursor.execute("""
                SELECT tName, sTitle, tmsTeamRole
                FROM PlayerSeasons
                WHERE auID = %s
                AND sStartDate <= CURDATE()
                AND (sEndDate IS NULL OR sEndDate >= CURDATE())
                """, (auID,))

                g.playerRoles = cursor.fetchall()
            else:
                session.clear()
    finally:
        connection.close()


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

        featuredUniversites = rows
    finally:
        connection.close()

    if(app.config["DEMO_MODE"]):
        if("auID" in session):
            print(f"Session User ID: {session["auID"]}")
            print(f"g.User: {g.user["auFirstName"]}")

    return render_template("index.html", universites=featuredUniversites)

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
            numRowsAffected = cursor.execute( "SELECT Distinct t.tID, t.tName, t.tSkillLevel, g.gtName FROM Team AS t JOIN GameTitle AS g ON t.gtID = g.gtID WHERE t.uID = %s ORDER BY g.gtName, t.tName", (uID,))
            teams = cursor.fetchall()

            #Fetch all active players associated with the university's teams
            cursor.execute("Select Distinct uID, auID, gamerTag, major, auFirstName, auLastName from UniversityPlayers WHERE uID = %s  ORDER BY gamerTag", (uID,))
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
                                SELECT
                                    u.uID,
                                    u.uName,
                                    t.tID,
                                    t.tName,
                                    t.tSkillLevel,
                                    g.gtName,
                                    ts.sID,
                                    ts.sTitle,
                                    ts.sStartDate,
                                    tm.tmsTeamRole
                                FROM TeamMembership AS tm
                                JOIN TeamSeason AS ts ON tm.sID = ts.sID
                                JOIN Team AS t ON ts.tID = t.tID
                                JOIN University AS u ON t.uID = u.uID
                                JOIN GameTitle AS g ON t.gtID = g.gtID
                                WHERE tm.auID = %s
                                ORDER BY
                                    u.uName,
                                    u.uID,
                                    ts.sStartDate DESC,
                                    ts.sID DESC,
                                    g.gtName,
                                    t.tName
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

            #Verify if the team data entity was found
            if team is None:
                abort(404, description=(f"Team with ID '{tID}' not found."))  # Display a 404 error if the team data entity was not found

            #Fetch all players associated with the team, marked as: [active / former / upcoming / unknown ] status per player
            cursor.execute("""
                SELECT *
                FROM TeamPlayerStatuses
                WHERE tID = %s
                ORDER BY
                    FIELD(playerStatus, 'Active', 'Upcoming', 'Former', 'Unknown'),
                    gamerTag
            """, (tID,))
            players = cursor.fetchall()

            #Fetch the university associated with the team
            numRowsAffected = cursor.execute("SELECT uID FROM Team WHERE tID = %s", (tID,))
            universityID = cursor.fetchone()
            numRowsAffected = cursor.execute("SELECT * FROM University WHERE uID = %s", (team['uID'],)) if universityID else None
            teamUniversity = cursor.fetchone()

            #Fetch game title associated with the team
            gtID = team["gtID"]
            numRowsAffected = cursor.execute("SELECT  gt.gtID, gt.gtName, gt.gtGenre FROM gameTitle as gt join team as t on %s = gt.gtID Limit 1", (gtID,))
            game = cursor.fetchone()

            #Fetch all team events
            cursor.execute("""
                    SELECT *
                    FROM TeamSeasonMatches
                    WHERE tID = %s AND mStartDate >= CURDATE()
                    ORDER BY mStartDate ASC
                """, (tID,))
            teamSchedule = cursor.fetchall()

            #Fetch all teams seasons, mark as: [Upcoming, Active, Completed, Unknown]
            numRowsAffected = cursor.execute("""
                                SELECT *,
                                    CASE
                                        WHEN sEndDate < CURDATE() THEN 'Completed'
                                        WHEN sStartDate > CURDATE() THEN 'Upcoming'
                                        WHEN sStartDate <= CURDATE()
                                            AND (sEndDate IS NULL OR sEndDate >= CURDATE())
                                            THEN 'Active'
                                        ELSE 'Unknown'
                                    END AS seasonStatus
                                FROM TeamSeason
                                WHERE tID = %s
                                ORDER BY sStartDate DESC
                            """, (tID,))
            teamsSeasons = cursor.fetchall()

            activeSeasons = [s for s in teamsSeasons if s["seasonStatus"] == "Active"]
            formerSeasons = [s for s in teamsSeasons if s["seasonStatus"] == "Completed"]
            upcomingSeasons = [s for s in teamsSeasons if s["seasonStatus"] == "Upcoming"]
    finally:
        connection.close()

    return render_template("team.html", currentTeam=team, players=players, currentUniversity=teamUniversity, teamSchedule = teamSchedule, 
                           activeSeasons = activeSeasons, formerSeasons =formerSeasons, upcomingSeasons = upcomingSeasons, game = game)

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
            if currentTeam is not None:
                cursor.execute(
                    "SELECT * FROM University WHERE uID = %s",
                    (currentTeam["uID"],)
                )
                currentUniversity = cursor.fetchone()
            else:
                abort(404, "Can not find a team for team with ID: %s", sID)

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

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        # Collect form info
        email = request.form.get("email", "").strip()
        password = request.form.get("password", "")

        # Connect to DB to query for user
        connection = get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT * FROM AccountUser WHERE auEmail = %s",
                    (email,)
                )
                user = cursor.fetchone()
        finally:
            connection.close()

        # Verify login information
        if user and check_password_hash(user["auHashPass"], password):

            # Clear any previous login session
            session.clear()

            # Save user ID to current flask session
            session["auID"] = user["auID"]

            # Find universities associated with this account
            connection = get_connection()
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        SELECT uID
                        FROM AccountUniversityRoles
                        WHERE auID = %s AND uID IS NOT NULL
                        ORDER BY uName
                    """, (user["auID"],))

                    universities = cursor.fetchall()
            finally:
                connection.close()

            if(app.config["DEMO_MODE"]):
                print(f"Succesful Login! User ID: %i", user["auID"])

            # One university: redirect directly to its profile
            if len(universities) == 1:
                return redirect(url_for(
                    "university",
                    uID=universities[0]["uID"]
                ))
            
            # Multiple universities (or none): go to homepage
            return redirect("/")

        # Invalid login
        return render_template(
            "login.html",
            error="Invalid email or password."
        ), 401

    # Else is GET request => render login template
    return render_template("login.html")

@app.route("/logout", methods=["POST"])
def logout():
    session.clear()
    return redirect(url_for("home"))

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
    app.secret_key = 'esports super secret key'
    app.config["SECRET_KEY"] = os.environ.get("FLASK_SECRET_KEY", "fallback-dev-key")

    app.run(debug=True)

