# Limitations

Known limitations of the pharmacy access analysis.

## Shared Limitations

Limitations concerning more than one notebook are merged here.

### Geometric Centroid Placement

Distances are measured from geometric (unweighted) SAL centroids. For compact urban SALs this closely approximates the population center, but for large, irregular rural SALs (common in KZN Traditional areas) the centroid may fall in uninhabited terrain, a river valley, hilltop, or nature reserve, introducing systematic measurement error; some residents may be significantly farther from the nearest pharmacy than the centroid distance suggests. Population-weighted centroids using Google Open Buildings v3 footprints would reduce this bias but are not yet integrated into the pipeline.

[osmnx_network_download](notebooks/osmnx_network_download.ipynb), [sal_pharmacy_distance_k3](notebooks/sal_pharmacy_distance_k3.ipynb), [network_threshold](notebooks/network_threshold.ipynb), [combine_access_score_network_threshold](notebooks/combine_access_score_network_threshold.ipynb).

### OSM Network Coverage Gaps

OSM pedestrian and drive networks have uneven coverage: urban areas are well-mapped, while rural KZN and informal settlements have significant gaps. Missing roads make the algorithm either route through longer detours or mark centroids as unreachable, inflating computed distances; walk distances in these areas may overestimate true pedestrian travel where informal footpaths exist. The `walk_snap_dist_m` and `drive_snap_dist_m` columns quantify this gap for each SAL.

[osmnx_network_download](notebooks/osmnx_network_download.ipynb), [sal_pharmacy_distance_k3](notebooks/sal_pharmacy_distance_k3.ipynb), [network_threshold](notebooks/network_threshold.ipynb), [combine_access_score_network_threshold](notebooks/combine_access_score_network_threshold.ipynb).

### Directed Drive Networks

Drive networks are directed, so one-way streets matter. The k=3 notebook converts to undirected for Dijkstra, which simplifies routing but may slightly underestimate true one-way-constrained drive distances.

[osmnx_network_download](notebooks/osmnx_network_download.ipynb), [sal_pharmacy_distance_k3](notebooks/sal_pharmacy_distance_k3.ipynb).

### Minibus Taxi Mode Not Captured

Neither the walk nor the drive network captures minibus taxi routes, the dominant public transport mode in South Africa. A SAL classified as exceeding the walk threshold may be well-served by a taxi route passing through a pharmacy cluster. Taxi route data are not available at sufficient spatial resolution for integration.

[network_threshold](notebooks/network_threshold.ipynb), [combine_access_score_network_threshold](notebooks/combine_access_score_network_threshold.ipynb).

### Threshold Arbitrariness

Policy thresholds (3 km walk, 10 km drive) are reference points, not natural discontinuities. A SAL at 3.1 km is classified differently from one at 2.9 km despite near-identical access. The multi-threshold approach (1/2/3/5 km walk, 5/10/15/20 km drive) at three k levels mitigates this by showing the full exceedance curve rather than a single binary cut; the threshold flags should be used as a family, not individually.

[network_threshold](notebooks/network_threshold.ipynb), [combine_access_score_network_threshold](notebooks/combine_access_score_network_threshold.ipynb).

## Notebook 1: sal_w_ward_deduplication

Duplicate rows carry identical ward, area, and geometry values, indicating a data artifact from the spatial join construction rather than a SAL-to-ward boundary overlap. The ward-match and EA_CODE-membership cross-checks against `pop_pred_final` now run at the end of `newpred_clean.ipynb`, after that file exists.

## Notebook 3: osmnx_network_download

All limitations noted in this notebook are covered by the Shared Limitations above (geometric centroid placement, OSM coverage gaps, directed drive networks).

## Notebook 4: 2sfca_clean

Limitation statements distilled from the notebook's closing section; the full narrative and comparison tables remain in the notebook.

- The 2SFCA score $A_{i}$ is relative: it is only meaningful within a province and travel mode, whereas absolute network distance is comparable across provinces.
- Zero-inflation is severe: more than half of KZN walk SALs score exactly 0. A zero can mean either a genuinely isolated SAL, a road-network connectivity breakdown near the catchment boundary, or a nearest-node snap that placed the SAL outside any pharmacy's catchment; the latter is a data-quality flag, not a real desert.
- High-score pathology: scores are inflated in low-demand areas (industrial, farms, sparse rural). The "artifact zone" (high $A_{i}$, far distance) accounts for the pathological top scorers in both provinces: Isando and Zwavelpoort in Gauteng walk, and the Malunga/Smukumuku cluster in KZN drive. These should be flagged and excluded from the "well-served" narrative.
- For Gauteng walk, 53.2% of SALs sit in the Pharmacy Desert tier but only 24.6% exceed 3 km; that 28-point gap is almost entirely zero-inflation and snap artifacts rather than true deserts. The score-tier classification obscures this.

## Notebook 5: snap_distance_append

- Snap distance is the **Euclidean** distance from the SAL centroid to the nearest network node in the projected CRS (EPSG:32735, meters). It is not a routed or network distance.
- Walk and drive snap distances differ because the walk and drive graphs have different node sets (different streets qualify for each mode).
- A snap distance of zero means the centroid projected exactly onto a network node, which is rare. Small values (< 50 m) are normal in dense urban areas.
- Large snap distances (> 500 m) indicate either a genuine data gap in OSM for that area, or a large SAL whose geometric centroid falls far from any mapped road. These are the same SALs where the 2SFCA Ai scores and k-nearest distances carry the most measurement uncertainty.
- These columns do not replace the `walk_circuity_k1` and `drive_circuity_k1` columns in `sal_pharmacy_distances_k3.csv`. Circuity captures how tortuous the actual routed path is; snap distance captures how far the path even started from the true centroid position.

## Notebook 6: sal_pharmacy_distance_k3

- Circuity is the ratio of network distance to Euclidean distance, a useful diagnostic. Ratios of 1.2–1.5 are typical for urban grids; higher ratios suggest barriers (rivers, highways, rail lines) or sparse road networks. Extremely high ratios (> 3) may indicate network data gaps.
- Both centroids and pharmacies are snapped to the nearest network node. For pharmacies near highways, this may snap to a highway node rather than the actual pedestrian-accessible entrance. Adding a maximum snap tolerance (e.g. 500 m) would flag pharmacies or centroids far from any mapped road.
- **k=3 compute cost:** the single-source Dijkstra approach is O(P × V log V) per graph, where P = unique pharmacy nodes and V = reachable graph nodes within the cutoff. For province-scale graphs with thousands of pharmacies, this can take several hours per graph. The checkpoint system ensures that interrupted runs resume without losing progress.
- **Cutoff trade-off:** the 50 km Dijkstra cutoff keeps computation bounded. SALs with no pharmacy within 50 km by network show NaN for that mode. This is acceptable because a 50 km network distance represents a travel time well beyond any reasonable access threshold.

## Notebook 7: network_threshold

- **k=1 vs k=3 interpretation:** k=1 exceedance answers "is there any pharmacy within reach?" while k=3 exceedance answers "are there three pharmacies within reach?" A SAL that passes k=1 but fails k=3 has fragile access, dependent on a single facility. The gap between k=1 and k=3 exceedance rates is the "redundancy deficit."

## Notebook 8: combine_access_score_network_threshold

### Population Model Assumptions

The `sal2023_est` column is a modeled estimate, not a census count. It uses a proportional step-down method: each SAL receives a share of its parent ward's 2023 population proportional to its share of the ward's 2011 census population. This assumes that the within-ward population distribution has not changed since 2011, an assumption that breaks for SALs with significant new development (greenfield housing, informal settlement growth) or depopulation. The 1,270 SALs with zero estimated population (truly vacant in 2011 with no dwellings) are included in SAL-count statistics but contribute nothing to population-weighted statistics.

### Snap-flag Concentration Among Deserts

The snap flag cross-tab with Access Typology shows that 36.3% of drive-network "Pharmacy Desert" SALs are snap-flagged, compared to 1.1% of "Well-Served" SALs. This concentration means that some Pharmacy Desert classifications may reflect OSM road data gaps rather than genuine pharmacy absence. However, areas with poor OSM coverage are also areas with poor road infrastructure, so the two effects reinforce rather than contradict each other.

### NaN Network Distances

NaN values in `walk_dist_k{1,2,3}_km` and `drive_dist_k{1,2,3}_km` indicate that no path exists between the SAL centroid and the k-th pharmacy within the 50 km Dijkstra cutoff. This affects 4,931 SALs (12.8%) at walk k=1 and 5,001 SALs (13.0%) at drive k=1. NaN distances are treated as exceeding all thresholds in the exceedance flags; in the Access Typology, NaN distances are treated as "beyond threshold."

### 2SFCA Methodology

The 2SFCA implementation uses a single supply unit per pharmacy ($S_{j} = 1$), meaning all pharmacies are assumed to have equal capacity. In practice, a high-volume chain pharmacy in Sandton and a single-pharmacist dispensary in rural KZN are treated identically; pharmacy capacity data (staffing, dispensing volume, hours) are not available in the dataset.

The minimum weighted population floor (`MIN_WEIGHTED_POP = 50`) prevents near-infinite $R_{j}$ ratios from pharmacies with extremely small catchment populations, capping the maximum $R_{j}$ at 20 (i.e., 1000/50). The floor value is arbitrary; sensitivity to alternative values (25, 100) has not been tested.

### Catchment Thresholds

Province-specific catchment distances (Gauteng walk: 2 km, KZN walk: 3 km; Gauteng drive: 5 km, KZN drive: 10 km) create a discontinuity at the province boundary. SALs on the KZN side of the border receive larger catchments than adjacent SALs in Gauteng's East Rand, despite comparable urbanization. A variable-catchment approach that assigns thresholds by Geography Type (EA_GTYPE) rather than province would eliminate this boundary effect but has not been implemented; the commented-out variable-catchment code exists in `2sfca_clean.ipynb`.

### Access Typology Terciles

The Access Typology uses province-specific terciles computed from nonzero Ai values only, which prevents the large number of zero-Ai SALs (53.2% of Gauteng walk, 74.3% of KZN walk) from pulling the tercile boundaries toward zero. "Low" and "high" are relative within each province, so a "high" Ai in KZN could be numerically lower than a "low" Ai in Gauteng; cross-province comparison of Ai scores requires caution.

### Pharmacy Data Coverage

The pharmacy dataset (2,152 geocoded records: 1,453 Gauteng, 699 KZN) combines records from GEMS, Momentum, Wooltru, SAMWUMED, and Vitality. It covers private-sector and government-employee pharmacies. Hospital pharmacies and informal dispensing points (clinic dispensaries, mobile units) are not included, so the actual number of points where medication can be obtained is likely higher than the pharmacy count and the analysis presents a conservative (pessimistic) view of access.
