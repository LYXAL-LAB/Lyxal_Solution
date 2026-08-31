-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  11. scheduler_audit_log                                                │
-- │  Journal d'audit append-only : qui a fait quoi sur quelle ressource.    │
-- │  Record ID = UUID (ex: scheduler_audit_log:⟨uuid⟩)                    │
-- │  Source : Croniq audit_log (migration 016)                              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_audit_log TYPE NORMAL SCHEMAFULL
    COMMENT "Journal d'audit append-only des actions effectuées sur le scheduler"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS actor_type
    ON TABLE scheduler_audit_log
    TYPE string
    ASSERT $value IN ['user', 'api_key', 'pat', 'oidc', 'system']
    COMMENT "Type d'acteur : user | api_key | pat | oidc | system";

DEFINE FIELD IF NOT EXISTS actor_id
    ON TABLE scheduler_audit_log
    TYPE option<string>
    COMMENT "Identifiant de l'acteur (user_id, key_id, etc.)";

DEFINE FIELD IF NOT EXISTS action
    ON TABLE scheduler_audit_log
    TYPE string
    COMMENT "Nom de l'action effectuée (ex: 'job.created', 'execution.replayed')";

DEFINE FIELD IF NOT EXISTS target_type
    ON TABLE scheduler_audit_log
    TYPE string
    COMMENT "Type de ressource ciblée (job, runner, execution, dead_letter, calendar, etc.)";

DEFINE FIELD IF NOT EXISTS target_id
    ON TABLE scheduler_audit_log
    TYPE option<string>
    COMMENT "Identifiant de la ressource ciblée";

DEFINE FIELD IF NOT EXISTS diff_json
    ON TABLE scheduler_audit_log
    TYPE option<object> FLEXIBLE
    COMMENT "Diff JSON ou contexte de l'action (petits payloads)";

DEFINE FIELD IF NOT EXISTS ip_address
    ON TABLE scheduler_audit_log
    TYPE option<string>
    COMMENT "Adresse IP de l'appelant";

DEFINE FIELD IF NOT EXISTS user_agent
    ON TABLE scheduler_audit_log
    TYPE option<string>
    COMMENT "User-Agent HTTP de la requête";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_audit_log
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de l'événement d'audit";

-- Index : filtrage chronologique (Activity Feed)
DEFINE INDEX IF NOT EXISTS idx_audit_log_created
    ON TABLE scheduler_audit_log
    FIELDS created_at;

-- Index : historique par ressource ciblée (Onglet Audit par job)
DEFINE INDEX IF NOT EXISTS idx_audit_log_target
    ON TABLE scheduler_audit_log
    FIELDS target_type, target_id;

-- Index : recherche par acteur
DEFINE INDEX IF NOT EXISTS idx_audit_log_actor
    ON TABLE scheduler_audit_log
    FIELDS actor_type, actor_id;
