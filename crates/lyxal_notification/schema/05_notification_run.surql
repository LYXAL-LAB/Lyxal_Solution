-- ============================================================================
-- TABLES : notification_run, notification_job
-- MODULE : lyxal_notification
-- RÔLE   : Déclenchements (idempotents) et étapes à exécuter (file d'envoi)
-- ============================================================================
-- Un déclenchement porte au plus un secret scellé (enc:v2, contexte du module) effacé dès que ses
-- étapes sont terminées ou à son expiration. Ses étapes s'exécutent dans l'ordre : une étape n'est
-- créée qu'à la fin de la précédente (fn::notification_run_advance). La file est réservée par
-- `locked_until` et `claim_token` (plusieurs workers possibles). Écrits par les fonctions du
-- module, en session de qui déclenche (notification.send, ou notification.manage pour un envoi de
-- test) ou du worker.

DEFINE TABLE OVERWRITE notification_run
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Qui déclenche voit ses déclenchements (idempotence vérifiée par relecture)
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) OR fn::notification_can({ action: "send", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "send", tenant: tenant }) OR fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Déclenchements de parcours pour un abonné";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_run
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
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
    ASSERT string::len($value) >= 1 AND string::len($value) <= 400
    READONLY
    COMMENT "Clé d'idempotence (event_id de lyxal_event ou clé fournie ; <clé>/<subscriber_id> pour une liste ou une diffusion)";

DEFINE FIELD OVERWRITE event_id ON TABLE notification_run
    TYPE option<string>
    READONLY
    COMMENT "Événement déclencheur";

DEFINE FIELD OVERWRITE subscriber ON TABLE notification_run
    TYPE option<record<notification_subscriber>>
    REFERENCE ON DELETE UNSET
    COMMENT "Abonné destinataire (retiré si l'abonné est supprimé : le déclenchement garde l'adresse utilisée jusqu'à sa purge)";

DEFINE FIELD OVERWRITE address ON TABLE notification_run
    TYPE object
    READONLY
    COMMENT "Adresse utilisée, copiée de l'abonné au déclenchement : { email, phone, locale, name, timezone }";

DEFINE FIELD OVERWRITE address.email ON TABLE notification_run TYPE option<string>;
DEFINE FIELD OVERWRITE address.phone ON TABLE notification_run TYPE option<string>;
DEFINE FIELD OVERWRITE address.locale ON TABLE notification_run TYPE option<string>;
DEFINE FIELD OVERWRITE address.name ON TABLE notification_run TYPE option<string>;
DEFINE FIELD OVERWRITE address.timezone ON TABLE notification_run TYPE option<string>;

DEFINE FIELD OVERWRITE broadcast ON TABLE notification_run
    TYPE option<record<notification_broadcast>>
    REFERENCE ON DELETE UNSET
    COMMENT "Diffusion d'origine";

DEFINE FIELD OVERWRITE actor ON TABLE notification_run
    TYPE option<string>
    READONLY
    COMMENT "subscriber_id de l'auteur de l'action";

DEFINE FIELD OVERWRITE organization_locale ON TABLE notification_run
    TYPE option<string>
    PERMISSIONS FOR create, update NONE
    COMMENT "Langue de l'organisation au déclenchement (BCP 47), posée par la base : le worker n'a pas à lire l'organisation";

DEFINE FIELD OVERWRITE payload ON TABLE notification_run
    TYPE object
    DEFAULT {}
    READONLY
    COMMENT "Variables non sensibles du gabarit";

DEFINE FIELD OVERWRITE payload.* ON TABLE notification_run TYPE any;

DEFINE FIELD OVERWRITE secret ON TABLE notification_run
    TYPE option<string>
    ASSERT $value IS NONE OR string::starts_with($value, "enc:v2:")
    -- Lu par le worker seulement ; effacé aussi par l'annulation (session de qui déclenche)
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant }) FOR create, update FULL
    COMMENT "Variables sensibles scellées (enc:v2), effacées après l'envoi, à l'annulation ou à l'expiration";

DEFINE FIELD OVERWRITE status ON TABLE notification_run
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "waiting", "completed", "failed", "skipped", "canceled", "merged"]
    COMMENT "État : pending (étape de canal en file), waiting (attente ou regroupement en cours), completed, failed, skipped, canceled, merged (rejoint un regroupement)";

DEFINE FIELD OVERWRITE skip_reason ON TABLE notification_run
    TYPE option<string>
    COMMENT "Motif d'abandon (suppressed:<motif>, preference:<niveau>, no_address:<canal>, condition, override, throttled, canceled)";

DEFINE FIELD OVERWRITE cursor ON TABLE notification_run
    TYPE int
    DEFAULT 0
    COMMENT "Étape courante : nombre d'étapes du parcours déjà engagées";

DEFINE FIELD OVERWRITE steps ON TABLE notification_run
    TYPE array<object>
    DEFAULT []
    READONLY
    COMMENT "Étapes du parcours copiées au déclenchement : une modification du parcours ne change pas un déclenchement en cours (cursor reste juste)";

DEFINE FIELD OVERWRITE steps.* ON TABLE notification_run
    TYPE object
    FLEXIBLE;

DEFINE FIELD OVERWRITE overrides ON TABLE notification_run
    TYPE object
    FLEXIBLE
    DEFAULT {}
    READONLY
    COMMENT "Surcharges du déclenchement : { steps : { <clé> : { skip, amount, unit, window } } }";

DEFINE FIELD OVERWRITE test ON TABLE notification_run
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Envoi de test : attentes, regroupements et limitations ignorés";

DEFINE FIELD OVERWRITE digest ON TABLE notification_run
    TYPE option<record<notification_digest>>
    REFERENCE ON DELETE UNSET
    COMMENT "Regroupement porté (ouvert par ce déclenchement) ou rejoint (déclenchement merged)";

DEFINE FIELD OVERWRITE created_at ON TABLE notification_run
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE expires_at ON TABLE notification_run
    TYPE option<datetime>
    COMMENT "Échéance : au-delà, les envois restants sont annulés et le secret effacé. Fournie au déclenchement, sinon 7 jours pour un déclenchement avec secret, sinon aucune (une longue attente ne fait rien expirer)";

DEFINE FIELD OVERWRITE purge_after ON TABLE notification_run
    TYPE datetime
    COMMENT "Date de purge (réglage retention_days_runs)";

DEFINE INDEX OVERWRITE notification_run_idempotency ON TABLE notification_run FIELDS scope_key, idempotency_key UNIQUE;
DEFINE INDEX OVERWRITE notification_run_purge ON TABLE notification_run FIELDS purge_after;
DEFINE INDEX OVERWRITE notification_run_secret_expiry ON TABLE notification_run FIELDS expires_at;
DEFINE INDEX OVERWRITE notification_run_subscriber ON TABLE notification_run FIELDS subscriber;
DEFINE INDEX OVERWRITE notification_run_status ON TABLE notification_run FIELDS scope_key, status;

DEFINE TABLE OVERWRITE notification_job
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant }) OR fn::notification_can({ action: "send", tenant: run.tenant })
        FOR create, update WHERE fn::notification_can({ action: "send", tenant: run.tenant }) OR fn::notification_can({ action: "manage", tenant: run.tenant })
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
    COMMENT "Étapes engagées d'un déclenchement (file d'envoi, attentes)";

DEFINE FIELD OVERWRITE run ON TABLE notification_job
    TYPE record<notification_run>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Déclenchement";

DEFINE FIELD OVERWRITE step_key ON TABLE notification_job TYPE string READONLY COMMENT "Étape";
DEFINE FIELD OVERWRITE type ON TABLE notification_job TYPE string ASSERT $value IN ["email", "delay", "digest", "throttle"] READONLY COMMENT "Type de l'étape";

DEFINE FIELD OVERWRITE status ON TABLE notification_job
    TYPE string
    DEFAULT "queued"
    ASSERT $value IN ["queued", "running", "waiting", "completed", "failed", "skipped", "canceled", "merged"]
    COMMENT "État : queued (en file ; attente pas encore confiée au planificateur), running, waiting (attente confiée au planificateur), completed, failed, skipped, canceled, merged (regroupement rejoint)";

DEFINE FIELD OVERWRITE wait_until ON TABLE notification_job TYPE option<datetime> COMMENT "Fin d'une attente ou d'une fenêtre de regroupement";
DEFINE FIELD OVERWRITE scheduler_run ON TABLE notification_job TYPE option<string> COMMENT "Exécution différée de lyxal_scheduler qui reprendra le déclenchement (référence texte)";

DEFINE FIELD OVERWRITE attempts ON TABLE notification_job TYPE int DEFAULT 0 COMMENT "Tentatives effectuées";
DEFINE FIELD OVERWRITE max_attempts ON TABLE notification_job TYPE int DEFAULT 8 COMMENT "Tentatives au plus";
DEFINE FIELD OVERWRITE next_retry_at ON TABLE notification_job TYPE datetime DEFAULT time::now() COMMENT "Prochaine exécution possible";
DEFINE FIELD OVERWRITE locked_until ON TABLE notification_job TYPE option<datetime> COMMENT "Fin de réservation";
DEFINE FIELD OVERWRITE claim_token ON TABLE notification_job TYPE option<string> COMMENT "Jeton de réservation (UUID v7)";
DEFINE FIELD OVERWRITE worker_id ON TABLE notification_job TYPE option<string> COMMENT "Worker réservataire";
DEFINE FIELD OVERWRITE integration ON TABLE notification_job TYPE option<record<notification_integration>> REFERENCE ON DELETE UNSET COMMENT "Intégration de la dernière tentative (bascule D3 : la suivante sert après un échec temporaire)";

DEFINE FIELD OVERWRITE skip_reason ON TABLE notification_job TYPE option<string> COMMENT "Motif d'une étape écartée (preference:<niveau>, no_address:<canal>, condition, override, throttled, test, canceled)";

DEFINE FIELD OVERWRITE last_error ON TABLE notification_job
    TYPE option<object>
    COMMENT "Dernière erreur : { class, code, detail }";

DEFINE FIELD OVERWRITE last_error.class ON TABLE notification_job TYPE string;
DEFINE FIELD OVERWRITE last_error.code ON TABLE notification_job TYPE string;
DEFINE FIELD OVERWRITE last_error.detail ON TABLE notification_job TYPE string;

DEFINE FIELD OVERWRITE created_at ON TABLE notification_job TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_job TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_job_queue ON TABLE notification_job FIELDS status, next_retry_at;
DEFINE INDEX OVERWRITE notification_job_step ON TABLE notification_job FIELDS run, step_key UNIQUE;
DEFINE INDEX OVERWRITE notification_job_wait ON TABLE notification_job FIELDS type, status, wait_until;
