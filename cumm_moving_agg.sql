--Report 7
--What are the total listing price and cumulative total listing price of small properties in each year?
select 
    year as listing_year,
    SUM(total_listing_price) as total_listing_price,
    SUM(SUM(total_listing_price)) OVER (ORDER BY year ROWS UNBOUNDED PRECEDING) AS CUM_LISTING_PRICE
from listing_fact l, listing_time_dim t
where l.listing_time_id = t.listing_timeid
and prop_size = 'small'
group by year; 

--Report 8
--What is the total number of hosts joining and 3 years moving average of host joining every year?
select 
    year as host_join_year,
    SUM(h.num_of_hosts) as num_of_hosts,
    ROUND(AVG(SUM(h.num_of_hosts)) OVER (ORDER BY year ROWS 2 PRECEDING),2) AS MOVING_3_MON_AVG
from host_fact h, host_join_time_dim t
where h.host_join_time_id = t.timeid
group by year;