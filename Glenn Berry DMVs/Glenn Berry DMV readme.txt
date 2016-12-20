The basic instructions for using these queries is that you should run each query in the set, one at a time (after reading the directions for that query). It is not really a good idea to simply run the entire batch in one shot, especially the first time you run these queries on a particular server, since some of these queries can take some time to run, depending on your workload and hardware. I also think it is very helpful to run each query, look at the results (and my comments on how to interpret the results) and think about the emerging picture of what is happening on your server as you go through the complete set. I have quite a few comments and links in the script on how to interpret the results after each query.

After running each query, you need to click on the top left square of the results grid in SQL Server Management Studio (SSMS) to select all of the results, and then right-click and select “Copy with Headers” to copy all of the results, including the column headers to the Windows clipboard. Then you paste the results into the matching tab in the blank results spreadsheet.

About half of the queries are instance specific and about half are database specific, so you will want to make sure you are connected to a database that you are concerned about instead of the master system database. Running the database-specific queries while being connected to the master database is a very common mistake that I see people making when they run these queries.

Note: These queries are stored on Dropbox. I occasionally get reports that the links to the queries and blank results spreadsheets do not work, which is most likely because Dropbox is blocked wherever people are trying to connect.

I also occasionally get reports that some of the queries simply don’t work. This usually turns out to be an issue where people have some of their user databases in 80 compatibility mode, which breaks many DMV queries, or that someone is running an incorrect version of the script for their version of SQL Server.

It is very important that you are running the correct version of the script that matches the major version of SQL Server that you are running. There is an initial query in each script that tries to confirm that you are using the correct version of the script for your version of SQL Server. If you are not using the correct version of these queries for your version of SQL Server, some of the queries are not going to work correctly.

If you want to understand how to better run and interpret these queries, you should consider listening to my three related Pluralsight courses, which are SQL Server 2014 DMV Diagnostic Queries – Part 1 ,  SQL Server 2014 DMV Diagnostic Queries – Part 2 and SQL Server 2014 DMV Diagnostic Queries – Part 3. All three of these courses are pretty short and to the point, at 67, 77, and 68 minutes respectively. Listening to these three courses is really the best way to thank me for maintaining and improving these scripts…

Please let me know what you think of these queries, and whether you have any suggestions for improvements. Thanks!

http://www.sqlskills.com/blogs/glenn/sql-server-diagnostic-information-queries-for-october-2016/
