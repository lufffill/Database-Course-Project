CREATE TABLE Members (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    DateJoined DATE DEFAULT GETDATE()
);
CREATE TABLE Trainers (
    TrainerID INT IDENTITY(1,1) PRIMARY KEY,
    TrainerName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(20)
);
CREATE TABLE MembershipTypes (
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    MembershipName VARCHAR(50) NOT NULL,
    MonthlyPrice DECIMAL(10,2) NOT NULL,
    DurationMonths INT NOT NULL
);

-- active and previous members
CREATE TABLE MemberMemberships (
    MemberMembershipID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    MembershipID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,

    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (MembershipID) REFERENCES MembershipTypes(MembershipID)
);
CREATE TABLE TrainingSessions (
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    SessionName VARCHAR(100) NOT NULL,
    TrainerID INT NOT NULL,
    SessionDate DATETIME NOT NULL,

    FOREIGN KEY (TrainerID) REFERENCES Trainers(TrainerID)
);

CREATE TABLE MemberSessions (
    MemberID INT NOT NULL,
    SessionID INT NOT NULL,
    PRIMARY KEY (MemberID, SessionID),

    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (SessionID) REFERENCES TrainingSessions(SessionID)
);

-- Indexes
CREATE UNIQUE INDEX IX_Members_Email ON Members(Email);
CREATE INDEX IX_TrainingSessions_Date ON TrainingSessions(SessionDate);
CREATE INDEX IX_MemberMemberships_MemberID ON MemberMemberships(MemberID);

-- =================================================================================================================================================================
INSERT INTO Members (FullName, Phone, Email)
VALUES 
('Vladyslav Pavlenko', '123456', 'john@mail.com'),
('Maksym Malyshkin', '987654', 'mary@mail.com'),
('Vlad Hnitsa', '555777', 'alex@mail.com');

INSERT INTO Trainers (TrainerName, Specialization, Phone)
VALUES
('David Namazov', 'Boxing', '111222'),
('Subo Aidinyan', 'Yoga', '222333');

INSERT INTO MembershipTypes (MembershipName, MonthlyPrice, DurationMonths)
VALUES
('Basic', 35.00, 1),
('Premium', 70.00, 3),
('VIP', 150.00, 6);

INSERT INTO MemberMemberships (MemberID, MembershipID, StartDate, EndDate)
VALUES
(1, 2, '2025-01-01', '2025-04-01'),
(2, 1, '2025-02-01', '2025-03-01');

INSERT INTO TrainingSessions (SessionName, TrainerID, SessionDate)
VALUES
('Wresling', 2, '2025-01-05 09:00'),
('Boxing', 1, '2025-01-06 18:00');

INSERT INTO MemberSessions (MemberID, SessionID)
VALUES
(1, 1),
(1, 2),
(2, 1);

-- ====================================================================================================================================================================================
UPDATE Members
SET Phone = '000111'
WHERE MemberID = 1;

DELETE FROM MemberSessions WHERE SessionID = 2;
TRUNCATE TABLE MemberSessions; -- example of truncate(clears the table without deleting it)

-- ==========================
-- Aggregates and group by
SELECT 
    mt.MembershipName,
    COUNT(mm.MemberID) AS MemberCount
FROM MembershipTypes mt
LEFT JOIN MemberMemberships mm ON mt.MembershipID = mm.MembershipID
GROUP BY mt.MembershipName;

-- aggregate with sum
SELECT 
    MembershipName,
    SUM(MonthlyPrice) AS TotalRevenue
FROM MembershipTypes mt
JOIN MemberMemberships mm ON mt.MembershipID = mm.MembershipID
GROUP BY MembershipName;

-- peggination offset/fetch
SELECT *
FROM Members
ORDER BY MemberID
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY;

-- ========================================= JOINTS
SELECT m.FullName, mt.MembershipName
FROM Members m
JOIN MemberMemberships mm ON m.MemberID = mm.MemberID
JOIN MembershipTypes mt ON mm.MembershipID = mt.MembershipID;


SELECT t.TrainerName, s.SessionName
FROM Trainers t
LEFT JOIN TrainingSessions s ON t.TrainerID = s.TrainerID;

SELECT 
    m.FullName,
    s.SessionName,
    s.SessionDate
FROM Members m
JOIN MemberSessions ms ON m.MemberID = ms.MemberID
JOIN TrainingSessions s ON ms.SessionID = s.SessionID;


-- ========================= VIEW 3 TABLES JOIN
GO
CREATE VIEW View_MemberSessions AS
SELECT 
    m.FullName,
    t.TrainerName,
    s.SessionName,
    s.SessionDate
FROM Members m
JOIN MemberSessions ms ON m.MemberID = ms.MemberID
JOIN TrainingSessions s ON ms.SessionID = s.SessionID
JOIN Trainers t ON s.TrainerID = t.TrainerID;
-- ====================== example
-- Show all records from the view
SELECT * FROM View_MemberSessions;

-- Show all sessions for a specific member
SELECT * FROM View_MemberSessions
WHERE FullName = 'Vladyslav Pavlenko';

-- procedure
GO
CREATE PROCEDURE AddMember
    @FullName VARCHAR(100),
    @Phone VARCHAR(20),
    @Email VARCHAR(100)
AS
BEGIN
    INSERT INTO Members(FullName, Phone, Email)
    VALUES (@FullName, @Phone, @Email);
END;

-- example
-- Insert a new member using the stored procedure
EXEC AddMember 
    @FullName = 'Olexandr Usyk',
    @Phone = '+12345678',
    @Email = 'usyk@mail.com';

-- Verify insertion
SELECT * FROM Members WHERE FullName = 'Olexandr Usyk';
--=================== function
GO
CREATE FUNCTION CountSessions(@MemberID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM MemberSessions WHERE MemberID = @MemberID);
END;
-- ============================= example
-- Count how many sessions member #1 has attended
SELECT dbo.CountSessions(1) AS TotalSessions;

-- Include function in a query
SELECT 
    FullName,
    dbo.CountSessions(MemberID) AS SessionCount
FROM Members;

-- ===================== trigger (log when new member is added) 
CREATE TABLE MemberLog (
    LogID INT IDENTITY PRIMARY KEY,
    MemberID INT,
    Action VARCHAR(50),
    LogDate DATETIME DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_MemberAdded
ON Members
AFTER INSERT
AS
BEGIN
    INSERT INTO MemberLog (MemberID, Action)
    SELECT MemberID, 'New Member Added' FROM inserted;
END;

-- Insert new member (trigger fires automatically)
INSERT INTO Members (FullName, Phone, Email)
VALUES ('Dana White', '+37060000000', 'dan@mail.com');

INSERT INTO Members (FullName, Phone, Email)
VALUES ('Jhon Bravo', '+37060000000', 'jhon@mail.com');
-- Check trigger results
SELECT * FROM MemberLog;

--=================== mannual transaction
GO
BEGIN TRANSACTION;

UPDATE Members SET Email = 'new@mail.com' WHERE MemberID = 2;

IF @@ERROR <> 0
    ROLLBACK TRAN;
ELSE
    COMMIT TRAN;
-- Check result of the transaction
SELECT MemberID, FullName, Email 
FROM Members 
WHERE MemberID = 2;
