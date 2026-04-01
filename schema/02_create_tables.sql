USE [AtelierDB];
GO

-- ============================================================
-- ЧАСТЬ 2: СОЗДАНИЕ ТАБЛИЦ (13 таблиц)
-- ============================================================

-- 1. Справочник типов клиентов (физ. лицо / юр. лицо)
CREATE TABLE ClientTypes (
    ClientTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL
);
GO

-- 2. Клиенты (покупатели — физ. и юр. лица)
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    CompanyName NVARCHAR(100) NULL,
    Phone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(50) NULL,
    ClientTypeID INT NOT NULL,
    CONSTRAINT FK_Clients_ClientTypes FOREIGN KEY (ClientTypeID) 
        REFERENCES ClientTypes(ClientTypeID)
);
GO

-- 3. Справочник должностей
CREATE TABLE Positions (
    PositionID INT IDENTITY(1,1) PRIMARY KEY,
    PositionName NVARCHAR(50) NOT NULL
);
GO

-- 4. Сотрудники ателье
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(20) NULL,
    PositionID INT NOT NULL,
    CONSTRAINT FK_Employees_Positions FOREIGN KEY (PositionID) 
        REFERENCES Positions(PositionID)
);
GO

-- 5. Справочник услуг ателье (пошив, подгонка, ремонт и т.д.)
CREATE TABLE Services (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL,
    BasePrice MONEY NOT NULL
);
GO

-- 6. Материалы (ткани, фурнитура и т.д.)
CREATE TABLE Materials (
    MaterialID INT IDENTITY(1,1) PRIMARY KEY,
    MaterialName NVARCHAR(100) NOT NULL,
    Color NVARCHAR(30) NULL,
    Unit NVARCHAR(10) NOT NULL,
    CurrentStock DECIMAL(10,2) DEFAULT 0,
    PurchasePrice MONEY NULL
);
GO

-- 7. Поставщики материалов
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100) NULL,
    Phone NVARCHAR(20) NULL
);
GO

-- 8. Поставки (заголовок)
CREATE TABLE SupplyDeliveries (
    DeliveryID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    DeliveryDate DATE DEFAULT GETDATE(),
    TotalAmount MONEY NULL,
    CONSTRAINT FK_Supplies_Suppliers FOREIGN KEY (SupplierID) 
        REFERENCES Suppliers(SupplierID)
);
GO

-- 9. Детали поставок (какие материалы, сколько, по какой цене)
CREATE TABLE SupplyDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    DeliveryID INT NOT NULL,
    MaterialID INT NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL,
    PricePerUnit MONEY NOT NULL,
    CONSTRAINT FK_SupplyDetails_Delivery FOREIGN KEY (DeliveryID) 
        REFERENCES SupplyDeliveries(DeliveryID),
    CONSTRAINT FK_SupplyDetails_Material FOREIGN KEY (MaterialID) 
        REFERENCES Materials(MaterialID)
);
GO

-- 10. Заказы на пошив (заголовок)
CREATE TABLE CustomOrders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATE DEFAULT GETDATE(),
    DueDate DATE NULL,
    IsCompleted BIT DEFAULT 0,
    CONSTRAINT FK_Orders_Clients FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID),
    CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID) 
        REFERENCES Employees(EmployeeID)
);
GO

-- 11. Услуги в заказе (какие услуги входят в конкретный заказ)
CREATE TABLE OrderServices (
    OrderServiceID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ServiceID INT NOT NULL,
    Quantity INT DEFAULT 1,
    AgreedPrice MONEY NOT NULL,
    CONSTRAINT FK_OrderServices_Order FOREIGN KEY (OrderID) 
        REFERENCES CustomOrders(OrderID),
    CONSTRAINT FK_OrderServices_Service FOREIGN KEY (ServiceID) 
        REFERENCES Services(ServiceID)
);
GO

-- 12. Расход материалов на заказ
CREATE TABLE OrderMaterials (
    OrderMaterialID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    MaterialID INT NOT NULL,
    QuantityUsed DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderMaterials_Order FOREIGN KEY (OrderID) 
        REFERENCES CustomOrders(OrderID),
    CONSTRAINT FK_OrderMaterials_Material FOREIGN KEY (MaterialID) 
        REFERENCES Materials(MaterialID)
);
GO

-- 13. Готовая продукция (изделия собственного пошива для продажи)
CREATE TABLE FinishedProducts (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Size NVARCHAR(10) NULL,
    Price MONEY NOT NULL,
    StockQuantity INT DEFAULT 0
);
GO

-- 14. Продажи готовой продукции
CREATE TABLE ProductSales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ClientID INT NULL,
    SaleDate DATE DEFAULT GETDATE(),
    Quantity INT NOT NULL,
    TotalSum MONEY NOT NULL,
    CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductID) 
        REFERENCES FinishedProducts(ProductID),
    CONSTRAINT FK_Sales_Client FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID)
);
GO

