-- 1. Tạo Cơ Sở Dữ Liệu
IF DB_ID('HIS_DB') IS NULL
BEGIN
    CREATE DATABASE HIS_DB;
END
GO

USE HIS_DB;
GO

-- 2. Bảng Danh Mục Bác Sĩ (Doctors)
IF OBJECT_ID('Doctors', 'U') IS NULL
BEGIN
    CREATE TABLE Doctors (
        DoctorID INT IDENTITY(1,1) PRIMARY KEY,
        DoctorName NVARCHAR(100) NOT NULL,
        Specialty NVARCHAR(100) NOT NULL,
        RoomNo NVARCHAR(20) NOT NULL
    );
END
GO

-- 3. Bảng Hồ Sơ Bệnh Nhân (Patients)
IF OBJECT_ID('Patients', 'U') IS NULL
BEGIN
    CREATE TABLE Patients (
        PatientID VARCHAR(20) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        DOB DATE NOT NULL,
        Gender NVARCHAR(10) NOT NULL,
        InsuranceCard VARCHAR(20) NULL,
        Address NVARCHAR(250) NULL,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- 4. Bảng Lượt Đăng Ký Khám (Visits)
IF OBJECT_ID('Visits', 'U') IS NULL
BEGIN
    CREATE TABLE Visits (
        VisitID INT IDENTITY(1,1) PRIMARY KEY,
        PatientID VARCHAR(20) NOT NULL,
        DoctorID INT NOT NULL REFERENCES Doctors(DoctorID),
        Status NVARCHAR(50) DEFAULT N'Chờ khám',
        VisitDate DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Visits_Patients FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
    );
END
GO

-- 5. Bảng Danh Mục Thuốc (Medications)
IF OBJECT_ID('Medications', 'U') IS NULL
BEGIN
    CREATE TABLE Medications (
        MedicationID INT IDENTITY(1,1) PRIMARY KEY,
        MedicationName NVARCHAR(100) NOT NULL,
        Unit NVARCHAR(20) NOT NULL,
        Price DECIMAL(18,2) NOT NULL,
        StockQuantity INT DEFAULT 1000
    );
END
GO

-- 6. Bảng Kết Quả Khám Bệnh (Examinations)
IF OBJECT_ID('Examinations', 'U') IS NULL
BEGIN
    CREATE TABLE Examinations (
        ExamID INT IDENTITY(1,1) PRIMARY KEY,
        VisitID INT NOT NULL UNIQUE REFERENCES Visits(VisitID),
        Symptoms NVARCHAR(500) NULL,
        Diagnosis NVARCHAR(500) NOT NULL,
        Notes NVARCHAR(500) NULL,
        ExamDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- 7. Bảng Đơn Thuốc (Prescriptions)
IF OBJECT_ID('Prescriptions', 'U') IS NULL
BEGIN
    CREATE TABLE Prescriptions (
        PrescriptionID INT IDENTITY(1,1) PRIMARY KEY,
        ExamID INT NOT NULL UNIQUE REFERENCES Examinations(ExamID),
        DoctorID INT NOT NULL REFERENCES Doctors(DoctorID),
        CreatedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- 8. Chi Tiết Đơn Thuốc (PrescriptionDetails)
IF OBJECT_ID('PrescriptionDetails', 'U') IS NULL
BEGIN
    CREATE TABLE PrescriptionDetails (
        DetailID INT IDENTITY(1,1) PRIMARY KEY,
        PrescriptionID INT NOT NULL REFERENCES Prescriptions(PrescriptionID) ON DELETE CASCADE,
        MedicationID INT NOT NULL REFERENCES Medications(MedicationID),
        Quantity INT NOT NULL CHECK (Quantity > 0),
        UsageInstructions NVARCHAR(250) NOT NULL
    );
END
GO

-- Chèn danh mục Bác sĩ (chỉ chèn nếu chưa có dữ liệu)
IF NOT EXISTS (SELECT 1 FROM Doctors)
BEGIN
    INSERT INTO Doctors (DoctorName, Specialty, RoomNo) VALUES
    (N'BS. Nguyễn Văn A', N'Khoa Nội Tổng Hợp', N'Phòng 101'),
    (N'BS. Trần Thị B', N'Khoa Nhi', N'Phòng 102'),
    (N'BS. Lê Hoàng C', N'Khoa Tim Mạch', N'Phòng 103'),
    (N'BS. Phạm Minh D', N'Khoa Tai Mũi Họng', N'Phòng 104');
END
GO

-- Chèn danh mục Thuốc mẫu (chỉ chèn nếu chưa có dữ liệu)
IF NOT EXISTS (SELECT 1 FROM Medications)
BEGIN
    INSERT INTO Medications (MedicationName, Unit, Price, StockQuantity) VALUES
    (N'Paracetamol 500mg', N'Viên', 1500.00, 5000),
    (N'Amoxicillin 500mg', N'Viên', 3000.00, 3000),
    (N'Decolgen Forte', N'Viên', 2000.00, 2000),
    (N'Panadol Extra', N'Viên', 2500.00, 4000),
    (N'Cough Syrup (Siro Ho)', N'Chai', 25000.00, 150),
    (N'Vitamin C 500mg', N'Viên', 800.00, 10000);
END
GO

-- 1. SP Tiếp Đón & Đăng Ký Khám Bệnh
CREATE OR ALTER PROCEDURE sp_RegisterPatient
    @FullName NVARCHAR(100),
    @DOB DATE,
    @Gender NVARCHAR(10),
    @InsuranceCard VARCHAR(20) = NULL,
    @Address NVARCHAR(250) = NULL,
    @DoctorID INT,
    @NewPatientID VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ExistingPatientID VARCHAR(20) = NULL;
    
    IF @InsuranceCard IS NOT NULL AND @InsuranceCard <> ''
    BEGIN
        SELECT TOP 1 @ExistingPatientID = PatientID 
        FROM Patients 
        WHERE InsuranceCard = @InsuranceCard;
    END
    
    IF @ExistingPatientID IS NULL
    BEGIN
        SELECT TOP 1 @ExistingPatientID = PatientID 
        FROM Patients 
        WHERE FullName = @FullName AND DOB = @DOB;
    END
    
    IF @ExistingPatientID IS NULL
    BEGIN
        DECLARE @NextNum INT;
        SELECT @NextNum = ISNULL(MAX(CAST(SUBSTRING(PatientID, 3, 4) AS INT)), 0) + 1 FROM Patients;
        SET @NewPatientID = 'BN' + RIGHT('0000' + CAST(@NextNum AS VARCHAR(4)), 4);
        
        INSERT INTO Patients (PatientID, FullName, DOB, Gender, InsuranceCard, Address)
        VALUES (@NewPatientID, @FullName, @DOB, @Gender, @InsuranceCard, @Address);
    END
    ELSE
    BEGIN
        SET @NewPatientID = @ExistingPatientID;
        UPDATE Patients 
        SET InsuranceCard = ISNULL(@InsuranceCard, InsuranceCard),
            Address = ISNULL(@Address, Address)
        WHERE PatientID = @NewPatientID;
    END

    INSERT INTO Visits (PatientID, DoctorID, Status, VisitDate)
    VALUES (@NewPatientID, @DoctorID, N'Chờ khám', GETDATE());
END;
GO

-- 2. SP Lấy Danh Sách Bệnh Nhân Chờ Khám
CREATE OR ALTER PROCEDURE sp_GetWaitingList
    @DoctorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        V.VisitID,
        P.PatientID,
        P.FullName,
        P.DOB,
        P.Gender,
        P.InsuranceCard,
        P.Address,
        D.DoctorName,
        D.RoomNo,
        V.VisitDate
    FROM Visits V
    INNER JOIN Patients P ON V.PatientID = P.PatientID
    INNER JOIN Doctors D ON V.DoctorID = D.DoctorID
    WHERE V.Status = N'Chờ khám'
      AND CAST(V.VisitDate AS DATE) = CAST(GETDATE() AS DATE)
      AND (@DoctorID IS NULL OR V.DoctorID = @DoctorID)
    ORDER BY V.VisitDate ASC;
END;
GO

-- 3. SP Lấy Danh Sách Bệnh Nhân Đã Tiếp Đón Trong Ngày
CREATE OR ALTER PROCEDURE sp_GetTodayRegisteredPatients
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        V.VisitID,
        P.PatientID,
        P.FullName,
        P.DOB,
        P.Gender,
        P.InsuranceCard,
        P.Address,
        D.DoctorName,
        D.RoomNo,
        V.Status,
        V.VisitDate
    FROM Visits V
    INNER JOIN Patients P ON V.PatientID = P.PatientID
    INNER JOIN Doctors D ON V.DoctorID = D.DoctorID
    WHERE CAST(V.VisitDate AS DATE) = CAST(GETDATE() AS DATE)
    ORDER BY V.VisitDate DESC;
END;
GO
