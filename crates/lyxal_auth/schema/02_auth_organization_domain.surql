-- ============================================================================
-- TABLE  : auth_organization_domain
-- MODULE : lyxal_auth
-- RÔLE   : Domaines e-mail vérifiés d'une organisation (rattachement automatique)
-- ============================================================================
-- Modèle : Keycloak `ORG_DOMAIN`, Logto `organization_jit_email_domains`. La vérification se fait
-- par un enregistrement DNS TXT `_lyxal-challenge.<domaine>` lu en Rust par l'hôte, sur sa session
-- système : seule celle-ci change l'état et lit l'empreinte du jeton de défi.

DEFINE TABLE OVERWRITE auth_organization_domain
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: organization })
    COMMENT "Domaines e-mail d'une organisation, vérifiés par DNS TXT";

DEFINE FIELD OVERWRITE organization ON TABLE auth_organization_domain
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation propriétaire du domaine";

DEFINE FIELD OVERWRITE domain ON TABLE auth_organization_domain
    TYPE string
    ASSERT string::len($value) >= 3 AND string::len($value) <= 253 AND $value == string::lowercase($value)
    READONLY
    COMMENT "Nom de domaine normalisé (minuscules)";

DEFINE FIELD OVERWRITE state ON TABLE auth_organization_domain
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "verified"]
    PERMISSIONS FOR select, create FULL FOR update WHERE fn::auth_session_valid({}).system
    COMMENT "État : en attente de vérification ou vérifié ; seule la session système (lecture DNS par l'hôte) le change";

DEFINE FIELD OVERWRITE challenge_hash ON TABLE auth_organization_domain
    TYPE string
    ASSERT string::len($value) = 64 AND string::is_hexadecimal($value)
    PERMISSIONS FOR create FULL FOR select, update WHERE fn::auth_session_valid({}).system
    COMMENT "Empreinte BLAKE3 (hex) du jeton de défi publié en DNS TXT ; jamais le jeton";

DEFINE FIELD OVERWRITE verified_at ON TABLE auth_organization_domain
    TYPE option<datetime>
    PERMISSIONS FOR select, create FULL FOR update WHERE fn::auth_session_valid({}).system
    COMMENT "Date de vérification";

DEFINE FIELD OVERWRITE auto_join ON TABLE auth_organization_domain
    TYPE bool
    DEFAULT false
    COMMENT "Rattachement automatique des identités dont l'e-mail appartient au domaine (vérifié seulement)";

DEFINE FIELD OVERWRITE default_roles ON TABLE auth_organization_domain
    TYPE array<record<auth_role>>
    DEFAULT []
    COMMENT "Rôles d'organisation attribués lors d'un rattachement automatique";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_organization_domain
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_organization_domain
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_organization_domain_domain ON TABLE auth_organization_domain FIELDS domain UNIQUE;
DEFINE INDEX OVERWRITE auth_organization_domain_organization ON TABLE auth_organization_domain FIELDS organization;

-- Le rattachement automatique exige un domaine vérifié ; seule la session système vérifie
DEFINE EVENT OVERWRITE auth_organization_domain_guard ON TABLE auth_organization_domain
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    IF $after.auto_join AND $after.state != "verified" { THROW "AUTH_DOMAIN_NOT_VERIFIED"; };
    IF ($before.state ?? "pending") != $after.state AND !fn::auth_session_valid({}).system { THROW "AUTH_PERMISSION_DENIED"; };
};
