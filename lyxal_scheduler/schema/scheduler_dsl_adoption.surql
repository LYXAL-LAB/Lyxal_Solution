-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  9. scheduler_dsl_adoption                                              │
-- │  Suivi des ressources DSL adoptées par l'API.                          │
-- │  Record ID = composé [type, key]                                        │
-- │     ex: scheduler_dsl_adoption:['calendar', 'france_business']          │
-- │  Source : Croniq dsl_adoptions (migration 007)                          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_dsl_adoption TYPE NORMAL SCHEMAFULL
    COMMENT "Suivi des ressources DSL adoptées par l'API (override du Croniqfile)"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS resource_type
    ON TABLE scheduler_dsl_adoption
    TYPE string
    ASSERT $value IN ['calendar', 'job', 'trigger']
    COMMENT "Type de ressource adoptée : calendar | job | trigger";

DEFINE FIELD IF NOT EXISTS resource_key
    ON TABLE scheduler_dsl_adoption
    TYPE string
    COMMENT "Identifiant DSL de la ressource (nom du calendrier, du job, etc.)";

DEFINE FIELD IF NOT EXISTS adopted_at
    ON TABLE scheduler_dsl_adoption
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date d'adoption";

DEFINE FIELD IF NOT EXISTS adopted_by
    ON TABLE scheduler_dsl_adoption
    TYPE option<string>
    COMMENT "user_id ou api_client_id qui a déclenché l'adoption";

-- Index d'unicité : recherche rapide et protection contre les doublons par type + clé
DEFINE INDEX IF NOT EXISTS idx_dsl_adoption_type_key
    ON TABLE scheduler_dsl_adoption
    FIELDS resource_type, resource_key
    UNIQUE;
