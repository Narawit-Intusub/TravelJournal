-- ========================================
-- สร้าง Test Users พร้อม Password ที่ใช้งานได้จริง
-- ========================================

USE TravelJournalDB;
GO

-- ลบ User เก่าถ้ามี (Optional)
DELETE FROM Users WHERE Username IN ('john_doe', 'jane_smith', 'admin');
GO

-- Password Hash สำหรับ "password123" (SHA256)
-- Hash = ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f

INSERT INTO Users (Username, Email, PasswordHash, FullName, IsActive) 
VALUES 
('john_doe', 'john@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'John Doe', 1),
('jane_smith', 'jane@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Jane Smith', 1),
('admin', 'admin@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Administrator', 1);

-- แสดงผลลัพธ์
SELECT UserID, Username, Email, FullName, CreatedDate 
FROM Users 
WHERE Username IN ('john_doe', 'jane_smith', 'admin');

PRINT 'Test Users Created Successfully!';
PRINT '';
PRINT 'Login Credentials:';
PRINT '   Username: john_doe   | Password: password123';
PRINT '   Username: jane_smith | Password: password123';
PRINT '   Username: admin      | Password: password123';
GO