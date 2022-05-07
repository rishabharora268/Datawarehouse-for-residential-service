--Creating LISTING_TYPE Dimension
create table listing_type_dim as
select * from MSTAY.listing_type;

select * from listing_type_dim;

--Creating LISTING_TIME Dimension


create table listing_time_dim as 
select distinct
to_char(listing_date, 'YYYYMM') as listing_timeID,
to_char(listing_date, 'MM') as Month,
to_char(listing_date, 'YYYY') as Year
from listing;

select * from listing_time_dim;

--Creating LISTING_SEASON Dimension

create table listing_season
(season varchar(10),
season_description varchar2(10));

insert into listing_season values ('Spring', 'Sep-Nov');
insert into listing_season values ('Summer', 'Dec-Feb');
insert into listing_season values ('Autumn', 'Mar-May');
insert into listing_season values ('Winter', 'Jun-Aug');

select * from listing_season;


--Creating LISTING_MAX_STAY Dimension

create table max_stay_dim
(duration varchar(10),
duration_description varchar2(30));

insert into max_stay_dim values ('short', 'less than 14 nights');
insert into max_stay_dim values ('medium', '14 to 30 nights');
insert into max_stay_dim values ('long', 'more than 30 nights');

select * from max_stay_dim;

--Creating PROPERTY_SIZE Dimension

create table prop_size_dim
(prop_size varchar(10),
size_description varchar(50));

insert into prop_size_dim values ('small', 'minimum of 1 bed and 1 bedroom');
insert into prop_size_dim values ('medium', 'minimum of 3 beds and 2 bedrooms');
insert into prop_size_dim values ('large', 'more than 5 beds and more than 3 bedrooms');

select * from  prop_size_dim;

--Creating RATING Dimension

create table rating_dim
(rating varchar(5),
rating_description varchar2(15));

insert into rating_dim values ('0-1', 'Poor');
insert into rating_dim values ('1-2', 'Not Good');
insert into rating_dim values ('2-3', 'Average');
insert into rating_dim values ('3-4', 'Good');
insert into rating_dim values ('4-5', 'Excellent');

select * from rating_dim;

--Creating HOST_LOCATION Dimension

create table host_loc_dim as 
select distinct host_location
from host;

select * from host_loc_dim;

--Creating HOST_JOIN_TIME dimension

create table host_join_time_dim as 
select distinct
to_char(host_since, 'YYYYMM') as TimeID,
to_char(host_since, 'MM') as Month,
to_char(host_since, 'YYYY') as Year
from host;

select * from host_join_time_dim;

--Creating HOST dimension 

create table host_dim as
select h.host_id,
       h.host_name,
       1.0/count(v.channel_id) as WeightFactor,
       LISTAGG (c.channel_name, '_') Within Group (Order By c.channel_name) as channel_list
from host h, host_verification v, mstay.channel c
where h.host_id = v.host_id
and v.channel_id = c.channel_id
group by h.host_id,h.host_name;

select * from host_dim;
       

--Creating HOST_VERIFICATION_BRIDGE

create table host_verf_bridge as
select * from host_verification;

select * from host_verf_bridge;

--Creating HOST_CHANNEL Dimension

create table host_channel_dim as 
select * from mstay.channel;

select * from host_channel_dim;

--Creating LISTING Fact
drop table temp_listing_fact;
create table temp_listing_fact as
select
    l.listing_id,
    l.listing_price,
    l.listing_max_nights,
    l.listing_date,
    p.prop_num_beds,
    p.prop_num_bedrooms,
    p.prop_average_rating,
    t.type_id,
    h.host_location
from listing l, mstay.listing_type t, host h, mstay.property p
where l.type_id = t.type_id
and l.host_id = h.host_id
and l.prop_id = p.prop_id;

select * from temp_listing_fact;

alter table temp_listing_fact
add duration varchar(10);

alter table temp_listing_fact
add listing_time_id varchar(6);

alter table temp_listing_fact
add prop_size varchar(10);

alter table temp_listing_fact
add rating varchar(10);

alter table temp_listing_fact
add season varchar(10);

select * from temp_listing_fact;

update temp_listing_fact
set duration = 'long'
where listing_max_nights > 30;

update temp_listing_fact
set duration = 'short'
where listing_max_nights < 14;

update temp_listing_fact
set duration = 'medium'
where duration is null;

update temp_listing_fact
set listing_time_id = to_char(listing_date, 'YYYYMM');

update temp_listing_fact
set prop_size = 'medium'
where prop_num_beds <=5 and prop_num_beds >=3
and prop_num_bedrooms <=3 and prop_num_bedrooms >=2;

update temp_listing_fact
set prop_size = 'large'
where prop_num_beds >5
and prop_num_bedrooms >3;

update temp_listing_fact
set prop_size = 'small'
where prop_size is null;

update temp_listing_fact
set rating = '1-star'
where prop_average_rating > 0 and prop_average_rating <=1;

update temp_listing_fact
set rating = '2-star'
where prop_average_rating > 1 and prop_average_rating <=2;

update temp_listing_fact
set rating = '3-star'
where prop_average_rating > 2 and prop_average_rating <=3;

update temp_listing_fact
set rating = '4-star'
where prop_average_rating > 3 and prop_average_rating <=4;

update temp_listing_fact
set rating = '5-star'
where prop_average_rating > 4;

update temp_listing_fact
set season = 'Spring'
where to_char(listing_date, 'MM') in ('09','10','11');

update temp_listing_fact
set season = 'Summer'
where to_char(listing_date, 'MM') in ('12','01','02');

update temp_listing_fact
set season = 'Autumn'
where to_char(listing_date, 'MM') in ('03','04','05');

update temp_listing_fact
set season = 'Winter'
where to_char(listing_date, 'MM') in ('06','07','08');

create table listing_fact as 
select
    listing_time_id,
    duration,
    prop_size,
    rating,
    season,
    host_location,
    type_id,
    count(*) as number_of_prop_listed,
    sum(listing_price) as total_listing_price
from temp_listing_fact
group by duration, listing_time_id, prop_size, rating, season, host_location, type_id;

select * from listing_fact;

--Creating PROPERTY Fact

create table temp_prop_fact as 
select prop_id,
       prop_average_rating,
       prop_num_beds,
       prop_num_bedrooms
from mstay.property;

alter table temp_prop_fact
add prop_size varchar(10);

alter table temp_prop_fact
add rating varchar(10);

update temp_prop_fact
set rating = '1-star'
where prop_average_rating > 0 and prop_average_rating <=1;

update temp_prop_fact
set rating = '2-star'
where prop_average_rating > 1 and prop_average_rating <=2;

update temp_prop_fact
set rating = '3-star'
where prop_average_rating > 2 and prop_average_rating <=3;

update temp_prop_fact
set rating = '4-star'
where prop_average_rating > 3 and prop_average_rating <=4;

update temp_prop_fact
set rating = '5-star'
where prop_average_rating > 4;

update temp_prop_fact
set prop_size = 'medium'
where prop_num_beds <=5 and prop_num_beds >=3
and prop_num_bedrooms <=3 and prop_num_bedrooms >=2;

update temp_prop_fact
set prop_size = 'large'
where prop_num_beds >5
and prop_num_bedrooms >3;

update temp_prop_fact
set prop_size = 'small'
where prop_size is null;

create table property_fact as
select 
    prop_size,
    rating,
    count(*) as num_of_properties
from temp_prop_fact
group by prop_size, rating;

select * from property_fact;

--Creating HOST Fact

create table temp_host_fact as
select 
    host_id,
    host_since,
    host_location
from host;

alter table temp_host_fact
add host_join_time_id varchar(6);

update temp_host_fact
set host_join_time_id = to_char(host_since, 'YYYYMM');

create table host_fact as
select 
    host_id,
    host_join_time_id,
    host_location,
    count(*) as num_of_hosts
from temp_host_fact
group by host_id, host_join_time_id, host_location;
    
select * from host_fact;








