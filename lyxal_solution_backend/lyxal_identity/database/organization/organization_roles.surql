-- Table organization_roles
DEFINE TABLE organization_roles SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_roles TYPE record<organizations>;
DEFINE FIELD name ON TABLE organization_roles TYPE string;
DEFINE FIELD description ON TABLE organization_roles TYPE option<string>;
DEFINE FIELD is_default ON TABLE organization_roles TYPE bool DEFAULT false;
DEFINE FIELD created_at ON TABLE organization_roles TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE organization_roles TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_org_role_name ON TABLE organization_roles COLUMNS organization, name UNIQUE;
