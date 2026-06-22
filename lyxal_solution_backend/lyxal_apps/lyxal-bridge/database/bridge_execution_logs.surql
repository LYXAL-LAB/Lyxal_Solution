---
-- Table de persistance des traces d'exécution du Bridge
-- Chaque appel bridge::call() génère une trace complète
-- qui est enregistrée ici pour audit, debugging et monitoring.
--

DEFINE TABLE IF NOT EXISTS bridge_execution_logs 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Journal d'exécution des appels Bridge (traçabilité complète)"
    PERMISSIONS NONE;

---- Identifiant de la trace ----

    DEFINE FIELD IF NOT EXISTS trace_id ON TABLE bridge_execution_logs 
        TYPE string
        ASSERT $value != "" AND $value != NONE
        COMMENT "Identifiant unique de la trace (format: brg-{timestamp_hex}-{random_hex})";

---- Contexte de l'appel ----

    DEFINE FIELD IF NOT EXISTS context ON TABLE bridge_execution_logs 
        TYPE object
        DEFAULT {}
        COMMENT "Contexte de l'appel Bridge";

        DEFINE FIELD IF NOT EXISTS context.provider ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Nom du provider (ex: airtable, slack)";

        DEFINE FIELD IF NOT EXISTS context.operation ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Nom de l'opération (ex: list_records, send_message)";

        DEFINE FIELD IF NOT EXISTS context.source ON TABLE bridge_execution_logs 
            TYPE string
            DEFAULT "surrealql"
            COMMENT "Source de l'appel (surrealql, api, webhook, scheduler)";

        DEFINE FIELD IF NOT EXISTS context.session_id ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "ID de session SurrealDB";

        DEFINE FIELD IF NOT EXISTS context.namespace ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Namespace SurrealDB";

        DEFINE FIELD IF NOT EXISTS context.database ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Database SurrealDB";

---- Phases d'exécution ----

    DEFINE FIELD IF NOT EXISTS phases ON TABLE bridge_execution_logs 
        TYPE array<object>
        DEFAULT []
        COMMENT "Phases d'exécution chronologiques";

        DEFINE FIELD IF NOT EXISTS phases.*.name ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Nom de la phase (resolve_metadata, resolve_auth, build_request, etc.)";

        DEFINE FIELD IF NOT EXISTS phases.*.duration_us ON TABLE bridge_execution_logs 
            TYPE int
            COMMENT "Durée de la phase en microsecondes";

        DEFINE FIELD IF NOT EXISTS phases.*.status ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Statut de la phase (ok, error, skipped)";

        DEFINE FIELD IF NOT EXISTS phases.*.details ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Détails additionnels sur la phase";

---- Requête HTTP ----

    DEFINE FIELD IF NOT EXISTS request ON TABLE bridge_execution_logs 
        TYPE option<object>
        COMMENT "Détails de la requête HTTP construite (secrets masqués)";

        DEFINE FIELD IF NOT EXISTS request.method ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Méthode HTTP (GET, POST, PUT, etc.)";

        DEFINE FIELD IF NOT EXISTS request.url ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "URL complète de la requête";

        DEFINE FIELD IF NOT EXISTS request.headers ON TABLE bridge_execution_logs 
            TYPE array<array<string>>
            DEFAULT []
            COMMENT "Headers HTTP (valeurs sensibles masquées)";

        DEFINE FIELD IF NOT EXISTS request.body_size ON TABLE bridge_execution_logs 
            TYPE option<int>
            COMMENT "Taille du body en octets";

        DEFINE FIELD IF NOT EXISTS request.content_type ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Content-Type du body";

---- Réponse HTTP ----

    DEFINE FIELD IF NOT EXISTS response ON TABLE bridge_execution_logs 
        TYPE option<object>
        COMMENT "Détails de la réponse HTTP reçue";

        DEFINE FIELD IF NOT EXISTS response.status ON TABLE bridge_execution_logs 
            TYPE int
            COMMENT "Code de status HTTP (200, 404, 500...)";

        DEFINE FIELD IF NOT EXISTS response.headers ON TABLE bridge_execution_logs 
            TYPE array<array<string>>
            DEFAULT []
            COMMENT "Headers de la réponse";

        DEFINE FIELD IF NOT EXISTS response.body_size ON TABLE bridge_execution_logs 
            TYPE int
            COMMENT "Taille du body de la réponse en octets";

        DEFINE FIELD IF NOT EXISTS response.content_type ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Content-Type de la réponse";

        DEFINE FIELD IF NOT EXISTS response.round_trip_ms ON TABLE bridge_execution_logs 
            TYPE int
            COMMENT "Durée du round-trip HTTP en millisecondes";

---- Erreurs ----

    DEFINE FIELD IF NOT EXISTS errors ON TABLE bridge_execution_logs 
        TYPE array<object>
        DEFAULT []
        COMMENT "Erreurs rencontrées pendant l'exécution";

        DEFINE FIELD IF NOT EXISTS errors.*.phase ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Phase où l'erreur s'est produite";

        DEFINE FIELD IF NOT EXISTS errors.*.error_type ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Type d'erreur (ProviderNotFound, HttpError, Timeout, etc.)";

        DEFINE FIELD IF NOT EXISTS errors.*.message ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Message d'erreur humainement lisible";

        DEFINE FIELD IF NOT EXISTS errors.*.attempt ON TABLE bridge_execution_logs 
            TYPE option<int>
            COMMENT "Numéro de tentative (pour les retries)";

        DEFINE FIELD IF NOT EXISTS errors.*.at ON TABLE bridge_execution_logs 
            TYPE datetime
            COMMENT "Timestamp de l'erreur";

---- Timestamps ----

    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE bridge_execution_logs 
        TYPE object
        DEFAULT {}
        COMMENT "Timestamps de la trace";

        DEFINE FIELD IF NOT EXISTS timestamp.started_at ON TABLE bridge_execution_logs 
            TYPE datetime
            COMMENT "Début de l'exécution";

        DEFINE FIELD IF NOT EXISTS timestamp.completed_at ON TABLE bridge_execution_logs 
            TYPE option<datetime>
            COMMENT "Fin de l'exécution";

---- Métriques ----

    DEFINE FIELD IF NOT EXISTS metrics ON TABLE bridge_execution_logs 
        TYPE object
        DEFAULT {}
        COMMENT "Métriques de performance";

        DEFINE FIELD IF NOT EXISTS metrics.total_duration_ms ON TABLE bridge_execution_logs 
            TYPE int
            COMMENT "Durée totale d'exécution en millisecondes";

        DEFINE FIELD IF NOT EXISTS metrics.attempts ON TABLE bridge_execution_logs 
            TYPE int
            DEFAULT 1
            COMMENT "Nombre de tentatives HTTP effectuées";

        DEFINE FIELD IF NOT EXISTS metrics.resolve_duration_us ON TABLE bridge_execution_logs 
            TYPE int
            DEFAULT 0
            COMMENT "Durée de résolution des métadonnées en microsecondes";

        DEFINE FIELD IF NOT EXISTS metrics.request_build_duration_us ON TABLE bridge_execution_logs 
            TYPE int
            DEFAULT 0
            COMMENT "Durée de construction de la requête en microsecondes";

        DEFINE FIELD IF NOT EXISTS metrics.http_round_trip_ms ON TABLE bridge_execution_logs 
            TYPE int
            DEFAULT 0
            COMMENT "Durée du round-trip HTTP en millisecondes";

        DEFINE FIELD IF NOT EXISTS metrics.cache_hit ON TABLE bridge_execution_logs 
            TYPE bool
            DEFAULT false
            COMMENT "Les métadonnées venaient-elles du cache ?";

---- Résultat final ----

    DEFINE FIELD IF NOT EXISTS outcome ON TABLE bridge_execution_logs 
        TYPE object
        COMMENT "Résultat final de l'appel";

        DEFINE FIELD IF NOT EXISTS outcome.type ON TABLE bridge_execution_logs 
            TYPE string
            COMMENT "Type de résultat : Success, HttpError, BridgeError";

        DEFINE FIELD IF NOT EXISTS outcome.status ON TABLE bridge_execution_logs 
            TYPE option<int>
            COMMENT "Code HTTP (si applicable)";

        DEFINE FIELD IF NOT EXISTS outcome.error_type ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Type d'erreur Bridge (si applicable)";

        DEFINE FIELD IF NOT EXISTS outcome.message ON TABLE bridge_execution_logs 
            TYPE option<string>
            COMMENT "Message d'erreur (si applicable)";

---- Indexes pour requêtage rapide ----

    DEFINE INDEX IF NOT EXISTS idx_trace_id ON TABLE bridge_execution_logs 
        FIELDS trace_id
        UNIQUE
        COMMENT "Lookup par trace_id";

    DEFINE INDEX IF NOT EXISTS idx_provider_op ON TABLE bridge_execution_logs 
        FIELDS context.provider, context.operation
        COMMENT "Filtrage par provider + opération";

    DEFINE INDEX IF NOT EXISTS idx_started_at ON TABLE bridge_execution_logs 
        FIELDS timestamp.started_at
        COMMENT "Tri chronologique";

    DEFINE INDEX IF NOT EXISTS idx_outcome_type ON TABLE bridge_execution_logs 
        FIELDS outcome.type
        COMMENT "Filtrage par type de résultat (Success/Error)";

    DEFINE INDEX IF NOT EXISTS idx_provider_time ON TABLE bridge_execution_logs 
        FIELDS context.provider, timestamp.started_at
        COMMENT "Historique par provider (tri chronologique)";
