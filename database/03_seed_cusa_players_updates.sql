-- 03_seed_cusa_players_updates.sql
-- Additional local DEMO data: fictional student accounts, team members, season memberships,
-- university staff accounts, university updates, and university-wide events.
-- All people, gamer tags, event descriptions, and updates are invented test data.
-- Run AFTER 01_schema.sql and 02_seed_cusa_minimal.sql (which supplies universities and teams).
-- This script creates any missing Fall 2026 DEMO TeamSeason rows before roster memberships.
-- Existing records are preserved; no production table DROP, DELETE, or UPDATE is performed.
-- This script is designed to be rerun without duplicating the same demo entries.
-- Account passwords are placeholders for display/database testing, NOT login-ready hashes.
-- Never deploy these fictional accounts as real authenticated users.
USE EsportsManagementDB;

-- Temporary seed tables only; these are removed at the end of this script.
DROP TEMPORARY TABLE IF EXISTS demo_seed_student;
DROP TEMPORARY TABLE IF EXISTS demo_seed_staff;
CREATE TEMPORARY TABLE demo_seed_student (
  schoolName VARCHAR(100) NOT NULL,
  teamName VARCHAR(100) NOT NULL,
  auFirstName VARCHAR(50) NOT NULL,
  auLastName VARCHAR(50) NOT NULL,
  auEmail VARCHAR(100) NOT NULL PRIMARY KEY,
  gamerTag VARCHAR(50) NOT NULL UNIQUE,
  major VARCHAR(100),
  teamRole VARCHAR(50)
);

CREATE TEMPORARY TABLE demo_seed_staff (
  schoolName VARCHAR(100) NOT NULL,
  auFirstName VARCHAR(50) NOT NULL,
  auLastName VARCHAR(50) NOT NULL,
  auEmail VARCHAR(100) NOT NULL PRIMARY KEY
);

START TRANSACTION;

-- Fictional students: 3 Rocket League players and 5 Valorant players per university.
-- Each name, email, and gamerTag is stable across resets so memberships can be re-seeded.
-- DEL: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('University of Delaware', 'DEMO DEL Rocket League', 'Alex', 'Kim', 'demo.student.del.orbit@example.test', 'DEMO_DEL_Orbit', 'Computer Science', 'Starter'),
  ('University of Delaware', 'DEMO DEL Rocket League', 'Jordan', 'Santos', 'demo.student.del.pixel@example.test', 'DEMO_DEL_Pixel', 'Digital Media', 'Starter'),
  ('University of Delaware', 'DEMO DEL Rocket League', 'Morgan', 'Dunn', 'demo.student.del.astra@example.test', 'DEMO_DEL_Astra', 'Information Systems', 'Starter'),
  ('University of Delaware', 'DEMO DEL Valorant', 'Casey', 'Bennett', 'demo.student.del.vector@example.test', 'DEMO_DEL_Vector', 'Mathematics', 'Starter'),
  ('University of Delaware', 'DEMO DEL Valorant', 'Taylor', 'Irwin', 'demo.student.del.comet@example.test', 'DEMO_DEL_Comet', 'Engineering', 'Starter'),
  ('University of Delaware', 'DEMO DEL Valorant', 'Riley', 'Patel', 'demo.student.del.sable@example.test', 'DEMO_DEL_Sable', 'Business', 'Starter'),
  ('University of Delaware', 'DEMO DEL Valorant', 'Avery', 'Brooks', 'demo.student.del.nimbus@example.test', 'DEMO_DEL_Nimbus', 'Computer Science', 'Starter'),
  ('University of Delaware', 'DEMO DEL Valorant', 'Parker', 'Ingram', 'demo.student.del.cipher@example.test', 'DEMO_DEL_Cipher', 'Digital Media', 'Starter');

-- FIU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Florida International University', 'DEMO FIU Rocket League', 'Cameron', 'Garcia', 'demo.student.fiu.glitch@example.test', 'DEMO_FIU_Glitch', 'Information Systems', 'Starter'),
  ('Florida International University', 'DEMO FIU Rocket League', 'Quinn', 'Nguyen', 'demo.student.fiu.zephyr@example.test', 'DEMO_FIU_Zephyr', 'Mathematics', 'Starter'),
  ('Florida International University', 'DEMO FIU Rocket League', 'Blake', 'Walker', 'demo.student.fiu.pulse@example.test', 'DEMO_FIU_Pulse', 'Engineering', 'Starter'),
  ('Florida International University', 'DEMO FIU Valorant', 'Emerson', 'Grant', 'demo.student.fiu.drift@example.test', 'DEMO_FIU_Drift', 'Business', 'Starter'),
  ('Florida International University', 'DEMO FIU Valorant', 'Rowan', 'Evans', 'demo.student.fiu.rift@example.test', 'DEMO_FIU_Rift', 'Computer Science', 'Starter'),
  ('Florida International University', 'DEMO FIU Valorant', 'Skyler', 'Lewis', 'demo.student.fiu.nova@example.test', 'DEMO_FIU_Nova', 'Digital Media', 'Starter'),
  ('Florida International University', 'DEMO FIU Valorant', 'Hayden', 'Turner', 'demo.student.fiu.vortex@example.test', 'DEMO_FIU_Vortex', 'Information Systems', 'Starter'),
  ('Florida International University', 'DEMO FIU Valorant', 'Reese', 'Ellis', 'demo.student.fiu.frost@example.test', 'DEMO_FIU_Frost', 'Mathematics', 'Starter');

-- JSU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Jacksonville State University', 'DEMO JSU Rocket League', 'Jamie', 'Carter', 'demo.student.jsu.echo@example.test', 'DEMO_JSU_Echo', 'Engineering', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Rocket League', 'Charlie', 'Jensen', 'demo.student.jsu.flare@example.test', 'DEMO_JSU_Flare', 'Business', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Rocket League', 'Dakota', 'Reed', 'demo.student.jsu.kite@example.test', 'DEMO_JSU_Kite', 'Computer Science', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Valorant', 'Kendall', 'Coleman', 'demo.student.jsu.prism@example.test', 'DEMO_JSU_Prism', 'Digital Media', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Valorant', 'Sage', 'Jameson', 'demo.student.jsu.ember@example.test', 'DEMO_JSU_Ember', 'Information Systems', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Valorant', 'Finley', 'Hayes', 'demo.student.jsu.mako@example.test', 'DEMO_JSU_Mako', 'Mathematics', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Valorant', 'Elliot', 'Ortiz', 'demo.student.jsu.solar@example.test', 'DEMO_JSU_Solar', 'Engineering', 'Starter'),
  ('Jacksonville State University', 'DEMO JSU Valorant', 'Remy', 'Young', 'demo.student.jsu.rune@example.test', 'DEMO_JSU_Rune', 'Business', 'Starter');

-- KSU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Kennesaw State University', 'DEMO KSU Rocket League', 'Harper', 'Holland', 'demo.student.ksu.onyx@example.test', 'DEMO_KSU_Onyx', 'Computer Science', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Rocket League', 'Micah', 'Foster', 'demo.student.ksu.bolt@example.test', 'DEMO_KSU_Bolt', 'Digital Media', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Rocket League', 'Drew', 'Mason', 'demo.student.ksu.rogue@example.test', 'DEMO_KSU_Rogue', 'Information Systems', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Valorant', 'Peyton', 'Vega', 'demo.student.ksu.halo@example.test', 'DEMO_KSU_Halo', 'Mathematics', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Valorant', 'Marley', 'Fields', 'demo.student.ksu.hex@example.test', 'DEMO_KSU_Hex', 'Engineering', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Valorant', 'Sydney', 'Diaz', 'demo.student.ksu.ion@example.test', 'DEMO_KSU_Ion', 'Business', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Valorant', 'Alex', 'Lewis', 'demo.student.ksu.orbit@example.test', 'DEMO_KSU_Orbit', 'Computer Science', 'Starter'),
  ('Kennesaw State University', 'DEMO KSU Valorant', 'Jordan', 'Turner', 'demo.student.ksu.pixel@example.test', 'DEMO_KSU_Pixel', 'Digital Media', 'Starter');

-- LIB: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Liberty University', 'DEMO LIB Rocket League', 'Morgan', 'Ellis', 'demo.student.lib.astra@example.test', 'DEMO_LIB_Astra', 'Information Systems', 'Starter'),
  ('Liberty University', 'DEMO LIB Rocket League', 'Casey', 'Carter', 'demo.student.lib.vector@example.test', 'DEMO_LIB_Vector', 'Mathematics', 'Starter'),
  ('Liberty University', 'DEMO LIB Rocket League', 'Taylor', 'Jensen', 'demo.student.lib.comet@example.test', 'DEMO_LIB_Comet', 'Engineering', 'Starter'),
  ('Liberty University', 'DEMO LIB Valorant', 'Riley', 'Reed', 'demo.student.lib.sable@example.test', 'DEMO_LIB_Sable', 'Business', 'Starter'),
  ('Liberty University', 'DEMO LIB Valorant', 'Avery', 'Coleman', 'demo.student.lib.nimbus@example.test', 'DEMO_LIB_Nimbus', 'Computer Science', 'Starter'),
  ('Liberty University', 'DEMO LIB Valorant', 'Parker', 'Jameson', 'demo.student.lib.cipher@example.test', 'DEMO_LIB_Cipher', 'Digital Media', 'Starter'),
  ('Liberty University', 'DEMO LIB Valorant', 'Cameron', 'Hayes', 'demo.student.lib.glitch@example.test', 'DEMO_LIB_Glitch', 'Information Systems', 'Starter'),
  ('Liberty University', 'DEMO LIB Valorant', 'Quinn', 'Ortiz', 'demo.student.lib.zephyr@example.test', 'DEMO_LIB_Zephyr', 'Mathematics', 'Starter');

-- MTSU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Middle Tennessee State University', 'DEMO MTSU Rocket League', 'Blake', 'Young', 'demo.student.mtsu.pulse@example.test', 'DEMO_MTSU_Pulse', 'Engineering', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Rocket League', 'Emerson', 'Holland', 'demo.student.mtsu.drift@example.test', 'DEMO_MTSU_Drift', 'Business', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Rocket League', 'Rowan', 'Foster', 'demo.student.mtsu.rift@example.test', 'DEMO_MTSU_Rift', 'Computer Science', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Valorant', 'Skyler', 'Mason', 'demo.student.mtsu.nova@example.test', 'DEMO_MTSU_Nova', 'Digital Media', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Valorant', 'Hayden', 'Vega', 'demo.student.mtsu.vortex@example.test', 'DEMO_MTSU_Vortex', 'Information Systems', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Valorant', 'Reese', 'Fields', 'demo.student.mtsu.frost@example.test', 'DEMO_MTSU_Frost', 'Mathematics', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Valorant', 'Jamie', 'Diaz', 'demo.student.mtsu.echo@example.test', 'DEMO_MTSU_Echo', 'Engineering', 'Starter'),
  ('Middle Tennessee State University', 'DEMO MTSU Valorant', 'Charlie', 'Kim', 'demo.student.mtsu.flare@example.test', 'DEMO_MTSU_Flare', 'Business', 'Starter');

-- MSU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Missouri State University', 'DEMO MSU Rocket League', 'Dakota', 'Santos', 'demo.student.msu.kite@example.test', 'DEMO_MSU_Kite', 'Computer Science', 'Starter'),
  ('Missouri State University', 'DEMO MSU Rocket League', 'Kendall', 'Dunn', 'demo.student.msu.prism@example.test', 'DEMO_MSU_Prism', 'Digital Media', 'Starter'),
  ('Missouri State University', 'DEMO MSU Rocket League', 'Sage', 'Bennett', 'demo.student.msu.ember@example.test', 'DEMO_MSU_Ember', 'Information Systems', 'Starter'),
  ('Missouri State University', 'DEMO MSU Valorant', 'Finley', 'Irwin', 'demo.student.msu.mako@example.test', 'DEMO_MSU_Mako', 'Mathematics', 'Starter'),
  ('Missouri State University', 'DEMO MSU Valorant', 'Elliot', 'Patel', 'demo.student.msu.solar@example.test', 'DEMO_MSU_Solar', 'Engineering', 'Starter'),
  ('Missouri State University', 'DEMO MSU Valorant', 'Remy', 'Brooks', 'demo.student.msu.rune@example.test', 'DEMO_MSU_Rune', 'Business', 'Starter'),
  ('Missouri State University', 'DEMO MSU Valorant', 'Harper', 'Ingram', 'demo.student.msu.onyx@example.test', 'DEMO_MSU_Onyx', 'Computer Science', 'Starter'),
  ('Missouri State University', 'DEMO MSU Valorant', 'Micah', 'Garcia', 'demo.student.msu.bolt@example.test', 'DEMO_MSU_Bolt', 'Digital Media', 'Starter');

-- NMSU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('New Mexico State University', 'DEMO NMSU Rocket League', 'Drew', 'Nguyen', 'demo.student.nmsu.rogue@example.test', 'DEMO_NMSU_Rogue', 'Information Systems', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Rocket League', 'Peyton', 'Walker', 'demo.student.nmsu.halo@example.test', 'DEMO_NMSU_Halo', 'Mathematics', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Rocket League', 'Marley', 'Grant', 'demo.student.nmsu.hex@example.test', 'DEMO_NMSU_Hex', 'Engineering', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Valorant', 'Sydney', 'Evans', 'demo.student.nmsu.ion@example.test', 'DEMO_NMSU_Ion', 'Business', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Valorant', 'Alex', 'Mason', 'demo.student.nmsu.orbit@example.test', 'DEMO_NMSU_Orbit', 'Computer Science', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Valorant', 'Jordan', 'Vega', 'demo.student.nmsu.pixel@example.test', 'DEMO_NMSU_Pixel', 'Digital Media', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Valorant', 'Morgan', 'Fields', 'demo.student.nmsu.astra@example.test', 'DEMO_NMSU_Astra', 'Information Systems', 'Starter'),
  ('New Mexico State University', 'DEMO NMSU Valorant', 'Casey', 'Diaz', 'demo.student.nmsu.vector@example.test', 'DEMO_NMSU_Vector', 'Mathematics', 'Starter');

-- SHSU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Sam Houston State University', 'DEMO SHSU Rocket League', 'Taylor', 'Kim', 'demo.student.shsu.comet@example.test', 'DEMO_SHSU_Comet', 'Engineering', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Rocket League', 'Riley', 'Santos', 'demo.student.shsu.sable@example.test', 'DEMO_SHSU_Sable', 'Business', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Rocket League', 'Avery', 'Dunn', 'demo.student.shsu.nimbus@example.test', 'DEMO_SHSU_Nimbus', 'Computer Science', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Valorant', 'Parker', 'Bennett', 'demo.student.shsu.cipher@example.test', 'DEMO_SHSU_Cipher', 'Digital Media', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Valorant', 'Cameron', 'Irwin', 'demo.student.shsu.glitch@example.test', 'DEMO_SHSU_Glitch', 'Information Systems', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Valorant', 'Quinn', 'Patel', 'demo.student.shsu.zephyr@example.test', 'DEMO_SHSU_Zephyr', 'Mathematics', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Valorant', 'Blake', 'Brooks', 'demo.student.shsu.pulse@example.test', 'DEMO_SHSU_Pulse', 'Engineering', 'Starter'),
  ('Sam Houston State University', 'DEMO SHSU Valorant', 'Emerson', 'Ingram', 'demo.student.shsu.drift@example.test', 'DEMO_SHSU_Drift', 'Business', 'Starter');

-- WKU: fictional members for both DEMO teams
INSERT INTO demo_seed_student (schoolName, teamName, auFirstName, auLastName, auEmail, gamerTag, major, teamRole) VALUES
  ('Western Kentucky University', 'DEMO WKU Rocket League', 'Rowan', 'Garcia', 'demo.student.wku.rift@example.test', 'DEMO_WKU_Rift', 'Computer Science', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Rocket League', 'Skyler', 'Nguyen', 'demo.student.wku.nova@example.test', 'DEMO_WKU_Nova', 'Digital Media', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Rocket League', 'Hayden', 'Walker', 'demo.student.wku.vortex@example.test', 'DEMO_WKU_Vortex', 'Information Systems', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Valorant', 'Reese', 'Grant', 'demo.student.wku.frost@example.test', 'DEMO_WKU_Frost', 'Mathematics', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Valorant', 'Jamie', 'Evans', 'demo.student.wku.echo@example.test', 'DEMO_WKU_Echo', 'Engineering', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Valorant', 'Charlie', 'Lewis', 'demo.student.wku.flare@example.test', 'DEMO_WKU_Flare', 'Business', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Valorant', 'Dakota', 'Turner', 'demo.student.wku.kite@example.test', 'DEMO_WKU_Kite', 'Computer Science', 'Starter'),
  ('Western Kentucky University', 'DEMO WKU Valorant', 'Kendall', 'Ellis', 'demo.student.wku.prism@example.test', 'DEMO_WKU_Prism', 'Digital Media', 'Starter');

-- Fictional staff coordinators for each university; needed for UniversityUpdate.staffAuID.
INSERT INTO demo_seed_staff (schoolName, auFirstName, auLastName, auEmail) VALUES
  ('University of Delaware', 'Robin', 'Clark', 'demo.staff.del@example.test'),
  ('Florida International University', 'Kelly', 'Bishop', 'demo.staff.fiu@example.test'),
  ('Jacksonville State University', 'Dana', 'Bell', 'demo.staff.jsu@example.test'),
  ('Kennesaw State University', 'Sidney', 'Fox', 'demo.staff.ksu@example.test'),
  ('Liberty University', 'Marion', 'Hart', 'demo.staff.lib@example.test'),
  ('Middle Tennessee State University', 'Chris', 'Baker', 'demo.staff.mtsu@example.test'),
  ('Missouri State University', 'Leslie', 'Rivera', 'demo.staff.msu@example.test'),
  ('New Mexico State University', 'Shawn', 'Price', 'demo.staff.nmsu@example.test'),
  ('Sam Houston State University', 'Robin', 'Porter', 'demo.staff.shsu@example.test'),
  ('Western Kentucky University', 'Frankie', 'Shaw', 'demo.staff.wku@example.test');

-- Create AccountUser records. Password values are deliberately unusable placeholders.
-- Real authentication testing requires hashes generated with the Flask app's hash function.
INSERT INTO AccountUser (auFirstName, auLastName, auEmail, auHashPass)
SELECT s.auFirstName, s.auLastName, s.auEmail, 'DEMO_ONLY_NOT_A_PASSWORD_HASH'
FROM demo_seed_student AS s
WHERE NOT EXISTS (SELECT 1 FROM AccountUser AS au WHERE au.auEmail = s.auEmail);

INSERT INTO AccountUser (auFirstName, auLastName, auEmail, auHashPass)
SELECT s.auFirstName, s.auLastName, s.auEmail, 'DEMO_ONLY_NOT_A_PASSWORD_HASH'
FROM demo_seed_staff AS s
WHERE NOT EXISTS (SELECT 1 FROM AccountUser AS au WHERE au.auEmail = s.auEmail);

-- Attach fictional students to TeamMember.
INSERT INTO TeamMember (auID, gamerTag, bio, major)
SELECT au.auID, s.gamerTag, 'Fictional esports student for university profile testing.', s.major
FROM demo_seed_student AS s
JOIN AccountUser AS au ON au.auEmail = s.auEmail
WHERE NOT EXISTS (SELECT 1 FROM TeamMember AS tm WHERE tm.auID = au.auID);

-- Create fictional StaffMember subtype records.
INSERT INTO StaffMember (auID)
SELECT au.auID
FROM demo_seed_staff AS s
JOIN AccountUser AS au ON au.auEmail = s.auEmail
WHERE NOT EXISTS (
    SELECT 1 FROM StaffMember AS sm WHERE sm.auID = au.auID
);

-- Connect each fictional staff account to its university via the junction table.
INSERT INTO StaffUniversityMembership (auID, uID, staffRole)
SELECT au.auID, u.uID, 'Esports Coordinator'
FROM demo_seed_staff AS s
JOIN AccountUser AS au ON au.auEmail = s.auEmail
JOIN University AS u ON u.uName = s.schoolName
WHERE NOT EXISTS (
    SELECT 1 FROM StaffUniversityMembership AS smu
    WHERE smu.auID = au.auID AND smu.uID = u.uID
);

-- Ensure each DEMO team has a Fall 2026 season before assigning its roster.
-- Some versions of 02_seed_cusa_minimal.sql contain only universities/teams and no TeamSeason rows.
-- Creates missing seasons for the fictional teams listed above; existing seasons are preserved.
-- Rocket League uses 3v3, while Valorant uses 5v5.
INSERT INTO TeamSeason (tID, sTitle, sFormat, sStartDate, sEndDate, sDescription)
SELECT t.tID, 'Fall 2026',
       CASE WHEN g.gtName = 'Rocket League' THEN '3v3' ELSE '5v5' END,
       '2026-08-17', '2026-12-11', 'DEMO season for roster and schedule testing'
FROM (
  SELECT DISTINCT schoolName, teamName FROM demo_seed_student
) AS s
JOIN University AS u ON u.uName = s.schoolName
JOIN Team AS t ON t.uID = u.uID AND t.tName = s.teamName
JOIN GameTitle AS g ON g.gtID = t.gtID
WHERE NOT EXISTS (
  SELECT 1 FROM TeamSeason AS ts
  WHERE ts.tID = t.tID AND ts.sTitle = 'Fall 2026'
);

-- Place each fictional student on the matching DEMO team's Fall 2026 season roster.
-- TeamMembership points to TeamSeason.sID, not directly to Team.tID.
INSERT INTO TeamMembership (auID, sID, tmsTeamRole, tmsJoinDate)
SELECT au.auID, ts.sID, s.teamRole, '2026-08-17'
FROM demo_seed_student AS s
JOIN AccountUser AS au ON au.auEmail = s.auEmail
JOIN University AS u ON u.uName = s.schoolName
JOIN Team AS t ON t.uID = u.uID AND t.tName = s.teamName
JOIN TeamSeason AS ts ON ts.tID = t.tID AND ts.sTitle = 'Fall 2026'
WHERE NOT EXISTS (
  SELECT 1 FROM TeamMembership AS m
  WHERE m.auID = au.auID AND m.sID = ts.sID
);

-- Fictional university-wide announcements (two per university).
-- UniversityUpdate requires a staff member who posts each announcement.
INSERT INTO UniversityUpdate (uID, staffAuID, uuTitle, uuInfo, uuDatePosted)
SELECT u.uID, sm.auID, announcements.title, announcements.info, announcements.posted
FROM demo_seed_staff AS s
JOIN University AS u ON u.uName = s.schoolName
JOIN AccountUser AS au ON au.auEmail = s.auEmail
JOIN StaffUniversityMembership AS sm ON sm.auID = au.auID AND sm.uID = u.uID
CROSS JOIN (
  SELECT 'DEMO Fall 2026 Rosters Published' AS title,
         'Our fictional Rocket League and Valorant rosters are ready to browse. These are sample profiles for website testing.' AS info,
         '2026-11-07 10:00:00' AS posted
  UNION ALL
  SELECT 'DEMO November Esports Activities',
         'Check the university schedule for fictional matches, the open house, and community events. Dates are for testing only.',
         '2026-11-08 09:00:00'
) AS announcements
WHERE NOT EXISTS (
  SELECT 1 FROM UniversityUpdate AS uu
  WHERE uu.uID = u.uID AND uu.uuTitle = announcements.title
);

-- Two additional fictional university-wide events per university.
-- The original CUSA seed already provides DEMO Esports Open House.
-- These remain UniversityEvent records, separate from TeamMatch records.
INSERT INTO UniversityEvent (uID, ueTitle, ueEventType, ueStartDate, ueEndDate, ueLocation, ueInfo)
SELECT u.uID, events.title, events.eventType, events.starts, events.ends, events.place, events.info
FROM demo_seed_staff AS s
JOIN University AS u ON u.uName = s.schoolName
CROSS JOIN (
  SELECT 'DEMO Esports Tryout Info Session' AS title, 'Information' AS eventType,
         '2026-11-12 16:00:00' AS starts, '2026-11-12 17:00:00' AS ends,
         'Campus Esports Lounge' AS place,
         'Fictional student information session for schedule UI testing.' AS info
  UNION ALL
  SELECT 'DEMO Community Game Night', 'Community',
         '2026-11-21 18:00:00', '2026-11-21 20:00:00',
         'Student Center', 'Fictional open game night for schedule UI testing.'
) AS events
WHERE NOT EXISTS (
  SELECT 1 FROM UniversityEvent AS ue
  WHERE ue.uID = u.uID AND ue.ueTitle = events.title
    AND ue.ueStartDate = events.starts
);

-- Multi-affiliation DEMO account: nyx.
-- This is a LOCAL TEST credential only: do not deploy it as a real account.
-- Username/email: demo.nyx@example.test    Password: NyxDemo2026!
-- Staff at SHSU and NMSU; player on both universities' DEMO RL and Valorant teams
-- in Fall 2026, plus SHSU Rocket League during Spring 2026.

INSERT INTO AccountUser (auFirstName, auLastName, auEmail, auHashPass)
SELECT 'Nate', 'Demo', 'demo.nyx@example.test',
       'pbkdf2:sha256:600000$9679b395c57324b2e433$7c17a994c219506693730d0e922bc0e639c516a6f8784052e50e7ab6f3aedcfe'
WHERE NOT EXISTS (
    SELECT 1 FROM AccountUser WHERE auEmail = 'demo.nyx@example.test'
);

INSERT INTO StaffMember (auID)
SELECT au.auID
FROM AccountUser AS au
WHERE au.auEmail = 'demo.nyx@example.test'
  AND NOT EXISTS (
      SELECT 1 FROM StaffMember AS sm WHERE sm.auID = au.auID
  );

INSERT INTO StaffUniversityMembership (auID, uID, staffRole)
SELECT au.auID, u.uID, 'Esports Coordinator'
FROM AccountUser AS au
JOIN University AS u
  ON u.uName IN ('Sam Houston State University', 'New Mexico State University')
WHERE au.auEmail = 'demo.nyx@example.test'
  AND NOT EXISTS (
      SELECT 1 FROM StaffUniversityMembership AS smu
      WHERE smu.auID = au.auID AND smu.uID = u.uID
  );

INSERT INTO TeamMember (auID, gamerTag, bio, major)
SELECT au.auID, 'nyx',
       'Fictional multi-university, multi-season test player.',
       'Software Engineering'
FROM AccountUser AS au
WHERE au.auEmail = 'demo.nyx@example.test'
  AND NOT EXISTS (
      SELECT 1 FROM TeamMember AS p WHERE p.auID = au.auID
  );

-- 5 memberships: 4 Fall 2026 (both games at SHSU/NMSU)
-- + 1 historical Spring 2026 (SHSU Rocket League).
INSERT INTO TeamMembership (auID, sID, tmsTeamRole, tmsJoinDate, tmsEndDate)
SELECT au.auID, ts.sID, 'Starter', ts.sStartDate,
       CASE WHEN ts.sTitle = 'Spring 2026' THEN ts.sEndDate ELSE NULL END
FROM AccountUser AS au
JOIN TeamMember AS p ON p.auID = au.auID
CROSS JOIN TeamSeason AS ts
JOIN Team AS t ON t.tID = ts.tID
WHERE au.auEmail = 'demo.nyx@example.test'
  AND (
      (
          ts.sTitle = 'Fall 2026'
          AND t.tName IN (
              'DEMO SHSU Rocket League',
              'DEMO SHSU Valorant',
              'DEMO NMSU Rocket League',
              'DEMO NMSU Valorant'
          )
      )
      OR (
          ts.sTitle = 'Spring 2026'
          AND t.tName = 'DEMO SHSU Rocket League'
      )
  )
  AND NOT EXISTS (
      SELECT 1 FROM TeamMembership AS m
      WHERE m.auID = au.auID AND m.sID = ts.sID
  );

COMMIT;

-- Remove only the temporary staging data (actual demo accounts/events remain).
DROP TEMPORARY TABLE IF EXISTS demo_seed_student;
DROP TEMPORARY TABLE IF EXISTS demo_seed_staff;

-- Verify counts after a fresh 01 -> 02 -> 03 seed sequence.
-- Expected after seeding: 20 Fall 2026 DEMO seasons, 80 student accounts,
-- 10 staff accounts, 80 memberships, 20 university updates, and 20 extra
-- university events (plus 10 open houses if the earlier seed included them).
-- Existing DEMO seasons are reused rather than duplicated.
SELECT COUNT(*) AS demo_student_accounts
FROM AccountUser WHERE auEmail LIKE 'demo.student.%@example.test';

SELECT COUNT(*) AS demo_staff_accounts
FROM AccountUser WHERE auEmail LIKE 'demo.staff.%@example.test';

-- Verify that every fictional DEMO team now has a Fall 2026 season.
SELECT COUNT(*) AS demo_team_seasons
FROM TeamSeason AS ts
JOIN Team AS t ON t.tID = ts.tID
WHERE t.tName LIKE 'DEMO %' AND ts.sTitle = 'Fall 2026';

SELECT COUNT(*) AS demo_team_memberships
FROM TeamMembership AS m
JOIN AccountUser AS au ON au.auID = m.auID
WHERE au.auEmail LIKE 'demo.student.%@example.test';

SELECT COUNT(*) AS demo_university_updates
FROM UniversityUpdate WHERE uuTitle LIKE 'DEMO %';

SELECT COUNT(*) AS demo_university_events
FROM UniversityEvent WHERE ueTitle LIKE 'DEMO %';

-- Check each school's roster count and role distribution.
SELECT u.uName, g.gtName, t.tName, COUNT(m.tmsID) AS roster_size
FROM University AS u
JOIN Team AS t ON t.uID = u.uID AND t.tName LIKE 'DEMO %'
JOIN GameTitle AS g ON g.gtID = t.gtID
JOIN TeamSeason AS ts ON ts.tID = t.tID AND ts.sTitle = 'Fall 2026'
LEFT JOIN TeamMembership AS m ON m.sID = ts.sID
GROUP BY u.uID, u.uName, g.gtName, t.tID, t.tName
ORDER BY u.uName, g.gtName;

