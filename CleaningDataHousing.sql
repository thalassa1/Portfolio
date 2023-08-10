--cleaning data queries
SELECT *
FROM Housing;

--standardize date format (remove blank time)

SELECT SaleDate, CONVERT(date, SaleDate)
FROM Housing;

ALTER TABLE Housing
ADD DateSold Date;

UPDATE Housing
SET DateSold = CONVERT(date, SaleDate);

ALTER TABLE Housing
DROP COLUMN SaleDate;

--populating null values 

SELECT PropertyAddress
FROM Housing
WHERE PropertyAddress IS NULL;

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- breaking out address into individual columns 

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Housing;

ALTER TABLE Housing
ADD Address nvarchar(255),
	City nvarchar(255);

UPDATE Housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1), 
	City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT Address, City
FROM Housing;

SELECT owneraddress, 
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState, 
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity, 
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddr
FROM Housing;

ALTER TABLE Housing
ADD OwnerState nvarchar(10),
	OwnerCity nvarchar(255),
	OwnerAddr nvarchar(255);

UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1), 
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerAddr = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

SELECT ownerState, ownerCity, ownerAddr
FROM Housing;

-- change y and n to yes and no

SELECT DISTINCT soldasvacant, COUNT(soldasvacant)
FROM Housing
GROUP BY SoldAsVacant;

SELECT DISTINCT SoldAsVacant, 
		CASE WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
			END  AS SoldVacant
FROM Housing;

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
			END;

--remove the duplicates

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
			PARTITION BY
			ParcelID,
			PropertyAddress, 
			SalePrice, 
			DateSold, 
			LegalReference
			ORDER BY
			UniqueID
			)  row_num
FROM Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns
ALTER TABLE Housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict