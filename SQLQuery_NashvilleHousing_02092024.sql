Select *
FROM NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(Date,saledate)
FROM NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

-- Populate Property Address Data

Select *
FROM NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null


-- Breaking out Address into Invidiual Columns (Address, City, State)

Select PropertyAddress
FROM NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select UniqueID, PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing


Select OwnerAddress
FROM NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)

SELECT UniqueID, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing


--Change 1 and 0 to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
Group by SoldasVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 1 THEN 'Yes'
	When SoldAsVacant = 0 Then 'No'
	END
FROM NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CONVERT(Nvarchar(255),SoldAsVacant)


Update NashvilleHousing
SET SoldASVacant =  CASE When SoldAsVacant = 1 THEN 'Yes'
	When SoldAsVacant = 0 Then 'No'
	END


--Remove Duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) Row_num
					
FROM NashvilleHousing
)
Select *
From RowNumCTE
Where Row_num >1


--Delete Unused Columns


Select *
FROM NashvilleHousing

Alter Table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

