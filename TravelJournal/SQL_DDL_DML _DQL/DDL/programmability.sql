USE [TravelJournalDB]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetActivityCountByDateRange]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetActivityCountByDateRange]
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
/****** Object:  View [dbo].[vw_PopularLocations]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_PopularLocations] AS
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
/****** Object:  View [dbo].[vw_UserStatsSummary]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_UserStatsSummary] AS
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
/****** Object:  View [dbo].[vw_UserUniqueLocations]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_UserUniqueLocations] AS
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
/****** Object:  StoredProcedure [dbo].[sp_AddTravelEntry]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_AddTravelEntry]
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
    
    -- เพิ่ม Travel Entry
    INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
    VALUES (@UserID, @Title, @Description, @TravelDate, @Rating);
    
    SET @EntryID = SCOPE_IDENTITY();
    
    -- ตรวจสอบว่า Location มีอยู่แล้วหรือไม่
    SELECT @LocationID = LocationID 
    FROM Locations 
    WHERE LocationName = @LocationName 
        AND Latitude = @Latitude 
        AND Longitude = @Longitude;
    
    -- ถ้าไม่มี ให้สร้างใหม่
    IF @LocationID IS NULL
    BEGIN
        INSERT INTO Locations (LocationName, Address, City, Country, Latitude, Longitude, Category)
        VALUES (@LocationName, @Address, @City, @Country, @Latitude, @Longitude, @Category);
        
        SET @LocationID = SCOPE_IDENTITY();
        
        -- สร้าง Statistics Record
        INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
        VALUES (@LocationID, 0, 0, 1);
    END
    
    -- เชื่อม Entry กับ Location
    INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder)
    VALUES (@EntryID, @LocationID, 1);
    
    -- Update Statistics
    EXEC sp_UpdateLocationStatistics @LocationID;
    
    COMMIT TRANSACTION;
    
    SELECT @EntryID AS NewEntryID, @LocationID AS LocationID;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteUser]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteUser]
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
/****** Object:  StoredProcedure [dbo].[sp_GetAllUsers]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllUsers]
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
/****** Object:  StoredProcedure [dbo].[sp_GetLocationStatistics]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetLocationStatistics]
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
/****** Object:  StoredProcedure [dbo].[sp_GetUserActivityLogs]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetUserActivityLogs]
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
/****** Object:  StoredProcedure [dbo].[sp_GetUserProfile]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetUserProfile]
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
/****** Object:  StoredProcedure [dbo].[sp_GetUserTravelEntries]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetUserTravelEntries]
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
/****** Object:  StoredProcedure [dbo].[sp_LoginUser]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Update Stored Procedure sp_LoginUser เพื่อส่งคืน Role
CREATE PROCEDURE [dbo].[sp_LoginUser]
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
/****** Object:  StoredProcedure [dbo].[sp_LogUserActivity]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_LogUserActivity]
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
/****** Object:  StoredProcedure [dbo].[sp_RegisterUser]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_RegisterUser]
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @FullName NVARCHAR(100)
AS
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName)
    VALUES (@Username, @Email, @Password, @FullName);
    
    SELECT SCOPE_IDENTITY() AS NewUserID;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ToggleUserStatus]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ToggleUserStatus]
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateLocationStatistics]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateLocationStatistics]
    @LocationID INT
AS
BEGIN
    DECLARE @VisitCount INT;
    DECLARE @AvgRating DECIMAL(3,2);
    DECLARE @PopularityScale INT;
    
    -- นับจำนวน Visit
    SELECT @VisitCount = COUNT(DISTINCT EL.EntryID)
    FROM EntryLocations EL
    WHERE EL.LocationID = @LocationID;
    
    -- คำนวณ Average Rating
    SELECT @AvgRating = AVG(CAST(TE.Rating AS DECIMAL(3,2)))
    FROM TravelEntries TE
    INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    WHERE EL.LocationID = @LocationID;
    
    -- คำนวณ Popularity Scale (1-5) จากจำนวน Visit
    -- Logic: แบ่ง 5 ระดับตาม Visit Count
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateUserProfile]    Script Date: 3/11/2568 2:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateUserProfile]
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
