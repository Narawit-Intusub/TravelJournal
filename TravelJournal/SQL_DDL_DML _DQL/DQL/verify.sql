-- ========================================
-- DQL (Data Query Language)
-- SELECT Queries for Data Retrieval
-- ========================================

USE TravelJournalDB;
GO

PRINT '========================================';
PRINT 'DQL - Data Query Examples';
PRINT '========================================';
PRINT '';

-- ========================================
-- 1. BASIC QUERIES
-- ========================================

PRINT '1. Get All Users';
SELECT * FROM Users;
PRINT '';

PRINT '2. Get All Locations';
SELECT * FROM Locations;
PRINT '';

PRINT '3. Get All Travel Entries';
SELECT * FROM TravelEntries;
PRINT '';

-- ========================================
-- 2. JOIN QUERIES
-- ========================================

PRINT '4. Get Travel Entries with User Info';
SELECT 
    TE.EntryID,
    U.Username,
    U.FullName,
    TE.Title,
    TE.TravelDate,
    TE.Rating
FROM TravelEntries TE
INNER JOIN Users U ON TE.UserID = U.UserID
ORDER BY TE.TravelDate DESC;
PRINT '';

PRINT '5. Get Travel Entries with Locations';
SELECT 
    TE.EntryID,
    U.FullName AS UserName,
    TE.Title,
    L.LocationName,
    L.City,
    L.Country,
    TE.TravelDate,
    TE.Rating
FROM TravelEntries TE
INNER JOIN Users U ON TE.UserID = U.UserID
INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
INNER JOIN Locations L ON EL.LocationID = L.LocationID
ORDER BY TE.TravelDate DESC;
PRINT '';

-- ========================================
-- 3. AGGREGATE QUERIES
-- ========================================

PRINT '6. Count Entries per User';
SELECT 
    U.Username,
    U.FullName,
    COUNT(TE.EntryID) AS TotalEntries
FROM Users U
LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
GROUP BY U.Username, U.FullName
ORDER BY TotalEntries DESC;
PRINT '';

PRINT '7. Most Popular Locations';
SELECT 
    L.LocationName,
    L.City,
    LS.VisitCount,
    LS.AverageRating,
    LS.PopularityScale
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
ORDER BY LS.VisitCount DESC, LS.AverageRating DESC;
PRINT '';

PRINT '8. Average Rating per Category';
SELECT 
    L.Category,
    COUNT(DISTINCT L.LocationID) AS LocationCount,
    AVG(LS.AverageRating) AS CategoryAvgRating
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
WHERE LS.AverageRating > 0
GROUP BY L.Category
ORDER BY CategoryAvgRating DESC;
PRINT '';

-- ========================================
-- 4. SUBQUERY EXAMPLES
-- ========================================

PRINT '9. Users with Most Entries';
SELECT 
    U.Username,
    U.FullName,
    (SELECT COUNT(*) FROM TravelEntries WHERE UserID = U.UserID) AS EntryCount
FROM Users U
WHERE U.Role = 'User'
ORDER BY EntryCount DESC;
PRINT '';

PRINT '10. Locations Never Visited';
SELECT 
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country
FROM Locations L
WHERE NOT EXISTS (
    SELECT 1 FROM EntryLocations EL 
    WHERE EL.LocationID = L.LocationID
);
PRINT '';

-- ========================================
-- 5. DATE QUERIES
-- ========================================

PRINT '11. Entries This Month';
SELECT 
    TE.Title,
    U.FullName,
    L.LocationName,
    TE.TravelDate
FROM TravelEntries TE
INNER JOIN Users U ON TE.UserID = U.UserID
INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
INNER JOIN Locations L ON EL.LocationID = L.LocationID
WHERE MONTH(TE.TravelDate) = MONTH(GETDATE())
  AND YEAR(TE.TravelDate) = YEAR(GETDATE())
ORDER BY TE.TravelDate DESC;
PRINT '';

PRINT '12. Entries in Last 30 Days';
SELECT 
    TE.Title,
    U.FullName,
    TE.TravelDate,
    DATEDIFF(DAY, TE.TravelDate, GETDATE()) AS DaysAgo
FROM TravelEntries TE
INNER JOIN Users U ON TE.UserID = U.UserID
WHERE TE.TravelDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY TE.TravelDate DESC;
PRINT '';

-- ========================================
-- 6. RATING QUERIES
-- ========================================

PRINT '13. High-Rated Locations (4+ stars)';
SELECT 
    L.LocationName,
    L.City,
    LS.AverageRating,
    LS.VisitCount
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
WHERE LS.AverageRating >= 4.0
ORDER BY LS.AverageRating DESC, LS.VisitCount DESC;
PRINT '';

PRINT '14. Entries with 5-Star Rating';
SELECT 
    TE.Title,
    U.FullName,
    L.LocationName,
    TE.Rating,
    TE.TravelDate
FROM TravelEntries TE
INNER JOIN Users U ON TE.UserID = U.UserID
INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
INNER JOIN Locations L ON EL.LocationID = L.LocationID
WHERE TE.Rating = 5
ORDER BY TE.TravelDate DESC;
PRINT '';

-- ========================================
-- 7. ACTIVITY LOG QUERIES
-- ========================================

PRINT '15. Recent User Activities';
SELECT TOP 20
    U.Username,
    UAL.ActivityType,
    UAL.ActivityDescription,
    UAL.CreatedDate
FROM UserActivityLogs UAL
INNER JOIN Users U ON UAL.UserID = U.UserID
ORDER BY UAL.CreatedDate DESC;
PRINT '';

PRINT '16. Login Activities';
SELECT 
    U.Username,
    UAL.ActivityType,
    UAL.IPAddress,
    UAL.CreatedDate
FROM UserActivityLogs UAL
INNER JOIN Users U ON UAL.UserID = U.UserID
WHERE UAL.ActivityType = 'Login'
ORDER BY UAL.CreatedDate DESC;
PRINT '';

-- ========================================
-- 8. STATISTICAL QUERIES
-- ========================================

PRINT '17. Overall Statistics';
SELECT 
    (SELECT COUNT(*) FROM Users WHERE Role = 'User') AS TotalUsers,
    (SELECT COUNT(*) FROM Users WHERE IsActive = 1) AS ActiveUsers,
    (SELECT COUNT(*) FROM TravelEntries) AS TotalEntries,
    (SELECT COUNT(*) FROM Locations) AS TotalLocations,
    (SELECT AVG(CAST(Rating AS DECIMAL(3,2))) FROM TravelEntries) AS OverallAvgRating;
PRINT '';

PRINT '18. User Statistics Summary';
SELECT 
    U.UserID,
    U.Username,
    U.FullName,
    COUNT(DISTINCT TE.EntryID) AS TotalEntries,
    COUNT(DISTINCT EL.LocationID) AS UniqueLocations,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating,
    MIN(TE.TravelDate) AS FirstTrip,
    MAX(TE.TravelDate) AS LastTrip
FROM Users U
LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
LEFT JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
WHERE U.Role = 'User'
GROUP BY U.UserID, U.Username, U.FullName;
PRINT '';

-- ========================================
-- 9. VIEW QUERIES
-- ========================================

PRINT '19. Query Popular Locations View';
SELECT * FROM vw_PopularLocations
ORDER BY PopularityScale DESC, VisitCount DESC;
PRINT '';

PRINT '20. Query User Unique Locations View';
SELECT * FROM vw_UserUniqueLocations
ORDER BY VisitCount DESC;
PRINT '';

PRINT '21. Query User Stats Summary View';
SELECT * FROM vw_UserStatsSummary
WHERE Role = 'User'
ORDER BY TotalEntries DESC;
PRINT '';

-- ========================================
-- 10. COMPLEX QUERIES
-- ========================================

PRINT '22. Top 5 Most Visited Cities';
SELECT TOP 5
    L.City,
    L.Country,
    COUNT(DISTINCT EL.EntryID) AS TotalVisits,
    COUNT(DISTINCT L.LocationID) AS UniqueLocations,
    AVG(LS.AverageRating) AS AvgCityRating
FROM Locations L
INNER JOIN EntryLocations EL ON L.LocationID = EL.LocationID
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
WHERE L.City IS NOT NULL
GROUP BY L.City, L.Country
ORDER BY TotalVisits DESC;
PRINT '';

PRINT '23. User Travel Timeline';
SELECT 
    U.FullName,
    L.LocationName,
    L.City,
    TE.Title,
    TE.TravelDate,
    TE.Rating,
    ROW_NUMBER() OVER (PARTITION BY U.UserID ORDER BY TE.TravelDate) AS TripNumber
FROM Users U
INNER JOIN TravelEntries TE ON U.UserID = TE.UserID
INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
INNER JOIN Locations L ON EL.LocationID = L.LocationID
ORDER BY U.FullName, TE.TravelDate;
PRINT '';

PRINT '24. Locations by Popularity Scale';
SELECT 
    LS.PopularityScale,
    CASE LS.PopularityScale
        WHEN 5 THEN 'Very Popular'
        WHEN 4 THEN 'Popular'
        WHEN 3 THEN 'Moderate'
        WHEN 2 THEN 'Low'
        ELSE 'Very Low'
    END AS PopularityLevel,
    COUNT(L.LocationID) AS LocationCount,
    STRING_AGG(L.LocationName, ', ') AS Locations
FROM Locations L
INNER JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
GROUP BY LS.PopularityScale
ORDER BY LS.PopularityScale DESC;
PRINT '';

PRINT '25. Monthly Travel Statistics';
SELECT 
    YEAR(TE.TravelDate) AS Year,
    MONTH(TE.TravelDate) AS Month,
    DATENAME(MONTH, TE.TravelDate) AS MonthName,
    COUNT(TE.EntryID) AS TotalTrips,
    COUNT(DISTINCT TE.UserID) AS UniqueUsers,
    AVG(CAST(TE.Rating AS DECIMAL(3,2))) AS AvgRating
FROM TravelEntries TE
GROUP BY YEAR(TE.TravelDate), MONTH(TE.TravelDate), DATENAME(MONTH, TE.TravelDate)
ORDER BY Year DESC, Month DESC;
PRINT '';

-- ========================================
-- 11. SEARCH QUERIES
-- ========================================

PRINT '26. Search Locations by Name (Example: วัด)';
SELECT 
    L.LocationID,
    L.LocationName,
    L.City,
    L.Country,
    L.Category,
    LS.VisitCount,
    LS.AverageRating
FROM Locations L
LEFT JOIN LocationStatistics LS ON L.LocationID = LS.LocationID
WHERE L.LocationName LIKE '%วัด%'
ORDER BY LS.VisitCount DESC;
PRINT '';

PRINT '27. Search Entries by Description';
SELECT 
    TE.Title,
    TE.Description,
    U.FullName,
    TE.TravelDate
FROM TravelEntries TE
INNER JOIN Users U ON TE.UserID = U.UserID
WHERE TE.Description LIKE '%สวย%'
ORDER BY TE.TravelDate DESC;
PRINT '';

-- ========================================
-- 12. ADMIN QUERIES
-- ========================================

PRINT '28. Users Who Haven''t Logged In Recently';
SELECT 
    U.Username,
    U.FullName,
    U.Email,
    U.LastLogin,
    DATEDIFF(DAY, U.LastLogin, GETDATE()) AS DaysSinceLastLogin
FROM Users U
WHERE U.LastLogin IS NOT NULL 
  AND U.LastLogin < DATEADD(DAY, -30, GETDATE())
ORDER BY U.LastLogin;
PRINT '';

PRINT '29. Activity Summary by Type';
SELECT 
    ActivityType,
    COUNT(*) AS Count,
    MIN(CreatedDate) AS FirstOccurrence,
    MAX(CreatedDate) AS LastOccurrence
FROM UserActivityLogs
GROUP BY ActivityType
ORDER BY Count DESC;
PRINT '';

PRINT '30. User Engagement Metrics';
SELECT 
    U.Username,
    U.FullName,
    COUNT(DISTINCT TE.EntryID) AS EntriesCreated,
    COUNT(DISTINCT UAL.LogID) AS TotalActivities,
    dbo.fn_GetActivityCountByDateRange(U.UserID, 7) AS ActivitiesLast7Days,
    dbo.fn_GetActivityCountByDateRange(U.UserID, 30) AS ActivitiesLast30Days
FROM Users U
LEFT JOIN TravelEntries TE ON U.UserID = TE.UserID
LEFT JOIN UserActivityLogs UAL ON U.UserID = UAL.UserID
WHERE U.Role = 'User'
GROUP BY U.UserID, U.Username, U.FullName
ORDER BY TotalActivities DESC;
PRINT '';

-- ========================================
-- End of DQL Queries
-- ========================================

PRINT '';
PRINT '✅ DQL Queries Completed - 30 Example Queries Executed!';
PRINT '';
PRINT '📊 Query Categories:';
PRINT '   1-3:   Basic SELECT queries';
PRINT '   4-5:   JOIN queries';
PRINT '   6-8:   Aggregate queries';
PRINT '   9-10:  Subqueries';
PRINT '   11-12: Date queries';
PRINT '   13-14: Rating queries';
PRINT '   15-16: Activity log queries';
PRINT '   17-18: Statistical queries';
PRINT '   19-21: VIEW queries';
PRINT '   22-25: Complex queries';
PRINT '   26-27: Search queries';
PRINT '   28-30: Admin queries';
GO