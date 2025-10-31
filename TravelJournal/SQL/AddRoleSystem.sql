-- ========================================
-- เพิ่ม Role System
-- ========================================

USE TravelJournalDB;
GO

-- เพิ่ม Column Role ใน Users Table
ALTER TABLE Users
ADD Role NVARCHAR(20) DEFAULT 'User';
GO

-- Update existing users เป็น User
UPDATE Users SET Role = 'User' WHERE Role IS NULL;
GO

-- สร้าง Admin User
DELETE FROM Users WHERE Username = 'admin';
GO

INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, IsActive) 
VALUES ('admin', 'admin@traveljournal.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Administrator', 'Admin', 1);
GO

-- Update Stored Procedure sp_LoginUser เพื่อส่งคืน Role
ALTER PROCEDURE sp_LoginUser
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
        SELECT UserID, Username, Email, FullName, Role FROM Users WHERE UserID = @UserID;
    END
    ELSE
    BEGIN
        SELECT NULL AS UserID;
    END
END;
GO

-- แสดงผลลัพธ์
SELECT UserID, Username, Email, FullName, Role, CreatedDate 
FROM Users;

PRINT 'Role System Added Successfully!';
PRINT '';
PRINT 'Login Credentials:';
PRINT 'Admin: username=admin, password=password123';
PRINT 'User: username=john_doe, password=password123';
GO