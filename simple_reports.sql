--Report 1 
--Show the Top 5 years when the maximum number of hosts registered for each location.
select * from
(select 
    host_location,
    year as join_year,
    sum(num_of_hosts) as num_of_hosts,
    RANK() OVER (PARTITION BY host_location ORDER BY sum(num_of_hosts) DESC) AS RANK_BY_LOCATION
from host_fact h, host_join_time_dim t
where h.host_join_time_id = t.timeid
group by host_location, year)
where rank_by_location<=5;


--Report 2
--Show the years where Top 30% of properties are listed by season.
select * 
from
(
select 
    season,
    year,
    sum(number_of_prop_listed) as number_of_prop_listed,
    PERCENT_RANK() OVER (PARTITION BY season ORDER BY sum(number_of_prop_listed) DESC) AS RANK_BY_SEASON
from listing_fact l, listing_time_dim t
where t.listing_timeid = l.listing_time_id
group by season,year)
where rank_by_season>0.7;


    