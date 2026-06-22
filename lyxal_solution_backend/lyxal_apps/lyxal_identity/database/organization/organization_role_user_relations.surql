-- Table organization_role_user_relations
DEFINE TABLE organization_role_user_relations SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_role_user_relations TYPE record<organizations>;
DEFINE FIELD role ON TABLE organization_role_user_relations TYPE record<organization_roles>;
DEFINE FIELD user ON TABLE organization_role_user_relations TYPE record<users>;
DEFINE FIELD created_at ON TABLE organization_role_user_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_org_role_user ON TABLE organization_role_user_relations COLUMNS organization, role, user UNIQUE;
