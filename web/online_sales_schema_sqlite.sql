-- SQL Schema for Online Sales Database (Normalized)
-- Database: SQLite

PRAGMA foreign_keys = ON;

-- Table: Customers
DROP TABLE IF EXISTS `Customers`;
CREATE TABLE `Customers` (
    `CustomerID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `FirstName` TEXT NOT NULL,
    `LastName` TEXT NOT NULL,
    `Email` TEXT NOT NULL UNIQUE,
    `PasswordHash` TEXT NOT NULL,
    `PhoneNumber` TEXT,
    `RegistrationDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `LastLoginDate` DATETIME NULL
);

-- Table: Locations
DROP TABLE IF EXISTS `Locations`;
CREATE TABLE `Locations` (
    `PostalCode` TEXT PRIMARY KEY,
    `City` TEXT NOT NULL,
    `State` TEXT,
    `Country` TEXT NOT NULL
);

-- Table: Addresses
DROP TABLE IF EXISTS `Addresses`;
CREATE TABLE `Addresses` (
    `AddressID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `CustomerID` INTEGER NOT NULL,
    `AddressType` TEXT NOT NULL, -- e.g., Shipping, Billing
    `StreetAddress` TEXT NOT NULL,
    `PostalCode` TEXT NOT NULL,
    FOREIGN KEY (`CustomerID`) REFERENCES `Customers`(`CustomerID`) ON DELETE CASCADE,
    FOREIGN KEY (`PostalCode`) REFERENCES `Locations`(`PostalCode`) ON DELETE RESTRICT
);

-- Table: Categories
DROP TABLE IF EXISTS `Categories`;
CREATE TABLE `Categories` (
    `CategoryID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `CategoryName` TEXT NOT NULL UNIQUE,
    `Description` TEXT
);

-- Table: Products
DROP TABLE IF EXISTS `Products`;
CREATE TABLE `Products` (
    `ProductID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `ProductName` TEXT NOT NULL,
    `Description` TEXT,
    `CategoryID` INTEGER,
    `UnitPrice` REAL NOT NULL, -- Using REAL for decimal values
    `ImageURL` TEXT,
    `DateAdded` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `LastUpdated` DATETIME NULL, -- ON UPDATE CURRENT_TIMESTAMP removed
    FOREIGN KEY (`CategoryID`) REFERENCES `Categories`(`CategoryID`) ON DELETE SET NULL
);

-- Table: InventoryStock
DROP TABLE IF EXISTS `InventoryStock`;
CREATE TABLE `InventoryStock` (
    `StockID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `ProductID` INTEGER NOT NULL UNIQUE,
    `QuantityInStock` INTEGER NOT NULL DEFAULT 0,
    `ReorderLevel` INTEGER DEFAULT 10,
    `LastStockUpdate` DATETIME NULL, -- ON UPDATE CURRENT_TIMESTAMP removed
    FOREIGN KEY (`ProductID`) REFERENCES `Products`(`ProductID`) ON DELETE CASCADE
);

-- Table: Orders
DROP TABLE IF EXISTS `Orders`;
CREATE TABLE `Orders` (
    `OrderID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `CustomerID` INTEGER NOT NULL,
    `OrderDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `OrderStatus` TEXT NOT NULL, -- e.g., Pending, Processing, Shipped, Delivered, Cancelled
    `ShippingAddressID` INTEGER NOT NULL,
    `BillingAddressID` INTEGER NOT NULL,
    `TotalAmount` REAL NOT NULL, -- Denormalized: Sum of OrderItems subtotals
    `PaymentMethod` TEXT,
    `PaymentStatus` TEXT NOT NULL, -- e.g., Paid, Pending, Failed
    FOREIGN KEY (`CustomerID`) REFERENCES `Customers`(`CustomerID`) ON DELETE RESTRICT,
    FOREIGN KEY (`ShippingAddressID`) REFERENCES `Addresses`(`AddressID`) ON DELETE RESTRICT,
    FOREIGN KEY (`BillingAddressID`) REFERENCES `Addresses`(`AddressID`) ON DELETE RESTRICT
);

-- Table: OrderItems
DROP TABLE IF EXISTS `OrderItems`;
CREATE TABLE `OrderItems` (
    `OrderItemID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `OrderID` INTEGER NOT NULL,
    `ProductID` INTEGER NOT NULL,
    `Quantity` INTEGER NOT NULL,
    `UnitPriceAtPurchase` REAL NOT NULL,
    `Subtotal` REAL NOT NULL, -- Denormalized: Quantity * UnitPriceAtPurchase
    FOREIGN KEY (`OrderID`) REFERENCES `Orders`(`OrderID`) ON DELETE CASCADE,
    FOREIGN KEY (`ProductID`) REFERENCES `Products`(`ProductID`) ON DELETE RESTRICT,
    UNIQUE (`OrderID`, `ProductID`)
);

-- Table: ShoppingCarts
DROP TABLE IF EXISTS `ShoppingCarts`;
CREATE TABLE `ShoppingCarts` (
    `CartID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `CustomerID` INTEGER NOT NULL UNIQUE,
    `DateCreated` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `LastUpdated` DATETIME NULL, -- ON UPDATE CURRENT_TIMESTAMP removed
    FOREIGN KEY (`CustomerID`) REFERENCES `Customers`(`CustomerID`) ON DELETE CASCADE
);

-- Table: CartItems
DROP TABLE IF EXISTS `CartItems`;
CREATE TABLE `CartItems` (
    `CartItemID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `CartID` INTEGER NOT NULL,
    `ProductID` INTEGER NOT NULL,
    `Quantity` INTEGER NOT NULL,
    `DateAdded` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`CartID`) REFERENCES `ShoppingCarts`(`CartID`) ON DELETE CASCADE,
    FOREIGN KEY (`ProductID`) REFERENCES `Products`(`ProductID`) ON DELETE CASCADE,
    UNIQUE (`CartID`, `ProductID`)
);

-- Table: Administrators (Optional for SQLite, as auth is usually app-level)
DROP TABLE IF EXISTS `Administrators`;
CREATE TABLE `Administrators` (
    `AdminID` INTEGER PRIMARY KEY AUTOINCREMENT,
    `Username` TEXT NOT NULL UNIQUE,
    `PasswordHash` TEXT NOT NULL,
    `Email` TEXT NOT NULL UNIQUE,
    `Role` TEXT NOT NULL, -- e.g., SuperAdmin, OrderManager, ProductManager
    `LastLoginDate` DATETIME NULL
);

-- User Permissions are handled at the file system level for SQLite or within the application.
-- The previous MySQL user and grant statements are not applicable here.

