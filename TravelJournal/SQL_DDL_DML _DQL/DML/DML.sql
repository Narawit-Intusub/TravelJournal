-- ========================================
-- Travel Journal Database - DML Script (Full)
-- INSERT, UPDATE, DELETE samples + verification
-- ========================================

USE TravelJournalDB;
GO

PRINT '=== Starting DML Script Execution ===';
PRINT '';

-- ========================================
-- 1) INSERT SAMPLE DATA
-- ========================================

PRINT '--- Inserting Sample Data ---';

-- -----------------------------
-- 1.1 USERS
-- -----------------------------
PRINT 'Inserting Users...';

-- รหัสผ่านทั้งหมดเป็นตัวอย่าง hash (SHA-256 ของ "password123")
DECLARE @PwdHash NVARCHAR(255) = N'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f';

INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, IsActive)
VALUES ('admin','admin@traveljournal.com', @PwdHash, 'Administrator','Admin',1);

INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, DateOfBirth, Role, IsActive)
VALUES
('john_doe','john@example.com',  @PwdHash,'John Doe','1990-05-15','User',1),
('jane_smith','jane@example.com',@PwdHash,'Jane Smith','1992-08-20','User',1),
('bob_wilson','bob@example.com', @PwdHash,'Bob Wilson','1988-12-10','User',1),
('alice_brown','alice@example.com',@PwdHash,'Alice Brown','1995-03-25','User',1);

PRINT '✓ Inserted 5 users (1 Admin, 4 Users)';

-- -----------------------------
-- 1.2 LOCATIONS
-- -----------------------------
PRINT '';
PRINT 'Inserting Locations...';

INSERT INTO dbo.Locations (LocationName, Address, City, Country, Latitude, Longitude, Category)
VALUES
-- Thailand
(N'วัดพระแก้ว', N'ถนนหน้าพระลาน', N'กรุงเทพมหานคร', N'ไทย', 13.750600, 100.492000, N'วัฒนธรรม'),
(N'เกาะพีพี', N'อ่าวนาง', N'กระบี', N'ไทย', 7.740700, 98.778400, N'ธรรมชาติ'),
(N'ดอยสุเทพ', N'ตำบลสุเทพ', N'เชียงใหม่', N'ไทย', 18.804600, 98.921600, N'วัฒนธรรม'),
(N'พระบรมมหาราชวัง', N'ถนนหน้าพระลาน', N'กรุงเทพมหานคร', N'ไทย', 13.750000, 100.491300, N'วัฒนธรรม'),
(N'ตลาดน้ำดำเนินสะดวก', N'อำเภอดำเนินสะดวก', N'ราชบุรี', N'ไทย', 13.516400, 99.955300, N'วัฒนธรรม'),
(N'อุทยานแห่งชาติเขาใหญ่', N'ตำบลปากช่อง', N'นครราชสีมา', N'ไทย', 14.429900, 101.371700, N'ธรรมชาติ'),
(N'ตลาดจตุจักร', N'ถนนพหลโยธิน', N'กรุงเทพมหานคร', N'ไทย', 13.799600, 100.549600, N'ช้อปปิ้ง'),
(N'เกาะสมุย', N'อ่าวบางรัก', N'สุราษฎร์ธานี', N'ไทย', 9.515900, 100.006400, N'ธรรมชาติ'),
(N'พิพิธภัณฑ์สยาม', N'ถนนมหาราช', N'กรุงเทพมหานคร', N'ไทย', 13.744100, 100.492500, N'วัฒนธรรม'),
(N'ถนนคนเดินเชียงใหม่', N'ถนนท่าแพ', N'เชียงใหม่', N'ไทย', 18.787400, 98.991100, N'ช้อปปิ้ง'),
-- International
('Eiffel Tower', 'Champ de Mars', 'Paris', 'France', 48.858400,   2.294500, N'วัฒนธรรม'),
('Great Wall of China', 'Huairou District', 'Beijing', 'China', 40.431900, 116.570400, N'วัฒนธรรม'),
('Machu Picchu', 'Cusco Region', 'Aguas Calientes', 'Peru', -13.163100, -72.545000, N'ธรรมชาติ'),
('Statue of Liberty', 'Liberty Island', 'New York', 'USA', 40.689200, -74.044500, N'วัฒนธรรม'),
('Sydney Opera House', 'Bennelong Point', 'Sydney', 'Australia', -33.856800, 151.215300, N'วัฒนธรรม');

PRINT '✓ Inserted 15 locations (10 Thailand, 5 International)';

-- -----------------------------
-- 1.3 INITIALIZE LOCATION STATISTICS
-- -----------------------------
PRINT '';
PRINT 'Initializing Location Statistics...';

INSERT INTO dbo.LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
SELECT L.LocationID, 0, 0, 1
FROM dbo.Locations L
LEFT JOIN dbo.LocationStatistics S ON S.LocationID = L.LocationID
WHERE S.LocationID IS NULL;

PRINT '✓ Initialized statistics for all locations';

-- -----------------------------
-- Helper: เก็บ UserID และ LocationID ลงตัวแปร
-- -----------------------------
DECLARE @AdminID INT     = (SELECT UserID FROM dbo.Users WHERE Username = 'admin');
DECLARE @JohnID  INT     = (SELECT UserID FROM dbo.Users WHERE Username = 'john_doe');
DECLARE @JaneID  INT     = (SELECT UserID FROM dbo.Users WHERE Username = 'jane_smith');
DECLARE @BobID   INT     = (SELECT UserID FROM dbo.Users WHERE Username = 'bob_wilson');
DECLARE @AliceID INT     = (SELECT UserID FROM dbo.Users WHERE Username = 'alice_brown');

DECLARE @L_WatPhraKaew INT     = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'วัดพระแก้ว' AND Latitude=13.750600 AND Longitude=100.492000);
DECLARE @L_PhiPhi INT          = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'เกาะพีพี' AND Latitude=7.740700 AND Longitude=98.778400);
DECLARE @L_DoiSuthep INT       = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'ดอยสุเทพ' AND Latitude=18.804600 AND Longitude=98.921600);
DECLARE @L_Chatuchak INT       = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'ตลาดจตุจักร' AND Latitude=13.799600 AND Longitude=100.549600);
DECLARE @L_KhaoYai INT         = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'อุทยานแห่งชาติเขาใหญ่' AND Latitude=14.429900 AND Longitude=101.371700);
DECLARE @L_GrandPalace INT     = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'พระบรมมหาราชวัง' AND Latitude=13.750000 AND Longitude=100.491300);
DECLARE @L_FloatingMarket INT  = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'ตลาดน้ำดำเนินสะดวก' AND Latitude=13.516400 AND Longitude=99.955300);
DECLARE @L_SiamMuseum INT      = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'พิพิธภัณฑ์สยาม' AND Latitude=13.744100 AND Longitude=100.492500);
DECLARE @L_Samui INT           = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'เกาะสมุย' AND Latitude=9.515900 AND Longitude=100.006400);
DECLARE @L_ChiangMaiWalk INT   = (SELECT LocationID FROM dbo.Locations WHERE LocationName = N'ถนนคนเดินเชียงใหม่' AND Latitude=18.787400 AND Longitude=98.991100);

DECLARE @L_Eiffel INT          = (SELECT LocationID FROM dbo.Locations WHERE LocationName = 'Eiffel Tower');
DECLARE @L_GreatWall INT       = (SELECT LocationID FROM dbo.Locations WHERE LocationName = 'Great Wall of China');
DECLARE @L_Machu INT           = (SELECT LocationID FROM dbo.Locations WHERE LocationName = 'Machu Picchu');
DECLARE @L_StatueLiberty INT   = (SELECT LocationID FROM dbo.Locations WHERE LocationName = 'Statue of Liberty');
DECLARE @L_SydneyOpera INT     = (SELECT LocationID FROM dbo.Locations WHERE LocationName = 'Sydney Opera House');

-- -----------------------------
-- 1.4 TRAVEL ENTRIES (เก็บ EntryID ไว้ใช้ลิงก์)
-- -----------------------------
PRINT '';
PRINT 'Inserting Travel Entries...';

DECLARE @E1 INT, @E2 INT, @E3 INT, @E4 INT, @E5 INT;
DECLARE @E6 INT, @E7 INT, @E8 INT, @E9 INT, @E10 INT;
DECLARE @E11 INT, @E12 INT, @E13 INT, @E14 INT;
DECLARE @E15 INT, @E16 INT, @E17 INT, @E18 INT;

-- John's
INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JohnID, N'วันหยุดที่วัดพระแก้ว', N'สถานที่สวยงามมาก บรรยากาศดี', '2024-01-15', 5);
SET @E1 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JohnID, N'ทริปเกาะพีพี สุดมันส์', N'ทะเลสวย น้ำใส เล่นน้ำได้ทั้งวัน', '2024-02-20', 5);
SET @E2 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JohnID, N'เที่ยวดอยสุเทพ', N'วิวสวย อากาศเย็นสบาย', '2024-03-10', 4);
SET @E3 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JohnID, N'ช้อปปิ้งจตุจักร', N'ของเยอะมาก ราคาถูก', '2024-04-05', 4);
SET @E4 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JohnID, N'ทริปเขาใหญ่', N'อากาศดี เห็นสัตว์ป่า', '2024-05-12', 5);
SET @E5 = SCOPE_IDENTITY();

-- Jane's
INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JaneID, 'Paris Dream Trip', 'Eiffel Tower at night is amazing!', '2024-01-20', 5);
SET @E6 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JaneID, 'China Adventure', 'Great Wall exceeded expectations', '2024-02-15', 5);
SET @E7 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JaneID, 'Thailand Beach Holiday', 'Phi Phi Island paradise', '2024-03-25', 5);
SET @E8 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JaneID, 'Weekend at Palace', 'Grand Palace is stunning', '2024-04-10', 4);
SET @E9 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@JaneID, 'Floating Market Fun', 'Authentic Thai experience', '2024-05-08', 4);
SET @E10 = SCOPE_IDENTITY();

-- Bob's
INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@BobID, 'Chiang Mai Weekend', 'Doi Suthep temple visit', '2024-02-18', 4);
SET @E11 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@BobID, 'Bangkok Shopping', 'Chatuchak market amazing', '2024-03-22', 3);
SET @E12 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@BobID, 'Samui Beach Trip', 'Relaxing beach holiday', '2024-04-15', 5);
SET @E13 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@BobID, 'Cultural Bangkok', 'Siam Museum interesting', '2024-05-20', 4);
SET @E14 = SCOPE_IDENTITY();

-- Alice's
INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@AliceID, 'NYC Adventure', 'Statue of Liberty iconic', '2024-01-25', 5);
SET @E15 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@AliceID, 'Sydney Opera', 'Beautiful architecture', '2024-02-28', 5);
SET @E16 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@AliceID, 'Machu Picchu Trek', 'Once in a lifetime experience', '2024-03-30', 5);
SET @E17 = SCOPE_IDENTITY();

INSERT INTO dbo.TravelEntries (UserID, Title, Description, TravelDate, Rating)
VALUES (@AliceID, 'Bangkok Culture', 'Wat Phra Kaew magnificent', '2024-04-20', 5);
SET @E18 = SCOPE_IDENTITY();

PRINT '✓ Inserted 18 travel entries';

-- -----------------------------
-- 1.5 ENTRY-LOCATION LINKS
-- -----------------------------
PRINT '';
PRINT 'Linking Entries to Locations...';

INSERT INTO dbo.EntryLocations (EntryID, LocationID, VisitOrder)
VALUES
(@E1,  @L_WatPhraKaew, 1),
(@E2,  @L_PhiPhi,      1),
(@E3,  @L_DoiSuthep,   1),
(@E4,  @L_Chatuchak,   1),
(@E5,  @L_KhaoYai,     1),

(@E6,  @L_Eiffel,      1),
(@E7,  @L_GreatWall,   1),
(@E8,  @L_PhiPhi,      1),
(@E9,  @L_GrandPalace, 1),
(@E10, @L_FloatingMarket, 1),

(@E11, @L_DoiSuthep,   1),
(@E12, @L_Chatuchak,   1),
(@E13, @L_Samui,       1),
(@E14, @L_SiamMuseum,  1),

(@E15, @L_StatueLiberty, 1),
(@E16, @L_SydneyOpera,   1),
(@E17, @L_Machu,         1),
(@E18, @L_WatPhraKaew,   1);

PRINT '✓ Linked all entries to locations (trigger will update stats)';

-- อัปเดตสถิติซ้ำให้ชัดเจน (ไม่จำเป็นแต่ช่วยยืนยันผล)
;WITH DistLoc AS (
    SELECT DISTINCT LocationID FROM dbo.EntryLocations
)
SELECT 1 AS _kickoff INTO #tmpIfNotExists; -- กันกรณีไม่มีผลลัพธ์ ทำให้ TRY...CATCH ไม่ error
DECLARE @LocID INT;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT LocationID FROM DistLoc;
OPEN c; FETCH NEXT FROM c INTO @LocID;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.sp_UpdateLocationStatistics @LocID;
    FETCH NEXT FROM c INTO @LocID;
END
CLOSE c; DEALLOCATE c;
DROP TABLE #tmpIfNotExists;

PRINT '✓ Updated statistics for all visited locations';

-- -----------------------------
-- 1.6 USER/ACTIVITY LOGS
-- -----------------------------
PRINT '';
PRINT 'Inserting Activity Logs...';

-- ใช้ SP เพื่อเขียนลงทั้ง UserActivityLogs และ ActivityLogs
EXEC dbo.sp_LogUserActivity @UserID=@AdminID, @ActivityType=N'Login',       @ActivityDescription=N'Admin logged in',   @IPAddress='192.168.1.1', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@JohnID,  @ActivityType=N'Login',       @ActivityDescription=N'User logged in',    @IPAddress='192.168.1.2', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@JaneID,  @ActivityType=N'Login',       @ActivityDescription=N'User logged in',    @IPAddress='192.168.1.3', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@BobID,   @ActivityType=N'Login',       @ActivityDescription=N'User logged in',    @IPAddress='192.168.1.4', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@AliceID, @ActivityType=N'Login',       @ActivityDescription=N'User logged in',    @IPAddress='192.168.1.5', @UserAgent=NULL;

EXEC dbo.sp_LogUserActivity @UserID=@JohnID,  @ActivityType=N'AddEntry',    @ActivityDescription=N'Added: วันหยุดที่วัดพระแก้ว', @IPAddress='192.168.1.2', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@JohnID,  @ActivityType=N'AddEntry',    @ActivityDescription=N'Added: ทริปเกาะพีพี สุดมันส์', @IPAddress='192.168.1.2', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@JaneID,  @ActivityType=N'AddEntry',    @ActivityDescription=N'Added: Paris Dream Trip', @IPAddress='192.168.1.3', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@JaneID,  @ActivityType=N'AddEntry',    @ActivityDescription=N'Added: China Adventure',  @IPAddress='192.168.1.3', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@BobID,   @ActivityType=N'AddEntry',    @ActivityDescription=N'Added: Chiang Mai Weekend', @IPAddress='192.168.1.4', @UserAgent=NULL;

EXEC dbo.sp_LogUserActivity @UserID=@JohnID,  @ActivityType=N'UpdateProfile', @ActivityDescription=N'Updated profile information', @IPAddress='192.168.1.2', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@JaneID,  @ActivityType=N'UpdateProfile', @ActivityDescription=N'Uploaded profile photo',      @IPAddress='192.168.1.3', @UserAgent=NULL;

EXEC dbo.sp_LogUserActivity @UserID=@AdminID, @ActivityType=N'AdminAction', @ActivityDescription=N'Viewed user statistics', @IPAddress='192.168.1.1', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@AdminID, @ActivityType=N'AdminAction', @ActivityDescription=N'Generated location report', @IPAddress='192.168.1.1', @UserAgent=NULL;

-- recent
EXEC dbo.sp_LogUserActivity @UserID=@JohnID,  @ActivityType=N'Login', @ActivityDescription=N'User logged in', @IPAddress='192.168.1.2', @UserAgent=NULL;
EXEC dbo.sp_LogUserActivity @UserID=@AdminID, @ActivityType=N'Login', @ActivityDescription=N'Admin logged in', @IPAddress='192.168.1.1', @UserAgent=NULL;

PRINT '✓ Inserted activity logs via sp_LogUserActivity';

-- ========================================
-- 2) UPDATE EXAMPLES
-- ========================================
PRINT '';
PRINT '--- Update Operations ---';

-- Update User Profile
UPDATE dbo.Users
SET ProfileImage = N'~/ProfileImages/2_profile.jpg',
    DateOfBirth = '1990-05-15'
WHERE Username = 'john_doe';
PRINT '✓ Updated john_doe profile';

-- Update Entry Description
UPDATE dbo.TravelEntries
SET Description = N'สถานที่สวยงามมาก บรรยากาศดี แนะนำให้มาเที่ยว!',
    UpdatedDate = GETDATE()
WHERE EntryID = @E1;
PRINT '✓ Updated entry description';

-- Update User LastLogin
UPDATE dbo.Users
SET LastLogin = GETDATE()
WHERE Username IN ('admin','john_doe','jane_smith');
PRINT '✓ Updated last login timestamps';

-- Update Location Category
UPDATE dbo.Locations
SET Category = N'อาหาร'
WHERE LocationName = N'ตลาดน้ำดำเนินสะดวก';
PRINT '✓ Updated location category';

-- ========================================
-- 3) (OPTIONAL) DELETE EXAMPLES – COMMENTED
-- ========================================
PRINT '';
PRINT '--- Delete Operations (Examples) ---';

-- ตัวอย่าง (คอมเมนต์ไว้เพื่อรักษาข้อมูลตัวอย่าง)
-- DELETE FROM dbo.TravelEntries WHERE EntryID = 999;
-- DELETE FROM dbo.Users WHERE IsActive = 0 AND DATEDIFF(DAY, LastLogin, GETDATE()) > 365;
-- DELETE FROM dbo.UserActivityLogs WHERE CreatedDate < DATEADD(YEAR, -1, GETDATE());
-- DELETE FROM dbo.Locations WHERE LocationID = 999;

PRINT '  *Examples commented out*';

-- ========================================
-- 4) VERIFICATION QUERIES
-- ========================================
PRINT '';
PRINT '--- Data Verification ---';

DECLARE @UserCount INT, @EntryCount INT, @LocationCount INT, @LogCount INT, @ActCount INT;

SELECT @UserCount = COUNT(*) FROM dbo.Users;
SELECT @EntryCount = COUNT(*) FROM dbo.TravelEntries;
SELECT @LocationCount = COUNT(*) FROM dbo.Locations;
SELECT @LogCount = COUNT(*) FROM dbo.UserActivityLogs;
SELECT @ActCount = COUNT(*) FROM dbo.ActivityLogs;

PRINT 'Data Summary:';
PRINT '  Users: '           + CAST(@UserCount AS NVARCHAR(20));
PRINT '  Travel Entries: '  + CAST(@EntryCount AS NVARCHAR(20));
PRINT '  Locations: '       + CAST(@LocationCount AS NVARCHAR(20));
PRINT '  UserActivityLogs: '+ CAST(@LogCount AS NVARCHAR(20));
PRINT '  ActivityLogs: '    + CAST(@ActCount AS NVARCHAR(20));

PRINT '';
PRINT '=== DML Script Completed Successfully! ===';
PRINT '';
PRINT 'Sample Data Inserted:';
PRINT '  5 Users (1 Admin, 4 Users)';
PRINT '  15 Locations (Thailand + International)';
PRINT '  18 Travel Entries';
PRINT '  18 Entry-Location Links';
PRINT '  Activity Logs inserted via SP';
PRINT '  Location Statistics updated (trigger + SP)';
PRINT '';
PRINT 'Test Credentials:';
PRINT '  Username: admin       | Password: password123';
PRINT '  Username: john_doe    | Password: password123';
PRINT '  Username: jane_smith  | Password: password123';
GO
