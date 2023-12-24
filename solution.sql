create database swiftanalysis;
show databases;
use swift;
Create TABLE jsontable(json_data JSON);
LOAD DATA INFILE 'c:/SWIFTAssignment.csv' INTO  TABLE jsontable(json_data);
SELECT * FROM jsontable;
-- extracting the data from json file into the table and creating essential boundaries
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.latest_status')) AS latest_status,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.latest_location')) AS latest_location,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.shipment_id')) AS shipment_id,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.deduped_track_details')) AS deduped_track_details
FROM jsontable;
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.latest_status')) AS latest_status,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.latest_location')) AS latest_location,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.shipment_id')) AS shipment_id,
    STR_TO_DATE(deduped.ctime, '%Y-%m-%d %H:%i:%s') AS ctime,
    deduped.location
FROM jsontable
CROSS JOIN JSON_TABLE(
    json_data->'$.deduped_track_details',
    '$[*]' COLUMNS (
        ctime VARCHAR(50) PATH '$.ctime',
        location VARCHAR(255) PATH '$.location'
    )
) AS deduped;

CREATE TABLE new_jsontable AS
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.latest_status')) AS latest_status,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.latest_location')) AS latest_location,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.shipment_id')) AS shipment_id,
    STR_TO_DATE(deduped.ctime, '%Y-%m-%d %H:%i:%s') AS ctime,
    deduped.location
FROM jsontable

CROSS JOIN JSON_TABLE(
    json_data->'$.deduped_track_details',
    '$[*]' COLUMNS (
        ctime VARCHAR(50) PATH '$.ctime',
        location VARCHAR(255) PATH '$.location'
    )
) AS deduped;
-- AFTER this i did the data cleaning by exporting in csv format and i have consolidated that part in the attached python file 
CREATE TABLE your_table (
    latest_status VARCHAR(255),
    latest_location VARCHAR(255),
    shipment_id VARCHAR(255),
    ctime DATETIME,
    location VARCHAR(255)
);

-- then i loaded the csv into this table using the query 
LOAD DATA INFILE 'c:/cleaned.csv)' into TABLE your_table 
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 rows;

-- Create a new table to store the results
-- Your original code for data extraction and cleaning
-- ...

-- Create a new table to store the results
CREATE TABLE analysis_results (
    location VARCHAR(255),
    percentage_delayed DECIMAL(10, 2),
    warehouse_status VARCHAR(50)
);

-- Insert the results into the new table
INSERT INTO analysis_results
SELECT
    location,
    SUM(CASE WHEN time_difference > 172800 THEN 1 ELSE 0 END) / COUNT(*) * 100 AS percentage_delayed,
    CASE
        WHEN latest_status = 'SHIPMENT DELAYED' THEN
            'Need Immediate Attention'
        WHEN SUM(CASE WHEN time_difference > 172800 THEN 1 ELSE 0 END) / COUNT(*) * 100 > 10 THEN
            'Prioritize for Clearing'
        ELSE
            'Ignore'
    END AS warehouse_status
FROM (
    SELECT
        t1.location,
        t1.shipment_id,
        t1.latest_status,
        TIMESTAMPDIFF(SECOND, LAG(t1.ctime) OVER (PARTITION BY t1.shipment_id ORDER BY t1.ctime), t1.ctime) AS time_difference
    FROM (
        SELECT
            location,
            shipment_id,
            MAX(UPPER(latest_status)) AS latest_status,
            ctime
        FROM
            your_table
        GROUP BY
            location, shipment_id, ctime
    ) AS t1
) AS delayed_info
GROUP BY
    location, latest_status
ORDER BY
    percentage_delayed DESC;

-- Display the contents of the analysis_results table
SELECT * FROM analysis_results;

-- Create a new table to store the unique results
CREATE TABLE unique_analysis_results (
    location VARCHAR(255),
    percentage_delayed DECIMAL(10, 2),
    warehouse_status VARCHAR(50)
);

-- Insert unique results into the new table
INSERT INTO unique_analysis_results
SELECT DISTINCT
    location,
    percentage_delayed,
    warehouse_status
FROM analysis_results;

-- Display the contents of the unique_analysis_results table
SELECT * FROM unique_analysis_results;

-- Create a new table to store the final results
CREATE TABLE final_results (
    location VARCHAR(255),
    percentage_delayed DECIMAL(10, 2),
    warehouse_status VARCHAR(50)
);

-- Insert unique results into the new table, giving priority to 'Need Immediate Attention'
INSERT INTO final_results
SELECT
    location,
    MAX(percentage_delayed) AS percentage_delayed,
    CASE
        WHEN MAX(warehouse_status = 'Need Immediate Attention') THEN 'Need Immediate Attention'
        ELSE MAX(warehouse_status)
    END AS warehouse_status
FROM unique_analysis_results
GROUP BY location;

-- Display the contents of the final_results table
SELECT * FROM final_results;