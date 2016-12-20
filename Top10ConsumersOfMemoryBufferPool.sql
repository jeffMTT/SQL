-- Top 10 consumers of memory from Buffer Pool
SELECT TOP 10
    [type]
  , SUM(single_pages_kb) AS memory_in_kb
FROM
    sys.dm_os_memory_clerks
GROUP BY
    type
ORDER BY
    SUM(single_pages_kb) DESC ;