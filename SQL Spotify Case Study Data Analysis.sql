------------------------------------------------------------------Spotify Case study-------------------------------------------------------------------------------

----Spotify Case study Data Analyst

USE Namaste_Sql_2_db;

CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from activity;
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

SELECT * FROM activity;

/*
-----Question-01 : FIND THE TOTAL ACTIVE USERS EACH DAY

Event_Date       Total_Active_Users
2022-01-01
2022-01-02
2022-01-03
2022-01-04

*/

SELECT event_date,COUNT(DISTINCT USER_ID) AS Total_Active_Users FROM activity
GROUP BY event_date;

-----Question-02 : FIND THE TOTAL ACTIVE USERS EACH Week

SELECT DATEPART(WEEK,event_date) AS Week_Number
,COUNT(DISTINCT USER_ID) AS Total_Active_Users FROM activity
GROUP BY DATEPART(WEEK,event_date);
/*
Week_Number        Total_Active_Users
1	                     3
2	                     5
*/

----- Question -03: Date wise total no of Users who made the purchase same day they installed the app
/*
2022-01-01       0
2022-01-02       0
2022-01-03       2
2022-01-04       1
*/
SELECT * FROM activity;

WITH CTE_1 AS
(SELECT USER_ID,event_date,COUNT(DISTINCT event_name) AS no_of_events
FROM activity
GROUP BY USER_ID,event_date
HAVING COUNT(DISTINCT event_name) = 2)
SELECT event_date,COUNT(USER_ID) AS no_of_users
FROM CTE_1
GROUP BY event_date;

/*
event_date   no_of_events
2022-01-03	   2
2022-01-04	   1
*/

/*
----- Question -04:  Percentage of paid users in india , USA and any other country should be tagged 
as other country percentage_users

India   40
USA     20
Others  40
*/

SELECT * FROM activity;


WITH Country_Users AS
(SELECT CASE WHEN country In ('USA','India') THEN country ELSE 'Others' END AS New_Country
,COUNT(DISTINCT user_id) AS User_cnt
FROM activity
WHERE event_name = 'app-purchase'
GROUP BY CASE WHEN country In ('USA','India') THEN country ELSE 'Others' END)
,Total AS (SELECT SUM(User_cnt) as Total_Cnt FROM Country_Users)

SELECT 
New_Country,User_cnt*1.0/Total_Cnt * 100 AS Per_User
FROM Country_Users,Total

/*
--- Question : 5  : Among all the users who installed the app on a given day,
How many did in app purchased on the very next day.

--- Day wise Result

Event Date   Cnt Users
2022-01-01      0
2022-01-02      1
2022-01-03      0
2022-01-04m     0

*/

SELECT * FROM activity;

WITH Prev_data AS
(SELECT *,
LAG(event_name,1) OVER(PARTITION BY user_id ORDER BY event_date) AS prev_event_name,
LAG(event_date,1) OVER(PARTITION BY user_id ORDER BY event_date) AS prev_event_date
FROM 
activity)
SELECT event_date,COUNT(DISTINCT user_id) AS Cnt_Users FROM 
Prev_data
WHERE event_name = 'app-purchase' AND prev_event_name = 'app-installed' AND DATEDIFF(DAY,prev_event_date,event_date) = 1
GROUP BY event_date;




