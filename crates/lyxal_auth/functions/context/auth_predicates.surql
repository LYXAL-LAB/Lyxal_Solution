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
-- fn::auth_org_admin_can_manage : un administrateur d'organisation peut-il gérer cette identité ?
-- ----------------------------------------------------------------------------
-- Seulement une identité membre de sa seule organisation (active), sans rôle d'installation : un
-- membre d'une autre organisation ou un administrateur de la plateforme relève de
-- auth.identity.manage. Les compteurs sont tenus par les événements de la base.

DEFINE FUNCTION OVERWRITE fn::auth_org_admin_can_manage($params: object) -> bool {
    IF !fn::auth_shares_organization({ identity: $params.identity, permission: "auth.member.manage" }) { RETURN false; };
    LET $counts = (SELECT membership_count, installation_role_count FROM ONLY $params.identity);
    RETURN $counts != NONE AND $counts.membership_count <= 1 AND $counts.installation_role_count = 0;
} COMMENT "Vrai si l'appelant gère l'identité ({ identity }) comme administrateur d'organisation : membre de sa seule organisation active, sans rôle d'installation";

-- ----------------------------------------------------------------------------
-- fn::auth_org_admin_first_identifier / fn::auth_org_admin_first_address
-- ----------------------------------------------------------------------------
-- Un administrateur d'organisation n'écrit que le premier identifiant d'un type (ou la première
-- adresse d'un canal et d'un usage) d'une identité qu'il gère : à la création de l'identité.

DEFINE FUNCTION OVERWRITE fn::auth_org_admin_first_identifier($params: object) -> bool {
    IF !fn::auth_org_admin_can_manage({ identity: $params.identity }) { RETURN false; };
    RETURN array::len(SELECT VALUE id FROM auth_credential_identifier WHERE identity = $params.identity AND type = $params.type LIMIT 1) = 0;
} COMMENT "Vrai si l'administrateur d'organisation peut créer un identifiant ({ identity, type }) : identité gérée, aucun identifiant de ce type";

DEFINE FUNCTION OVERWRITE fn::auth_org_admin_first_address($params: object) -> bool {
    IF !fn::auth_org_admin_can_manage({ identity: $params.identity }) { RETURN false; };
    RETURN array::len(SELECT VALUE id FROM auth_address WHERE identity = $params.identity AND channel = $params.channel AND usage = $params.usage LIMIT 1) = 0;
} COMMENT "Vrai si l'administrateur d'organisation peut créer une adresse ({ identity, channel, usage }) : identité gérée, aucune adresse de ce canal et de cet usage";

