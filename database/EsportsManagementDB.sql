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

# dummy entry for test. Remove later
insert into University(uName, uState, uCity) values('Sam Houston State University', 'Texas', 'Huntsville');	#university dummy Tests
insert into GameTitle(gtName, gtGenre) values('Valorant', 'Tactical Shooter');
insert into Team(tName, uID, gtID, tSkillLevel) values('SHSU Orange', 1, 1, 'Varsity');
 
insert into AccountUser(auFirstName, auLastName, auEmail, auHashPass)
values ('Sam', 'Bearkat', 'sam@shsu.edu', 'hash1'),
       ('Kat', 'Player', 'kat@shsu.edu', 'hash2');
insert into StaffMember(auID, uID, staffRole) values(1, 1, 'Admin');
insert into TeamMember(auID, gamerTag, bio, major) values(2, 'KatAttack', 'Duelist main', 'Computer Science');
insert into GamerConnections(auID, discordUser, riotGamesUser) values(2, 'kat#0001', 'KatAttack#NA1');
 
insert into TeamSeason(tID, sTitle, sFormat, sStartDate, sEndDate) values(1, 'Fall 2026', 'Round Robin', '2026-09-01', '2026-12-15');
insert into TeamEvent(sID, teTitle, teEventType, teStartDate, teLocation) values(1, 'Opening Match', 'Match', '2026-09-10 18:00:00', 'Online');
insert into TeamMembership(auID, sID, tmsTeamRole, tmsJoinDate) values(2, 1, 'Duelist', '2026-08-25');
insert into UniversityEvent(uID, ueTitle, ueEventType, ueStartDate, ueLocation) values(1, 'Esports Showcase', 'Showcase', '2026-10-30 17:00:00', 'Student Center');
insert into UniversityUpdate(uID, staffAuID, uuTitle, uuInfo) values(1, 1, 'Tryouts Open', 'Varsity tryouts start next week.');
insert into UniversityNewUserRequest(uID, unurFirstName, unurLastName, unurEmail, unurHashPass)
values(1, 'New', 'Student', 'new@shsu.edu', 'hash3');
insert into UniversityProfileAccountRequest(uarFirstName, uarLastName, uarEmail, uarHashPass, uarUniversityName, uarState, uarCity)
values('Jane', 'Doe', 'jane@utexas.edu', 'hash4', 'University of Texas', 'Texas', 'Austin');


select * from University;
select * from GameTitle;
select * from Team;
select * from AccountUser;
select * from StaffMember;
select * from TeamMember;
select * from GamerConnections;
select * from TeamSeason;
select * from TeamEvent;
select * from TeamMembership;
select * from UniversityEvent;
select * from UniversityUpdate;
select * from UniversityNewUserRequest;
select * from UniversityProfileAccountRequest;