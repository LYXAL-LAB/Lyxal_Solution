-- ============================================================================
-- TABLE  : secrets_read_ticket
-- MODULE : lyxal_secrets
-- RÔLE   : Ticket de lecture d'une valeur : à usage unique, 60 secondes
-- ============================================================================
-- Créé avec les droits du demandeur (fn::secrets_read_begin, ou écriture directe soumise aux
-- mêmes règles par secrets_read_ticket_guard) ; sa création écrit l'entrée « read » du journal
-- dans la même transaction. Seule la session système échange un ticket contre l'enveloppe
-- (fn::secrets_read_envelope) : sans trace au journal, aucune valeur n'est remise.

DEFINE TABLE OVERWRITE secrets_read_ticket
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::secrets_can({ action: "read_value", tenant: tenant })
            OR fn::secrets_can({ action: "list", tenant: tenant })
        FOR create WHERE fn::secrets_can({ action: "read_value", tenant: tenant })
        FOR update WHERE fn::secrets_can({ action: "worker", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "worker", tenant: tenant })
            OR fn::secrets_can({ action: "purge", tenant: tenant })
    COMMENT "Ticket de lecture d'une valeur : usage unique, 60 secondes, tracé au journal à sa création";

DEFINE FIELD OVERWRITE secret ON TABLE secrets_read_ticket
    TYPE record<secrets_secret>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Secret lu";

DEFINE FIELD OVERWRITE version ON TABLE secrets_read_ticket
    TYPE record<secrets_version>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Version lue";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_read_ticket
    TYPE option<record<auth_organization>>
    READONLY
    COMMENT "Organisation du secret (NONE : installation)";

DEFINE FIELD OVERWRITE number ON TABLE secrets_read_ticket
    TYPE int
    READONLY
    COMMENT "Numéro de la version lue";

DEFINE FIELD OVERWRITE actor ON TABLE secrets_read_ticket
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Identité du demandeur (NONE : programme ou session système)";

DEFINE FIELD OVERWRITE application ON TABLE secrets_read_ticket
    TYPE option<record<auth_application>>
    READONLY
    COMMENT "Application du demandeur sans identité (compte de service, clé d'API)";

DEFINE FIELD OVERWRITE consumer ON TABLE secrets_read_ticket
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Consommateur annoncé (module, pour la session système ; client_id d'une application)";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_read_ticket
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE expires_at ON TABLE secrets_read_ticket
    TYPE datetime
    DEFAULT time::now() + 60s
    READONLY
    COMMENT "Fin de validité : 60 secondes après la création";

DEFINE FIELD OVERWRITE used_at ON TABLE secrets_read_ticket
    TYPE option<datetime>
    COMMENT "Échange contre l'enveloppe (usage unique)";

DEFINE INDEX OVERWRITE secrets_read_ticket_expiry ON TABLE secrets_read_ticket FIELDS expires_at;
