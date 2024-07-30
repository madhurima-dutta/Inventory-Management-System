-- Creating brands table
CREATE TABLE brands (
    bid SERIAL PRIMARY KEY,
    bname VARCHAR(20)
);

-- Creating inv_user table
CREATE TABLE inv_user (
    user_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(20),
    password VARCHAR(20),
    last_login TIMESTAMP,
    user_type VARCHAR(10)
);

-- Creating categories table
CREATE TABLE categories (
    cid SERIAL PRIMARY KEY,
    category_name VARCHAR(20)
);

-- Creating stores table
CREATE TABLE stores (
    sid SERIAL PRIMARY KEY,
    sname VARCHAR(20),
    address VARCHAR(20),
    mobno BIGINT
);

-- Creating product table
CREATE TABLE product (
    pid SERIAL PRIMARY KEY,
    cid INT REFERENCES categories(cid),
    bid INT REFERENCES brands(bid),
    sid INT REFERENCES stores(sid),
    pname VARCHAR(20),
    p_stock INT,
    price INT,
    added_date DATE
);

-- Creating provides table
CREATE TABLE provides (
    bid INT REFERENCES brands(bid),
    sid INT REFERENCES stores(sid),
    discount INT
);

-- Creating customer_cart table
CREATE TABLE customer_cart (
    cust_id SERIAL PRIMARY KEY,
    name VARCHAR(20),
    mobno BIGINT
);

-- Creating select_product table
CREATE TABLE select_product (
    cust_id INT REFERENCES customer_cart(cust_id),
    pid INT REFERENCES product(pid),
    quantity INT
);

-- Creating transaction table
CREATE TABLE transaction (
    id SERIAL PRIMARY KEY,
    total_amount INT,
    paid INT,
    due INT,
    gst INT,
    discount INT,
    payment_method VARCHAR(10),
    cart_id INT REFERENCES customer_cart(cust_id)
);

-- Creating invoice table
CREATE TABLE invoice (
    item_no SERIAL PRIMARY KEY,
    product_name VARCHAR(20),
    quantity INT,
    net_price INT,
    transaction_id INT REFERENCES transaction(id)
);

-- Inserting into brands
INSERT INTO brands (bname) VALUES ('Apple'), ('Samsung'), ('Nike'), ('Fortune');

-- Inserting into inv_user
INSERT INTO inv_user (user_id, name, password, last_login, user_type)
VALUES
('vidit@gmail.com', 'vidit', '1234', '2018-10-31 12:40', 'admin'),
('harsh@gmail.com', 'Harsh Khanelwal', '1111', '2018-10-30 10:20', 'Manager'),
('prashant@gmail.com', 'Prashant', '0011', '2018-10-29 10:20', 'Accountant');

-- Inserting into categories
INSERT INTO categories (category_name) VALUES ('Electronics'), ('Clothing'), ('Grocery');

-- Inserting into stores
INSERT INTO stores (sname, address, mobno)
VALUES 
('Ram kumar', 'Katpadi vellore', 9999999999),
('Rakesh kumar', 'Chennai', 8888555541),
('Suraj', 'Haryana', 7777555541);

-- Inserting into product
INSERT INTO product (cid, bid, sid, pname, p_stock, price, added_date)
VALUES 
(1, 1, 1, 'IPHONE', 4, 45000, '2018-10-31'),
(1, 1, 1, 'Airpods', 3, 19000, '2018-10-27'),
(1, 1, 1, 'Smart Watch', 3, 19000, '2018-10-27'),
(2, 3, 2, 'Air Max', 6, 7000, '2018-10-27'),
(3, 4, 3, 'REFINED OIL', 6, 750, '2018-10-25');

-- Inserting into provides
INSERT INTO provides (bid, sid, discount)
VALUES 
(1, 1, 12),
(2, 2, 7),
(3, 3, 15),
(1, 2, 7),
(4, 2, 19),
(4, 3, 20);

-- Inserting into customer_cart
INSERT INTO customer_cart (name, mobno)
VALUES 
('Ram', 9876543210),
('Shyam', 7777777777),
('Mohan', 7777777775);

-- Inserting into select_product
INSERT INTO select_product (cust_id, pid, quantity)
VALUES 
(1, 2, 2),
(1, 3, 1),
(2, 3, 3),
(3, 2, 1);

-- Inserting into transaction
INSERT INTO transaction (total_amount, paid, due, gst, discount, payment_method, cart_id)
VALUES 
(57000, 20000, 5000, 350, 350, 'card', 1),
(57000, 57000, 0, 570, 570, 'cash', 2),
(19000, 17000, 2000, 190, 190, 'cash', 3);

CREATE OR REPLACE FUNCTION get_due_amount(c_id INT) RETURNS INT AS $$
DECLARE
    due1 INT;
BEGIN
    SELECT due INTO due1 FROM transaction WHERE cart_id = c_id;
    RETURN due1;
END;
$$ LANGUAGE plpgsql;

-- Example call
SELECT get_due_amount(1);

DO $$
DECLARE
    product_id INT;
    product_name VARCHAR(20);
    product_stock INT;
    p_product CURSOR FOR SELECT pid, pname, p_stock FROM product;
BEGIN
    OPEN p_product;
    LOOP
        FETCH p_product INTO product_id, product_name, product_stock;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '% % %', product_id, product_name, product_stock;
    END LOOP;
    CLOSE p_product;
END;
$$;

CREATE OR REPLACE PROCEDURE check_stock(p_id INT) LANGUAGE plpgsql AS $$
DECLARE
    stock INT;
BEGIN
    SELECT p_stock INTO stock FROM product WHERE pid = p_id;
    IF stock < 2 THEN
        RAISE NOTICE 'Stock is Less';
    ELSE
        RAISE NOTICE 'Enough Stock';
    END IF;
END;
$$;

-- Example call
CALL check_stock(2);

