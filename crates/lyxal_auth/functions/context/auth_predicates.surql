-- ============================================================================
-- FONCTIONS : prédicats utilisés par les clauses PERMISSIONS
-- MODULE    : lyxal_auth
-- ============================================================================
-- Jamais d'erreur : un appel invalide vaut faux.

-- ----------------------------------------------------------------------------
-- fn::auth_shares_organization : l'identité est-elle membre de l'organisation active de
-- l'appelant, qui y détient la permission ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_shares_organization($params: object) -> bool {
    IF $auth == NONE OR !type::is_record($auth, "auth_session") { RETURN false; };
    IF !type::is_record($params.identity, "auth_identity") { RETURN false; };
    LET $organization = (SELECT VALUE organization FROM ONLY $auth);
    IF $organization IS NONE { RETURN false; };
    IF !fn::auth_has_permission({ permission: $params.permission, tenant: $organization }) { RETURN false; };
    RETURN array::len(SELECT VALUE id FROM auth_member_of WHERE in = $params.identity AND out = $organization LIMIT 1) > 0;
} COMMENT "Vrai si l'identité ({ identity }) est membre de l'organisation active de l'appelant, qui y détient la permission ({ permission })";

-- ----------------------------------------------------------------------------
-- fn::auth_invitation_pending : l'appelant a-t-il une invitation en attente dans l'organisation
-- (et, si `role` est donné, cette invitation prévoit-elle ce rôle) ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_invitation_pending($params: object) -> bool {
    IF $auth == NONE OR !type::is_record($auth, "auth_session") { RETURN false; };
    IF !type::is_record($params.organization, "auth_organization") { RETURN false; };
    LET $identity = (SELECT VALUE identity FROM ONLY $auth);
    LET $emails = (SELECT VALUE value FROM auth_credential_identifier WHERE identity = $identity AND type = "email");
    LET $invitations = (
        SELECT roles FROM auth_organization_invitation
        WHERE organization = $params.organization AND state = "pending" AND expires_at > time::now() AND email IN $emails
    );
    IF $params.role IS NONE { RETURN array::len($invitations) > 0; };
    RETURN array::any($invitations, |$i| $params.role IN $i.roles);
} COMMENT "Vrai si l'appelant a une invitation en attente et non expirée dans l'organisation ({ organization }), prévoyant le rôle s'il est donné ({ role })";
