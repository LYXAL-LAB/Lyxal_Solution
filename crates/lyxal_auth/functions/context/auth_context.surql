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
    LET $s = (SELECT state, created_at, idle_expires_at, expires_at, identity, application, api_key FROM ONLY $auth);
    IF $s == NONE { RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" }; };
    IF $s.state = "revoked" { RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" }; };
    IF $s.state != "active" OR $s.expires_at <= time::now() OR $s.idle_expires_at <= time::now() {
        RETURN { valid: false, system: false, code: "AUTH_SESSION_EXPIRED" };
    };
    -- Sujet : identité (session interactive ou clé d'API) ou application (compte de service)
    LET $subject = IF $s.identity IS NOT NONE {
        (SELECT state, not_before, permissions_version FROM ONLY $s.identity)
    } ELSE {
        (SELECT state, not_before, permissions_version FROM ONLY $s.application)
    };
    IF $subject == NONE OR $subject.state != "active" {
        RETURN { valid: false, system: false, code: IF $s.identity IS NOT NONE { "AUTH_IDENTITY_INACTIVE" } ELSE { "AUTH_APPLICATION_INACTIVE" } };
    };
    IF $subject.not_before IS NOT NONE AND $s.created_at < $subject.not_before { RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" }; };
    IF $s.api_key IS NOT NONE {
        LET $key = (SELECT revoked_at, expires_at FROM ONLY $s.api_key);
        IF $key == NONE OR $key.revoked_at IS NOT NONE OR ($key.expires_at IS NOT NONE AND $key.expires_at <= time::now()) {
            RETURN { valid: false, system: false, code: "AUTH_SESSION_REVOKED" };
        };
    };
    IF !type::is_int($token.pv) OR $token.pv < $subject.permissions_version { RETURN { valid: false, system: false, code: "AUTH_SESSION_STALE" }; };
    RETURN { valid: true, system: false, code: NONE };
} COMMENT "Indique si la session du jeton est utilisable (active, non expirée, sujet actif — identité ou application —, postérieure à not_before, clé d'API valide, droits à jour) ; { valid, system, code }";

-- ----------------------------------------------------------------------------
-- fn::auth_context : identité, session, organisation active, permissions, AAL
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_context($params: object) {
    LET $language = IF type::is_string($params.language) { $params.language } ELSE { NONE };
    LET $check = fn::auth_session_valid({});
    IF !$check.valid { RETURN fn::error_result($check.code, $language, {}); };
    IF $check.system {
        RETURN fn::result_ok({ system: true, identity: NONE, application: NONE, kind: NONE, session: NONE, organization: NONE, permissions: [], aal: NONE, amr: [], authenticated_at: NONE });
    };
    LET $s = (SELECT identity, application, kind, organization, aal, amr, authenticated_at FROM ONLY $auth);
    RETURN fn::result_ok({
        system: false,
        identity: $s.identity,
        application: $s.application,
        kind: $s.kind,
        session: $auth,
        organization: $s.organization,
        permissions: IF type::is_array($token.permissions) { $token.permissions } ELSE { [] },
        aal: $s.aal,
        amr: $s.amr.method,
        authenticated_at: $s.authenticated_at
    });
} COMMENT "Contexte de l'appelant : { system, identity, application, kind, session, organization, permissions, aal, amr, authenticated_at } ; erreur AUTH_SESSION_* si la session n'est pas utilisable";

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
    LET $permission = (SELECT scope, min_aal FROM ONLY type::record("auth_permission", $params.permission));
    IF $permission == NONE { RETURN false; };
    LET $s = (SELECT organization, aal FROM ONLY $auth);
    -- Niveau d'assurance relu en base (une réauthentification compte aussitôt, même pour un jeton déjà émis)
    IF ($permission.min_aal ?? 1) > ($s.aal ?? 1) { RETURN false; };
    IF $permission.scope = "installation" { RETURN true; };
    IF $permission.scope != "organization" OR $params.tenant IS NONE OR !type::is_record($params.tenant, "auth_organization") { RETURN false; };
    RETURN $params.tenant = $s.organization;
} COMMENT "Vrai si l'appelant détient la permission ({ permission, tenant }) : session système, ou session valide dont le jeton porte la permission, d'AAL au moins égal au min_aal de la permission (et, pour une permission d'organisation, tenant = organisation active). Jamais d'erreur";
