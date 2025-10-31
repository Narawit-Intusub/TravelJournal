-- ========================================
-- Update Database สำหรับ User Profile
-- ========================================

USE TravelJournalDB;
GO

-- ตรวจสอบว่ามี ProfileImage column แล้วหรือยัง
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'ProfileImage')
BEGIN
    ALTER TABLE Users
    ADD ProfileImage NVARCHAR(255) NULL;
END
GO

-- สร้าง Stored Procedure สำหรับอัปเดต Profile
IF OBJECT_ID('sp_UpdateUserProfile', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateUserProfile;
GO

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

-- สร้าง Stored Procedure สำหรับดึงข้อมูล Profile
IF OBJECT_ID('sp_GetUserProfile', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetUserProfile;
GO

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

-- สร้าง View สำหรับดู User's Unique Locations
IF OBJECT_ID('vw_UserUniqueLocations', 'V') IS NOT NULL
    DROP VIEW vw_UserUniqueLocations;
GO

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

PRINT 'Profile System Updated Successfully!';
GO