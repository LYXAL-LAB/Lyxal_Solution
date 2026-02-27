DEFINE TABLE user_sso_identities SCHEMAFULL;

DEFINE FIELD tenant ON TABLE user_sso_identities TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD user ON TABLE user_sso_identities TYPE record<users> ASSERT $value != NONE;
DEFINE FIELD issuer ON TABLE user_sso_identities TYPE string ASSERT $value != NONE;
DEFINE FIELD identity_id ON TABLE user_sso_identities TYPE string ASSERT $value != NONE;
DEFINE FIELD detail ON TABLE user_sso_identities TYPE object DEFAULT {};
DEFINE FIELD created_at ON TABLE user_sso_identities TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE user_sso_identities TYPE datetime DEFAULT time::now();
DEFINE FIELD sso_connector ON TABLE user_sso_identities TYPE record<sso_connectors> ASSERT $value != NONE;

DEFINE INDEX issuer_identity ON TABLE user_sso_identities COLUMNS tenant, issuer, identity_id UNIQUE;
