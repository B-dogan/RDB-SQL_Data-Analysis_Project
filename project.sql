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

----------------------------------------------------- ilk commit