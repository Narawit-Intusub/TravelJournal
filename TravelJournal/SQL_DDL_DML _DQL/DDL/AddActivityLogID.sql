-- ========================================
-- Create ActivityLogs System for TravelJournalDB
-- ========================================
USE TravelJournalDB;
GO

-- ============================================
-- Step 1: Create ActivityLogs table if not exists
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivityLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE ActivityLogs (
        ActivityLogID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        ActivityType NVARCHAR(50) NOT NULL,
        ActivityDescription NVARCHAR(500),
        IPAddress NVARCHAR(45),
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ActivityLogs_Users FOREIGN KEY (UserID) 
            REFERENCES Users(UserID) ON DELETE CASCADE
    );
    
    -- Create indexes for better performance
    CREATE INDEX IX_ActivityLogs_UserID ON ActivityLogs(UserID);
    CREATE INDEX IX_ActivityLogs_CreatedDate ON ActivityLogs(CreatedDate DESC);
    CREATE INDEX IX_ActivityLogs_ActivityType ON ActivityLogs(ActivityType);
    
    PRINT 'ActivityLogs table created successfully!';
END
ELSE
BEGIN
    PRINT 'ActivityLogs table already exists.';
END
GO

-- ============================================
-- Step 2: Insert sample activity logs for existing users
-- ============================================
IF NOT EXISTS (SELECT 1 FROM ActivityLogs)
BEGIN
    -- สร้าง sample logs สำหรับ users ทุกคน
    INSERT INTO ActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress, CreatedDate)
    SELECT 
        UserID,
        'Registration',
        'User registered successfully',
        '127.0.0.1',
        CreatedDate
    FROM Users;
    
    -- เพิ่ม login logs สำหรับ users ที่เคย login
    INSERT INTO ActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress, CreatedDate)
    SELECT 
        UserID,
        'Login',
        'User logged in',
        '127.0.0.1',
        LastLogin
    FROM Users
    WHERE LastLogin IS NOT NULL;
    
    PRINT 'Sample activity logs inserted for all users.';
END
ELSE
BEGIN
    PRINT 'ActivityLogs already contains data.';
END
GO

-- ============================================
-- Step 3: Create/Update sp_GetUserActivityLogs
-- ============================================
IF OBJECT_ID('sp_GetUserActivityLogs', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetUserActivityLogs;
GO

CREATE PROCEDURE sp_GetUserActivityLogs
    @UserID INT,
    @TopRecords INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopRecords)
        al.ActivityLogID,
        al.CreatedDate,
        al.ActivityType,
        al.ActivityDescription,
        al.IPAddress,
        u.Username
    FROM ActivityLogs al
    INNER JOIN Users u ON al.UserID = u.UserID
    WHERE al.UserID = @UserID
    ORDER BY al.CreatedDate DESC;
END
GO

PRINT 'sp_GetUserActivityLogs created successfully!';
GO

-- ============================================
-- Step 4: Create sp_InsertActivityLog
-- ============================================
IF OBJECT_ID('sp_InsertActivityLog', 'P') IS NOT NULL
    DROP PROCEDURE sp_InsertActivityLog;
GO

CREATE PROCEDURE sp_InsertActivityLog
    @UserID INT,
    @ActivityType NVARCHAR(50),
    @ActivityDescription NVARCHAR(500) = NULL,
    @IPAddress NVARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO ActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress, CreatedDate)
    VALUES (@UserID, @ActivityType, @ActivityDescription, @IPAddress, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS ActivityLogID;
END
GO

PRINT '✅ sp_InsertActivityLog created successfully!';
GO

-- ============================================
-- Step 5: Create sp_GetAllActivityLogs (for Admin)
-- ============================================
IF OBJECT_ID('sp_GetAllActivityLogs', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllActivityLogs;
GO

CREATE PROCEDURE sp_GetAllActivityLogs
    @TopRecords INT = 1000
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopRecords)
        al.ActivityLogID,
        al.UserID,
        u.Username,
        u.FullName,
        al.ActivityType,
        al.ActivityDescription,
        al.IPAddress,
        al.CreatedDate
    FROM ActivityLogs al
    INNER JOIN Users u ON al.UserID = u.UserID
    ORDER BY al.CreatedDate DESC;
END
GO

PRINT '✅ sp_GetAllActivityLogs created successfully!';
GO

-- ============================================
-- Step 6: Create sp_DeleteOldActivityLogs (Maintenance)
-- ============================================
IF OBJECT_ID('sp_DeleteOldActivityLogs', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteOldActivityLogs;
GO

CREATE PROCEDURE sp_DeleteOldActivityLogs
    @DaysToKeep INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DeleteCount INT;
    DECLARE @CutoffDate DATETIME = DATEADD(DAY, -@DaysToKeep, GETDATE());
    
    DELETE FROM ActivityLogs
    WHERE CreatedDate < @CutoffDate;
    
    SET @DeleteCount = @@ROWCOUNT;
    
    SELECT @DeleteCount AS DeletedRecords, @CutoffDate AS CutoffDate;
END
GO

PRINT 'sp_DeleteOldActivityLogs created successfully!';
GO

-- ============================================
-- Step 7: Create View for Activity Statistics
-- ============================================
IF OBJECT_ID('vw_UserActivityStats', 'V') IS NOT NULL
    DROP VIEW vw_UserActivityStats;
GO

CREATE VIEW vw_UserActivityStats AS
SELECT 
    U.UserID,
    U.Username,
    U.FullName,
    COUNT(AL.ActivityLogID) AS TotalActivities,
    MAX(AL.CreatedDate) AS LastActivity,
    SUM(CASE WHEN AL.ActivityType = 'Login' THEN 1 ELSE 0 END) AS LoginCount,
    SUM(CASE WHEN AL.ActivityType = 'Create' THEN 1 ELSE 0 END) AS CreateCount,
    SUM(CASE WHEN AL.ActivityType = 'Update' THEN 1 ELSE 0 END) AS UpdateCount,
    SUM(CASE WHEN AL.ActivityType = 'Delete' THEN 1 ELSE 0 END) AS DeleteCount,
    SUM(CASE WHEN AL.ActivityType = 'View' THEN 1 ELSE 0 END) AS ViewCount
FROM Users U
LEFT JOIN ActivityLogs AL ON U.UserID = AL.UserID
GROUP BY U.UserID, U.Username, U.FullName;
GO

PRINT 'vw_UserActivityStats created successfully!';
GO

-- ============================================
-- Step 8: Test the stored procedures
-- ============================================
PRINT '========================================';
PRINT 'Testing ActivityLogs System...';
PRINT '========================================';
GO

-- Test 1: Get logs for first user
DECLARE @TestUserID INT;
SELECT TOP 1 @TestUserID = UserID FROM Users ORDER BY UserID;

IF @TestUserID IS NOT NULL
BEGIN
    PRINT 'Test 1: Getting logs for UserID: ' + CAST(@TestUserID AS VARCHAR(10));
    EXEC sp_GetUserActivityLogs @UserID = @TestUserID, @TopRecords = 5;
    PRINT '';
END

-- Test 2: Insert a new activity log
IF @TestUserID IS NOT NULL
BEGIN
    PRINT 'Test 2: Inserting new activity log...';
    EXEC sp_InsertActivityLog 
        @UserID = @TestUserID, 
        @ActivityType = 'Test', 
        @ActivityDescription = 'Testing activity log system',
        @IPAddress = '192.168.1.1';
    PRINT '';
END

-- Test 3: View activity statistics
PRINT 'Test 3: Viewing activity statistics...';
SELECT TOP 5 * FROM vw_UserActivityStats ORDER BY TotalActivities DESC;
GO

PRINT '========================================';
PRINT 'ActivityLogs System Setup Complete!';
PRINT '========================================';
PRINT '';
PRINT 'Available Stored Procedures:';
PRINT '   - sp_GetUserActivityLogs';
PRINT '   - sp_InsertActivityLog';
PRINT '   - sp_GetAllActivityLogs';
PRINT '   - sp_DeleteOldActivityLogs';
PRINT '';
PRINT 'Available Views:';
PRINT '   - vw_UserActivityStats';
PRINT '';
PRINT 'You can now use the Activity Logs feature!';
GO