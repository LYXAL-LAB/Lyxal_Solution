-- Table organization_role_scope_relations
DEFINE TABLE organization_role_scope_relations SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_role_scope_relations TYPE record<organizations>;
DEFINE FIELD organization_role ON TABLE organization_role_scope_relations TYPE record<organization_roles>;
DEFINE FIELD scope ON TABLE organization_role_scope_relations TYPE record<scopes>;
DEFINE FIELD created_at ON TABLE organization_role_scope_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ors_rel ON TABLE organization_role_scope_relations COLUMNS organization, organization_role, scope UNIQUE;
