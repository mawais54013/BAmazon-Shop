DROP DATABASE IF EXISTS bamazon;
-- This creates the database if one does not exist already
CREATE DATABASE bamazon;
-- and through usings this database
USE bamazon;
-- create a product table to list and use info from this data set
CREATE TABLE products (
    Item_id INT NOT NULL AUTO_INCREMENT,
    Product_name VARCHAR(200) NOT NULL,
    Product_sale INT NULL,
    Department_name VARCHAR(200) NOT NULL,
    Price DECIMAL(10,2) NULL,
    Stock_Available INT NULL,
    PRIMARY KEY (Item_id)
);
-- this is used mainly for supervisor to see which department is doing well
CREATE TABLE departments (
    department_id INT NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(200) NOT NULL,
    over_head_costs INT NOT NULL,
    product_sales INT NOT NULL,
    total_profit INT NOT NULL,
    PRIMARY KEY (department_id)
);
-- insert info and items into products
INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Apple Airpods", 0,"Tech", 159.99, 70);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Micosoft Wireless Keyboard", 0, "Tech", 59.99, 120);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Avengers Infinity War", 0, "Movies", 19.99, 200);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Black Buttoned Shirt", 0,"Clothing", 27.50, 90);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Post-Its", 0,"Stationary", 3.99, 1000);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Clorox Cleaning Wipes", 0, "Household", 5.99, 300);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Avengers Infinity War", 0, "Movies", 19.99, 200);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Limited Edition Spiderman Pop Funko", 0,"Toys", 8.99, 30);

INSERT INTO products (Product_name, Product_sale,Department_name, Price, Stock_Available)
VALUES ("Screwdriver", 0, "Home Improvement", 7.99, 50);

INSERT INTO products (Product_name, Product_sale, Department_name, Price, Stock_Available)
VALUES ("Oreo Cookies", 0, "Food", 2.99, 350);


-- insert department info to departments
INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Tech", 400, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Movies", 70, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Clothing", 250, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Stationary", 100, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Household", 290, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Toys", 350, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Home Improvement", 230, 0, 0);

INSERT INTO departments(department_name, over_head_costs, product_sales, total_profit)
VALUES ("Food", 320, 0, 0);

