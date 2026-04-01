USE [AtelierDB];
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


