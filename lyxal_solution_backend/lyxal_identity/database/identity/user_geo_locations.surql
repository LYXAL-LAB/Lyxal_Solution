DEFINE TABLE user_geo_locations SCHEMAFULL;

DEFINE FIELD tenant ON TABLE user_geo_locations TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD user ON TABLE user_geo_locations TYPE record<users> ASSERT $value != NONE;
DEFINE FIELD latitude ON TABLE user_geo_locations TYPE float;
DEFINE FIELD longitude ON TABLE user_geo_locations TYPE float;
DEFINE FIELD updated_at ON TABLE user_geo_locations TYPE datetime DEFAULT time::now();

-- Ensure both are null or both are set
DEFINE FIELD location_check ON TABLE user_geo_locations TYPE bool 
    VALUE (latitude == NONE AND longitude == NONE) OR (latitude != NONE AND longitude != NONE);
