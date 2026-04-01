USE [AtelierDB];
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


