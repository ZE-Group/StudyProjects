-- let's create our table in the new database 

CREATE TABLE property (
    UniqueID INT,
    ParcelID VARCHAR(20),
    LandUse VARCHAR(50),
    PropertyAddress VARCHAR(100),
    SaleDate DATE,
    SalePrice VARCHAR(20),
    LegalReference VARCHAR(50),
    SoldAsVacant VARCHAR(3),
    OwnerName VARCHAR(100),
    OwnerAddress VARCHAR(100),
    Acreage DECIMAL(10, 2),
    TaxDistrict VARCHAR(50),
    LandValue DECIMAL(10, 2),
    BuildingValue DECIMAL(10, 2),
    TotalValue DECIMAL(10, 2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

SELECT * FROM property 
LIMIT 1;

	-- since we have some property address null with the same parcelid

SELECT *
FROM property
WHERE PropertyAddress IS null
ORDER BY ParcelID;

	-- we can do a self join to insert the same address where is null 


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM property a
JOIN property b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS null;

UPDATE property
SET PropertyAddress = (
    SELECT PropertyAddress
    FROM property
    WHERE PropertyAddress IS NOT NULL
    LIMIT 1
)
WHERE PropertyAddress IS NULL;

	-- Now let's break Address into Individual Columns (Address, City, State)
		-- let's start with the property adress 
		
SELECT * FROM property 
LIMIT 1;

SELECT
    TRIM(SPLIT_PART(PropertyAddress, ',', 1)) AS PropertyAddress,
    TRIM(SPLIT_PART(PropertyAddress, ',', 2)) AS PropertyState
FROM property;

--ALTER TABLE property
--ADD COLUMN Property_Address VARCHAR(255),
--ADD COLUMN PropertyState VARCHAR(255);

UPDATE property
SET Property_Address = TRIM(SPLIT_PART(PropertyAddress, ',', 1)),
    PropertyState = TRIM(SPLIT_PART(PropertyAddress, ',', 2));
	
		-- now let's do the same for the owneraddress
    
SELECT * FROM property 
LIMIT 5;

SELECT a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress
FROM property a
JOIN property b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.OwnerAddress IS Not null;


UPDATE property
SET OwnerAddress = (
    SELECT OwnerAddress
    FROM property
    WHERE OwnerAddress IS NOT NULL
    LIMIT 1
)
WHERE OwnerAddress IS NULL;

SELECT
    TRIM(SPLIT_PART(OwnerAddress, ',', 1)) AS OwnerAddress,
    TRIM(SPLIT_PART(OwnerAddress, ',', 2)) AS OwnerCity,
	TRIM(SPLIT_PART(owneraddress, ',', 3)) AS OwnerState
FROM property;

ALTER TABLE property
ADD COLUMN Owner_Address VARCHAR(255),
ADD COLUMN OwnerCity VARCHAR(255),
ADD COLUMN OwnerState VARCHAR(255);

UPDATE property
SET Owner_Address = TRIM(SPLIT_PART(OwnerAddress, ',', 1)),
    OwnerCity = TRIM(SPLIT_PART(OwnerAddress, ',', 2)),
	OwnerState = TRIM(SPLIT_PART(OwnerAddress, ',', 3));
	

SELECT * FROM property 
LIMIT 5;

-- since we have some Y and N inside our table
  -- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM property
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, 
 CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
 END
FROM property;

UPDATE property 
SET SoldAsVacant = 
		CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	 	END;


	-- Now let's remove Duplicates
	
SELECT parcelid, property.property_address, legalreference, saledate, COUNT(*) AS duplicate_count
FROM property
GROUP BY parcelid, property.property_address, legalreference, saledate
HAVING COUNT(*) > 1;

WITH duplicates AS (
    SELECT parcelid, property_address, legalreference, saledate,
           ROW_NUMBER() OVER (PARTITION BY parcelid, property_address, legalreference, saledate
                              ORDER BY parcelid, property_address, legalreference, saledate) 
           AS row_num
    FROM property
) 

DELETE FROM property
WHERE (parcelid, property_address, legalreference, saledate) IN (
    SELECT parcelid, property_address, legalreference, saledate
    FROM duplicates
    WHERE row_num > 1
);

	-- Let's remove some unused column 
	
ALTER TABLE property
	DROP COLUMN SaleDate,
	DROP COLUMN TaxDistrict,
	DROP COLUMN PropertyAddress,
	DROP COLUMN OwnerAddress;
		
