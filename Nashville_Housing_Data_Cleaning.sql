-- Cleaning Data in SQL

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;


-- Change SaleDate Format to DATE (2 ways)
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;
-- Or the long way...
--SELECT SaleDate, CONVERT(DATE, SaleDate)
--FROM NashvilleHousing;

--ALTER TABLE NashvilleHousing
--ADD SaleDateNew DATE;

--UPDATE NashvilleHousing
--SET SaleDateNew = CONVERT(DATE, SaleDate);

-- Populate PropertyAddress data based on ParcelID using Self Join
SELECT T1.UniqueID, T2.UniqueID, T1.ParcelID, T2.ParcelID, T1.PropertyAddress, T2.PropertyAddress, ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM NashvilleHousing AS T1
JOIN NashvilleHousing AS T2
ON T1.ParcelID = T2.ParcelID
AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL;

UPDATE T1
SET PropertyAddress = ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM NashvilleHousing AS T1
JOIN NashvilleHousing AS T2
ON T1.ParcelID = T2.ParcelID
AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL;

-- Split PropertyAddress into Address & City using SUBSTRING
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
FROM NashvilleHousing;

SELECT PropertyAddress, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertyAddressNew VARCHAR(100),
	PropertyCity VARCHAR(50);

UPDATE NashvilleHousing
SET PropertyAddressNew = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress));

-- Split OwnerAddress into Address, City & State using PARSENAME
SELECT OwnerAddress, TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)),
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3))
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL;

ALTER TABLE NashvilleHousing
ADD OwnerAddressNew VARCHAR(100),
	OwnerCity VARCHAR(50),
	OwnerState VARCHAR(20);

UPDATE NashvilleHousing
SET OwnerAddressNew = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)),
	OwnerCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
	OwnerState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1));

-- Change Y, N to Yes and No in the SoldAsVacant Column using CASE
SELECT SoldAsVacant, COUNT(UniqueID)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(UniqueID) DESC;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing
ORDER BY SoldAsVacant;

ALTER TABLE NashvilleHousing
ADD SoldAsVacantNew VARCHAR(3);

UPDATE NashvilleHousing
SET SoldAsVacantNew = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;

SELECT SoldAsVacantNew, COUNT(UniqueID)
FROM NashvilleHousing
GROUP BY SoldAsVacantNew
ORDER BY COUNT(UniqueID) DESC;

-- Delete unnecessary columns
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SoldAsVacant, OwnerAddress, TaxDistrict;

-- Remove duplicates using ROW_NUMBER and CTE
WITH CTE_duplicate AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
SELECT *
FROM CTE_duplicate
WHERE row_num <= 1;