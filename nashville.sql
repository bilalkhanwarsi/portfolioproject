select * 
from Portfolioproject..nashville

--standarize date format

alter table Portfolioproject..nashville
add saledateconverted date;

update Portfolioproject..nashville
set saledateconverted = convert (date,SaleDate)

select saledateconverted 
from Portfolioproject..nashville

--populate property address data

select * 
from Portfolioproject..nashville
where PropertyAddress is null

select * 
from Portfolioproject..nashville
order by ParcelID

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.propertyaddress,b.PropertyAddress)
from Portfolioproject..nashville a
join Portfolioproject..nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress,b.PropertyAddress)
from Portfolioproject..nashville a
join Portfolioproject..nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



--breaking out address into individual columns (address,city,state)

select PropertyAddress
from Portfolioproject..nashville

select
substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as address
,substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress)) as address
from Portfolioproject..nashville


alter table Portfolioproject.dbo.nashville
add propertysplitaddress nvarchar(255);

Update Portfolioproject.dbo.nashville
set propertysplitaddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1)



alter table Portfolioproject.dbo.nashville
add propertysplitcity nvarchar(255);

Update Portfolioproject.dbo.nashville
set propertysplitcity = substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress))

--PARSENAME METHOD
select *
from Portfolioproject..nashville

select
PARSENAME(REPLACE(OwnerAddress , ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress , ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress , ',', '.'), 1)
from Portfolioproject..nashville 

alter table Portfolioproject.dbo.nashville
add ownerssplitaddress nvarchar(255);

Update Portfolioproject.dbo.nashville
set ownerssplitaddress = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 3)

alter table Portfolioproject.dbo.nashville
add ownersplitcity nvarchar(255);

Update Portfolioproject.dbo.nashville
set ownerssplitcity = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 2)

alter table Portfolioproject.dbo.nashville
add ownerysplitstate nvarchar(255);

Update Portfolioproject.dbo.nashville
set ownerysplitstate = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 1)

select*
from Portfolioproject..nashville

--change Y and N to Yes and No in "sold in Vacant" field

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from Portfolioproject..nashville


select distinct (SoldAsVacant),count(SoldAsVacant)
from Portfolioproject..nashville
group by SoldAsVacant
order by 2

update Portfolioproject..nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end




--remove duplicate 

with RowNumCTE as(
select *,
ROW_NUMBER()over (
partition by parcelid,
propertyaddress,
saleprice,
saledate,
legalreference
order by 
uniqueid
) row_num 
from Portfolioproject..nashville
)
delete 
from RowNumCTE
where row_num > 1


--delete unused coloumns

alter table Portfolioproject..nashville
drop column OwnerAddress, Taxdistrict, PropertyAddress, ownerysplitaddress

alter table Portfolioproject..nashville
drop column saledate

select * 
from Portfolioproject..nashville
