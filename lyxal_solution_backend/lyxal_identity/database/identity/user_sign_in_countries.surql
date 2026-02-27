DEFINE TABLE user_sign_in_countries SCHEMAFULL;

DEFINE FIELD tenant ON TABLE user_sign_in_countries TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD user ON TABLE user_sign_in_countries TYPE record<users> ASSERT $value != NONE;
DEFINE FIELD country ON TABLE user_sign_in_countries TYPE string ASSERT $value != NONE;
DEFINE FIELD last_sign_in_at ON TABLE user_sign_in_countries TYPE datetime DEFAULT time::now();

DEFINE INDEX user_country ON TABLE user_sign_in_countries COLUMNS user, country UNIQUE;
DEFINE INDEX tenant_user_last_sign_in ON TABLE user_sign_in_countries COLUMNS tenant, user, last_sign_in_at;
