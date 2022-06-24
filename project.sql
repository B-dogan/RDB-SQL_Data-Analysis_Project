SELECT *
from cust_dimen

-- id sütununu temizleyerek daha güzel bir görüntü elde etmeye çalýþacaðým : 
-- hatýrlatma : 
  SELECT SUBSTRING('Cust_1',6,25)

SELECT SUBSTRING(C.Cust_id,6,25) AS Cust_id,C.Customer_Name,C.Province,C.Region,C.Customer_Segment              
from cust_dimen C

---- 1) cust_dimen düzenlendi 

SELECT * 
FROM market_fact

--- bu tabloda da buna benzer bir durum var 

SELECT SUBSTRING(M.Ord_id,5,25) AS Ord_id,
	   SUBSTRING(M.Prod_id,6,25) AS Prod_id,
	   SUBSTRING(M.Ship_id,5,25) AS Ship_id,
	   SUBSTRING(M.Cust_id,6,25) AS Cust_id,M.Sales,M.Discount,M.Order_Quantity,M.Product_Base_Margin
FROM market_fact M


-- 2) market_fact düzenlendi 

SELECT *
FROM orders_dimen

-- BURADA  ORD_id bölümünde düzenlemeler yapacaðýz .

SELECT SUBSTRING(o.Ord_id,5,25) AS Ord_id,o.Order_Date,o.Order_Priority
FROM orders_dimen o

-- 3) orders_dimen düzenlendi 


SELECT *
FROM prod_dimen

-- 4) Yukarýdaki iþlemi prod_id'ye uygulayacaðýz .

SELECT SUBSTRING(P.Prod_id,6,25) AS Prod_id,p.Product_Category,p.Product_Sub_Category
FROM prod_dimen P

-- 4)  prod_dimen düzenlendi 

SELECT * 
FROM shipping_dimen 

--- Ship_id 'de bunu uygulayacaðýz bu sefer de.


SELECT SUBSTRING(S.Ship_id,5,25) AS Ship_id, S.Order_ID , S.Ship_Mode,S.Ship_Date
FROM shipping_dimen  S

-- 5)  shipping_dimen  düzenlendi .


SELECT *
INTO newtable
FROM (SELECT SUBSTRING(S.Ship_id,5,25) AS Ship_id, S.Order_ID , S.Ship_Mode,S.Ship_Date
        FROM shipping_dimen  S) a

--- þimdi sýrasýyla bunlarý kullanarak yeni tablolar oluþturacaðýz :
-- 1-cust_dimen  için : 

SELECT *
INTO customer
from (SELECT SUBSTRING(C.Cust_id,6,25) AS Cust_id,C.Customer_Name,C.Province,C.Region,C.Customer_Segment              
from cust_dimen C
       ) c_d

SELECT * 
FROM customer

--2- market_fact için 

SELECT * 
INTO market_fct
FROM (SELECT SUBSTRING(M.Ord_id,5,25) AS Ord_id,
	   SUBSTRING(M.Prod_id,6,25) AS Prod_id,
	   SUBSTRING(M.Ship_id,5,25) AS Ship_id,
	   SUBSTRING(M.Cust_id,6,25) AS Cust_id,M.Sales,M.Discount,M.Order_Quantity,M.Product_Base_Margin
FROM market_fact M) M_F


SELECT *
FROM market_fct

--3- orders_Dimen için :

SELECT * 
INTO orders
FROM(SELECT SUBSTRING(o.Ord_id,5,25) AS Ord_id,o.Order_Date,o.Order_Priority
		FROM orders_dimen o) o_d

SELECT * 
FROM orders

--4 - prod_dimen için : 

SELECT * 
INTO product
FROM( SELECT SUBSTRING(P.Prod_id,6,25) AS Prod_id,p.Product_Category,p.Product_Sub_Category
	  FROM prod_dimen P
		) p_D

select * 
from product


-- 5- shipping_dimen

SELECT * 
INTO shipping
FROM(SELECT SUBSTRING(S.Ship_id,5,25) AS Ship_id, S.Order_ID , S.Ship_Mode,S.Ship_Date
		FROM shipping_dimen  S
            ) s_d

select * 
from shipping

-- SIRA GELDİ CONSTRAINTLERİ TANIMLAMAYA:

-- CUSTOMER : 

ALTER TABLE customer
ALTER COLUMN Cust_id INT NOT NULL


ALTER TABLE customer
ADD CONSTRAINT customer_pk PRIMARY KEY(Cust_id)


-- orders :


ALTER TABLE orders
ALTER COLUMN Ord_id INT NOT NULL

ALTER TABLE orders
ADD CONSTRAINT order_pk PRIMARY KEY(Ord_id)


-- product : 

ALTER TABLE product
ALTER COLUMN Prod_id INT NOT NULL

ALTER TABLE product
ADD CONSTRAINT product_pk PRIMARY KEY(Prod_id)

-- shipping

ALTER TABLE shipping
ALTER COLUMN Ship_id INT NOT NULL

ALTER TABLE shipping
ADD CONSTRAINT shipping_pk PRIMARY KEY(Ship_id)

-- market_fct: 

-- pk yapabileceğimiz halihazırda bir sütun olmadığından şunu yapacağız : 

ALTER TABLE market_fct
ADD market_id int not null identity(1,1) primary key

--------- şimdi foreign keyleri tanımlayalım : 

ALTER TABLE market_fct
ALTER COLUMN  Ord_id  INT NOT NULL


ALTER TABLE market_fct
ADD CONSTRAINT FK_market_fct FOREIGN KEY(Ord_id)
REFERENCES orders(Ord_id)


ALTER TABLE market_fct
ALTER COLUMN  Prod_id  INT NOT NULL

ALTER TABLE market_fct
ADD CONSTRAINT FK2_market_fct FOREIGN KEY(Prod_id)
REFERENCES product(Prod_id)


ALTER TABLE market_fct
ALTER COLUMN  Ship_id  INT NOT NULL

ALTER TABLE market_fct
ADD CONSTRAINT FK3_market_fct FOREIGN KEY(Ship_id)
REFERENCES shipping(Ship_id)


ALTER TABLE market_fct
ALTER COLUMN  Cust_id  INT NOT NULL

ALTER TABLE market_fct
ADD CONSTRAINT FK4_market_fct FOREIGN KEY(Cust_id)
REFERENCES customer(Cust_id)

