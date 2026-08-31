-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  4. scheduler_dead_letter                                               │
-- │  File d'attente des tâches définitivement en échec.                    │
-- │  Record ID = UUID (ex: scheduler_dead_letter:⟨uuid⟩)                  │
-- │  Source : Croniq dead_letters (migrations 001, 009, 022)               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_dead_letter TYPE NORMAL SCHEMAFULL
    COMMENT "Tâches définitivement en échec (après épuisement des retries)"
    CHANGEFEED 1d
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS execution_id
    ON TABLE scheduler_dead_letter
    TYPE record<scheduler_execution>
    COMMENT "Lien direct vers l'exécution d'origine";

DEFINE FIELD IF NOT EXISTS job_key
    ON TABLE scheduler_dead_letter
    TYPE record<scheduler_job_definition>
    COMMENT "Lien direct vers la définition du job concerné";

DEFINE FIELD IF NOT EXISTS fire_at
    ON TABLE scheduler_dead_letter
    TYPE datetime
    COMMENT "Date de mise en file d'attente";

DEFINE FIELD IF NOT EXISTS scheduled_for
    ON TABLE scheduler_dead_letter
    TYPE option<datetime>
    COMMENT "Date de tir logique d'origine";

DEFINE FIELD IF NOT EXISTS attempt
    ON TABLE scheduler_dead_letter
    TYPE int
    COMMENT "Tentative à laquelle le job a échoué définitivement";

DEFINE FIELD IF NOT EXISTS error
    ON TABLE scheduler_dead_letter
    TYPE string
    COMMENT "Message d'erreur final";

DEFINE FIELD IF NOT EXISTS dead_reason
    ON TABLE scheduler_dead_letter
    TYPE string
    COMMENT "Raison : max_retries_exceeded | timeout | manual | etc.";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE scheduler_dead_letter
    TYPE string
    DEFAULT 'pending'
    ASSERT $value IN ['pending', 'replayed', 'ignored', 'resolved']
    COMMENT "Statut du traitement DLQ : pending | replayed | ignored | resolved";

DEFINE FIELD IF NOT EXISTS replayed_at
    ON TABLE scheduler_dead_letter
    TYPE option<datetime>
    COMMENT "Date du rejeu de la dead letter";

DEFINE FIELD IF NOT EXISTS replayed_by
    ON TABLE scheduler_dead_letter
    TYPE option<string>
    COMMENT "Auteur/Module ayant demandé le rejeu";

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE scheduler_dead_letter
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Métadonnées de contexte dynamiques";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_dead_letter
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création de la dead letter";

DEFINE FIELD IF NOT EXISTS expires_at
    ON TABLE scheduler_dead_letter
    TYPE option<datetime>
    COMMENT "Date d'expiration automatique (purge par le watchdog)";

-- Unicité : une exécution ne génère qu'une seule dead letter
DEFINE INDEX IF NOT EXISTS idx_dead_letter_execution_id
    ON TABLE scheduler_dead_letter
    FIELDS execution_id UNIQUE;

-- Index : filtrer par job
DEFINE INDEX IF NOT EXISTS idx_dead_letter_job_key
    ON TABLE scheduler_dead_letter
    FIELDS job_key;

-- Index : affichage rapide du Dashboard DLQ (tâches non résolues récurrentes)
DEFINE INDEX IF NOT EXISTS idx_dead_letter_status_created
    ON TABLE scheduler_dead_letter
    FIELDS status, created_at;

-- Index : purge par expiration
DEFINE INDEX IF NOT EXISTS idx_dead_letter_expires_at
    ON TABLE scheduler_dead_letter
    FIELDS expires_at;