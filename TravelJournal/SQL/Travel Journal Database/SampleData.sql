-- ========================================
-- Travel Journal - Sample Data 
-- สร้างข้อมูลตัวอย่าง 200+ Records
-- Username: user001, user002, ..., user200
-- Password: password123 (ทุกคน)
-- Email: user1@example.com, user2@example.com, ...
-- ========================================

USE TravelJournalDB;
GO

PRINT '=== Starting Sample Data Generation ===';
PRINT '';

-- ========================================
-- 1. Generate 200 Users
-- ========================================

PRINT '=== Generating Users (200 records) ===';

DECLARE @UserCounter INT = 1;
DECLARE @Username NVARCHAR(50);
DECLARE @Email NVARCHAR(100);
DECLARE @FullName NVARCHAR(100);
DECLARE @FirstNames TABLE (Name NVARCHAR(50));
DECLARE @LastNames TABLE (Name NVARCHAR(50));

-- Thai First Names
INSERT INTO @FirstNames VALUES 
('สมชาย'), ('สมหญิง'), ('วิชัย'), ('สุดา'), ('ประยุทธ์'),
('อรุณ'), ('สุภาพร'), ('นิรันดร์'), ('พิมพ์ชนก'), ('ธนพล'),
('กฤษณะ'), ('สุธิดา'), ('วรรณา'), ('ปิยะ'), ('ธีรพงษ์'),
('นภัสสร'), ('ชัยวัฒน์'), ('กัญญา'), ('ธนากร'), ('ศิริพร'),
('John'), ('David'), ('Michael'), ('Sarah'), ('Emma'),
('James'), ('Emily'), ('Daniel'), ('Sophia'), ('Matthew'),
('Jessica'), ('Andrew'), ('Lisa'), ('Christopher'), ('Jennifer'),
('Ryan'), ('Ashley'), ('Kevin'), ('Michelle'), ('Brian');

-- Thai Last Names
INSERT INTO @LastNames VALUES
('ใจดี'), ('สุขสันต์'), ('รักเรียน'), ('มั่นคง'), ('ชาญชัย'),
('วิริยะ'), ('อุดมทรัพย์'), ('สว่างวงศ์'), ('เจริญสุข'), ('ทวีสุข'),
('ศรีสุข'), ('กิจการ'), ('บุญมี'), ('เพชรรัตน์'), ('ทองคำ'),
('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'),
('Garcia'), ('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'),
('Hernandez'), ('Lopez'), ('Gonzalez'), ('Wilson'), ('Anderson'),
('Thomas'), ('Taylor'), ('Moore'), ('Jackson'), ('Martin');

-- Password: password123 (SHA256)
DECLARE @PasswordHash NVARCHAR(255) = 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f';

WHILE @UserCounter <= 200
BEGIN
    SET @Username = 'user' + RIGHT('000' + CAST(@UserCounter AS NVARCHAR), 3);
    SET @Email = 'user' + CAST(@UserCounter AS NVARCHAR) + '@example.com';
    
    -- Random name combination
    SET @FullName = (SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID()) + ' ' + 
                    (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
    
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, IsActive, CreatedDate)
    VALUES (
        @Username, 
        @Email, 
        @PasswordHash, 
        @FullName,
        'User',
        1,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()) -- Random date within last year
    );
    
    SET @UserCounter = @UserCounter + 1;
    
    IF @UserCounter % 50 = 0
        PRINT '  Progress: ' + CAST(@UserCounter AS NVARCHAR) + ' users created...';
END

PRINT 'Created 200 users';
PRINT '';

-- ========================================
-- 2. Generate 200 Locations (Thailand + International)
-- ========================================

PRINT '=== Generating Locations (200 records) ===';

-- Thailand Locations
INSERT INTO Locations (LocationName, City, Country, Latitude, Longitude, Category) VALUES
-- Bangkok (50 locations)
('วัดพระแก้ว', 'กรุงเทพมหานคร', 'ไทย', 13.7506, 100.4920, 'วัฒนธรรม'),
('พระบรมมหาราชวัง', 'กรุงเทพมหานคร', 'ไทย', 13.7500, 100.4913, 'วัฒนธรรม'),
('วัดอรุณราชวราราม', 'กรุงเทพมหานคร', 'ไทย', 13.7437, 100.4887, 'วัฒนธรรม'),
('วัดโพธิ์', 'กรุงเทพมหานคร', 'ไทย', 13.7465, 100.4927, 'วัฒนธรรม'),
('ตลาดนัดจตุจักร', 'กรุงเทพมหานคร', 'ไทย', 13.7998, 100.5496, 'ช้อปปิ้ง'),
('สยามพารากอน', 'กรุงเทพมหานคร', 'ไทย', 13.7469, 100.5347, 'ช้อปปิ้ง'),
('ไอคอนสยาม', 'กรุงเทพมหานคร', 'ไทย', 13.7265, 100.5106, 'ช้อปปิ้ง'),
('เอเชียทีค เดอะ ริเวอร์ฟร้อนท์', 'กรุงเทพมหานคร', 'ไทย', 13.7042, 100.5113, 'ช้อปปิ้ง'),
('วัดไตรมิตรวิทยาราม', 'กรุงเทพมหานคร', 'ไทย', 13.7398, 100.5157, 'วัฒนธรรม'),
('วัดเทพศิรินทราวาส', 'กรุงเทพมหานคร', 'ไทย', 13.7651, 100.5071, 'วัฒนธรรม'),
('ถนนข้าวสาร', 'กรุงเทพมหานคร', 'ไทย', 13.7650, 100.5290, 'อาหาร'),
('เยาวราช', 'กรุงเทพมหานคร', 'ไทย', 13.7398, 100.5093, 'อาหาร'),
('ตลาดรถไฟศรีนครินทร์', 'กรุงเทพมหานคร', 'ไทย', 13.6912, 100.6452, 'ช้อปปิ้ง'),
('สวนลุมพินี', 'กรุงเทพมหานคร', 'ไทย', 13.7307, 100.5418, 'ธรรมชาติ'),
('สวนจตุจักร', 'กรุงเทพมหานคร', 'ไทย', 13.7965, 100.5528, 'ธรรมชาติ'),

-- Chiang Mai (30 locations)
('ดอยสุเทพ', 'เชียงใหม่', 'ไทย', 18.8046, 98.9216, 'วัฒนธรรม'),
('วัดพระธาตุดอยสุเทพ', 'เชียงใหม่', 'ไทย', 18.8047, 98.9217, 'วัฒนธรรม'),
('ถนนคนเดินวันอาทิตย์', 'เชียงใหม่', 'ไทย', 18.7883, 98.9853, 'ช้อปปิ้ง'),
('ประตูท่าแพ', 'เชียงใหม่', 'ไทย', 18.7869, 98.9917, 'อาหาร'),
('วัดเชียงมั่น', 'เชียงใหม่', 'ไทย', 18.7913, 98.9853, 'วัฒนธรรม'),
('สวนสัตว์เชียงใหม่', 'เชียงใหม่', 'ไทย', 18.8000, 98.9503, 'ธรรมชาติ'),
('ดอยอินทนนท์', 'เชียงใหม่', 'ไทย', 18.5886, 98.4867, 'ธรรมชาติ'),
('แม่สา', 'เชียงใหม่', 'ไทย', 18.9250, 98.8514, 'ธรรมชาติ'),
('บ่อสร้าง', 'เชียงใหม่', 'ไทย', 19.0933, 98.7853, 'ธรรมชาติ'),
('ไนท์บาซาร์', 'เชียงใหม่', 'ไทย', 18.7875, 98.9952, 'ช้อปปิ้ง'),

-- Phuket (25 locations)
('หาดป่าตอง', 'ภูเก็ต', 'ไทย', 7.8965, 98.3002, 'ธรรมชาติ'),
('หาดกะตะ', 'ภูเก็ต', 'ไทย', 7.8166, 98.3006, 'ธรรมชาติ'),
('หาดกะรน', 'ภูเก็ต', 'ไทย', 7.8042, 98.2993, 'ธรรมชาติ'),
('แหลมพรหมเทพ', 'ภูเก็ต', 'ไทย', 7.7553, 98.3050, 'ธรรมชาติ'),
('วัดฉลอง', 'ภูเก็ต', 'ไทย', 7.8388, 98.3479, 'วัฒนธรรม'),
('พิพิธภัณฑ์ภูเก็ต', 'ภูเก็ต', 'ไทย', 7.8821, 98.3880, 'วัฒนธรรม'),
('ตลาดใหม่บางเหนียว', 'ภูเก็ต', 'ไทย', 7.8831, 98.3877, 'อาหาร'),
('หาดไม้ขาว', 'ภูเก็ต', 'ไทย', 8.0431, 98.3134, 'ธรรมชาติ'),
('อ่าวปัง-งา', 'พังงา', 'ไทย', 8.2756, 98.5014, 'ธรรมชาติ'),
('เกาะพีพี', 'กระบี', 'ไทย', 7.7407, 98.7784, 'ธรรมชาติ'),

-- Other Thailand Locations (50 locations)
('อยุธยา', 'พระนครศรีอยุธยา', 'ไทย', 14.3532, 100.5776, 'วัฒนธรรม'),
('วัดพระศรีสรรเพชญ์', 'พระนครศรีอยุธยา', 'ไทย', 14.3558, 100.5679, 'วัฒนธรรม'),
('สุโขทัย', 'สุโขทัย', 'ไทย', 17.0137, 99.7060, 'วัฒนธรรม'),
('เขาใหญ่', 'นครราชสีมา', 'ไทย', 14.4299, 101.3717, 'ธรรมชาติ'),
('พิมาย', 'นครราชสีมา', 'ไทย', 15.2206, 102.4952, 'วัฒนธรรม'),
('น้ำตกเอราวัณ', 'กาญจนบุรี', 'ไทย', 14.3710, 99.1483, 'ธรรมชาติ'),
('สะพานข้ามแม่น้ำแคว', 'กาญจนบุรี', 'ไทย', 14.0421, 99.5051, 'วัฒนธรรม'),
('ตลาดน้ำดำเนินสะดวก', 'ราชบุรี', 'ไทย', 13.5164, 99.9553, 'วัฒนธรรม'),
('เขาหลวง', 'ระนอง', 'ไทย', 9.5406, 98.6208, 'ธรรมชาติ'),
('หาดรัตนชัย', 'ระนอง', 'ไทย', 9.9554, 98.6191, 'ธรรมชาติ'),
('เกาะสมุย', 'สุราษฎร์ธานี', 'ไทย', 9.5357, 100.0628, 'ธรรมชาติ'),
('เกาะพะงัน', 'สุราษฎร์ธานี', 'ไทย', 9.7331, 100.0104, 'ธรรมชาติ'),
('เกาะเต่า', 'สุราษฎร์ธานี', 'ไทย', 10.0955, 99.8384, 'ธรรมชาติ'),
('หาดราไวย์', 'ภูเก็ต', 'ไทย', 7.7831, 98.3264, 'ธรรมชาติ'),
('อ่าวนาง', 'กระบี', 'ไทย', 8.0314, 98.8270, 'ธรรมชาติ'),
('ถ้ำพระนาง', 'กระบี', 'ไทย', 8.0184, 98.8396, 'ธรรมชาติ'),
('เกาะลันตา', 'กระบี', 'ไทย', 7.6477, 99.0407, 'ธรรมชาติ'),
('พัทยา', 'ชลบุรี', 'ไทย', 12.9236, 100.8825, 'ธรรมชาติ'),
('เกาะล้าน', 'ชลบุรี', 'ไทย', 12.9166, 100.7734, 'ธรรมชาติ'),
('หาดจอมเทียน', 'ชลบุรี', 'ไทย', 12.8673, 100.9100, 'ธรรมชาติ');

-- Generate additional random locations to reach 200
DECLARE @LocationCounter INT = 1;
DECLARE @LocName NVARCHAR(200);
DECLARE @LocCity NVARCHAR(100);
DECLARE @LocCountry NVARCHAR(100);
DECLARE @Lat DECIMAL(10, 8);
DECLARE @Lng DECIMAL(11, 8);
DECLARE @Cat NVARCHAR(50);

DECLARE @Cities TABLE (City NVARCHAR(100), Country NVARCHAR(100));
INSERT INTO @Cities VALUES
('เชียงราย', 'ไทย'), ('ลำปาง', 'ไทย'), ('พะเยา', 'ไทย'), ('น่าน', 'ไทย'),
('อุดรธานี', 'ไทย'), ('ขอนแก่น', 'ไทย'), ('อุบลราชธานี', 'ไทย'),
('นครพนม', 'ไทย'), ('สกลนคร', 'ไทย'), ('เลย', 'ไทย'),
('ตรัง', 'ไทย'), ('สตูล', 'ไทย'), ('สงขลา', 'ไทย'), ('ปัตตานี', 'ไทย'),
('ประจวบคีรีขันธ์', 'ไทย'), ('เพชรบุรี', 'ไทย'), ('สมุทรสาคร', 'ไทย'),
('Tokyo', 'Japan'), ('Kyoto', 'Japan'), ('Osaka', 'Japan'), ('Seoul', 'South Korea'),
('Busan', 'South Korea'), ('Singapore', 'Singapore'), ('Bali', 'Indonesia'),
('Paris', 'France'), ('London', 'UK'), ('New York', 'USA'), ('Los Angeles', 'USA'),
('Rome', 'Italy'), ('Barcelona', 'Spain'), ('Amsterdam', 'Netherlands'),
('Berlin', 'Germany'), ('Vienna', 'Austria'), ('Sydney', 'Australia'),
('Melbourne', 'Australia'), ('Dubai', 'UAE'), ('Hong Kong', 'China');

DECLARE @Categories TABLE (Category NVARCHAR(50));
INSERT INTO @Categories VALUES ('ธรรมชาติ'), ('วัฒนธรรม'), ('อาหาร'), ('ผจญภัย'), ('ช้อปปิ้ง'), ('อื่นๆ');

WHILE @LocationCounter <= 135 -- Add 135 more to reach 200 total
BEGIN
    -- Random location data
    SELECT TOP 1 @LocCity = City, @LocCountry = Country FROM @Cities ORDER BY NEWID();
    SELECT TOP 1 @Cat = Category FROM @Categories ORDER BY NEWID();
    
    SET @LocName = @LocCity + ' Attraction ' + CAST(@LocationCounter AS NVARCHAR);
    
    -- Random coordinates (Thailand range: 5-20 lat, 97-106 lng)
    IF @LocCountry = 'ไทย'
    BEGIN
        SET @Lat = 5.0 + (ABS(CHECKSUM(NEWID())) % 1500) / 100.0;
        SET @Lng = 97.0 + (ABS(CHECKSUM(NEWID())) % 900) / 100.0;
    END
    ELSE
    BEGIN
        -- International coordinates
        SET @Lat = -90.0 + (ABS(CHECKSUM(NEWID())) % 18000) / 100.0;
        SET @Lng = -180.0 + (ABS(CHECKSUM(NEWID())) % 36000) / 100.0;
    END
    
    INSERT INTO Locations (LocationName, City, Country, Latitude, Longitude, Category)
    VALUES (@LocName, @LocCity, @LocCountry, @Lat, @Lng, @Cat);
    
    SET @LocationCounter = @LocationCounter + 1;
    
    IF @LocationCounter % 50 = 0
        PRINT '  Progress: ' + CAST(@LocationCounter + 65 AS NVARCHAR) + ' locations created...';
END

PRINT 'Created 200 locations';
PRINT '';

-- Initialize Statistics for all locations
INSERT INTO LocationStatistics (LocationID, VisitCount, AverageRating, PopularityScale)
SELECT LocationID, 0, 0, 1 
FROM Locations 
WHERE LocationID NOT IN (SELECT LocationID FROM LocationStatistics);

PRINT '✓ Initialized location statistics';
PRINT '';

-- ========================================
-- 3. Generate 500+ Travel Entries
-- ========================================

PRINT '=== Generating Travel Entries (500+ records) ===';

DECLARE @EntryCounter INT = 1;
DECLARE @RandomUserID INT;
DECLARE @RandomLocationID INT;
DECLARE @RandomTitle NVARCHAR(200);
DECLARE @RandomDesc NVARCHAR(MAX);
DECLARE @RandomDate DATE;
DECLARE @RandomRating INT;

DECLARE @Titles TABLE (Title NVARCHAR(200));
INSERT INTO @Titles VALUES
('ทริปสุดประทับใจ'), ('การเดินทางที่ยอดเยี่ยม'), ('วันหยุดที่น่าจดจำ'),
('ประสบการณ์ที่ดีที่สุด'), ('ทริปสุดพิเศษ'), ('วันหยุดแสนสนุก'),
('การผจญภัยครั้งใหม่'), ('ทริปครอบครัว'), ('เที่ยวกับเพื่อน'),
('honeymoon trip'), ('solo travel'), ('business trip'),
('amazing experience'), ('wonderful journey'), ('memorable trip'),
('best vacation ever'), ('perfect getaway'), ('awesome adventure');

DECLARE @Descriptions TABLE (Description NVARCHAR(MAX));
INSERT INTO @Descriptions VALUES
('สถานที่สวยงามมาก บรรยากาศดี อาหารอร่อย ประทับใจมากๆ จะกลับมาอีกแน่นอน'),
('ทริปนี้สนุกมาก ได้เห็นทิวทัศน์สวยๆ ผู้คนเป็นมิตร บริการดีเยี่ยม'),
('ถือเป็นการเดินทางที่คุ้มค่ามาก ได้ประสบการณ์ดีๆ เรียนรู้วัฒนธรรมใหม่ๆ'),
('สถานที่นี้เหมาะสำหรับครอบครัว เด็กๆชอบมาก มีกิจกรรมให้ทำเยอะ'),
('บรรยากาศสงบ เงียบ เหมาะกับการพักผ่อน รีแลกซ์ได้ดีมาก'),
('Amazing place! Beautiful scenery, friendly people, great food'),
('Perfect location for photography, stunning views everywhere'),
('Highly recommended for adventure seekers, lots of activities'),
('Best place to relax and unwind, peaceful atmosphere'),
('Great for families, kids loved it, safe and clean environment');

WHILE @EntryCounter <= 500
BEGIN
    -- Random user (1-200)
    SET @RandomUserID = 1 + (ABS(CHECKSUM(NEWID())) % 200);
    
    -- Random location (1-200)
    SET @RandomLocationID = 1 + (ABS(CHECKSUM(NEWID())) % 200);
    
    -- Random title and description
    SELECT TOP 1 @RandomTitle = Title FROM @Titles ORDER BY NEWID();
    SELECT TOP 1 @RandomDesc = Description FROM @Descriptions ORDER BY NEWID();
    
    -- Random date within last 2 years
    SET @RandomDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 730), GETDATE());
    
    -- Random rating 1-5
    SET @RandomRating = 1 + (ABS(CHECKSUM(NEWID())) % 5);
    
    -- Insert Travel Entry
    INSERT INTO TravelEntries (UserID, Title, Description, TravelDate, Rating, CreatedDate)
    VALUES (@RandomUserID, @RandomTitle, @RandomDesc, @RandomDate, @RandomRating, @RandomDate);
    
    -- Link to Location
    INSERT INTO EntryLocations (EntryID, LocationID, VisitOrder)
    VALUES (SCOPE_IDENTITY(), @RandomLocationID, 1);
    
    SET @EntryCounter = @EntryCounter + 1;
    
    IF @EntryCounter % 100 = 0
        PRINT '  Progress: ' + CAST(@EntryCounter AS NVARCHAR) + ' travel entries created...';
END

PRINT 'Created 500+ travel entries';
PRINT '';

-- ========================================
-- 4. Update Location Statistics
-- ========================================

PRINT '=== Updating Location Statistics ===';

-- Update all location statistics
DECLARE @StatLocationID INT;
DECLARE loc_cursor CURSOR FOR 
    SELECT DISTINCT LocationID FROM EntryLocations;

OPEN loc_cursor;
FETCH NEXT FROM loc_cursor INTO @StatLocationID;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_UpdateLocationStatistics @StatLocationID;
    FETCH NEXT FROM loc_cursor INTO @StatLocationID;
END

CLOSE loc_cursor;
DEALLOCATE loc_cursor;

PRINT 'Updated all location statistics';
PRINT '';

-- ========================================
-- 5. Generate Activity Logs (300+ records)
-- ========================================

PRINT '=== Generating Activity Logs (300+ records) ===';

DECLARE @LogCounter INT = 1;
DECLARE @LogUserID INT;
DECLARE @LogType NVARCHAR(50);
DECLARE @LogDesc NVARCHAR(500);
DECLARE @LogDate DATETIME;

DECLARE @ActivityTypes TABLE (ActivityType NVARCHAR(50), Description NVARCHAR(500));
INSERT INTO @ActivityTypes VALUES
('Login', 'User logged in to the system'),
('Logout', 'User logged out from the system'),
('AddEntry', 'Added new travel entry'),
('UpdateProfile', 'Updated user profile information'),
('UploadPhoto', 'Uploaded profile photo'),
('ViewMap', 'Viewed travel map'),
('ViewTimeline', 'Viewed travel timeline'),
('SearchLocation', 'Searched for a location'),
('ViewStatistics', 'Viewed location statistics');

WHILE @LogCounter <= 300
BEGIN
    -- Random user
    SET @LogUserID = 1 + (ABS(CHECKSUM(NEWID())) % 200);
    
    -- Random activity
    SELECT TOP 1 @LogType = ActivityType, @LogDesc = Description 
    FROM @ActivityTypes ORDER BY NEWID();
    
    -- Random date within last 6 months
    SET @LogDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 180), GETDATE());
    
    INSERT INTO UserActivityLogs (UserID, ActivityType, ActivityDescription, CreatedDate)
    VALUES (@LogUserID, @LogType, @LogDesc, @LogDate);
    
    SET @LogCounter = @LogCounter + 1;
    
    IF @LogCounter % 100 = 0
        PRINT '  Progress: ' + CAST(@LogCounter AS NVARCHAR) + ' activity logs created...';
END

PRINT 'Created 300+ activity logs';
PRINT '';

-- ========================================
-- 6. Summary Statistics
-- ========================================

PRINT '==============================================';
PRINT 'Sample Data Generation Completed!';
PRINT '==============================================';
PRINT '';

DECLARE @TotalUsers INT, @TotalLocations INT, @TotalEntries INT, @TotalLogs INT;
DECLARE @MostPopularLocation NVARCHAR(200), @MostActiveUser NVARCHAR(50);

SELECT @TotalUsers = COUNT(*) FROM Users;
SELECT @TotalLocations = COUNT(*) FROM Locations;
SELECT @TotalEntries = COUNT(*) FROM TravelEntries;
SELECT @TotalLogs = COUNT(*) FROM UserActivityLogs;

SELECT TOP 1 @MostPopularLocation = L.LocationName
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
ORDER BY LS.VisitCount DESC;

SELECT TOP 1 @MostActiveUser = U.Username
FROM Users U
INNER JOIN TravelEntries TE ON U.UserID = TE.UserID
GROUP BY U.Username
ORDER BY COUNT(TE.EntryID) DESC;

PRINT 'Database Statistics:';
PRINT '   Total Users: ' + CAST(@TotalUsers AS NVARCHAR);
PRINT '   Total Locations: ' + CAST(@TotalLocations AS NVARCHAR);
PRINT '   Total Travel Entries: ' + CAST(@TotalEntries AS NVARCHAR);
PRINT '   Total Activity Logs: ' + CAST(@TotalLogs AS NVARCHAR);
PRINT '';
PRINT 'Top Statistics:';
PRINT '   Most Popular Location: ' + ISNULL(@MostPopularLocation, 'N/A');
PRINT '   Most Active User: ' + ISNULL(@MostActiveUser, 'N/A');
PRINT '';
PRINT 'Test Credentials:';
PRINT '   All users: user001 to user200';
PRINT '   Password: password123';
PRINT '   Admin: admin / password123';
PRINT '';
PRINT 'Popularity Scale Distribution:';

SELECT 
    PopularityScale,
    COUNT(*) AS LocationCount,
    CASE PopularityScale
        WHEN 5 THEN 'Very Popular (100+ visits)'
        WHEN 4 THEN 'Popular (50-99 visits)'
        WHEN 3 THEN 'Moderate (20-49 visits)'
        WHEN 2 THEN 'Low (5-19 visits)'
        ELSE 'Very Low (0-4 visits)'
    END AS Description
FROM LocationStatistics
GROUP BY PopularityScale
ORDER BY PopularityScale DESC;

PRINT '';
PRINT '==============================================';
PRINT 'Ready to use! Login and explore the data.';
PRINT '==============================================';
GO