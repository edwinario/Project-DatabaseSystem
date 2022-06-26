
--1
SELECT  ms.StaffId , ms.StaffName , 
		ms.StaffAddress , msu.SupplierName, 
		[Total Purchase] = COUNT(distinct p.PurchaseId)
FROM MsStaff ms
	 JOIN Purchase p
	 ON ms.StaffId = p.StaffId
	 JOIN MsSupplier msu
	 ON msu.SupplierId = p.SupplierId
	 JOIN PurchaseDetail pd
	 ON p.PurchaseId = pd.PurchaseId
WHERE MONTH(p.PurchaseDate) = 11 AND CAST(RIGHT(ms.StaffId,1) AS INT) % 2 = 0
GROUP BY ms.StaffId, ms.StaffName, ms.StaffAddress,msu.SupplierName

--2
SELECT  s.SalesId, c.CustomerName, 
		[Total Sales Price] = SUM(sd.SalesQuantity * mc.ClothPrice)
FROM Sales s
	 JOIN MsCustomer c
	 ON s.CustomerId = c.CustomerId
	 JOIN SalesDetail sd
	 ON sd.SalesId = s.SalesId
	 JOIN MsCloth mc
	 ON mc.ClothId = sd.ClothId
WHERE c.CustomerName like '%m%'
GROUP BY s.SalesId, c.CustomerName
HAVING SUM(sd.SalesQuantity * mc.ClothPrice) > 2000000

--3
SELECT [Month] = DATENAME(MONTH,p.PurchaseDate), 
	   [Transaction Count] = COUNT(distinct p.PurchaseId),
	   [Material Sold Count] = SUM(pd.PurchaseQuantity)
FROM Purchase p
	 JOIN PurchaseDetail pd
	 ON p.PurchaseId = pd.PurchaseId
	 JOIN MsStaff s
	 ON s.StaffId = p.StaffId
	 JOIN MsMaterial m
	 ON m.MaterialId = pd.MaterialId
WHERE s.StaffAge BETWEEN 25 AND 30 
GROUP BY p.PurchaseDate
HAVING SUM(pd.PurchaseQuantity * m.MaterialPrice) > 150000

--4
SELECT [CustomerName] = LOWER(c.CustomerName), 
	   c.CustomerEmail, c.CustomerAddress,
	   [Cloth Bought Count] = SUM(sd.SalesQuantity), 
	   [Total Price] = 'IDR ' + CAST(SUM(sd.SalesQuantity * mc.ClothPrice) AS VARCHAR)
FROM MsCustomer c
	 JOIN Sales s
	 ON c.CustomerId = s.CustomerId
	 JOIN SalesDetail sd
	 ON sd.SalesId = s.SalesId
	 JOIN MsCloth mc
	 ON mc.ClothId = sd.ClothId
	 JOIN MsPayment p
	 ON p.PaymentTypeId = sd.PaymentTypeId
WHERE p.PaymentType in ('Cash','Shopee-Pay','Cryptocurrency')
GROUP BY c.CustomerName,c.CustomerEmail,c.CustomerAddress
go

--5
SELECT DISTINCT [PurchaseID] = RIGHT(p.PurchaseId,3), 
				p.PurchaseDate, s.StaffName, py.PaymentType
FROM Purchase p
JOIN PurchaseDetail pd
ON p.PurchaseId = pd.PurchaseId
JOIN MsStaff s
ON s.StaffId = p.StaffId
JOIN MsPayment py
ON py.PaymentTypeId = pd.PaymentTypeId, (
	SELECT [AvgSalary] = AVG(StaffSalary)
	FROM MsStaff
) AS salar
WHERE s.StaffSalary > salar.AvgSalary AND s.StaffGender LIKE 'Female' AND YEAR(GETDATE()) - s.StaffAge < 1996

--6
SELECT DISTINCT s.SalesId, 
				[SalesDate] = CONVERT(VARCHAR, s.SalesDate, 107), 
				c.CustomerName, c.CustomerGender
FROM Sales s
JOIN MsCustomer c
ON s.CustomerId = c.CustomerId
JOIN SalesDetail sd
ON sd.SalesId = s.SalesId , (
	SELECT [MinQ] = MIN(quantsum.sumQ)
	FROM SalesDetail sd
	JOIN Sales s
	ON sd.SalesId = s.SalesId,(
		SELECT [sumQ] = SUM(sd.SalesQuantity)
		FROM SalesDetail sd
		JOIN Sales s
		ON sd.SalesId = s.SalesId
		WHERE DAY(s.SalesDate) = 15
		GROUP BY sd.SalesId
	) AS quantsum
) AS quantmin
WHERE sd.SalesQuantity < quantmin.MinQ AND YEAR(s.SalesDate) = 2021

--7
SELECT PD.PurchaseId, SupplierName, 
	   [SupplierPhone] = STUFF(SupplierPhone , 1, 1,'+62'), 
	   [PurchaseDate] = DATENAME(WEEKDAY,PurchaseDate), 
	   [Quantity] = SUM(PurchaseQuantity)
FROM PurchaseDetail PD 
JOIN Purchase P 
ON P.PurchaseId = PD.PurchaseId 
JOIN MsSupplier MS 
ON MS.SupplierId = P.SupplierId
WHERE DATENAME(WEEKDAY, PurchaseDate) in ('Friday', 'Saturday', 'Sunday') 
GROUP BY PD.PurchaseId, SupplierName, SupplierPhone, PurchaseDate
HAVING SUM(PurchaseQuantity) > (
    SELECT AVG(TotalToCalculateAverage.[Total of Quantity per ID]) AS [Average Quantity]
    FROM (
        SELECT PurchaseId, SUM(PurchaseQuantity) AS [Total of Quantity per ID]
        FROM PurchaseDetail
        GROUP BY PurchaseId
    ) AS TotalToCalculateAverage
)

--8
SELECT [CustomerName] = 
	CASE
		WHEN c.CustomerGender = 'Male' THEN 'Mr. ' + c.CustomerName
		ELSE 'Mrs. ' + c.CustomerName
	END, 
	c.CustomerPhone, c.CustomerAddress,
	[CustomerDOB] = CONVERT(VARCHAR, c.CustomerDOB, 103), 
	[Cloth Count] = SUM(sd.SalesQuantity)
FROM Sales s
JOIN SalesDetail sd
ON s.SalesId = sd.SalesId
JOIN MsCustomer c
ON c.CustomerId = s.CustomerId , (
	SELECT TOP 1 [Maxq] = c.CustomerId
	FROM SalesDetail sd
	JOIN Sales s
	ON sd.SalesId = s.SalesId
	JOIN MsCustomer c
	ON c.CustomerId = s.CustomerId
	GROUP BY c.CustomerId
	ORDER BY SUM(sd.SalesQuantity) DESC
) AS highestquan
WHERE c.CustomerName LIKE '%o%' AND c.CustomerId = highestquan.Maxq
group by c.CustomerGender,c.CustomerName,c.CustomerPhone,c.CustomerAddress,c.CustomerDOB

--9
go
CREATE VIEW ViewCustomerTransaction
AS
SELECT c.CustomerId,c.CustomerName,c.CustomerEmail,c.CustomerDOB,
	  [Mininum Quantity] = MIN(sd.SalesQuantity),
	  [Maximum Quantity] = MAX(sd.SalesQuantity)
FROM MsCustomer c
	 JOIN Sales s
	 ON c.CustomerId = s.CustomerId
	 JOIN SalesDetail sd
	 ON sd.SalesId = s.SalesId
WHERE YEAR(c.CustomerDOB) >= 2000 AND c.CustomerEmail LIKE '%@yahoo.com'
GROUP BY c.CustomerId,c.CustomerName,c.CustomerEmail,c.CustomerDOB
go

--10
CREATE VIEW ViewFemaleStaffTransaction
AS
SELECT s.StaffId,
	   [StaffName] = UPPER(s.StaffName), 
	   [Staff Salary] = 'Rp ' + CAST(s.StaffSalary AS VARCHAR) + ',00',
	   [Material Bought Count] = CAST(COUNT(m.MaterialId) AS VARCHAR) + ' Pc(s)'
FROM MsStaff s
JOIN Purchase p
ON s.StaffId = p.StaffId
JOIN PurchaseDetail pd
ON pd.PurchaseId = p.PurchaseId
JOIN MsMaterial m
ON m.MaterialId = pd.MaterialId
WHERE s.StaffGender LIKE 'Female' AND s.StaffSalary > (
	SELECT [avg] = AVG(s.StaffSalary)
	FROM MsStaff s
)
GROUP BY s.StaffId,s.StaffName,s.StaffSalary
go