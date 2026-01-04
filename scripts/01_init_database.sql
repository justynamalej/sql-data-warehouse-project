/*
==================================
Create Database and Schemas
==================================
Script Purpose:
	This script creates the new database 'DWH_CRM_ERP' after checking if it already exists. If the database exists, it's dropped and recreated.
	Additionally, three schemas are created: 'bronze', 'silver' and 'gold'.

WARNING:
	Running this script will drop the entire 'DWH_CRM_ERP' database if it exists.
	All data in the database will be permanently deleted.
	Proceed with caution and ensure you have proper backups before running this script.
*/

USE master;

--Drop and recreate the database 'DWH_CRM_ERP'

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DWH_CRM_ERP')
BEGIN
	ALTER DATABASE DWH_CRM_ERP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DWH_CRM_ERP;
END

--Create the database

CREATE DATABASE DWH_CRM_ERP;

USE DWH_CRM_ERP;

--Create Schemas

GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
