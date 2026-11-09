-- ============================================================================
-- TABLE  : auth_credential_identifier
-- MODULE : lyxal_auth
-- RÔLE   : Identifiants de connexion normalisés (e-mail, nom d'utilisateur, téléphone)
-- ============================================================================
-- Modèle : Kratos `identity_credential_identifiers`. Unique par (type, valeur) pour toute
-- l'installation : un e-mail = une identité (D10). Valeurs normalisées par lyxal_core.

DEFINE TABLE OVERWRITE auth_credential_identifier
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.read" })
            OR fn::auth_shares_organization({ identity: identity, permission: "auth.member.read" })
        -- Un administrateur d'organisation n'écrit que le premier identifiant de chaque type d'une
        -- identité qu'il crée dans son organisation ; changer un identifiant exige
        -- auth.identity.manage (ou le parcours de changement d'adresse de la personne)
        FOR create WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR fn::auth_org_admin_first_identifier({ identity: identity, type: type })
        FOR update, delete WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Identifiants de connexion uniques pour l'installation";

DEFINE FIELD OVERWRITE identity ON TABLE auth_credential_identifier
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Identité propriétaire";

DEFINE FIELD OVERWRITE type ON TABLE auth_credential_identifier
    TYPE string
    ASSERT $value IN ["email", "username", "phone"]
    READONLY
    COMMENT "Type d'identifiant";

DEFINE FIELD OVERWRITE value ON TABLE auth_credential_identifier
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 320
    COMMENT "Valeur normalisée (e-mail en minuscules, téléphone E.164…)";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_credential_identifier
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE INDEX OVERWRITE auth_credential_identifier_unique ON TABLE auth_credential_identifier FIELDS type, value UNIQUE;
DEFINE INDEX OVERWRITE auth_credential_identifier_identity ON TABLE auth_credential_identifier FIELDS identity;
