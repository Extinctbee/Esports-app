-- 01_schema.sql
-- Destructive INITIAL SETUP / RESET only: drops the database and recreates all 14 tables.
-- All example data is intentionally moved into 02_seed_cusa_demo.sql.
-- DO NOT execute this on an existing database you intend to preserve.

# Drop existing db
DROP DATABASE IF EXISTS EsportsManagementDB;
# Create and use
CREATE DATABASE EsportsManagementDB;
USE EsportsManagementDB;

# Create University
create table University(
uID int primary key auto_increment,
uName varchar(100) Unique,
uState varchar (20),
uCity varchar(100),
uLogoURL varchar(100)
);

# Create Game Title
create table GameTitle(
gtID int primary key auto_increment,
gtName varchar(100) NOT NULL UNIQUE,
gtGenre varchar(50)
);

# Create Team
create table Team(

tID int primary key auto_increment,
uID int NOT NULL,
gtID int NOT Null,
tName varchar(100) NOT NULL,
tSkillLevel ENUM('Varsity', 'Junior Varsity', 'Academy') DEFAULT 'Varsity',

 # Defining the Foreign Key Constraint
    CONSTRAINT fk_university_team
	FOREIGN KEY (uID) 
    REFERENCES University(uID),
    
    Constraint fk_gameititle_team
    Foreign Key (gtID)
    References GameTitle(gtID)
);



# Create University Events (University HOSTS Events 1:M)
create table UniversityEvent(
ueID int primary key auto_increment,
uID int NOT NULL,
ueTitle varchar(100) NOT NULL,
ueEventType varchar(50),
ueStartDate datetime,
ueEndDate datetime,
ueLocation varchar(150),
ueInfo text,
 
    CONSTRAINT fk_university_event
    FOREIGN KEY (uID)
    REFERENCES University(uID)
    ON DELETE CASCADE
);

# Create AccountUser (supertype/parent for Staff Member and Team Member)
create table AccountUser(
auID int primary key auto_increment,
auFirstName varchar(50) NOT NULL,
auLastName varchar(50) NOT NULL,
auEmail varchar(100) NOT NULL UNIQUE,
auHashPass varchar(255) NOT NULL
);

# Create Staff Member ("Is A" AccountUser; University EMPLOYS Staff 1:M)
create table StaffMember(
auID int primary key,
uID int NOT NULL,
staffRole varchar(50) NOT NULL,
 
    CONSTRAINT fk_staff_accountuser
    FOREIGN KEY (auID)
    REFERENCES AccountUser(auID)
    ON DELETE CASCADE,
 
    CONSTRAINT fk_staff_university
    FOREIGN KEY (uID)
    REFERENCES University(uID)
);

# Create Team Member ("Is A" AccountUser)
create table TeamMember(
auID int primary key,
gamerTag varchar(50) NOT NULL UNIQUE,
bio text,
major varchar(100),
 
    CONSTRAINT fk_teammember_accountuser
    FOREIGN KEY (auID)
    REFERENCES AccountUser(auID)
    ON DELETE CASCADE
);

# Create Gamer Connections (Team Member LINKS Gamer Connections 1 : 0-1)
create table GamerConnections(
auID int primary key,
discordUser varchar(50),
epicGamesUser varchar(50),
riotGamesUser varchar(50),
steamUser varchar(50),
twitchUser varchar(50),
 
    CONSTRAINT fk_gamerconn_teammember
    FOREIGN KEY (auID)
    REFERENCES TeamMember(auID)
    ON DELETE CASCADE
);

# Create University Updates (University ADVERTISES 1:M, Staff Member POSTS 1:M)
# ---------------------------------------------------------
create table UniversityUpdate(
uuID int primary key auto_increment,
uID int NOT NULL,
staffAuID int NOT NULL,
uuTitle varchar(100) NOT NULL,
uuInfo text,
uuDatePosted datetime DEFAULT CURRENT_TIMESTAMP,
 
    CONSTRAINT fk_update_university
    FOREIGN KEY (uID)
    REFERENCES University(uID)
    ON DELETE CASCADE,
 
    CONSTRAINT fk_update_staff
    FOREIGN KEY (staffAuID)
    REFERENCES StaffMember(auID)
);

# Create Team Season (Team COMPETES DURING Team Season 1:M)
create table TeamSeason(
sID int primary key auto_increment,
tID int NOT NULL,
sTitle varchar(100) NOT NULL,
sFormat varchar(50),
sStartDate date,
sEndDate date,
sRecord varchar(20),
sDescription text,
 
    CONSTRAINT fk_season_team
    FOREIGN KEY (tID)
    REFERENCES Team(tID)
    ON DELETE CASCADE
);

# Create Team Events (Team Season SCHEDULES Team Events 1:M)
create table TeamEvent(
teID int primary key auto_increment,
sID int NOT NULL,
teTitle varchar(100) NOT NULL,
teEventType varchar(50),
teStartDate datetime,
teEndDate datetime,
teLocation varchar(150),
teStreamURL varchar(255),
teInfo text,
 
    CONSTRAINT fk_teamevent_season
    FOREIGN KEY (sID)
    REFERENCES TeamSeason(sID)
    ON DELETE CASCADE
);

# Create Team Membership
# (Team Member PLAYS UNDER Membership 1:M, Team Season LINKED TO Membership 1:M)
create table TeamMembership(
tmsID int primary key auto_increment,
auID int NOT NULL,
sID int NOT NULL,
tmsTeamRole varchar(50),
tmsJoinDate date,
tmsEndDate date,
 
    CONSTRAINT fk_membership_teammember
    FOREIGN KEY (auID)
    REFERENCES TeamMember(auID)
    ON DELETE CASCADE,
 
    CONSTRAINT fk_membership_season
    FOREIGN KEY (sID)
    REFERENCES TeamSeason(sID)
    ON DELETE CASCADE,
 
    # a member can only be on a given season roster once
    CONSTRAINT uq_member_season UNIQUE (auID, sID)
);

create table UniversityNewUserRequest(
unurID int primary key auto_increment,
uID int NOT NULL,
unurFirstName varchar(50) NOT NULL,
unurLastName varchar(50) NOT NULL,
unurEmail varchar(100) NOT NULL,
unurHashPass varchar(255) NOT NULL,
unurStatus ENUM('Pending', 'Approved', 'Denied') DEFAULT 'Pending',
reviewedByAuID int NULL,      # staff member who handled it
createdAuID int NULL UNIQUE,  # AccountUser created once approved
 
    CONSTRAINT fk_unur_university
    FOREIGN KEY (uID)
    REFERENCES University(uID)
    ON DELETE CASCADE,
 
    CONSTRAINT fk_unur_staff
    FOREIGN KEY (reviewedByAuID)
    REFERENCES StaffMember(auID)
    ON DELETE SET NULL,
 
    CONSTRAINT fk_unur_accountuser
    FOREIGN KEY (createdAuID)
    REFERENCES AccountUser(auID)
    ON DELETE SET NULL
);

# Create University Profile Account Requests
# (Approval creates new University profile + admin AccountUser as first university member)
create table UniversityProfileAccountRequest(
uarID int primary key auto_increment,
uarFirstName varchar(50) NOT NULL,
uarLastName varchar(50) NOT NULL,
uarEmail varchar(100) NOT NULL,
uarHashPass varchar(255) NOT NULL,
uarUniversityName varchar(100) NOT NULL,
uarState varchar(20),
uarCity varchar(100),
uarRequestDate datetime DEFAULT CURRENT_TIMESTAMP,
uarStatus ENUM('Pending', 'Approved', 'Denied') DEFAULT 'Pending'
);
