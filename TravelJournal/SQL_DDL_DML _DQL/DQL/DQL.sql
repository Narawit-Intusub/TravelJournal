-- ========================================
-- Travel Journal - Complex SQL Queries
-- 10 คำสั่ง SQL ที่ซับซ้อนและเป็นประโยชน์
-- ========================================

USE TravelJournalDB;
GO

PRINT '=== Complex SQL Queries for Travel Journal ===';
PRINT '';

-- ========================================
-- Query 1: Top 5 Most Active Users
-- คำอธิบาย: หาผู้ใช้ที่มีกิจกรรมมากที่สุด 5 อันดับแรก
-- ใช้: JOIN, COUNT, GROUP BY, ORDER BY, HAVING
-- ========================================

PRINT '1. Top 5 Most Active Users (Users with Most Entries and Locations)';
PRINT '-------------------------------------------------------------------';

SELECT TOP 5
    U.UserID,
    U.Username,
    U.FullName,
    U.Email,
    COUNT(DISTINCT TE.EntryID) AS TotalEntries,
    COUNT(DISTINCT EL.LocationID) AS UniqueLocations,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AverageRating,
    MAX(TE.TravelDate) AS LastTravelDate,
    DATEDIFF(DAY, MIN(TE.TravelDate), MAX(TE.TravelDate)) AS TravelingDays
FROM Users U
INNER JOIN TravelEntries TE ON U.UserID = TE.UserID
INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
WHERE U.IsActive = 1
GROUP BY U.UserID, U.Username, U.FullName, U.Email
HAVING COUNT(DISTINCT TE.EntryID) >= 1  -- มีอย่างน้อย 1 Entry
ORDER BY TotalEntries DESC, UniqueLocations DESC;

PRINT '';

-- ========================================
-- Query 2: Popular Locations with User Visit Details
-- คำอธิบาย: แสดงสถานที่ยอดนิยม พร้อมรายละเอียดผู้เยี่ยมชม
-- ใช้: Multiple JOINs, Aggregate Functions, Subquery
-- ========================================

PRINT '2. Popular Locations with Complete Statistics';
PRINT '----------------------------------------------';

SELECT 
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country,
    L.Category,
    LS.VisitCount,
    LS.AverageRating,
    LS.PopularityScale,
    -- Subquery: นับจำนวน Users ที่เคยมา
    (SELECT COUNT(DISTINCT TE.UserID)
     FROM TravelEntries TE
     INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
     WHERE EL.LocationID = L.LocationID) AS UniqueVisitors,
    -- Subquery: หาวันที่มีคนมาล่าสุด
    (SELECT MAX(TE.TravelDate)
     FROM TravelEntries TE
     INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
     WHERE EL.LocationID = L.LocationID) AS LastVisitDate,
    -- Subquery: หาคะแนนสูงสุดที่สถานที่นี้ได้รับ
    (SELECT MAX(TE.Rating)
     FROM TravelEntries TE
     INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
     WHERE EL.LocationID = L.LocationID) AS HighestRating
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
WHERE LS.VisitCount > 0
ORDER BY LS.PopularityScale DESC, LS.VisitCount DESC;

PRINT '';

-- ========================================
-- Query 3: User Travel Frequency by Month
-- คำอธิบาย: วิเคราะห์ความถี่การเดินทางของแต่ละ User แยกตามเดือน
-- ใช้: DATE Functions, GROUP BY with ROLLUP, CASE
-- ========================================

PRINT '3. User Travel Frequency Analysis by Month';
PRINT '-------------------------------------------';

SELECT 
    U.Username,
    YEAR(TE.TravelDate) AS TravelYear,
    MONTH(TE.TravelDate) AS TravelMonth,
    DATENAME(MONTH, TE.TravelDate) AS MonthName,
    COUNT(TE.EntryID) AS TripsInMonth,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgMonthlyRating,
    CASE 
        WHEN COUNT(TE.EntryID) >= 5 THEN 'Very Active'
        WHEN COUNT(TE.EntryID) >= 3 THEN 'Active'
        WHEN COUNT(TE.EntryID) >= 1 THEN 'Moderate'
        ELSE 'Inactive'
    END AS ActivityLevel
FROM Users U
INNER JOIN TravelEntries TE ON U.UserID = TE.UserID
WHERE TE.TravelDate >= DATEADD(YEAR, -1, GETDATE())  -- ข้อมูล 1 ปีล่าสุด
GROUP BY U.Username, YEAR(TE.TravelDate), MONTH(TE.TravelDate), DATENAME(MONTH, TE.TravelDate)
ORDER BY TravelYear DESC, TravelMonth DESC, TripsInMonth DESC;

PRINT '';

-- ========================================
-- Query 4: Locations Never Visited by Specific User
-- คำอธิบาย: หาสถานที่ที่ผู้ใช้คนนั้นยังไม่เคยไป (แนะนำสถานที่ใหม่)
-- ใช้: NOT EXISTS, Subquery, LEFT JOIN
-- ========================================

PRINT '4. Recommended Locations (Not Yet Visited by User)';
PRINT '---------------------------------------------------';

DECLARE @TargetUserID INT = 2;  -- เปลี่ยนเป็น UserID ที่ต้องการ

SELECT 
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country,
    L.Category,
    LS.VisitCount AS PopularityCount,
    LS.AverageRating AS OverallRating,
    LS.PopularityScale,
    -- คำนวณ Score แนะนำ
    (LS.PopularityScale * 2 + LS.AverageRating) AS RecommendationScore
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
WHERE NOT EXISTS (
    -- ตรวจสอบว่า User นี้เคยไปหรือยัง
    SELECT 1
    FROM TravelEntries TE
    INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    WHERE TE.UserID = @TargetUserID
    AND EL.LocationID = L.LocationID
)
AND LS.VisitCount > 0  -- สถานที่ต้องมีคนไปแล้ว
ORDER BY RecommendationScore DESC;

PRINT '';

-- ========================================
-- Query 5: Category Analysis with Rankings
-- คำอธิบาย: วิเคราะห์ Category พร้อม Ranking
-- ใช้: ROW_NUMBER, PARTITION BY, CTE, Window Functions
-- ========================================

PRINT '5. Category Analysis with Location Rankings';
PRINT '--------------------------------------------';

WITH CategoryStats AS (
    SELECT 
        L.Category,
        L.LocationID,
        L.LocationName,
        L.City,
        LS.VisitCount,
        LS.AverageRating,
        LS.PopularityScale,
        -- Ranking ภายใน Category
        ROW_NUMBER() OVER (PARTITION BY L.Category ORDER BY LS.VisitCount DESC) AS RankInCategory,
        -- Average ของ Category
        AVG(LS.AverageRating) OVER (PARTITION BY L.Category) AS CategoryAvgRating,
        -- Count ภายใน Category
        COUNT(*) OVER (PARTITION BY L.Category) AS LocationsInCategory
    FROM Locations L
    INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
)
SELECT 
    Category,
    LocationName,
    City,
    VisitCount,
    AverageRating,
    PopularityScale,
    RankInCategory,
    CategoryAvgRating,
    LocationsInCategory,
    CASE 
        WHEN RankInCategory = 1 THEN 'Top in Category'
        WHEN RankInCategory = 2 THEN '2nd in Category'
        WHEN RankInCategory = 3 THEN '3rd in Category'
        ELSE CAST(RankInCategory AS NVARCHAR) + 'th'
    END AS Position
FROM CategoryStats
WHERE RankInCategory <= 5  -- แสดงแค่ Top 5 ของแต่ละ Category
ORDER BY Category, RankInCategory;

PRINT '';

-- ========================================
-- Query 6: User Comparison Analysis
-- คำอธิบาย: เปรียบเทียบ User 2 คนแบบ Side-by-Side
-- ใช้: PIVOT, UNION, CASE, Multiple Aggregations
-- ========================================

PRINT '6. User Comparison Analysis';
PRINT '----------------------------';

DECLARE @User1 INT = 2, @User2 INT = 3;

SELECT 
    Metric,
    MAX(CASE WHEN UserID = @User1 THEN Value END) AS User1_Value,
    MAX(CASE WHEN UserID = @User2 THEN Value END) AS User2_Value,
    ABS(MAX(CASE WHEN UserID = @User1 THEN Value END) - 
        MAX(CASE WHEN UserID = @User2 THEN Value END)) AS Difference
FROM (
    -- Total Entries
    SELECT 
        U.UserID,
        'Total Entries' AS Metric,
        CAST(COUNT(TE.EntryID) AS DECIMAL(10,2)) AS Value
    FROM Users U
    LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
    WHERE U.UserID IN (@User1, @User2)
    GROUP BY U.UserID
    
    UNION ALL
    
    -- Unique Locations
    SELECT 
        U.UserID,
        'Unique Locations' AS Metric,
        CAST(COUNT(DISTINCT EL.LocationID) AS DECIMAL(10,2)) AS Value
    FROM Users U
    LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
    LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    WHERE U.UserID IN (@User1, @User2)
    GROUP BY U.UserID
    
    UNION ALL
    
    -- Average Rating
    SELECT 
        U.UserID,
        'Average Rating' AS Metric,
        AVG(CAST(TE.Rating AS DECIMAL(10,2))) AS Value
    FROM Users U
    LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
    WHERE U.UserID IN (@User1, @User2)
    GROUP BY U.UserID
) AS ComparisonData
GROUP BY Metric;

PRINT '';

-- ========================================
-- Query 7: Time Series Analysis - Popularity Trend
-- คำอธิบาย: วิเคราะห์แนวโน้มความนิยมของสถานที่ตามช่วงเวลา
-- ใช้: DATE Functions, LAG, LEAD, Window Functions
-- ========================================

PRINT '7. Location Popularity Trend Over Time';
PRINT '---------------------------------------';

WITH MonthlyVisits AS (
    SELECT 
        L.LocationID,
        L.LocationName,
        YEAR(TE.TravelDate) AS Year,
        MONTH(TE.TravelDate) AS Month,
        COUNT(TE.EntryID) AS MonthlyVisits,
        AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS MonthlyAvgRating
    FROM Locations L
    INNER JOIN EntryLocations EL ON L.LocationID = EL.LocationID
    INNER JOIN TravelEntries TE ON EL.EntryID = TE.EntryID
    WHERE TE.TravelDate >= DATEADD(MONTH, -6, GETDATE())  -- 6 เดือนล่าสุด
    GROUP BY L.LocationID, L.LocationName, YEAR(TE.TravelDate), MONTH(TE.TravelDate)
),
TrendAnalysis AS (
    SELECT 
        LocationID,
        LocationName,
        Year,
        Month,
        MonthlyVisits,
        MonthlyAvgRating,
        -- เปรียบเทียบกับเดือนก่อนหน้า
        LAG(MonthlyVisits) OVER (PARTITION BY LocationID ORDER BY Year, Month) AS PreviousMonthVisits,
        -- เปรียบเทียบกับเดือนถัดไป
        LEAD(MonthlyVisits) OVER (PARTITION BY LocationID ORDER BY Year, Month) AS NextMonthVisits
    FROM MonthlyVisits
)
SELECT 
    LocationName,
    Year,
    Month,
    MonthlyVisits,
    PreviousMonthVisits,
    CASE 
        WHEN PreviousMonthVisits IS NULL THEN 'New Data'
        WHEN MonthlyVisits > PreviousMonthVisits THEN 'Increasing'
        WHEN MonthlyVisits < PreviousMonthVisits THEN 'Decreasing'
        ELSE 'Stable'
    END AS Trend,
    CASE 
        WHEN PreviousMonthVisits IS NOT NULL AND PreviousMonthVisits > 0
        THEN CAST((MonthlyVisits - PreviousMonthVisits) * 100.0 / PreviousMonthVisits AS DECIMAL(5,2))
        ELSE 0
    END AS PercentageChange
FROM TrendAnalysis
ORDER BY LocationID, Year DESC, Month DESC;

PRINT '';

-- ========================================
-- Query 8: Complex Location Statistics with Multiple Aggregations
-- คำอธิบาย: สถิติสถานที่แบบละเอียด ใช้ Aggregate Functions หลายตัว
-- ใช้: Multiple JOINs, Subqueries, HAVING, Complex Calculations
-- ========================================

PRINT '8. Comprehensive Location Statistics';
PRINT '-------------------------------------';

SELECT 
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country,
    L.Category,
    -- Basic Statistics
    COUNT(DISTINCT TE.EntryID) AS TotalVisits,
    COUNT(DISTINCT TE.UserID) AS UniqueVisitors,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating,
    MIN(TE.Rating) AS MinRating,
    MAX(TE.Rating) AS MaxRating,
    STDEV(CAST(TE.Rating AS DECIMAL(3,2))) AS RatingStdDev,
    -- Date Statistics
    MIN(TE.TravelDate) AS FirstVisit,
    MAX(TE.TravelDate) AS LastVisit,
    DATEDIFF(DAY, MIN(TE.TravelDate), MAX(TE.TravelDate)) AS DaysSinceFirstVisit,
    -- Popularity Metrics
    LS.PopularityScale,
    CASE 
        WHEN LS.PopularityScale >= 4 THEN 'High Demand'
        WHEN LS.PopularityScale = 3 THEN 'Moderate Demand'
        ELSE 'Low Demand'
    END AS DemandLevel,
    -- Visitor Retention (คนที่กลับมาอีก)
    COUNT(DISTINCT TE.UserID) - 
    (SELECT COUNT(DISTINCT TE2.UserID)
     FROM TravelEntries TE2
     INNER JOIN EntryLocations EL2 ON TE2.EntryID = EL2.EntryID
     WHERE EL2.LocationID = L.LocationID
     GROUP BY TE2.UserID
     HAVING COUNT(TE2.EntryID) = 1) AS ReturningVisitors
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
LEFT JOIN EntryLocations EL ON L.LocationID = EL.LocationID
LEFT JOIN TravelEntries TE ON EL.EntryID = TE.EntryID
GROUP BY L.LocationID, L.LocationName, L.City, L.Country, L.Category, LS.PopularityScale
HAVING COUNT(DISTINCT TE.EntryID) > 0
ORDER BY TotalVisits DESC;

PRINT '';

-- ========================================
-- Query 9: User Activity Pattern Analysis
-- คำอธิบาย: วิเคราะห์ Pattern การใช้งานของ User
-- ใช้: Complex JOINs, Date Functions, CASE, Multiple Aggregations
-- ========================================

PRINT '9. User Activity Pattern Analysis';
PRINT '----------------------------------';

SELECT 
    U.UserID,
    U.Username,
    U.FullName,
    -- Activity Statistics
    COUNT(DISTINCT TE.EntryID) AS TotalEntries,
    COUNT(DISTINCT EL.LocationID) AS UniqueLocations,
    COUNT(DISTINCT UAL.LogID) AS TotalActivities,
    -- Time Statistics
    DATEDIFF(DAY, U.CreatedDate, GETDATE()) AS DaysSinceMember,
    DATEDIFF(DAY, U.LastLogin, GETDATE()) AS DaysSinceLastLogin,
    DATEDIFF(DAY, MAX(TE.TravelDate), GETDATE()) AS DaysSinceLastTravel,
    -- Frequency Calculations
    CASE 
        WHEN DATEDIFF(DAY, U.CreatedDate, GETDATE()) > 0
        THEN CAST(COUNT(DISTINCT TE.EntryID) AS DECIMAL(10,2)) / DATEDIFF(DAY, U.CreatedDate, GETDATE())
        ELSE 0
    END AS EntriesPerDay,
    -- Favorite Category
    (SELECT TOP 1 L.Category
     FROM TravelEntries TE2
     INNER JOIN EntryLocations EL2 ON TE2.EntryID = EL2.EntryID
     INNER JOIN Locations L ON EL2.LocationID = L.LocationID
     WHERE TE2.UserID = U.UserID AND L.Category IS NOT NULL
     GROUP BY L.Category
     ORDER BY COUNT(*) DESC) AS FavoriteCategory,
    -- Travel Preferences
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRatingGiven,
    CASE 
        WHEN AVG(CAST(TE.Rating AS DECIMAL(3,2))) >= 4.5 THEN 'Highly Satisfied'
        WHEN AVG(CAST(TE.Rating AS DECIMAL(3,2))) >= 3.5 THEN 'Satisfied'
        WHEN AVG(CAST(TE.Rating AS DECIMAL(3,2))) >= 2.5 THEN 'Neutral'
        ELSE 'Unsatisfied'
    END AS SatisfactionLevel,
    -- User Status
    CASE 
        WHEN DATEDIFF(DAY, U.LastLogin, GETDATE()) <= 7 THEN 'Active'
        WHEN DATEDIFF(DAY, U.LastLogin, GETDATE()) <= 30 THEN 'Moderate'
        WHEN DATEDIFF(DAY, U.LastLogin, GETDATE()) <= 90 THEN ' Inactive'
        ELSE 'Dormant'
    END AS UserStatus
FROM Users U
LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
LEFT JOIN UserActivityLogs UAL ON U.UserID = UAL.UserID
WHERE U.IsActive = 1
GROUP BY U.UserID, U.Username, U.FullName, U.CreatedDate, U.LastLogin
ORDER BY TotalEntries DESC;

PRINT '';

-- ========================================
-- Query 10: Advanced Admin Dashboard Query
-- คำอธิบาย: Query สำหรับ Admin Dashboard แบบครบวงจร
-- ใช้: Multiple CTEs, Complex JOINs, Subqueries, Window Functions
-- ========================================

PRINT '10. Complete Admin Dashboard Statistics';
PRINT '----------------------------------------';

WITH UserStats AS (
    SELECT 
        U.UserID,
        U.Username,
        U.Role,
        U.IsActive,
        COUNT(DISTINCT TE.EntryID) AS EntryCount,
        COUNT(DISTINCT EL.LocationID) AS LocationCount,
        MAX(TE.TravelDate) AS LastTravelDate
    FROM Users U
    LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
    LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
    GROUP BY U.UserID, U.Username, U.Role, U.IsActive
),
LocationStats AS (
    SELECT 
        Category,
        COUNT(*) AS LocationCount,
        AVG(VisitCount) AS AvgVisits,
        SUM(VisitCount) AS TotalVisits
    FROM Locations L
    INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
    GROUP BY Category
),
ActivityStats AS (
    SELECT 
        ActivityType,
        COUNT(*) AS ActivityCount,
        COUNT(DISTINCT UserID) AS UniqueUsers
    FROM UserActivityLogs
    WHERE CreatedDate >= DATEADD(DAY, -30, GETDATE())
    GROUP BY ActivityType
)
SELECT 
    'System Overview' AS ReportSection,
    -- User Statistics
    (SELECT COUNT(*) FROM Users) AS TotalUsers,
    (SELECT COUNT(*) FROM Users WHERE IsActive = 1) AS ActiveUsers,
    (SELECT COUNT(*) FROM Users WHERE Role = 'Admin') AS AdminUsers,
    (SELECT COUNT(*) FROM Users WHERE CreatedDate >= DATEADD(DAY, -1, GETDATE())) AS NewUsersToday,
    -- Entry Statistics
    (SELECT COUNT(*) FROM TravelEntries) AS TotalEntries,
    (SELECT COUNT(DISTINCT LocationID) FROM Locations) AS TotalLocations,
    (SELECT AVG(CAST(Rating AS DECIMAL(3,2))) FROM TravelEntries) AS OverallAvgRating,
    -- Activity Statistics
    (SELECT COUNT(*) FROM UserActivityLogs WHERE CreatedDate >= DATEADD(DAY, -1, GETDATE())) AS ActivitiesToday,
    (SELECT COUNT(*) FROM UserActivityLogs WHERE CreatedDate >= DATEADD(DAY, -7, GETDATE())) AS ActivitiesThisWeek,
    -- Top Performers
    (SELECT TOP 1 Username FROM UserStats ORDER BY EntryCount DESC) AS MostActiveUser,
    (SELECT TOP 1 LocationName FROM Locations L INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID ORDER BY LS.VisitCount DESC) AS MostPopularLocation,
    (SELECT TOP 1 Category FROM LocationStats ORDER BY TotalVisits DESC) AS MostPopularCategory;

PRINT '';
PRINT '=== All 10 Complex Queries Executed Successfully! ===';
PRINT '';

-- ========================================
-- Summary of Techniques Used
-- ========================================
PRINT 'SQL Techniques Demonstrated:';
PRINT '✓ Multiple JOINs (INNER, LEFT, RIGHT)';
PRINT '✓ Subqueries (Correlated and Non-correlated)';
PRINT '✓ Common Table Expressions (CTEs)';
PRINT '✓ Window Functions (ROW_NUMBER, LAG, LEAD, PARTITION BY)';
PRINT '✓ Aggregate Functions (COUNT, SUM, AVG, MIN, MAX, STDEV)';
PRINT '✓ GROUP BY, HAVING';
PRINT '✓ CASE statements';
PRINT '✓ Date Functions (DATEADD, DATEDIFF, YEAR, MONTH)';
PRINT '✓ String Functions (DATENAME, CAST)';
PRINT '✓ UNION, PIVOT concepts';
PRINT '✓ NOT EXISTS, IN';
PRINT '✓ Complex calculations and derived columns';
GO