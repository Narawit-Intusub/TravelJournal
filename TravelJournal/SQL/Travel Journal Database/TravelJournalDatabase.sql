-- ========================================
-- Travel Journal Database - Complete Script
-- สร้างตั้งแต่ต้น พร้อมทุก Features
-- ========================================

-- ========================================
-- 1. สร้าง Database
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TravelJournalDB')
BEGIN
    CREATE DATABASE TravelJournalDB;
END
GO

USE TravelJournalDB;
GO

PRINT '=== Starting Database Creation ===';
PRINT '';

-- ========================================
-- 2. ลบ Objects เก่า (ถ้ามี) เพื่อสร้างใหม่
-- ========================================

-- Drop Triggers
IF OBJECT_ID('trg_UpdateStatsAfterEntry', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateStatsAfterEntry;
GO

-- Drop Views
IF OBJECT_ID('vw_PopularLocations', 'V') IS NOT NULL
    DROP VIEW vw_PopularLocations;
GO

IF OBJECT_ID('vw_UserStatsSummary', 'V') IS NOT NULL
    DROP VIEW vw_UserStatsSummary;
GO

IF OBJECT_ID('vw_UserUniqueLocations', 'V') IS NOT NULL
    DROP VIEW vw_UserUniqueLocations;
GO

-- Drop Stored Procedures
IF OBJECT_ID('sp_RegisterUser', 'P') IS NOT NULL DROP PROCEDURE sp_RegisterUser;
IF OBJECT_ID('sp_LoginUser', 'P') IS NOT NULL DROP PROCEDURE sp_LoginUser;
IF OBJECT_ID('sp_AddTravelEntry', 'P') IS NOT NULL DROP PROCEDURE sp_AddTravelEntry;
IF OBJECT_ID('sp_UpdateLocationStatistics', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateLocationStatistics;
IF OBJECT_ID('sp_GetUserTravelEntries', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserTravelEntries;
IF OBJECT_ID('sp_GetLocationStatistics', 'P') IS NOT NULL DROP PROCEDURE sp_GetLocationStatistics;
IF OBJECT_ID('sp_UpdateUserProfile', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateUserProfile;
IF OBJECT_ID('sp_GetUserProfile', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserProfile;
IF OBJECT_ID('sp_LogUserActivity', 'P') IS NOT NULL DROP PROCEDURE sp_LogUserActivity;
IF OBJECT_ID('sp_GetAllUsers', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllUsers;
IF OBJECT_ID('sp_GetUserActivityLogs', 'P') IS NOT NULL DROP PROCEDURE sp_GetUserActivityLogs;
IF OBJECT_ID('sp_ToggleUserStatus', 'P') IS NOT NULL DROP PROCEDURE sp_ToggleUserStatus;
IF OBJECT_ID('sp_DeleteUser', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteUser;
GO

-- Drop Functions
IF OBJECT_ID('fn_GetActivityCountByDateRange', 'FN') IS NOT NULL
    DROP FUNCTION fn_GetActivityCountByDateRange;
GO

-- Drop Tables (ตามลำดับ Foreign Key)
IF OBJECT_ID('UserActivityLogs', 'U') IS NOT NULL DROP TABLE UserActivityLogs;
IF OBJECT_ID('LocationStatistics', 'U') IS NOT NULL DROP TABLE LocationStatistics;
IF OBJECT_ID('EntryLocations', 'U') IS NOT NULL DROP TABLE EntryLocations;
IF OBJECT_ID('TravelEntries', 'U') IS NOT NULL DROP TABLE TravelEntries;
IF OBJECT_ID('Locations', 'U') IS NOT NULL DROP TABLE Locations;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

PRINT 'Cleaned up old objects';
PRINT '';

-- ========================================
-- 3. สร้าง Tables
-- ========================================

PRINT '=== Creating Tables ===';

-- Table 1: Users
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
PRINT 'Created table: Users';

-- Table 2: TravelEntries
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
PRINT '✓ Created table: TravelEntries';

-- Table 3: Locations
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
PRINT 'Created table: Locations';

-- Table 4: EntryLocations
CREATE TABLE EntryLocations (
    EntryLocationID INT PRIMARY KEY IDENTITY(1,1),
    EntryID INT FOREIGN KEY REFERENCES TravelEntries(EntryID) ON DELETE CASCADE,
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID) ON DELETE CASCADE,
    VisitOrder INT,
    Notes NVARCHAR(500),
    PhotoURL NVARCHAR(255)
);
PRINT '✓ Created table: EntryLocations';

-- Table 5: LocationStatistics
CREATE TABLE LocationStatistics (
    StatID INT PRIMARY KEY IDENTITY(1,1),
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID) ON DELETE CASCADE,
    VisitCount INT DEFAULT 0,
    AverageRating DECIMAL(3,2),
    PopularityScale INT CHECK (PopularityScale BETWEEN 1 AND 5),
    LastUpdated DATETIME DEFAULT GETDATE()
);
PRINT 'Created table: LocationStatistics';

-- Table 6: UserActivityLogs
CREATE TABLE UserActivityLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    ActivityType NVARCHAR(50) NOT NULL,
    ActivityDescription NVARCHAR(500),
    IPAddress NVARCHAR(50),
    UserAgent NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE()
);
PRINT 'Created table: UserActivityLogs';

PRINT '';

-- ========================================
-- 4. สร้าง Indexes
-- ========================================

PRINT '=== Creating Indexes ===';

CREATE INDEX IX_Users_Username ON Users(Username);
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_TravelEntries_UserID ON TravelEntries(UserID);
CREATE INDEX IX_TravelEntries_TravelDate ON TravelEntries(TravelDate);
CREATE INDEX IX_Locations_LatLong ON Locations(Latitude, Longitude);
CREATE INDEX IX_LocationStatistics_LocationID ON LocationStatistics(LocationID);
CREATE INDEX IX_UserActivityLogs_UserID ON UserActivityLogs(UserID);
CREATE INDEX IX_UserActivityLogs_ActivityType ON UserActivityLogs(ActivityType);
CREATE INDEX IX_UserActivityLogs_CreatedDate ON UserActivityLogs(CreatedDate);

PRINT 'Created all indexes';
PRINT '';

-- ========================================
-- 5. สร้าง Stored Procedures
-- ========================================

PRINT '=== Creating Stored Procedures ===';

-- SP 1: Register User
CREATE PROCEDURE sp_RegisterUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @FullName NVARCHAR(100)
AS
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role)
    VALUES (@Username, @Email, @Password, @FullName, 'User');
    
    SELECT SCOPE_IDENTITY() AS NewUserID;
END;
GO
PRINT 'Created: sp_RegisterUser';

-- SP 2: Login User
CREATE PROCEDURE sp_LoginUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    DECLARE @UserID INT;
    
    SELECT @UserID = UserID
    FROM Users
    WHERE Username = @Username AND PasswordHash = @Password AND IsActive = 1;
    
    IF @UserID IS NOT NULL
    BEGIN
        UPDATE Users SET LastLogin = GETDATE() WHERE UserID = @UserID;
        SELECT UserID, Username, Email, FullName, Role FROM Users WHERE UserID = @UserID;
    END
    ELSE
    BEGIN
        SELECT NULL AS UserID;
    END
END;
GO
PRINT 'Created: sp_LoginUser';

-- SP 3: Add Travel Entry
CREATE PROCEDURE sp_AddTravelEntry
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
    DECLARE @EntryID INT;
    DECLARE @LocationID INT;
    
    BEGIN TRANSACTION;
    
    -- Insert Travel Entry
    INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
    VALUES (@UserID, @Title, @Description, @TravelDate, @Rating);
    
    SET @EntryID = SCOPE_IDENTITY();
    
    -- Check if Location exists
    SELECT @LocationID = LocationID 
    FROM Locations 
    WHERE LocationName = @LocationName 
        AND Latitude = @Latitude 
        AND Longitude = @Longitude;
    
    -- Create new Location if not exists
    IF @LocationID IS NULL
    BEGIN
        INSERT INTO Locations (LocationName, Address, City, Country, Latitude, Longitude, Category)
        VALUES (@LocationName, @Address, @City, @Country, @Latitude, @Longitude, @Category);
        
        SET @LocationID = SCOPE_IDENTITY();
        
        -- Create Statistics Record
        INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
        VALUES (@LocationID, 0, 0, 1);
    END
    
    -- Link Entry to Location
    INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder)
    VALUES (@EntryID, @LocationID, 1);
    
    -- Update Statistics
    EXEC sp_UpdateLocationStatistics @LocationID;
    
    COMMIT TRANSACTION;
    
    SELECT @EntryID AS NewEntryID, @LocationID AS LocationID;
END;
GO
PRINT 'Created: sp_AddTravelEntry';

-- SP 4: Update Location Statistics
CREATE PROCEDURE sp_UpdateLocationStatistics
    @LocationID INT
AS
BEGIN
    DECLARE @VisitCount INT;
    DECLARE @AvgRating DECIMAL(3,2);
    DECLARE @PopularityScale INT;
    
    -- Count Visits
    SELECT @VisitCount = COUNT(DISTINCT EL.EntryID)
    FROM EntryLocations EL
    WHERE EL.LocationID = @LocationID;
    
    -- Calculate Average Rating
    SELECT @AvgRating = AVG(CAST(TE.Rating AS DECIMAL(3,2)))
    FROM TravelEntries TE
    INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    WHERE EL.LocationID = @LocationID;
    
    -- Calculate Popularity Scale (1-5)
    SET @PopularityScale = CASE
        WHEN @VisitCount >= 100 THEN 5
        WHEN @VisitCount >= 50 THEN 4
        WHEN @VisitCount >= 20 THEN 3
        WHEN @VisitCount >= 5 THEN 2
        ELSE 1
    END;
    
    -- Update Statistics
    UPDATE LocationStatistics
    SET VisitCount = @VisitCount,
        AverageRating = ISNULL(@AvgRating, 0),
        PopularityScale = @PopularityScale,
        LastUpdated = GETDATE()
    WHERE LocationID = @LocationID;
END;
GO
PRINT 'Created: sp_UpdateLocationStatistics';

-- SP 5: Get User Travel Entries
CREATE PROCEDURE sp_GetUserTravelEntries
    @UserID INT
AS
BEGIN
    SELECT 
        TE.EntryID,
        TE.Title,
        TE.Description,
        TE.TravelDate,
        TE.Rating,
        L.LocationID,
        L.LocationName,
        L.City,
        L.Country,
        L.Latitude,
        L.Longitude,
        L.Category,
        TE.CreatedDate
    FROM TravelEntries TE
    INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    INNER JOIN Locations L ON EL.LocationID = L.LocationID
    WHERE TE.UserID = @UserID
    ORDER BY TE.TravelDate DESC;
END;
GO
PRINT 'Created: sp_GetUserTravelEntries';

-- SP 6: Get Location Statistics
CREATE PROCEDURE sp_GetLocationStatistics
AS
BEGIN
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
        LS.LastUpdated
    FROM Locations L
    INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
    ORDER BY LS.PopularityScale DESC, LS.VisitCount DESC;
END;
GO
PRINT 'Created: sp_GetLocationStatistics';

-- SP 7: Update User Profile
CREATE PROCEDURE sp_UpdateUserProfile
    @UserID INT,
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @DateOfBirth DATE = NULL,
    @ProfileImage NVARCHAR(255) = NULL
AS
BEGIN
    UPDATE Users
    SET FullName = @FullName,
        Email = @Email,
        DateOfBirth = @DateOfBirth,
        ProfileImage = @ProfileImage
    WHERE UserID = @UserID;
    
    SELECT UserID, Username, Email, FullName, DateOfBirth, ProfileImage, Role
    FROM Users
    WHERE UserID = @UserID;
END;
GO
PRINT 'Created: sp_UpdateUserProfile';

-- SP 8: Get User Profile
CREATE PROCEDURE sp_GetUserProfile
    @UserID INT
AS
BEGIN
    SELECT 
        U.UserID,
        U.Username,
        U.Email,
        U.FullName,
        U.DateOfBirth,
        U.ProfileImage,
        U.Role,
        U.CreatedDate,
        U.LastLogin,
        COUNT(DISTINCT TE.EntryID) AS TotalEntries,
        COUNT(DISTINCT EL.LocationID) AS TotalLocations
    FROM Users U
    LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
    LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    WHERE U.UserID = @UserID
    GROUP BY U.UserID, U.Username, U.Email, U.FullName, U.DateOfBirth, 
             U.ProfileImage, U.Role, U.CreatedDate, U.LastLogin;
END;
GO
PRINT 'Created: sp_GetUserProfile';

-- SP 9: Log User Activity
CREATE PROCEDURE sp_LogUserActivity
    @UserID INT,
    @ActivityType NVARCHAR(50),
    @ActivityDescription NVARCHAR(500) = NULL,
    @IPAddress NVARCHAR(50) = NULL,
    @UserAgent NVARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress, UserAgent)
    VALUES (@UserID, @ActivityType, @ActivityDescription, @IPAddress, @UserAgent);
END;
GO
PRINT 'Created: sp_LogUserActivity';

-- SP 10: Get All Users (Admin)
CREATE PROCEDURE sp_GetAllUsers
AS
BEGIN
    SELECT 
        U.UserID,
        U.Username,
        U.Email,
        U.FullName,
        U.Role,
        U.IsActive,
        U.CreatedDate,
        U.LastLogin,
        COUNT(DISTINCT TE.EntryID) AS TotalEntries,
        COUNT(DISTINCT EL.LocationID) AS TotalLocations
    FROM Users U
    LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
    LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    GROUP BY U.UserID, U.Username, U.Email, U.FullName, U.Role, U.IsActive, U.CreatedDate, U.LastLogin
    ORDER BY U.CreatedDate DESC;
END;
GO
PRINT 'Created: sp_GetAllUsers';

-- SP 11: Get User Activity Logs
CREATE PROCEDURE sp_GetUserActivityLogs
    @UserID INT = NULL,
    @TopRecords INT = 100
AS
BEGIN
    IF @UserID IS NULL
    BEGIN
        SELECT TOP (@TopRecords)
            L.LogID,
            L.UserID,
            U.Username,
            U.FullName,
            L.ActivityType,
            L.ActivityDescription,
            L.IPAddress,
            L.CreatedDate
        FROM UserActivityLogs L
        INNER JOIN Users U ON L.UserID = U.UserID
        ORDER BY L.CreatedDate DESC;
    END
    ELSE
    BEGIN
        SELECT TOP (@TopRecords)
            L.LogID,
            L.UserID,
            U.Username,
            U.FullName,
            L.ActivityType,
            L.ActivityDescription,
            L.IPAddress,
            L.CreatedDate
        FROM UserActivityLogs L
        INNER JOIN Users U ON L.UserID = U.UserID
        WHERE L.UserID = @UserID
        ORDER BY L.CreatedDate DESC;
    END
END;
GO
PRINT 'Created: sp_GetUserActivityLogs';

-- SP 12: Toggle User Status
CREATE PROCEDURE sp_ToggleUserStatus
    @UserID INT,
    @AdminUserID INT
AS
BEGIN
    DECLARE @CurrentStatus BIT;
    DECLARE @Username NVARCHAR(50);
    
    SELECT @CurrentStatus = IsActive, @Username = Username
    FROM Users
    WHERE UserID = @UserID;
    
    UPDATE Users
    SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
    WHERE UserID = @UserID;
    
    DECLARE @NewStatus BIT = CASE WHEN @CurrentStatus = 1 THEN 0 ELSE 1 END;
    DECLARE @Action NVARCHAR(500) = 'Admin ' + CAST(@AdminUserID AS NVARCHAR) + 
                                    ' changed status of user ' + @Username + 
                                    ' from ' + CASE WHEN @CurrentStatus = 1 THEN 'Active' ELSE 'Inactive' END +
                                    ' to ' + CASE WHEN @NewStatus = 1 THEN 'Active' ELSE 'Inactive' END;
    
    EXEC sp_LogUserActivity @AdminUserID, 'AdminAction', @Action;
    
    SELECT 'Success' AS Result, @NewStatus AS NewStatus;
END;
GO
PRINT 'Created: sp_ToggleUserStatus';

-- SP 13: Delete User
CREATE PROCEDURE sp_DeleteUser
    @UserID INT,
    @AdminUserID INT
AS
BEGIN
    DECLARE @Username NVARCHAR(50);
    
    SELECT @Username = Username FROM Users WHERE UserID = @UserID;
    
    IF @Username IS NOT NULL
    BEGIN
        DECLARE @Action NVARCHAR(500) = 'Admin deleted user: ' + @Username;
        EXEC sp_LogUserActivity @AdminUserID, 'AdminAction', @Action;
        
        DELETE FROM Users WHERE UserID = @UserID;
        
        SELECT 'Success' AS Result;
    END
    ELSE
    BEGIN
        SELECT 'Error' AS Result;
    END
END;
GO
PRINT 'Created: sp_DeleteUser';

PRINT '';

-- ========================================
-- 6. สร้าง Views
-- ========================================

PRINT '=== Creating Views ===';

-- View 1: Popular Locations
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
PRINT 'Created: vw_PopularLocations';

-- View 2: User Unique Locations
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
PRINT 'Created: vw_UserUniqueLocations';

-- View 3: User Stats Summary
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
PRINT 'Created: vw_UserStatsSummary';

PRINT '';

-- ========================================
-- 7. สร้าง Functions
-- ========================================

PRINT '=== Creating Functions ===';

-- Function: Get Activity Count by Date Range
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
PRINT 'Created: fn_GetActivityCountByDateRange';

PRINT '';

-- ========================================
-- 8. สร้าง Triggers
-- ========================================

PRINT '=== Creating Triggers ===';

-- Trigger: Auto-update Statistics
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
PRINT 'Created: trg_UpdateStatsAfterEntry';

PRINT '';

-- ========================================
-- 9. Insert Sample Data
-- ========================================

PRINT '=== Inserting Sample Data ===';

-- Sample Users (Password: password123 hashed with SHA256)
INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, IsActive) VALUES
('admin', 'admin@traveljournal.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Administrator', 'Admin', 1),
('john_doe', 'john@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'John Doe', 'User', 1),
('jane_smith', 'jane@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Jane Smith', 'User', 1);
PRINT '✓ Inserted sample users';

-- Sample Locations
INSERT INTO Locations (LocationName, Address, City, Country, Latitude, Longitude, Category) VALUES
('วัดพระแก้ว', 'ถนนหน้าพระลาน', 'กรุงเทพมหานคร', 'ไทย', 13.7506, 100.4920, 'วัฒนธรรม'),
('เกาะพีพี', 'อ่าวนาง', 'กระบี', 'ไทย', 7.7407, 98.7784, 'ธรรมชาติ'),
('ดอยสุเทพ', 'ตำบลสุเทพ', 'เชียงใหม่', 'ไทย', 18.8046, 98.9216, 'วัฒนธรรม'),
('ตลาดน้ำดำเนินสะดวก', 'อำเภอดำเนินสะดวก', 'ราชบุรี', 'ไทย', 13.5164, 99.9553, 'วัฒนธรรม'),
('อุทยานแห่งชาติเขาใหญ่', 'ตำบลปากช่อง', 'นครราชสีมา', 'ไทย', 14.4299, 101.3717, 'ธรรมชาติ');
PRINT '✓ Inserted sample locations';

-- Initialize Statistics
INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
SELECT LocationID, 0, 0, 1 FROM Locations;
PRINT '✓ Initialized location statistics';

-- Sample Activity Logs
INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, CreatedDate) VALUES
(1, 'Login', 'Admin logged in', DATEADD(DAY, -1, GETDATE())),
(2, 'Login', 'User logged in', DATEADD(DAY, -2, GETDATE())),
(3, 'Login', 'User logged in', DATEADD(DAY, -3, GETDATE()));
PRINT '✓ Inserted sample activity logs';

PRINT '';

-- ========================================
-- 10. Verification
-- ========================================

PRINT '=== Verification ===';

DECLARE @TableCount INT, @SPCount INT, @ViewCount INT, @TriggerCount INT;

SELECT @TableCount = COUNT(*) FROM sys.tables WHERE name IN ('Users', 'TravelEntries', 'Locations', 'EntryLocations', 'LocationStatistics', 'UserActivityLogs');
SELECT @SPCount = COUNT(*) FROM sys.procedures WHERE name LIKE 'sp_%';
SELECT @ViewCount = COUNT(*) FROM sys.views WHERE name LIKE 'vw_%';
SELECT @TriggerCount = COUNT(*) FROM sys.triggers WHERE name LIKE 'trg_%';

PRINT 'Tables created: ' + CAST(@TableCount AS NVARCHAR) + ' / 6';
PRINT 'Stored Procedures created: ' + CAST(@SPCount AS NVARCHAR) + ' / 13';
PRINT 'Views created: ' + CAST(@ViewCount AS NVARCHAR) + ' / 3';
PRINT 'Triggers created: ' + CAST(@TriggerCount AS NVARCHAR) + ' / 1';
PRINT '';

-- ========================================
-- 11. Summary
-- ========================================

PRINT '==============================================';
PRINT 'Database Creation Completed Successfully!';
PRINT '==============================================';
PRINT '';
PRINT 'Database: TravelJournalDB';
PRINT '';
PRINT 'Objects Created:';
PRINT '   - Tables: 6';
PRINT '   - Stored Procedures: 13';
PRINT '   - Views: 3';
PRINT '   - Functions: 1';
PRINT '   - Triggers: 1';
PRINT '   - Indexes: 9';
PRINT '';
PRINT 'Sample Users:';
PRINT '   Username: admin      | Password: password123 | Role: Admin';
PRINT '   Username: john_doe   | Password: password123 | Role: User';
PRINT '   Username: jane_smith | Password: password123 | Role: User';
PRINT '';
PRINT '🗺️ Sample Locations: 5';
PRINT '   - วัดพระแก้ว (กรุงเทพฯ)';
PRINT '   - เกาะพีพี (กระบี)';
PRINT '   - ดอยสุเทพ (เชียงใหม่)';
PRINT '   - ตลาดน้ำดำเนินสะดวก (ราชบุรี)';
PRINT '   - อุทยานแห่งชาติเขาใหญ่ (นครราชสีมา)';
PRINT '';
PRINT 'Security:';
PRINT '   - Password Hashing: SHA256';
PRINT '   - Role-based Access Control';
PRINT '   - Activity Logging Enabled';
PRINT '';
PRINT '🎯 Next Steps:';
PRINT '   1. Run this script in SQL Server Management Studio';
PRINT '   2. Configure Web.config connection string';
PRINT '   3. Build and run ASP.NET application';
PRINT '   4. Login with sample credentials';
PRINT '';
PRINT 'Features Available:';
PRINT '   ✓ User Registration & Login';
PRINT '   ✓ Travel Entry Management';
PRINT '   ✓ Location Tracking with Coordinates';
PRINT '   ✓ Google Maps Integration (via Leaflet)';
PRINT '   ✓ Travel Timeline';
PRINT '   ✓ User Profile with Photo Upload';
PRINT '   ✓ Admin Dashboard';
PRINT '   ✓ Location Statistics & Analytics';
PRINT '   ✓ User Activity Logging';
PRINT '   ✓ Popularity Scale (1-5)';
PRINT '';
PRINT '==============================================';
PRINT 'Script execution completed at: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '==============================================';
GO

-- ========================================
-- 12. Quick Test Queries (Optional)
-- ========================================

-- Uncomment these to test the database

/*
-- Test 1: View all users
SELECT * FROM Users;

-- Test 2: View all locations
SELECT * FROM Locations;

-- Test 3: View location statistics
EXEC sp_GetLocationStatistics;

-- Test 4: Test login
EXEC sp_LoginUser 'admin', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f';

-- Test 5: View activity logs
SELECT * FROM UserActivityLogs;

-- Test 6: View user stats
SELECT * FROM vw_UserStatsSummary;

-- Test 7: Test function
SELECT dbo.fn_GetActivityCountByDateRange(1, 7) AS ActivitiesLast7Days;
*/