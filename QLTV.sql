-- Tạo cơ sở dữ liệu
CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

-- Tạo bảng Books
CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(255) NOT NULL,
    Author NVARCHAR(255) NOT NULL,
    Genre NVARCHAR(100),
    PublishedYear INT,
    TotalQuantity INT NOT NULL
);
GO

-- Tạo bảng Readers (Độc giả)
CREATE TABLE Readers (
    ReaderID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(MAX),
    RegistrationDate DATE,
    ExpiryDate DATE
);
GO

-- Tạo bảng Staff (Nhân viên)
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(MAX),
    WorkingTime NVARCHAR(50)
);
GO

-- Tạo bảng Borrowings (Mượn sách)
CREATE TABLE Borrowings (
    BorrowID INT PRIMARY KEY IDENTITY(1,1),
    ReaderID INT,
    BookID INT,
    BorrowDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,

    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);
GO

-- Tạo thủ tục thêm sách vào thư viện
CREATE PROCEDURE AddBook
    @Title NVARCHAR(255),
    @Author NVARCHAR(255),
    @Genre NVARCHAR(100),
    @PublishedYear INT,
    @TotalQuantity INT
AS
BEGIN
    INSERT INTO Books (Title, Author, Genre, PublishedYear, TotalQuantity)
    VALUES (@Title, @Author, @Genre, @PublishedYear, @TotalQuantity);
END;
GO

-- Tạo thủ tục mượn sách
CREATE PROCEDURE BorrowBook
    @ReaderID INT,
    @BookID INT
AS
BEGIN
    DECLARE @Quantity INT;
    SELECT @Quantity = TotalQuantity FROM Books WHERE BookID = @BookID;
    
    IF @Quantity > 0
    BEGIN
        INSERT INTO Borrowings (ReaderID, BookID, BorrowDate, DueDate)
        VALUES (@ReaderID, @BookID, GETDATE(), DATEADD(DAY, 14, GETDATE()));
        
        UPDATE Books SET TotalQuantity = TotalQuantity - 1 WHERE BookID = @BookID;
    END
    ELSE
    BEGIN
        PRINT 'Sách không còn trong thư viện';
    END
END;
GO

-- Tạo thủ tục trả sách
CREATE PROCEDURE ReturnBook
    @ReaderID INT,
    @BookID INT
AS
BEGIN
    UPDATE Borrowings
    SET ReturnDate = GETDATE()
    WHERE ReaderID = @ReaderID AND BookID = @BookID AND ReturnDate IS NULL;
    
    UPDATE Books
    SET TotalQuantity = TotalQuantity + 1
    WHERE BookID = @BookID;
END;
GO

-- Tạo view tất cả sách
CREATE VIEW AllBooks AS
SELECT 
    BookID,
    Title,
    Author,
    Genre,
    PublishedYear,
    TotalQuantity
FROM Books;
GO

-- Tạo view tất cả nhân viên
CREATE VIEW AllStaff AS
SELECT 
    StaffID,
    FullName,
    PhoneNumber,
    Address,
    WorkingTime
FROM Staff;
GO

-- Tạo view tất cả độc giả
CREATE VIEW AllReaders AS
SELECT 
    ReaderID,
    FullName,
    PhoneNumber,
    Address,
    RegistrationDate,
    ExpiryDate
FROM Readers;
GO

-- Tạo view sách đang được mượn
CREATE VIEW BooksCurrentlyBorrowed AS
SELECT 
    r.FullName AS ReaderName,
    b.Title AS BookTitle,
    br.BorrowDate AS BorrowDate,
    br.ReturnDate AS ReturnDate
FROM Borrowings br
JOIN Books b ON br.BookID = b.BookID
JOIN Readers r ON br.ReaderID = r.ReaderID
WHERE br.ReturnDate IS NULL;
GO

-- Tạo view lịch sử mượn sách
CREATE VIEW BorrowingHistory AS
SELECT 
    r.FullName AS ReaderName,
    b.Title AS BookTitle,
    br.BorrowDate AS BorrowDate,
    br.ReturnDate AS ReturnDate
FROM Borrowings br
JOIN Books b ON br.BookID = b.BookID
JOIN Readers r ON br.ReaderID = r.ReaderID;
GO

-- Tạo view sách mượn phổ biến
CREATE VIEW MostPopularBooks AS
SELECT 
    b.Title AS BookTitle,
    COUNT(br.BookID) AS BorrowCount
FROM Borrowings br
JOIN Books b ON br.BookID = b.BookID
GROUP BY b.Title
ORDER BY BorrowCount DESC;
GO

-- Tạo view độc giả mượn sách nhiều nhất
CREATE VIEW MostActiveReaders AS
SELECT 
    r.FullName AS ReaderName,
    COUNT(br.BookID) AS BorrowCount
FROM Borrowings br
JOIN Readers r ON br.ReaderID = r.ReaderID
GROUP BY r.FullName
ORDER BY BorrowCount DESC;
GO

-- Dữ liệu mẫu cho bảng Books
INSERT INTO Books (Title, Author, Genre, PublishedYear, TotalQuantity)
VALUES 
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 'Fantasy', 1997, 5),
('The Lord of the Rings', 'J.R.R. Tolkien', 'Fantasy', 1954, 3),
('1984', 'George Orwell', 'Dystopian', 1949, 7),
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 6),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 1925, 4),
('Moby-Dick', 'Herman Melville', 'Adventure', 1851, 2),
('Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 8),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 5),
('Brave New World', 'Aldous Huxley', 'Dystopian', 1932, 6),
('The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 4),
('Fahrenheit 451', 'Ray Bradbury', 'Dystopian', 1953, 5),
('Crime and Punishment', 'Fyodor Dostoevsky', 'Classic', 1866, 3),
('Wuthering Heights', 'Emily Brontë', 'Romance', 1847, 6),
('The Picture of Dorian Gray', 'Oscar Wilde', 'Classic', 1890, 5),
('Don Quixote', 'Miguel de Cervantes', 'Adventure', 1605, 7),
('The Count of Monte Cristo', 'Alexandre Dumas', 'Adventure', 1844, 8),
('Les Misérables', 'Victor Hugo', 'Historical', 1862, 5),
('Dracula', 'Bram Stoker', 'Horror', 1897, 6),
('Frankenstein', 'Mary Shelley', 'Horror', 1818, 4),
('The Brothers Karamazov', 'Fyodor Dostoevsky', 'Classic', 1880, 3);
GO

-- Dữ liệu mẫu cho bảng Readers
INSERT INTO Readers (FullName, PhoneNumber, Address, RegistrationDate, ExpiryDate)
VALUES 
('Le Thi C', '0987654321', '789 Last St', '2025-01-01', '2026-01-01'),
('Pham Minh D', '0976543210', '101 New St', '2025-02-01', '2026-02-01'),
('Nguyen Thi E', '0931234567', '102 Another St', '2025-03-01', '2026-03-01'),
('Tran Van F', '0923456789', '103 Old St', '2025-04-01', '2026-04-01'),
('Hoang Minh G', '0912345678', '104 Green St', '2025-05-01', '2026-05-01'),
('Bui Thi H', '0901234567', '105 Blue St', '2025-06-01', '2026-06-01'),
('Vu Van I', '0897654321', '106 Yellow St', '2025-07-01', '2026-07-01'),
('Ngo Thi J', '0886543210', '107 Red St', '2025-08-01', '2026-08-01'),
('Phan Van K', '0875432109', '108 White St', '2025-09-01', '2026-09-01'),
('Do Minh L', '0864321098', '109 Black St', '2025-10-01', '2026-10-01'),
('Trinh Van M', '0853210987', '110 Silver St', '2025-11-01', '2026-11-01'),
('Huynh Thi N', '0842109876', '111 Gold St', '2025-12-01', '2026-12-01'),
('Pham Van O', '0831098765', '112 Bronze St', '2026-01-01', '2027-01-01'),
('Le Thi P', '0820987654', '113 Copper St', '2026-02-01', '2027-02-01'),
('Nguyen Van Q', '0819876543', '114 Iron St', '2026-03-01', '2027-03-01'),
('Tran Thi R', '0808765432', '115 Steel St', '2026-04-01', '2027-04-01'),
('Do Van S', '0797654321', '116 Platinum St', '2026-05-01', '2027-05-01'),
('Hoang Thi T', '0786543210', '117 Diamond St', '2026-06-01', '2027-06-01'),
('Bui Van U', '0775432109', '118 Emerald St', '2026-07-01', '2027-07-01');
GO

-- Dữ liệu mẫu cho bảng Borrowings
INSERT INTO Borrowings (ReaderID, BookID, BorrowDate, DueDate)
VALUES 
(1, 1, '2025-03-01', '2025-03-15'),
(2, 2, '2025-03-02', '2025-03-16'),
(3, 3, '2025-03-03', '2025-03-17'),
(4, 4, '2025-03-04', '2025-03-18'),
(5, 5, '2025-03-05', '2025-03-19'),
(6, 6, '2025-03-06', '2025-03-20'),
(7, 7, '2025-03-07', '2025-03-21'),
(8, 8, '2025-03-08', '2025-03-22'),
(9, 9, '2025-03-09', '2025-03-23'),
(10, 10, '2025-03-10', '2025-03-24'),
(11, 11, '2025-03-11', '2025-03-25'),
(12, 12, '2025-03-12', '2025-03-26'),
(13, 13, '2025-03-13', '2025-03-27'),
(14, 14, '2025-03-14', '2025-03-28'),
(15, 15, '2025-03-15', '2025-03-29'),
(16, 16, '2025-03-16', '2025-03-30'),
(17, 17, '2025-03-17', '2025-03-31'),
(18, 18, '2025-03-18', '2025-04-01'),
(19, 19, '2025-03-19', '2025-04-02'),
(20, 20, '2025-03-20', '2025-04-03');
GO

-- Dữ liệu mẫu bảng Staff
INSERT INTO Staff (FullName, PhoneNumber, Address, WorkingTime)
VALUES 
('Nguyen Van A', '0901234567', '123 Main St', '7 AM - 12 AM'),
('Tran Thi B', '0912345678', '456 Another St', '7 AM - 12 AM'),
('Le Minh C', '0923456789', '789 Last St', '1 PM - 6 PM'),
('Pham Van D', '0934567890', '101 New St', '1 PM - 6 PM'),
('Bui Thi E', '0945678901', '202 City St', '7 PM - 11 PM'),
('Hoang Van F', '0956789012', '303 Town St', '7 PM - 11 PM');
GO

-- Truy vấn các view

-- Xem tất cả sách
SELECT * FROM AllBooks;

-- Xem tất cả nhân viên
SELECT * FROM AllStaff;

-- Xem tất cả độc giả
SELECT * FROM AllReaders;

-- Xem sách đang mượn
SELECT * FROM BooksCurrentlyBorrowed;

-- Xem lịch sử mượn sách
SELECT * FROM BorrowingHistory;

-- Xem sách mượn phổ biến
SELECT * FROM MostPopularBooks;

-- Xem độc giả mượn sách nhiều nhất
SELECT * FROM MostActiveReaders;
GO

CREATE TRIGGER trg_AfterBorrow
ON Borrowings
AFTER INSERT
AS
BEGIN
    DECLARE @BookID INT;
    DECLARE @TotalQuantity INT;
    
    SELECT @BookID = BookID FROM INSERTED;
    SELECT @TotalQuantity = TotalQuantity FROM Books WHERE BookID = @BookID;
    
    IF @TotalQuantity > 0
    BEGIN
        UPDATE Books
        SET TotalQuantity = TotalQuantity - 1
        WHERE BookID = @BookID;
    END
    ELSE
    BEGIN
        PRINT 'Sách không còn trong thư viện';
    END
END;
GO

CREATE TRIGGER trg_AfterReturn
ON Borrowings
AFTER UPDATE
AS
BEGIN
    DECLARE @BookID INT;
    DECLARE @ReturnDate DATE;
    
    SELECT @BookID = BookID, @ReturnDate = ReturnDate FROM INSERTED;
    
    IF @ReturnDate IS NOT NULL
    BEGIN
        UPDATE Books
        SET TotalQuantity = TotalQuantity + 1
        WHERE BookID = @BookID;
    END
END;
GO

CREATE TRIGGER trg_AfterDeleteReader
ON Readers
AFTER DELETE
AS
BEGIN
    DECLARE @ReaderID INT;
    
    SELECT @ReaderID = ReaderID FROM DELETED;
    
    DELETE FROM Borrowings WHERE ReaderID = @ReaderID;
END;
GO

CREATE TRIGGER trg_AfterDeleteBook
ON Books
AFTER DELETE
AS
BEGIN
    DECLARE @BookID INT;
    
    SELECT @BookID = BookID FROM DELETED;
    
    DELETE FROM Borrowings WHERE BookID = @BookID;
END;
GO

CREATE TRIGGER trg_AfterUpdateBook
ON Books
AFTER UPDATE
AS
BEGIN
    -- Đây có thể là nơi bạn muốn cập nhật lại các báo cáo thống kê khác
    PRINT 'Cập nhật thông tin sách thành công';
END;
GO

CREATE TRIGGER trg_BeforeBorrow
ON Borrowings
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BookID INT;
    DECLARE @ReaderID INT;
    DECLARE @Quantity INT;
    
    SELECT @ReaderID = ReaderID, @BookID = BookID FROM INSERTED;
    SELECT @Quantity = TotalQuantity FROM Books WHERE BookID = @BookID;
    
    IF @Quantity > 0
    BEGIN
        INSERT INTO Borrowings (ReaderID, BookID, BorrowDate, DueDate)
        SELECT ReaderID, BookID, GETDATE(), DATEADD(DAY, 14, GETDATE()) FROM INSERTED;
        
        UPDATE Books
        SET TotalQuantity = TotalQuantity - 1
        WHERE BookID = @BookID;
    END
    ELSE
    BEGIN
        PRINT 'Không đủ sách để mượn';
    END
END;
GO

-- Trigger sau khi trả sách muộn
CREATE TRIGGER trg_AfterReturnLate
ON Borrowings
AFTER UPDATE
AS
BEGIN
    DECLARE @ReaderID INT, @BookID INT, @DueDate DATE, @ReturnDate DATE, @LateDays INT, @LateFee DECIMAL(10, 2);

    -- Lấy thông tin từ bảng Borrowings
    SELECT @ReaderID = ReaderID, @BookID = BookID, @DueDate = DueDate, @ReturnDate = ReturnDate
    FROM inserted;

    -- Kiểm tra xem sách có được trả muộn không
    IF @ReturnDate > @DueDate
    BEGIN
        -- Tính số ngày trả muộn
        SET @LateDays = DATEDIFF(DAY, @DueDate, @ReturnDate);

        -- Giả sử mức phí trễ là 100 VND mỗi ngày
        SET @LateFee = @LateDays * 100;

        -- Cập nhật bảng Borrowings với phí trễ
        UPDATE Borrowings
        SET LateFee = @LateFee
        WHERE ReaderID = @ReaderID AND BookID = @BookID;
        
        -- In thông báo về phí trễ
        PRINT 'Phí trễ: ' + CAST(@LateFee AS NVARCHAR(20)) + ' VND';
    END
END;
GO

CREATE TRIGGER trg_AfterInsertStaff
ON Staff
AFTER INSERT
AS
BEGIN
    PRINT 'Thêm nhân viên mới thành công';
END;
GO

CREATE TRIGGER trg_AfterInsertReader
ON Readers
AFTER INSERT
AS
BEGIN
    PRINT 'Độc giả mới đã được đăng ký thành công';
END;
GO

CREATE TRIGGER trg_AfterUpdateBookQuantity
ON Books
AFTER UPDATE
AS
BEGIN
    DECLARE @TotalQuantity INT;
    
    SELECT @TotalQuantity = TotalQuantity FROM INSERTED;
    
    IF @TotalQuantity < 0
    BEGIN
        PRINT 'Số lượng sách không thể nhỏ hơn 0';
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE LOGIN StaffLogin WITH PASSWORD = 'Staff123#';
CREATE LOGIN ReaderLogin WITH PASSWORD = 'Reader123@';
CREATE LOGIN AdminLogin WITH PASSWORD = 'Admin123!';
GO

-- Tạo người dùng
CREATE USER StaffUser FOR LOGIN StaffLogin;
CREATE USER ReaderUser FOR LOGIN ReaderLogin;
CREATE USER AdminUser FOR LOGIN AdminLogin;
GO

-- Phân quyền cho nhân viên
GRANT SELECT ON AllBooks TO StaffUser;
GRANT EXECUTE ON BorrowBook TO StaffUser;
GRANT EXECUTE ON ReturnBook TO StaffUser;

-- Phân quyền cho độc giả
GRANT EXECUTE ON BorrowBook TO ReaderUser;
GRANT EXECUTE ON ReturnBook TO ReaderUser;
GRANT SELECT ON BooksCurrentlyBorrowed TO ReaderUser;

-- Phân quyền cho quản lý
GRANT SELECT, INSERT, UPDATE, DELETE ON Books TO AdminUser;
GRANT EXECUTE ON AddBook TO AdminUser;
GRANT EXECUTE ON BorrowBook TO AdminUser;
GRANT EXECUTE ON ReturnBook TO AdminUser;
GRANT SELECT ON MostPopularBooks TO AdminUser;
GO

BACKUP DATABASE LibraryDB
TO DISK = 'C:\Downloads\LibraryDB_Backup.bak';
GO
