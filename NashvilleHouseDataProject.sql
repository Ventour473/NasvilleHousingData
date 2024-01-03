

/*
Cleaning Data in SQL Queries
*/

--SELECT COUNT(*)
--FROM PortfolioProject..NashvilleHouseData


--Create a copy of the original Dataset to work on
USE PortfolioProject

CREATE TABLE NashvilleHouseData1 (
UniqueID float NOT NULL PRIMARY KEY, ParcelID nvarchar(255),
LandUse nvarchar(255), PropertyAddress nvarchar(255), SaleDate datetime,
SalePrice float, LegalReference nvarchar(255), SoldAsVacant nvarchar(255),
OwnerName nvarchar(255), OwnerAddress nvarchar(255), Acreage float,
TaxDistrict nvarchar (255), LandValue float, BuildingValue float,
TotalValue float, YearBuilt float, Bedrooms float, FullBath float, HalfBath float)

INSERT INTO NashvilleHouseData1 
SELECT *
FROM PortfolioProject.dbo.NashvilleHouseData

SELECT *
FROM PortfolioProject.dbo.NashvilleHouseData1
------------------------------------------------------------------------------------------------------------------
--Standardize Date Format
-- Creating another column on copy to show how to change or add columns
-- However the datetime could be converted directly to date when creating the copy

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
ADD SaleDateConverted DATE

UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------------------------------------------
--Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHouseData1
--Where PropertyAddress IS NULL
ORDER BY ParcelID

--Create a self join to match ParcelId with Null Property Address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHouseData1 a
JOIN PortfolioProject.dbo.NashvilleHouseData1 b
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHouseData1 a
JOIN PortfolioProject.dbo.NashvilleHouseData1 b
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHouseData1

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress )) as City
FROM PortfolioProject.dbo.NashvilleHouseData1

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
ADD Address nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
ADD City nvarchar(255) 

UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress ))

---------------------------------------------------------------------------------------------------------
--Splitting OwnerAddress using a different method

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHouseData1

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
ADD OwnerStreetAddress nvarchar(255)


UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
ADD OwnerCity nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
ADD OwnerState nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHouseData1

---------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHouseData1
GROUP BY SoldAsVacant

SELECT DISTINCT(SoldAsVacant),
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END  AS SoldAsVacant1
FROM PortfolioProject.dbo.NashvilleHouseData1

UPDATE PortfolioProject.dbo.NashvilleHouseData1
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END  
FROM PortfolioProject.dbo.NashvilleHouseData1

----------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num

FROM PortfolioProject.dbo.NashvilleHouseData1
--ORDER BY ParcelID)
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHouseData1

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHouseData1
DROP COLUMN SaleDate