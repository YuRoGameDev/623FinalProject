-- Transaction 1
-- Delete product p1 from Product and Stock.
CREATE OR REPLACE PROCEDURE transaction1()
LANGUAGE plpgsql AS $$
BEGIN
    -- Stock rows must be deleted first due to FK constraint
    DELETE FROM stock   WHERE prodid = 'p1';
    DELETE FROM product WHERE prodid = 'p1';

    IF NOT FOUND THEN
        RAISE NOTICE 'Product p1 does not exist';
    ELSE
        RAISE NOTICE 'Product p1 deleted successfully';
    END IF;
END;
$$;
 
 
-- Transaction 2
-- Delete depot d1 from Depot and Stock.
CREATE OR REPLACE PROCEDURE transaction2()
LANGUAGE plpgsql AS $$
BEGIN
    -- Stock rows must be deleted first due to FK constraint
    DELETE FROM stock WHERE depid = 'd1';
    DELETE FROM depot WHERE depid = 'd1';

    IF NOT FOUND THEN
        RAISE NOTICE 'Depot d1 does not exist';
    ELSE
        RAISE NOTICE 'Depot d1 deleted successfully';
    END IF;
END;
$$;
 
 
-- Transaction 3
-- Rename product p1 to pp1 in Product and Stock.
CREATE OR REPLACE PROCEDURE transaction3()
LANGUAGE plpgsql AS $$
BEGIN
    -- Defer FK check until Python issues COMMIT.
    SET CONSTRAINTS fk_stock_prodid DEFERRED;
 
    UPDATE product SET prodid = 'pp1' WHERE prodid = 'p1';
    UPDATE stock   SET prodid = 'pp1' WHERE prodid = 'p1';

    IF NOT FOUND THEN
        RAISE NOTICE 'Product p1 does not exist';
    ELSE
        RAISE NOTICE 'Product p1 changed to pp1';
    END IF;
END;
$$;
 
 
-- Transaction 4
-- Rename depot d1 to dd1 in Depot and Stock.
CREATE OR REPLACE PROCEDURE transaction4()
LANGUAGE plpgsql AS $$
BEGIN
    -- Defer FK check until Python issues COMMIT.
    SET CONSTRAINTS fk_stock_depid DEFERRED;
 
    UPDATE depot SET depid = 'dd1' WHERE depid = 'd1';
    UPDATE stock SET depid = 'dd1' WHERE depid = 'd1';

    IF NOT FOUND THEN
        RAISE NOTICE 'Depot d1 does not exist';
    ELSE
        RAISE NOTICE 'Depot d1 changed to dd1';
    END IF;
END;
$$;
 
 
-- Transaction 5
-- Add product (p100, cd, 5) to Product and (p100, d2, 50) to Stock.
CREATE OR REPLACE PROCEDURE transaction5()
LANGUAGE plpgsql AS $$
BEGIN
    -- Check if product already exists
    IF EXISTS (SELECT 1 FROM product WHERE prodid = 'p100') THEN
        RAISE NOTICE 'Product p100 already exists';
    ELSE
        INSERT INTO product (prodid, pname, price)
        VALUES ('p100', 'cd', 5);

        RAISE NOTICE 'Product p100 inserted';
    END IF;

    -- Check if depot exists (to avoid FK failure)
    IF NOT EXISTS (SELECT 1 FROM depot WHERE depid = 'd2') THEN
        RAISE NOTICE 'Depot d2 does not exist';
    ELSE
        INSERT INTO stock (prodid, depid, quantity)
        VALUES ('p100', 'd2', 50);

        RAISE NOTICE 'Stock (p100, d2, 50) inserted';
    END IF;
END;
$$;
 
 
-- Transaction 6
-- Add depot (d100, Chicago, 100) to Depot and (p1, d100, 100) to Stock.
CREATE OR REPLACE PROCEDURE transaction6()
LANGUAGE plpgsql AS $$
BEGIN
    -- Check if depot already exists
    IF EXISTS (SELECT 1 FROM depot WHERE depid = 'd100') THEN
        RAISE NOTICE 'Depot d100 already exists';
    ELSE
        INSERT INTO depot (depid, addr, volume)
        VALUES ('d100', 'Chicago', 100);

        RAISE NOTICE 'Depot d100 inserted';
    END IF;

    -- Check if product exists (avoid FK failure)
    IF NOT EXISTS (SELECT 1 FROM product WHERE prodid = 'p1') THEN
        RAISE NOTICE 'Product p1 does not exist';
    ELSE
        INSERT INTO stock (prodid, depid, quantity)
        VALUES ('p1', 'd100', 100);

        RAISE NOTICE 'Stock (p1, d100, 100) inserted';
    END IF;
END;
$$;

 
