-- PROVINCE LOOKUP TABLE UPDATE
-- Adds missing Gauteng and KwaZulu-Natal cities/suburbs identified during Step 12 review.
-- These records were incorrectly being dropped due to missing lookup entries.
-- Run this script BEFORE re-executing Steps 6-10 of the main province population script.


-- GAUTENG ADDITIONS (17 RECORDS AFFECTED)
-- City of Johannesburg Metropolitan Municipality suburbs.
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Fourways'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Four Ways'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Magaliessig'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Bassonia'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Southgate'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'South Gate'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Aspen Hills'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Dainfern'),
('Gauteng', NULL, NULL, 'City of Johannesburg', 'Fairlands');

-- City of Tshwane Metropolitan Municipality suburbs.
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('Gauteng', NULL, NULL, 'City of Tshwane', 'City of Tshwane'),
('Gauteng', NULL, NULL, 'City of Tshwane', 'Olifantsfontein');

-- City of Ekurhuleni Metropolitan Municipality suburbs.
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('Gauteng', NULL, NULL, 'City of Ekurhuleni', 'Greenstone'),
('Gauteng', NULL, NULL, 'City of Ekurhuleni', 'Modderfontein');

-- West Rand District Municipality suburbs.
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('Gauteng', 'Mogale City', 'West Rand', NULL, 'Roodekrans'),
('Gauteng', 'Mogale City', 'West Rand', NULL, 'Mogale City');


-- KWAZULU-NATAL ADDITIONS (10 RECORDS AFFECTED)
-- eThekwini Metropolitan Municipality suburbs.
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('KwaZulu-Natal', NULL, NULL, 'eThekwini', 'Cornubia'),
('KwaZulu-Natal', NULL, NULL, 'eThekwini', 'Newlands East'),
('KwaZulu-Natal', NULL, NULL, 'eThekwini', 'Newlands West'),
('KwaZulu-Natal', NULL, NULL, 'eThekwini', 'Kwadabeka');

-- King Cetshwayo District Municipality (uMhlathuze Local Municipality).
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('KwaZulu-Natal', 'uMhlathuze', 'King Cetshwayo', NULL, 'Esikhawini');

-- uMkhanyakude District Municipality (Big Five Hlabisa Local Municipality).
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('KwaZulu-Natal', 'Big Five Hlabisa', 'uMkhanyakude', NULL, 'Mkuze');

-- Harry Gwala District Municipality (Dr Nkosazana Dlamini Zuma Local Municipality).
INSERT INTO MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP 
(PROVINCE, LOCAL_MUNICIPALITY, DISTRICT_MUNICIPALITY, METROPOLITAN_MUNICIPALITY, CITY)
VALUES
('KwaZulu-Natal', 'Dr Nkosazana Dlamini Zuma', 'Harry Gwala', NULL, 'Underberg');


-- VERIFICATION QUERY
-- Confirms the new entries were added successfully.
SELECT 
    PROVINCE,
    COUNT(*) AS NEW_ENTRIES
FROM MUSA_DAIR_DB.RAW.PROVINCE_LOOKUP
WHERE CITY IN (
    'Fourways', 'Four Ways', 'Magaliessig', 'Bassonia', 'Southgate', 'South Gate',
    'Aspen Hills', 'Dainfern', 'Fairlands', 'City of Tshwane', 'Olifantsfontein',
    'Greenstone', 'Modderfontein', 'Roodekrans', 'Mogale City',
    'Cornubia', 'Newlands East', 'Newlands West', 'Kwadabeka', 
    'Esikhawini', 'Mkuze', 'Underberg'
)
GROUP BY PROVINCE
ORDER BY PROVINCE;
