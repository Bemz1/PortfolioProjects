/*
Cleaning Data in SQL
*/

select *
from [PortfolioProject].[dbo].[NashvilleHousing]

-- Standardize Date Format

select SaleDateConverted
from [PortfolioProject].[dbo].[NashvilleHousing]

update [PortfolioProject].[dbo].[NashvilleHousing]
set SaleDate = CONVERT(Date, SaleDate)

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
add SaleDateConverted Date;

update [PortfolioProject].[dbo].[NashvilleHousing]
set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Date

select *
from [PortfolioProject].[dbo].[NashvilleHousing]
--where PropertyAddress is Null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject].[dbo].[NashvilleHousing] As a
join [PortfolioProject].[dbo].[NashvilleHousing] As b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject].[dbo].[NashvilleHousing] As a
join [PortfolioProject].[dbo].[NashvilleHousing] As b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual columns (Address, city State)

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) As Address
,substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) As Address
from [PortfolioProject].[dbo].[NashvilleHousing]

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
add PropertySplitAddress nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)


Alter table [PortfolioProject].[dbo].[NashvilleHousing]
add PropertySplitCity nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))


select
PARSENAME(Replace(OwnerAddress, ',','.'),3)
,PARSENAME(Replace(OwnerAddress, ',','.'),2)
,PARSENAME(Replace(OwnerAddress, ',','.'),1)
from [PortfolioProject].[dbo].[NashvilleHousing]

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
add OwnerSplitAddress nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)


Alter table [PortfolioProject].[dbo].[NashvilleHousing]
add OwnerSplitCity nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
add OwnerSplitState nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

select * 
from [PortfolioProject].[dbo].[NashvilleHousing]

-- Changing N to No and Y to Yes in "SoldAsVacant" filed

select Distinct(SoldAsVacant), count(SoldAsVacant)
from [PortfolioProject].[dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2

select SoldAsVacant
,Case when SoldAsVacant = 'Y' then 'Yes' 
	   when SoldAsVacant = 'N' then 'No' 
	   else SoldAsVacant
 End 
from [PortfolioProject].[dbo].[NashvilleHousing]

select Distinct(SoldAsVacant)
from [PortfolioProject].[dbo].[NashvilleHousing]

update [PortfolioProject].[dbo].[NashvilleHousing]
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes' 
	   when SoldAsVacant = 'N' then 'No' 
	   else SoldAsVacant
 End 
from [PortfolioProject].[dbo].[NashvilleHousing]

-- Rmove Duplicates

with RowNumCTE As(
select * 
,ROW_NUMBER() over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from [PortfolioProject].[dbo].[NashvilleHousing]
)
Select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--Delete unused columns

select *
from [PortfolioProject].[dbo].[NashvilleHousing]

Alter Table [PortfolioProject].[dbo].[NashvilleHousing]
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [PortfolioProject].[dbo].[NashvilleHousing]
drop column SaleDate