-- =============================================================================
-- TABLE: log
-- =============================================================================
-- DESCRIPTION: Logs des opérations 
-- 
-- FIELDS:
--   result: option<object>
--     { 
--      success: $success, // Indicateur de succès (error_severity)
--      reason_key: $reason_key, // Id du code de retour (error_code)
--     }
--   operation: option<object>
--     { 
--      parent_run_id: $parent_run_id, // UUID du run parent (chaînage de sous-opérations)
--      run_id: $run_id, // UUID unique de l'exécution
--      function_id: $function_id, // ID de la fonction en cours
--      caller_function_id: $caller_function_id, // ID de la fonction appelante
--     }
--   resource: option<object>
--     { 
--      id: $resource_id, // ID de la ressource concernée
--      table_id: $resource_table_id, // ID de la table de la ressource concernée
--      embedding: $resource_embedding, // Optionnel: Vecteur sémantique de la ressource
--     }
-- - target: option<object>
--     { 
--      id: $target_id, // ID de la cible concernée
--      table_id: $target_table_id, // ID de la table de la cible concernée 
--      embedding: $target_embedding, // Optionnel: Vecteur sémantique de la cible
--     }
-- - message: option<object>
--     { 
--      key_id: $message_key_id, // ID de la clé i18n du message
--      vars: $message_vars, // Variables pour le message i18n
--      embedding: $message_embedding, // Optionnel: Vecteur sémantique de la clé de message
--     }
-- - user_id: option<record<user>> // ID de l'utilisateur ayant effectué l'action
-- - meta: Flexible option<object> // Métadonnées (pagination, filtres, etc.)
-- - data: Flexible option<object> // Données additionnelles de l'opération
-- - before: Flexible option<object> // Snapshot métier avant l'opération
-- - after: Flexible option<object> // Snapshot métier après l'opération
-- - log_date: option<object> // Informations sur la date de l'événement
--     {
--      timestamp: $timestamp, // Horodatage précis de l'événement
--      year: $year,           // Année, pour archivage
--      week: $week,           // Numéro de semaine, pour rapports
--      day: $day,             // Date (YYYY-MM-DD), pour regroupements
--      expires_at: $expires_at // Date d'expiration pré-calculée pour le nettoyage
--     }
-- =============================================================================

DEFINE TABLE IF NOT EXISTS log TYPE NORMAL SCHEMAFULL
  COMMENT 'Logs des opérations'
  PERMISSIONS FULL;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Définition des champs
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Objet Result
DEFINE FIELD IF NOT EXISTS result ON log TYPE option<object>
 COMMENT 'Résultat de l\'opération';
DEFINE FIELD IF NOT EXISTS result.success ON log TYPE bool 
 COMMENT 'Indicateur de succès de l\'opération';
DEFINE FIELD IF NOT EXISTS result.reason_key ON log TYPE record<error_code> 
 COMMENT 'Clé du code de retour';

-- Objet Operation
DEFINE FIELD IF NOT EXISTS operation ON log TYPE option<object>
 COMMENT 'Opération en cours';
DEFINE FIELD IF NOT EXISTS operation.run_id ON log TYPE string 
  COMMENT 'UUID unique de l\'exécution';
DEFINE FIELD IF NOT EXISTS operation.parent_run_id ON log TYPE option<string> 
 COMMENT 'UUID du run parent (chaînage)';
DEFINE FIELD IF NOT EXISTS operation.function_id ON log TYPE option<record<builder_catalogue>> 
 COMMENT 'Fonction en cours d\'exécution';
DEFINE FIELD IF NOT EXISTS operation.caller_function_id ON log TYPE option<record<builder_catalogue>> 
 COMMENT 'Fonction qui a appelé la fonction en cours';

-- Objet Resource
DEFINE FIELD IF NOT EXISTS resource ON log TYPE option<object>
 COMMENT 'Ressource concernée';
DEFINE FIELD IF NOT EXISTS resource.id ON log TYPE option<string>
  COMMENT 'ID de la ressource concernée';
DEFINE FIELD IF NOT EXISTS resource.table_id ON log TYPE option<record<builder_catalogue>> 
  COMMENT 'Table de la ressource concernée';
DEFINE FIELD IF NOT EXISTS resource.embedding ON log TYPE option<array<float>> 
 COMMENT 'Vecteur sémantique de la ressource';

-- Objet Target
DEFINE FIELD IF NOT EXISTS target ON log TYPE option<object>
 COMMENT 'Cible concernée';
DEFINE FIELD IF NOT EXISTS target.id ON log TYPE option<string>
 COMMENT 'ID de la cible concernée';
DEFINE FIELD IF NOT EXISTS target.table_id ON log TYPE option<record<builder_catalogue>> 
 COMMENT 'Table de la cible concernée';
DEFINE FIELD IF NOT EXISTS target.embedding ON log TYPE option<array<float>> 
 COMMENT 'Vecteur sémantique de la cible';

-- Objet Message
DEFINE FIELD IF NOT EXISTS message ON log TYPE option<object>
 COMMENT 'Message concerné';
DEFINE FIELD IF NOT EXISTS message.key_id ON log TYPE option<record<i18n_key>> 
 COMMENT 'Clé i18n du message de retour';
DEFINE FIELD IF NOT EXISTS message.vars ON log TYPE option<object> 
  COMMENT 'Variables pour le message i18n';
DEFINE FIELD IF NOT EXISTS message.embedding ON log TYPE option<array<float>> 
 COMMENT 'Vecteur sémantique de la clé de message';

-- Champs de premier niveau
DEFINE FIELD IF NOT EXISTS user_id ON log TYPE option<record<user>> 
  COMMENT 'Utilisateur ayant effectué l\'action';
DEFINE FIELD IF NOT EXISTS meta ON log FLEXIBLE TYPE option<object> 
  COMMENT 'Métadonnées (pagination, filtres, etc.)';
DEFINE FIELD IF NOT EXISTS data ON log FLEXIBLE TYPE option<object> 
  COMMENT 'Données additionnelles de l\'opération';
DEFINE FIELD IF NOT EXISTS before ON log FLEXIBLE TYPE option<object> 
  COMMENT 'Snapshot métier avant l\'opération';
DEFINE FIELD IF NOT EXISTS after ON log FLEXIBLE TYPE option<object> 
  COMMENT 'Snapshot métier après l\'opération';

-- Objet LogDate
DEFINE FIELD IF NOT EXISTS log_date ON log TYPE option<object>
 COMMENT 'Date de l\'événement';
DEFINE FIELD log_date.timestamp ON log TYPE datetime DEFAULT time::now() 
 COMMENT 'Horodatage précis de l\'événement';
DEFINE FIELD IF NOT EXISTS log_date.year ON log TYPE option<number> 
 COMMENT 'Année de l\'événement';
DEFINE FIELD IF NOT EXISTS log_date.week ON log TYPE option<number> 
 COMMENT 'Semaine de l\'événement';
DEFINE FIELD IF NOT EXISTS log_date.day ON log TYPE option<string> 
 COMMENT 'Jour de l\'événement (YYYY-MM-DD)';
DEFINE FIELD IF NOT EXISTS log_date.expires_at ON log TYPE option<datetime> 
 COMMENT 'Date d\'expiration du log';

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Définition des index
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEFINE INDEX IF NOT EXISTS idx_log_timestamp ON log FIELDS log_date.timestamp
  COMMENT 'Index pour trier par date';
DEFINE INDEX IF NOT EXISTS idx_log_user ON log FIELDS user_id
  COMMENT 'Index pour filtrer par utilisateur';
DEFINE INDEX IF NOT EXISTS idx_log_resource_id ON log FIELDS resource.id
  COMMENT 'Index pour filtrer par ressource';
DEFINE INDEX IF NOT EXISTS idx_log_resource_table ON log FIELDS resource.table_id
  COMMENT 'Index pour filtrer par table de ressource';
DEFINE INDEX IF NOT EXISTS idx_log_reason_key ON log FIELDS result.reason_key
  COMMENT 'Index pour filtrer par code de retour';
DEFINE INDEX IF NOT EXISTS idx_log_run_id ON log FIELDS operation.run_id
  COMMENT 'Index pour filtrer par run';
DEFINE INDEX IF NOT EXISTS idx_log_target ON log FIELDS target.table_id, target.id
  COMMENT 'Index pour filtrer par cible';
DEFINE INDEX IF NOT EXISTS idx_log_expires_at ON log FIELDS log_date.expires_at
 COMMENT 'Index pour filtrer par date d\'expiration';