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
        Phone VARCHAR(20) NULL,
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
    @Phone VARCHAR(20) = NULL,
    @NewPatientID VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ExistingPatientID VARCHAR(20) = NULL;
    
    -- Chỉ kiểm tra trùng khớp dựa trên Số điện thoại
    IF @Phone IS NOT NULL AND @Phone <> ''
    BEGIN
        SELECT TOP 1 @ExistingPatientID = PatientID 
        FROM Patients 
        WHERE Phone = @Phone;
    END
    
    -- Nếu chưa tồn tại bệnh nhân có SĐT này thì tạo mới
    IF @ExistingPatientID IS NULL
    BEGIN
        DECLARE @NextNum INT;
        SELECT @NextNum = ISNULL(MAX(CAST(SUBSTRING(PatientID, 3, 4) AS INT)), 0) + 1 FROM Patients;
        SET @NewPatientID = 'BN' + RIGHT('0000' + CAST(@NextNum AS VARCHAR(4)), 4);
        
        INSERT INTO Patients (PatientID, FullName, DOB, Gender, InsuranceCard, Address, Phone)
        VALUES (@NewPatientID, @FullName, @DOB, @Gender, @InsuranceCard, @Address, @Phone);
    END
    -- Nếu đã tồn tại bệnh nhân trùng SĐT thì cập nhật thông tin và dùng lại mã BN cũ
    ELSE
    BEGIN
        SET @NewPatientID = @ExistingPatientID;
        UPDATE Patients 
        SET FullName = @FullName,
            DOB = @DOB,
            Gender = @Gender,
            InsuranceCard = ISNULL(@InsuranceCard, InsuranceCard),
            Address = ISNULL(@Address, Address)
        WHERE PatientID = @NewPatientID;
    END

    -- Tạo lượt khám
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
        ROW_NUMBER() OVER(ORDER BY V.VisitDate ASC) AS QueueNo,
        V.VisitID,
        P.PatientID,
        P.FullName,
        P.DOB,
        P.Gender,
        P.InsuranceCard,
        P.Address,
        P.Phone,
        D.DoctorName,
        D.RoomNo,
        V.Status,
        V.VisitDate
    FROM Visits V
    INNER JOIN Patients P ON V.PatientID = P.PatientID
    INNER JOIN Doctors D ON V.DoctorID = D.DoctorID
    WHERE CAST(V.VisitDate AS DATE) = CAST(GETDATE() AS DATE)
    ORDER BY V.VisitDate ASC;
END;
GO

-- 9. Chèn thêm 50 loại thuốc bổ sung (chỉ chèn nếu chưa có)
IF NOT EXISTS (SELECT 1 FROM Medications WHERE MedicationName = N'Ibuprofen 400mg')
BEGIN
    INSERT INTO Medications (MedicationName, Unit, Price, StockQuantity) VALUES
    (N'Ibuprofen 400mg', N'Viên', 1200.00, 2500),
    (N'Metformin 500mg', N'Viên', 800.00, 4500),
    (N'Amlodipine 5mg', N'Viên', 1000.00, 3000),
    (N'Atorvastatin 10mg', N'Viên', 3500.00, 1500),
    (N'Omeprazole 20mg', N'Viên', 1500.00, 4000),
    (N'Esomeprazole 40mg', N'Viên', 8500.00, 2000),
    (N'Loratadine 10mg', N'Viên', 1200.00, 5000),
    (N'Cetirizine 10mg', N'Viên', 1000.00, 6000),
    (N'Cefuroxime 500mg', N'Viên', 7500.00, 1800),
    (N'Cefixime 200mg', N'Viên', 6000.00, 2000),
    (N'Azithromycin 500mg', N'Viên', 12000.00, 1000),
    (N'Ciprofloxacin 500mg', N'Viên', 4500.00, 1200),
    (N'Augmentin 1g', N'Viên', 18000.00, 800),
    (N'Methylprednisolone 16mg', N'Viên', 4000.00, 1500),
    (N'Acetylcysteine 200mg', N'Gói', 2500.00, 3000),
    (N'Bromhexine 8mg', N'Viên', 600.00, 5000),
    (N'Ambroxol 30mg', N'Viên', 800.00, 4000),
    (N'Phosphalugel', N'Gói', 4500.00, 600),
    (N'Smecta 3g', N'Gói', 5000.00, 1000),
    (N'Oresol', N'Gói', 1500.00, 2000),
    (N'Berberin 50mg', N'Viên', 300.00, 15000),
    (N'Neurobion', N'Viên', 2200.00, 5000),
    (N'Ginkgo Biloba 80mg', N'Viên', 3000.00, 4000),
    (N'Piracetam 800mg', N'Viên', 2500.00, 3000),
    (N'Calcium Carbonate 500mg', N'Viên', 1500.00, 6000),
    (N'Vitamin D3 1000IU', N'Viên', 1800.00, 4000),
    (N'Glucosamine 500mg', N'Viên', 4500.00, 2500),
    (N'Salbutamol 2mg', N'Viên', 500.00, 3000),
    (N'Prednisolone 5mg', N'Viên', 800.00, 4000),
    (N'Meloxicam 7.5mg', N'Viên', 2000.00, 2000),
    (N'Diclofenac 50mg', N'Viên', 1000.00, 3000),
    (N'Celecoxib 200mg', N'Viên', 5000.00, 1500),
    (N'Losartan 50mg', N'Viên', 3200.00, 2000),
    (N'Rosuvastatin 10mg', N'Viên', 6500.00, 1200),
    (N'Pantoprazole 40mg', N'Viên', 5500.00, 2500),
    (N'Domperidone 10mg', N'Viên', 800.00, 4000),
    (N'Loperamide 2mg', N'Viên', 600.00, 3500),
    (N'Fexofenadine 180mg', N'Viên', 4500.00, 2000),
    (N'Clarithromycin 500mg', N'Viên', 9500.00, 1000),
    (N'Levofloxacin 500mg', N'Viên', 11000.00, 1000),
    (N'Metronidazole 250mg', N'Viên', 1000.00, 3000),
    (N'Spasmo-Canulase', N'Viên', 3500.00, 1500),
    (N'Aciclovir 400mg', N'Viên', 2200.00, 2000),
    (N'Gliclazide 80mg', N'Viên', 1500.00, 3000),
    (N'Glimepiride 2mg', N'Viên', 2000.00, 2000),
    (N'Enalapril 5mg', N'Viên', 800.00, 4000),
    (N'Telfast HD 180mg', N'Viên', 9000.00, 1200),
    (N'Hapacol 250 (Trẻ em)', N'Gói', 1800.00, 2500),
    (N'Efferalgan 80mg (Đặt trực tràng)', N'Viên', 5000.00, 500),
    (N'Strepsils Cool', N'Viên', 1500.00, 6000);
END
GO
