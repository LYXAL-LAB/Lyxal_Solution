-- Table organization_role_application_relations
DEFINE TABLE organization_role_application_relations SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_role_application_relations TYPE record<organizations>;
DEFINE FIELD organization_role ON TABLE organization_role_application_relations TYPE record<organization_roles>;
DEFINE FIELD application ON TABLE organization_role_application_relations TYPE record<applications>;
DEFINE FIELD created_at ON TABLE organization_role_application_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ora_rel ON TABLE organization_role_application_relations COLUMNS organization, organization_role, application UNIQUE;
