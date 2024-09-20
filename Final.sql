
-- Practical Assignment 01 "Complex select"

CREATE DATABASE PA01;

USE PA01;

-- Creating tables

CREATE TABLE Clients (
    ClientID INT AUTO_INCREMENT PRIMARY KEY,
    ClientName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20)
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    ClientID INT,
    ProductID INT,
    OrderDate DATE,
    Quantity INT,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert data into Clients
INSERT INTO Clients (ClientName, Email, Phone) VALUES
('John Doe', 'john.doe@example.com', '555-1234'),
('Jane Smith', 'jane.smith@example.com', '555-5678'),
('Alice Johnson', 'alice.johnson@example.com', '555-8765'),
('Bob Brown', 'bob.brown@example.com', '555-4321'),
('Charlie Black', 'charlie.black@example.com', '555-1122');

-- Insert data into Products
INSERT INTO Products (ProductName, Price) VALUES
('Laptop', 999.99),
('Smartphone', 499.99),
('Tablet', 299.99),
('Smartwatch', 199.99),
('Headphones', 99.99);

-- Insert data into Orders
INSERT INTO Orders (ClientID, ProductID, OrderDate, Quantity) VALUES
(1, 1, '2024-09-01', 1),
(1, 3, '2024-09-01', 2),
(2, 2, '2024-08-31', 1),
(3, 4, '2024-08-30', 3),
(4, 1, '2024-08-29', 1),
(4, 5, '2024-08-29', 2),
(5, 3, '2024-08-28', 1),
(5, 4, '2024-08-28', 1),
(5, 2, '2024-08-28', 1),
(3, 1, '2024-08-30', 1);

-- Next 2 tables were made by ChatGPT 
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

INSERT INTO Categories (CategoryName) VALUES
('Electronics'),
('Accessories'),
('Computers'),
('Mobile Devices');

CREATE TABLE OrderStatus (
    StatusID INT AUTO_INCREMENT PRIMARY KEY,
    StatusName VARCHAR(50)
);

-- Insert data into OrderStatus
INSERT INTO OrderStatus (StatusName) VALUES
('Pending'),
('Shipped'),
('Delivered'),
('Cancelled');

ALTER TABLE Orders
ADD StatusID INT,
ADD FOREIGN KEY (StatusID) REFERENCES OrderStatus(StatusID);

ALTER TABLE Products
ADD CategoryID INT,
ADD FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID);

-- Here I want to find our "best customer" and worst accroding to their spents 
WITH FilteredOrders AS (
    select o.OrderID,
        o.ClientID,
        o.ProductID,
        o.OrderDate,
        o.Quantity,
        o.StatusID
    FROM Orders o
    JOIN OrderStatus ors ON o.StatusID = ors.StatusID
    WHERE o.OrderDate >= '2024-07-01' AND ors.StatusName != 'Cancelled'
)


(select 
    c.ClientName,
    SUM(p.Price * o.Quantity) as TotalSpent ,
    COUNT(o.OrderID) as NumberOfOrders
from FilteredOrders o
join Clients c on o.ClientID = c.ClientID
join Products p on o.ProductID = p.ProductID
join Categories ct on p.CategoryID = ct.CategoryID
where ct.CategoryName != "Accessories"
group by c.ClientID, c.ClientName
order by TotalSpent desc , NumberOfOrders desc 
limit 1 )

union 

(select 
    c.ClientName,
    SUM(p.Price * o.Quantity) as TotalSpent ,
    COUNT(o.OrderID) as NumberOfOrders
from FilteredOrders o
join Clients c on o.ClientID = c.ClientID
join Products p on o.ProductID = p.ProductID
join Categories ct on p.CategoryID = ct.CategoryID
where ct.CategoryName != "Accessories"
group by c.ClientID, c.ClientName
order by TotalSpent asc , NumberOfOrders asc 
limit 1 )
