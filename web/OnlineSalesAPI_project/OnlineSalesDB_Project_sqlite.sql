-- SQLite version of Categories and Products tables from OnlineSalesDB_Project.sql

PRAGMA foreign_keys = ON;

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
    `UnitPrice` REAL NOT NULL,
    `ImageURL` TEXT,
    `DateAdded` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `LastUpdated` DATETIME, -- ON UPDATE CURRENT_TIMESTAMP removed, handle in application logic if needed
    FOREIGN KEY (`CategoryID`) REFERENCES `Categories`(`CategoryID`) ON DELETE SET NULL
);

-- Populate Categories
INSERT INTO `Categories` (`CategoryName`, `Description`) VALUES
("Electronics", "Gadgets, devices, and accessories"),
("Books", "Fiction, non-fiction, educational"),
("Clothing", "Apparel for men, women, and children"),
("Home & Kitchen", "Appliances, decor, and kitchenware"),
("Sports & Outdoors", "Equipment for various sports and outdoor activities");

-- Populate Products (linking to Categories)
-- Assuming CategoryIDs will be 1-5 based on the above inserts
INSERT INTO `Products` (`ProductName`, `Description`, `CategoryID`, `UnitPrice`, `ImageURL`, `DateAdded`) VALUES
("Laptop Pro 15", "High-performance laptop for professionals", 1, 1299.99, "http://example.com/laptop_pro.jpg", datetime('now')),
("The Great Novel", "A captivating story of adventure", 2, 19.99, "http://example.com/great_novel.jpg", datetime('now')),
("Men's Cotton T-Shirt", "Comfortable and stylish t-shirt", 3, 25.50, "http://example.com/mens_tshirt.jpg", datetime('now')),
("Smart Coffee Maker", "Brew coffee remotely with your phone", 4, 89.95, "http://example.com/coffee_maker.jpg", datetime('now')),
("Yoga Mat Premium", "Non-slip, eco-friendly yoga mat", 5, 35.00, "http://example.com/yoga_mat.jpg", datetime('now')),
("Wireless Headphones", "Noise-cancelling over-ear headphones", 1, 199.99, "http://example.com/headphones.jpg", datetime('now')),
("History of the World", "Comprehensive historical account", 2, 29.95, "http://example.com/history_book.jpg", datetime('now'));

-- Example of a product without a category initially, or if category is deleted
INSERT INTO `Products` (`ProductName`, `Description`, `CategoryID`, `UnitPrice`, `ImageURL`, `DateAdded`) VALUES
("Mystery Gadget", "A cool new gadget, category pending", NULL, 75.00, "http://example.com/mystery_gadget.jpg", datetime('now'));

