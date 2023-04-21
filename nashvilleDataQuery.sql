/* This data relates to property information from Nashville, TN*/
/*The purpose of these queries is to clean up the data*/



--Change the date so it is standardized
SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject3.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--include the property address data
SELECT *
FROM PortfolioProject3.dbo.NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject3.dbo.NashvilleHousing a
JOIN PortfolioProject3.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject3.dbo.NashvilleHousing a
JOIN PortfolioProject3.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

--We want to split up the address into address, city, state
SELECT PropertyAddress
FROM PortfolioProject3.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM PortfolioProject3.dbo.NashvilleHousing

--create 2 new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject3.dbo.NashvilleHousing


----to split owner address using ParseName

SELECT OwnerAddress
FROM PortfolioProject3.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject3.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM PortfolioProject3.dbo.NashvilleHousing


--in sold as vacant we want to change y and n to yes and no for consistency

Select Distinct (SoldAsVacant) , Count(SoldAsVacant)
FROM PortfolioProject3.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject3.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--We would like to remove duplicates
With RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER by UniqueID) row_num
FROM PortfolioProject3.dbo.NashvilleHousing

)
SELECT * 
FROM RowNumCTE
WHERE row_num >1
Order by PropertyAddress


--We would like to delete unused columns
SELECT * 
FROM PortfolioProject3.dbo.NashvilleHousing

ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
DROP COLUMN SaleDate