-- ============================================================
-- ПОЛНЫЙ СКРИПТ БАЗЫ ДАННЫХ: AtelierDB
-- Тема 36: Информационная поддержка работы ателье
-- СУБД: Microsoft SQL Server 2014+
-- ============================================================

-- ============================================================
-- ЧАСТЬ 1: СОЗДАНИЕ БАЗЫ ДАННЫХ
-- ============================================================
USE [master];
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'AtelierDB')
BEGIN
    ALTER DATABASE [AtelierDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [AtelierDB];
END
GO

CREATE DATABASE [AtelierDB];
GO

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

-- ============================================================
-- ЧАСТЬ 3: ЗАПОЛНЕНИЕ ДАННЫМИ
-- ============================================================

-- Типы клиентов
INSERT INTO ClientTypes (TypeName) VALUES 
(N'Физическое лицо'),
(N'Юридическое лицо');
GO

-- Клиенты (8 записей: физ. и юр. лица)
SET IDENTITY_INSERT Clients ON;
INSERT INTO Clients (ClientID, FirstName, LastName, CompanyName, Phone, Email, ClientTypeID) VALUES
(1, N'Анна',    N'Петрова',   NULL,                 N'8-901-111-11-11', N'anna@mail.ru',    1),
(2, N'Иван',    N'Сидоров',   NULL,                 N'8-902-222-22-22', N'ivan@mail.ru',    1),
(3, N'Мария',   N'Козлова',   NULL,                 N'8-903-333-33-33', N'maria@mail.ru',   1),
(4, NULL,        NULL,         N'ООО "Стиль"',       N'8-495-100-10-10', N'style@corp.ru',   2),
(5, NULL,        NULL,         N'ООО "Театр Мод"',   N'8-495-200-20-20', N'teatr@corp.ru',   2),
(6, N'Елена',   N'Новикова',  NULL,                 N'8-904-444-44-44', N'elena@mail.ru',   1),
(7, N'Дмитрий', N'Волков',    NULL,                 N'8-905-555-55-55', N'dmitry@mail.ru',  1),
(8, NULL,        NULL,         N'ИП Кузнецов А.В.',  N'8-495-300-30-30', N'kuznecov@ip.ru',  2);
SET IDENTITY_INSERT Clients OFF;
GO

-- Должности
INSERT INTO Positions (PositionName) VALUES
(N'Портной'),
(N'Закройщик'),
(N'Дизайнер'),
(N'Менеджер'),
(N'Швея');
GO

-- Сотрудники (6 записей)
SET IDENTITY_INSERT Employees ON;
INSERT INTO Employees (EmployeeID, FirstName, LastName, Phone, PositionID) VALUES
(1, N'Ольга',    N'Иванова',    N'8-910-001-00-01', 1),
(2, N'Светлана', N'Смирнова',   N'8-910-002-00-02', 2),
(3, N'Татьяна',  N'Федорова',   N'8-910-003-00-03', 3),
(4, N'Алексей',  N'Морозов',    N'8-910-004-00-04', 4),
(5, N'Наталья',  N'Попова',     N'8-910-005-00-05', 5),
(6, N'Екатерина',N'Лебедева',   N'8-910-006-00-06', 1);
SET IDENTITY_INSERT Employees OFF;
GO

-- Услуги ателье (7 записей)
INSERT INTO Services (ServiceName, BasePrice) VALUES
(N'Пошив платья',         5000.00),
(N'Пошив костюма',        8000.00),
(N'Пошив юбки',           2500.00),
(N'Подгонка по фигуре',   1500.00),
(N'Ремонт одежды',        800.00),
(N'Пошив пальто',         12000.00),
(N'Пошив рубашки',        3000.00);
GO

-- Материалы (8 записей)
SET IDENTITY_INSERT Materials ON;
INSERT INTO Materials (MaterialID, MaterialName, Color, Unit, CurrentStock, PurchasePrice) VALUES
(1, N'Шерсть',      N'Черный',   N'м',   120.00, 900.00),
(2, N'Хлопок',      N'Белый',    N'м',   200.00, 400.00),
(3, N'Шёлк',        N'Красный',  N'м',   45.00,  1500.00),
(4, N'Лён',         N'Бежевый',  N'м',   80.00,  600.00),
(5, N'Подкладка',   N'Серый',    N'м',   150.00, 200.00),
(6, N'Пуговицы',    NULL,        N'шт',  500.00, 15.00),
(7, N'Молния',      NULL,        N'шт',  300.00, 50.00),
(8, N'Нитки',       N'Разные',   N'кат', 100.00, 80.00);
SET IDENTITY_INSERT Materials OFF;
GO

-- Поставщики (4 записи)
SET IDENTITY_INSERT Suppliers ON;
INSERT INTO Suppliers (SupplierID, CompanyName, ContactPerson, Phone) VALUES
(1, N'ООО "ТканиОпт"',      N'Сергеев П.А.',  N'8-495-700-70-01'),
(2, N'ООО "Фурнитура+"',    N'Белова Т.И.',   N'8-495-700-70-02'),
(3, N'ИП Ткачёв',           N'Ткачёв А.М.',   N'8-495-700-70-03'),
(4, N'ООО "ТекстильПро"',   N'Орлова Н.С.',   N'8-495-700-70-04');
SET IDENTITY_INSERT Suppliers OFF;
GO

-- Поставки (5 записей)
SET IDENTITY_INSERT SupplyDeliveries ON;
INSERT INTO SupplyDeliveries (DeliveryID, SupplierID, DeliveryDate, TotalAmount) VALUES
(1, 1, '2025-09-01', 45000.00),
(2, 2, '2025-09-15', 12000.00),
(3, 3, '2025-10-01', 30000.00),
(4, 1, '2025-10-20', 36000.00),
(5, 4, '2025-11-05', 20000.00);
SET IDENTITY_INSERT SupplyDeliveries OFF;
GO

-- Детали поставок (триггер trg_AddStock пока не создан, вставляем без него)
-- Позже при создании триггера он будет работать на новые поставки
INSERT INTO SupplyDetails (DeliveryID, MaterialID, Quantity, PricePerUnit) VALUES
(1, 1, 50.00, 900.00),
(1, 2, 80.00, 400.00),
(2, 6, 200.00, 15.00),
(2, 7, 100.00, 50.00),
(3, 3, 20.00, 1500.00),
(4, 1, 40.00, 900.00),
(4, 4, 30.00, 600.00),
(5, 5, 100.00, 200.00);
GO

-- Заказы на пошив (8 записей)
SET IDENTITY_INSERT CustomOrders ON;
INSERT INTO CustomOrders (OrderID, ClientID, EmployeeID, OrderDate, DueDate, IsCompleted) VALUES
(1, 1, 1, '2025-09-10', '2025-09-25', 1),
(2, 2, 2, '2025-09-15', '2025-10-01', 1),
(3, 4, 1, '2025-10-01', '2025-10-20', 1),
(4, 3, 3, '2025-10-10', '2025-10-30', 1),
(5, 5, 2, '2025-11-01', '2025-11-20', 0),
(6, 6, 6, '2025-11-10', '2025-11-30', 0),
(7, 1, 1, '2025-11-15', '2025-12-05', 0),
(8, 7, 3, '2025-11-20', '2025-12-10', 0);
SET IDENTITY_INSERT CustomOrders OFF;
GO

-- Услуги в заказах
INSERT INTO OrderServices (OrderID, ServiceID, Quantity, AgreedPrice) VALUES
(1, 1, 1, 5000.00),   -- заказ 1: пошив платья
(2, 2, 1, 8500.00),   -- заказ 2: пошив костюма
(3, 2, 3, 24000.00),  -- заказ 3: 3 костюма для юр.лица
(4, 3, 1, 2500.00),   -- заказ 4: пошив юбки
(4, 4, 1, 1500.00),   -- заказ 4: + подгонка
(5, 6, 2, 24000.00),  -- заказ 5: 2 пальто
(6, 1, 1, 5500.00),   -- заказ 6: пошив платья
(7, 7, 2, 6000.00),   -- заказ 7: 2 рубашки
(8, 1, 1, 5000.00);   -- заказ 8: пошив платья
GO

-- Расход материалов на заказы
INSERT INTO OrderMaterials (OrderID, MaterialID, QuantityUsed) VALUES
(1, 3, 3.00),   -- заказ 1: шёлк на платье
(1, 8, 2.00),   -- заказ 1: нитки
(2, 1, 4.00),   -- заказ 2: шерсть на костюм
(2, 5, 2.00),   -- заказ 2: подкладка
(2, 6, 8.00),   -- заказ 2: пуговицы
(3, 1, 12.00),  -- заказ 3: шерсть на 3 костюма
(3, 5, 6.00),   -- заказ 3: подкладка
(4, 2, 2.00),   -- заказ 4: хлопок на юбку
(5, 1, 8.00),   -- заказ 5: шерсть на 2 пальто
(5, 5, 4.00),   -- заказ 5: подкладка
(6, 3, 3.50),   -- заказ 6: шёлк
(7, 2, 4.00),   -- заказ 7: хлопок на 2 рубашки
(8, 3, 3.00);   -- заказ 8: шёлк
GO

-- Готовая продукция (6 записей)
INSERT INTO FinishedProducts (ProductName, Size, Price, StockQuantity) VALUES
(N'Платье летнее',      N'S',  4500.00, 5),
(N'Платье летнее',      N'M',  4500.00, 3),
(N'Юбка офисная',       N'M',  2200.00, 7),
(N'Костюм мужской',     N'L',  9500.00, 2),
(N'Рубашка мужская',    N'M',  2800.00, 10),
(N'Пальто женское',     N'S',  11000.00, 1);
GO

-- Продажи готовой продукции (6 записей)
INSERT INTO ProductSales (ProductID, ClientID, SaleDate, Quantity, TotalSum) VALUES
(1, 3, '2025-09-20', 1, 4500.00),
(3, 1, '2025-09-25', 2, 4400.00),
(4, 4, '2025-10-05', 1, 9500.00),
(5, 2, '2025-10-10', 3, 8400.00),
(2, 6, '2025-11-01', 1, 4500.00),
(6, 5, '2025-11-10', 1, 11000.00);
GO


-- ============================================================
-- ЧАСТЬ 4: ПРЕДСТАВЛЕНИЯ (3 штуки, одно редактируемое)
-- ============================================================

-- View 1: Остатки материалов на складе (удобный просмотр для менеджера)
CREATE VIEW v_MaterialStock AS
SELECT MaterialName, Color, CurrentStock, Unit, PurchasePrice
FROM Materials;
GO

-- View 2: Список сотрудников с названиями должностей (вместо ID)
CREATE VIEW v_EmployeeList AS
SELECT 
    E.EmployeeID,
    E.FirstName, 
    E.LastName, 
    E.Phone, 
    P.PositionName
FROM Employees E
JOIN Positions P ON E.PositionID = P.PositionID;
GO

-- View 3: Редактируемое представление для работы с клиентами
-- Через него можно INSERT, UPDATE, DELETE
CREATE VIEW v_ClientsEditable AS
SELECT ClientID, FirstName, LastName, CompanyName, Phone, Email, ClientTypeID
FROM Clients;
GO


-- ============================================================
-- ЧАСТЬ 5: ФУНКЦИИ (2 скалярные + 1 табличная)
-- ============================================================

-- Функция 1 (Скалярная): Количество заказов у конкретного клиента
CREATE FUNCTION dbo.CountClientOrders (@ClientID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM CustomOrders WHERE ClientID = @ClientID;
    RETURN @Count;
END;
GO

-- Функция 2 (Скалярная): Общая сумма всех продаж готовой продукции
CREATE FUNCTION dbo.GetTotalSalesSum()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Sum DECIMAL(10,2);
    SELECT @Sum = SUM(TotalSum) FROM ProductSales;
    RETURN ISNULL(@Sum, 0);
END;
GO

-- Функция 3 (Табличная): Материалы с низким остатком (менее порогового значения)
-- Параметр @Threshold позволяет задать порог (по умолчанию используем 10)
CREATE FUNCTION dbo.GetLowStockMaterials(@Threshold DECIMAL(10,2) = 10)
RETURNS TABLE
AS
RETURN
(
    SELECT MaterialID, MaterialName, Color, CurrentStock, Unit
    FROM Materials 
    WHERE CurrentStock < @Threshold
);
GO


-- ============================================================
-- ЧАСТЬ 6: ХРАНИМЫЕ ПРОЦЕДУРЫ (3 штуки)
-- ============================================================

-- Процедура 1: Оформление нового заказа
-- Дата заказа ставится автоматически, статус = не выполнен
CREATE PROCEDURE dbo.CreateNewOrder
    @ClientID INT,
    @EmployeeID INT,
    @DueDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Проверяем, существует ли клиент
    IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = @ClientID)
    BEGIN
        RAISERROR(N'Клиент с таким ID не найден!', 16, 1);
        RETURN;
    END

    -- Проверяем, существует ли сотрудник
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR(N'Сотрудник с таким ID не найден!', 16, 1);
        RETURN;
    END

    INSERT INTO CustomOrders (ClientID, EmployeeID, OrderDate, DueDate, IsCompleted)
    VALUES (@ClientID, @EmployeeID, GETDATE(), @DueDate, 0);

    PRINT N'Заказ успешно создан. ID = ' + CAST(SCOPE_IDENTITY() AS NVARCHAR(10));
END;
GO

-- Процедура 2: Обновление закупочной цены материала
CREATE PROCEDURE dbo.UpdateMaterialPrice
    @MaterialID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM Materials WHERE MaterialID = @MaterialID)
    BEGIN
        RAISERROR(N'Материал с таким ID не найден!', 16, 1);
        RETURN;
    END

    IF @NewPrice <= 0
    BEGIN
        RAISERROR(N'Цена должна быть положительной!', 16, 1);
        RETURN;
    END

    UPDATE Materials 
    SET PurchasePrice = @NewPrice 
    WHERE MaterialID = @MaterialID;

    PRINT N'Цена материала обновлена.';
END;
GO

-- Процедура 3: Безопасное удаление клиента (нельзя удалить, если есть заказы)
CREATE PROCEDURE dbo.DeleteClientSafe
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = @ClientID)
    BEGIN
        RAISERROR(N'Клиент с таким ID не найден!', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM CustomOrders WHERE ClientID = @ClientID)
    BEGIN
        RAISERROR(N'Нельзя удалить клиента — у него есть заказы!', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ProductSales WHERE ClientID = @ClientID)
    BEGIN
        RAISERROR(N'Нельзя удалить клиента — у него есть покупки!', 16, 1);
        RETURN;
    END

    DELETE FROM Clients WHERE ClientID = @ClientID;
    PRINT N'Клиент удалён.';
END;
GO


-- ============================================================
-- ЧАСТЬ 7: ТРИГГЕРЫ (3 штуки)
-- ============================================================

-- Триггер 1 (AFTER INSERT): При добавлении деталей поставки — 
-- автоматически УВЕЛИЧИВАЕТ остаток материала на складе
CREATE TRIGGER trg_AddStock
ON SupplyDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE M
    SET M.CurrentStock = M.CurrentStock + I.Quantity
    FROM Materials M
    JOIN inserted I ON M.MaterialID = I.MaterialID;
END;
GO

-- Триггер 2 (AFTER INSERT): При расходе материала на заказ —
-- автоматически УМЕНЬШАЕТ остаток на складе
-- ИСПРАВЛЕНО: добавлена проверка на отрицательный остаток
CREATE TRIGGER trg_ReduceStock
ON OrderMaterials
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Проверяем, хватает ли материала на складе
    IF EXISTS (
        SELECT 1 
        FROM Materials M 
        JOIN inserted I ON M.MaterialID = I.MaterialID 
        WHERE M.CurrentStock < I.QuantityUsed
    )
    BEGIN
        RAISERROR(N'Недостаточно материала на складе! Операция отменена.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE M
    SET M.CurrentStock = M.CurrentStock - I.QuantityUsed
    FROM Materials M
    JOIN inserted I ON M.MaterialID = I.MaterialID;
END;
GO

-- Триггер 3 (INSTEAD OF DELETE): Запрет удаления должности, 
-- если на ней есть сотрудники
CREATE TRIGGER trg_PreventPositionDelete
ON Positions
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 FROM Employees 
        WHERE PositionID IN (SELECT PositionID FROM deleted)
    )
    BEGIN
        RAISERROR(N'Нельзя удалить должность — на ней работают сотрудники!', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Positions 
        WHERE PositionID IN (SELECT PositionID FROM deleted);
    END
END;
GO


-- ============================================================
-- ЧАСТЬ 8: ДЕМОНСТРАЦИОННЫЕ ЗАПРОСЫ (для защиты)
-- ============================================================

PRINT N'';
PRINT N'========================================';
PRINT N'  ДЕМОНСТРАЦИЯ РАБОТЫ ОБЪЕКТОВ БД';
PRINT N'========================================';
PRINT N'';

-- ---- ПРЕДСТАВЛЕНИЯ ----
PRINT N'--- View 1: Остатки материалов на складе ---';
SELECT * FROM v_MaterialStock;

PRINT N'--- View 2: Список сотрудников ---';
SELECT * FROM v_EmployeeList;

PRINT N'--- View 3: Клиенты (редактируемое представление) ---';
SELECT * FROM v_ClientsEditable;

-- Демонстрация INSERT через редактируемое представление
PRINT N'--- Добавление клиента через v_ClientsEditable ---';
INSERT INTO v_ClientsEditable (FirstName, LastName, Phone, ClientTypeID)
VALUES (N'Тест', N'Тестов', N'8-999-000-00-00', 1);
SELECT TOP 1 * FROM v_ClientsEditable ORDER BY ClientID DESC;

-- Удаляем тестового клиента
DELETE FROM v_ClientsEditable WHERE FirstName = N'Тест' AND LastName = N'Тестов';
GO


-- ---- ФУНКЦИИ ----
PRINT N'--- Функция 1: Количество заказов клиента ID=1 ---';
SELECT dbo.CountClientOrders(1) AS [Заказов у клиента 1];

PRINT N'--- Функция 2: Общая выручка от продаж ---';
SELECT dbo.GetTotalSalesSum() AS [Общая выручка];

PRINT N'--- Функция 3: Материалы с остатком менее 50 ---';
SELECT * FROM dbo.GetLowStockMaterials(50);
GO


-- ---- ХРАНИМЫЕ ПРОЦЕДУРЫ ----
PRINT N'--- Процедура 1: Создание нового заказа ---';
EXEC dbo.CreateNewOrder @ClientID = 6, @EmployeeID = 1, @DueDate = '2026-01-30';
SELECT TOP 1 * FROM CustomOrders ORDER BY OrderID DESC;

PRINT N'--- Процедура 2: Обновление цены материала ID=3 ---';
SELECT MaterialName, PurchasePrice AS [Было] FROM Materials WHERE MaterialID = 3;
EXEC dbo.UpdateMaterialPrice @MaterialID = 3, @NewPrice = 1600.00;
SELECT MaterialName, PurchasePrice AS [Стало] FROM Materials WHERE MaterialID = 3;

PRINT N'--- Процедура 3: Попытка удалить клиента с заказами ---';
EXEC dbo.DeleteClientSafe @ClientID = 1;
GO


-- ---- ТРИГГЕРЫ ----
PRINT N'--- Триггер 1: Поставка материала (автоувеличение склада) ---';
SELECT MaterialName, CurrentStock AS [До поставки] FROM Materials WHERE MaterialID = 2;
INSERT INTO SupplyDetails (DeliveryID, MaterialID, Quantity, PricePerUnit) 
VALUES (1, 2, 30.00, 400.00);
SELECT MaterialName, CurrentStock AS [После поставки (+30)] FROM Materials WHERE MaterialID = 2;

PRINT N'--- Триггер 2: Расход материала (автоуменьшение склада) ---';
DECLARE @LastOrderID INT;
SELECT @LastOrderID = MAX(OrderID) FROM CustomOrders;
SELECT MaterialName, CurrentStock AS [До расхода] FROM Materials WHERE MaterialID = 2;
INSERT INTO OrderMaterials (OrderID, MaterialID, QuantityUsed) 
VALUES (@LastOrderID, 2, 5.00);
SELECT MaterialName, CurrentStock AS [После расхода (-5)] FROM Materials WHERE MaterialID = 2;
GO

PRINT N'--- Триггер 3: Попытка удалить должность с сотрудниками ---';
DELETE FROM Positions WHERE PositionID = 1;
-- Ожидаемый результат: ошибка "Нельзя удалить должность"
GO


-- ============================================================
-- ЧАСТЬ 9: ПРИМЕРЫ ПОЛЕЗНЫХ ЗАПРОСОВ (для раздела 8 отчёта)
-- ============================================================

-- Пример 1: Какие заказы ещё не выполнены, с именами клиентов
PRINT N'--- Незавершённые заказы ---';
SELECT 
    O.OrderID,
    ISNULL(C.FirstName + N' ' + C.LastName, C.CompanyName) AS [Клиент],
    E.FirstName + N' ' + E.LastName AS [Исполнитель],
    O.OrderDate AS [Дата заказа],
    O.DueDate AS [Срок сдачи]
FROM CustomOrders O
JOIN Clients C ON O.ClientID = C.ClientID
JOIN Employees E ON O.EmployeeID = E.EmployeeID
WHERE O.IsCompleted = 0
ORDER BY O.DueDate;
GO

-- Пример 2: Выручка по услугам (какие услуги приносят больше денег)
PRINT N'--- Выручка по видам услуг ---';
SELECT 
    S.ServiceName AS [Услуга],
    SUM(OS.Quantity) AS [Кол-во],
    SUM(OS.AgreedPrice) AS [Выручка]
FROM OrderServices OS
JOIN Services S ON OS.ServiceID = S.ServiceID
GROUP BY S.ServiceName
ORDER BY [Выручка] DESC;
GO

-- Пример 3: Топ-клиенты по количеству заказов
PRINT N'--- Топ клиенты ---';
SELECT 
    ISNULL(C.FirstName + N' ' + C.LastName, C.CompanyName) AS [Клиент],
    CT.TypeName AS [Тип],
    dbo.CountClientOrders(C.ClientID) AS [Кол-во заказов]
FROM Clients C
JOIN ClientTypes CT ON C.ClientTypeID = CT.ClientTypeID
ORDER BY [Кол-во заказов] DESC;
GO

-- Пример 4: Какие материалы заканчиваются (менее 50 единиц)
PRINT N'--- Материалы с низким остатком ---';
SELECT * FROM dbo.GetLowStockMaterials(50);
GO

PRINT N'========================================';
PRINT N'  СКРИПТ ЗАВЕРШЁН УСПЕШНО';
PRINT N'========================================';
GO
