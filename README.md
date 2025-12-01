PROJECT 2 — Advanced SQL Analytics

A collection of advanced SQL analytical exercises built on the WideWorldImporters database.
This project demonstrates real-world data analysis techniques including CTEs, window functions, pivoting, customer behavior analysis, geographic segmentation, and profitability analysis.

📌 Dataset

Database: WideWorldImporters
Tables used include:

Sales.Invoices

Sales.InvoiceLines

Sales.Orders

Sales.Customers

Sales.CustomerCategories

Warehouse.StockItems

Purchasing.Suppliers

Application.Cities

Application.Countries

Application.StateProvinces

📊 Exercises Included
EX 1 — Yearly Income & Growth Rate

Aggregation per year

Liner monthly expansion

YoY growth calculation using self-joins

EX 2 — TOP 5 Customers per Quarter

Window function: DENSE_RANK()

Quarter analysis

Revenue segmentation

EX 3 — Top 10 Most Profitable Products

Profit = ExtendedPrice − Tax

Sorting by total profitability

EX 4 — Product Margin Ranking

ROW_NUMBER(), DENSE_RANK()

Nominal margin calculation

Filtering out expired products

EX 5 — Supplier and Product Catalog

STRING_AGG()

Supplier → Product relationships

EX 6 — Top 5 High-Value Customers by Geography

Joins across Customer → City → Country → Region

Total spending analysis

EX 7 — Monthly Cumulative Revenue Analysis

CTE

Window functions

UNION ALL for yearly totals

EX 8 — Pivot: Orders per Month by Year

PIVOT table

Monthly ordering patterns

EX 9 — Customer Behavior & Churn Detection

LAG()

Day gaps between orders

Rule-based churn classifier

EX 10 — Customer Categories Distribution

Category segmentation

Distribution factor (percentage)
