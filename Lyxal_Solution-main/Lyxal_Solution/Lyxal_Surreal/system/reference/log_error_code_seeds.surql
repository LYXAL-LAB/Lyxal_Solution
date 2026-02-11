-- =============================================================================================
-- |
-- | Fichier : log_error_code_seeds.surql
-- | Module : system / reference
-- | Description : Seeds pour tous les codes d'erreur du module 'log'.
-- |
-- | Notes :
-- |   - Utilise la langue 'fr' par défaut
-- |   - Les severities sont : info, success, warning, error, critical
-- =============================================================================================
    LET $language_id=type::thing('i18n_language','fr');
    LET $info_id = type::thing('builder_error_severity','info');
    LET $success_id = type::thing('builder_error_severity','success');
    LET $warning_id = type::thing('builder_error_severity','warning');
    LET $error_id = type::thing('builder_error_severity','error');
    LET $critical_id = type::thing('builder_error_severity','critical');

    -- =============================================================================================
    -- | Create Logs
    -- =============================================================================================

    -- log.create.success
    LET $key_i18n_message = type::thing('i18n_key', 'log.create.success.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id SET text = 'Entrée de log créée avec succès';
    CREATE type::thing('error_code', 'log.create.success') SET
    severity = $success_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.create.failed
    LET $key_i18n_message = type::thing('i18n_key', 'log.create.failed.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Échec de la création de l''entrée de log';
    CREATE type::thing('error_code', 'log.create.failed') SET
    severity = $error_id, success_result = false, i18n = { message: $key_i18n_message };

    -- log.create.failed.config_not_found
    LET $key_i18n_message = type::thing('i18n_key', 'log.create.failed.config_not_found.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Échec de la création du log : configuration introuvable';
    CREATE type::thing('error_code', 'log.create.failed.config_not_found') SET
    severity = $critical_id, success_result = false, i18n = { message: $key_i18n_message };

    -- log.create.disabled
    LET $key_i18n_message = type::thing('i18n_key', 'log.create.disabled.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Le logging est désactivé, aucune entrée créée';
    CREATE type::thing('error_code', 'log.create.disabled') SET
    severity = $info_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.create.skipped.severity_too_low
    LET $key_i18n_message = type::thing('i18n_key', 'log.create.skipped.severity_too_low.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Log non créé : sévérité inférieure au seuil configuré';
    CREATE type::thing('error_code', 'log.create.skipped.severity_too_low') SET
    severity = $info_id, success_result = true, i18n = { message: $key_i18n_message };

    -- =============================================================================================
    -- | Maintenance Logs
    -- =============================================================================================

    -- log.maintenance.start
    LET $key_i18n_message = type::thing('i18n_key', 'log.maintenance.start.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Début de la maintenance planifiée des logs';
    CREATE type::thing('error_code', 'log.maintenance.start') SET
    severity = $info_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.maintenance.success
    LET $key_i18n_message = type::thing('i18n_key', 'log.maintenance.success.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Maintenance des logs terminée avec succès';
    CREATE type::thing('error_code', 'log.maintenance.success') SET
    severity = $success_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.maintenance.failed
    LET $key_i18n_message = type::thing('i18n_key', 'log.maintenance.failed.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Échec de la maintenance des logs';
    CREATE type::thing('error_code', 'log.maintenance.failed') SET
    severity = $error_id, success_result = false, i18n = { message: $key_i18n_message };

    -- =============================================================================================
    -- | Get Logs
    -- =============================================================================================

    -- log.get.list.success
    LET $key_i18n_message = type::thing('i18n_key', 'log.get.list.success.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Logs récupérés avec succès';
    CREATE type::thing('error_code', 'log.get.list.success') SET
    severity = $success_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.get.list.empty
    LET $key_i18n_message = type::thing('i18n_key', 'log.get.list.empty.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Aucun log trouvé pour les filtres fournis';
    CREATE type::thing('error_code', 'log.get.list.empty') SET
    severity = $info_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.get.id.success
    LET $key_i18n_message = type::thing('i18n_key', 'log.get.id.success.message');
    CREATE $key_i18n_message;
    RELATE $key_i18n_message->i18n_translation->$language_id SET text = 'Log récupéré avec succès';
    CREATE type::thing('error_code', 'log.get.id.success') SET
    severity = $success_id, success_result = true, i18n = { message: $key_i18n_message };

    -- log.get.id.not_found
    LET $key_i18n_message = type::thing('i18n_key', 'log.get.id.not_found.message');
   CREATE $key_i18n_message;
   RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Le log avec l\'ID spécifié n\'existe pas';
    CREATE type::thing('error_code', 'log.get.id.not_found') SET
    severity = $warning_id, success_result = false, i18n = { message: $key_i18n_message };