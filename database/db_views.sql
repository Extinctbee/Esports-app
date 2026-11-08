-- University Schedule View
-- Combines university-wide events with matches from all university teams.
-- Each row includes its university ID for filtering in Flask.
CREATE OR REPLACE VIEW UniversitySchedule AS

-- University-wide events
SELECT
    ue.uID,
    'UniversityEvent' AS itemType,
    ue.ueID AS itemID,
    ue.ueTitle AS title,
    ue.ueStartDate AS startDate,
    ue.ueEndDate AS endDate,
    ue.ueLocation AS location,
    ue.ueInfo AS info,
    NULL AS teamName,
    NULL AS gameTitle,
    NULL AS streamURL,
    NULL AS matchStatus

FROM UniversityEvent AS ue

UNION ALL

-- Matches from every team belonging to the university
SELECT
    t.uID,
    'TeamMatch' AS itemType,
    m.mID AS itemID,
    CONCAT(t.tName, ' vs. ', m.mOpponent) AS title,
    m.mStartDate AS startDate,
    NULL AS endDate,
    m.mLocation AS location,
    m.mInfo AS info,
    t.tName AS teamName,
    g.gtName AS gameTitle,
    m.mStreamURL AS streamURL,
    m.mStatus AS matchStatus

FROM TeamMatch AS m
JOIN TeamSeason AS ts ON m.sID = ts.sID
JOIN Team AS t ON ts.tID = t.tID
JOIN GameTitle AS g ON t.gtID = g.gtID;


-- University Players View
-- Gets team members, their accounts, and their associated university teams.

CREATE OR REPLACE VIEW UniversityPlayers AS
SELECT
    t.uID,
    tm.auID,
    tm.gamerTag,
    tm.bio,
    tm.major,
    au.auFirstName,
    au.auLastName,
    t.tID,
    t.tName,
    g.gtName,
    tms.tmsTeamRole

FROM TeamMember AS tm
JOIN AccountUser AS au ON tm.auID = au.auID
JOIN TeamMembership AS tms ON tm.auID = tms.auID
JOIN TeamSeason AS ts ON tms.sID = ts.sID
JOIN Team AS t ON ts.tID = t.tID
JOIN GameTitle AS g ON t.gtID = g.gtID;

-- Players Seasons View
-- Gets players, their teams, and their associated seasons per team
CREATE OR REPLACE VIEW PlayerSeasons AS
SELECT
    p.auID,
    p.gamerTag,
    tm.tmsID,
    tm.tmsTeamRole,
    s.sID,
    s.sTitle,
    s.sFormat,
    s.sStartDate,
    s.sEndDate,
    s.sRecord,
    s.sDescription,
    t.tID,
    t.tName,
    t.tSkillLevel,
    t.gtID,
    t.uID,
    g.gtName

FROM TeamMember AS p
JOIN TeamMembership AS tm ON p.auID = tm.auID
JOIN TeamSeason AS s ON tm.sID = s.sID
JOIN Team AS t ON s.tID = t.tID
JOIN GameTitle AS g ON t.gtID = g.gtID;

-- Team Season Matches View
-- Gets all matches associated with a team's seasons,
-- including team information, game title, and every match attribute.
CREATE OR REPLACE VIEW TeamSeasonMatches AS
SELECT
    t.tID,
    t.tName,
    g.gtName,
    s.sTitle,
    m.*

FROM TeamMatch AS m
JOIN TeamSeason AS s ON m.sID = s.sID
JOIN Team AS t ON s.tID = t.tID
JOIN GameTitle AS g ON t.gtID = g.gtID;

-- View tables
Select * from UniversitySchedule;
Select * from UniversityPlayers;
Select * from PlayerSeasons;
Select * from TeamSeasonMatches;





