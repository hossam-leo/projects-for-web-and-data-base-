-- Disable foreign key checks temporarily to avoid order issues during creation
SET FOREIGN_KEY_CHECKS=0;

-- Table: Customers
DROP TABLE IF EXISTS `Customers`;
CREATE TABLE `Customers` (
    `CustomerID` INT AUTO_INCREMENT PRIMARY KEY,
    `FirstName` VARCHAR(100) NOT NULL,
    `LastName` VARCHAR(100) NOT NULL,
    `Email` VARCHAR(255) NOT NULL UNIQUE,
    `PasswordHash` VARCHAR(255) NOT NULL,
    `PhoneNumber` VARCHAR(20),
    `RegistrationDate` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `LastLoginDate` TIMESTAMP NULL
);

-- Table: Locations
DROP TABLE IF EXISTS `Locations`;
CREATE TABLE `Locations` (
    `PostalCode` VARCHAR(20) PRIMARY KEY,
    `City` VARCHAR(100) NOT NULL,
    `State` VARCHAR(100),
    `Country` VARCHAR(100) NOT NULL
);

-- Table: Addresses
DROP TABLE IF EXISTS `Addresses`;
CREATE TABLE `Addresses` (
    `AddressID` INT AUTO_INCREMENT PRIMARY KEY,
    `CustomerID` INT NOT NULL,
    `AddressType` VARCHAR(50) NOT NULL COMMENT 'e.g., Shipping, Billing',
    `StreetAddress` VARCHAR(255) NOT NULL,
    `PostalCode` VARCHAR(20) NOT NULL,
    FOREIGN KEY (`CustomerID`) REFERENCES `Customers`(`CustomerID`) ON DELETE CASCADE,
    FOREIGN KEY (`PostalCode`) REFERENCES `Locations`(`PostalCode`) ON DELETE RESTRICT
);

-- Table: Categories
DROP TABLE IF EXISTS `Categories`;
CREATE TABLE `Categories` (
    `CategoryID` INT AUTO_INCREMENT PRIMARY KEY,
    `CategoryName` VARCHAR(100) NOT NULL UNIQUE,
    `Description` TEXT
);

-- Table: Products
DROP TABLE IF EXISTS `Products`;
CREATE TABLE `Products` (
    `ProductID` INT AUTO_INCREMENT PRIMARY KEY,
    `ProductName` VARCHAR(255) NOT NULL,
    `Description` TEXT,
    `CategoryID` INT,
    `UnitPrice` DECIMAL(10, 2) NOT NULL,
    `ImageURL` VARCHAR(2048),
    `DateAdded` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `LastUpdated` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`CategoryID`) REFERENCES `Categories`(`CategoryID`) ON DELETE SET NULL
);

-- Table: InventoryStock
DROP TABLE IF EXISTS `InventoryStock`;
CREATE TABLE `InventoryStock` (
    `StockID` INT AUTO_INCREMENT PRIMARY KEY,
    `ProductID` INT NOT NULL UNIQUE,
    `QuantityInStock` INT NOT NULL DEFAULT 0,
    `ReorderLevel` INT DEFAULT 10,
    `LastStockUpdate` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ProductID`) REFERENCES `Products`(`ProductID`) ON DELETE CASCADE
);

-- Table: Orders
DROP TABLE IF EXISTS `Orders`;
CREATE TABLE `Orders` (
    `OrderID` INT AUTO_INCREMENT PRIMARY KEY,
    `CustomerID` INT NOT NULL,
    `OrderDate` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `OrderStatus` VARCHAR(50) NOT NULL COMMENT 'e.g., Pending, Processing, Shipped, Delivered, Cancelled',
    `ShippingAddressID` INT NOT NULL,
    `BillingAddressID` INT NOT NULL,
    `TotalAmount` DECIMAL(12, 2) NOT NULL COMMENT 'Denormalized: Sum of OrderItems subtotals',
    `PaymentMethod` VARCHAR(50),
    `PaymentStatus` VARCHAR(50) NOT NULL COMMENT 'e.g., Paid, Pending, Failed',
    FOREIGN KEY (`CustomerID`) REFERENCES `Customers`(`CustomerID`) ON DELETE RESTRICT,
    FOREIGN KEY (`ShippingAddressID`) REFERENCES `Addresses`(`AddressID`) ON DELETE RESTRICT,
    FOREIGN KEY (`BillingAddressID`) REFERENCES `Addresses`(`AddressID`) ON DELETE RESTRICT
);

-- Table: OrderItems
DROP TABLE IF EXISTS `OrderItems`;
CREATE TABLE `OrderItems` (
    `OrderItemID` INT AUTO_INCREMENT PRIMARY KEY,
    `OrderID` INT NOT NULL,
    `ProductID` INT NOT NULL,
    `Quantity` INT NOT NULL,
    `UnitPriceAtPurchase` DECIMAL(10, 2) NOT NULL,
    `Subtotal` DECIMAL(12, 2) NOT NULL COMMENT 'Denormalized: Quantity * UnitPriceAtPurchase',
    FOREIGN KEY (`OrderID`) REFERENCES `Orders`(`OrderID`) ON DELETE CASCADE,
    FOREIGN KEY (`ProductID`) REFERENCES `Products`(`ProductID`) ON DELETE RESTRICT,
    UNIQUE (`OrderID`, `ProductID`)
);

-- Table: ShoppingCarts
DROP TABLE IF EXISTS `ShoppingCarts`;
CREATE TABLE `ShoppingCarts` (
    `CartID` INT AUTO_INCREMENT PRIMARY KEY,
    `CustomerID` INT NOT NULL UNIQUE,
    `DateCreated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `LastUpdated` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`CustomerID`) REFERENCES `Customers`(`CustomerID`) ON DELETE CASCADE
);

-- Table: CartItems
DROP TABLE IF EXISTS `CartItems`;
CREATE TABLE `CartItems` (
    `CartItemID` INT AUTO_INCREMENT PRIMARY KEY,
    `CartID` INT NOT NULL,
    `ProductID` INT NOT NULL,
    `Quantity` INT NOT NULL,
    `DateAdded` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`CartID`) REFERENCES `ShoppingCarts`(`CartID`) ON DELETE CASCADE,
    FOREIGN KEY (`ProductID`) REFERENCES `Products`(`ProductID`) ON DELETE CASCADE,
    UNIQUE (`CartID`, `ProductID`)
);

-- Table: Administrators
DROP TABLE IF EXISTS `Administrators`;
CREATE TABLE `Administrators` (
    `AdminID` INT AUTO_INCREMENT PRIMARY KEY,
    `Username` VARCHAR(100) NOT NULL UNIQUE,
    `PasswordHash` VARCHAR(255) NOT NULL,
    `Email` VARCHAR(255) NOT NULL UNIQUE,
    `Role` VARCHAR(50) NOT NULL COMMENT 'e.g., SuperAdmin, OrderManager, ProductManager',
    `LastLoginDate` TIMESTAMP NULL
);


-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS=1;

INSERT INTO `Locations` (`PostalCode`, `City`, `State`, `Country`) VALUES
("90210", "Beverly Hills", "CA", "USA"),
("10001", "New York", "NY", "USA"),
("60606", "Chicago", "IL", "USA"),
("77002", "Houston", "TX", "USA"),
("94107", "San Francisco", "CA", "USA"),
("02116", "Boston", "MA", "USA"),
("33133", "Miami", "FL", "USA"),
("80202", "Denver", "CO", "USA"),
("98101", "Seattle", "WA", "USA"),
("20001", "Washington", "DC", "USA"),
("SW1A 1AA", "London", NULL, "UK"),
("75001", "Paris", NULL, "France");


INSERT INTO `Customers` (`FirstName`, `LastName`, `Email`, `PasswordHash`, `PhoneNumber`, `RegistrationDate`) VALUES
("John", "Doe", "john.doe@example.com", "hash123", "555-0101", NOW()),
("Jane", "Smith", "jane.smith@example.com", "hash456", "555-0102", NOW()),
("Alice", "Johnson", "alice.johnson@example.com", "hash789", "555-0103", NOW()),
("Bob", "Williams", "bob.williams@example.com", "hash101", "555-0104", NOW()),
("Charlie", "Brown", "charlie.brown@example.com", "hash112", "555-0105", NOW()),
("Diana", "Davis", "diana.davis@example.com", "hash131", "555-0106", NOW()),
("Edward", "Miller", "edward.miller@example.com", "hash415", "555-0107", NOW()),
("Fiona", "Wilson", "fiona.wilson@example.com", "hash161", "555-0108", NOW()),
("George", "Moore", "george.moore@example.com", "hash718", "555-0109", NOW()),
("Helen", "Taylor", "helen.taylor@example.com", "hash192", "555-0110", NOW());


INSERT INTO `Addresses` (`CustomerID`, `AddressType`, `StreetAddress`, `PostalCode`) VALUES
(1, "Shipping", "123 Main St", "90210"),
(1, "Billing", "123 Main St", "90210"),
(2, "Shipping", "456 Oak Ave", "10001"),
(3, "Shipping", "789 Pine Ln", "60606"),
(4, "Billing", "101 Maple Dr", "77002"),
(5, "Shipping", "202 Birch Rd", "94107"),
(6, "Shipping", "303 Cedar Ct", "02116"),
(7, "Billing", "404 Elm St", "33133"),
(8, "Shipping", "505 Spruce Way", "80202"),
(9, "Shipping", "606 Aspen Pl", "98101"),
(10, "Billing", "707 Willow Bend", "20001");


INSERT INTO `Categories` (`CategoryName`, `Description`) VALUES
("Electronics", "Gadgets, devices, and accessories"),
("Books", "Fiction, non-fiction, educational"),
("Clothing", "Apparel for men, women, and children"),
("Home & Kitchen", "Appliances, decor, and kitchenware"),
("Sports & Outdoors", "Equipment for various sports and outdoor activities"),
("Toys & Games", "Fun and educational toys for all ages"),
("Beauty & Personal Care", "Cosmetics, skincare, and grooming products"),
("Automotive", "Parts and accessories for vehicles"),
("Health & Wellness", "Vitamins, supplements, and health products"),
("Office Supplies", "Stationery, furniture, and office equipment");


INSERT INTO `Products` (`ProductName`, `Description`, `CategoryID`, `UnitPrice`, `ImageURL`) VALUES
("Laptop Pro 15", "High-performance laptop for professionals", 1, 1299.99, "http://example.com/laptop_pro.jpg"),
("The Great Novel", "A captivating story of adventure", 2, 19.99, "http://example.com/great_novel.jpg"),
("Men's Cotton T-Shirt", "Comfortable and stylish t-shirt", 3, 25.50, "http://example.com/mens_tshirt.jpg"),
("Smart Coffee Maker", "Brew coffee remotely with your phone", 4, 89.95, "http://example.com/coffee_maker.jpg"),
("Yoga Mat Premium", "Non-slip, eco-friendly yoga mat", 5, 35.00, "http://example.com/yoga_mat.jpg"),
("Building Blocks Set", "Creative building blocks for kids", 6, 49.99, "http://example.com/building_blocks.jpg"),
("Organic Face Cream", "Nourishing and hydrating face cream", 7, 22.75, "http://example.com/face_cream.jpg"),
("Car Phone Mount", "Universal car phone holder", 8, 15.99, "http://example.com/car_mount.jpg"),
("Vitamin C Gummies", "Daily immune support gummies", 9, 12.50, "http://example.com/vitamin_c.jpg"),
("Ergonomic Office Chair", "Comfortable chair for long working hours", 10, 250.00, "http://example.com/office_chair.jpg"),
("Wireless Headphones", "Noise-cancelling over-ear headphones", 1, 199.99, "http://example.com/headphones.jpg"),
("History of the World", "Comprehensive historical account", 2, 29.95, "http://example.com/history_book.jpg");


INSERT INTO `InventoryStock` (`ProductID`, `QuantityInStock`, `ReorderLevel`) VALUES
(1, 50, 10),
(2, 120, 20),
(3, 200, 50),
(4, 75, 15),
(5, 150, 30),
(6, 300, 60),
(7, 90, 20),
(8, 250, 50),
(9, 500, 100),
(10, 40, 10),
(11, 60, 15),
(12, 80, 25);

INSERT INTO `Orders` (`CustomerID`, `OrderStatus`, `ShippingAddressID`, `BillingAddressID`, `TotalAmount`, `PaymentMethod`, `PaymentStatus`) VALUES
(1, "Delivered", 1, 2, 1325.49, "Credit Card", "Paid"), 
(2, "Shipped", 3, 3, 19.99, "PayPal", "Paid"), 
(3, "Processing", 4, 4, 25.50, "Credit Card", "Paid"),
(4, "Pending", 5, 5, 89.95, "Credit Card", "Pending"), 
(5, "Delivered", 6, 6, 35.00, "PayPal", "Paid"), 
(1, "Shipped", 1, 2, 49.99, "Credit Card", "Paid"), 
(6, "Processing", 7, 7, 22.75, "Credit Card", "Paid"), 
(7, "Delivered", 8, 8, 15.99, "PayPal", "Paid"), 
(8, "Pending", 9, 9, 12.50, "Credit Card", "Pending"), 
(9, "Shipped", 10, 10, 250.00, "Credit Card", "Paid"), 
(10, "Delivered", 11, 11, 199.99, "PayPal", "Paid"); 

INSERT INTO `OrderItems` (`OrderID`, `ProductID`, `Quantity`, `UnitPriceAtPurchase`, `Subtotal`) VALUES
(1, 1, 1, 1299.99, 1299.99),
(1, 3, 1, 25.50, 25.50), 
(2, 2, 1, 19.99, 19.99), 
(3, 3, 1, 25.50, 25.50),
(4, 4, 1, 89.95, 89.95), 
(5, 5, 1, 35.00, 35.00), 
(6, 6, 1, 49.99, 49.99), 
(7, 7, 1, 22.75, 22.75), 
(8, 8, 1, 15.99, 15.99), 
(9, 9, 1, 12.50, 12.50), 
(10, 10, 1, 250.00, 250.00), 
(11, 11, 1, 199.99, 199.99); 

INSERT INTO `ShoppingCarts` (`CustomerID`, `LastUpdated`) VALUES
(1, NOW()),
(2, NOW()),
(3, NOW()),
(4, NOW()),
(5, NOW()),
(6, NOW()),
(7, NOW()),
(8, NOW()),
(9, NOW()),
(10, NOW());


INSERT INTO `CartItems` (`CartID`, `ProductID`, `Quantity`) VALUES
(1, 2, 1), 
(1, 5, 2), 
(2, 1, 1), 
(3, 7, 1), 
(4, 10, 1), 
(5, 4, 1), 
(6, 8, 3), 
(7, 11, 1), 
(8, 3, 2), 
(9, 6, 1), 
(10, 9, 5); 


INSERT INTO `Administrators` (`Username`, `PasswordHash`, `Email`, `Role`) VALUES
("admin_user", "securehash_admin", "admin@example.com", "SuperAdmin"),
("product_manager", "securehash_pm", "pm@example.com", "ProductManager"),
("order_processor", "securehash_op", "op@example.com", "OrderManager"),
("support_staff1", "securehash_ss1", "support1@example.com", "SupportStaff"),
("data_analyst", "securehash_da", "analyst@example.com", "Analyst"),
("marketing_lead", "securehash_ml", "marketing@example.com", "Marketing"),
("inventory_clerk", "securehash_ic", "inventory@example.com", "InventoryManager"),
("webmaster", "securehash_wm", "webmaster@example.com", "WebAdmin"),
("finance_officer", "securehash_fo", "finance@example.com", "Finance"),
("ceo_user", "securehash_ceo", "ceo@example.com", "SuperAdmin");

