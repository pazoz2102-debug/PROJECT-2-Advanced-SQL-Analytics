--- PROJECT 2 ---
-------------------------------------------------------

--*** EX 1 ***
;WITH y AS
(
    SELECT 
        YEAR(si.InvoiceDate) AS [YEAR],
        SUM(sil.ExtendedPrice) AS [IncomePerYear],
        COUNT(DISTINCT MONTH(si.InvoiceDate)) AS [NumberOfDistinctMonths],
        SUM(sil.ExtendedPrice) * 12 / NULLIF(COUNT(DISTINCT MONTH(si.InvoiceDate)), 0) AS [YearlyLinearIncome]
    FROM Sales.Invoices SI 
    JOIN Sales.InvoiceLines SIL ON si.InvoiceID = sil.InvoiceID
    GROUP BY YEAR(si.InvoiceDate)
)
SELECT 
    y.[year], 
    y.IncomePerYear, 
    y.NumberOfDistinctMonths,
    y.YearlyLinearIncome,
    CAST(100 * (y.YearlyLinearIncome - yp.YearlyLinearIncome) / NULLIF(yp.YearlyLinearIncome, 0) AS decimal(18,2)) AS GrowthRate
FROM y
LEFT JOIN y AS yp ON yp.[year] = y.[year] - 1
ORDER BY y.[year];
-------------------------------------------------------

--*** EX 2 ***
SELECT t.[year], t.TheQuarter, t.CustomerName, t.IncomePerYear, t.dnr
FROM  
( 
    SELECT 
        s.[year], 
        s.TheQuarter, 
        s.CustomerName, 
        s.IncomePerYear,
        DENSE_RANK() OVER (PARTITION BY s.[year], s.TheQuarter ORDER BY s.IncomePerYear DESC) AS DNR
    FROM  
    ( 
        SELECT 
            YEAR(si.InvoiceDate) AS [year],
            DATEPART(Q, si.InvoiceDate) AS TheQuarter,
            c.CustomerName,
            SUM(sil.ExtendedPrice) AS IncomePerYear
        FROM Sales.Invoices SI 
        JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
        JOIN Sales.Customers c ON si.CustomerID = c.CustomerID
        GROUP BY YEAR(si.InvoiceDate), DATEPART(Q, si.InvoiceDate), c.CustomerName
    ) AS s  
) AS T 
WHERE t.dnr <= 5 
ORDER BY 1,2,5;
-------------------------------------------------------

--*** EX 3 ***
SELECT TOP (10)
    sil.StockItemID, 
    wsi.StockItemName,
    SUM(sil.ExtendedPrice - sil.TaxAmount) AS [TotalProfit]
FROM Sales.InvoiceLines AS SIL 
JOIN Warehouse.StockItems WSI ON SIL.StockItemID = WSI.StockItemID
GROUP BY sil.StockItemID, wsi.StockItemName
ORDER BY [TotalProfit] DESC;
-------------------------------------------------------

--*** EX 4 ***
SELECT
    ROW_NUMBER() OVER (ORDER BY (wsi.RecommendedRetailPrice - wsi.UnitPrice) DESC) AS RN,
    wsi.StockItemID,
    wsi.StockItemName,
    wsi.UnitPrice, 
    wsi.RecommendedRetailPrice,
    CAST(wsi.RecommendedRetailPrice - wsi.UnitPrice AS decimal(18,2)) AS NominalProductProfit,
    DENSE_RANK() OVER (ORDER BY (wsi.RecommendedRetailPrice - wsi.UnitPrice) DESC) AS DNR
FROM Warehouse.StockItems AS wsi
WHERE wsi.ValidTo > SYSDATETIME()
ORDER BY RN;
-------------------------------------------------------

--*** EX 5 ***
SELECT
    CONCAT(s.SupplierID, ' - ', s.SupplierName) AS SupplierDetails,
    STRING_AGG(CONCAT(si.StockItemID, ' ', si.StockItemName), ', / ')
        WITHIN GROUP (ORDER BY si.StockItemID) AS ProductDetails
FROM Purchasing.Suppliers AS s
JOIN Warehouse.StockItems AS si ON si.SupplierID = s.SupplierID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY s.SupplierID;
-------------------------------------------------------

--*** EX 6 ***
;WITH EX AS 
(
    SELECT 
        si.CustomerID, 
        SUM(sil.ExtendedPrice) AS TotalExtendedPrice
    FROM Sales.InvoiceLines AS SIL 
    JOIN Sales.Invoices AS SI ON sil.InvoiceID = si.InvoiceID
    GROUP BY si.CustomerID
)
SELECT TOP (5)
    a.CustomerID,
    ac.CityName,
    ac1.CountryName,
    ac1.Continent,
    ac1.Region,
    a.TotalExtendedPrice
FROM EX AS a 
JOIN Sales.Customers AS c ON c.CustomerID = a.CustomerID
JOIN Application.Cities AS ac ON ac.CityID = c.DeliveryCityID
JOIN Application.StateProvinces AS asp ON asp.StateProvinceID = ac.StateProvinceID
JOIN Application.Countries AS ac1 ON ac1.CountryID = asp.CountryID
ORDER BY a.TotalExtendedPrice DESC;
-------------------------------------------------------

--*** EX 7 ***
;WITH y AS 
(
    SELECT 
        YEAR(si.InvoiceDate) AS OrderYear, 
        MONTH(si.InvoiceDate) AS OrderMonth,
        SUM(sil.ExtendedPrice) AS MonthlyTotal
    FROM Sales.Invoices si 
    JOIN Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
    GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)
)
SELECT 
    OrderYear, 
    OrderMonth, 
    MonthlyTotal,
    SUM(MonthlyTotal) OVER (PARTITION BY OrderYear ORDER BY OrderMonth ROWS UNBOUNDED PRECEDING) AS CumulativeTotal
FROM y

UNION ALL

SELECT 
    OrderYear, 
    NULL, 
    SUM(MonthlyTotal), 
    SUM(MonthlyTotal)
FROM y
GROUP BY OrderYear
ORDER BY OrderYear, OrderMonth;
-------------------------------------------------------

--*** EX 8 ***
SELECT m, [2013], [2014], [2015], [2016]
FROM 
(
    SELECT 
        YEAR(so.OrderDate) AS y, 
        MONTH(so.OrderDate) AS m, 
        so.OrderID
    FROM Sales.Orders AS so
) k
PIVOT 
(
    COUNT(OrderID) FOR y IN ([2013], [2014], [2015], [2016])
) t
ORDER BY 1;
-------------------------------------------------------
--*** EX 9 ***
;WITH orders AS 
(
    SELECT 
        o.CustomerID, 
        c.CustomerName, 
        o.OrderDate,
        LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate) AS PreviousOrderDate,
        DATEDIFF(
            day,
            LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate),
            o.OrderDate
        ) AS DaysSinceLastOrder
    FROM Sales.Orders o 
    JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
),
avg_gaps AS 
(
    SELECT 
        CustomerID,
        AVG(CAST(DaysSinceLastOrder AS float)) AS AvgDaysBetweenOrders
    FROM orders
    WHERE DaysSinceLastOrder IS NOT NULL
    GROUP BY CustomerID
)
SELECT 
    o.CustomerID,
    o.CustomerName,
    o.OrderDate,
    o.PreviousOrderDate,
    o.DaysSinceLastOrder,
    CAST(a.AvgDaysBetweenOrders AS int) AS AvgDaysBetweenOrders,
    CASE
        WHEN o.DaysSinceLastOrder > 2 * a.AvgDaysBetweenOrders THEN 'Potential Churn'
        ELSE 'Active'
    END AS CustomerStatus
FROM orders o 
LEFT JOIN avg_gaps a ON a.CustomerID = o.CustomerID
ORDER BY o.CustomerID, o.OrderDate;
-------------------------------------------------------

--*** EX 10 ***
;WITH g AS 
(
    SELECT 
        cc.CustomerCategoryName,
        COUNT(*) AS CustomerCount
    FROM Sales.Customers c  
    JOIN Sales.CustomerCategories cc
        ON cc.CustomerCategoryID = c.CustomerCategoryID
    WHERE 
        c.CustomerID = c.BillToCustomerID 
        AND c.ValidTo > SYSDATETIME()               
    GROUP BY cc.CustomerCategoryName
)
SELECT TOP (5)
    CustomerCategoryName,
    CustomerCount,
    SUM(CustomerCount) OVER () AS TotalCustCount,
    100.0 * CustomerCount / SUM(CustomerCount) OVER () AS DistributionFactor
FROM g
ORDER BY CustomerCount DESC;
