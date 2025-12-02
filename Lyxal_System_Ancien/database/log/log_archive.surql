-- =============================================================================================
-- |
-- | Fichier : log_archive.surql
-- | Module : System / log
-- | Description : Archive des logs. Miroir exact de la structure de la table `log` pour
-- |               l'archivage des logs anciens. Les logs archivés sont déplacés ici depuis
-- |               la table `log` pour optimiser les performances.
-- |               Refactorisé selon les conventions modulaires Lyxal.
-- |
-- | Dépendances :
-- |   - error_code
-- |   - i18n_key
-- |   - user
-- |   - builder_catalogue
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS log_archive TYPE NORMAL SCHEMAFULL
    COMMENT 'Archive des logs (miroir de la table `log`)'
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE FULL
        FOR UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification du type de log
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE log_archive
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification du type de log';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE log_archive
        TYPE option<string>
        COMMENT 'Code du type de log (ex: OPERATION_SUCCESS, OPERATION_ERROR)';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE log_archive
        TYPE option<string>
        COMMENT 'Slug URL-friendly du type de log';

-- ============================================================================
-- BLOC RESULT : Résultat de l'opération
-- ============================================================================

DEFINE FIELD IF NOT EXISTS result ON TABLE log_archive
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc résultat : résultat de l\'opération';

    DEFINE FIELD IF NOT EXISTS result.success ON TABLE log_archive
        TYPE bool
        COMMENT 'Indicateur de succès de l\'opération';

    DEFINE FIELD IF NOT EXISTS result.reason_key ON TABLE log_archive
        TYPE record<error_code>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Code d\'erreur associé au résultat';

-- ============================================================================
-- BLOC OPERATION : Informations d'exécution
-- ============================================================================

DEFINE FIELD IF NOT EXISTS operation ON TABLE log_archive
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc opération : informations d\'exécution';

    DEFINE FIELD IF NOT EXISTS operation.run_id ON TABLE log_archive
        TYPE string
        COMMENT 'UUID unique de l\'exécution';

    DEFINE FIELD IF NOT EXISTS operation.parent_run_id ON TABLE log_archive
        TYPE option<string>
        COMMENT 'UUID du run parent (chaînage de sous-opérations)';

    DEFINE FIELD IF NOT EXISTS operation.function_id ON TABLE log_archive
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Fonction en cours d\'exécution';

    DEFINE FIELD IF NOT EXISTS operation.caller_function_id ON TABLE log_archive
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Fonction qui a appelé la fonction en cours';

-- ============================================================================
-- BLOC RESOURCE : Ressource principale concernée
-- ============================================================================

DEFINE FIELD IF NOT EXISTS resource ON TABLE log_archive
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc ressource : ressource principale concernée';

    DEFINE FIELD IF NOT EXISTS resource.id ON TABLE log_archive
        TYPE option<string>
        COMMENT 'ID de la ressource concernée';

    DEFINE FIELD IF NOT EXISTS resource.table_id ON TABLE log_archive
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Table de la ressource concernée';

    DEFINE FIELD IF NOT EXISTS resource.embedding ON TABLE log_archive
        TYPE option<array<float>>
        COMMENT 'Vecteur sémantique de la ressource (pour recherche sémantique)';

-- ============================================================================
-- BLOC TARGET : Cible secondaire concernée
-- ============================================================================

DEFINE FIELD IF NOT EXISTS target ON TABLE log_archive
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc cible : ressource secondaire concernée (ex: dans une relation)';

    DEFINE FIELD IF NOT EXISTS target.id ON TABLE log_archive
        TYPE option<string>
        COMMENT 'ID de la cible concernée';

    DEFINE FIELD IF NOT EXISTS target.table_id ON TABLE log_archive
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Table de la cible concernée';

    DEFINE FIELD IF NOT EXISTS target.embedding ON TABLE log_archive
        TYPE option<array<float>>
        COMMENT 'Vecteur sémantique de la cible (pour recherche sémantique)';

-- ============================================================================
-- BLOC MESSAGE : Message traduisible
-- ============================================================================

DEFINE FIELD IF NOT EXISTS message ON TABLE log_archive
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Bloc message : informations pour la traduction des messages';

    DEFINE FIELD IF NOT EXISTS message.key_id ON TABLE log_archive
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n du message de retour';

    DEFINE FIELD IF NOT EXISTS message.vars ON TABLE log_archive
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Variables pour l\'interpolation du message i18n';

    DEFINE FIELD IF NOT EXISTS message.embedding ON TABLE log_archive
        TYPE option<array<float>>
        COMMENT 'Vecteur sémantique du message (pour recherche sémantique)';

-- ============================================================================
-- BLOC CONTENT : Contenu et données de l'opération
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE log_archive
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc contenu : données et métadonnées de l\'opération';

    DEFINE FIELD IF NOT EXISTS content.user_id ON TABLE log_archive
        TYPE option<record<user>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Utilisateur ayant effectué l\'action';

    DEFINE FIELD IF NOT EXISTS content.meta ON TABLE log_archive
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Métadonnées additionnelles (pagination, filtres, etc.)';

    DEFINE FIELD IF NOT EXISTS content.data ON TABLE log_archive
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Données additionnelles de l\'opération';

    DEFINE FIELD IF NOT EXISTS content.before ON TABLE log_archive
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Snapshot métier avant l\'opération';

    DEFINE FIELD IF NOT EXISTS content.after ON TABLE log_archive
        TYPE option<object>
        FLEXIBLE
        COMMENT 'Snapshot métier après l\'opération';

-- ============================================================================
-- BLOC STATUS : État du log
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE log_archive
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état du log';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE log_archive
        TYPE bool
        DEFAULT false
        COMMENT 'Indique si le log est actif (toujours false pour les archives)';

    DEFINE FIELD IF NOT EXISTS status.is_archived ON TABLE log_archive
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si le log a été archivé (toujours true pour les archives)';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE log_archive
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE log_archive
        TYPE option<string>
        DEFAULT "system"
        COMMENT 'Identifiant du créateur du log (utilisateur ou service)';

    DEFINE FIELD IF NOT EXISTS metadata.source ON TABLE log_archive
        TYPE option<string>
        COMMENT 'Source du log (ex: api, function, event)';

    DEFINE FIELD IF NOT EXISTS metadata.archived_at ON TABLE log_archive
        TYPE option<datetime>
        COMMENT 'Date d\'archivage du log';

    DEFINE FIELD IF NOT EXISTS metadata.archived_by ON TABLE log_archive
        TYPE option<string>
        COMMENT 'Identifiant du service ayant archivé le log';

-- ============================================================================
-- BLOC TIMESTAMP : Informations temporelles
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE log_archive
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamp : informations temporelles';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE log_archive
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Horodatage précis de l\'événement original';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE log_archive
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification';

    DEFINE FIELD IF NOT EXISTS timestamp.expires_at ON TABLE log_archive
        TYPE option<datetime>
        COMMENT 'Date d\'expiration pré-calculée pour le nettoyage automatique';

    DEFINE FIELD IF NOT EXISTS timestamp.year ON TABLE log_archive
        TYPE option<number>
        COMMENT 'Année de l\'événement (pour archivage et rapports)';

    DEFINE FIELD IF NOT EXISTS timestamp.week ON TABLE log_archive
        TYPE option<number>
        COMMENT 'Numéro de semaine de l\'événement (pour rapports)';

    DEFINE FIELD IF NOT EXISTS timestamp.day ON TABLE log_archive
        TYPE option<string>
        COMMENT 'Date de l\'événement au format YYYY-MM-DD (pour regroupements)';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE log_archive
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_log_archive_created_at ON TABLE log_archive
    FIELDS timestamp.created_at
    COMMENT 'Index pour trier par date de création';

DEFINE INDEX IF NOT EXISTS idx_log_archive_user_id ON TABLE log_archive
    FIELDS content.user_id
    COMMENT 'Index pour filtrer par utilisateur';

DEFINE INDEX IF NOT EXISTS idx_log_archive_resource_id ON TABLE log_archive
    FIELDS resource.id
    COMMENT 'Index pour filtrer par ressource';

DEFINE INDEX IF NOT EXISTS idx_log_archive_resource_table ON TABLE log_archive
    FIELDS resource.table_id
    COMMENT 'Index pour filtrer par table de ressource';

DEFINE INDEX IF NOT EXISTS idx_log_archive_reason_key ON TABLE log_archive
    FIELDS result.reason_key
    COMMENT 'Index pour filtrer par code de retour';

DEFINE INDEX IF NOT EXISTS idx_log_archive_run_id ON TABLE log_archive
    FIELDS operation.run_id
    COMMENT 'Index pour filtrer par run';

DEFINE INDEX IF NOT EXISTS idx_log_archive_target ON TABLE log_archive
    FIELDS target.table_id, target.id
    COMMENT 'Index pour filtrer par cible';

DEFINE INDEX IF NOT EXISTS idx_log_archive_function_id ON TABLE log_archive
    FIELDS operation.function_id
    COMMENT 'Index pour filtrer par fonction';

DEFINE INDEX IF NOT EXISTS idx_log_archive_expires_at ON TABLE log_archive
    FIELDS timestamp.expires_at
    COMMENT 'Index pour filtrer par date d\'expiration (nettoyage automatique)';

DEFINE INDEX IF NOT EXISTS idx_log_archive_timestamp_day ON TABLE log_archive
    FIELDS timestamp.day
    COMMENT 'Index pour regroupements par jour';
