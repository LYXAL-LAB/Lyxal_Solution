-- ============================================================================
-- TABLE  : scheduler_audit
-- MODULE : lyxal_scheduler
-- RÔLE   : Journal des actions des personnes, en ajout seul
-- ============================================================================
-- Écrit uniquement par les DEFINE EVENT du module (fn::scheduler_audit_write) ; aucun utilisateur
-- ne crée, ne modifie ni ne supprime une entrée. Trace les créations, modifications, pauses,
-- reprises, suppressions, déclenchements, rejeux, annulations, relances, réglages, calendriers,
-- files et tâches ; pas chaque exécution (suivie par scheduler_run). Jamais d'arguments.

DEFINE TABLE OVERWRITE scheduler_audit
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "read", tenant: tenant })
        FOR create, update, delete NONE
    COMMENT "Journal des actions des personnes, en ajout seul ; jamais d'arguments";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_audit
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation) ; le journal part avec elle";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_audit
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE action ON TABLE scheduler_audit
    TYPE string
    READONLY
    ASSERT string::len($value) >= 3 AND string::len($value) <= 64
    COMMENT "Action (schedule.create, run.cancel, settings.update…)";

DEFINE FIELD OVERWRITE actor ON TABLE scheduler_audit
    TYPE option<string>
    READONLY
    COMMENT "Identité ou application de l'auteur (NONE : session système)";

DEFINE FIELD OVERWRITE session_kind ON TABLE scheduler_audit
    TYPE option<string>
    READONLY
    COMMENT "Type de session : system, interactive, service, api_key";

DEFINE FIELD OVERWRITE ip ON TABLE scheduler_audit
    TYPE option<string>
    READONLY
    COMMENT "Adresse de la session";

DEFINE FIELD OVERWRITE schedule ON TABLE scheduler_audit
    TYPE option<string>
    READONLY
    COMMENT "Planification concernée";

DEFINE FIELD OVERWRITE run ON TABLE scheduler_audit
    TYPE option<string>
    READONLY
    COMMENT "Exécution concernée";

DEFINE FIELD OVERWRITE details ON TABLE scheduler_audit
    TYPE object
    FLEXIBLE
    DEFAULT {}
    READONLY
    COMMENT "Détails (champs modifiés, motif…) ; jamais d'arguments";

DEFINE FIELD OVERWRITE created_at ON TABLE scheduler_audit
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Écriture";

DEFINE INDEX OVERWRITE scheduler_audit_scope ON TABLE scheduler_audit FIELDS scope_key, created_at;
DEFINE INDEX OVERWRITE scheduler_audit_schedule ON TABLE scheduler_audit FIELDS schedule;
