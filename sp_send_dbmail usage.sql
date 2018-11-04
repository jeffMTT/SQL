--sp_send_dbmail
DECLARE @tableHTML NVARCHAR(MAX);
SET @tableHTML =
N'<H1>Work Order Report</H1>' +
N'<table border="1">' +
N'<tr><th>Work Order ID</th><th>Product ID</th>' +
N'<th>Name</th><th>Order Qty</th><th>Due Date</th>' +
N'<th>Expected Revenue</th></tr>' +
CAST ( ( SELECT td = wo.WorkOrderID, '',
td = p.ProductID, '',
td = p.Name, '',
td = wo.OrderQty, '',
td = wo.DueDate, '',
td = (p.ListPrice - p.StandardCost) * wo.OrderQty
FROM AdventureWorks.Production.WorkOrder as wo
JOIN AdventureWorks.Production.Product AS p
ON wo.ProductID = p.ProductID
WHERE DueDate > '2004-04-30'
AND DATEDIFF(dd, '2004-04-30', DueDate) < 2
ORDER BY DueDate ASC,
(p.ListPrice - p.StandardCost) * wo.OrderQty DESC
FOR XML PATH('tr'), TYPE
) AS NVARCHAR(MAX) ) +
N'</table>' ;

EXEC msdb.dbo.sp_send_dbmail @recipients='victor.isakov@sql.local',
@subject = 'Work Order List',
@body = @tableHTML,
@body_format = 'HTML'
ORDER BY days_past DESC;

--create a new operator
EXEC msdb.dbo.sp_add_operator @name=N'Victor Isakov',
@enabled=1,
@weekday_pager_start_time=90000,
@weekday_pager_end_time=180000,
@saturday_pager_start_time=90000,
@saturday_pager_end_time=180000,
@sunday_pager_start_time=90000,
@sunday_pager_end_time=180000,
@pager_days=0,
@email_address=N'victor.isakov@SQL.LOCAL',
@pager_address=N'marcus.isakov@SQL.LOCAL',
@category_name=N'[Microsoft Certified Architect]';
