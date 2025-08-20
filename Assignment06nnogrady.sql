--*************************************************************************--
-- Title: Assignment06
-- Author: nnogrady
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,nnogrady,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_nnogrady')
	 Begin 
	  Alter Database [Assignment06DB_nnogrady] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_nnogrady;
	 End
	Create Database Assignment06DB_nnogrady;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_nnogrady;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
/*
Select *
From Categories

SELECT CategoryID, CategoryName
FROM Categories
GO
*/
GO

CREATE or ALTER VIEW vCategories
WITH SCHEMABINDING
AS
SELECT TOP 100000 CategoryID, CategoryName
FROM dbo.Categories
GO

/*SELECT *
FROM Products
GO

SELECT ProductID, ProductName, CategoryID, UnitPrice
From Products
GO
*/

CREATE or ALTER VIEW vProducts
WITH SCHEMABINDING
AS
SELECT TOP 100000 ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products
GO

/*SELECT *
FROM Employees
GO

SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM Employees
GO
*/

CREATE or ALTER VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT TOP 100000 EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees
GO

/*
SELECT *
FROM Inventories

SELECT InventoryID, InventoryDate, EmployeeID, ProductID, COUNT
FROM Inventories
GO
*/

CREATE or ALTER VIEW vInventories
WITH SCHEMABINDING
AS
SELECT TOP 100000 InventoryID, InventoryDate, EmployeeID, ProductID, COUNT
FROM dbo.Inventories
GO

SELECT *
FROM vCategories
GO
SELECT *
FROM vProducts
GO
SELECT *
FROM vEmployees
GO
SELECT *
From vInventories
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;
GO
DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;
GO
DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GO
DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*SELECT * FROM Inventories
SELECT * FROM Products

SELECT Categories.CategoryName, Products.ProductName, Products.UnitPrice
From dbo.Categories Join dbo.Products 
ON Categories.CategoryID = Products.CategoryID
GO
*/

CREATE or ALTER VIEW vProductsByCategories
WITH SCHEMABINDING
AS
SELECT TOP 100000 Categories.CategoryName, Products.ProductName, Products.UnitPrice
From dbo.Categories Join dbo.Products 
ON Categories.CategoryID = Products.CategoryID
ORDER BY CategoryName, ProductName
GO

SELECT *
FROM vProductsByCategories
GO
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/*SELECT * FROM Products
SELECT * FROM Inventories

SELECT Products.ProductName, Inventories.InventoryDate, Inventories.COUNT
FROM Products JOIN Inventories
ON Inventories.ProductID = Products.ProductID
*/


CREATE or ALTER VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING
AS
SELECT TOP 100000 ProductName, Inventories.InventoryDate, Inventories.COUNT
FROM dbo.Products JOIN dbo.Inventories
ON Inventories.ProductID = Products.ProductID
ORDER BY ProductName, InventoryDate, Count

GO
SELECT * from vInventoriesByProductsByDates

GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
SELECT * FROM Inventories
SELECT * FROM Employees
GO

SELECT DISTINCT Inventories.InventoryDate, Employees.EmployeeLastName
FROM Inventories JOIN Employees 
ON Inventories.EmployeeID = Employees.EmployeeID;
GO
*/

CREATE OR ALTER VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING
AS
SELECT DISTINCT TOP 100 Inventories.InventoryDate, Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS Employee
FROM dbo.Inventories JOIN dbo.Employees 
ON Inventories.EmployeeID = Employees.EmployeeID
ORDER BY InventoryDate, Employee

GO
SELECT * FROM vInventoriesByEmployeesByDates
GO
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
SELECT * FROM Categories
SELECT * FROM Products
SELECT * FROM Inventories

GO

SELECT Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.COUNT
FROM Products JOIN Categories
ON Categories.CategoryID = Products.CategoryID
JOIN Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, COUNT

GO
*/

CREATE OR ALTER VIEW vInventoriesByProductsByCategories
WITH SCHEMABINDING
AS
SELECT TOP 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.COUNT
FROM dbo.Products JOIN dbo.Categories
ON Categories.CategoryID = Products.CategoryID
JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, COUNT

GO
SELECT * FROM vInventoriesByProductsByCategories
GO
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
/*
SELECT * FROM Products
SELECT * From Categories
SELECT * FROM Inventories
SELECT * FROM Employees

GO

SELECT Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count, Employees.EmployeeLastName
FROM Categories JOIN Products
ON Categories.CategoryID = Products.CategoryID
JOIN Inventories
ON Products.ProductID = Inventories.ProductID
JOIN Employees
ON Inventories.EmployeeID = Employees.EmployeeID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeLastName 
GO
*/

CREATE or ALTER VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING
AS 
SELECT TOP 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count, 
Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS Employee
FROM dbo.Categories JOIN dbo.Products
ON Categories.CategoryID = Products.CategoryID
JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees
ON Inventories.EmployeeID = Employees.EmployeeID
ORDER BY InventoryDate, CategoryName, ProductName, Employee 

GO

SELECT * FROM vInventoriesByProductsByEmployees

GO
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*SELECT * FROM Products
SELECT * From Categories
SELECT * FROM Inventories
SELECT * FROM Employees

SELECT Categories.CategoryName, Products.ProductName,Inventories.InventoryDate, Inventories.Count, Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS Employee
FROM Products JOIN Categories 
ON Categories.CategoryID = Products.CategoryID
JOIN Inventories 
ON Products.ProductID = Inventories.ProductID
JOIN Employees 
ON Inventories.EmployeeID = Employees.EmployeeID
WHERE Products.ProductID IN (
SELECT ProductID 
FROM Products 
WHERE ProductName IN ('Chang', 'Chai'))
ORDER BY InventoryDate, CategoryName, ProductName 
GO
*/

CREATE OR ALTER VIEW vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING
AS
SELECT TOP 100000 Categories.CategoryName, Products.ProductName,Inventories.InventoryDate, Inventories.Count, Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS Employee
FROM dbo.Products JOIN dbo.Categories 
ON Categories.CategoryID = Products.CategoryID
JOIN dbo.Inventories 
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees 
ON Inventories.EmployeeID = Employees.EmployeeID
WHERE Products.ProductID IN (
SELECT ProductID 
FROM dbo.Products 
WHERE ProductName IN ('Chang', 'Chai'))
ORDER BY InventoryDate, CategoryName, ProductName 

GO

Select * FROM vInventoriesForChaiAndChangByEmployees
GO
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
SELECT * FROM Employees


SELECT Sup.EmployeeFirstName + ' ' + Sup.EmployeeLastName AS Supervisor,Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName AS Employee
FROM Employees AS Emp
LEFT JOIN Employees AS Sup ON Emp.ManagerID = Sup.EmployeeID
ORDER BY Supervisor, Employee;
GO
*/

CREATE or ALTER VIEW vEmployeesByManager
WITH SCHEMABINDING
AS
SELECT TOP 100000 Sup.EmployeeFirstName + ' ' + Sup.EmployeeLastName AS Supervisor,Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName AS Employee
FROM dbo.Employees AS Emp
LEFT JOIN dbo.Employees AS Sup ON Emp.ManagerID = Sup.EmployeeID
ORDER BY Supervisor, Employee;

GO

Select * From vEmployeesByManager
GO
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/*
SELECT Categories.CategoryID, Categories.CategoryName, 
Products.ProductID, Products.ProductName,Products.UnitPrice, 
Inventories.InventoryID, Inventories.InventoryDate, Inventories.Count, Inventories.[Count],
Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS Employee,    Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName AS Manager
FROM dbo.Products JOIN dbo.Categories 
ON Categories.CategoryID = Products.CategoryID
JOIN dbo.Inventories 
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees 
ON Inventories.EmployeeID = Employees.EmployeeID
LEFT JOIN dbo.Employees AS Manager ON Employees.ManagerID = Manager.EmployeeID
ORDER BY CategoryName, ProductName, InventoryID, Employee

Go 
*/

CREATE OR ALTER VIEW vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING
AS 
SELECT TOP 100000 Categories.CategoryID, Categories.CategoryName, 
Products.ProductID, Products.ProductName,Products.UnitPrice, 
Inventories.InventoryID, Inventories.InventoryDate, Inventories.Count,
Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS Employee,    Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName AS Manager
FROM dbo.Products JOIN dbo.Categories 
ON Categories.CategoryID = Products.CategoryID
JOIN dbo.Inventories 
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees 
ON Inventories.EmployeeID = Employees.EmployeeID
LEFT JOIN dbo.Employees AS Manager ON Employees.ManagerID = Manager.EmployeeID
ORDER BY CategoryName, ProductName, InventoryID, Employee

GO

Select * FROM vInventoriesByProductsByCategoriesByEmployees

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/