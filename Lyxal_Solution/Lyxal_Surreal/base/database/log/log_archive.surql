-- =============================================================================================
-- |
-- | Fichier : log_archive.surql
-- | Module : base
-- | Description : Archive des logs. Doit être un miroir exact de la structure de la table `log`.
-- |
-- | Structure :
-- |   - result: object (success, reason_key)
-- |   - operation: object (run_id, parent_run_id, function_id, caller_function_id)
-- |   - resource: object (id, table_id, embedding)
-- |   - target: object (id, table_id, embedding)
-- |   - message: object (key, vars, embedding)
-- |   - user_id: record<user>
-- |   - meta: object
-- |   - data: object
-- |   - before: object
-- |   - after: object
-- |   - log_date: object (timestamp, year, week, day, expires_at)
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS log_archive TYPE NORMAL SCHEMAFULL
  COMMENT 'Archive des logs (miroir de la table `log`)'
  PERMISSIONS FULL;

-- =============================================================================
-- Objets Structurés
-- =============================================================================

-- Objet Result: Contient le résultat de l'opération.
DEFINE FIELD IF NOT EXISTS result ON log_archive TYPE option<object>
 COMMENT 'Résultat de l\'opération';
DEFINE FIELD IF NOT EXISTS result.success ON log_archive TYPE bool 
 COMMENT 'Indicateur de succès de l\'opération';
DEFINE FIELD IF NOT EXISTS result.reason_key ON log_archive TYPE record<error_code> 
 COMMENT 'Clé du code de retour';

-- Objet Operation: Contient les informations d'exécution.
DEFINE FIELD IF NOT EXISTS operation ON log_archive TYPE option<object>
 COMMENT 'Opération en cours';
DEFINE FIELD IF NOT EXISTS operation.run_id ON log_archive TYPE string 
 COMMENT 'UUID unique de l\'exécution';
DEFINE FIELD IF NOT EXISTS operation.parent_run_id ON log_archive TYPE option<string>
 COMMENT 'UUID du run parent (chaînage)';
DEFINE FIELD IF NOT EXISTS operation.function_id ON log_archive 
 TYPE option<record<builder_catalogue>> 
 COMMENT 'Fonction en cours d\'exécution';
DEFINE FIELD IF NOT EXISTS operation.caller_function_id ON log_archive 
 TYPE option<record<builder_catalogue>> 
 COMMENT 'Fonction qui a appelé la fonction en cours';

-- Objet Resource: La ressource principale sur laquelle l'opération a agi.
DEFINE FIELD IF NOT EXISTS resource ON log_archive TYPE option<object>
 COMMENT 'Ressource concernée';
DEFINE FIELD IF NOT EXISTS resource.id ON log_archive TYPE option<string> 
 COMMENT 'ID de la ressource concernée';
DEFINE FIELD IF NOT EXISTS resource.table_id ON log_archive TYPE option<record<builder_catalogue>>
 COMMENT 'Table de la ressource concernée';
DEFINE FIELD IF NOT EXISTS resource.embedding ON log_archive TYPE option<array<float>> 
 COMMENT 'Vecteur sémantique de la ressource';

-- Objet Target: La ressource secondaire (ex: dans une relation).
DEFINE FIELD IF NOT EXISTS target ON log_archive TYPE option<object>
 COMMENT 'Cible concernée';
DEFINE FIELD IF NOT EXISTS target.id ON log_archive TYPE option<string> 
 COMMENT 'ID de la cible';
DEFINE FIELD IF NOT EXISTS target.table_id ON log_archive TYPE option<record<builder_catalogue>> 
 COMMENT 'Table de la cible';
DEFINE FIELD IF NOT EXISTS target.embedding ON log_archive TYPE option<array<float>> 
 COMMENT 'Vecteur sémantique de la cible';

-- Objet Message: Informations pour la traduction des messages.
DEFINE FIELD IF NOT EXISTS message ON log_archive TYPE option<object>
 COMMENT 'Message concerné';
DEFINE FIELD IF NOT EXISTS message.key ON log_archive TYPE option<record<i18n_key>> 
 COMMENT 'Clé du message à traduire';
DEFINE FIELD IF NOT EXISTS message.vars ON log_archive TYPE option<object>  
 COMMENT 'Variables pour le message';
DEFINE FIELD IF NOT EXISTS message.embedding ON log_archive TYPE option<array<float>> 
  COMMENT 'Vecteur sémantique du message';

-- Objet LogDate: Informations temporelles sur le log.
DEFINE FIELD IF NOT EXISTS log_date ON log_archive TYPE option<object>
 COMMENT 'Informations temporelles sur le log';
DEFINE FIELD IF NOT EXISTS log_date.timestamp ON log_archive TYPE datetime DEFAULT time::now() 
 COMMENT 'Horodatage précis de l\'événement';
DEFINE FIELD IF NOT EXISTS log_date.year ON log_archive TYPE option<number> 
 COMMENT 'Année de l\'événement';
DEFINE FIELD IF NOT EXISTS log_date.week ON log_archive TYPE option<number> 
 COMMENT 'Semaine de l\'événement';
DEFINE FIELD IF NOT EXISTS log_date.day ON log_archive TYPE option<string> 
 COMMENT 'Jour de l\'événement (YYYY-MM-DD)';
DEFINE FIELD IF NOT EXISTS log_date.expires_at ON log_archive TYPE option<datetime> COMMENT 'Date d''expiration du log (pour archivage/suppression)';

-- =============================================================================
-- Champs de Premier Niveau
-- =============================================================================

DEFINE FIELD IF NOT EXISTS user_id ON log_archive TYPE option<record<user>> 
 COMMENT 'Utilisateur ayant effectué l\'action';
DEFINE FIELD IF NOT EXISTS meta ON log_archive TYPE option<object> 
  COMMENT 'Métadonnées (pagination, filtres, etc.)';
DEFINE FIELD IF NOT EXISTS data ON log_archive TYPE option<object> 
 COMMENT 'Données additionnelles de l\'opération';
DEFINE FIELD IF NOT EXISTS before ON log_archive TYPE option<object> 
 COMMENT 'Snapshot métier avant l\'opération';
DEFINE FIELD IF NOT EXISTS after ON log_archive TYPE option<object> 
 COMMENT 'Snapshot métier après l\'opération';

-- =============================================================================
-- Index
-- =============================================================================

DEFINE INDEX IF NOT EXISTS idx_log_archive_timestamp ON log_archive FIELDS log_date.timestamp
 COMMENT 'Index pour trier par date';
DEFINE INDEX IF NOT EXISTS idx_log_archive_user ON log_archive FIELDS user_id
 COMMENT 'Index pour filtrer par utilisateur';
DEFINE INDEX IF NOT EXISTS idx_log_archive_resource ON log_archive 
 FIELDS resource.table_id, resource.id
 COMMENT 'Index pour filtrer par ressource';
DEFINE INDEX IF NOT EXISTS idx_log_archive_reason ON log_archive FIELDS result.reason_key
 COMMENT 'Index pour filtrer par code de retour';
DEFINE INDEX IF NOT EXISTS idx_log_archive_run ON log_archive FIELDS operation.run_id
 COMMENT 'Index pour filtrer par run';
DEFINE INDEX IF NOT EXISTS idx_log_archive_target ON log_archive FIELDS target.table_id, target.id
 COMMENT 'Index pour filtrer par cible';
DEFINE INDEX IF NOT EXISTS idx_log_archive_function ON log_archive FIELDS operation.function_id
 COMMENT 'Index pour filtrer par fonction';