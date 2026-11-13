-- ============================================================================
-- TABLES : secrets_audit, secrets_audit_head
-- MODULE : lyxal_secrets
-- RÔLE   : Journal chaîné du coffre-fort, en ajout seul ; tête de chaîne par portée
-- ============================================================================
-- Écrit uniquement par les DEFINE EVENT du module (fn::secrets_audit_write), qui s'exécutent sans
-- contrôle de droits ; aucun utilisateur ne crée, ne modifie ni ne supprime une entrée. Chaque
-- entrée porte l'empreinte de la précédente (fn::security_audit_entry de lyxal_core) : une
-- modification par une session système est détectée par fn::secrets_audit_verify. Le numéro
-- (scope_key, seq) est unique : deux écritures simultanées d'une même portée ne peuvent pas
-- fourcher la chaîne, l'une échoue et est rejouée. Jamais de valeur de secret.

DEFINE TABLE OVERWRITE secrets_audit
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::secrets_can({ action: "audit", tenant: tenant })
        FOR create, update, delete NONE
    COMMENT "Journal chaîné du coffre-fort, en ajout seul ; jamais de valeur";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_audit
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation) ; le journal part avec elle";

DEFINE FIELD OVERWRITE scope_key ON TABLE secrets_audit
    TYPE string
    READONLY
    COMMENT "Portée de la chaîne : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE seq ON TABLE secrets_audit
    TYPE int
    READONLY
    ASSERT $value >= 1
    COMMENT "Rang dans la chaîne de la portée (1, 2, 3…)";

DEFINE FIELD OVERWRITE event ON TABLE secrets_audit
    TYPE object
    FLEXIBLE
    READONLY
    COMMENT "Entrée : { seq, action, outcome, actor, application, session, session_kind, ip, secret, path, version, details, at } ; sujet de l'empreinte";

DEFINE FIELD OVERWRITE previous_hash ON TABLE secrets_audit
    TYPE option<string>
    READONLY
    COMMENT "Empreinte de l'entrée précédente (NONE pour la première)";

DEFINE FIELD OVERWRITE entry_hash ON TABLE secrets_audit
    TYPE string
    READONLY
    COMMENT "Empreinte SHA-256 de « <précédente>:<entrée> » (fn::security_audit_entry)";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_audit
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Écriture";

DEFINE INDEX OVERWRITE secrets_audit_seq ON TABLE secrets_audit FIELDS scope_key, seq UNIQUE;
DEFINE INDEX OVERWRITE secrets_audit_secret ON TABLE secrets_audit FIELDS event.secret;

DEFINE TABLE OVERWRITE secrets_audit_head
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::secrets_can({ action: "audit", tenant: tenant })
        FOR create, update, delete NONE
    COMMENT "Tête de la chaîne d'une portée : dernier rang et dernière empreinte";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_audit_head
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE seq ON TABLE secrets_audit_head
    TYPE int
    COMMENT "Dernier rang écrit";

DEFINE FIELD OVERWRITE last_hash ON TABLE secrets_audit_head
    TYPE string
    COMMENT "Empreinte de la dernière entrée (détecte la suppression d'entrées en fin de chaîne)";
