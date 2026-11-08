-- ============================================================================
-- TABLE  : auth_policy
-- MODULE : lyxal_auth
-- RÔLE   : Politique de sécurité de l'installation et surcharges par organisation
-- ============================================================================
-- Modèle : politiques Keycloak (realm), réglages de sécurité Logto. Objets par thème ; la
-- politique effective d'une organisation est celle de l'installation surchargée thème par thème
-- (fn::auth_policy_get).

DEFINE TABLE OVERWRITE auth_policy
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE
            OR fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.read", tenant: tenant })
        FOR create, update WHERE (tenant IS NONE AND fn::auth_has_permission({ permission: "auth.policy.manage" }))
            OR (tenant IS NOT NONE AND (fn::auth_has_permission({ permission: "auth.organization.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.policy.manage", tenant: tenant })))
        FOR delete NONE
    COMMENT "Politique de sécurité : installation et surcharges par organisation";

DEFINE FIELD OVERWRITE tenant ON TABLE auth_policy
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : politique de l'installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE auth_policy
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE password ON TABLE auth_policy
    TYPE option<object>
    COMMENT "Mot de passe : { min_length, require_classes, history }";

DEFINE FIELD OVERWRITE password.min_length ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 8 AND $value <= 128);

DEFINE FIELD OVERWRITE password.require_classes ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 0 AND $value <= 4);

DEFINE FIELD OVERWRITE password.history ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 0 AND $value <= 24);

DEFINE FIELD OVERWRITE lockout ON TABLE auth_policy
    TYPE option<object>
    COMMENT "Verrouillage : { max_failures, lock_seconds }";

DEFINE FIELD OVERWRITE lockout.max_failures ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 3 AND $value <= 100);

DEFINE FIELD OVERWRITE lockout.lock_seconds ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 60 AND $value <= 86400);

DEFINE FIELD OVERWRITE session ON TABLE auth_policy
    TYPE option<object>
    COMMENT "Sessions : { access_seconds, idle_seconds, absolute_seconds }";

DEFINE FIELD OVERWRITE session.access_seconds ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 60 AND $value <= 3600);

DEFINE FIELD OVERWRITE session.idle_seconds ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 300 AND $value <= 2592000);

DEFINE FIELD OVERWRITE session.absolute_seconds ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 3600 AND $value <= 31536000);

DEFINE FIELD OVERWRITE mfa ON TABLE auth_policy
    TYPE option<object>
    COMMENT "Double facteur : { required, methods }";

DEFINE FIELD OVERWRITE mfa.required ON TABLE auth_policy
    TYPE option<bool>;

DEFINE FIELD OVERWRITE mfa.methods ON TABLE auth_policy
    TYPE option<array<string>>;

DEFINE FIELD OVERWRITE mfa.methods.* ON TABLE auth_policy
    TYPE string
    ASSERT $value IN ["totp", "passkey", "recovery_code"];

DEFINE FIELD OVERWRITE invitation ON TABLE auth_policy
    TYPE option<object>
    COMMENT "Invitations : { ttl_seconds }";

DEFINE FIELD OVERWRITE invitation.ttl_seconds ON TABLE auth_policy
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 3600 AND $value <= 2592000);

DEFINE FIELD OVERWRITE registration ON TABLE auth_policy
    TYPE option<object>
    COMMENT "Inscription : { mode } (invitation_only, D9)";

DEFINE FIELD OVERWRITE registration.mode ON TABLE auth_policy
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["invitation_only"];

DEFINE FIELD OVERWRITE created_at ON TABLE auth_policy
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_policy
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_policy_scope_key ON TABLE auth_policy FIELDS scope_key UNIQUE;
