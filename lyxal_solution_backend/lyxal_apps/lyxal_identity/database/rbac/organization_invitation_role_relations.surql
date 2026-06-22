DEFINE TABLE organization_invitation_role_relations SCHEMAFULL;

DEFINE FIELD tenant ON TABLE organization_invitation_role_relations TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD organization_invitation ON TABLE organization_invitation_role_relations TYPE record<organization_invitations> ASSERT $value != NONE;
DEFINE FIELD organization_role ON TABLE organization_invitation_role_relations TYPE record<organization_roles> ASSERT $value != NONE;

DEFINE INDEX relation ON TABLE organization_invitation_role_relations COLUMNS tenant, organization_invitation, organization_role UNIQUE;
