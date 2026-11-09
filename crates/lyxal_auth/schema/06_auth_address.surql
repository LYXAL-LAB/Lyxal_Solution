-- ============================================================================
-- TABLE  : auth_address
-- MODULE : lyxal_auth
-- RÔLE   : Adresses vérifiables et de récupération d'une identité
-- ============================================================================
-- Modèle : Kratos `identity_verifiable_addresses` et `identity_recovery_addresses`. La
-- vérification (codes, liens) passe par les parcours (`auth_flow`).

DEFINE TABLE OVERWRITE auth_address
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.read" })
            OR fn::auth_shares_organization({ identity: identity, permission: "auth.member.read" })
        -- Un administrateur d'organisation n'écrit que la première adresse de chaque usage d'une
        -- identité qu'il crée dans son organisation ; une adresse de récupération ne change que par
        -- auth.identity.manage (ou le parcours de changement d'adresse de la personne)
        FOR create WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR fn::auth_org_admin_first_address({ identity: identity, channel: channel, usage: usage })
        FOR update, delete WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Adresses vérifiables et de récupération des identités";

DEFINE FIELD OVERWRITE identity ON TABLE auth_address
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Identité propriétaire";

DEFINE FIELD OVERWRITE channel ON TABLE auth_address
    TYPE string
    ASSERT $value IN ["email", "phone"]
    READONLY
    COMMENT "Canal de l'adresse";

DEFINE FIELD OVERWRITE value ON TABLE auth_address
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 320
    COMMENT "Adresse normalisée";

DEFINE FIELD OVERWRITE usage ON TABLE auth_address
    TYPE string
    ASSERT $value IN ["verification", "recovery"]
    READONLY
    COMMENT "Usage : vérification ou récupération";

DEFINE FIELD OVERWRITE verified_at ON TABLE auth_address
    TYPE option<datetime>
    COMMENT "Date de vérification (NONE : non vérifiée)";

DEFINE FIELD OVERWRITE primary ON TABLE auth_address
    TYPE bool
    DEFAULT false
    COMMENT "Adresse principale de son canal";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_address
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_address
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_address_unique ON TABLE auth_address FIELDS channel, value, usage UNIQUE;
DEFINE INDEX OVERWRITE auth_address_identity ON TABLE auth_address FIELDS identity;
