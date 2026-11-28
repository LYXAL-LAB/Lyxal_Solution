-- ============================================================================
-- TABLES : infra_change, infra_change_head
-- MODULE : lyxal_infra
-- RÔLE   : Journal chaîné des changements (intentions d'écriture, issues, décisions)
-- ============================================================================
-- Toute intention d'écriture chez l'hébergeur est notée avant l'appel (state sent), puis son
-- issue (done, failed) ; les décisions et constats (conflit, résolution, approbation, rattachement,
-- mode, suppression humaine constatée) sont notés tels quels (noted). Le contenu d'une entrée
-- (rang, zone, enregistrement, action, avant, après, auteur, date) est chaîné à la précédente
-- (fn::security_audit_entry) et ne change jamais ; seule l'issue d'une entrée sent est posée,
-- une fois. infra_change_head:installation tient le dernier rang et la dernière empreinte.
-- Jamais de secret ; les zones et enregistrements par leur clé.

DEFINE TABLE OVERWRITE infra_change
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "worker" })
        FOR create WHERE fn::infra_can({ action: "manage" }) OR fn::infra_can({ action: "worker" })
        FOR update, delete WHERE fn::infra_can({ action: "worker" })
    COMMENT "Journal chaîné des changements de lyxal_infra";

DEFINE FIELD OVERWRITE rank ON TABLE infra_change
    TYPE int
    READONLY
    ASSERT $value >= 1
    COMMENT "Rang dans la chaîne (1, 2, 3…), unique";

DEFINE FIELD OVERWRITE zone ON TABLE infra_change
    TYPE option<record<infra_zone>>
    READONLY
    COMMENT "Zone (clé opaque ; le lien reste après le détachement)";

DEFINE FIELD OVERWRITE record ON TABLE infra_change
    TYPE option<record<infra_record>>
    READONLY
    COMMENT "Enregistrement voulu concerné";

DEFINE FIELD OVERWRITE action ON TABLE infra_change
    TYPE string
    READONLY
    ASSERT $value IN ["add", "set", "delete", "conflict", "resolve", "approve", "drift_deleted", "attach", "detach", "mode"]
    COMMENT "add, set, delete (écritures chez l'hébergeur) ; conflict, resolve, approve, drift_deleted, attach, detach, mode (constats et décisions)";

DEFINE FIELD OVERWRITE state ON TABLE infra_change
    TYPE string
    ASSERT $value IN ["sent", "done", "failed", "noted"]
    COMMENT "sent (intention notée avant l'appel), done, failed, noted (constat ou décision)";

DEFINE FIELD OVERWRITE before ON TABLE infra_change
    TYPE any
    READONLY
    COMMENT "Valeur avant (objet, NONE remplacé par NULL), jamais de secret";

DEFINE FIELD OVERWRITE after ON TABLE infra_change
    TYPE any
    READONLY
    COMMENT "Valeur après (objet, NONE remplacé par NULL), jamais de secret";

DEFINE FIELD OVERWRITE actor ON TABLE infra_change
    TYPE string
    READONLY
    COMMENT "Auteur : identité, application (compte de service) ou system";

DEFINE FIELD OVERWRITE provider_status ON TABLE infra_change
    TYPE option<int>
    COMMENT "Statut HTTP rendu par le fournisseur";

DEFINE FIELD OVERWRITE code ON TABLE infra_change
    TYPE option<string>
    COMMENT "Code INFRA_* de l'échec";

DEFINE FIELD OVERWRITE previous_hash ON TABLE infra_change
    TYPE option<string>
    READONLY
    COMMENT "Empreinte de l'entrée précédente";

DEFINE FIELD OVERWRITE entry_hash ON TABLE infra_change
    TYPE string
    READONLY
    COMMENT "Empreinte SHA-256 de « <précédente>:<contenu> » (fn::security_audit_entry)";

DEFINE FIELD OVERWRITE created_at ON TABLE infra_change
    TYPE datetime
    READONLY
    COMMENT "Date de l'entrée (dans l'empreinte)";

DEFINE INDEX OVERWRITE infra_change_rank ON TABLE infra_change FIELDS rank UNIQUE;
DEFINE INDEX OVERWRITE infra_change_zone ON TABLE infra_change FIELDS zone, created_at;

-- Garde : une entrée ne change qu'une fois, de sent à done ou failed (statut et code de l'issue).
DEFINE EVENT OVERWRITE infra_change_guard ON TABLE infra_change
WHEN $event = "UPDATE"
THEN {
    IF $before.state != "sent" OR $after.state NOT IN ["done", "failed"] { THROW "INFRA_WRITE_FORBIDDEN"; };
};

DEFINE TABLE OVERWRITE infra_change_head
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "worker" })
        FOR create, update WHERE fn::infra_can({ action: "manage" }) OR fn::infra_can({ action: "worker" })
        FOR delete NONE
    COMMENT "Tête du journal chaîné : dernier rang et dernière empreinte (fiche unique infra_change_head:installation)";

DEFINE FIELD OVERWRITE rank ON TABLE infra_change_head
    TYPE int
    ASSERT $value >= 1
    COMMENT "Dernier rang écrit";

DEFINE FIELD OVERWRITE last_hash ON TABLE infra_change_head
    TYPE string
    COMMENT "Empreinte de la dernière entrée";

-- Garde : la tête n'avance que d'un rang à la fois.
DEFINE EVENT OVERWRITE infra_change_head_guard ON TABLE infra_change_head
WHEN $event = "UPDATE"
THEN {
    IF $after.rank != $before.rank + 1 { THROW "INFRA_WRITE_FORBIDDEN"; };
};
