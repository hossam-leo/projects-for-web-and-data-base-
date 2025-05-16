-- Query 1: Text Search - Find products containing a specific keyword in their name or description.
-- Search for products related to "Pro"
SELECT ProductID,ProductName,Description,UnitPrice,(SELECT CategoryName FROM Categories WHERE Categories.CategoryID = Products.CategoryID) AS CategoryName FROM Products WHERE ProductName LIKE "%Pro%" OR Description LIKE "%Pro%";

-- Query 2: Aggregate Function - Calculate the total number of orders and total sales amount for each customer.
SELECT C.CustomerID,C.FirstName,C.LastName,C.Email,COUNT(O.OrderID) AS TotalOrders,SUM(O.TotalAmount) AS TotalSpent FROM Customers C JOIN Orders O ON C.CustomerID = O.CustomerID GROUP BY C.CustomerID, C.FirstName, C.LastName, C.Email ORDER BY TotalSpent DESC;

-- Query 3: Ascending/Descending Order - List all products by their unit price in descending order.
SELECT ProductID,ProductName,UnitPrice,(SELECT CategoryName FROM Categories WHERE Categories.CategoryID = Products.CategoryID) AS CategoryName FROM Products ORDER BY UnitPrice DESC;

-- Query 4: Important Query - Find the top 5 best-selling products based on the quantity sold in OrderItems.
SELECT P.ProductID,P.ProductName,SUM(OI.Quantity) AS TotalQuantitySold,SUM(OI.Subtotal) AS TotalRevenueFromProduct FROM Products P JOIN OrderItems OI ON P.ProductID = OI.ProductID GROUP BY P.ProductID, P.ProductName ORDER BY TotalQuantitySold DESC LIMIT 5;

-- Query 5: Important Query - List customers who have placed orders in the last 30 days, along with their order details.
--
SELECT C.CustomerID,C.FirstName,C.LastName,O.OrderID,O.OrderDate,O.OrderStatus,O.TotalAmount FROM Customers C JOIN Orders O ON C.CustomerID = O.CustomerID WHERE O.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) ORDER BY O.OrderDate DESC, C.LastName ASC;

-- Query 6 : 
SELECT * from addresses;
