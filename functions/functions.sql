USE [AtelierDB];
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


