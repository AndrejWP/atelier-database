USE [AtelierDB];
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


