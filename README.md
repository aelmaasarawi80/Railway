# Railway
DEPI project

Project Goals
Identify Patterns in Delays and Cancellations:
Determine which routes, stations, and ticket types are most prone to delays and cancellations.
Analyze the most common reasons for delays.
Environmental Impact:
Calculate the carbon footprint of journeys based on distance traveled.
Customer Satisfaction:
Investigate the impact of delays on refund requests and customer satisfaction.
Visualize Insights:
Create visualizations (e.g., heatmaps, bar charts, pie charts) to communicate findings effectively.

Data Sources
The original dataset was on one spreadsheet which was divided into four:
1- trips Table:
Contains information about each trip, including:
Trip ID
Route
Departure Station
Arrival Destination
Journey Status (On Time, Delayed, Cancelled)
Reason for Delay
Date of Journey
Departure Time

2- transactions Table:
Contains information about ticket purchases, including:
Transaction ID
Trip ID
Ticket Type (Advance, Standard)
Price
Railcard (Adult, No card, Disabled)
Refund Request (Yes, No)

3- routes Table:
Contains information about each route, including:
Route
Distance (in kilometers)
CO2e emissions

4- stations Table:
Contains information about stations, including:
Station
Latitude
Longitude
City

Analysis Performed
Punctuality Rate:
Calculated the percentage of journeys that were On Time, Delayed, or Cancelled.

Reasons for Delays:
Identified the most common reasons for delays (e.g., Signal Failure, Weather).

Impact of Routes and Stations:
Analyzed which routes and stations are most prone to delays and cancellations.

Impact of Ticket Types and Railcards:
Investigated whether certain ticket types or Railcards are more likely to be delayed.

Environmental Impact:
Calculated the carbon footprint of journeys based on distance and CO2e emissions.

Visualizations:
Created heatmaps, bar charts, and pie charts to visualize the results.
