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

