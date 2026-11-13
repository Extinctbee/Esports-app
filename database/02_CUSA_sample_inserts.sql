-- 02_seed_cusa_minimal.sql
-- Minimal local DEMO data: 10 CUSA universities + two FICTIONAL teams each, plus sample schedules.
-- Universities are real. Every team below is invented, not an official roster.
-- Existing universities/teams are preserved; no database DROP or DELETE.
-- Use after running the existing schema. No staff/accounts are required for this demo.
USE EsportsManagementDB;
START TRANSACTION;

-- Universities: existing uName values are left unchanged.
INSERT INTO University (uName, uState, uCity, uLogoURL) VALUES
  ('University of Delaware', 'Delaware', 'Newark', 'img/university-logo/UD.png'), -- DEL
  ('Florida International University', 'Florida', 'Miami', 'img/university-logo/FIU.png'), -- FIU
  ('Jacksonville State University', 'Alabama', 'Jacksonville', 'img/university-logo/JSU.png'), -- JSU
  ('Kennesaw State University', 'Georgia', 'Kennesaw', 'img/university-logo/KSU.png'), -- KSU
  ('Liberty University', 'Virginia', 'Lynchburg', 'img/university-logo/LU.png'), -- LIB
  ('Middle Tennessee State University', 'Tennessee', 'Murfreesboro', 'img/university-logo/MTSU.png'), -- MTSU
  ('Missouri State University', 'Missouri', 'Springfield', 'img/university-logo/MSU.png'), -- MSU
  ('New Mexico State University', 'New Mexico', 'Las Cruces', 'img/university-logo/NMSU.png'), -- NMSU
  ('Sam Houston State University', 'Texas', 'Huntsville', 'img/university-logo/SHSU.png'), -- SHSU
  ('Western Kentucky University', 'Kentucky', 'Bowling Green', 'img/university-logo/WKU.png') -- WKU
ON DUPLICATE KEY UPDATE uID = uID;

-- Two shared game titles, reused if they already exist.
INSERT INTO GameTitle (gtName, gtGenre) VALUES
  ('Rocket League', 'Sports / Vehicular Soccer'),
  ('Valorant', 'Tactical Shooter')
ON DUPLICATE KEY UPDATE gtID = gtID;

-- Fictional team rows. Each section contains one school's test teams.
-- Names beginning DEMO indicate invented data.
INSERT INTO Team (uID, gtID, tName, tSkillLevel)
SELECT u.uID, g.gtID, s.tName, 'Varsity'
FROM (
  -- DEL: University of Delaware
  SELECT 'University of Delaware' AS uName, 'Rocket League' AS gtName, 'DEMO DEL Rocket League' AS tName
  UNION ALL SELECT 'University of Delaware' AS uName, 'Valorant' AS gtName, 'DEMO DEL Valorant' AS tName
  -- FIU: Florida International University
  UNION ALL SELECT 'Florida International University' AS uName, 'Rocket League' AS gtName, 'DEMO FIU Rocket League' AS tName
  UNION ALL SELECT 'Florida International University' AS uName, 'Valorant' AS gtName, 'DEMO FIU Valorant' AS tName
  -- JSU: Jacksonville State University
  UNION ALL SELECT 'Jacksonville State University' AS uName, 'Rocket League' AS gtName, 'DEMO JSU Rocket League' AS tName
  UNION ALL SELECT 'Jacksonville State University' AS uName, 'Valorant' AS gtName, 'DEMO JSU Valorant' AS tName
  -- KSU: Kennesaw State University
  UNION ALL SELECT 'Kennesaw State University' AS uName, 'Rocket League' AS gtName, 'DEMO KSU Rocket League' AS tName
  UNION ALL SELECT 'Kennesaw State University' AS uName, 'Valorant' AS gtName, 'DEMO KSU Valorant' AS tName
  -- LIB: Liberty University
  UNION ALL SELECT 'Liberty University' AS uName, 'Rocket League' AS gtName, 'DEMO LIB Rocket League' AS tName
  UNION ALL SELECT 'Liberty University' AS uName, 'Valorant' AS gtName, 'DEMO LIB Valorant' AS tName
  -- MTSU: Middle Tennessee State University
  UNION ALL SELECT 'Middle Tennessee State University' AS uName, 'Rocket League' AS gtName, 'DEMO MTSU Rocket League' AS tName
  UNION ALL SELECT 'Middle Tennessee State University' AS uName, 'Valorant' AS gtName, 'DEMO MTSU Valorant' AS tName
  -- MSU: Missouri State University
  UNION ALL SELECT 'Missouri State University' AS uName, 'Rocket League' AS gtName, 'DEMO MSU Rocket League' AS tName
  UNION ALL SELECT 'Missouri State University' AS uName, 'Valorant' AS gtName, 'DEMO MSU Valorant' AS tName
  -- NMSU: New Mexico State University
  UNION ALL SELECT 'New Mexico State University' AS uName, 'Rocket League' AS gtName, 'DEMO NMSU Rocket League' AS tName
  UNION ALL SELECT 'New Mexico State University' AS uName, 'Valorant' AS gtName, 'DEMO NMSU Valorant' AS tName
  -- SHSU: Sam Houston State University
  UNION ALL SELECT 'Sam Houston State University' AS uName, 'Rocket League' AS gtName, 'DEMO SHSU Rocket League' AS tName
  UNION ALL SELECT 'Sam Houston State University' AS uName, 'Valorant' AS gtName, 'DEMO SHSU Valorant' AS tName
  -- WKU: Western Kentucky University
  UNION ALL SELECT 'Western Kentucky University' AS uName, 'Rocket League' AS gtName, 'DEMO WKU Rocket League' AS tName
  UNION ALL SELECT 'Western Kentucky University' AS uName, 'Valorant' AS gtName, 'DEMO WKU Valorant' AS tName
) AS s
JOIN University AS u ON u.uName = s.uName
JOIN GameTitle AS g ON g.gtName = s.gtName
WHERE NOT EXISTS (
  SELECT 1 FROM Team AS t
  WHERE t.uID = u.uID AND t.gtID = g.gtID AND t.tName = s.tName
);

-- Fictional Fall 2026 seasons for each DEMO team.
-- Each season belongs to one team; rerunning this seed preserves existing seasons.
INSERT INTO TeamSeason (tID, sTitle, sFormat, sStartDate, sEndDate, sDescription)
SELECT t.tID, 'Fall 2026',
       CASE WHEN g.gtName = 'Rocket League' THEN '3v3' ELSE '5v5' END,
       '2026-08-17', '2026-12-11', 'DEMO season for schedule testing'
FROM Team AS t
JOIN GameTitle AS g ON g.gtID = t.gtID
WHERE t.tName LIKE 'DEMO %'
  AND NOT EXISTS (
    SELECT 1 FROM TeamSeason AS ts
    WHERE ts.tID = t.tID AND ts.sTitle = 'Fall 2026'
  );

-- Additional historical DEMO season for testing a player's past SHSU membership.
-- Only the SHSU Rocket League team receives this Spring 2026 season.
INSERT INTO TeamSeason (tID, sTitle, sFormat, sStartDate, sEndDate, sDescription)
SELECT t.tID, 'Spring 2026', '3v3',
       '2026-01-12', '2026-05-15',
       'DEMO historical season for player affiliation testing'
FROM Team AS t
JOIN University AS u ON u.uID = t.uID
WHERE u.uName = 'Sam Houston State University'
  AND t.tName = 'DEMO SHSU Rocket League'
  AND NOT EXISTS (
      SELECT 1
      FROM TeamSeason AS ts
      WHERE ts.tID = t.tID AND ts.sTitle = 'Spring 2026'
  );

-- Fictional matches for the DEMO team seasons.
-- Match times differ by game; opponents are placeholders, not actual scheduled opponents.
-- Existing DEMO matches are preserved when the seed is rerun.
INSERT INTO TeamMatch (sID, mOpponent, mStartDate, mLocation, mInfo)
SELECT ts.sID, 'DEMO Opponent',
       CASE WHEN g.gtName = 'Rocket League'
            THEN '2026-11-18 18:00:00'
            ELSE '2026-11-19 19:00:00' END,
       'Online', 'Fictional match for university schedule testing'
FROM TeamSeason AS ts
JOIN Team AS t ON t.tID = ts.tID
JOIN GameTitle AS g ON g.gtID = t.gtID
WHERE t.tName LIKE 'DEMO %'
  AND ts.sTitle = 'Fall 2026'
  AND NOT EXISTS (
    SELECT 1 FROM TeamMatch AS m
    WHERE m.sID = ts.sID AND m.mOpponent = 'DEMO Opponent'
  );

-- Completed fictional SHSU Rocket League series for results-card testing.
-- Scores are series wins (team first); includes wins, losses, and a zero score.
INSERT INTO TeamMatch (
    sID, mOpponent, mStartDate, mLocation,
    mStatus, mTeamScore, mOpponentScore, mStreamURL, mInfo
)
SELECT ts.sID, demo.opponent, demo.starts, 'Online',
       'Completed', demo.teamScore, demo.opponentScore,
       CASE WHEN demo.opponent IN ('DEMO Comets', 'DEMO Pulsars')
            THEN 'https://www.twitch.tv/heyitsnateirl' ELSE NULL END,
       'Fictional completed series for demo results testing; not an official result.'
FROM (
    SELECT 'Fall 2026' AS seasonTitle, 'DEMO Comets' AS opponent,
           '2026-10-15 18:00:00' AS starts, 3 AS teamScore, 1 AS opponentScore
    UNION ALL SELECT 'Fall 2026', 'DEMO Meteors', '2026-10-22 18:00:00', 2, 3
    UNION ALL SELECT 'Fall 2026', 'DEMO Nebulas', '2026-11-05 18:00:00', 3, 0
    UNION ALL SELECT 'Spring 2026', 'DEMO Pulsars', '2026-03-12 18:00:00', 3, 2
    UNION ALL SELECT 'Spring 2026', 'DEMO Quasars', '2026-04-09 18:00:00', 0, 3
) AS demo
JOIN TeamSeason AS ts ON ts.sTitle = demo.seasonTitle
JOIN Team AS t ON t.tID = ts.tID
JOIN University AS u ON u.uID = t.uID
JOIN GameTitle AS g ON g.gtID = t.gtID
WHERE u.uName = 'Sam Houston State University'
  AND t.tName = 'DEMO SHSU Rocket League'
  AND g.gtName = 'Rocket League'
  AND NOT EXISTS (
      SELECT 1 FROM TeamMatch AS m
      WHERE m.sID = ts.sID AND m.mOpponent = demo.opponent
        AND m.mStartDate = demo.starts
  );

-- Backfill the two stream links if these demo matches were seeded previously.
-- This is a channel link for UI testing, not a recording of the fictional match.
UPDATE TeamMatch AS m
JOIN TeamSeason AS ts ON ts.sID = m.sID
JOIN Team AS t ON t.tID = ts.tID
JOIN University AS u ON u.uID = t.uID
JOIN GameTitle AS g ON g.gtID = t.gtID
SET m.mStreamURL = 'https://www.twitch.tv/heyitsnateirl'
WHERE u.uName = 'Sam Houston State University'
  AND t.tName = 'DEMO SHSU Rocket League'
  AND g.gtName = 'Rocket League'
  AND (m.mStreamURL IS NULL OR m.mStreamURL = '')
  AND (
      (ts.sTitle = 'Fall 2026' AND m.mOpponent = 'DEMO Comets'
       AND m.mStartDate = '2026-10-15 18:00:00')
      OR
      (ts.sTitle = 'Spring 2026' AND m.mOpponent = 'DEMO Pulsars'
       AND m.mStartDate = '2026-03-12 18:00:00')
  );

-- Fictional university-wide events to test the combined schedule.
-- These belong to University, not to individual teams; no staff/accounts are required.
INSERT INTO UniversityEvent (uID, ueTitle, ueEventType, ueStartDate, ueEndDate, ueLocation, ueInfo)
SELECT u.uID, 'DEMO Esports Open House', 'Community',
       '2026-11-20 15:00:00', '2026-11-20 17:00:00',
       'Campus', 'Fictional university event for schedule testing'
FROM University AS u
WHERE u.uName IN (
  'University of Delaware', 'Florida International University',
  'Jacksonville State University', 'Kennesaw State University',
  'Liberty University', 'Middle Tennessee State University',
  'Missouri State University', 'New Mexico State University',
  'Sam Houston State University', 'Western Kentucky University'
)
  AND NOT EXISTS (
    SELECT 1 FROM UniversityEvent AS ue
    WHERE ue.uID = u.uID
      AND ue.ueTitle = 'DEMO Esports Open House'
      AND ue.ueStartDate = '2026-11-20 15:00:00'
  );

COMMIT;

-- Verify the school, fictional team, season, match, and university event records.
SELECT COUNT(*) AS cusa_university_count FROM University
WHERE uName IN ('University of Delaware', 'Florida International University', 'Jacksonville State University', 'Kennesaw State University', 'Liberty University', 'Middle Tennessee State University', 'Missouri State University', 'New Mexico State University', 'Sam Houston State University', 'Western Kentucky University');

SELECT u.uName, COUNT(t.tID) AS team_count
FROM University u LEFT JOIN Team t ON t.uID=u.uID AND t.tName LIKE 'DEMO %'
WHERE u.uName IN ('University of Delaware', 'Florida International University', 'Jacksonville State University', 'Kennesaw State University', 'Liberty University', 'Middle Tennessee State University', 'Missouri State University', 'New Mexico State University', 'Sam Houston State University', 'Western Kentucky University')
GROUP BY u.uID, u.uName ORDER BY u.uName;

-- Verify the fictional season and schedule records.
SELECT COUNT(*) AS demo_team_season_count
FROM TeamSeason AS ts
JOIN Team AS t ON t.tID = ts.tID
WHERE t.tName LIKE 'DEMO %' AND ts.sTitle = 'Fall 2026';

SELECT COUNT(*) AS demo_team_match_count
FROM TeamMatch AS m
JOIN TeamSeason AS ts ON ts.sID = m.sID
JOIN Team AS t ON t.tID = ts.tID
WHERE t.tName LIKE 'DEMO %' AND m.mOpponent = 'DEMO Opponent';

SELECT COUNT(*) AS demo_university_event_count
FROM UniversityEvent
WHERE ueTitle = 'DEMO Esports Open House';


