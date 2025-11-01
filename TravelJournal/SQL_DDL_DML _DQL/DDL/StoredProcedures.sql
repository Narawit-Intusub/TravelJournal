-- ========================================
-- Stored Procedures
-- ========================================

USE TravelJournalDB;
GO

-- ========================================
-- SP 1: Register User
-- ========================================
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

-- ========================================
-- SP 2: Login User
-- ========================================
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

-- ========================================
-- SP 3: Add Travel Entry
-- ========================================
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
    
    -- Add Travel Entry
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
    
    -- Link Entry with Location
    INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder)
    VALUES (@EntryID, @LocationID, 1);
    
    -- Update Statistics
    EXEC sp_UpdateLocationStatistics @LocationID;
    
    COMMIT TRANSACTION;
    
    SELECT @EntryID AS NewEntryID, @LocationID AS LocationID;
END;
GO

-- ========================================
-- SP 4: Update Location Statistics
-- ========================================
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
    
    -- Calculate Popularity Scale (1-5) based on Visit Count
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

-- ========================================
-- SP 5: Get User Travel Entries
-- ========================================
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

-- ========================================
-- SP 6: Get Location Statistics (Admin)
-- ========================================
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

-- ========================================
-- SP 7: Get User Profile
-- ========================================
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

-- ========================================
-- SP 8: Update User Profile
-- ========================================
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

-- ========================================
-- SP 9: Log User Activity
-- ========================================
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
-- SP 10: Get All Users (Admin)
-- ========================================
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
-- SP 11: Get User Activity Logs
-- ========================================
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

-- ========================================
-- SP 12: Toggle User Status (Admin)
-- ========================================
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
-- SP 13: Delete User (Admin)
-- ========================================
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

PRINT '✅ All Stored Procedures Created Successfully!';
GO