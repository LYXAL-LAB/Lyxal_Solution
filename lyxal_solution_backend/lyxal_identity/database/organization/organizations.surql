DEFINE TABLE organizations SCHEMAFULL;

DEFINE FIELD tenant_id ON TABLE organizations TYPE string;
DEFINE FIELD name ON TABLE organizations TYPE string;
DEFINE FIELD description ON TABLE organizations TYPE option<string>;
DEFINE FIELD custom_data ON TABLE organizations TYPE object DEFAULT {};
DEFINE FIELD is_mfa_required ON TABLE organizations TYPE bool DEFAULT false;
DEFINE FIELD color ON TABLE organizations TYPE object DEFAULT {};
DEFINE FIELD branding ON TABLE organizations TYPE object DEFAULT {};
DEFINE FIELD custom_css ON TABLE organizations TYPE option<string>;
DEFINE FIELD created_at ON TABLE organizations TYPE datetime DEFAULT time::now();

DEFINE INDEX organizations_tenant_id_id ON TABLE organizations COLUMNS tenant_id, id;
