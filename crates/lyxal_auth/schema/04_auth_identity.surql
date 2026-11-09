-- ============================================================================
-- TABLE  : auth_identity
-- MODULE : lyxal_auth
-- RÔLE   : Identités des personnes (les comptes de service sont des auth_application)
-- ============================================================================
-- Modèle : Kratos `identities`, Logto `users`, Keycloak `USER_ENTITY`. Un e-mail = une identité
-- pour toute l'installation (D10). Pas de suppression physique : état `deleted` ; la purge
-- différée est prévue par la feuille de route (ROADMAP.md).

DEFINE TABLE OVERWRITE auth_identity
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND id = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.read" })
            OR fn::auth_shares_organization({ identity: id, permission: "auth.member.read" })
        FOR create WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR ($auth IS NOT NONE AND fn::auth_has_permission({ permission: "auth.member.manage", tenant: $auth.organization }))
        -- Un administrateur d'organisation ne modifie que les traits (sans identifiant ni adresse,
        -- fn::auth_identity_update_traits) d'un membre de sa seule organisation ; les champs de
        -- sécurité n'appartiennent qu'à auth.identity.manage et aux événements de la base
        FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR fn::auth_org_admin_can_manage({ identity: id })
        FOR delete NONE
    COMMENT "Identités de l'installation (un e-mail = une identité)";

DEFINE FIELD OVERWRITE schema ON TABLE auth_identity
    TYPE record<auth_identity_schema>
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Schéma de traits appliqué";

DEFINE FIELD OVERWRITE traits ON TABLE auth_identity
    TYPE object
    COMMENT "Traits validés par le schéma (e-mail, nom, langue…)";

DEFINE FIELD OVERWRITE traits.* ON TABLE auth_identity
    TYPE any;

DEFINE FIELD OVERWRITE state ON TABLE auth_identity
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "inactive", "locked", "deleted"]
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "État : active, inactive, verrouillée ou supprimée";

DEFINE FIELD OVERWRITE external_id ON TABLE auth_identity
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Identifiant dans un système externe (unique s'il est renseigné)";

DEFINE FIELD OVERWRITE public_metadata ON TABLE auth_identity
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées visibles par l'identité";

DEFINE FIELD OVERWRITE public_metadata.* ON TABLE auth_identity
    TYPE any;

DEFINE FIELD OVERWRITE admin_metadata ON TABLE auth_identity
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées réservées à l'administration";

DEFINE FIELD OVERWRITE admin_metadata.* ON TABLE auth_identity
    TYPE any;

DEFINE FIELD OVERWRITE available_aal ON TABLE auth_identity
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0 AND $value <= 2
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Niveau d'assurance atteignable (0 : aucun moyen, 1 : un facteur, 2 : deux facteurs)";

DEFINE FIELD OVERWRITE not_before ON TABLE auth_identity
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Toute session créée avant cette date est refusée (révocation globale)";

DEFINE FIELD OVERWRITE permissions_version ON TABLE auth_identity
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Version des droits, incrémentée à chaque changement de rôle ou d'adhésion";

DEFINE FIELD OVERWRITE membership_count ON TABLE auth_identity
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Nombre d'organisations dont l'identité est membre (tenu par les événements de auth_member_of)";

DEFINE FIELD OVERWRITE installation_role_count ON TABLE auth_identity
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Nombre de rôles d'installation de l'identité (tenu par les événements de auth_has_role)";

DEFINE FIELD OVERWRITE last_login_at ON TABLE auth_identity
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
    COMMENT "Dernière connexion";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_identity
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE deleted_at ON TABLE auth_identity
    TYPE option<datetime>
    PERMISSIONS FOR create, update NONE
    COMMENT "Date du passage à l'état deleted (écrite par la base) ; purge après la durée de conservation";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_identity
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_identity_external_id ON TABLE auth_identity FIELDS external_id UNIQUE;
DEFINE INDEX OVERWRITE auth_identity_state ON TABLE auth_identity FIELDS state;

-- Une identité supprimée ne revient pas ; sortir de l'état actif pose not_before
DEFINE EVENT OVERWRITE auth_identity_state_guard ON TABLE auth_identity
WHEN $event = "UPDATE" AND $before.state != $after.state
THEN {
    IF $before.state = "deleted" { THROW "AUTH_IDENTITY_INACTIVE"; };
};

-- Passage à l'état supprimé : date posée par la base (point de départ de la conservation)
DEFINE EVENT OVERWRITE auth_identity_deleted_at ON TABLE auth_identity
WHEN $event = "UPDATE" AND $before.state != "deleted" AND $after.state = "deleted"
THEN {
    UPDATE $after.id SET deleted_at = time::now();
};
