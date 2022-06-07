--- Cleaning data in SQL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------- ## ALTERNATE WAY

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--- Populate Property Address

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

--- DO a Self Join ( To Evaluvate the Table)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a. ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;  --- How is null works in the first line 

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a. ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

---- Breaking Out Address into [ Address | City | Sate ]

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address

FROM PortfolioProject.dbo.NashvilleHousing

--- Create 2 New Columns

ALTER TABLE NashvilleHousing
ADD PropertySplit_Address NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplit_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplit_City NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplit_City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM  PortfolioProject.dbo.NashvilleHousing

---- Split on Owner Address

SELECT OwnerAddress
FROM  PortfolioProject.dbo.NashvilleHousing

--- PARSENAME -- insted of SUBSTRING

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM  PortfolioProject.dbo.NashvilleHousing
 

ALTER TABLE NashvilleHousing
ADD OwnerSplit_Address NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplit_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplit_City NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplit_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplit_State NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplit_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM  PortfolioProject.dbo.NashvilleHousing

--- Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM  PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant


--- Revome Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--- After deleting Duplicates
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate