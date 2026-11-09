# Pharmacy Access in Gauteng and KwaZulu-Natal

Measures how far residents of each SAL in Gauteng and KwaZulu-Natal live from a registered pharmacy and how that access tracks apartheid-era geography.

## Geography

**SAL**: A Stats SA Small Area Layer polygon, the unit every access metric is reported for. Identified by an 8-digit code.

**Settlement Type**: One of eight neighborhood classes a SAL belongs to: Suburb, Farms & Smallholdings, Township, Informal Settlement, Traditional (Former Homeland), Collective Living Quarters, Non-Residential, or No Dwellings (2011).

**No Dwellings (2011)**: The Settlement Type for SALs where the 2011 Census enumerated no dwellings.

**Geography Type**: Stats SA's three-way classification of a SAL as Urban, Traditional, or Farms.

**Wealth Class**: DAIR's grouping of Settlement Types into Wealthy, Non-Wealthy, and Non-Residential.

**Ward**: A 2020 municipal ward; the larger unit that census population totals are published at and then apportioned down to SALs.

## Population

**Modeled Population**: A SAL's estimated 2023 population: its share of its Ward's 2011 population applied to the Ward's 2022 Census total.

**Population Group**: The Stats SA 2011 Census classification of residents as Black African, Coloured, Indian/Asian, White or Other. Population Group figures are always 2011 counts.

**Majority Population Group**: The Population Group with the most 2011 residents in a SAL (a plurality, not necessarily over half). Ties go to the group listed first above. SALs with no Population Group data have none.

## Access

**2SFCA Score**: A SAL's pharmacy accessibility score from the two-step floating catchment area method with distance decay, computed separately for walking and driving.

**Distance Threshold**: The policy reference distance to the nearest pharmacy: 3 km walking, 10 km driving.

**Snap Distance**: The Euclidean distance from a SAL's geometric centroid to the nearest node on a mode's network graph, in meters (EPSG:32735). A Snap Flag marks SALs whose Snap Distance exceeds 500 m.

**Snap Flag**: A mark on a SAL whose center lies more than 500 m from the nearest road-network node, so its network distances and 2SFCA score are less reliable.

**Access Typology**: A per-SAL, per-mode class that crosses the 2SFCA score tier with whether the nearest pharmacy is within the Distance Threshold.

**Pharmacy Desert**: An Access Typology class: no pharmacy reachable within the catchment and the nearest pharmacy is beyond the Distance Threshold.

**Connectivity Gap**: An Access Typology class: the nearest pharmacy is within the Distance Threshold, yet the 2SFCA score is zero.

**Demand Overcrowding**: An Access Typology class: the nearest pharmacy is within the Distance Threshold but the 2SFCA score is in the bottom tercile, so nearby pharmacies serve too many people.

**Well-Served**: An Access Typology class: the nearest pharmacy is within the Distance Threshold and the 2SFCA score is above the bottom tercile.

**Access Gap**, **Artifact Zone**: Access Typology classes that are defined but have no members in the current data.

**Access Share**: A group of SALs' share of its province's total access (each SAL's 2SFCA score weighted by its Modeled Population), per mode. Always read next to the group's Population Share.

**Population Share**: A group of SALs' share of its province's Modeled Population; the baseline an Access Share is compared against.

## Interpretation

**Limitation**: A known shortcoming or caveat in the data, methods, or interpretation that qualifies what the analysis can claim. Consolidated in `limitations.md`.
