DEFINE TABLE custom_profile_fields SCHEMAFULL;

DEFINE FIELD tenant ON TABLE custom_profile_fields TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD name ON TABLE custom_profile_fields TYPE string ASSERT $value != NONE;
DEFINE FIELD type ON TABLE custom_profile_fields TYPE string ASSERT $value != NONE;
DEFINE FIELD label ON TABLE custom_profile_fields TYPE string DEFAULT "";
DEFINE FIELD description ON TABLE custom_profile_fields TYPE string;
DEFINE FIELD required ON TABLE custom_profile_fields TYPE bool DEFAULT false;
DEFINE FIELD config ON TABLE custom_profile_fields TYPE object DEFAULT {};
DEFINE FIELD created_at ON TABLE custom_profile_fields TYPE datetime DEFAULT time::now();
DEFINE FIELD sie_order ON TABLE custom_profile_fields TYPE int DEFAULT 0;

DEFINE INDEX name ON TABLE custom_profile_fields COLUMNS tenant, name UNIQUE;
