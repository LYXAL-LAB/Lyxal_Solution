-- ============================================================================
-- TABLE  : secrets_request
-- MODULE : lyxal_secrets
-- RÔLE   : Demande d'accès (kind access) ou de changement d'un secret protégé (kind change)
-- ============================================================================
-- États : pending → approved (nombre d'approbations atteint ; accès : l'accès est créé) ou
-- rejected (un refus) / cancelled (demandeur) / expired (sans réponse) ; changement approuvé →
-- applying → applied (l'auteur l'applique avec ses droits). On n'approuve jamais sa propre
-- demande. Une demande de changement ouverte par secret au plus. Écritures par les fonctions
-- fn::secrets_request_* ; écritures directes gardées par secrets_request_guard. Jamais de valeur.

DEFINE TABLE OVERWRITE secrets_request
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (requested_identity IS NOT NONE AND requested_identity = $auth.identity)
            OR (requested_application IS NOT NONE AND requested_application = $auth.application)
            OR fn::secrets_can({ action: "access", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create WHERE tenant = $auth.organization OR fn::secrets_can({ action: "access", tenant: tenant })
        FOR update WHERE (requested_identity IS NOT NONE AND requested_identity = $auth.identity)
            OR (requested_application IS NOT NONE AND requested_application = $auth.application)
            OR fn::secrets_can({ action: "access", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "worker", tenant: tenant })
    COMMENT "Demande d'accès ou de changement d'un secret protégé, approuvée par d'autres que le demandeur";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_request
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation";

DEFINE FIELD OVERWRITE kind ON TABLE secrets_request
    TYPE string
    READONLY
    ASSERT $value IN ["access", "change"]
    COMMENT "access : demande d'accès ; change : changement d'un secret protégé";

DEFINE FIELD OVERWRITE requested_identity ON TABLE secrets_request
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Demandeur (identité)";

DEFINE FIELD OVERWRITE requested_application ON TABLE secrets_request
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Demandeur (application)";

DEFINE FIELD OVERWRITE path ON TABLE secrets_request
    TYPE string
    READONLY
    ASSERT fn::validation_lyxal_storage_path($value, NONE, true, 256).value == $value
    COMMENT "Chemin demandé (accès) ou chemin du secret (changement)";

DEFINE FIELD OVERWRITE folder ON TABLE secrets_request
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Accès demandé sur un dossier";

DEFINE FIELD OVERWRITE actions ON TABLE secrets_request
    TYPE array<string>
    DEFAULT []
    READONLY
    ASSERT array::all($value, |$a| $a IN ["list", "read_value", "write", "delete"])
    COMMENT "Opérations demandées (accès)";

DEFINE FIELD OVERWRITE duration ON TABLE secrets_request
    TYPE option<duration>
    READONLY
    COMMENT "Durée de l'accès demandé";

DEFINE FIELD OVERWRITE secret ON TABLE secrets_request
    TYPE option<record<secrets_secret>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Secret à changer (changement)";

DEFINE FIELD OVERWRITE operation ON TABLE secrets_request
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR $value IN ["value", "rollback", "disable", "delete", "destroy"]
    COMMENT "Changement : value (version proposée en service), rollback (retour à une version), disable, delete, destroy";

DEFINE FIELD OVERWRITE number ON TABLE secrets_request
    TYPE option<int>
    READONLY
    ASSERT $value IS NONE OR $value >= 1
    COMMENT "Version visée : proposée (value), cible (rollback), à détruire (destroy)";

DEFINE FIELD OVERWRITE reason ON TABLE secrets_request
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 512
    COMMENT "Motif";

DEFINE FIELD OVERWRITE required_approvals ON TABLE secrets_request
    TYPE int
    READONLY
    ASSERT $value >= 1 AND $value <= 5
    COMMENT "Approbations requises, fixées à la création (protection la plus exigeante)";

DEFINE FIELD OVERWRITE approvals ON TABLE secrets_request
    TYPE array<object>
    DEFAULT []
    ASSERT array::len($value) <= 5
    COMMENT "Approbations reçues : { by, at, comment }";

DEFINE FIELD OVERWRITE approvals[*].by ON TABLE secrets_request TYPE string;
DEFINE FIELD OVERWRITE approvals[*].at ON TABLE secrets_request TYPE datetime;
DEFINE FIELD OVERWRITE approvals[*].comment ON TABLE secrets_request TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512;

DEFINE FIELD OVERWRITE state ON TABLE secrets_request
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "approved", "rejected", "cancelled", "expired", "applying", "applied"]
    COMMENT "État : pending, approved, rejected, cancelled, expired, applying, applied";

DEFINE FIELD OVERWRITE open_slot ON TABLE secrets_request
    TYPE string
    VALUE IF $this.kind = "change" AND $this.state IN ["pending", "approved", "applying"] { "open" } ELSE { <string> $this.id }
    COMMENT "Une demande de changement ouverte par secret (index unique)";

DEFINE FIELD OVERWRITE decided_by ON TABLE secrets_request
    TYPE option<string>
    COMMENT "Auteur du refus";

DEFINE FIELD OVERWRITE decision_reason ON TABLE secrets_request
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 512
    COMMENT "Motif du refus ou de l'urgence";

DEFINE FIELD OVERWRITE grant ON TABLE secrets_request
    TYPE option<record<secrets_grant>>
    COMMENT "Accès créé à l'approbation (accès)";

DEFINE FIELD OVERWRITE emergency ON TABLE secrets_request
    TYPE bool
    DEFAULT false
    COMMENT "Changement appliqué en urgence, avant les approbations";

DEFINE FIELD OVERWRITE consumed_at ON TABLE secrets_request
    TYPE option<datetime>
    COMMENT "Changement autorisé exécuté (posé par la garde d'écriture) : une demande n'autorise qu'un seul changement";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_request
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE expires_at ON TABLE secrets_request
    TYPE datetime
    READONLY
    COMMENT "Échéance d'une demande sans réponse";

DEFINE FIELD OVERWRITE decided_at ON TABLE secrets_request
    TYPE option<datetime>
    COMMENT "Décision (approbation finale, refus, annulation, expiration)";

DEFINE FIELD OVERWRITE applied_at ON TABLE secrets_request
    TYPE option<datetime>
    COMMENT "Application du changement";

DEFINE INDEX OVERWRITE secrets_request_open ON TABLE secrets_request FIELDS secret, open_slot UNIQUE;
DEFINE INDEX OVERWRITE secrets_request_state ON TABLE secrets_request FIELDS tenant, state;
DEFINE INDEX OVERWRITE secrets_request_expiry ON TABLE secrets_request FIELDS state, expires_at;
