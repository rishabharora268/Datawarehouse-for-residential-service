--Report 3
--What are the subtotals and total listing price from each listing type, season, and listing duration?

select DECODE(GROUPING(t.type_description), 1, 'All listing types', t.type_description) AS listing_type,
       DECODE(GROUPING(season), 1, 'All seasons', season) AS season,
       DECODE(GROUPING(duration), 1, 'All durations', duration) AS duration,
       sum(total_listing_price) as total_listing_price
from listing_fact l, listing_type_dim t
where l.type_id = t.type_id
group by cube(t.type_description, season, duration);

--Report 4
--What are the subtotals and total listing price from each listing type and listing duration for each season?
select DECODE(GROUPING(season), 1, 'All seasons', season) AS season,
       DECODE(GROUPING(t.type_description), 1, 'All listing types', t.type_description) AS listing_type,
       DECODE(GROUPING(duration), 1, 'All durations', duration) AS duration,
       sum(total_listing_price) as total_listing_price
from listing_fact l, listing_type_dim t
where l.type_id = t.type_id
group by season, cube(t.type_description, duration);

--Report 5
--What are the subtotals and total listing price from each property size and rating?
select
    DECODE(GROUPING(prop_size), 1, 'All sizes', prop_size) AS prop_size,
    DECODE(GROUPING(rating), 1, 'All ratings', rating) AS rating,
    sum(num_of_properties) as total_listing_price
from property_fact
group by rollup(prop_size,rating);


--Report 6
--What are the subtotals and total listing price from season and property size for each year?
select
    year AS listing_year,
    DECODE(GROUPING(prop_size), 1, 'All sizes', prop_size) AS prop_size,
    DECODE(GROUPING(season), 1, 'All seasons', season) AS season,    
    sum(total_listing_price) as total_listing_price
from listing_fact l,listing_time_dim t
where l.listing_time_id = t.listing_timeid
group by year, rollup(prop_size,season);


    
