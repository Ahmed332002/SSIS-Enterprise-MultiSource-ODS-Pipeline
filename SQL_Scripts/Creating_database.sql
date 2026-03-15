IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SourceDB_Sales')
BEGIN
    ALTER DATABASE SourceDB_Sales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SourceDB_Sales;
END
GO

CREATE DATABASE SourceDB_Sales;
GO

USE SourceDB_Sales;
GO

-- Create HR Source Database
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SourceDB_HR')
BEGIN
    ALTER DATABASE SourceDB_HR SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SourceDB_HR;
END
GO

CREATE DATABASE SourceDB_HR;
GO
USE SourceDB_Sales;
GO

-- Customers Table
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerCode VARCHAR(20) NOT NULL UNIQUE,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    CustomerType VARCHAR(20), -- Retail, Wholesale, Online
    CreditLimit DECIMAL(18,2),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- Products Table
CREATE TABLE dbo.Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductCode VARCHAR(20) NOT NULL UNIQUE,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    UnitPrice DECIMAL(18,2),
    UnitsInStock INT,
    ReorderLevel INT,
    Discontinued BIT DEFAULT 0,
    SupplierID INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- Sales Orders Table
CREATE TABLE dbo.SalesOrders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderNumber VARCHAR(20) NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia VARCHAR(50),
    Freight DECIMAL(18,2),
    ShipName VARCHAR(100),
    ShipAddress VARCHAR(200),
    ShipCity VARCHAR(50),
    ShipState VARCHAR(50),
    ShipZipCode VARCHAR(10),
    ShipCountry VARCHAR(50),
    OrderStatus VARCHAR(20), -- Pending, Processing, Shipped, Delivered, Cancelled
    TotalAmount DECIMAL(18,2),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);

-- Order Details Table
CREATE TABLE dbo.OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0,
    LineTotal AS (UnitPrice * Quantity * (1 - Discount)),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES dbo.SalesOrders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);
USE SourceDB_HR;
GO

-- Departments Table
CREATE TABLE dbo.Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentCode VARCHAR(20) NOT NULL UNIQUE,
    DepartmentName VARCHAR(100) NOT NULL,
    ManagerID INT NULL,
    Location VARCHAR(100),
    Budget DECIMAL(18,2),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- Employees Table
CREATE TABLE dbo.Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode VARCHAR(20) NOT NULL UNIQUE,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    HireDate DATE NOT NULL,
    JobTitle VARCHAR(100),
    DepartmentID INT,
    ManagerID INT NULL,
    Salary DECIMAL(18,2),
    CommissionPct DECIMAL(5,2),
    IsActive BIT DEFAULT 1,
    TerminationDate DATE NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID)
);

-- Employee Attendance Table
CREATE TABLE dbo.EmployeeAttendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    CheckInTime TIME,
    CheckOutTime TIME,
    WorkHours DECIMAL(5,2),
    AttendanceStatus VARCHAR(20), -- Present, Absent, Late, Leave, Holiday
    Remarks VARCHAR(200),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID)
);

-- Payroll Table
CREATE TABLE dbo.Payroll (
    PayrollID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    PayPeriodStart DATE NOT NULL,
    PayPeriodEnd DATE NOT NULL,
    BaseSalary DECIMAL(18,2),
    Bonus DECIMAL(18,2) DEFAULT 0,
    Deductions DECIMAL(18,2) DEFAULT 0,
    NetPay AS (BaseSalary + Bonus - Deductions),
    PaymentDate DATE,
    PaymentStatus VARCHAR(20), -- Pending, Processed, Paid
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID)
);

USE SourceDB_Sales;
GO

-- Insert Customers
INSERT INTO dbo.Customers (CustomerCode, CustomerName, Email, Phone, Address, City, State, ZipCode, Country, CustomerType, CreditLimit, IsActive)
VALUES 
('CUST001', 'Acme Corporation', 'contact@acme.com', '555-0101', '123 Main St', 'New York', 'NY', '10001', 'USA', 'Wholesale', 50000.00, 1),
('CUST002', 'Global Tech Solutions', 'info@globaltech.com', '555-0102', '456 Tech Blvd', 'San Francisco', 'CA', '94102', 'USA', 'Wholesale', 75000.00, 1),
('CUST003', 'Retail Store Inc', 'sales@retailstore.com', '555-0103', '789 Shopping Ave', 'Los Angeles', 'CA', '90001', 'USA', 'Retail', 25000.00, 1),
('CUST004', 'E-Commerce Plus', 'orders@ecomplus.com', '555-0104', '321 Digital Way', 'Seattle', 'WA', '98101', 'USA', 'Online', 35000.00, 1),
('CUST005', 'Manufacturing Co', 'procurement@mfg.com', '555-0105', '654 Industry Dr', 'Chicago', 'IL', '60601', 'USA', 'Wholesale', 100000.00, 1),
('CUST006', 'Small Business LLC', 'owner@smallbiz.com', '555-0106', '987 Local St', 'Austin', 'TX', '73301', 'USA', 'Retail', 15000.00, 1),
('CUST007', 'International Trading', 'trade@intltrade.com', '555-0107', '147 Export Ln', 'Miami', 'FL', '33101', 'USA', 'Wholesale', 80000.00, 1),
('CUST008', 'Quick Mart Chain', 'hq@quickmart.com', '555-0108', '258 Retail Rd', 'Boston', 'MA', '02101', 'USA', 'Retail', 40000.00, 1),
('CUST009', 'Tech Startup Co', 'admin@techstart.com', '555-0109', '369 Innovation St', 'San Jose', 'CA', '95101', 'USA', 'Online', 20000.00, 1),
('CUST010', 'Distribution Network', 'logistics@distnet.com', '555-0110', '741 Warehouse Blvd', 'Dallas', 'TX', '75201', 'USA', 'Wholesale', 90000.00, 1),
('CUST011', 'Corner Shop', 'shop@corner.com', '555-0111', '852 Neighborhood Ave', 'Portland', 'OR', '97201', 'USA', 'Retail', 10000.00, 1),
('CUST012', 'Premium Buyers Club', 'vip@premium.com', '555-0112', '963 Luxury Ln', 'Beverly Hills', 'CA', '90210', 'USA', 'Wholesale', 120000.00, 1),
('CUST013', 'Budget Stores Ltd', 'contact@budget.com', '555-0113', '159 Value St', 'Phoenix', 'AZ', '85001', 'USA', 'Retail', 18000.00, 1),
('CUST014', 'Online Mega Store', 'support@megastore.com', '555-0114', '357 Digital Plaza', 'Denver', 'CO', '80201', 'USA', 'Online', 45000.00, 1),
('CUST015', 'Wholesale Depot', 'bulk@depot.com', '555-0115', '486 Distribution Way', 'Atlanta', 'GA', '30301', 'USA', 'Wholesale', 65000.00, 1);

-- Insert Products
INSERT INTO dbo.Products (ProductCode, ProductName, Category, SubCategory, UnitPrice, UnitsInStock, ReorderLevel, Discontinued, SupplierID)
VALUES 
('PROD001', 'Laptop Pro 15', 'Electronics', 'Computers', 1299.99, 50, 10, 0, 1),
('PROD002', 'Wireless Mouse', 'Electronics', 'Accessories', 29.99, 200, 50, 0, 1),
('PROD003', 'USB-C Cable', 'Electronics', 'Cables', 15.99, 500, 100, 0, 2),
('PROD004', 'Office Chair Deluxe', 'Furniture', 'Chairs', 249.99, 75, 15, 0, 3),
('PROD005', 'Standing Desk', 'Furniture', 'Desks', 599.99, 30, 8, 0, 3),
('PROD006', 'LED Monitor 27"', 'Electronics', 'Monitors', 349.99, 100, 20, 0, 1),
('PROD007', 'Mechanical Keyboard', 'Electronics', 'Accessories', 89.99, 150, 30, 0, 1),
('PROD008', 'Noise-Canceling Headphones', 'Electronics', 'Audio', 199.99, 80, 15, 0, 4),
('PROD009', 'Webcam HD', 'Electronics', 'Accessories', 79.99, 120, 25, 0, 1),
('PROD010', 'Desk Lamp LED', 'Office Supplies', 'Lighting', 39.99, 180, 40, 0, 5),
('PROD011', 'Notebook Set', 'Office Supplies', 'Stationery', 12.99, 400, 80, 0, 5),
('PROD012', 'Pen Collection', 'Office Supplies', 'Stationery', 8.99, 600, 120, 0, 5),
('PROD013', 'File Cabinet', 'Furniture', 'Storage', 189.99, 45, 10, 0, 3),
('PROD014', 'Bookshelf', 'Furniture', 'Storage', 129.99, 60, 12, 0, 3),
('PROD015', 'Tablet 10"', 'Electronics', 'Tablets', 399.99, 90, 18, 0, 1),
('PROD016', 'Smartphone Pro', 'Electronics', 'Phones', 899.99, 70, 15, 0, 1),
('PROD017', 'Printer All-in-One', 'Electronics', 'Printers', 279.99, 55, 12, 0, 4),
('PROD018', 'Paper Ream A4', 'Office Supplies', 'Paper', 6.99, 800, 150, 0, 5),
('PROD019', 'Whiteboard', 'Office Supplies', 'Presentation', 89.99, 40, 10, 0, 5),
('PROD020', 'Conference Phone', 'Electronics', 'Phones', 449.99, 35, 8, 0, 4);

-- Insert Sales Orders
DECLARE @CustomerID INT, @OrderDate DATETIME, @Counter INT = 1;

WHILE @Counter <= 50
BEGIN
    SET @CustomerID = (@Counter % 15) + 1;
    SET @OrderDate = DATEADD(DAY, -(@Counter * 3), GETDATE());
    
    INSERT INTO dbo.SalesOrders (OrderNumber, CustomerID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipState, ShipZipCode, ShipCountry, OrderStatus, TotalAmount)
    VALUES (
        'ORD' + RIGHT('00000' + CAST(@Counter AS VARCHAR(5)), 5),
        @CustomerID,
        @OrderDate,
        DATEADD(DAY, 7, @OrderDate),
        CASE WHEN @Counter % 3 = 0 THEN NULL ELSE DATEADD(DAY, 3, @OrderDate) END,
        CASE (@Counter % 3) WHEN 0 THEN 'FedEx' WHEN 1 THEN 'UPS' ELSE 'DHL' END,
        ROUND(RAND() * 100, 2),
        'Ship Name ' + CAST(@Counter AS VARCHAR(5)),
        'Ship Address ' + CAST(@Counter AS VARCHAR(5)),
        'City ' + CAST(@Counter AS VARCHAR(5)),
        'State',
        '12345',
        'USA',
        CASE 
            WHEN @Counter % 5 = 0 THEN 'Delivered'
            WHEN @Counter % 5 = 1 THEN 'Shipped'
            WHEN @Counter % 5 = 2 THEN 'Processing'
            ELSE 'Pending'
        END,
        0 -- Will be updated after OrderDetails insert
    );
    
    SET @Counter = @Counter + 1;
END

-- Insert Order Details
DECLARE @OrderID INT, @ProductID INT, @Quantity INT, @DetailCounter INT = 1;

WHILE @DetailCounter <= 150
BEGIN
    SET @OrderID = ((@DetailCounter - 1) % 50) + 1;
    SET @ProductID = ((@DetailCounter - 1) % 20) + 1;
    SET @Quantity = (ABS(CHECKSUM(NEWID())) % 10) + 1;
    
    INSERT INTO dbo.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    SELECT 
        @OrderID,
        @ProductID,
        p.UnitPrice,
        @Quantity,
        CASE WHEN @DetailCounter % 10 = 0 THEN 0.10 ELSE 0.00 END
    FROM dbo.Products p
    WHERE p.ProductID = @ProductID;
    
    SET @DetailCounter = @DetailCounter + 1;
END

-- Update TotalAmount in SalesOrders
UPDATE so
SET TotalAmount = totals.OrderTotal
FROM dbo.SalesOrders so
INNER JOIN (
    SELECT OrderID, SUM(LineTotal) AS OrderTotal
    FROM dbo.OrderDetails
    GROUP BY OrderID
) totals ON so.OrderID = totals.OrderID;

-- ============================================================================
-- STEP 5: INSERT SAMPLE DATA - HR DATABASE
-- ============================================================================

USE SourceDB_HR;
GO

-- Insert Departments
INSERT INTO dbo.Departments (DepartmentCode, DepartmentName, Location, Budget, IsActive)
VALUES 
('DEPT001', 'Sales', 'Building A - Floor 1', 500000.00, 1),
('DEPT002', 'Marketing', 'Building A - Floor 2', 350000.00, 1),
('DEPT003', 'IT', 'Building B - Floor 1', 600000.00, 1),
('DEPT004', 'Human Resources', 'Building A - Floor 3', 250000.00, 1),
('DEPT005', 'Finance', 'Building B - Floor 2', 400000.00, 1),
('DEPT006', 'Operations', 'Building C - Floor 1', 550000.00, 1),
('DEPT007', 'Customer Service', 'Building A - Floor 1', 300000.00, 1),
('DEPT008', 'Research & Development', 'Building B - Floor 3', 750000.00, 1),
('DEPT009', 'Legal', 'Building A - Floor 4', 200000.00, 1),
('DEPT010', 'Procurement', 'Building C - Floor 2', 280000.00, 1);

-- Insert Employees
INSERT INTO dbo.Employees (EmployeeCode, FirstName, LastName, Email, Phone, HireDate, JobTitle, DepartmentID, ManagerID, Salary, CommissionPct, IsActive)
VALUES 
-- Sales Department
('EMP001', 'John', 'Smith', 'john.smith@company.com', '555-1001', '2020-01-15', 'Sales Manager', 1, NULL, 85000.00, 0.05, 1),
('EMP002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', '555-1002', '2020-03-20', 'Sales Representative', 1, 1, 55000.00, 0.08, 1),
('EMP003', 'Michael', 'Williams', 'michael.williams@company.com', '555-1003', '2021-02-10', 'Sales Representative', 1, 1, 52000.00, 0.08, 1),
('EMP004', 'Emily', 'Brown', 'emily.brown@company.com', '555-1004', '2021-05-12', 'Sales Representative', 1, 1, 50000.00, 0.08, 1),

-- Marketing Department
('EMP005', 'David', 'Jones', 'david.jones@company.com', '555-1005', '2019-06-01', 'Marketing Director', 2, NULL, 95000.00, NULL, 1),
('EMP006', 'Jennifer', 'Garcia', 'jennifer.garcia@company.com', '555-1006', '2020-08-15', 'Marketing Specialist', 2, 5, 58000.00, NULL, 1),
('EMP007', 'Robert', 'Martinez', 'robert.martinez@company.com', '555-1007', '2021-01-20', 'Content Writer', 2, 5, 48000.00, NULL, 1),

-- IT Department
('EMP008', 'Lisa', 'Rodriguez', 'lisa.rodriguez@company.com', '555-1008', '2018-03-10', 'IT Director', 3, NULL, 110000.00, NULL, 1),
('EMP009', 'William', 'Hernandez', 'william.hernandez@company.com', '555-1009', '2019-07-22', 'Senior Developer', 3, 8, 88000.00, NULL, 1),
('EMP010', 'Jessica', 'Lopez', 'jessica.lopez@company.com', '555-1010', '2020-09-05', 'Developer', 3, 8, 72000.00, NULL, 1),
('EMP011', 'James', 'Gonzalez', 'james.gonzalez@company.com', '555-1011', '2021-04-18', 'Junior Developer', 3, 8, 55000.00, NULL, 1),
('EMP012', 'Mary', 'Wilson', 'mary.wilson@company.com', '555-1012', '2021-11-08', 'System Administrator', 3, 8, 68000.00, NULL, 1),

-- HR Department
('EMP013', 'Christopher', 'Anderson', 'christopher.anderson@company.com', '555-1013', '2017-05-15', 'HR Director', 4, NULL, 92000.00, NULL, 1),
('EMP014', 'Amanda', 'Thomas', 'amanda.thomas@company.com', '555-1014', '2019-10-20', 'HR Manager', 4, 13, 68000.00, NULL, 1),
('EMP015', 'Daniel', 'Taylor', 'daniel.taylor@company.com', '555-1015', '2020-12-01', 'Recruiter', 4, 13, 52000.00, NULL, 1),

-- Finance Department
('EMP016', 'Patricia', 'Moore', 'patricia.moore@company.com', '555-1016', '2018-02-14', 'Finance Director', 5, NULL, 105000.00, NULL, 1),
('EMP017', 'Matthew', 'Jackson', 'matthew.jackson@company.com', '555-1017', '2019-04-25', 'Senior Accountant', 5, 16, 75000.00, NULL, 1),
('EMP018', 'Linda', 'Martin', 'linda.martin@company.com', '555-1018', '2020-06-30', 'Accountant', 5, 16, 58000.00, NULL, 1),
('EMP019', 'Joshua', 'Lee', 'joshua.lee@company.com', '555-1019', '2021-08-15', 'Financial Analyst', 5, 16, 62000.00, NULL, 1),

-- Operations Department
('EMP020', 'Barbara', 'Perez', 'barbara.perez@company.com', '555-1020', '2017-09-10', 'Operations Manager', 6, NULL, 88000.00, NULL, 1),
('EMP021', 'Andrew', 'White', 'andrew.white@company.com', '555-1021', '2019-11-18', 'Operations Coordinator', 6, 20, 56000.00, NULL, 1),
('EMP022', 'Elizabeth', 'Harris', 'elizabeth.harris@company.com', '555-1022', '2020-05-22', 'Logistics Specialist', 6, 20, 54000.00, NULL, 1),

-- Customer Service
('EMP023', 'Joseph', 'Sanchez', 'joseph.sanchez@company.com', '555-1023', '2019-01-12', 'CS Manager', 7, NULL, 72000.00, NULL, 1),
('EMP024', 'Susan', 'Clark', 'susan.clark@company.com', '555-1024', '2020-03-08', 'Customer Service Rep', 7, 23, 42000.00, NULL, 1),
('EMP025', 'Kevin', 'Ramirez', 'kevin.ramirez@company.com', '555-1025', '2021-02-15', 'Customer Service Rep', 7, 23, 40000.00, NULL, 1),

-- R&D Department
('EMP026', 'Nancy', 'Lewis', 'nancy.lewis@company.com', '555-1026', '2016-08-20', 'R&D Director', 8, NULL, 120000.00, NULL, 1),
('EMP027', 'Brian', 'Robinson', 'brian.robinson@company.com', '555-1027', '2018-10-05', 'Research Scientist', 8, 26, 95000.00, NULL, 1),
('EMP028', 'Karen', 'Walker', 'karen.walker@company.com', '555-1028', '2020-07-12', 'Lab Technician', 8, 26, 58000.00, NULL, 1),

-- Legal Department
('EMP029', 'Steven', 'Young', 'steven.young@company.com', '555-1029', '2017-12-01', 'Legal Counsel', 9, NULL, 115000.00, NULL, 1),
('EMP030', 'Michelle', 'Allen', 'michelle.allen@company.com', '555-1030', '2019-09-18', 'Paralegal', 9, 29, 62000.00, NULL, 1);
DECLARE @EmpID INT = 1, @Date DATE, @DayCounter INT;

WHILE @EmpID <= 10
BEGIN
    SET @DayCounter = 0;
    WHILE @DayCounter < 30
    BEGIN
        SET @Date = CAST(DATEADD(DAY, -@DayCounter, GETDATE()) AS DATE);
        
        -- Skip weekends
        IF DATEPART(WEEKDAY, @Date) NOT IN (1, 7)
        BEGIN
            INSERT INTO dbo.EmployeeAttendance (EmployeeID, AttendanceDate, CheckInTime, CheckOutTime, WorkHours, AttendanceStatus, Remarks)
            VALUES (
                @EmpID,
                @Date,
                CASE WHEN RAND() > 0.1 THEN '09:00:00' ELSE '09:30:00' END,
                CASE WHEN RAND() > 0.2 THEN '18:00:00' ELSE '17:30:00' END,
                8.0 + (RAND() * 2 - 1),
                CASE 
                    WHEN RAND() > 0.95 THEN 'Absent'
                    WHEN RAND() > 0.90 THEN 'Late'
                    ELSE 'Present'
                END,
                NULL
            );
        END
        
        SET @DayCounter = @DayCounter + 1;
    END
    
    SET @EmpID = @EmpID + 1;
END

-- Insert Payroll Records (Last 3 months for all employees)
DECLARE @PayEmpID INT = 1, @MonthCounter INT = 0;

WHILE @PayEmpID <= 30
BEGIN
    SET @MonthCounter = 0;
    WHILE @MonthCounter < 3
    BEGIN
        DECLARE @PeriodEnd DATE = DATEADD(MONTH, -@MonthCounter, EOMONTH(GETDATE()));
        DECLARE @PeriodStart DATE = DATEADD(DAY, 1, EOMONTH(@PeriodEnd, -1));
        
        INSERT INTO dbo.Payroll (EmployeeID, PayPeriodStart, PayPeriodEnd, BaseSalary, Bonus, Deductions, PaymentDate, PaymentStatus)
        SELECT 
            @PayEmpID,
            @PeriodStart,
            @PeriodEnd,
            Salary / 12, -- Monthly salary
            CASE WHEN RAND() > 0.7 THEN ROUND(RAND() * 1000, 2) ELSE 0 END,
            ROUND((Salary / 12) * 0.15, 2), -- 15% deductions
            DATEADD(DAY, 5, @PeriodEnd),
            'Paid'
        FROM dbo.Employees
        WHERE EmployeeID = @PayEmpID;
        
        SET @MonthCounter = @MonthCounter + 1;
    END
    
    SET @PayEmpID = @PayEmpID + 1;
END