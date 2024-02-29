

-- Converting the  String Sale_date to Date adding to the table

Alter table nashville_data 
add column date date;

update nashville_data
set date = str_to_date(sale_date,"%M %d,%Y");

-- Replacing "Y"/ "N" in sold_as_vacant to distinct "Yes" and "No"

update nashville_data
set sold_as_vacant = case when sold_as_vacant = "Y" then "Yes"
					 when sold_as_vacant = "N" then "No"
					 else sold_as_vacant
					 end ;

-- Handling the null values in property_address column

select a.property_address
from nashville_data a 
join nashville_data b 
on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
where a.property_address = '';

-- Updating the null values as property_address column with Address having the same parcel_id

update nashville_data a 
join nashville_data b on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
set a.property_address = null
where a.property_address = '';

update nashville_data a 
join nashville_data b 
on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
set a.property_address = ifnull(a.property_address,b.property_address)
where a.property_address is null;


-- Extracting the full property_address to Street and City

alter table nashville_data
add column property_address_street varchar(100);

alter table nashville_data
add column property_address_city varchar(100);

update nashville_data
set property_address_street = substring_index(property_address,',',1);

update nashville_data
set property_address_city = substring_index(property_address,',',-1);


-- Extracting the full owner_address to Street,City and State

alter table nashville_data
add column owner_street varchar(100);

update nashville_data 
set owner_street = substring_index(owner_address,',',1);

alter table nashville_data
add column owner_city varchar(100);

update nashville_data
set owner_city = Trim(substring_index(substring_index(owner_address,',',2),',',-1));

alter table nashville_data
add column owner_state varchar(100);

update nashville_data 
set owner_state = Trim(substring_index(owner_address,',',-1));

-- Checking Duplicates 

select * from 
(select *,
row_number() over (partition by parcel_id,property_address_city,property_address_street,date,legal_ref
                    order by parcel_id asc) as rn
from nashville_data)x
where x.rn > 1
order by unique_id; 

-- Deleting duplicate 

delete from nashville_data
where unique_id in 
              (select unique_id from 
              (select *,
              row_number() over(partition by  parcel_id,property_address_city,property_address_street,date,legal_ref
								order by parcel_id asc) as rn 
			   from nashville_data) x
			   where x.rn >1 
			   order by unique_id);

-- Droping unnecessary column 

alter table nashville_data 
drop column property_address,
drop column owner_address,
drop column tax_district,
drop column sale_date;

select * from nashville_data;







                   