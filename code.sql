CREATE DATABASE ecommerce_db;

USE ecommerce_db;
SHOW DATABASES;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT UNIQUE,
    quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);

CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT UNIQUE,
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT,
    product_id INT,
    quantity INT NOT NULL,
    UNIQUE (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30) DEFAULT 'Pending',
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    amount DECIMAL(10,2),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SHOW TABLES;
DESC customers;

INSERT INTO customers
(first_name, last_name, email, phone, city)
VALUES
('Deepa', 'Kambad', 'deepa@gmail.com', '9876543210', 'Bangalore'),
('Akashay', 'Kumar', 'akashay@gmail.com', '9876543211', 'Mysore'),
('Priya', 'Sharma', 'priya@gmail.com', '9876543212', 'Hubli'),
('Rahul', 'Patil', 'rahul@gmail.com', '9876543213', 'Belgaum'),
('Sneha', 'Rao', 'sneha@gmail.com', '9876543214', 'Bangalore');

INSERT INTO categories (category_name)
VALUES
('Electronics'),
('Clothing'),
('Footwear'),
('Home Appliances'),
('Accessories');

INSERT INTO products
(product_name, category_id, price, description)
VALUES
('Laptop', 1, 55000, 'HP Laptop'),
('Mobile Phone', 1, 20000, 'Samsung Mobile'),
('T-Shirt', 2, 800, 'Cotton T-Shirt'),
('Shoes', 3, 1500, 'Running Shoes'),
('Washing Machine', 4, 25000, 'Front Load'),
('Smart Watch', 5, 3000, 'Digital Watch'),
('Headphones', 1, 1200, 'Wireless Headphones');

INSERT INTO inventory (product_id, quantity)
VALUES
(1, 10),
(2, 20),
(3, 50),
(4, 30),
(5, 8),
(6, 25),
(7, 40);

INSERT INTO cart (customer_id)
VALUES
(1), (2), (3), (4), (5);

INSERT INTO cart_items
(cart_id, product_id, quantity)
VALUES
(1, 1, 1),
(1, 6, 2),
(2, 2, 1),
(3, 3, 3),
(4, 4, 1);

INSERT INTO orders
(customer_id, total_amount, order_status)
VALUES
(1, 61000, 'Confirmed'),
(2, 20000, 'Pending'),
(3, 2400, 'Delivered'),
(4, 1500, 'Cancelled');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 55000),
(1, 6, 2, 3000),
(2, 2, 1, 20000),
(3, 3, 3, 800),
(4, 4, 1, 1500);

INSERT INTO payments
(order_id, payment_method, payment_status, amount)
VALUES
(1, 'UPI', 'Success', 61000),
(2, 'Card', 'Pending', 20000),
(3, 'UPI', 'Success', 2400),
(4, 'Cash', 'Failed', 1500);

SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    o.total_amount
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;

SELECT
    c.first_name,
    o.order_id,
    o.total_amount,
    o.order_status
FROM customers c
RIGHT JOIN orders o
ON c.customer_id = o.customer_id;

SELECT
    c.customer_id,
    c.first_name,
    c.email
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT product_name, price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);

SELECT first_name, email
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > 10000
);

SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id;

SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

SELECT SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'Success';

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status IN ('Confirmed', 'Delivered')
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC;

SELECT
    p.product_name,
    i.quantity
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
WHERE i.quantity < 10;

SELECT
    c.first_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Confirmed', 'Delivered')
GROUP BY c.customer_id, c.first_name
ORDER BY total_spent DESC
LIMIT 1;

CREATE VIEW customer_orders AS
SELECT
    c.customer_id,
    c.first_name,
    c.email,
    o.order_id,
    o.total_amount,
    o.order_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

SELECT * FROM customer_orders;

SELECT *
FROM customer_orders
WHERE order_status = 'Confirmed';

CREATE VIEW product_details AS
SELECT
    p.product_id,
    p.product_name,
    p.price,
    c.category_name
FROM products p
JOIN categories c
ON p.category_id = c.category_id;

SELECT * FROM product_details;

CREATE OR REPLACE VIEW customer_orders AS
SELECT
    c.first_name,
    o.order_id,
    o.total_amount,
    o.order_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled';

CREATE INDEX idx_customer_email
ON customers(email);

SELECT *
FROM customers
WHERE email = 'deepa@gmail.com';

CREATE INDEX idx_product_price
ON products(price);

SHOW INDEX FROM customers;

CREATE INDEX idx_customer_city_name
ON customers(city, first_name);

SELECT *
FROM customers
WHERE city = 'Bangalore'
AND first_name = 'Deepa';\

DELIMITER //

CREATE PROCEDURE GetAllCustomers()
BEGIN
    SELECT * FROM customers;
END //

DELIMITER ;

CALL GetAllCustomers();

DELIMITER //

CREATE PROCEDURE GetProductsByCategory(
    IN cat_id INT
)
BEGIN
    SELECT *
    FROM products
    WHERE category_id = cat_id;
END //

DELIMITER ;

CALL GetProductsByCategory(1);

DELIMITER //

CREATE PROCEDURE GetProductsByPrice(
    IN min_price DECIMAL(10,2),
    IN max_price DECIMAL(10,2)
)
BEGIN
    SELECT product_name, price
    FROM products
    WHERE price BETWEEN min_price AND max_price;
END //

DELIMITER ;

CALL GetProductsByPrice(1000, 25000);

DELIMITER //

CREATE PROCEDURE GetCustomerCount(
    OUT total INT
)
BEGIN
    SELECT COUNT(*)
    INTO total
    FROM customers;
END //

DELIMITER ;
DROP PROCEDURE IF EXISTS GetCustomerCount;
CALL GetCustomerCount(@total);

SELECT @total;


DELIMITER //

CREATE PROCEDURE UpdateProductPrice(
    IN p_id INT,
    IN new_price DECIMAL(10,2)
)
BEGIN
    UPDATE products
    SET price = new_price
    WHERE product_id = p_id;
END //

DELIMITER ;

CALL UpdateProductPrice(1, 58000);

SELECT * FROM products
WHERE product_id = 1;

SHOW PROCEDURE STATUS
WHERE Db = 'ecommerce_db';



DELIMITER //

CREATE PROCEDURE CheckProductStock(
    IN p_id INT
)
BEGIN
    SELECT
        p.product_name,
        i.quantity,
        CASE
            WHEN i.quantity > 0 THEN 'Available'
            ELSE 'Out of Stock'
        END AS stock_status
    FROM products p
    JOIN inventory i
    ON p.product_id = i.product_id
    WHERE p.product_id = p_id;
END //

DELIMITER ;

CALL CheckProductStock(1);

DELIMITER //

CREATE TRIGGER check_product_price
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product price cannot be negative';
    END IF;
END //

DELIMITER ;

INSERT INTO products
(product_name, category_id, price)
VALUES
('Test Product', 1, 500);

DELIMITER //

CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity = quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //

DELIMITER ;

SELECT * FROM inventory
WHERE product_id = 1;

INSERT INTO orders
(customer_id, total_amount, order_status)
VALUES
(5, 55000, 'Confirmed');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(5, 1, 1, 55000);

SELECT * FROM inventory
WHERE product_id = 1;

DELIMITER //

CREATE TRIGGER check_inventory_quantity
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
END //

DELIMITER ;

UPDATE inventory
SET quantity = 5
WHERE product_id = 1;

CREATE TABLE deleted_products (
    product_id INT,
    product_name VARCHAR(100),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER backup_deleted_product
AFTER DELETE ON products
FOR EACH ROW
BEGIN
    INSERT INTO deleted_products
    (product_id, product_name)
    VALUES
    (OLD.product_id, OLD.product_name);
END //

DELIMITER ;

SHOW TRIGGERS;

SELECT * FROM inventory
WHERE product_id = 2;

START TRANSACTION;

INSERT INTO orders
(customer_id, total_amount, order_status)
VALUES
(1, 20000, 'Confirmed');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(6, 2, 1, 20000);

UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 2;

INSERT INTO payments
(order_id, payment_method, payment_status, amount)
VALUES
(6, 'UPI', 'Success', 20000);

COMMIT;

START TRANSACTION;

UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 2;

ROLLBACK;

SELECT * FROM inventory
WHERE product_id = 2;


START TRANSACTION;

UPDATE products
SET price = 21000
WHERE product_id = 2;

SAVEPOINT price_updated;

UPDATE inventory
SET quantity = quantity - 5
WHERE product_id = 2;

ROLLBACK TO SAVEPOINT price_updated;

COMMIT;

START TRANSACTION;

UPDATE inventory
SET quantity = quantity - 2
WHERE product_id = 3
AND quantity >= 2;

SELECT * FROM inventory
WHERE product_id = 3;

COMMIT;

SELECT
    p.product_id,
    p.product_name,
    p.price,
    i.quantity AS available_stock
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
WHERE p.product_id = 1;

DELIMITER //

CREATE PROCEDURE PlaceOrder(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_payment_method VARCHAR(30)
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_order_id INT;
    DECLARE v_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM products
    WHERE product_id = p_product_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product does not exist';
    END IF;

    SELECT price INTO v_price
    FROM products
    WHERE product_id = p_product_id;

    SET v_total = v_price * p_quantity;

    START TRANSACTION;

    UPDATE inventory
    SET quantity = quantity - p_quantity
    WHERE product_id = p_product_id
    AND quantity >= p_quantity;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    INSERT INTO orders
    (customer_id, total_amount, order_status)
    VALUES
    (p_customer_id, v_total, 'Confirmed');

    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
    VALUES
    (v_order_id, p_product_id, p_quantity, v_price);

    INSERT INTO payments
    (order_id, payment_method, payment_status, amount)
    VALUES
    (v_order_id, p_payment_method, 'Pending', v_total);

    COMMIT;

    SELECT
        v_order_id AS order_id,
        v_total AS total_amount,
        'Order placed successfully' AS message;

END //

DELIMITER ;




SELECT * FROM orders
ORDER BY order_id DESC;

SELECT * FROM order_items
ORDER BY order_item_id DESC;

SELECT * FROM payments
ORDER BY payment_id DESC;

SELECT * FROM inventory
WHERE product_id = 2;

SELECT
    c.first_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    o.total_amount,
    o.order_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
WHERE c.customer_id = 1
ORDER BY o.order_date DESC;


DELIMITER //

CREATE PROCEDURE CancelOrder(
    IN p_order_id INT
)
BEGIN
    DECLARE v_status VARCHAR(30);
    DECLARE v_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO v_count
    FROM orders
    WHERE order_id = p_order_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order does not exist';
    END IF;

    START TRANSACTION;

    SELECT order_status INTO v_status
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;

    IF v_status IN ('Cancelled', 'Delivered') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order cannot be cancelled';
    END IF;

    UPDATE inventory i
    JOIN (
        SELECT product_id, SUM(quantity) AS total_qty
        FROM order_items
        WHERE order_id = p_order_id
        GROUP BY product_id
    ) oi ON i.product_id = oi.product_id
    SET i.quantity = i.quantity + oi.total_qty;

    UPDATE orders
    SET order_status = 'Cancelled'
    WHERE order_id = p_order_id;

    COMMIT;

    SELECT 'Order cancelled successfully' AS message;

END //

DELIMITER ;

CALL CancelOrder(6);

SELECT * FROM orders
WHERE order_id = 6;

SELECT * FROM inventory;

UPDATE orders
SET order_status = 'Shipped'
WHERE order_id = 6;

SELECT order_id, order_status
FROM orders;

UPDATE payments
SET payment_status = 'Success'
WHERE order_id = 6;

SELECT * FROM payments;

SELECT
    SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'Success';

SELECT
    YEAR(payment_date) AS sales_year,
    MONTH(payment_date) AS sales_month,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE payment_status = 'Success'
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date)
ORDER BY sales_year, sales_month;

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status IN ('Confirmed', 'Shipped', 'Delivered')
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

SELECT
    c.customer_id,
    c.first_name,
    c.email,
    SUM(p.amount) AS total_spending
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
WHERE p.payment_status = 'Success'
GROUP BY
    c.customer_id,
    c.first_name,
    c.email
ORDER BY total_spending DESC
LIMIT 5;

SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM categories c
JOIN products p
ON c.category_id = p.category_id
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status IN ('Confirmed', 'Shipped', 'Delivered')
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount
FROM payments
WHERE payment_status = 'Success'
GROUP BY payment_method;

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;

SELECT
    p.product_name,
    i.quantity AS available_stock
FROM products p
JOIN inventory i
ON p.product_id = i.product_id
WHERE i.quantity < 10
ORDER BY i.quantity ASC;

CREATE OR REPLACE VIEW sales_report AS
SELECT
    o.order_id,
    c.first_name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS item_total,
    o.order_status
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id;

SELECT * FROM sales_report;

SELECT *
FROM sales_report
WHERE item_total > 5000;