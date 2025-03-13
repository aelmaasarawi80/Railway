create database Trains;
use Trains;

ALTER TABLE trips
MODIFY `Trip ID` VARCHAR(10) NOT NULL;

ALTER TABLE transactions
MODIFY `Trip ID` VARCHAR(10) NOT NULL;

SHOW INDEX FROM trips;

ALTER TABLE transactions
ADD CONSTRAINT fk_trip
FOREIGN KEY (`Trip ID`) 
REFERENCES trips(`Trip ID`);

ALTER TABLE trips
ADD CONSTRAINT fk_trip2
FOREIGN KEY (`Departure Station`) 
REFERENCES stations(`Station`);

ALTER TABLE trips
ADD CONSTRAINT fk_trip3
FOREIGN KEY (`Arrival Destination`) 
REFERENCES stations(`Station`);

ALTER TABLE trips
ADD CONSTRAINT fk_trip4
FOREIGN KEY (`Route`) 
REFERENCES routes(`Route`);

# percentages of journey status
SELECT 
    `Journey Status`,
    COUNT(*) AS JourneyCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM trips
GROUP BY `Journey Status`;


#assessing statiosn with most delays and cancellations
SELECT 
    `Departure Station`,
    `Arrival Destination`,
    COUNT(*) AS DelayCount
FROM trips
WHERE `Journey Status` = 'Delayed'
GROUP BY `Departure Station`, `Arrival Destination`
ORDER BY DelayCount DESC;

SELECT 
    `Departure Station`,
    `Arrival Destination`,
    COUNT(*) AS DelayCount
FROM trips
WHERE `Journey Status` = 'Cancelled'
GROUP BY `Departure Station`, `Arrival Destination`
ORDER BY DelayCount DESC;


# assessign most common reasons for delays
SELECT 
    `Reason for Delay`,
    COUNT(*) AS OccurrenceCount
FROM trips
WHERE `Journey Status` IN ('Delayed', 'Cancelled') 
GROUP BY `Reason for Delay`
ORDER BY OccurrenceCount DESC;

SELECT 
    `Departure Station`,
    `Arrival Destination`,
    `Reason for Delay`,
    COUNT(*) AS OccurrenceCount
FROM trips
WHERE `Journey Status` IN ('Delayed', 'Cancelled')
GROUP BY `Departure Station`, `Arrival Destination`, `Reason for Delay`
ORDER BY OccurrenceCount DESC;

# Average price and distance per route
SELECT 
    r.`Route`,
    ROUND(AVG(t.`Price`), 2) AS AveragePrice
FROM transactions t
JOIN routes r ON t.`Route` = r.`Route`
GROUP BY r.`Route`
ORDER BY AveragePrice DESC;

SELECT 
    r.`Route`,
    r.`Distance`,
    ROUND(AVG(t.`Price`), 2) AS AveragePrice,
    ROUND(AVG(t.`Price`) / r.`Distance`, 2) AS PricePerKm
FROM transactions t
JOIN routes r ON t.`Route` = r.`Route`
GROUP BY r.`Route`, r.`Distance`
ORDER BY PricePerKm DESC;

# effect of delays of customer satsisfaction (refund)
SELECT 
    `Journey Status`,
    COUNT(*) AS TotalJourneys,
    SUM(CASE WHEN `Refund Request` = 'Yes' THEN 1 ELSE 0 END) AS RefundRequests,
    ROUND(SUM(CASE WHEN `Refund Request` = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS RefundRequestPercentage
FROM transactions
GROUP BY `Journey Status`;

SELECT 
    t.`Journey Status`,
    t.`Ticket Class`,
    COUNT(*) AS TotalJourneys,
    SUM(CASE WHEN t.`Refund Request` = 'Yes' THEN 1 ELSE 0 END) AS RefundRequests,
    ROUND(SUM(CASE WHEN t.`Refund Request` = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS RefundRequestPercentage
FROM transactions t
GROUP BY t.`Journey Status`, t.`Ticket Class`
ORDER BY t.`Journey Status`, t.`Ticket Class`;

#payment types
SELECT 
    `Payment Method`,
    `Ticket Class`,
    COUNT(*) AS PaymentCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY `Ticket Class`), 2) AS PaymentPercentage
FROM transactions
GROUP BY `Payment Method`, `Ticket Class`
ORDER BY `Ticket Class`, PaymentCount DESC;

# day trends
SELECT 
    DAYNAME(STR_TO_DATE(`Date of Purchase`, '%m/%d/%Y')) AS DayOfWeek,
    COUNT(*) AS PurchaseCount
FROM transactions
GROUP BY DayOfWeek
ORDER BY PurchaseCount DESC;

SELECT 
    DAYNAME(STR_TO_DATE(`Date of Journey`, '%m/%d/%Y')) AS DayOfWeek,
    COUNT(*) AS PurchaseCount
FROM transactions
GROUP BY DayOfWeek
ORDER BY PurchaseCount DESC;

SELECT 
    DAYNAME(STR_TO_DATE(`Date of Purchase`, '%m/%d/%Y')) AS DayOfWeek,
    HOUR(STR_TO_DATE(`Time of Purchase`, '%H:%i:%s')) AS HourOfDay,
    COUNT(*) AS PurchaseCount
FROM transactions
GROUP BY DayOfWeek, HourOfDay
ORDER BY PurchaseCount DESC;

# effect of railcards on price
SELECT 
    `Railcard`,
    ROUND(AVG(`Price`), 2) AS AveragePrice
FROM transactions
GROUP BY `Railcard`;

SELECT 
    t.`Route`,
    t.`Railcard`,
    ROUND(AVG(t.`Price`), 2) AS AveragePrice
FROM transactions t
GROUP BY t.`Route`, t.`Railcard`
ORDER BY t.`Route`;

# SALES BY ROUTE
SELECT 
    t.`Route`,
    SUM(t.`Price`) AS TotalRevenue
FROM transactions t
GROUP BY t.`Route`
ORDER BY TotalRevenue DESC;

SELECT 
    t.`Route`,
    SUM(t.`Price`) AS TotalRevenue
FROM transactions t
WHERE t.`Refund Request` = 'No' 
GROUP BY t.`Route`
ORDER BY TotalRevenue DESC;


# impact of delays financially
SELECT 
    t.`Journey Status`,
    COUNT(*) AS TotalJourneys,
    SUM(CASE WHEN tr.`Refund Request` = 'Yes' THEN tr.`Price` ELSE 0 END) AS TotalRefundCost
FROM trips t
JOIN transactions tr ON t.`Trip ID` = tr.`Trip ID`
WHERE t.`Journey Status` IN ('Delayed', 'Cancelled')
GROUP BY t.`Journey Status`;

SELECT 
    t.`Reason for Delay`,
    COUNT(*) AS TotalJourneys,
    SUM(CASE WHEN tr.`Refund Request` = 'Yes' THEN tr.`Price` ELSE 0 END) AS TotalRefundCost
FROM trips t
JOIN transactions tr ON t.`Trip ID` = tr.`Trip ID`
WHERE t.`Journey Status` = 'Delayed' or t.`Journey Status` = 'Cancelled'
GROUP BY t.`Reason for Delay`;

SELECT
	count(*)
from transactions
where `Reason for Delay` = 'Weather Conditions' 
and `Refund Request` = 'Yes' 
and `Journey Status` = 'Delayed';

# delays and cancellatiosn per routes
SELECT 
    `Route`,
    SUM(CASE WHEN `Journey Status` = 'Delayed' THEN 1 ELSE 0 END) AS DelayedJourneys,
    SUM(CASE WHEN `Journey Status` = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledJourneys,
    COUNT(*) AS TotalJourneys,
    ROUND(SUM(CASE WHEN `Journey Status` = 'Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DelayPercentage,
    ROUND(SUM(CASE WHEN `Journey Status` = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CancellationPercentage
FROM trips
GROUP BY `Route`
ORDER BY DelayedJourneys DESC, CancelledJourneys DESC;

SELECT 
    `Departure Station`,
    `Arrival Destination`,
    SUM(CASE WHEN `Journey Status` = 'Delayed' THEN 1 ELSE 0 END) AS DelayedJourneys,
    SUM(CASE WHEN `Journey Status` = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledJourneys,
    COUNT(*) AS TotalJourneys,
    ROUND(SUM(CASE WHEN `Journey Status` = 'Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DelayPercentage,
    ROUND(SUM(CASE WHEN `Journey Status` = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CancellationPercentage
FROM trips
GROUP BY `Departure Station`, `Arrival Destination`
ORDER BY DelayedJourneys DESC, CancelledJourneys DESC;


# transaction per day
SELECT 
    `Date of Journey`,
    COUNT(*) AS NumberOfTransactions
FROM transactions
GROUP BY `Date of Journey`
ORDER BY `Date of Journey`;

# emissions
SELECT 
    t.`Trip ID`,
    t.`Route`,
    r.`Distance`,
    r.`CO2e emissionss` AS CarbonEmissions
FROM trips t
JOIN routes r ON t.`Route` = r.`Route`
GROUP BY t.`Trip ID`, t.`Route`, r.`Distance`, r.`CO2e emissionss`
ORDER BY CarbonEmissions DESC;

# Journey status by reason of delay
select
	`Journey Status`, `Reason for Delay`, count(*)
from transactions
group by `Journey Status`, `Reason for Delay`;

# checking if York to Wakefield has any on time trip
SELECT *
FROM trips
WHERE `Route` = 'York to Wakefield'
  AND `Journey Status` = 'On Time';

# average price for ticket types
SELECT 
    `Ticket Type`,
    ROUND(AVG(`Price`), 2) AS AveragePrice
FROM transactions
GROUP BY `Ticket Type`
ORDER BY AveragePrice DESC;

