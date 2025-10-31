-- ========================================
-- Travel Journal Database Schema
-- SQL Server Management Studio
-- ========================================

USE TravelJournalDB;
GO

-- ========================================
-- Table 1: Users
-- ========================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    DateOfBirth DATE,
    ProfileImage NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    IsActive BIT DEFAULT 1
);

-- ========================================
-- Table 2: TravelEntries (บันทึกการท่องเที่ยว)
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

-- ========================================
-- Table 3: Locations (สถานที่ท่องเที่ยว)
-- ========================================
CREATE TABLE Locations (
    LocationID INT PRIMARY KEY IDENTITY(1,1),
    LocationName NVARCHAR(200) NOT NULL,
    Address NVARCHAR(500),
    City NVARCHAR(100),
    Country NVARCHAR(100),
    Latitude DECIMAL(10, 8) NOT NULL,
    Longitude DECIMAL(11, 8) NOT NULL,
    Category NVARCHAR(50), -- เช่น "ธรรมชาติ", "วัฒนธรรม", "อาหาร"
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- ========================================
-- Table 4: EntryLocations (ความสัมพันธ์ระหว่าง Entry กับ Location)
-- ========================================
CREATE TABLE EntryLocations (
    EntryLocationID INT PRIMARY KEY IDENTITY(1,1),
    EntryID INT FOREIGN KEY REFERENCES TravelEntries(EntryID) ON DELETE CASCADE,
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID) ON DELETE CASCADE,
    VisitOrder INT, -- ลำดับการเยี่ยมชม
    Notes NVARCHAR(500),
    PhotoURL NVARCHAR(255)
);

-- ========================================
-- Table 5: LocationStatistics (สถิติสถานที่)
-- ========================================
CREATE TABLE LocationStatistics (
    StatID INT PRIMARY KEY IDENTITY(1,1),
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID) ON DELETE CASCADE,
    VisitCount INT DEFAULT 0,
    AverageRating DECIMAL(3,2),
    PopularityScale INT CHECK (PopularityScale BETWEEN 1 AND 5),
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- ========================================
-- Indexes สำหรับ Performance
-- ========================================
CREATE INDEX IX_Users_Username ON Users(Username);
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_TravelEntries_UserID ON TravelEntries(UserID);
CREATE INDEX IX_TravelEntries_TravelDate ON TravelEntries(TravelDate);
CREATE INDEX IX_Locations_LatLong ON Locations(Latitude, Longitude);
CREATE INDEX IX_LocationStatistics_LocationID ON LocationStatistics(LocationID);

-- ========================================
-- Stored Procedures
-- ========================================

-- SP: ลงทะเบียน User ใหม่
GO
CREATE PROCEDURE sp_RegisterUser
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

-- SP: Login User
GO
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
        SELECT UserID, Username, Email, FullName FROM Users WHERE UserID = @UserID;
    END
    ELSE
    BEGIN
        SELECT NULL AS UserID;
    END
END;
GO

-- SP: เพิ่ม Travel Entry พร้อม Location
GO
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

-- SP: Update Location Statistics
GO
CREATE PROCEDURE sp_UpdateLocationStatistics
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

-- SP: Get User Travel Entries
GO
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

-- SP: Get Location Statistics for Admin
GO
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
-- Sample Data for Testing
-- ========================================

-- Insert Sample Users
INSERT INTO Users (Username, Email, PasswordHash, FullName) VALUES
('john_doe', 'john@example.com', 'hashed_password_123', 'John Doe'),
('jane_smith', 'jane@example.com', 'hashed_password_456', 'Jane Smith');

-- Insert Sample Locations
INSERT INTO Locations (LocationName, Address, City, Country, Latitude, Longitude, Category) VALUES
('วัดพระแก้ว', 'ถนนหน้าพระลาน', 'กรุงเทพมหานคร', 'ไทย', 13.7506, 100.4920, 'วัฒนธรรม'),
('เกาะพีพี', 'อ่าวนาง', 'กระบี', 'ไทย', 7.7407, 98.7784, 'ธรรมชาติ'),
('ตลาดน้ำดำเนินสะดวก', 'ราชบุรี', 'ราชบุรี', 'ไทย', 13.5164, 99.9553, 'วัฒนธรรม');

-- Initialize Statistics
INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
SELECT LocationID, 0, 0, 1 FROM Locations;

-- ========================================
-- Views สำหรับ Reporting
-- ========================================

GO
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
-- Trigger: Auto-update Statistics เมื่อมี Entry ใหม่
-- ========================================

GO
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

PRINT 'Database TravelJournalDB created successfully!';
PRINT 'All tables, stored procedures, views, and triggers have been created.';
PRINT 'Sample data has been inserted for testing.';