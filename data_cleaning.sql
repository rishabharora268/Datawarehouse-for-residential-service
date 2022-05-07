--Error 1

--Detecting Error

select count(*) from mstay.booking;

select count(*) from
(select distinct * from mstay.booking);

select booking_id, count(*)
from mstay.booking
group by booking_id
having count(*)>1;

--Booking Table contains a duplicate value

--Code to clean

create table booking as 
(select distinct * from mstay.booking);

--Verification

select count(*) from booking;

select count(*) from
(select distinct * from booking);

--Error 2 

select count(*) from mstay.host;

select count(*) from
(select distinct * from mstay.host);

select host_id, count(*)
from mstay.host
group by host_id
having count(*)>1;

--Host Table contains a duplicate value

--Code to clean

create table host as 
(select distinct * from mstay.host);

--Verification


select count(*) from host;

select count(*) from
(select distinct * from host);

--Error 3

select * from mstay.review
where booking_id not in (select booking_id from mstay.booking);

--Invalid booking id found in review table

--Code to Clean

create table review as 
(select * from mstay.review
where booking_id in (select booking_id from mstay.booking));

--Verification

select * from review
where booking_id not in (select booking_id from mstay.booking);

--Error 4

select * from mstay.listing
where prop_id not in (select prop_id from mstay.property);

select * from mstay.listing
where host_id not in (select host_id from mstay.host);

--Invalid prop_id and host_id found in listing

--Code to clean

create table listing as 
(
select * from mstay.listing
where prop_id in (select prop_id from mstay.property));

--Verification


select * from listing
where prop_id not in (select prop_id from mstay.property);

select * from listing
where host_id not in (select host_id from mstay.host);

--Error 5

select * from mstay.host_verification
where channel_id not in (select channel_id from mstay.channel);

select * from mstay.host_verification
where host_id not in (select host_id from mstay.host);

--invalid channel_id and host_id found in host verification table

--Code to clean

create table host_verification as
(select * from mstay.host_verification
where host_id in (select host_id from mstay.host));

--Verification


select * from host_verification
where channel_id not in (select channel_id from mstay.channel);

select * from host_verification
where host_id not in (select host_id from mstay.host);


--Error 6

select * from mstay.amenity where amm_id is null;

--Null values found in ammenity table primary key

--Code to clean

create table amenity as
(select * from mstay.amenity
where amm_id is not null);

--Verification


select * from amenity where amm_id is null;

--Error 7

select * from mstay.listing
where listing_price<0;

--Out of bound values found in listing

--Code to clean

delete from listing where listing_price<0;

--Verification


select * from listing
where listing_price<0;


