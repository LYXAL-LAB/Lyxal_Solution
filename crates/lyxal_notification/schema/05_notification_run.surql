-- ============================================================================
-- TABLES : notification_run, notification_job
-- MODULE : lyxal_notification
-- RÔLE   : Déclenchements (idempotents) et étapes à exécuter (file d'envoi)
-- ============================================================================
-- Un déclenchement porte au plus un secret scellé (enc:v2, contexte du module) effacé dès que ses
-- étapes sont terminées ou à son expiration. La file est réservée par `locked_until` et
-- `claim_token` (plusieurs workers possibles).

DEFINE TABLE OVERWRITE notification_run
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Qui déclenche voit ses déclenchements (idempotence vérifiée par relecture)
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) OR fn::notification_can({ action: "send", tenant: tenant })
        FOR create WHERE fn::notification_can({ action: "send", tenant: tenant })
        FOR update, delete WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Déclenchements de parcours pour un destinataire";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_run
    TYPE option<record<auth_organization>>
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_run
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité de la clé d'idempotence";

DEFINE FIELD OVERWRITE workflow ON TABLE notification_run
    TYPE record<notification_workflow>
    READONLY
    COMMENT "Parcours déclenché";

DEFINE FIELD OVERWRITE idempotency_key ON TABLE notification_run
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    READONLY
    COMMENT "Clé d'idempotence (event_id de lyxal_event ou clé fournie)";

DEFINE FIELD OVERWRITE event_id ON TABLE notification_run
    TYPE option<string>
    READONLY
    COMMENT "Événement déclencheur";

DEFINE FIELD OVERWRITE recipient ON TABLE notification_run
    TYPE object
    READONLY
    COMMENT "Destinataire : { email, locale, name }";

DEFINE FIELD OVERWRITE recipient.email ON TABLE notification_run TYPE string;
DEFINE FIELD OVERWRITE recipient.locale ON TABLE notification_run TYPE option<string>;
DEFINE FIELD OVERWRITE recipient.name ON TABLE notification_run TYPE option<string>;

DEFINE FIELD OVERWRITE payload ON TABLE notification_run
    TYPE object
    DEFAULT {}
    READONLY
    COMMENT "Variables non sensibles du gabarit";

DEFINE FIELD OVERWRITE payload.* ON TABLE notification_run TYPE any;

DEFINE FIELD OVERWRITE secret ON TABLE notification_run
    TYPE option<string>
    ASSERT $value IS NONE OR string::starts_with($value, "enc:v2:")
    PERMISSIONS FOR select, update WHERE fn::notification_can({ action: "worker", tenant: tenant }) FOR create FULL
    COMMENT "Variables sensibles scellées (enc:v2), effacées après l'envoi ou à l'expiration";

DEFINE FIELD OVERWRITE status ON TABLE notification_run
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "completed", "failed", "skipped"]
    COMMENT "État";

DEFINE FIELD OVERWRITE skip_reason ON TABLE notification_run
    TYPE option<string>
    COMMENT "Motif d'abandon (adresse supprimée…)";

DEFINE FIELD OVERWRITE created_at ON TABLE notification_run
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE expires_at ON TABLE notification_run
    TYPE datetime
    COMMENT "Fin de validité du secret ; purge du déclenchement selon les réglages";

DEFINE FIELD OVERWRITE purge_after ON TABLE notification_run
    TYPE datetime
    COMMENT "Date de purge (réglage retention_days_runs)";

DEFINE INDEX OVERWRITE notification_run_idempotency ON TABLE notification_run FIELDS scope_key, idempotency_key UNIQUE;
DEFINE INDEX OVERWRITE notification_run_purge ON TABLE notification_run FIELDS purge_after;
DEFINE INDEX OVERWRITE notification_run_secret_expiry ON TABLE notification_run FIELDS expires_at;

DEFINE TABLE OVERWRITE notification_job
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant }) OR fn::notification_can({ action: "send", tenant: run.tenant })
        FOR create WHERE fn::notification_can({ action: "send", tenant: run.tenant })
        FOR update, delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
    COMMENT "Étapes à exécuter (file d'envoi)";

DEFINE FIELD OVERWRITE run ON TABLE notification_job
    TYPE record<notification_run>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Déclenchement";

DEFINE FIELD OVERWRITE step_key ON TABLE notification_job TYPE string READONLY COMMENT "Étape";
DEFINE FIELD OVERWRITE channel ON TABLE notification_job TYPE string ASSERT $value IN ["email"] READONLY COMMENT "Canal";

DEFINE FIELD OVERWRITE status ON TABLE notification_job
    TYPE string
    DEFAULT "queued"
    ASSERT $value IN ["queued", "running", "completed", "failed", "skipped", "canceled"]
    COMMENT "État";

DEFINE FIELD OVERWRITE attempts ON TABLE notification_job TYPE int DEFAULT 0 COMMENT "Tentatives effectuées";
DEFINE FIELD OVERWRITE max_attempts ON TABLE notification_job TYPE int DEFAULT 8 COMMENT "Tentatives au plus";
DEFINE FIELD OVERWRITE next_retry_at ON TABLE notification_job TYPE datetime DEFAULT time::now() COMMENT "Prochaine exécution possible";
DEFINE FIELD OVERWRITE locked_until ON TABLE notification_job TYPE option<datetime> COMMENT "Fin de réservation";
DEFINE FIELD OVERWRITE claim_token ON TABLE notification_job TYPE option<string> COMMENT "Jeton de réservation (UUID v7)";
DEFINE FIELD OVERWRITE worker_id ON TABLE notification_job TYPE option<string> COMMENT "Worker réservataire";

DEFINE FIELD OVERWRITE last_error ON TABLE notification_job
    TYPE option<object>
    COMMENT "Dernière erreur : { class, code, detail }";

DEFINE FIELD OVERWRITE last_error.class ON TABLE notification_job TYPE string;
DEFINE FIELD OVERWRITE last_error.code ON TABLE notification_job TYPE string;
DEFINE FIELD OVERWRITE last_error.detail ON TABLE notification_job TYPE string;

DEFINE FIELD OVERWRITE created_at ON TABLE notification_job TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_job TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_job_queue ON TABLE notification_job FIELDS status, next_retry_at;
DEFINE INDEX OVERWRITE notification_job_run ON TABLE notification_job FIELDS run;
