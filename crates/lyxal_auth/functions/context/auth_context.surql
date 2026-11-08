-- ============================================================================
-- FONCTIONS : contexte d'authentification et contrôle des droits
-- MODULE    : lyxal_auth
-- ============================================================================
-- fn::auth_session_valid, fn::auth_context et fn::auth_has_permission relisent la session à
-- chaque appel (révocation sur connexion ouverte, plan du programme §1.2). Les permissions sont
-- celles du jeton (claim `permissions`, calculées à son émission) ; la version des droits
-- (claim `pv`) dépassée rend la session obsolète jusqu'à son renouvellement.
-- Session système (root de l'hôte) : aucune méthode d'accès et aucun `$auth`.

-- ----------------------------------------------------------------------------
-- fn::auth_session_valid : la session du jeton est-elle utilisable ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_valid($params: object) -> object {
    IF $session.ac == NONE AND $auth == NONE { RETURN { valid: true, system: true, code: NONE }; };
    IF $auth == NONE OR !type::is_record($auth, "auth_session") { RETURN { valid: false, system: false, code: "AUTH_SESSION_REQUIRED" }; };
    LET $s = (SELECT state, created_at, idle_expires_at, expires_at, identity FROM ONLY $auth);
    IF $s == NONE { RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" }; };
    IF $s.state = "revoked" { RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" }; };
    IF $s.state != "active" OR $s.expires_at <= time::now() OR $s.idle_expires_at <= time::now() {
        RETURN { valid: false, system: false, code: "AUTH_SESSION_EXPIRED" };
    };
    LET $i = (SELECT state, not_before, permissions_version FROM ONLY $s.identity);
    IF $i == NONE OR $i.state != "active" { RETURN { valid: false, system: false, code: "AUTH_IDENTITY_INACTIVE" }; };
    IF $i.not_before IS NOT NONE AND $s.created_at < $i.not_before { RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" }; };
    IF !type::is_int($token.pv) OR $token.pv < $i.permissions_version { RETURN { valid: false, system: false, code: "AUTH_SESSION_STALE" }; };
    RETURN { valid: true, system: false, code: NONE };
} COMMENT "Indique si la session du jeton est utilisable (active, non expirée, postérieure à not_before, droits à jour) ; { valid, system, code }";

-- ----------------------------------------------------------------------------
-- fn::auth_context : identité, session, organisation active, permissions, AAL
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_context($params: object) {
    LET $language = IF type::is_string($params.language) { $params.language } ELSE { NONE };
    LET $check = fn::auth_session_valid({});
    IF !$check.valid { RETURN fn::error_result($check.code, $language, {}); };
    IF $check.system {
        RETURN fn::result_ok({ system: true, identity: NONE, session: NONE, organization: NONE, permissions: [], aal: NONE });
    };
    LET $s = (SELECT identity, organization, aal FROM ONLY $auth);
    RETURN fn::result_ok({
        system: false,
        identity: $s.identity,
        session: $auth,
        organization: $s.organization,
        permissions: IF type::is_array($token.permissions) { $token.permissions } ELSE { [] },
        aal: $s.aal
    });
} COMMENT "Contexte de l'appelant : { system, identity, session, organization, permissions, aal } ; erreur AUTH_SESSION_* si la session n'est pas utilisable";

-- ----------------------------------------------------------------------------
-- fn::auth_has_permission : l'appelant détient-il la permission (dans l'organisation) ?
-- ----------------------------------------------------------------------------
-- Jamais d'erreur (utilisable dans une clause PERMISSIONS) : un appel invalide vaut faux.
-- Permission d'installation : présente dans le jeton. Permission d'organisation : présente et
-- `tenant` égal à l'organisation active de la session.

DEFINE FUNCTION OVERWRITE fn::auth_has_permission($params: object) -> bool {
    LET $check = fn::auth_session_valid({});
    IF !$check.valid { RETURN false; };
    IF $check.system { RETURN true; };
    IF !type::is_string($params.permission) OR string::len($params.permission) > 128 { RETURN false; };
    IF !type::is_array($token.permissions) OR $params.permission NOTINSIDE $token.permissions { RETURN false; };
    LET $scope = (SELECT VALUE scope FROM ONLY type::record("auth_permission", $params.permission));
    IF $scope = "installation" { RETURN true; };
    IF $scope != "organization" OR $params.tenant IS NONE OR !type::is_record($params.tenant, "auth_organization") { RETURN false; };
    RETURN $params.tenant = (SELECT VALUE organization FROM ONLY $auth);
} COMMENT "Vrai si l'appelant détient la permission ({ permission, tenant }) : session système, ou session valide dont le jeton porte la permission (et, pour une permission d'organisation, tenant = organisation active). Jamais d'erreur";
