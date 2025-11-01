-- ========================================
-- DDL (Data Definition Language)
-- Create Tables, Indexes, Views, Functions
-- ========================================

-- สร้าง Database
CREATE DATABASE TravelJournalDB;
GO

USE TravelJournalDB;
GO

-- ========================================
-- TABLE 1: Users
-- ========================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    DateOfBirth DATE,
    ProfileImage NVARCHAR(255),
    Role NVARCHAR(20) DEFAULT 'User',
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    IsActive BIT DEFAULT 1
);
GO

-- ========================================
-- TABLE 2: TravelEntries
-- ========================================
CREATE TABLE TravelEntries (
    EntryID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    TravelDate DATE NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- TABLE 3: Locations
-- ========================================
CREATE TABLE Locations (
    LocationID INT PRIMARY KEY IDENTITY(1,1),
    LocationName NVARCHAR(200) NOT NULL,
    Address NVARCHAR(500),
    City NVARCHAR(100),
    Country NVARCHAR(100),
    Latitude DECIMAL(10, 8) NOT NULL,
    Longitude DECIMAL(11, 8) NOT NULL,
    Category NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- TABLE 4: EntryLocations
-- ========================================
CREATE TABLE EntryLocations (
    EntryLocationID INT PRIMARY KEY IDENTITY(1,1),
    EntryID INT FOREIGN KEY REFERENCES TravelEntries(EntryID) ON DELETE CASCADE,
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID) ON DELETE CASCADE,
    VisitOrder INT,
    Notes NVARCHAR(500),
    PhotoURL NVARCHAR(255)
);
GO

-- ========================================
-- TABLE 5: LocationStatistics
-- ========================================
CREATE TABLE LocationStatistics (
    StatID INT PRIMARY KEY IDENTITY(1,1),
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID) ON DELETE CASCADE,
    VisitCount INT DEFAULT 0,
    AverageRating DECIMAL(3,2),
    PopularityScale INT CHECK (PopularityScale BETWEEN 1 AND 5),
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- TABLE 6: UserActivityLogs
-- ========================================
CREATE TABLE UserActivityLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    ActivityType NVARCHAR(50) NOT NULL,
    ActivityDescription NVARCHAR(500),
    IPAddress NVARCHAR(50),
    UserAgent NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- INDEXES for Performance
-- ========================================
CREATE INDEX IX_Users_Username ON Users(Username);
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_Role ON Users(Role);
CREATE INDEX IX_TravelEntries_UserID ON TravelEntries(UserID);
CREATE INDEX IX_TravelEntries_TravelDate ON TravelEntries(TravelDate);
CREATE INDEX IX_Locations_LatLong ON Locations(Latitude, Longitude);
CREATE INDEX IX_LocationStatistics_LocationID ON LocationStatistics(LocationID);
CREATE INDEX IX_UserActivityLogs_UserID ON UserActivityLogs(UserID);
CREATE INDEX IX_UserActivityLogs_ActivityType ON UserActivityLogs(ActivityType);
CREATE INDEX IX_UserActivityLogs_CreatedDate ON UserActivityLogs(CreatedDate);
GO

-- ========================================
-- VIEW 1: vw_PopularLocations
-- ========================================
CREATE VIEW vw_PopularLocations AS
SELECT 
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country,
    L.Latitude,
    L.Longitude,
    L.Category,
    LS.VisitCount,
    LS.AverageRating,
    LS.PopularityScale,
    CASE LS.PopularityScale
        WHEN 5 THEN 'Very Popular'
        WHEN 4 THEN 'Popular'
        WHEN 3 THEN 'Moderate'
        WHEN 2 THEN 'Low'
        ELSE 'Very Low'
    END AS PopularityLevel
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID;
GO

-- ========================================
-- VIEW 2: vw_UserUniqueLocations
-- ========================================
CREATE VIEW vw_UserUniqueLocations AS
SELECT 
    U.UserID,
    U.Username,
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country,
    L.Category,
    L.Latitude,
    L.Longitude,
    COUNT(DISTINCT TE.EntryID) AS VisitCount,
    MAX(TE.TravelDate) AS LastVisitDate,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating
FROM Users U
INNER JOIN TravelEntries TE ON U.UserID = TE.UserID
INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
INNER JOIN Locations L ON EL.LocationID = L.LocationID
GROUP BY U.UserID, U.Username, L.LocationID, L.LocationName, L.City, 
         L.Country, L.Category, L.Latitude, L.Longitude;
GO

-- ========================================
-- VIEW 3: vw_UserStatsSummary
-- ========================================
CREATE VIEW vw_UserStatsSummary AS
SELECT 
    U.UserID,
    U.Username,
    U.FullName,
    U.Email,
    U.Role,
    U.IsActive,
    U.CreatedDate,
    U.LastLogin,
    COUNT(DISTINCT TE.EntryID) AS TotalEntries,
    COUNT(DISTINCT EL.LocationID) AS TotalLocations,
    COUNT(DISTINCT L.LogID) AS TotalActivities,
    MAX(L.CreatedDate) AS LastActivityDate
FROM Users U
LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
LEFT JOIN UserActivityLogs L ON U.UserID = L.UserID
GROUP BY U.UserID, U.Username, U.FullName, U.Email, U.Role, U.IsActive, U.CreatedDate, U.LastLogin;
GO

-- ========================================
-- FUNCTION: fn_GetActivityCountByDateRange
-- ========================================
CREATE FUNCTION fn_GetActivityCountByDateRange
(
    @UserID INT,
    @DaysBack INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    
    SELECT @Count = COUNT(*)
    FROM UserActivityLogs
    WHERE UserID = @UserID
    AND CreatedDate >= DATEADD(DAY, -@DaysBack, GETDATE());
    
    RETURN @Count;
END;
GO

-- ========================================
-- TRIGGER: trg_UpdateStatsAfterEntry
-- ========================================
CREATE TRIGGER trg_UpdateStatsAfterEntry
ON EntryLocations
AFTER INSERT
AS
BEGIN
    DECLARE @LocationID INT;
    
    SELECT @LocationID = LocationID FROM inserted;
    
    EXEC sp_UpdateLocationStatistics @LocationID;
END;
GO

PRINT '✅ DDL Completed - All Tables, Indexes, Views, Functions, and Triggers Created!';
GO