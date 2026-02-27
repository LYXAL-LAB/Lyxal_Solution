-- Table organization_role_resource_scope_relations
DEFINE TABLE organization_role_resource_scope_relations SCHEMAFULL;
DEFINE FIELD organization ON TABLE organization_role_resource_scope_relations TYPE record<organizations>;
DEFINE FIELD organization_role ON TABLE organization_role_resource_scope_relations TYPE record<organization_roles>;
DEFINE FIELD resource ON TABLE organization_role_resource_scope_relations TYPE record<resources>;
DEFINE FIELD scope ON TABLE organization_role_resource_scope_relations TYPE record<scopes>;
DEFINE FIELD created_at ON TABLE organization_role_resource_scope_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_orrs_rel ON TABLE organization_role_resource_scope_relations COLUMNS organization, organization_role, resource, scope UNIQUE;
