DEFINE TABLE organization_invitations SCHEMAFULL;

DEFINE FIELD tenant_id ON TABLE organization_invitations TYPE string;
DEFINE FIELD inviter_id ON TABLE organization_invitations TYPE option<record<users>>;
DEFINE FIELD invitee ON TABLE organization_invitations TYPE string;
DEFINE FIELD accepted_user_id ON TABLE organization_invitations TYPE option<record<users>>;
DEFINE FIELD organization_id ON TABLE organization_invitations TYPE record<organizations>;
DEFINE FIELD status ON TABLE organization_invitations TYPE string 
    ASSERT $value IN ['Pending', 'Accepted', 'Expired', 'Revoked'];
DEFINE FIELD created_at ON TABLE organization_invitations TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE organization_invitations TYPE datetime DEFAULT time::now();
DEFINE FIELD expires_at ON TABLE organization_invitations TYPE datetime;

DEFINE INDEX organization_invitations_pending_unique 
    ON TABLE organization_invitations 
    COLUMNS tenant_id, invitee, organization_id 
    UNIQUE 
    WHERE status = 'Pending';
