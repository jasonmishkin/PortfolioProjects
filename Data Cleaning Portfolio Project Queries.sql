/*

Cleanng Data in SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, Convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = Convert(date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, Charindex(',',PropertyAddress) - 1) as Address,
substring(PropertyAddress, Charindex(',',PropertyAddress) + 1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',',PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = substring(PropertyAddress, Charindex(',',PropertyAddress) + 1, len(PropertyAddress))

Select *
from PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with rownumCTE as (
Select *, 
	Row_number() over(
	Partition By parcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				Order by 
					UniqueID
					) as row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select * 
from rownumCTE
where row_num > 1
order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


