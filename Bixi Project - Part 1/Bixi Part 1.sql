/*
Bixi Project - Part 1 - Data Analysis in SQL
Daniel Mortensen
July 13, 2021
*/

-- Set default schema
USE bixi;


##################
### Question 1 ###
##################
-- 1. The total number of trips for the year of 2016.
SELECT COUNT(*)
FROM trips
WHERE YEAR(start_date) = 2016; -- 3,917,401

-- 2. The total number of trips for the year of 2017.
SELECT COUNT(*)
FROM trips
WHERE YEAR(start_date) = 2017; -- 4,666,765

-- 3. The total number of trips for the year of 2016 broken-down by month.
SELECT 
	MONTH(start_date) AS Month, 
    COUNT(*) AS Count
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY MONTH(start_date);
/*
month	count
4		189923
5		561077
6		631503
7		699248
8		672778
9		620263
10		392480
11		150129
*/

-- 4. The total number of trips for the year of 2017 broken-down by month.
SELECT 
	MONTH(start_date) AS Month, 
    COUNT(*) AS Count
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY MONTH(start_date);
/*
month	count
4		195662
5		587447
6		741835
7		860732
8		839938
9		731851
10		559506
11		149794
*/

-- 5. The average number of trips a day for each year-month combination in the dataset.
SELECT 
	year, 
    month, 
    (count / days_per_month) AS average_trips_per_day 
FROM 
(SELECT 
	YEAR(start_date) AS year, 
    MONTH(start_date) AS month, 
    COUNT(*) AS count,
    IF(MONTH(start_date)=4 OR MONTH(start_date)=6 OR MONTH(start_date)=9 OR MONTH(start_date)=11, 30, 31) AS days_per_month
FROM trips
GROUP BY YEAR(start_date), MONTH(start_date), days_per_month) AS sub_table;
/*
year	month	average_trips_per_day
2016	4	6330.7667
2016	5	18099.2581
2016	6	21050.1000
2016	7	22556.3871
2016	8	21702.5161
2016	9	20675.4333
2016	10	12660.6452
2016	11	5004.3000
2017	4	6522.0667
2017	5	18949.9032
2017	6	24727.8333
2017	7	27765.5484
2017	8	27094.7742
2017	9	24395.0333
2017	10	18048.5806
2017	11	4993.1333
*/

-- 6. Save your query results from the previous question (Q1.5) by creating a table called "working_table1".
CREATE TABLE working_table1 AS
SELECT 
	year, 
    month, 
    (count / days_per_month) AS average_trips_per_day 
FROM 
(SELECT 
	YEAR(start_date) AS year, 
    MONTH(start_date) AS month, 
    COUNT(*) AS count,
    IF(MONTH(start_date)=4 OR MONTH(start_date)=6 OR MONTH(start_date)=9 OR MONTH(start_date)=11, 30, 31) AS days_per_month
FROM trips
GROUP BY YEAR(start_date), MONTH(start_date), days_per_month) AS sub_table;

##################
### Question 2 ###
##################
-- 1. The total number of trips in the year 2017 broken-down by membership status (member/non-member).
SELECT 
	is_member, 
    IF(is_member = 0, "NO", "YES") AS member, 
    COUNT(*) AS count 
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY is_member
ORDER BY is_member ASC;
/*
is_member	member	COUNT(*)
0			NO		882083
1			YES		3784682
*/

-- 2. The fraction of total trips that were done by members for the year of 2017 broken-down by month.
SELECT 
	MONTH(start_date) AS month,
    COUNT(*) AS trips
FROM trips
WHERE (YEAR(start_date) = 2017) AND (is_member = 1)
GROUP BY MONTH(start_date)
ORDER BY is_member ASC;
/*
month	trips
4		163417
5		481540
6		599509
7		657865
8		656049
9		604358
10		483445
11		138499
*/


##################
### Question 4 ###
##################
-- 1. What are the names of the 5 most popular starting stations? Solve this problem without using a subquery.
SELECT 
	A.start_station_code, 
    COUNT(*) AS total_number_of_trips, 
    B.name
FROM trips AS A
LEFT JOIN stations AS B
ON A.start_station_code = B.code
GROUP BY A.start_station_code, B.name
ORDER BY total_number_of_trips DESC
LIMIT 5;
/*
26.922 seconds
start_station_code	total_number_of_trips	name
6100	97150	Mackay / de Maisonneuve
6184	81279	Métro Mont-Royal (Rivard / du Mont-Royal)
6078	78848	Métro Place-des-Arts (de Maisonneuve / de Bleury)
6136	76813	Métro Laurier (Rivard / Laurier)
6064	72298	Métro Peel (de Maisonneuve / Stanley)
*/

-- 2. Solve the same question as Q4.1, but now use a subquery. Is there a difference in query run time between 4.1 and 4.2?
SELECT 
	A.start_station_code, 
    A.count, 
    B.name 
FROM 
(SELECT trips.start_station_code, COUNT(*) AS count
FROM trips
GROUP BY start_station_code) AS A
LEFT JOIN stations AS B
ON A.start_station_code = B.code
ORDER BY A.count DESC
LIMIT 5;
/*
2.453 seconds
start_station_code	count	name
6100	97150	Mackay / de Maisonneuve
6184	81279	Métro Mont-Royal (Rivard / du Mont-Royal)
6078	78848	Métro Place-des-Arts (de Maisonneuve / de Bleury)
6136	76813	Métro Laurier (Rivard / Laurier)
6064	72298	Métro Peel (de Maisonneuve / Stanley)
*/


##################
### Question 5 ###
##################
-- 1. How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day?
SELECT 
	CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
	END AS start_time_of_day,
    CASE
       WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
	END AS end_time_of_day,
    COUNT(*) AS trip_count
FROM trips
WHERE start_station_code = (SELECT code FROM stations WHERE name = "Mackay / de Maisonneuve")
GROUP BY start_time_of_day, end_time_of_day
ORDER BY start_time_of_day, end_time_of_day;
/*
start_time_of_day	end_time_of_day	trip_count
afternoon	afternoon	28495
afternoon	evening	2223
evening	evening	35829
evening	night	952
morning	afternoon	917
morning	morning	16467
night	morning	68
night	night	12199
*/


##################
### Question 6 ###
##################
-- List all stations for which at least 10% of trips are round trips. Round trips are those that start and end in the same station. This time we will only consider
-- stations with at least 500 starting trips. (Please include answers for all steps outlined here)
-- 1. First, write a query that counts the number of starting trips per station.
SELECT start_station_code, COUNT(*)
FROM trips
GROUP BY start_station_code;

-- 2. Second, write a query that counts, for each station, the number of round trips.
SELECT start_station_code, count 
FROM
(SELECT start_station_code, COUNT(*) AS count, end_station_code
FROM trips
GROUP BY start_station_code, end_station_code) AS A
WHERE start_station_code = end_station_code;

-- 3. Combine the above queries and calculate the fraction of round trips to the total number of starting trips for each station.
SELECT 
	A.start_station_code, 
    countA AS total_trips, 
    countB AS round_trips, 
    countB / countA * 100 AS ratio
FROM
(SELECT start_station_code, COUNT(*) AS countA
FROM trips
GROUP BY start_station_code) AS A
LEFT JOIN 
(SELECT start_station_code, countB 
FROM
(SELECT start_station_code, COUNT(*) AS countB, end_station_code
FROM trips
GROUP BY start_station_code, end_station_code) AS sub_table
WHERE start_station_code = end_station_code) AS B
ON A.start_station_code = B.start_station_code;

-- 4. Filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips.
SELECT 
	A.start_station_code, 
    countA AS total_trips, 
    countB AS round_trips, 
    countB / countA * 100 AS ratio
FROM
(SELECT start_station_code, COUNT(*) AS countA
FROM trips
GROUP BY start_station_code) AS A
LEFT JOIN 
(SELECT start_station_code, countB 
FROM
(SELECT start_station_code, COUNT(*) AS countB, end_station_code
FROM trips
GROUP BY start_station_code, end_station_code) AS sub_table
WHERE start_station_code = end_station_code) AS B
ON A.start_station_code = B.start_station_code
HAVING total_trips >= 500 AND (countB / countA * 100) >= 10
ORDER BY ratio DESC;
/*
station_start_code	total_trips	round_trips	ratio
6501	28672	8658	30.1967
7048	2398	559	23.3111
6428	5246	1072	20.4346
7015	2991	600	20.0602
6736	1708	330	19.3208
6359	6201	1145	18.4648
7007	2439	437	17.9172
6714	3151	464	14.7255
6502	6138	882	14.3695
6109	6417	883	13.7603
6026	50822	5622	11.0621
6016	2719	300	11.0335
6429	8569	927	10.8181
5006	1439	144	10.0069
*/
CREATE TABLE round_trips AS
SELECT 
	A.start_station_code, 
    countA AS total_trips, 
    countB AS round_trips, 
    countB / countA * 100 AS ratio
FROM
(SELECT start_station_code, COUNT(*) AS countA
FROM trips
GROUP BY start_station_code) AS A
LEFT JOIN 
(SELECT start_station_code, countB 
FROM
(SELECT start_station_code, COUNT(*) AS countB, end_station_code
FROM trips
GROUP BY start_station_code, end_station_code) AS sub_table
WHERE start_station_code = end_station_code) AS B
ON A.start_station_code = B.start_station_code
HAVING total_trips >= 500 AND (countB / countA * 100) >= 10
ORDER BY ratio DESC;

SELECT 
	B.name, 
    A.total_trips, 
    A.round_trips, 
    A.ratio 
FROM round_trips AS A
LEFT JOIN stations AS B
ON A.start_station_code = B.code;
/*
name	total_trips	round_trips	ratio
Métro Jean-Drapeau	28672	8658	30.1967
Métro Angrignon	2398	559	23.3111
Berlioz / de l'Île des Soeurs	5246	1072	20.4346
LaSalle / 4e avenue	2991	600	20.0602
Basile-Routhier / Gouin	1708	330	19.3208
Parc Plage	6201	1145	18.4648
Gare Canora	2439	437	17.9172
LaSalle / Sénécal	3151	464	14.7255
Casino de Montréal	6138	882	14.3695
Quai de la navette fluviale	6417	883	13.7603
de la Commune / Place Jacques-Cartier	50822	5622	11.0621
Jacques-Le Ber / de la Pointe Nord	2719	300	11.0335
Place du Commerce	8569	927	10.8181
Collège Édouard-Montpetit	1439	144	10.0069
*/
