-- Table organization_user_relations
DEFINE TABLE organization_user_relations SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_user_relations TYPE record<organizations>;
DEFINE FIELD user ON TABLE organization_user_relations TYPE record<users>;
DEFINE FIELD created_at ON TABLE organization_user_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_org_user ON TABLE organization_user_relations COLUMNS organization, user UNIQUE;
