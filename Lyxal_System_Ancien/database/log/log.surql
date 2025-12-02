-- =============================================================================================
-- |
-- | Fichier : log.surql
-- | Module : System / log
-- | Description : Table de logs des opérations système. Enregistre toutes les opérations
-- |               avec leur résultat, contexte d'exécution, ressources concernées et messages.
-- |               Refactorisé selon les conventions modulaires Lyxal.
-- |
-- | Dépendances :
-- |   - error_code
-- |   - i18n_key
-- |   - user
-- |   - builder_catalogue
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS log TYPE NORMAL SCHEMAFULL
    COMMENT 'Logs des opérations système'
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE FULL
        FOR UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification du type de log
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE log
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification du type de log';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE log
        TYPE option<string>
        COMMENT 'Code du type de log (ex: OPERATION_SUCCESS, OPERATION_ERROR)';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE log
        TYPE option<string>
        COMMENT 'Slug URL-friendly du type de log';

-- ============================================================================
-- BLOC RESULT : Résultat de l'opération
-- ============================================================================

DEFINE FIELD IF NOT EXISTS result ON TABLE log
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc résultat : résultat de l\'opération';

    DEFINE FIELD IF NOT EXISTS result.success ON TABLE log
        TYPE bool
        COMMENT 'Indicateur de succès de l\'opération';

    DEFINE FIELD IF NOT EXISTS result.reason_key ON TABLE log
        TYPE record<error_code>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Code d\'erreur associé au résultat';

-- ============================================================================
-- BLOC OPERATION : Informations d'exécution
-- ============================================================================

DEFINE FIELD IF NOT EXISTS operation ON TABLE log
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc opération : informations d\'exécution';

    DEFINE FIELD IF NOT EXISTS operation.run_id ON TABLE log
        TYPE string
        COMMENT 'UUID unique de l\'exécution';

    DEFINE FIELD IF NOT EXISTS operation.parent_run_id ON TABLE log
        TYPE option<string>
        COMMENT 'UUID du run parent (chaînage de sous-opérations)';

    DEFINE FIELD IF NOT EXISTS operation.function_id ON TABLE log
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Fonction en cours d\'exécution';

    DEFINE FIELD IF NOT EXISTS operation.caller_function_id ON TABLE log
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Fonction qui a appelé la fonction en cours';

-- ============================================================================
-- BLOC RESOURCE : Ressource principale concernée
-- ============================================================================

DEFINE FIELD IF NOT EXISTS resource ON TABLE log
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc ressource : ressource principale concernée';

    DEFINE FIELD IF NOT EXISTS resource.id ON TABLE log
        TYPE option<string>
        COMMENT 'ID de la ressource concernée';

    DEFINE FIELD IF NOT EXISTS resource.table_id ON TABLE log
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Table de la ressource concernée';

    DEFINE FIELD IF NOT EXISTS resource.embedding ON TABLE log
        TYPE option<array<float>>
        COMMENT 'Vecteur sémantique de la ressource (pour recherche sémantique)';

-- ============================================================================
-- BLOC TARGET : Cible secondaire concernée
-- ============================================================================

DEFINE FIELD IF NOT EXISTS target ON TABLE log
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc cible : ressource secondaire concernée (ex: dans une relation)';

    DEFINE FIELD IF NOT EXISTS target.id ON TABLE log
        TYPE option<string>
        COMMENT 'ID de la cible concernée';

    DEFINE FIELD IF NOT EXISTS target.table_id ON TABLE log
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Table de la cible concernée';

    DEFINE FIELD IF NOT EXISTS target.embedding ON TABLE log
        TYPE option<array<float>>
        COMMENT 'Vecteur sémantique de la cible (pour recherche sémantique)';

-- ============================================================================
-- BLOC MESSAGE : Message traduisible
-- ============================================================================

DEFINE FIELD IF NOT EXISTS message ON TABLE log
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc message : informations pour la traduction des messages';

    DEFINE FIELD IF NOT EXISTS message.key_id ON TABLE log
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n du message de retour';

    DEFINE FIELD IF NOT EXISTS message.vars ON TABLE log
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Variables pour l\'interpolation du message i18n';

    DEFINE FIELD IF NOT EXISTS message.embedding ON TABLE log
        TYPE option<array<float>>
        COMMENT 'Vecteur sémantique du message (pour recherche sémantique)';

-- ============================================================================
-- BLOC CONTENT : Contenu et données de l'opération
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE log
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc contenu : données et métadonnées de l\'opération';

    DEFINE FIELD IF NOT EXISTS content.user_id ON TABLE log
        TYPE option<record<user>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Utilisateur ayant effectué l\'action';

    DEFINE FIELD IF NOT EXISTS content.meta ON TABLE log
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Métadonnées additionnelles (pagination, filtres, etc.)';

    DEFINE FIELD IF NOT EXISTS content.data ON TABLE log
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Données additionnelles de l\'opération';

    DEFINE FIELD IF NOT EXISTS content.before ON TABLE log
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Snapshot métier avant l\'opération';

    DEFINE FIELD IF NOT EXISTS content.after ON TABLE log
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Snapshot métier après l\'opération';

-- ============================================================================
-- BLOC STATUS : État du log
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE log
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état du log';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE log
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si le log est actif (non archivé)';

    DEFINE FIELD IF NOT EXISTS status.is_archived ON TABLE log
        TYPE bool
        DEFAULT false
        COMMENT 'Indique si le log a été archivé';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE log
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE log
        TYPE option<string>
        DEFAULT "system"
        COMMENT 'Identifiant du créateur du log (utilisateur ou service)';

    DEFINE FIELD IF NOT EXISTS metadata.source ON TABLE log
        TYPE option<string>
        COMMENT 'Source du log (ex: api, function, event)';

-- ============================================================================
-- BLOC TIMESTAMP : Informations temporelles
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE log
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamp : informations temporelles';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE log
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Horodatage précis de l\'événement';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE log
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification';

    DEFINE FIELD IF NOT EXISTS timestamp.expires_at ON TABLE log
        TYPE option<datetime>
        COMMENT 'Date d\'expiration pré-calculée pour le nettoyage automatique';

    DEFINE FIELD IF NOT EXISTS timestamp.year ON TABLE log
        TYPE option<number>
        COMMENT 'Année de l\'événement (pour archivage et rapports)';

    DEFINE FIELD IF NOT EXISTS timestamp.week ON TABLE log
        TYPE option<number>
        COMMENT 'Numéro de semaine de l\'événement (pour rapports)';

    DEFINE FIELD IF NOT EXISTS timestamp.day ON TABLE log
        TYPE option<string>
        COMMENT 'Date de l\'événement au format YYYY-MM-DD (pour regroupements)';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE log
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_log_created_at ON TABLE log
    FIELDS timestamp.created_at
    COMMENT 'Index pour trier par date de création';

DEFINE INDEX IF NOT EXISTS idx_log_user_id ON TABLE log
    FIELDS content.user_id
    COMMENT 'Index pour filtrer par utilisateur';

DEFINE INDEX IF NOT EXISTS idx_log_resource_id ON TABLE log
    FIELDS resource.id
    COMMENT 'Index pour filtrer par ressource';

DEFINE INDEX IF NOT EXISTS idx_log_resource_table ON TABLE log
    FIELDS resource.table_id
    COMMENT 'Index pour filtrer par table de ressource';

DEFINE INDEX IF NOT EXISTS idx_log_reason_key ON TABLE log
    FIELDS result.reason_key
    COMMENT 'Index pour filtrer par code de retour';

DEFINE INDEX IF NOT EXISTS idx_log_run_id ON TABLE log
    FIELDS operation.run_id
    COMMENT 'Index pour filtrer par run';

DEFINE INDEX IF NOT EXISTS idx_log_target ON TABLE log
    FIELDS target.table_id, target.id
    COMMENT 'Index pour filtrer par cible';

DEFINE INDEX IF NOT EXISTS idx_log_expires_at ON TABLE log
    FIELDS timestamp.expires_at
    COMMENT 'Index pour filtrer par date d\'expiration (nettoyage automatique)';

DEFINE INDEX IF NOT EXISTS idx_log_status_active ON TABLE log
    FIELDS status.is_active
    COMMENT 'Index pour filtrer les logs actifs';

DEFINE INDEX IF NOT EXISTS idx_log_status_archived ON TABLE log
    FIELDS status.is_archived
    COMMENT 'Index pour filtrer les logs archivés';

DEFINE INDEX IF NOT EXISTS idx_log_timestamp_day ON TABLE log
    FIELDS timestamp.day
    COMMENT 'Index pour regroupements par jour';
