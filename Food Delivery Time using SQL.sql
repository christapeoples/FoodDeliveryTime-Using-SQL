Select *
From PortfolioProject.dbo.deliverytime
order by 3,4

-- Selecting Data that we are going to be using

select ID,Delivery_person_ID, Delivery_person_Ratings,Delivery_person_Age, Restaurant_latitude,Restaurant_longitude, Delivery_location_latitude,Delivery_location_longitude,Type_of_order, Type_of_vehicle, Time_taken_min
from PortfolioProject.dbo.deliverytime
order by 1,2


-- Looking at Delivery person ID vs Time Taken in Minutes

SELECT
    Delivery_person_ID,
    AVG(CAST(Time_taken_min AS DECIMAL(10, 2))) AS Average_Time_taken_min
FROM PortfolioProject.dbo.deliverytime
GROUP BY Delivery_person_ID
ORDER BY Delivery_person_ID;

-- Looking at Delivery_person_Age vs Time_taken_min

SELECT
    Delivery_person_Age,
    AVG(CAST(Time_taken_min AS DECIMAL(10, 2)) * 1.0) AS Average_Time_taken_minutes
FROM PortfolioProject.dbo.deliverytime
GROUP BY Delivery_person_Age
ORDER BY Delivery_person_Age;

-- Looking at Type of Vehicle vs Time taken in Minutes

SELECT
    Type_of_vehicle,
    AVG(time_taken_min) AS Average_Time_Taken_Minutes
FROM PortfolioProject.dbo.deliverytime
GROUP BY Type_of_vehicle
ORDER BY Type_of_vehicle;

-- Looking at the Restaurant distance vs Delivery location vs Time_Taken in minutes

SELECT
    Restaurant_latitude AS Location_latitude,
    Restaurant_longitude AS Location_longitude,
    AVG(time_taken_min) AS Average_Time_Taken_Minutes
FROM PortfolioProject..deliverytime
GROUP BY Restaurant_latitude, Restaurant_longitude
UNION
SELECT
    Delivery_location_latitude AS Location_latitude,
    Delivery_location_longitude AS Location_longitude,
    AVG(time_taken_min) AS Average_Time_Taken_Minutes
FROM PortfolioProject..deliverytime
GROUP BY Delivery_location_latitude, Delivery_location_longitude
ORDER BY Location_latitude, Location_longitude;

-- Looking at Max, Median, Min of Restaurant ID

    MAX(ID) AS Max_ID,
    (
        SELECT
            ID
        FROM (
            SELECT
                ID,
                ROW_NUMBER() OVER (ORDER BY ID) AS RowAsc,
                ROW_NUMBER() OVER (ORDER BY ID DESC) AS RowDesc
            FROM PortfolioProject..deliverytime
        ) AS Subquery
        WHERE RowAsc = RowDesc
           OR RowAsc + 1 = RowDesc
           OR RowAsc = RowDesc + 1
    ) AS Median_ID,
    MIN(ID) AS Min_ID
FROM PortfolioProject..deliverytime;


SELECT
    (
        COUNT(*) * SUM(time_taken_min * Restaurant_latitude) - SUM(time_taken_min) * SUM(Restaurant_latitude)
    ) / (SQRT((COUNT(*) * SUM(time_taken_min * time_taken_min) - POWER(SUM(time_taken_min), 2)) * (COUNT(*) * SUM(Restaurant_latitude * Restaurant_latitude) - POWER(SUM(Restaurant_latitude), 2))) AS Correlation_Restaurant_Latitude,
    (
        COUNT(*) * SUM(time_taken_min * Restaurant_longitude) - SUM(time_taken_min) * SUM(Restaurant_longitude)
    ) / (SQRT((COUNT(*) * SUM(time_taken_min * time_taken_min) - POWER(SUM(time_taken_min), 2)) * (COUNT(*) * SUM(Restaurant_longitude * Restaurant_longitude) - POWER(SUM(Restaurant_longitude), 2))) AS Correlation_Restaurant_Longitude,
    (
        COUNT(*) * SUM(time_taken_min * Delivery_location_latitude) - SUM(time_taken_min) * SUM(Delivery_location_latitude)
    ) / (SQRT((COUNT(*) * SUM(time_taken_min * time_taken_min) - POWER(SUM(time_taken_min), 2)) * (COUNT(*) * SUM(Delivery_location_latitude * Delivery_location_latitude) - POWER(SUM(Delivery_location_latitude), 2))) AS Correlation_Delivery_Location_Latitude,
    (
        COUNT(*) * SUM(time_taken_min * Delivery_location_longitude) - SUM(time_taken_min) * SUM(Delivery_location_longitude)
    ) / (SQRT((COUNT(*) * SUM(time_taken_min * time_taken_min) - POWER(SUM(time_taken_min), 2)) * (COUNT(*) * SUM(Delivery_location_longitude * Delivery_location_longitude) - POWER(SUM(Delivery_location_longitude), 2))) AS Correlation_Delivery_Location_Longitude
FROM PortfolioProject..deliverytime;

-- Looking at the time_taken_min vs Rating
SELECT
    Delivery_person_Ratings,
    AVG(Time_taken_min) AS Average_Time_taken_min
FROM PortfolioProject..deliverytime
GROUP BY Delivery_person_Ratings
ORDER BY Delivery_person_Ratings ASC;

-- Showing the Order Type vs Average Time Taken in Minutes
SELECT
    Type_of_order,
    AVG(Time_taken_min) AS Average_Time_taken_min
FROM PortfolioProject..deliverytime
GROUP BY Type_of_order;

--This shows just a list of all order types along with their respective time taken in minutes

SELECT
    Type_of_order,
    Time_taken_min
FROM PortfolioProject..deliverytime
ORDER BY Time_taken_min ASC, Type_of_order ASC;

-- Showing the averages of time taken and type of order
SELECT
    Type_of_order,
    AVG(CAST(Time_taken_min AS DECIMAL(10, 2))) AS average_time_taken_mins
FROM PortfolioProject..deliverytime
GROUP BY Type_of_order;

--Examing the delivery times and rating across different types of vehicles
SELECT
    Type_of_vehicle,
    AVG(Time_taken_min) AS Average_Delivery_Time,
    AVG(Delivery_person_Ratings) AS Average_Rating
FROM PortfolioProject..deliverytime
GROUP BY Type_of_vehicle;


--Examing the average delivery timer per vehicle
SELECT
    Type_of_vehicle,
    AVG(Time_taken_min) AS Average_Delivery_Time
FROM PortfolioProject..deliverytime
GROUP BY Type_of_vehicle;


-- delivery locations and time taken in minutes
SELECT
    Delivery_location_latitude,
    Delivery_location_longitude,
    AVG(Time_taken_min) AS Average_Delivery_Time
FROM PortfolioProject..deliverytime
GROUP BY Delivery_location_latitude, Delivery_location_longitude;

-- Taking a closer examine at the distance between restaurant and delivery location

-- Haversine formula to calculate distance
DECLARE @EarthRadius DECIMAL(10, 2) = 6371; -- Earth's radius in kilometers
DECLARE @RestaurantLatitude DECIMAL(9, 6);
DECLARE @RestaurantLongitude DECIMAL(9, 6);
DECLARE @DeliveryLatitude DECIMAL(9, 6);
DECLARE @DeliveryLongitude DECIMAL(9, 6);
DECLARE @DeltaLat DECIMAL(9, 6);
DECLARE @DeltaLon DECIMAL(9, 6);
DECLARE @a DECIMAL(10, 8);
DECLARE @c DECIMAL(10, 8);
DECLARE @Distance DECIMAL(10, 2);

-- Set the latitude and longitude for the restaurant and delivery location from your dataset
-- Replace with your actual column names
SELECT TOP 1
    @RestaurantLatitude = Restaurant_latitude,
    @RestaurantLongitude = Restaurant_longitude
FROM PortfolioProject..deliverytime;

SELECT TOP 1
    @DeliveryLatitude = Delivery_location_latitude,
    @DeliveryLongitude = Delivery_location_longitude
FROM PortfolioProject..deliverytime;

-- Calculate the differences in latitude and longitude
SET @DeltaLat = RADIANS(@DeliveryLatitude - @RestaurantLatitude);
SET @DeltaLon = RADIANS(@DeliveryLongitude - @RestaurantLongitude);

-- Haversine formula calculation
SET @a = SIN(@DeltaLat / 2) * SIN(@DeltaLat / 2)
    + COS(RADIANS(@RestaurantLatitude)) * COS(RADIANS(@DeliveryLatitude))
    * SIN(@DeltaLon / 2) * SIN(@DeltaLon / 2);

SET @c = 2 * ATN2(SQRT(@a), SQRT(1 - @a));

-- Calculate the distance
SET @Distance = @EarthRadius * @c;

-- Output the calculated distance
SELECT @Distance AS DistanceInKilometers;

-- Average of type of order
SELECT
	Type_of_order,
	AVG(1.0) AS Average_type_of_order
From Portfolioproject..deliverytime
GROUP BY Type_of_order
ORDER BY Type_of_order ASC;




--Average of time take in minutes

SELECT AVG(Time_taken_min) AS Average_time_taken_minutes
FROM PortfolioProject..deliverytime;

--Average vehicle type

SELECT
    Type_of_vehicle,
    AVG(CAST(Time_taken_min AS DECIMAL(10, 2))) AS Average_Time_taken_min
FROM PortfolioProject..deliverytime
GROUP BY Type_of_vehicle;


-- Median of the type of orders

WITH MedianPositions AS (
    SELECT
        Type_of_order,
        FLOOR((COUNT(*) + 1) / 2) AS LowerMedianPosition,
        CEILING((COUNT(*) + 1) / 2) AS UpperMedianPosition
    FROM PortfolioProject..deliverytime
    GROUP BY Type_of_order
)

SELECT
    d.Type_of_order,
    AVG(d.Time_taken_min) AS Median_Time_taken_min
FROM (
    SELECT
        Type_of_order,
        Time_taken_min,
        ROW_NUMBER() OVER (PARTITION BY Type_of_order ORDER BY Time_taken_min) AS RowAsc
    FROM PortfolioProject..deliverytime
) AS d
JOIN MedianPositions AS m
    ON d.Type_of_order = m.Type_of_order
WHERE d.RowAsc = m.LowerMedianPosition
    OR d.RowAsc = m.UpperMedianPosition
GROUP BY d.Type_of_order;

-- Showing the column options for type_of_order

SELECT DISTINCT Type_of_order
FROM PortfolioProject..deliverytime;

-- Median Restaurant ID vs Delivery_Person vs Rating

WITH MedianRanked AS (
    SELECT
        ID,
        Delivery_Person_ID,
        Delivery_person_Ratings,
        NTILE(2) OVER (PARTITION BY Delivery_Person_ID, Delivery_person_Ratings ORDER BY ID) AS MedianGroup
    FROM PortfolioProject..deliverytime
)

SELECT
    Delivery_Person_ID,
    Delivery_person_Ratings,
    AVG(ID) AS Median_ID
FROM MedianRanked
WHERE MedianGroup = 2
GROUP BY Delivery_Person_ID, Delivery_person_Rating;









