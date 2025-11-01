-- ========================================
-- DML (Data Manipulation Language)
-- INSERT, UPDATE, DELETE Sample Data
-- ========================================

USE TravelJournalDB;
GO

-- ========================================
-- INSERT Sample Users
-- ========================================

-- Password: "password123" (SHA256)
-- Hash: ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f

INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, IsActive) 
VALUES 
('admin', 'admin@traveljournal.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Administrator', 'Admin', 1),
('john_doe', 'john@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'John Doe', 'User', 1),
('jane_smith', 'jane@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Jane Smith', 'User', 1),
('somchai', 'somchai@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'สมชาย ใจดี', 'User', 1);
GO

PRINT 'Users inserted: admin, john_doe, jane_smith, somchai';
PRINT 'Password for all: password123';
GO

-- ========================================
-- INSERT Sample Locations (Thailand)
-- ========================================

INSERT INTO Locations (LocationName, Address, City, Country, Latitude, Longitude, Category) VALUES
('วัดพระแก้ว', 'ถนนหน้าพระลาน', 'กรุงเทพมหานคร', 'ไทย', 13.750600, 100.492000, 'วัฒนธรรม'),
('พระบรมมหาราชวัง', 'ถนนหน้าพระลาน', 'กรุงเทพมหานคร', 'ไทย', 13.750000, 100.491300, 'วัฒนธรรม'),
('เกาะพีพี', 'อ่าวนาง', 'กระบี', 'ไทย', 7.740700, 98.778400, 'ธรรมชาติ'),
('ดอยสุเทพ', 'ถนนห้วยแก้ว', 'เชียงใหม่', 'ไทย', 18.804600, 98.921600, 'วัฒนธรรม'),
('ตลาดน้ำดำเนินสะดวก', 'ตำบลดำเนินสะดวก', 'ราชบุรี', 'ไทย', 13.516400, 99.955300, 'วัฒนธรรม'),
('หาดป่าตอง', 'ถนนราชอุทิศ', 'ภูเก็ต', 'ไทย', 7.890000, 98.300000, 'ธรรมชาติ'),
('ตลาดน้ำอัมพวา', 'อัมพวา', 'สมุทรสงคราม', 'ไทย', 13.425000, 99.956700, 'วัฒนธรรม'),
('วัดอรุณราชวราราม', 'ถนนอรุณอมรินทร์', 'กรุงเทพมหานคร', 'ไทย', 13.743900, 100.488700, 'วัฒนธรรม'),
('ตลาดจตุจักร', 'ถนนพหลโยธิน', 'กรุงเทพมหานคร', 'ไทย', 13.799722, 100.549722, 'ช้อปปิ้ง'),
('ไร่องุ่นเขาใหญ่', 'ตำบลมูสี', 'นครราชสีมา', 'ไทย', 14.430000, 101.370000, 'ธรรมชาติ');
GO

PRINT 'Sample Locations inserted: 10 locations in Thailand';
GO

-- ========================================
-- Initialize Location Statistics
-- ========================================

INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
SELECT LocationID, 0, 0, 1 FROM Locations;
GO

PRINT 'Location Statistics initialized';
GO

-- ========================================
-- INSERT Sample Travel Entries
-- ========================================

-- John's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(2, 'เที่ยววัดพระแก้ว', 'สวยงามมาก วัดที่สวยที่สุดในไทย', '2024-01-15', 5),
(2, 'ดำน้ำที่เกาะพีพี', 'น้ำใสมาก ปะการังสวย', '2024-02-20', 5),
(2, 'ไหว้พระดอยสุเทพ', 'วิวสวย อากาศดี', '2024-03-10', 4);

-- Jane's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(3, 'ช้อปปิ้งจตุจักร', 'ของเยอะมาก ราคาถูก', '2024-01-20', 4),
(3, 'ตะลุยตลาดน้ำอัมพวา', 'อาหารอร่อย บรรยากาศดี', '2024-02-15', 5),
(3, 'พักผ่อนหาดป่าตอง', 'หาดสวย น้ำทะเลสะอาด', '2024-03-05', 4);

-- Somchai's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(4, 'เที่ยววัดอรุณ', 'ถ่ายรูปสวยมาก', '2024-01-25', 5),
(4, 'ชิมไวน์เขาใหญ่', 'บรรยากาศดี อากาศเย็น', '2024-02-28', 4),
(4, 'ล่องเรือตลาดน้ำดำเนินสะดวก', 'สนุก ของอร่อย', '2024-03-15', 4);
GO

PRINT 'Sample Travel Entries inserted: 9 entries';
GO

-- ========================================
-- Link Entries with Locations
-- ========================================

-- John's entries
INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder) VALUES
(1, 1, 1),  -- วัดพระแก้ว
(2, 3, 1),  -- เกาะพีพี
(3, 4, 1);  -- ดอยสุเทพ

-- Jane's entries
INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder) VALUES
(4, 9, 1),  -- ตลาดจตุจักร
(5, 7, 1),  -- ตลาดน้ำอัมพวา
(6, 6, 1);  -- หาดป่าตอง

-- Somchai's entries
INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder) VALUES
(7, 8, 1),  -- วัดอรุณ
(8, 10, 1), -- ไร่องุ่นเขาใหญ่
(9, 5, 1);  -- ตลาดน้ำดำเนินสะดวก
GO

PRINT 'Entry-Location relationships created';
GO

-- ========================================
-- Update Location Statistics
-- ========================================

EXEC sp_UpdateLocationStatistics 1;  -- วัดพระแก้ว
EXEC sp_UpdateLocationStatistics 3;  -- เกาะพีพี
EXEC sp_UpdateLocationStatistics 4;  -- ดอยสุเทพ
EXEC sp_UpdateLocationStatistics 5;  -- ตลาดน้ำดำเนินสะดวก
EXEC sp_UpdateLocationStatistics 6;  -- หาดป่าตอง
EXEC sp_UpdateLocationStatistics 7;  -- ตลาดน้ำอัมพวา
EXEC sp_UpdateLocationStatistics 8;  -- วัดอรุณ
EXEC sp_UpdateLocationStatistics 9;  -- ตลาดจตุจักร
EXEC sp_UpdateLocationStatistics 10; -- ไร่องุ่นเขาใหญ่
GO

PRINT 'Location Statistics updated';
GO

-- ========================================
-- INSERT Sample Activity Logs
-- ========================================

INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, CreatedDate) VALUES
(2, 'Login', 'User logged in', DATEADD(DAY, -5, GETDATE())),
(2, 'AddEntry', 'Added travel entry: เที่ยววัดพระแก้ว', DATEADD(DAY, -4, GETDATE())),
(3, 'Login', 'User logged in', DATEADD(DAY, -3, GETDATE())),
(3, 'AddEntry', 'Added travel entry: ช้อปปิ้งจตุจักร', DATEADD(DAY, -2, GETDATE())),
(4, 'Login', 'User logged in', DATEADD(DAY, -1, GETDATE())),
(4, 'UpdateProfile', 'Updated profile information', DATEADD(DAY, -1, GETDATE()));
GO

PRINT 'Sample Activity Logs inserted';
GO

-- ========================================
-- UPDATE Examples
-- ========================================

-- Update user's full name
UPDATE Users 
SET FullName = 'John William Doe' 
WHERE Username = 'john_doe';

-- Update entry description
UPDATE TravelEntries 
SET Description = 'สวยงามมาก วัดที่สวยที่สุดในไทย บรรยากาศศักดิ์สิทธิ์' 
WHERE EntryID = 1;

-- Update location category
UPDATE Locations 
SET Category = 'ช้อปปิ้ง/วัฒนธรรม' 
WHERE LocationID = 9;

GO

PRINT 'Sample UPDATEs executed';
GO

-- ========================================
-- DELETE Examples (Commented for safety)
-- ========================================

-- Delete a specific entry (uncomment to use)
-- DELETE FROM TravelEntries WHERE EntryID = 1;

-- Delete inactive users (uncomment to use)
-- DELETE FROM Users WHERE IsActive = 0;

-- Delete old activity logs (uncomment to use)
-- DELETE FROM UserActivityLogs WHERE CreatedDate < DATEADD(MONTH, -6, GETDATE());

PRINT '⚠️ DELETE examples are commented for safety';
GO

-- ========================================
-- Verification Queries
-- ========================================

PRINT '';
PRINT '========== Data Verification ==========';
PRINT '';

-- Count records
SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM Users
UNION ALL
SELECT 'Locations', COUNT(*) FROM Locations
UNION ALL
SELECT 'TravelEntries', COUNT(*) FROM TravelEntries
UNION ALL
SELECT 'EntryLocations', COUNT(*) FROM EntryLocations
UNION ALL
SELECT 'LocationStatistics', COUNT(*) FROM LocationStatistics
UNION ALL
SELECT 'UserActivityLogs', COUNT(*) FROM UserActivityLogs;

PRINT '';
PRINT '✅ DML Completed - Sample Data Inserted Successfully!';
PRINT '';
PRINT '📝 Test Accounts:';
PRINT '   Username: admin      | Password: password123 | Role: Admin';
PRINT '   Username: john_doe   | Password: password123 | Role: User';
PRINT '   Username: jane_smith | Password: password123 | Role: User';
PRINT '   Username: somchai    | Password: password123 | Role: User';
GO