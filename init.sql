-- Table Creation
CREATE TABLE product (
prodid CHAR(10),
pname VARCHAR(30),
price DECIMAL(10,2)
);

CREATE TABLE depot (
depid CHAR(10),
addr VARCHAR(50),
volume INT
);

CREATE TABLE stock (
prodid CHAR(10),
depid CHAR(10),
quantity INT
);

-- Constraints and Keys
ALTER TABLE product
ADD CONSTRAINT pk_product PRIMARY KEY (prodid);

ALTER TABLE depot
ADD CONSTRAINT pk_depot PRIMARY KEY (depid);

ALTER TABLE stock
ADD CONSTRAINT pk_stock PRIMARY KEY (prodid, depid);

ALTER TABLE stock
ADD CONSTRAINT fk_stock_prodid
FOREIGN KEY (prodid) REFERENCES product(prodid) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE stock
ADD CONSTRAINT fk_stock_depid
FOREIGN KEY (depid) REFERENCES depot(depid) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE product
ADD CONSTRAINT ck_product_price CHECK (price > 0);

ALTER TABLE depot
ADD CONSTRAINT ck_depot_volume CHECK (volume >= 0);

ALTER TABLE stock
ADD CONSTRAINT ck_stock_quantity CHECK (quantity IS NOT NULL);

-- Values
INSERT INTO product (prodid, pname, price) VALUES
('p1', 'tape', 2.50),
('p2', 'tv', 250),
('p3', 'vcr', 80);

INSERT INTO depot (depid, addr, volume) VALUES
('d1', 'New York', 9000),
('d2', 'Syracuse', 6000),
('d4', 'New York', 2000);

INSERT INTO stock (prodid, depid, quantity) VALUES
('p1', 'd1', 1000),
('p1', 'd2', -100),
('p1', 'd4', 1200),
('p3', 'd1', 3000),
('p3', 'd4', 2000),
('p2', 'd4', 1500),
('p2', 'd1', -400),
('p2', 'd2', 2000);