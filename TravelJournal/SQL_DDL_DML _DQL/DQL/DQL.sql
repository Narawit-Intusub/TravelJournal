USE TravelJournalDB;
GO


-- ผู้ใช้ทั้งหมด (ล่าสุดก่อน)
SELECT UserID, Username, Email, Role, IsActive, CreatedDate, LastLogin
FROM dbo.Users
ORDER BY CreatedDate DESC;

-- รายการท่องเที่ยวทั้งหมด + ชื่อผู้ใช้
SELECT TE.EntryID, U.Username, TE.Title, TE.TravelDate, TE.Rating, TE.CreatedDate
FROM dbo.TravelEntries TE
JOIN dbo.Users U ON U.UserID = TE.UserID
ORDER BY TE.TravelDate DESC;

-- สถานที่ทั้งหมด + ค่าพิกัด + วันที่สร้าง
SELECT LocationID, LocationName, City, Country, Latitude, Longitude, Category, CreatedDate
FROM dbo.Locations
ORDER BY Country, City, LocationName;


-- แต่ละทริปไปที่ไหนบ้าง (รองรับหลายโลเคชันต่อ 1 entry)
SELECT 
  TE.EntryID, U.Username, TE.Title, TE.TravelDate, TE.Rating,
  L.LocationID, L.LocationName, L.City, L.Country, EL.VisitOrder
FROM dbo.TravelEntries TE
JOIN dbo.Users U ON U.UserID = TE.UserID
JOIN dbo.EntryLocations EL ON EL.EntryID = TE.EntryID
JOIN dbo.Locations L ON L.LocationID = EL.LocationID
ORDER BY TE.TravelDate DESC, EL.VisitOrder ASC;


-- สถานที่ยอดนิยม (เรียงตามจำนวนครั้งที่ไปเยือน)
SELECT TOP (20)
  L.LocationID, L.LocationName, L.City, L.Country, L.Category,
  LS.VisitCount, LS.AverageRating, LS.PopularityScale, LS.LastUpdated
FROM dbo.LocationStatistics LS
JOIN dbo.Locations L ON L.LocationID = LS.LocationID
ORDER BY LS.VisitCount DESC, LS.AverageRating DESC;

-- อันดับผู้ใช้ตามจำนวนทริป
SELECT TOP (20)
  U.UserID, U.Username, COUNT(*) AS TotalEntries,
  AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating
FROM dbo.Users U
LEFT JOIN dbo.TravelEntries TE ON TE.UserID = U.UserID
GROUP BY U.UserID, U.Username
ORDER BY TotalEntries DESC, AvgRating DESC;


-- ภาพรวมสถานที่ + ระดับความนิยมที่ทำเป็น label แล้ว
SELECT * FROM dbo.vw_PopularLocations ORDER BY PopularityScale DESC, VisitCount DESC;

-- ผู้ใช้แต่ละคนเคยไปที่ไหนบ้าง (unique) พร้อมจำนวนครั้ง/เรตติ้งเฉลี่ย
SELECT * FROM dbo.vw_UserUniqueLocations ORDER BY UserID, VisitCount DESC;

-- สรุปสถิติผู้ใช้ (entries/locations/กิจกรรมล่าสุด)
SELECT * FROM dbo.vw_UserStatsSummary ORDER BY CreatedDate DESC;


-- กิจกรรมล่าสุด (รวม UserActivityLogs + ActivityLogs)
SELECT TOP (50)
  U.Username, UA.ActivityType, UA.ActivityDescription, UA.IPAddress, UA.UserAgent, UA.CreatedDate
FROM dbo.UserActivityLogs UA
JOIN dbo.Users U ON U.UserID = UA.UserID
ORDER BY UA.CreatedDate DESC;

SELECT TOP (50)
  U.Username, AL.ActivityType, AL.ActivityDescription, AL.IPAddress, AL.CreatedDate
FROM dbo.ActivityLogs AL
JOIN dbo.Users U ON U.UserID = AL.UserID
ORDER BY AL.CreatedDate DESC;

-- สรุปกิจกรรมรายผู้ใช้ใน 30 วันที่ผ่านมา
SELECT U.UserID, U.Username, COUNT(*) AS ActivityCount
FROM dbo.UserActivityLogs UA
JOIN dbo.Users U ON U.UserID = UA.UserID
WHERE UA.CreatedDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY U.UserID, U.Username
ORDER BY ActivityCount DESC;
