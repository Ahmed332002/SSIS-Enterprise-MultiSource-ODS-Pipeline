/*============================================================================
  ODS (OPERATIONAL DATA STORE) DATABASE SETUP
  This script creates the ODS database with staging and integration layers
  Author: Practice Setup
  Date: 2026-02-05
============================================================================*/

-- ============================================================================
-- STEP 1: CREATE ODS DATABASE
-- ============================================================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ODS_Enterprise')
BEGIN
    ALTER DATABASE ODS_Enterprise SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ODS_Enterprise;
END
GO

CREATE DATABASE ODS_Enterprise;
GO

USE ODS_Enterprise;
GO

-- ============================================================================
-- STEP 2: CREATE SCHEMAS FOR ORGANIZATION
-- ============================================================================

-- Staging schema for initial data loads
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');
GO

-- Integration schema for cleaned/transformed data
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'int')
    EXEC('CREATE SCHEMA int');
GO

-- Metadata schema for ETL control
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'meta')
    EXEC('CREATE SCHEMA meta');
GO

-- ============================================================================
-- STEP 3: CREATE METADATA TABLES
-- ============================================================================

-- ETL Execution Log
CREATE TABLE meta.ETL_ExecutionLog (
    ExecutionLogID INT PRIMARY KEY IDENTITY(1,1),
    PackageName VARCHAR(200) NOT NULL,
    ExecutionStartTime DATETIME NOT NULL,
    ExecutionEndTime DATETIME NULL,
    ExecutionStatus VARCHAR(20), -- Running, Success, Failed
    RowsExtracted INT NULL,
    RowsLoaded INT NULL,
    RowsRejected INT NULL,
    ErrorMessage VARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Source System Registry
CREATE TABLE meta.SourceSystems (
    SourceSystemID INT PRIMARY KEY IDENTITY(1,1),
    SourceSystemName VARCHAR(100) NOT NULL,
    SourceSystemCode VARCHAR(20) NOT NULL UNIQUE,
    Description VARCHAR(500),
    ConnectionString VARCHAR(500),
    IsActive BIT DEFAULT 1,
    LastLoadDate DATETIME NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- Table Load Control
CREATE TABLE meta.TableLoadControl (
    TableLoadControlID INT PRIMARY KEY IDENTITY(1,1),
    SourceSystemID INT NOT NULL,
    SourceTableName VARCHAR(200) NOT NULL,
    TargetTableName VARCHAR(200) NOT NULL,
    LoadType VARCHAR(20), -- Full, Incremental, Delta
    LastLoadDate DATETIME NULL,
    LastSuccessfulLoadDate DATETIME NULL,
    WatermarkColumn VARCHAR(100) NULL,
    WatermarkValue VARCHAR(100) NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SourceSystemID) REFERENCES meta.SourceSystems(SourceSystemID)
);

-- Data Quality Rules
CREATE TABLE meta.DataQualityRules (
    RuleID INT PRIMARY KEY IDENTITY(1,1),
    RuleName VARCHAR(100) NOT NULL,
    TableName VARCHAR(200) NOT NULL,
    ColumnName VARCHAR(100),
    RuleType VARCHAR(50), -- NotNull, Unique, Range, Lookup, Pattern
    RuleDefinition VARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- STEP 4: CREATE STAGING TABLES (Sales Source)
-- ============================================================================

-- Staging: Customers
CREATE TABLE stg.Customers (
    StagingID INT IDENTITY(1,1),
    CustomerID INT,
    CustomerCode VARCHAR(20),
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    CustomerType VARCHAR(20),
    CreditLimit DECIMAL(18,2),
    IsActive BIT,
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_Sales'
);

-- Staging: Products
CREATE TABLE stg.Products (
    StagingID INT IDENTITY(1,1),
    ProductID INT,
    ProductCode VARCHAR(20),
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    UnitPrice DECIMAL(18,2),
    UnitsInStock INT,
    ReorderLevel INT,
    Discontinued BIT,
    SupplierID INT,
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_Sales'
);

-- Staging: Sales Orders
CREATE TABLE stg.SalesOrders (
    StagingID INT IDENTITY(1,1),
    OrderID INT,
    OrderNumber VARCHAR(20),
    CustomerID INT,
    OrderDate DATETIME,
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
    OrderStatus VARCHAR(20),
    TotalAmount DECIMAL(18,2),
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_Sales'
);

-- Staging: Order Details
CREATE TABLE stg.OrderDetails (
    StagingID INT IDENTITY(1,1),
    OrderDetailID INT,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    LineTotal DECIMAL(18,2),
    SourceCreatedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_Sales'
);

-- ============================================================================
-- STEP 5: CREATE STAGING TABLES (HR Source)
-- ============================================================================

-- Staging: Departments
CREATE TABLE stg.Departments (
    StagingID INT IDENTITY(1,1),
    DepartmentID INT,
    DepartmentCode VARCHAR(20),
    DepartmentName VARCHAR(100),
    ManagerID INT,
    Location VARCHAR(100),
    Budget DECIMAL(18,2),
    IsActive BIT,
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_HR'
);

-- Staging: Employees
CREATE TABLE stg.Employees (
    StagingID INT IDENTITY(1,1),
    EmployeeID INT,
    EmployeeCode VARCHAR(20),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    HireDate DATE,
    JobTitle VARCHAR(100),
    DepartmentID INT,
    ManagerID INT,
    Salary DECIMAL(18,2),
    CommissionPct DECIMAL(5,2),
    IsActive BIT,
    TerminationDate DATE,
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_HR'
);

-- Staging: Employee Attendance
CREATE TABLE stg.EmployeeAttendance (
    StagingID INT IDENTITY(1,1),
    AttendanceID INT,
    EmployeeID INT,
    AttendanceDate DATE,
    CheckInTime TIME,
    CheckOutTime TIME,
    WorkHours DECIMAL(5,2),
    AttendanceStatus VARCHAR(20),
    Remarks VARCHAR(200),
    SourceCreatedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_HR'
);

-- Staging: Payroll
CREATE TABLE stg.Payroll (
    StagingID INT IDENTITY(1,1),
    PayrollID INT,
    EmployeeID INT,
    PayPeriodStart DATE,
    PayPeriodEnd DATE,
    BaseSalary DECIMAL(18,2),
    Bonus DECIMAL(18,2),
    Deductions DECIMAL(18,2),
    NetPay DECIMAL(18,2),
    PaymentDate DATE,
    PaymentStatus VARCHAR(20),
    SourceCreatedDate DATETIME,
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem VARCHAR(50) DEFAULT 'SourceDB_HR'
);

-- ============================================================================
-- STEP 6: CREATE INTEGRATION TABLES (Cleaned & Integrated Data)
-- ============================================================================

-- Integration: Customers (with SCD Type 1)
CREATE TABLE int.Customers (
    CustomerKey INT PRIMARY KEY IDENTITY(1,1),
    SourceCustomerID INT NOT NULL,
    CustomerCode VARCHAR(20) NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    CustomerType VARCHAR(20),
    CreditLimit DECIMAL(18,2),
    IsActive BIT,
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0
);

-- Integration: Products
CREATE TABLE int.Products (
    ProductKey INT PRIMARY KEY IDENTITY(1,1),
    SourceProductID INT NOT NULL,
    ProductCode VARCHAR(20) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    UnitPrice DECIMAL(18,2),
    UnitsInStock INT,
    ReorderLevel INT,
    Discontinued BIT,
    SupplierID INT,
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0
);

-- Integration: Sales Orders
CREATE TABLE int.SalesOrders (
    OrderKey INT PRIMARY KEY IDENTITY(1,1),
    SourceOrderID INT NOT NULL,
    OrderNumber VARCHAR(20) NOT NULL,
    CustomerKey INT,
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
    OrderStatus VARCHAR(20),
    TotalAmount DECIMAL(18,2),
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CustomerKey) REFERENCES int.Customers(CustomerKey)
);

-- Integration: Order Details
CREATE TABLE int.OrderDetails (
    OrderDetailKey INT PRIMARY KEY IDENTITY(1,1),
    SourceOrderDetailID INT NOT NULL,
    OrderKey INT NOT NULL,
    ProductKey INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5,2),
    LineTotal DECIMAL(18,2),
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (OrderKey) REFERENCES int.SalesOrders(OrderKey),
    FOREIGN KEY (ProductKey) REFERENCES int.Products(ProductKey)
);

-- Integration: Departments
CREATE TABLE int.Departments (
    DepartmentKey INT PRIMARY KEY IDENTITY(1,1),
    SourceDepartmentID INT NOT NULL,
    DepartmentCode VARCHAR(20) NOT NULL,
    DepartmentName VARCHAR(100) NOT NULL,
    ManagerID INT,
    Location VARCHAR(100),
    Budget DECIMAL(18,2),
    IsActive BIT,
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0
);

-- Integration: Employees
CREATE TABLE int.Employees (
    EmployeeKey INT PRIMARY KEY IDENTITY(1,1),
    SourceEmployeeID INT NOT NULL,
    EmployeeCode VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    FullName AS (FirstName + ' ' + LastName),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    HireDate DATE NOT NULL,
    JobTitle VARCHAR(100),
    DepartmentKey INT,
    ManagerID INT,
    Salary DECIMAL(18,2),
    CommissionPct DECIMAL(5,2),
    IsActive BIT,
    TerminationDate DATE,
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    SourceModifiedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (DepartmentKey) REFERENCES int.Departments(DepartmentKey)
);

-- Integration: Employee Attendance
CREATE TABLE int.EmployeeAttendance (
    AttendanceKey INT PRIMARY KEY IDENTITY(1,1),
    SourceAttendanceID INT NOT NULL,
    EmployeeKey INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    CheckInTime TIME,
    CheckOutTime TIME,
    WorkHours DECIMAL(5,2),
    AttendanceStatus VARCHAR(20),
    Remarks VARCHAR(200),
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (EmployeeKey) REFERENCES int.Employees(EmployeeKey)
);

-- Integration: Payroll
CREATE TABLE int.Payroll (
    PayrollKey INT PRIMARY KEY IDENTITY(1,1),
    SourcePayrollID INT NOT NULL,
    EmployeeKey INT NOT NULL,
    PayPeriodStart DATE NOT NULL,
    PayPeriodEnd DATE NOT NULL,
    BaseSalary DECIMAL(18,2),
    Bonus DECIMAL(18,2),
    Deductions DECIMAL(18,2),
    NetPay DECIMAL(18,2),
    PaymentDate DATE,
    PaymentStatus VARCHAR(20),
    SourceSystem VARCHAR(50),
    SourceCreatedDate DATETIME,
    ODSCreatedDate DATETIME DEFAULT GETDATE(),
    ODSModifiedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (EmployeeKey) REFERENCES int.Employees(EmployeeKey)
);

-- ============================================================================
-- STEP 7: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Customers Indexes
CREATE UNIQUE INDEX IX_Customers_CustomerCode ON int.Customers(CustomerCode) WHERE IsDeleted = 0;
CREATE INDEX IX_Customers_SourceID ON int.Customers(SourceCustomerID);

-- Products Indexes
CREATE UNIQUE INDEX IX_Products_ProductCode ON int.Products(ProductCode) WHERE IsDeleted = 0;
CREATE INDEX IX_Products_Category ON int.Products(Category);

-- Sales Orders Indexes
CREATE UNIQUE INDEX IX_SalesOrders_OrderNumber ON int.SalesOrders(OrderNumber) WHERE IsDeleted = 0;
CREATE INDEX IX_SalesOrders_OrderDate ON int.SalesOrders(OrderDate);
CREATE INDEX IX_SalesOrders_CustomerKey ON int.SalesOrders(CustomerKey);

-- Employees Indexes
CREATE UNIQUE INDEX IX_Employees_EmployeeCode ON int.Employees(EmployeeCode) WHERE IsDeleted = 0;
CREATE INDEX IX_Employees_DepartmentKey ON int.Employees(DepartmentKey);

-- Attendance Indexes
CREATE INDEX IX_Attendance_EmployeeDate ON int.EmployeeAttendance(EmployeeKey, AttendanceDate);

-- ============================================================================
-- STEP 8: INSERT METADATA
-- ============================================================================

-- Register Source Systems
INSERT INTO meta.SourceSystems (SourceSystemName, SourceSystemCode, Description, IsActive)
VALUES 
('Sales Database', 'SALES_DB', 'Production Sales System', 1),
('HR Database', 'HR_DB', 'Human Resources System', 1);

-- Register Tables for Loading
INSERT INTO meta.TableLoadControl (SourceSystemID, SourceTableName, TargetTableName, LoadType, IsActive)
VALUES 
-- Sales System
(1, 'dbo.Customers', 'stg.Customers', 'Incremental', 1),
(1, 'dbo.Products', 'stg.Products', 'Incremental', 1),
(1, 'dbo.SalesOrders', 'stg.SalesOrders', 'Incremental', 1),
(1, 'dbo.OrderDetails', 'stg.OrderDetails', 'Incremental', 1),
-- HR System
(2, 'dbo.Departments', 'stg.Departments', 'Full', 1),
(2, 'dbo.Employees', 'stg.Employees', 'Incremental', 1),
(2, 'dbo.EmployeeAttendance', 'stg.EmployeeAttendance', 'Incremental', 1),
(2, 'dbo.Payroll', 'stg.Payroll', 'Incremental', 1);

-- Create Data Quality Rules
INSERT INTO meta.DataQualityRules (RuleName, TableName, ColumnName, RuleType, RuleDefinition, IsActive)
VALUES 
('Customer Email Format', 'stg.Customers', 'Email', 'Pattern', 'Email must contain @ symbol', 1),
('Product Price Positive', 'stg.Products', 'UnitPrice', 'Range', 'UnitPrice must be > 0', 1),
('Order Date Valid', 'stg.SalesOrders', 'OrderDate', 'Range', 'OrderDate cannot be future date', 1),
('Employee Salary Positive', 'stg.Employees', 'Salary', 'Range', 'Salary must be > 0', 1);