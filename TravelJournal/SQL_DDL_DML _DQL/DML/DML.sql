-- ========================================
-- Travel Journal Database - DML Script
-- Data Manipulation Language
-- INSERT, UPDATE, DELETE statements
-- ========================================

USE TravelJournalDB;
GO

PRINT '=== Starting DML Script Execution ===';
PRINT '';

-- ========================================
-- 1. INSERT SAMPLE DATA
-- ========================================

PRINT '--- Inserting Sample Data ---';

-- ========================================
-- INSERT Users
-- ========================================
PRINT '';
PRINT 'Inserting Users...';

-- Admin User (Password: password123)
INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, IsActive) 
VALUES ('admin', 'admin@traveljournal.com', 
        'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
        'Administrator', 'Admin', 1);

-- Regular Users (Password: password123)
INSERT INTO Users (Username, Email, PasswordHash, FullName, DateOfBirth, Role, IsActive) 
VALUES 
('john_doe', 'john@example.com', 
 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'John Doe', '1990-05-15', 'User', 1),
('jane_smith', 'jane@example.com', 
 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Jane Smith', '1992-08-20', 'User', 1),
('bob_wilson', 'bob@example.com', 
 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Bob Wilson', '1988-12-10', 'User', 1),
('alice_brown', 'alice@example.com', 
 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Alice Brown', '1995-03-25', 'User', 1);

PRINT '✓ Inserted 5 users (1 Admin, 4 Users)';

-- ========================================
-- INSERT Locations
-- ========================================
PRINT '';
PRINT 'Inserting Locations...';

INSERT INTO Locations (LocationName, Address, City, Country, Latitude, Longitude, Category) 
VALUES 
-- Thailand Locations
('วัดพระแก้ว', 'ถนนหน้าพระลาน', 'กรุงเทพมหานคร', 'ไทย', 13.750600, 100.492000, 'วัฒนธรรม'),
('เกาะพีพี', 'อ่าวนาง', 'กระบี', 'ไทย', 7.740700, 98.778400, 'ธรรมชาติ'),
('ดอยสุเทพ', 'ตำบลสุเทพ', 'เชียงใหม่', 'ไทย', 18.804600, 98.921600, 'วัฒนธรรม'),
('พระบรมมหาราชวัง', 'ถนนหน้าพระลาน', 'กรุงเทพมหานคร', 'ไทย', 13.750000, 100.491300, 'วัฒนธรรม'),
('ตลาดน้ำดำเนินสะดวก', 'อำเภอดำเนินสะดวก', 'ราชบุรี', 'ไทย', 13.516400, 99.955300, 'วัฒนธรรม'),
('อุทยานแห่งชาติเขาใหญ่', 'ตำบลปากช่อง', 'นครราชสีมา', 'ไทย', 14.429900, 101.371700, 'ธรรมชาติ'),
('ตลาดจตุจักร', 'ถนนพหลโยธิน', 'กรุงเทพมหานคร', 'ไทย', 13.799600, 100.549600, 'ช้อปปิ้ง'),
('เกาะสมุย', 'อ่าวบางรัก', 'สุราษฎร์ธานี', 'ไทย', 9.515900, 100.006400, 'ธรรมชาติ'),
('พิพิธภัณฑ์สยาม', 'ถนนมหาราช', 'กรุงเทพมหานคร', 'ไทย', 13.744100, 100.492500, 'วัฒนธรรม'),
('ถนนคนเดินเชียงใหม่', 'ถนนท่าแพ', 'เชียงใหม่', 'ไทย', 18.787400, 98.991100, 'ช้อปปิ้ง'),
-- International Locations
('Eiffel Tower', 'Champ de Mars', 'Paris', 'France', 48.858400, 2.294500, 'วัฒนธรรม'),
('Great Wall of China', 'Huairou District', 'Beijing', 'China', 40.431900, 116.570400, 'วัฒนธรรม'),
('Machu Picchu', 'Cusco Region', 'Aguas Calientes', 'Peru', -13.163100, -72.545000, 'ธรรมชาติ'),
('Statue of Liberty', 'Liberty Island', 'New York', 'USA', 40.689200, -74.044500, 'วัฒนธรรม'),
('Sydney Opera House', 'Bennelong Point', 'Sydney', 'Australia', -33.856800, 151.215300, 'วัฒนธรรม');

PRINT '✓ Inserted 15 locations (10 Thailand, 5 International)';

-- ========================================
-- INSERT LocationStatistics (Initialize)
-- ========================================
PRINT '';
PRINT 'Initializing Location Statistics...';

INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
SELECT LocationID, 0, 0, 1 FROM Locations;

PRINT '✓ Initialized statistics for all locations';

-- ========================================
-- INSERT TravelEntries
-- ========================================
PRINT '';
PRINT 'Inserting Travel Entries...';

-- John's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(2, 'วันหยุดที่วัดพระแก้ว', 'สถานที่สวยงามมาก บรรยากาศดี', '2024-01-15', 5),
(2, 'ทริปเกาะพีพี สุดมันส์', 'ทะเลสวย น้ำใส เล่นน้ำได้ทั้งวัน', '2024-02-20', 5),
(2, 'เที่ยวดอยสุเทพ', 'วิวสวย อากาศเย็นสบาย', '2024-03-10', 4),
(2, 'ช้อปปิ้งจตุจักร', 'ของเยอะมาก ราคาถูก', '2024-04-05', 4),
(2, 'ทริปเขาใหญ่', 'อากาศดี เห็นสัตว์ป่า', '2024-05-12', 5);

-- Jane's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(3, 'Paris Dream Trip', 'Eiffel Tower at night is amazing!', '2024-01-20', 5),
(3, 'China Adventure', 'Great Wall exceeded expectations', '2024-02-15', 5),
(3, 'Thailand Beach Holiday', 'Phi Phi Island paradise', '2024-03-25', 5),
(3, 'Weekend at Palace', 'Grand Palace is stunning', '2024-04-10', 4),
(3, 'Floating Market Fun', 'Authentic Thai experience', '2024-05-08', 4);

-- Bob's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(4, 'Chiang Mai Weekend', 'Doi Suthep temple visit', '2024-02-18', 4),
(4, 'Bangkok Shopping', 'Chatuchak market amazing', '2024-03-22', 3),
(4, 'Samui Beach Trip', 'Relaxing beach holiday', '2024-04-15', 5),
(4, 'Cultural Bangkok', 'Siam Museum interesting', '2024-05-20', 4);

-- Alice's Entries
INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES 
(5, 'NYC Adventure', 'Statue of Liberty iconic', '2024-01-25', 5),
(5, 'Sydney Opera', 'Beautiful architecture', '2024-02-28', 5),
(5, 'Machu Picchu Trek', 'Once in a lifetime experience', '2024-03-30', 5),
(5, 'Bangkok Culture', 'Wat Phra Kaew magnificent', '2024-04-20', 5);

PRINT '✓ Inserted 18 travel entries';

-- ========================================
-- INSERT EntryLocations (Link Entries to Locations)
-- ========================================
PRINT '';
PRINT 'Linking Entries to Locations...';

INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder)
VALUES 
-- John's Trips
(1, 1, 1),  -- วัดพระแก้ว
(2, 2, 1),  -- เกาะพีพี
(3, 3, 1),  -- ดอยสุเทพ
(4, 7, 1),  -- จตุจักร
(5, 6, 1),  -- เขาใหญ่
-- Jane's Trips
(6, 11, 1), -- Eiffel Tower
(7, 12, 1), -- Great Wall
(8, 2, 1),  -- Phi Phi (repeat visit)
(9, 4, 1),  -- Grand Palace
(10, 5, 1), -- Floating Market
-- Bob's Trips
(11, 3, 1), -- Doi Suthep (repeat visit)
(12, 7, 1), -- Chatuchak (repeat visit)
(13, 8, 1), -- Samui
(14, 9, 1), -- Siam Museum
-- Alice's Trips
(15, 14, 1), -- Statue of Liberty
(16, 15, 1), -- Sydney Opera
(17, 13, 1), -- Machu Picchu
(18, 1, 1);  -- Wat Phra Kaew (repeat visit)

PRINT '✓ Linked all entries to locations';

-- ========================================
-- UPDATE LocationStatistics (Trigger will auto-update)
-- ========================================
PRINT '';
PRINT 'Updating Location Statistics...';

-- Manually update for locations that have visits
DECLARE @LocationID INT;
DECLARE location_cursor CURSOR FOR 
    SELECT DISTINCT LocationID FROM EntryLocations;

OPEN location_cursor;
FETCH NEXT FROM location_cursor INTO @LocationID;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_UpdateLocationStatistics @LocationID;
    FETCH NEXT FROM location_cursor INTO @LocationID;
END

CLOSE location_cursor;
DEALLOCATE location_cursor;

PRINT '✓ Updated statistics for all visited locations';

-- ========================================
-- INSERT UserActivityLogs (Sample Logs)
-- ========================================
PRINT '';
PRINT 'Inserting Activity Logs...';

INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, IPAddress, CreatedDate)
VALUES 
-- Login Activities
(1, 'Login', 'Admin logged in', '192.168.1.1', DATEADD(DAY, -7, GETDATE())),
(2, 'Login', 'User logged in', '192.168.1.2', DATEADD(DAY, -6, GETDATE())),
(3, 'Login', 'User logged in', '192.168.1.3', DATEADD(DAY, -5, GETDATE())),
(4, 'Login', 'User logged in', '192.168.1.4', DATEADD(DAY, -4, GETDATE())),
(5, 'Login', 'User logged in', '192.168.1.5', DATEADD(DAY, -3, GETDATE())),
-- Add Entry Activities
(2, 'AddEntry', 'Added entry: วันหยุดที่วัดพระแก้ว', '192.168.1.2', DATEADD(DAY, -6, GETDATE())),
(2, 'AddEntry', 'Added entry: ทริปเกาะพีพี สุดมันส์', '192.168.1.2', DATEADD(DAY, -5, GETDATE())),
(3, 'AddEntry', 'Added entry: Paris Dream Trip', '192.168.1.3', DATEADD(DAY, -5, GETDATE())),
(3, 'AddEntry', 'Added entry: China Adventure', '192.168.1.3', DATEADD(DAY, -4, GETDATE())),
(4, 'AddEntry', 'Added entry: Chiang Mai Weekend', '192.168.1.4', DATEADD(DAY, -4, GETDATE())),
-- Profile Updates
(2, 'UpdateProfile', 'Updated profile information', '192.168.1.2', DATEADD(DAY, -3, GETDATE())),
(3, 'UpdateProfile', 'Uploaded profile photo', '192.168.1.3', DATEADD(DAY, -2, GETDATE())),
-- Admin Actions
(1, 'AdminAction', 'Viewed user statistics', '192.168.1.1', DATEADD(DAY, -2, GETDATE())),
(1, 'AdminAction', 'Generated location report', '192.168.1.1', DATEADD(DAY, -1, GETDATE())),
-- Recent Activities
(2, 'Login', 'User logged in', '192.168.1.2', GETDATE()),
(1, 'Login', 'Admin logged in', '192.168.1.1', GETDATE());

PRINT '✓ Inserted 16 activity log entries';

PRINT '';

-- ========================================
-- 2. UPDATE EXAMPLES
-- ========================================

PRINT '--- Update Operations ---';
PRINT '';

-- Update User Profile
UPDATE Users 
SET ProfileImage = '~/ProfileImages/2_profile.jpg',
    DateOfBirth = '1990-05-15'
WHERE Username = 'john_doe';
PRINT '✓ Updated john_doe profile';

-- Update Entry Description
UPDATE TravelEntries
SET Description = 'สถานที่สวยงามมาก บรรยากาศดี แนะนำให้มาเที่ยว!',
    UpdatedDate = GETDATE()
WHERE EntryID = 1;
PRINT '✓ Updated entry description';

-- Update User LastLogin
UPDATE Users
SET LastLogin = GETDATE()
WHERE Username IN ('admin', 'john_doe', 'jane_smith');
PRINT '✓ Updated last login timestamps';

-- Update Location Category
UPDATE Locations
SET Category = 'อาหาร'
WHERE LocationName = 'ตลาดน้ำดำเนินสะดวก';
PRINT '✓ Updated location category';

PRINT '';

-- ========================================
-- 3. DELETE EXAMPLES (Commented out - for reference)
-- ========================================

PRINT '--- Delete Operations (Examples) ---';
PRINT '';

-- Delete Example 1: Delete a specific entry
-- DELETE FROM TravelEntries WHERE EntryID = 999;
PRINT '  (Example) DELETE FROM TravelEntries WHERE EntryID = 999;';

-- Delete Example 2: Delete inactive users
-- DELETE FROM Users WHERE IsActive = 0 AND DATEDIFF(DAY, LastLogin, GETDATE()) > 365;
PRINT '  (Example) DELETE FROM Users WHERE IsActive = 0;';

-- Delete Example 3: Delete old activity logs
-- DELETE FROM UserActivityLogs WHERE CreatedDate < DATEADD(YEAR, -1, GETDATE());
PRINT '  (Example) DELETE FROM UserActivityLogs WHERE CreatedDate < 1 year ago;';

-- Delete Example 4: Delete location and cascade
-- DELETE FROM Locations WHERE LocationID = 999;
PRINT '  (Example) DELETE FROM Locations WHERE LocationID = 999;';

PRINT '';
PRINT '(Delete examples are commented out to preserve sample data)';

PRINT '';

-- ========================================
-- 4. VERIFICATION QUERIES
-- ========================================

PRINT '--- Data Verification ---';
PRINT '';

DECLARE @UserCount INT, @EntryCount INT, @LocationCount INT, @LogCount INT;

SELECT @UserCount = COUNT(*) FROM Users;
SELECT @EntryCount = COUNT(*) FROM TravelEntries;
SELECT @LocationCount = COUNT(*) FROM Locations;
SELECT @LogCount = COUNT(*) FROM UserActivityLogs;

PRINT 'Data Summary:';
PRINT '  Users: ' + CAST(@UserCount AS NVARCHAR);
PRINT '  Travel Entries: ' + CAST(@EntryCount AS NVARCHAR);
PRINT '  Locations: ' + CAST(@LocationCount AS NVARCHAR);
PRINT '  Activity Logs: ' + CAST(@LogCount AS NVARCHAR);

PRINT '';
PRINT '=== DML Script Completed Successfully! ===';
PRINT '';
PRINT 'Sample Data Inserted:';
PRINT '  5 Users (1 Admin, 4 Users)';
PRINT '  15 Locations (Thailand + International)';
PRINT '  18 Travel Entries';
PRINT '  18 Entry-Location Links';
PRINT '  16 Activity Logs';
PRINT '  Updated Location Statistics';
PRINT '';
PRINT 'Test Credentials:';
PRINT '  Username: admin     | Password: password123';
PRINT '  Username: john_doe  | Password: password123';
PRINT '  Username: jane_smith| Password: password123';
GO