--1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”, 
--“prod_dimen”, “shipping_dimen”, Create a new table, named as
--“combined_table”

SELECT *
FROM customer C
LEFT JOIN market_fct M
ON C.Cust_id = M.Cust_id
LEFT JOIN orders O
ON  O.Ord_id = M.Ord_id
LEFT JOIN product P 
ON P.Prod_id = M.Prod_id
LEFT JOIN shipping  S
ON S.Ship_id = M.Ship_id

WITH for_combined as(
			SELECT c.*,o.*,p.*,s.*,m.Sales,m.Discount,m.Order_Quantity,m.Product_Base_Margin
			, m.market_id
			FROM customer C
			LEFT JOIN market_fct M
			ON C.Cust_id = M.Cust_id
			LEFT JOIN orders O
			ON  O.Ord_id = M.Ord_id
			LEFT JOIN product P 
			ON P.Prod_id = M.Prod_id
			LEFT JOIN shipping  S
			ON S.Ship_id = M.Ship_id   )
SELECT * 
INTO combined_table
from for_combined ; 


SELECT * 
FROM combined_table

-- 2. Find the top 3 customers who have the maximum count of orders.

--WF KULLANILARAK : 

SELECT distinct m.Cust_id ,COUNT(o.Ord_id) OVER(PARTITION BY M.Cust_id) AS count_of_orders
FROM orders O , market_fct M
WHERE O.Ord_id = M.Ord_id 
order by count_of_orders desc

SELECT TOP 3 C.Cust_id ,C.Customer_Name ,A.count_of_orders
FROM customer C,(
					SELECT distinct m.Cust_id ,COUNT(o.Ord_id) OVER(PARTITION BY M.Cust_id) AS count_of_orders
					FROM orders O , market_fct M
					WHERE O.Ord_id = M.Ord_id 
					 ) A
WHERE C.Cust_id = A.Cust_id 
order by A.count_of_orders desc 


-- GROUP BY VE Oluþturduðumuz combined_table kullanýlarak : 

SELECT TOP (3) Customer_Name, cust_id, COUNT(Ord_id) total_ord
FROM combined_table
GROUP BY cust_id,customer_name
ORDER BY total_ord DESC

--3. Create a new column at combined_table as DaysTakenForDelivery that  
--contains the date difference of Order_Date and Ship_Date.

SELECT DATEDIFF(DAY,CT.Order_Date, CT.Ship_Date)  DaysTakenForDelivery
FROM combined_table CT


---DATEDIFF'in bize int döndürdüðünü hatýrlayalým !!!


ALTER TABLE combined_table
ADD DaysTakenForDelivery int

SELECT *
FROM combined_table

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY,Order_Date,Ship_Date)
		
--- bu sonuçta her satýr için bize  bu iþlemi yapacak !!!!!!!

SELECT *
FROM combined_table


--- hatta þöyle de yapabilirdik : 
/*
ALTER TABLE combined_table
ADD DaysTakenForDelivery int  burada datatype yazýyoruz ya hani bu int döndüreceði için zaten direk þunu da yaza-
bilirdik : 
            ALTER TABLE combined_table
			ADD DaysTakenForDelivery AS
			DATEDIFF(DAY, Order_Date, Ship_Date)   */

--4.) Find the customer whose order took the maximum time to get delivered.

SELECT TOP 1 C.Cust_id,C.Customer_Name,C.Ord_id,C.DaysTakenForDelivery
FROM combined_table C
ORDER BY C.DaysTakenForDelivery DESC
 

--5-)  Count the total number of unique customers in January and how many of them 
  --   came back every month over the entire year in 2011

SELECT MONTH(C.Order_Date) MONTH_ , COUNT(DISTINCT C.Cust_id ) unique_customer
FROM combined_table C
GROUP BY MONTH(C.Order_Date) 
HAVING MONTH(C.Order_Date) = 1         --- BU OCAK AYINDAKÝ UNIQUE CUSTOMERS SAYISI 


-- 2011 DE HER AY GELEN MÜÞTERÝLER KÝMLER NASIL BULURUZ ? 

SELECT MONTH(C.Order_Date) MONTH_ ,year(C.Order_Date) year_, COUNT(DISTINCT C.Cust_id) unique_customer
FROM combined_table C
GROUP BY MONTH(C.Order_Date),year(C.Order_Date)
HAVING year(C.Order_Date) = '2011'  

--------------------------------------------------------------------------------5 ÇÖZÜLMEDÝ??????
--6. Write a query to return for each user the time elapsed between the first 
-- purchasing and the third purchasing, in ascending order by Customer ID.
 
SELECT c.Cust_id,o.Ord_id,o.Order_Date
FROM customer c ,market_fct m,orders o
where c.Cust_id = m.Cust_id and o.Ord_id = m.Ord_id
ORDER BY C.Cust_id

SELECT c.Cust_id,o.Ord_id,o.Order_Date,
LEAD(O.Order_Date,2) OVER(PARTITION BY  c.Cust_id ORDER BY o.Order_Date)
FROM customer c ,market_fct m,orders o
where c.Cust_id = m.Cust_id and o.Ord_id = m.Ord_id
ORDER BY C.Cust_id




DATEDIFF(DAY,LEAD(O.Order_Date,2) OVER(PARTITION BY c.Cust_id,o.Ord_id ORDER BY o.Ord_id),O.Order_Date ) A

---------------- 6.SORUYU NUMBERÝNGLERÝ ÝZLEYÝNCE YAPALIM !!!!!!!



--7. Write a query that returns customers who purchased both product 11 and 
--product 14, as well as the ratio of these products to the total number of 
--products purchased by the customer

SELECT DISTINCT  CT.Cust_id,CT.Customer_Name
FROM combined_table CT         -- 11.ÜRÜNÜ SATIN ALAN MÜÞTERÝLER
WHERE  CT.Prod_id = 11 

INTERSECT        -- HEM 11'Ý HEM DE 14'Ü ALANLARI ARIYORUM BEN 

SELECT DISTINCT  CT.Cust_id,CT.Customer_Name
FROM combined_table CT          
WHERE  CT.Prod_id = 14            -- 14.ÜRÜNÜ SATIN ALAN MÜÞTERÝLER 

---19 KÝÞÝ HEM 11.ÜRÜNÜ HEM DE 14.ÜRÜNÜ ALMIÞ.

CREATE VIEW  COMMONPROD11_14 AS 
SELECT DISTINCT  CT.Cust_id,CT.Customer_Name
FROM combined_table CT        
WHERE  CT.Prod_id = 11 
INTERSECT       
SELECT DISTINCT  CT.Cust_id,CT.Customer_Name
FROM combined_table CT          
WHERE  CT.Prod_id = 14            

WITH RATIO_URUN AS(
				SELECT  CP.Cust_id , M.Prod_id,COUNT(M.Prod_id) OVER(PARTITION BY CP.Cust_id) kimkacurun_almis
				FROM COMMONPROD11_14 CP, market_fct M
				WHERE CP.Cust_id = M.Cust_id ) 
SELECT * , CASE r.kimkacurun_almis  
			when  r.kimkacurun_almis  THEN CAST(2 AS FLOAT) / CAST(r.kimkacurun_almis  as float) 
			end  as ratio
FROM RATIO_URUN r
order by kimkacurun_almis desc

---------------- BU SORUNUN NE ÝSTEDÝÐÝNE BÝR DAHA BAKILABÝLÝR !.

---------------------Customer Segmentation------------------------

--1. Create a “view” that keeps visit logs of customers on a monthly basis.
--(For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW logs_of_customer as 
SELECT CT.Cust_id ,YEAR(CT.Order_Date) YEAR_ ,MONTH(CT.Order_Date) MONTH_
FROM combined_table CT


SELECT * 
FROM logs_of_customer
ORDER BY 1,2,3

-- 2. Create a “view” that keeps the number of monthly visits by users. (Show 
--- separately all months from the beginning business)

CREATE VIEW monthly_visit_count as 
		SELECT  * , COUNT(*) OVER(PARTITION BY Cust_id ,YEAR_, MONTH_) num_of_monthly
		FROM customer_visit  --- bu view'ı kullandım .


SELECT * 
FROM monthly_visit_count


SELECT * ,DENSE_RANK() OVER(PARTITION BY Cust_id ORDER BY YEAR_ , MONTH_)
FROM monthly_visit_count


--3. For each visit of customers, create the next month of the visit as a separate  column

SELECT * 
FROM monthly_visit_count


SELECT  YEAR_, MONTH_,
		DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY [YEAR_] , [MONTH_])		
FROM	monthly_visit_count

-- cust_id partitiona alıp DENSE_RANK yapınca,
--CUSTOMER'A GÖRE; yıl ve ay ikililerine cust_id bazında numara vermiş oldum.
SELECT  *,
		DENSE_RANK () OVER (ORDER BY [YEAR_] , [MONTH_]) CURRENT_MONTH		
FROM	monthly_visit_count
ORDER BY 1,2,3


CREATE VIEW NEXT_VISIT AS
SELECT *,
		LEAD(CURRENT_MONTH, 1) OVER (PARTITION BY Cust_id ORDER BY CURRENT_MONTH) NEXT_VISIT_MONTH
FROM
(
SELECT  *,
		DENSE_RANK () OVER (ORDER BY [YEAR_] , [MONTH_]) CURRENT_MONTH
		
FROM	monthly_visit_count
) A

select *
from NEXT_VISIT



--4. Calculate the monthly time gap between two consecutive visits by each customer.

CREATE VIEW gaps AS
SELECT *,
		NEXT_VISIT_MONTH - CURRENT_MONTH time_gaps
FROM	NEXT_VISIT


select *
from gaps

--5. Categorise customers using average time gaps. Choose the most fitted
--labeling model for you.
--For example: 
--o Labeled as churn if the customer hasn't made another purchase in the 
--months since they made their first purchase.
--o Labeled as regular if the customer has made a purchase every month.
--Etc.

select * 
from gaps


SELECT cust_id, AVG(time_gaps) avg_time_gap
FROM gaps
GROUP BY cust_id
-- burada da her müşterinin alışverişleri arasında geçen ortalama zamanları getirdim.
	-- buna göre artık müşterilerin alışveriş yapma sıklıklarını görebiliyorum.

SELECT cust_id, avg_time_gap,
		CASE WHEN avg_time_gap = 1 THEN 'retained'
			WHEN avg_time_gap > 1 THEN 'irregular'
			WHEN avg_time_gap IS NULL THEN 'Churn'
			ELSE 'UNKNOWN' END CUST_LABELS
FROM
		(
		SELECT Cust_id, AVG(time_gaps) avg_time_gap
		FROM	gaps
		GROUP BY Cust_id
		) A

----------------------------------***************************************------------------------------
--Month-Wise Retention Rate
--Find month-by-month customer retention ratei since the start of the business.

--There are many different variations in the calculation of Retention Rate. But we will 
--try to calculate the month-wise retention rate in this project.
--So, we will be interested in how many of the customers in the previous month could 
--be retained in the next month.
--Proceed step by step by creating “views”. You can use the view you got at the end of 
--the Customer Segmentation section as a source.


--- 1. Find the number of customers retained month-wise. (You can use time gaps)
SELECT DISTINCT YEAR_,
				MONTH_,
				CURRENT_MONTH,
				NEXT_VISIT_MONTH,
				COUNT(cust_id) OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTION_MONTH_WISE
FROM			gaps
ORDER BY		NEXT_VISIT_MONTH


SELECT	DISTINCT cust_id, [YEAR_],
		[MONTH_],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		time_gaps,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	gaps
where	time_gaps =1
ORDER BY cust_id, NEXT_VISIT_MONTH


--2. Calculate the month-wise retention rate.

CREATE VIEW CURRENT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR_],
		[MONTH_],
		CURRENT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY CURRENT_MONTH) RETENTITON_MONTH_WISE
FROM     gaps

SELECT *
FROM	CURRENT_NUM_OF_CUST



CREATE VIEW NEXT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR_],
		[MONTH_],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	gaps
WHERE	time_gaps = 1
AND		CURRENT_MONTH > 1


SELECT DISTINCT
		B.[YEAR_],
		B.[MONTH_],
		B.CURRENT_MONTH,
		B.NEXT_VISIT_MONTH,
		1.0 * B.RETENTITON_MONTH_WISE / A.RETENTITON_MONTH_WISE RETENTION_RATE
FROM	CURRENT_NUM_OF_CUST A LEFT JOIN NEXT_NUM_OF_CUST B
ON		A.CURRENT_MONTH + 1 = B.NEXT_VISIT_MONTH





















