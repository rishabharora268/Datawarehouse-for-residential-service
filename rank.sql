--Report 9
--Show ranking of each property size and ranking of each property rating based on the total number of properties. 
select 
    prop_size,
    rating,
    sum(num_of_properties),
    RANK() OVER (PARTITION BY prop_size ORDER BY SUM(num_of_properties) DESC) AS RANK_BY_SIZE,
    RANK() OVER (PARTITION BY rating ORDER BY SUM(num_of_properties) DESC) AS RANK_BY_RATING
from property_fact
group by prop_size, rating;


--Report 10
--Show ranking of each listing type and ranking of each season based on the average listing price.
select 
    type_description as listing_type,
    season,
    round(sum(total_listing_price)/sum(number_of_prop_listed),2) as average_listing_price,
    RANK() OVER (PARTITION BY type_description ORDER BY sum(total_listing_price)/sum(number_of_prop_listed) DESC) AS RANK_BY_LISTING_TYPE,
    RANK() OVER (PARTITION BY season ORDER BY sum(total_listing_price)/sum(number_of_prop_listed) DESC) AS RANK_BY_SEASON
from listing_fact l, listing_type_dim t
where l.type_id = t.type_id
group by type_description, season;

    