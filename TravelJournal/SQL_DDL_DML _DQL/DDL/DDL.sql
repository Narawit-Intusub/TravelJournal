-- ========================================
-- Travel Journal Database - FULL DDL
-- ========================================

-- 1) CREATE DATABASE (if not exists)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TravelJournalDB')
BEGIN
    CREATE DATABASE TravelJournalDB;
    PRINT 'Database TravelJournalDB created';
END
ELSE
BEGIN
    PRINT 'Database TravelJournalDB already exists';
END
GO
USE TravelJournalDB;
GO

PRINT '=== Starting DDL Script Execution ===';
PRINT '';

-- ========================================
-- 2) DROP EXISTING OBJECTS (Clean Up)
-- ========================================

PRINT '--- Dropping Existing Objects ---';

-- Triggers
IF OBJECT_ID('dbo.trg_UpdateStatsAfterEntry', 'TR') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.trg_UpdateStatsAfterEntry;
    PRINT 'Dropped Trigger: trg_UpdateStatsAfterEntry';
END

-- Views
IF OBJECT_ID('dbo.vw_PopularLocations', 'V') IS NOT NULL DROP VIEW dbo.vw_PopularLocations;
IF OBJECT_ID('dbo.vw_UserStatsSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_UserStatsSummary;
IF OBJECT_ID('dbo.vw_UserUniqueLocations', 'V') IS NOT NULL DROP VIEW dbo.vw_UserUniqueLocations;

-- Stored Procedures
IF OBJECT_ID('dbo.sp_RegisterUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RegisterUser;
IF OBJECT_ID('dbo.sp_LoginUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_LoginUser;
IF OBJECT_ID('dbo.sp_AddTravelEntry', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddTravelEntry;
IF OBJECT_ID('dbo.sp_UpdateLocationStatistics', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateLocationStatistics;
IF OBJECT_ID('dbo.sp_GetUserTravelEntries', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserTravelEntries;
IF OBJECT_ID('dbo.sp_GetLocationStatistics', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetLocationStatistics;
IF OBJECT_ID('dbo.sp_UpdateUserProfile', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateUserProfile;
IF OBJECT_ID('dbo.sp_GetUserProfile', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserProfile;
IF OBJECT_ID('dbo.sp_LogUserActivity', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_LogUserActivity;
IF OBJECT_ID('dbo.sp_GetAllUsers', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllUsers;
IF OBJECT_ID('dbo.sp_GetUserActivityLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserActivityLogs;
IF OBJECT_ID('dbo.sp_ToggleUserStatus', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ToggleUserStatus;
IF OBJECT_ID('dbo.sp_DeleteUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeleteUser;

-- Functions
IF OBJECT_ID('dbo.fn_GetActivityCountByDateRange', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetActivityCountByDateRange;

-- Tables (children first)
IF OBJECT_ID('dbo.UserActivityLogs', 'U') IS NOT NULL DROP TABLE dbo.UserActivityLogs;
IF OBJECT_ID('dbo.ActivityLogs', 'U') IS NOT NULL DROP TABLE dbo.ActivityLogs;
IF OBJECT_ID('dbo.LocationStatistics', 'U') IS NOT NULL DROP TABLE dbo.LocationStatistics;
IF OBJECT_ID('dbo.EntryLocations', 'U') IS NOT NULL DROP TABLE dbo.EntryLocations;
IF OBJECT_ID('dbo.TravelEntries', 'U') IS NOT NULL DROP TABLE dbo.TravelEntries;
IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL DROP TABLE dbo.Locations;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;

PRINT 'Dropped all objects (if existed).';
PRINT '';

-- ========================================
-- 3) CREATE TABLES
-- ========================================

PRINT '--- Creating Tables ---';

-- Users
CREATE TABLE dbo.Users (
    UserID       INT IDENTITY(1,1) PRIMARY KEY,
    Username     NVARCHAR(50)  NOT NULL UNIQUE,
    Email        NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName     NVARCHAR(100),
    DateOfBirth  DATE,
    ProfileImage NVARCHAR(255),
    Role         NVARCHAR(20)  NOT NULL DEFAULT 'User',
    CreatedDate  DATETIME      NOT NULL DEFAULT GETDATE(),
    LastLogin    DATETIME,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT CK_Users_Role  CHECK (Role IN ('User','Admin')),
    CONSTRAINT CK_Users_Email CHECK (Email LIKE '%@%')
);
PRINT 'Created: Users';

-- Locations
CREATE TABLE dbo.Locations (
    LocationID   INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(200) NOT NULL,
    Address      NVARCHAR(500),
    City         NVARCHAR(100),
    Country      NVARCHAR(100),
    Latitude     DECIMAL(10,8) NOT NULL,
    Longitude    DECIMAL(11,8) NOT NULL,
    Category     NVARCHAR(50),
    CreatedDate  DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_Locations_Latitude  CHECK (Latitude BETWEEN -90  AND 90),
    CONSTRAINT CK_Locations_Longitude CHECK (Longitude BETWEEN -180 AND 180),
    CONSTRAINT UQ_Locations_Coordinates UNIQUE (LocationName, Latitude, Longitude)
);
PRINT 'Created: Locations';

-- TravelEntries
CREATE TABLE dbo.TravelEntries (
    EntryID     INT IDENTITY(1,1) PRIMARY KEY,
    UserID      INT NOT NULL,
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    TravelDate  DATE NOT NULL,
    Rating      INT  NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_TravelEntries_Users
        FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
    CONSTRAINT CK_TravelEntries_Rating CHECK (Rating BETWEEN 1 AND 5)
);
PRINT 'Created: TravelEntries';

-- EntryLocations (entry ↔ multiple locations)
CREATE TABLE dbo.EntryLocations (
    EntryLocationID INT IDENTITY(1,1) PRIMARY KEY,
    EntryID    INT NOT NULL,
    LocationID INT NOT NULL,
    VisitOrder INT,
    Notes      NVARCHAR(500),
    PhotoURL   NVARCHAR(255),
    CONSTRAINT FK_EntryLocations_Entries   FOREIGN KEY (EntryID)   REFERENCES dbo.TravelEntries(EntryID) ON DELETE CASCADE,
    CONSTRAINT FK_EntryLocations_Locations FOREIGN KEY (LocationID) REFERENCES dbo.Locations(LocationID)  ON DELETE CASCADE,
    CONSTRAINT UQ_EntryLocations UNIQUE (EntryID, LocationID)
);
PRINT 'Created: EntryLocations';

-- LocationStatistics
CREATE TABLE dbo.LocationStatistics (
    StatID          INT IDENTITY(1,1) PRIMARY KEY,
    LocationID      INT NOT NULL,
    VisitCount      INT         DEFAULT 0,
    AverageRating   DECIMAL(3,2),
    PopularityScale INT,
    LastUpdated     DATETIME    DEFAULT GETDATE(),
    CONSTRAINT FK_LocationStatistics_Locations FOREIGN KEY (LocationID)
        REFERENCES dbo.Locations(LocationID) ON DELETE CASCADE,
    CONSTRAINT CK_LocationStatistics_PopularityScale CHECK (PopularityScale BETWEEN 1 AND 5),
    CONSTRAINT CK_LocationStatistics_VisitCount CHECK (VisitCount >= 0),
    CONSTRAINT CK_LocationStatistics_Rating CHECK (AverageRating BETWEEN 0 AND 5),
    CONSTRAINT UQ_LocationStatistics_Location UNIQUE (LocationID)
);
PRINT 'Created: LocationStatistics';

-- ActivityLogs (generic app audit)
CREATE TABLE dbo.ActivityLogs (
    ActivityLogID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID              INT NOT NULL,
    ActivityType        NVARCHAR(50)  NOT NULL,
    ActivityDescription NVARCHAR(500),
    IPAddress           NVARCHAR(45),
    CreatedDate         DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_ActivityLogs_Users FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID) ON DELETE CASCADE
);
PRINT 'Created: ActivityLogs';

-- UserActivityLogs (richer user-facing log)
CREATE TABLE dbo.UserActivityLogs (
    LogID               INT IDENTITY(1,1) PRIMARY KEY,
    UserID              INT NOT NULL,
    ActivityType        NVARCHAR(50)  NOT NULL,
    ActivityDescription NVARCHAR(500),
    IPAddress           NVARCHAR(50),
    UserAgent           NVARCHAR(500),
    CreatedDate         DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserActivityLogs_Users FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID) ON DELETE CASCADE
);
PRINT 'Created: UserActivityLogs';

PRINT '';

-- ========================================
-- 4) INDEXES
-- ========================================

PRINT '--- Creating Indexes ---';

-- Users
CREATE INDEX IX_Users_Username ON dbo.Users(Username);
CREATE INDEX IX_Users_Email    ON dbo.Users(Email);
CREATE INDEX IX_Users_Role     ON dbo.Users(Role);
CREATE INDEX IX_Users_IsActive ON dbo.Users(IsActive);
PRINT 'Indexes: Users';

-- Locations
CREATE INDEX IX_Locations_LatLong  ON dbo.Locations(Latitude, Longitude);
CREATE INDEX IX_Locations_City     ON dbo.Locations(City);
CREATE INDEX IX_Locations_Country  ON dbo.Locations(Country);
CREATE INDEX IX_Locations_Category ON dbo.Locations(Category);
PRINT 'Indexes: Locations';

-- TravelEntries
CREATE INDEX IX_TravelEntries_UserID     ON dbo.TravelEntries(UserID);
CREATE INDEX IX_TravelEntries_TravelDate ON dbo.TravelEntries(TravelDate);
CREATE INDEX IX_TravelEntries_Rating     ON dbo.TravelEntries(Rating);
PRINT 'Indexes: TravelEntries';

-- EntryLocations
CREATE INDEX IX_EntryLocations_EntryID    ON dbo.EntryLocations(EntryID);
CREATE INDEX IX_EntryLocations_LocationID ON dbo.EntryLocations(LocationID);
PRINT 'Indexes: EntryLocations';

-- LocationStatistics
CREATE INDEX IX_LocationStatistics_LocationID      ON dbo.LocationStatistics(LocationID);
CREATE INDEX IX_LocationStatistics_PopularityScale ON dbo.LocationStatistics(PopularityScale);
CREATE INDEX IX_LocationStatistics_VisitCount      ON dbo.LocationStatistics(VisitCount);
PRINT 'Indexes: LocationStatistics';

-- ActivityLogs
CREATE INDEX IX_ActivityLogs_UserID      ON dbo.ActivityLogs(UserID);
CREATE INDEX IX_ActivityLogs_CreatedDate ON dbo.ActivityLogs(CreatedDate);
PRINT 'Indexes: ActivityLogs';

-- UserActivityLogs
CREATE INDEX IX_UserActivityLogs_UserID       ON dbo.UserActivityLogs(UserID);
CREATE INDEX IX_UserActivityLogs_ActivityType ON dbo.UserActivityLogs(ActivityType);
CREATE INDEX IX_UserActivityLogs_CreatedDate  ON dbo.UserActivityLogs(CreatedDate);
PRINT 'Indexes: UserActivityLogs';

PRINT '';

-- ========================================
-- 5) VIEWS
-- ========================================

PRINT '--- Creating Views ---';
GO
CREATE VIEW dbo.vw_PopularLocations AS
SELECT 
    L.LocationID, L.LocationName, L.City, L.Country,
    L.Latitude, L.Longitude, L.Category,
    LS.VisitCount, LS.AverageRating, LS.PopularityScale,
    CASE LS.PopularityScale
        WHEN 5 THEN 'Very Popular'
        WHEN 4 THEN 'Popular'
        WHEN 3 THEN 'Moderate'
        WHEN 2 THEN 'Low'
        ELSE 'Very Low'
    END AS PopularityLevel
FROM dbo.Locations L
JOIN dbo.LocationStatistics LS ON L.LocationID = LS.LocationID;
GO
PRINT 'Created: vw_PopularLocations';

GO
CREATE VIEW dbo.vw_UserUniqueLocations AS
SELECT 
    U.UserID, U.Username,
    L.LocationID, L.LocationName, L.City, L.Country, L.Category,
    L.Latitude, L.Longitude,
    COUNT(DISTINCT TE.EntryID) AS VisitCount,
    MAX(TE.TravelDate) AS LastVisitDate,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating
FROM dbo.Users U
JOIN dbo.TravelEntries TE ON U.UserID = TE.UserID
JOIN dbo.EntryLocations EL ON TE.EntryID = EL.EntryID
JOIN dbo.Locations L ON EL.LocationID = L.LocationID
GROUP BY U.UserID, U.Username, L.LocationID, L.LocationName, 
         L.City, L.Country, L.Category, L.Latitude, L.Longitude;
GO
PRINT 'Created: vw_UserUniqueLocations';

GO
CREATE VIEW dbo.vw_UserStatsSummary AS
SELECT 
    U.UserID, U.Username, U.FullName, U.Email, U.Role, U.IsActive,
    U.CreatedDate, U.LastLogin,
    COUNT(DISTINCT TE.EntryID) AS TotalEntries,
    COUNT(DISTINCT EL.LocationID) AS TotalLocations,
    COUNT(DISTINCT L.LogID) AS TotalActivities,
    MAX(L.CreatedDate) AS LastActivityDate
FROM dbo.Users U
LEFT JOIN dbo.TravelEntries TE ON U.UserID = TE.UserID
LEFT JOIN dbo.EntryLocations EL ON TE.EntryID = EL.EntryID
LEFT JOIN dbo.UserActivityLogs L ON U.UserID = L.UserID
GROUP BY U.UserID, U.Username, U.FullName, U.Email, U.Role, 
         U.IsActive, U.CreatedDate, U.LastLogin;
GO
PRINT 'Created: vw_UserStatsSummary';

PRINT '';

-- ========================================
-- 6) FUNCTIONS
-- ========================================

PRINT '--- Creating Functions ---';
GO
CREATE FUNCTION dbo.fn_GetActivityCountByDateRange
(
    @UserID INT,
    @DaysBack INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*)
    FROM dbo.UserActivityLogs
    WHERE UserID = @UserID
      AND CreatedDate >= DATEADD(DAY, -@DaysBack, GETDATE());
    RETURN @Count;
END;
GO
PRINT 'Created: fn_GetActivityCountByDateRange';

PRINT '';

-- ========================================
-- 7) STORED PROCEDURES
-- ========================================

PRINT '--- Creating Stored Procedures ---';
GO
CREATE PROCEDURE dbo.sp_RegisterUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @FullName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role)
    VALUES (@Username, @Email, @Password, @FullName, 'User');
    SELECT SCOPE_IDENTITY() AS NewUserID;
END;
GO
PRINT 'Created: sp_RegisterUser';

GO
CREATE PROCEDURE dbo.sp_LoginUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserID INT;

    SELECT @UserID = UserID
    FROM dbo.Users
    WHERE Username = @Username AND PasswordHash = @Password AND IsActive = 1;

    IF @UserID IS NOT NULL
    BEGIN
        UPDATE dbo.Users SET LastLogin = GETDATE() WHERE UserID = @UserID;
        SELECT UserID, Username, Email, FullName, Role FROM dbo.Users WHERE UserID = @UserID;
    END
    ELSE
    BEGIN
        SELECT CAST(NULL AS INT) AS UserID;
    END
END;
GO
PRINT 'Created: sp_LoginUser';

GO
CREATE PROCEDURE dbo.sp_AddTravelEntry
    @UserID INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @TravelDate DATE,
    @Rating INT,
    @LocationName NVARCHAR(200),
    @Address NVARCHAR(500),
    @City NVARCHAR(100),
    @Country NVARCHAR(100),
    @Latitude DECIMAL(10, 8),
    @Longitude DECIMAL(11, 8),
    @Category NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EntryID INT, @LocationID INT;

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
        VALUES (@UserID, @Title, @Description, @TravelDate, @Rating);
        SET @EntryID = SCOPE_IDENTITY();

        SELECT @LocationID = LocationID
        FROM dbo.Locations
        WHERE LocationName = @LocationName AND Latitude = @Latitude AND Longitude = @Longitude;

        IF @LocationID IS NULL
        BEGIN
            INSERT INTO dbo.Locations (LocationName, Address, City, Country, Latitude, Longitude, Category)
            VALUES (@LocationName, @Address, @City, @Country, @Latitude, @Longitude, @Category);
            SET @LocationID = SCOPE_IDENTITY();

            INSERT INTO dbo.LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
            VALUES (@LocationID, 0, 0, 1);
        END

        INSERT INTO dbo.EntryLocations (EntryID, LocationID, VisitOrder)
        VALUES (@EntryID, @LocationID, 1);

        EXEC dbo.sp_UpdateLocationStatistics @LocationID;

        COMMIT TRANSACTION;
        SELECT @EntryID AS NewEntryID, @LocationID AS LocationID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
PRINT 'Created: sp_AddTravelEntry';

GO
CREATE PROCEDURE dbo.sp_UpdateLocationStatistics
    @LocationID INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH S AS (
        SELECT
            EL.LocationID,
            COUNT(DISTINCT EL.EntryID) AS VisitCount,
            AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating
        FROM dbo.EntryLocations EL
        JOIN dbo.TravelEntries TE ON TE.EntryID = EL.EntryID
        WHERE EL.LocationID = @LocationID
        GROUP BY EL.LocationID
    )
    UPDATE LS
      SET VisitCount = ISNULL(S.VisitCount, 0),
          AverageRating = ISNULL(S.AvgRating, 0),
          PopularityScale = CASE
              WHEN ISNULL(S.VisitCount,0) >= 100 THEN 5
              WHEN ISNULL(S.VisitCount,0) >=  50 THEN 4
              WHEN ISNULL(S.VisitCount,0) >=  20 THEN 3
              WHEN ISNULL(S.VisitCount,0) >=   5 THEN 2
              ELSE 1 END,
          LastUpdated = GETDATE()
    FROM dbo.LocationStatistics LS
    LEFT JOIN S ON S.LocationID = LS.LocationID
    WHERE LS.LocationID = @LocationID;
END;
GO
PRINT 'Created: sp_UpdateLocationStatistics';

GO
CREATE PROCEDURE dbo.sp_GetUserTravelEntries
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TE.EntryID, TE.Title, TE.TravelDate, TE.Rating, TE.CreatedDate, TE.UpdatedDate
    FROM dbo.TravelEntries TE
    WHERE TE.UserID = @UserID
    ORDER BY TE.TravelDate DESC;
END;
GO
PRINT 'Created: sp_GetUserTravelEntries';

GO
CREATE PROCEDURE dbo.sp_GetLocationStatistics
    @LocationID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LS.*
    FROM dbo.LocationStatistics LS
    WHERE LS.LocationID = @LocationID;
END;
GO
PRINT 'Created: sp_GetLocationStatistics';

GO
CREATE PROCEDURE dbo.sp_UpdateUserProfile
    @UserID INT,
    @FullName NVARCHAR(100) = NULL,
    @DateOfBirth DATE = NULL,
    @ProfileImage NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Users
    SET FullName = COALESCE(@FullName, FullName),
        DateOfBirth = COALESCE(@DateOfBirth, DateOfBirth),
        ProfileImage = COALESCE(@ProfileImage, ProfileImage)
    WHERE UserID = @UserID;
END;
GO
PRINT 'Created: sp_UpdateUserProfile';

GO
CREATE PROCEDURE dbo.sp_GetUserProfile
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, Username, Email, FullName, DateOfBirth, ProfileImage, Role, CreatedDate, LastLogin, IsActive
    FROM dbo.Users WHERE UserID = @UserID;
END;
GO
PRINT 'Created: sp_GetUserProfile';

GO
CREATE PROCEDURE dbo.sp_LogUserActivity
    @UserID INT,
    @ActivityType NVARCHAR(50),
    @ActivityDescription NVARCHAR(500) = NULL,
    @IPAddress NVARCHAR(50) = NULL,
    @UserAgent NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.UserActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress, UserAgent)
    VALUES (@UserID, @ActivityType, @ActivityDescription, @IPAddress, @UserAgent);

    INSERT INTO dbo.ActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress)
    VALUES (@UserID, @ActivityType, @ActivityDescription, @IPAddress);
END;
GO
PRINT 'Created: sp_LogUserActivity';

GO
CREATE PROCEDURE dbo.sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, Username, Email, FullName, Role, IsActive, CreatedDate, LastLogin
    FROM dbo.Users
    ORDER BY CreatedDate DESC;
END;
GO
PRINT 'Created: sp_GetAllUsers';

GO
CREATE PROCEDURE dbo.sp_GetUserActivityLogs
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LogID, ActivityType, ActivityDescription, IPAddress, UserAgent, CreatedDate
    FROM dbo.UserActivityLogs
    WHERE UserID = @UserID
    ORDER BY CreatedDate DESC;
END;
GO
PRINT 'Created: sp_GetUserActivityLogs';

GO
CREATE PROCEDURE dbo.sp_ToggleUserStatus
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Users
    SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
    WHERE UserID = @UserID;
END;
GO
PRINT 'Created: sp_ToggleUserStatus';

GO
CREATE PROCEDURE dbo.sp_DeleteUser
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Users WHERE UserID = @UserID; -- will cascade to child tables
END;
GO
PRINT 'Created: sp_DeleteUser';

PRINT '';

-- ========================================
-- 8) TRIGGERS (set-based)
-- ========================================

PRINT '--- Creating Triggers ---';
GO
CREATE TRIGGER dbo.trg_UpdateStatsAfterEntry
ON dbo.EntryLocations
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH DistLoc AS (
        SELECT DISTINCT LocationID FROM inserted WHERE LocationID IS NOT NULL
    )
    UPDATE LS
    SET
        VisitCount = S.VisitCount,
        AverageRating = ISNULL(S.AvgRating, 0),
        PopularityScale = CASE
            WHEN S.VisitCount >= 100 THEN 5
            WHEN S.VisitCount >=  50 THEN 4
            WHEN S.VisitCount >=  20 THEN 3
            WHEN S.VisitCount >=   5 THEN 2
            ELSE 1 END,
        LastUpdated = GETDATE()
    FROM dbo.LocationStatistics LS
    JOIN (
        SELECT EL.LocationID,
               COUNT(DISTINCT EL.EntryID) AS VisitCount,
               AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating
        FROM dbo.EntryLocations EL
        JOIN dbo.TravelEntries TE ON TE.EntryID = EL.EntryID
        WHERE EL.LocationID IN (SELECT LocationID FROM DistLoc)
        GROUP BY EL.LocationID
    ) S ON S.LocationID = LS.LocationID;
END;
GO
PRINT 'Created: trg_UpdateStatsAfterEntry';

PRINT '';
PRINT '=== DDL Script Completed Successfully! ===';
PRINT '';
PRINT 'Database Schema Created:';
PRINT '  7 Tables (Users, TravelEntries, Locations, EntryLocations, LocationStatistics, ActivityLogs, UserActivityLogs)';
PRINT '  13 Stored Procedures';
PRINT '  3 Views';
PRINT '  1 Function';
PRINT '  1 Trigger (set-based)';
PRINT '  Multiple Indexes';
PRINT '  Constraints (PK, FK, CHECK, UNIQUE)';
GO
