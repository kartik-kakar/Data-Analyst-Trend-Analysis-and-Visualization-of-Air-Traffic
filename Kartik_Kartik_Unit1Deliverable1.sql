use airtraffic;

-- To begin with, We start by using the airtraffic schema. 


select * from flights limit 20;
select * from airports;

-- I wrote these two begining queries to always have the column names in front of me to see which table to use for the following queries. 




-- QUESTION 1

-- Ques 1.1 How many flights were there in 2018 and 2019 separately?

select 
extract(year from FlightDate) as `year`, 
count(*) as total_flights_per_year       
from flights
where extract(year from FlightDate) in (2018, 2019)
group by `year`; 

-- There were a total of 3218653 flights in the year of 2018 and 3302708 in 2019. 




-- Ques 1.2 In total, how many flights were cancelled or departed late over both years?
-- First, I will see how many flights were cancelled over both years.

select 
count(*) as totalCancelledFlights
from flights
where (Cancelled = '1') and extract(year from FlightDate) in (2018, 2019);

select 
count(*) as totalDelayedFlights
from flights
where (DepDelay > '0') and extract(year from FlightDate) in (2018, 2019);

-- Over both 2018 and 2019, 92363 were Cancelled and 2542442 flights were Delayed. 




-- Ques 1.3 Show the number of flights that were cancelled broken down by the reason for cancellation.

select CancellationReason, count(*) as totalCancelledFlights
from flights
where Cancelled = '1'
group by CancellationReason
order by totalCancelledFlights;

-- Mostly flights were cancelled due to unfavourable weather conditions (50,225 flights). Least common reason was security issues with 35. 





-- Quest 1.4 For each month in 2019, report both the total number of flights and percentage of flights cancelled. Based on your results, what might you say about the cyclic nature of airline revenue?

select 
extract(month from FlightDate) as per_month,
count(*) as total_flights,
(sum(Cancelled) * 100 / count(*)) as percentage
from flights
where extract(year from FlightDate) = '2019'
group by per_month
order by per_month;


/*
This was the derived answer: 

   1	262165	2.2078
   2	237896	2.3128
   3	283648	2.4957
   4	274115	2.7102
   5	285094	2.4245
   6	282653	2.1836
   7	291955	1.5492
   8	290493	1.2475
   9	268625	1.2352
  10  	283815	0.8072
  11	266878	0.5920
  12	275371	0.5073

Based on this data, in different months of 2019, we can see a variety of percentages ranging between 0.5% - 2.7%. 
It appears that airline revenue exhibits a cyclic pattern. This could be due to seasonal factors like weather conditions, holidays and trends. 
*/




-- QUESTION 2
	

-- Ques 2.1 Create two new tables, one for each year (2018 and 2019) showing the total miles traveled and number of flights broken down by airline.
-- Firstly, we will make a new table for the year of 2018.

create table TotalMilesFlights2018 as
select Reporting_Airline as airlines,
count(*) as total_flights,
sum(Distance) as total_distance
from flights
where  extract(year from FlightDate) = '2018'
group by airlines;


select * from TotalMilesFlights2018;
-- This query was written to see the resulting table for analysis. 

/* In 2018, total DL flights were 949283 which travelled a total distance of 842409169 miles, 
followed by 916818 AA flights with a distance of 933094276 miles and 1352552 WN flights with 1012847097 miles.
*/

-- Following query will make an individual table for the year 2019. 

create table TotalMilesFlights2019 as
select Reporting_Airline as airlines,
count(*) as total_flights,
sum(Distance) as total_distance
from flights
where  extract(year from FlightDate) = '2019'
group by airlines;


select * from TotalMilesFlights2019;
-- This one will display the result of the previous query. 

/* In 2019, 991986 DL flights had an accumulated a distance of 889277534 miles, followed by 946776 AA flights and 
1363946 WN flights with 938328443 and 1011583832 miles respectively. 
*/




-- Ques 2.2 Using your new tables, find the year-over-year percent change in total flights and miles traveled for each airline.

select 
mf2018.airlines,
mf2018.total_flights as flights_in_2018,
mf2018.total_distance,
mf2019.total_flights as flights_in_2019,
mf2019.total_distance
from TotalMilesFlights2018 mf2018
join TotalMilesFlights2019 mf2019
on mf2018.airlines = mf2019.airlines;

-- Above query is an extra one just to join the 2 New tables we made in Ques 2.1 to look at the numbers and maybe have a broad understanding. 


/* Next to find out the year-over-year percentage change, I deducted the 2018 flights from 2019 ones * 100 and divided the whole by 2018 flights and named the calculation percentageChangeFlights. 
   Same thing with the total distance, named it percentageChangeMiles.
*/
select
mf2018.airlines,
mf2018.total_flights as flights2018, mf2018.total_distance,
mf2019.total_flights as flights2019, mf2019.total_distance,
((mf2019.total_flights - mf2018.total_flights) * 100 / mf2018.total_flights) as percentageChangeFlights,
((mf2019.total_distance - mf2018.total_distance) * 100 / mf2018.total_distance) as percentageChangeMiles
from TotalMilesFlights2018 as mf2018
join TotalMilesFlights2019 as mf2019
on mf2018.airlines = mf2019.airlines;

/*
This table is the result of above query: 

airlines     flights2018      total_distance      flights2019       total_distance        percentageChangeFlights         percentageChangeMiles
   AA	      916818	         933094276	        946776	           938328443	              3.2676	               0.5609472841734591
   DL	      949283	         842409169	        991986	           889277534	              4.4984	               5.563610502439818
   WN	      1352552	         1012847097	        1363946	           1011583832	              0.8424	              -0.12472415666113125
 
 Based on our result, here are some investmwent guidance for the fund managers:
 1. Fund Managers should consider investing in the airlines which show show a significant positive change over the years like the DL airlines. 
	They had the most increased percentage in no. of flights and total distance travelled. 
 2. They should also see why there was a negative change in the WN airlines and what they are doing to handle the situation. 
 3. AA airlines also showed a positive increase in total flights and distance. Although not as much as the DL flights, for investment purposes, 
	they shouldn't just invest in one airline, diversification in portfolio is necessary. 
*/





-- I wrote these queries again to avoid scrolling up to the top again and again. 

select * from flights limit 10 ;
select * from airports;




-- From now on, I noticed these queries taking longer time to execute than normal. 

-- QUESTION 3

-- Ques 3.1 What are the names of the 10 most popular destination airports overall?

select a.AirportName, count(*) as TotalFlights
from flights f
join airports a
on f.DestAirportID = a.AirportID
group by a.AirportName
order by TotalFlights desc
limit 10;


/* To find out the top 10 most popular destination airports, we will join the 2 two tables airports and flights through the AirportID in both tables. 
   "Hartsfield-Jackson Atlanta International" airport has the most no of incoming flights. 
*/



-- Ques 3.2 Answer the same question but using a subquery to aggregate & limit the flight data before your join with the airport information.

select a.AirportName, count(*) as TotalFlights
from airports a
join (select f.DestAirportID , count(*) as count
	  from flights f
      group by f.DestAirportID
      order by count desc
      limit 10) as kk
on a.AirportID = kk.DestAirportID
group by a.AirportName
order by TotalFlights desc;

/*
As per the requirement of the question, we get the same result from both the queries. But the 2nd one is much more efficient and has a less runtime because we
used a subquery before joing the airports table to the flights table (result called kk). Also, we limited the no of rows to 10 that needed to join to the airports table. 
*/




-- QUESTION 4

-- Ques 4.1 Determine the number of unique aircrafts each airline operated in total over 2018-2019.


select Reporting_Airline,
count(distinct Tail_Number) as Unique_planes
from flights
where extract(year from FlightDate) in ('2018', '2019')
group by Reporting_Airline;

-- We calculated the count of unique tail numbers fron the flights table which were active in the year of 2018 and 2019. AA had 993 followed by DL with 988 and WN 754.




-- Ques 4.2 What is the average distance traveled per aircraft for each of the three airlines?


select 
Reporting_Airline as airline,
count(distinct Tail_Number) as Unique_planes,
sum(Distance) / count(distinct Tail_Number) as avgDisPerPlane
from flights
where extract(year from FlightDate) in ('2018', '2019')
group by airline
order by Unique_planes desc;
   

/* We calculated the average distance per plane by dividing the sum of total distance of each airline by the unique tail count of each airline. 
A higher count of the airplanes of each airline suggests a higher equipment and maintenance costs. However, this could also mean that the WN 
airline with a lower count of 754 planes utilizes their planes more efficiently. They have the highest average distance travelled per aircraft. 

*/






-- QUESTION 5 In this question, we were given a "case when" function which categorizes the departure times in morning, afternoon, evening and night. 


-- Ques 5.1 Find the average departure delay for each time-of-day across the whole data set. Can you explain the pattern you see?


select 
	case when hour(CRSDepTime) between 7 and 11 then '1 - morning'
		 when hour(CRSDepTime) between 12 and 16 then '2 - afternoon'
	     when hour(CRSDepTime) between 17 and 21 then '3 - evening'
		 else "4 - night"
	end as"time_of_day",
avg(case when DepDelay < 0 then '0'
		 else DepDelay
         end) as Average_delay
from flights
group by time_of_day
order by time_of_day;

-- This query uses the case when function and calculates the average departure delay considering early departures and arrivals (negative values) 
-- as on-time (0 delay). Evenings have the highest delay followed by afternoons. Morning and Nights were super close in terms of average delay. 


-- Ques 5.2 Now, find the average departure delay for each airport and time-of-day combination.


select a.AirportName,
	case when hour(f.CRSDepTime) between 7 and 11 then '1 - morning'
		 when hour(f.CRSDepTime) between 12 and 16 then '2 - afternoon'
	     when hour(f.CRSDepTime) between 17 and 21 then '3 - evening'
		 else "4 - night"
	end as"time_of_day",
avg(case when f.DepDelay < 0 then '0'
		 else f.DepDelay
         end) as Average_delay
from flights f
join airports a
on  f.OriginAirportID = a.AirportID
group by a.AirportName, time_of_day
order by a.AirportName, time_of_day desc;

/*
This query finds the average departure delay in each airport broken down by different times (given in the question).
It considers early departure as on time (if its a negative value, it will consider it as 0), groups them by the airport name and time of day
order them in descending. 
*/


-- However this query takes a long time to process and sometimes was giving me error code 2013. Therefore, we will limit the result to make it more efficient in the following query. 


-- Ques 5.3 Next, limit your average departure delay analysis to morning delays and airports with at least 10,000 flights

select a.AirportName,
       avg(case when f.DepDelay < 0 then '0'
				else f.DepDelay 
				end) as Average_am_delays
from flights f
join airports a
on  f.OriginAirportID = a.AirportID
where hour(f.CRSDepTime) between 7 and 11
group by a.AirportName
having count(*) >= 10000
order by Average_am_delays desc;

/* In this query, we used an "average" funtion with a "case when" and limited our result to just the morning departure delays 
and took into account only those airports with atleast 10,000 flights or more. Then, grouped the result by the Airport name
and ordered the result by average morning delays in descending. "San Francisco International" had the most morning delays followed by 
"Chicago O'Hare International" and "Dallas/Fort Worth International".
*/



-- In the next query, we will remove the limit on flight count but calculate the the highest morning delays per airport along with their city names. 

-- Ques 5.4 Finally, name the top-10 airports with the highest average morning delay. In what cities are these airports located?

select a.AirportName, a.City,
       avg(case when f.DepDelay < 0 then '0'
				else f.DepDelay 
				end) as Average_am_delays
from flights f
join airports a
on  f.OriginAirportID = a.AirportID
where hour(f.CRSDepTime) between 7 and 11
group by a.AirportName, a.City
order by Average_am_delays desc
limit 10;

/*
This query gives the list of the top 10 airports with their respective cities with the highest overall average of morning departure delays.  
We grouped the result by the airport name as well as city names and got the top 10 results by ordering them and putting them in descending order
according to the morning delays. 
*/






