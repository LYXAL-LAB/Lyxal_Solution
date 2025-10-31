-- =============================================================================================
-- |
-- | Fichier     : region_seeds.surql
-- | Module      : geographical
-- | Description : Peuple la table `region` avec les régions géographiques mondiales.
-- |
-- =============================================================================================

-- ===================================
-- | AFRIQUE (AF)
-- ===================================
CREATE region:eastern_africa SET key.name = i18n_key:region_eastern_africa_name, continent = continent:af, location = (40.0, -5.0);
CREATE region:middle_africa SET key.name = i18n_key:region_middle_africa_name, continent = continent:af, location = (20.0, 0.0);
CREATE region:northern_africa SET key.name = i18n_key:region_northern_africa_name, continent = continent:af, location = (10.0, 25.0);
CREATE region:southern_africa SET key.name = i18n_key:region_southern_africa_name, continent = continent:af, location = (25.0, -25.0);
CREATE region:western_africa SET key.name = i18n_key:region_western_africa_name, continent = continent:af, location = (0.0, 10.0);
CREATE region:caribbean SET key.name = i18n_key:region_caribbean_name, continent = continent:na, location = (-70.0, 18.0);
CREATE region:central_america SET key.name = i18n_key:region_central_america_name, continent = continent:na, location = (-85.0, 12.0);
CREATE region:northern_america SET key.name = i18n_key:region_northern_america_name, continent = continent:na, location = (-100.0, 50.0);
CREATE region:south_america SET key.name = i18n_key:region_south_america_name, continent = continent:sa, location = (-60.0, -15.0);
CREATE region:central_asia SET key.name = i18n_key:region_central_asia_name, continent = continent:as, location = (65.0, 45.0);
CREATE region:eastern_asia SET key.name = i18n_key:region_eastern_asia_name, continent = continent:as, location = (115.0, 35.0);
CREATE region:south_eastern_asia SET key.name = i18n_key:region_south_eastern_asia_name, continent = continent:as, location = (110.0, 5.0);
CREATE region:southern_asia SET key.name = i18n_key:region_southern_asia_name, continent = continent:as, location = (78.0, 23.0);
CREATE region:western_asia SET key.name = i18n_key:region_western_asia_name, continent = continent:as, location = (45.0, 35.0);
CREATE region:eastern_europe SET key.name = i18n_key:region_eastern_europe_name, continent = continent:eu, location = (30.0, 52.0);
CREATE region:northern_europe SET key.name = i18n_key:region_northern_europe_name, continent = continent:eu, location = (15.0, 60.0);
CREATE region:southern_europe SET key.name = i18n_key:region_southern_europe_name, continent = continent:eu, location = (15.0, 42.0);
CREATE region:western_europe SET key.name = i18n_key:region_western_europe_name, continent = continent:eu, location = (5.0, 50.0);
CREATE region:australia_and_new_zealand SET key.name = i18n_key:region_australia_and_new_zealand_name, continent = continent:oc, location = (135.0, -27.0);
CREATE region:melanesia SET key.name = i18n_key:region_melanesia_name, continent = continent:oc, location = (160.0, -10.0);
CREATE region:micronesia SET key.name = i18n_key:region_micronesia_name, continent = continent:oc, location = (150.0, 10.0);
CREATE region:polynesia SET key.name = i18n_key:region_polynesia_name, continent = continent:oc, location = (-150.0, -15.0);