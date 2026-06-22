-- Table organization_jit_roles (Just-In-Time role assignment)
DEFINE TABLE organization_jit_roles SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_jit_roles TYPE record<organizations>;
DEFINE FIELD role ON TABLE organization_jit_roles TYPE record<organization_roles>;
DEFINE FIELD created_at ON TABLE organization_jit_roles TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_org_jit_role ON TABLE organization_jit_roles COLUMNS organization, role UNIQUE;
