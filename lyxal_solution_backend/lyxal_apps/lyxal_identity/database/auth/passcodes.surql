DEFINE TABLE passcodes SCHEMAFULL;

DEFINE FIELD tenant ON TABLE passcodes TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD interaction_jti ON TABLE passcodes TYPE string;
DEFINE FIELD type ON TABLE passcodes TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON TABLE passcodes TYPE string;
DEFINE FIELD phone ON TABLE passcodes TYPE string;
DEFINE FIELD code ON TABLE passcodes TYPE string ASSERT $value != NONE;
DEFINE FIELD try_count ON TABLE passcodes TYPE int DEFAULT 0;
DEFINE FIELD created_at ON TABLE passcodes TYPE datetime DEFAULT time::now();

DEFINE INDEX interaction_jti_type ON TABLE passcodes COLUMNS tenant, interaction_jti, type;
DEFINE INDEX email_type ON TABLE passcodes COLUMNS tenant, email, type;
DEFINE INDEX phone_type ON TABLE passcodes COLUMNS tenant, phone, type;
