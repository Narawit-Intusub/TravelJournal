-- ========================================
-- Admin Features Database Setup
-- ========================================

USE TravelJournalDB;
GO

-- ========================================
-- Table: UserActivityLogs
-- ========================================
IF OBJECT_ID('UserActivityLogs', 'U') IS NULL
BEGIN
    CREATE TABLE UserActivityLogs (
        LogID INT PRIMARY KEY IDENTITY(1,1),
        UserID INT FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
        ActivityType NVARCHAR(50) NOT NULL, -- Login, Logout, AddEntry, UpdateProfile, etc.
        ActivityDescription NVARCHAR(500),
        IPAddress NVARCHAR(50),
        UserAgent NVARCHAR(500),
        CreatedDate DATETIME DEFAULT GETDATE()
    );

    CREATE INDEX IX_UserActivityLogs_UserID ON UserActivityLogs(UserID);
    CREATE INDEX IX_UserActivityLogs_ActivityType ON UserActivityLogs(ActivityType);
    CREATE INDEX IX_UserActivityLogs_CreatedDate ON UserActivityLogs(CreatedDate);
END
GO

-- ========================================
-- Stored Procedure: Log User Activity
-- ========================================
IF OBJECT_ID('sp_LogUserActivity', 'P') IS NOT NULL
    DROP PROCEDURE sp_LogUserActivity;
GO

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

-- ========================================
-- Stored Procedure: Get All Users (Admin)
-- ========================================
IF OBJECT_ID('sp_GetAllUsers', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllUsers;
GO

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

-- ========================================
-- Stored Procedure: Get User Activity Logs
-- ========================================
IF OBJECT_ID('sp_GetUserActivityLogs', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetUserActivityLogs;
GO

CREATE PROCEDURE sp_GetUserActivityLogs
    @UserID INT = NULL,
    @TopRecords INT = 100
AS
BEGIN
    IF @UserID IS NULL
    BEGIN
        -- Get all logs
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
        -- Get logs for specific user
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

-- ========================================
-- Stored Procedure: Toggle User Active Status
-- ========================================
IF OBJECT_ID('sp_ToggleUserStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_ToggleUserStatus;
GO

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
    
    -- Toggle status
    UPDATE Users
    SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
    WHERE UserID = @UserID;
    
    -- Log activity
    DECLARE @NewStatus BIT = CASE WHEN @CurrentStatus = 1 THEN 0 ELSE 1 END;
    DECLARE @Action NVARCHAR(500) = 'Admin ' + CAST(@AdminUserID AS NVARCHAR) + 
                                    ' changed status of user ' + @Username + 
                                    ' from ' + CASE WHEN @CurrentStatus = 1 THEN 'Active' ELSE 'Inactive' END +
                                    ' to ' + CASE WHEN @NewStatus = 1 THEN 'Active' ELSE 'Inactive' END;
    
    EXEC sp_LogUserActivity @AdminUserID, 'AdminAction', @Action;
    
    SELECT 'Success' AS Result, @NewStatus AS NewStatus;
END;
GO

-- ========================================
-- Stored Procedure: Delete User (Admin)
-- ========================================
IF OBJECT_ID('sp_DeleteUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteUser;
GO

CREATE PROCEDURE sp_DeleteUser
    @UserID INT,
    @AdminUserID INT
AS
BEGIN
    DECLARE @Username NVARCHAR(50);
    
    SELECT @Username = Username FROM Users WHERE UserID = @UserID;
    
    IF @Username IS NOT NULL
    BEGIN
        -- Log before delete
        DECLARE @Action NVARCHAR(500) = 'Admin deleted user: ' + @Username;
        EXEC sp_LogUserActivity @AdminUserID, 'AdminAction', @Action;
        
        -- Delete user (cascade will delete related data)
        DELETE FROM Users WHERE UserID = @UserID;
        
        SELECT 'Success' AS Result;
    END
    ELSE
    BEGIN
        SELECT 'Error' AS Result;
    END
END;
GO

-- ========================================
-- View: User Statistics Summary
-- ========================================
IF OBJECT_ID('vw_UserStatsSummary', 'V') IS NOT NULL
    DROP VIEW vw_UserStatsSummary;
GO

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
-- Insert Sample Activity Logs (for testing)
-- ========================================
-- สร้าง sample logs สำหรับ users ที่มีอยู่
INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, CreatedDate)
SELECT UserID, 'Login', 'User logged in', DATEADD(DAY, -RAND()*30, GETDATE())
FROM Users
WHERE UserID IN (1, 2);

INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, CreatedDate)
SELECT UserID, 'AddEntry', 'Added new travel entry', DATEADD(DAY, -RAND()*20, GETDATE())
FROM Users
WHERE UserID IN (1, 2);

-- ========================================
-- Function: Get Activity Stats by Date Range
-- ========================================
IF OBJECT_ID('fn_GetActivityCountByDateRange', 'FN') IS NOT NULL
    DROP FUNCTION fn_GetActivityCountByDateRange;
GO

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

PRINT 'Admin Features Database Setup Completed!';
PRINT '';
PRINT 'Created:';
PRINT '   - UserActivityLogs Table';
PRINT '   - sp_LogUserActivity';
PRINT '   - sp_GetAllUsers';
PRINT '   - sp_GetUserActivityLogs';
PRINT '   - sp_ToggleUserStatus';
PRINT '   - sp_DeleteUser';
PRINT '   - vw_UserStatsSummary View';
PRINT '   - fn_GetActivityCountByDateRange Function';
GO