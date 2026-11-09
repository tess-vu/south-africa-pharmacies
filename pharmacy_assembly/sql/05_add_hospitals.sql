-- HOSPITAL APPEND TO PHARMACIES_COMBINED
-- Appends public hospital pharmacy records from RAW.HOSPITALS into INTERMEDIATE.PHARMACIES_COMBINED.
-- Hospitals are mapped to Gauteng and KwaZulu-Natal using PR_NAME field.
-- Geographic coordinates are created using ST_MAKEPOINT from X (longitude) and Y (latitude).


-- APPEND HOSPITAL RECORDS
-- Inserts public hospital records with mapped municipality information.
INSERT INTO MUSA_DAIR_DB.INTERMEDIATE.PHARMACIES_COMBINED (
    PHARMACY_ID,
    PROVINCE,
    LOCAL_MUNICIPALITY,
    DISTRICT_MUNICIPALITY,
    METROPOLITAN_MUNICIPALITY,
    CITY,
    PRACTICE_NAME,
    PRACTICE_NUM,
    PRACTICE_TYPE,
    ADDRESS,
    PHONE,
    FUNDING,
    COMPANY,
    COORDS
)
SELECT
    -- Generates sequential PHARMACY_ID continuing from existing max value.
    (SELECT COALESCE(MAX(PHARMACY_ID), 0) FROM MUSA_DAIR_DB.INTERMEDIATE.PHARMACIES_COMBINED) + ROW_NUMBER() OVER (ORDER BY NAME) AS PHARMACY_ID,
    
    -- Province mapping from PR_NAME field.
    PR_NAME AS PROVINCE,
    
    -- Local municipality not available in hospital data.
    NULL AS LOCAL_MUNICIPALITY,
    
    -- District municipality from DC_NAME for non-metro areas.
    -- DC_MDB_C codes starting with 'DC' indicate district municipalities.
    CASE 
        WHEN DC_MDB_C LIKE 'DC%' THEN DC_NAME
        ELSE NULL 
    END AS DISTRICT_MUNICIPALITY,
    
    -- Metropolitan municipality from MAP_TITLE for metro areas.
    -- Non-DC codes indicate metropolitan municipalities.
    CASE 
        WHEN DC_MDB_C NOT LIKE 'DC%' THEN MAP_TITLE
        ELSE NULL 
    END AS METROPOLITAN_MUNICIPALITY,
    
    -- City not directly available in hospital data.
    NULL AS CITY,
    
    -- Practice name from hospital NAME field.
    NAME AS PRACTICE_NAME,
    
    -- Practice number not available for public hospitals.
    NULL AS PRACTICE_NUM,
    
    -- Practice type hardcoded as Hospital per specification.
    'Hospital' AS PRACTICE_TYPE,
    
    -- Address not available in hospital data.
    NULL AS ADDRESS,
    
    -- Phone not available in hospital data.
    NULL AS PHONE,
    
    -- Funding hardcoded as Public per specification.
    'Public' AS FUNDING,
    
    -- Company not applicable for public hospitals.
    NULL AS COMPANY,
    
    -- Creates GEOGRAPHY point from X (longitude) and Y (latitude).
    ST_MAKEPOINT(X, Y) AS COORDS

FROM MUSA_DAIR_DB.RAW.PHARMACIES_HOSPITALS
WHERE PR_NAME IN ('Gauteng', 'KwaZulu-Natal');


-- ADD SAPC_ID COLUMN
-- Adds column for South African Pharmacy Council identifier.
ALTER TABLE MUSA_DAIR_DB.INTERMEDIATE.PHARMACIES_COMBINED 
ADD COLUMN IF NOT EXISTS SAPC_ID VARCHAR;


-- VALIDATION: HOSPITAL RECORD COUNTS
-- Verifies hospital records were added correctly.
SELECT 'HOSPITAL RECORDS BY PROVINCE' AS VALIDATION;
SELECT 
    PROVINCE,
    COUNT(*) AS HOSPITAL_COUNT
FROM MUSA_DAIR_DB.INTERMEDIATE.PHARMACIES_COMBINED
WHERE PRACTICE_TYPE = 'Hospital'
GROUP BY PROVINCE
ORDER BY PROVINCE;


-- VALIDATION: PRACTICE TYPE DISTRIBUTION
-- Shows distribution of pharmacies vs hospitals.
SELECT 'PRACTICE TYPE DISTRIBUTION' AS VALIDATION;
SELECT 
    PRACTICE_TYPE,
    FUNDING,
    COUNT(*) AS RECORD_COUNT
FROM MUSA_DAIR_DB.INTERMEDIATE.PHARMACIES_COMBINED
GROUP BY PRACTICE_TYPE, FUNDING
ORDER BY PRACTICE_TYPE, FUNDING;


-- VALIDATION: TOTAL RECORDS
-- Total records after hospital append.
SELECT 'TOTAL RECORDS AFTER HOSPITAL APPEND' AS VALIDATION;
SELECT COUNT(*) AS TOTAL_RECORDS 
FROM MUSA_DAIR_DB.INTERMEDIATE.PHARMACIES_COMBINED;
