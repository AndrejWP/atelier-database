USE [AtelierDB];
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
