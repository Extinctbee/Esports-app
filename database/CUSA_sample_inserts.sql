-- 02_seed_cusa_minimal.sql
-- Minimal local DEMO data: 10 CUSA universities + two FICTIONAL teams each.
-- Universities are real. Every team below is invented, not an official roster.
-- Existing universities/teams are preserved; no database DROP or DELETE.
-- Use after running the existing schema. No staff/accounts/events necessary for current UI.
USE EsportsManagementDB;
START TRANSACTION;

-- Universities: existing uName values are left unchanged.
INSERT INTO University (uName, uState, uCity, uLogoURL) VALUES
  ('University of Delaware', 'Delaware', 'Newark', NULL), -- DEL
  ('Florida International University', 'Florida', 'Miami', NULL), -- FIU
  ('Jacksonville State University', 'Alabama', 'Jacksonville', NULL), -- JSU
  ('Kennesaw State University', 'Georgia', 'Kennesaw', NULL), -- KSU
  ('Liberty University', 'Virginia', 'Lynchburg', NULL), -- LIB
  ('Middle Tennessee State University', 'Tennessee', 'Murfreesboro', NULL), -- MTSU
  ('Missouri State University', 'Missouri', 'Springfield', NULL), -- MSU
  ('New Mexico State University', 'New Mexico', 'Las Cruces', NULL), -- NMSU
  ('Sam Houston State University', 'Texas', 'Huntsville', NULL), -- SHSU
  ('Western Kentucky University', 'Kentucky', 'Bowling Green', NULL) -- WKU
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

COMMIT;

-- Verify the school and fictional team records.
SELECT COUNT(*) AS cusa_university_count FROM University
WHERE uName IN ('University of Delaware', 'Florida International University', 'Jacksonville State University', 'Kennesaw State University', 'Liberty University', 'Middle Tennessee State University', 'Missouri State University', 'New Mexico State University', 'Sam Houston State University', 'Western Kentucky University');

SELECT u.uName, COUNT(t.tID) AS team_count
FROM University u LEFT JOIN Team t ON t.uID=u.uID AND t.tName LIKE 'DEMO %'
WHERE u.uName IN ('University of Delaware', 'Florida International University', 'Jacksonville State University', 'Kennesaw State University', 'Liberty University', 'Middle Tennessee State University', 'Missouri State University', 'New Mexico State University', 'Sam Houston State University', 'Western Kentucky University')
GROUP BY u.uID, u.uName ORDER BY u.uName;
