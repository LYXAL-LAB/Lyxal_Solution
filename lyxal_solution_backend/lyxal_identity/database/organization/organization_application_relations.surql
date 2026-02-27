-- Table organization_application_relations
DEFINE TABLE organization_application_relations SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_application_relations TYPE record<organizations>;
DEFINE FIELD application ON TABLE organization_application_relations TYPE record<applications>;
DEFINE FIELD created_at ON TABLE organization_application_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_org_app ON TABLE organization_application_relations COLUMNS organization, application UNIQUE;
