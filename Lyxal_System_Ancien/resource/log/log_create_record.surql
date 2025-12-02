-- =============================================================================================
-- |
-- | Fichier : log_create_record.surql
-- | Module : system / log
-- | Description : Crée une entrée dans `log` en conformité avec le schéma objet, en
-- |               respectant les règles de configuration de l'application (activation,
-- |               niveau de sévérité, rétention).
-- |
-- | Paramètres :
-- |   - $result: object (contient `reason_key` lié à un `error_code` avec une `severity`)
-- |   - $operation: object
-- |   - $resource: option<object>
-- |   - $target: option<object>
-- |   - $message: option<object>
-- |   - $user_id: option<record<user>>
-- |   - $meta: option<object>
-- |   - $data: option<object>
-- |   - $before: option<object>
-- |   - $after: option<object>
-- |
-- | Comportement :
-- |   1. Récupère la configuration `system_configuration:default`.
-- |   2. Si le logging est désactivé, retourne un succès sans rien faire.
-- |   3. Compare la sévérité de l'événement (`$result.reason_key.severity.rank`) avec le
-- |      niveau minimum configuré (`$config.log_configuration.level.rank`).
-- |   4. Si la sévérité est trop basse, retourne un succès sans rien faire.
-- |   5. Calcule la date d'expiration en se basant sur `$config.log_configuration.hot_retention`.
-- |   6. Crée l'enregistrement de log.
-- |
-- | Retour :
-- |   - { success: true, reason_code: "log_create_record_success", data: { log_id, run_id } }
-- |   - { success: true, reason_code: "log_create_record_disabled", ... }
-- |   - { success: true, reason_code: "log_create_record_skipped_severity_too_low", ... }
-- |   - { success: false, reason_code: "log_create_record_failed", ... }
-- |   - { success: false, reason_code: "log_create_record_failed_config_not_found", ... }
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::log_create_record(
  $result: object,
  $operation: object,
  $resource: option<object>,
  $target: option<object>,
  $message: option<object>,
  $user_id: option<record<user>>,
  $meta: option<object>,
  $data: option<object>,
  $before: option<object>,
  $after: option<object>
) {
  -- Préparation du retour par défaut
  LET $return_data = { run_id: $operation.run_id };

  -- Étape 1: Récupérer la configuration du système
  LET $config = (SELECT * FROM system_configuration:default)[0];
  IF $config IS NONE {
    RETURN { success: false, reason_code: 'log_create_record_failed_config_not_found', data: $return_data };
  };

  -- Étape 2: Vérifier si le logging est activé
  IF $config.log_configuration.enabled = false {
    RETURN { success: true, reason_code: 'log_create_record_disabled', data: $return_data };
  };

  -- Étape 3: Comparer les niveaux de sévérité
  LET $event_severity_rank = (SELECT VALUE severity.rank FROM $result.reason_key)[0];
  LET $min_severity_rank = (SELECT VALUE rank FROM $config.log_configuration.level)[0];
  
  -- Si une des sévérités n'a pas pu être récupérée, on log par défaut (sécurité)
  IF $event_severity_rank IS NOT NONE AND $min_severity_rank IS NOT NONE {
    IF $event_severity_rank < $min_severity_rank {
      RETURN { success: true, reason_code: 'log_create_record_skipped_severity_too_low', data: $return_data };
    }
  };

  -- Étape 4: Calculer la date d'expiration et préparer les timestamps
  LET $now = time::now();
  -- Récupération de l'unité de temps (référence à time_unit)
  LET $retention_unit_record = $config.log_configuration.hot_retention.unit;
  IF $retention_unit_record IS NONE {
    RETURN { success: false, reason_code: 'log_create_record_failed_config_invalid', data: $return_data };
  };
  LET $retention_unit_value = $retention_unit_record.identity.value;
  LET $retention_value = $config.log_configuration.hot_retention.value;
  
  -- Calcul de la durée selon l'unité (syntaxe correcte : duration::from::* avec deux deux-points)
  LET $retention_duration = 
      IF $retention_unit_value = 'seconds' THEN duration::from::secs($retention_value)
      ELSE IF $retention_unit_value = 'minutes' THEN duration::from::mins($retention_value)
      ELSE IF $retention_unit_value = 'hours' THEN duration::from::hours($retention_value)
      ELSE IF $retention_unit_value = 'days' THEN duration::from::days($retention_value)
      ELSE IF $retention_unit_value = 'weeks' THEN duration::from::weeks($retention_value)
      ELSE IF $retention_unit_value = 'months' THEN duration::from::days($retention_value * 30)
      ELSE IF $retention_unit_value = 'years' THEN duration::from::days($retention_value * 365)
      ELSE duration::from::days(30)
  END;
  LET $expiration_date = $now + $retention_duration;
  
  -- Étape 5: Générer identity.code et identity.slug à partir du reason_key
  LET $reason_code = (SELECT VALUE identity.code FROM $result.reason_key)[0];
  LET $identity_code = IF $reason_code IS NOT NONE { 
    string::uppercase($reason_code) 
  } ELSE { 
    'LOG_' + string::uppercase(string::replace($operation.run_id, '-', '_')) 
  };
  LET $identity_slug = string::lowercase(string::replace(string::replace($identity_code, '_', '-'), '.', '-'));

  -- Étape 6: Création de l'entrée de log avec la nouvelle structure modulaire
  LET $created = CREATE log SET
    identity.code = $identity_code,
    identity.slug = $identity_slug,
    result = $result,
    operation = $operation,
    resource = $resource,
    target = $target,
    message = $message,
    content.user_id = $user_id,
    content.meta = $meta OR {} || { session_id: session::id() },
    content.data = $data OR {},
    content.before = $before,
    content.after = $after,
    status.is_active = true,
    status.is_archived = false,
    metadata.created_by = "system",
    metadata.source = "function",
    timestamp.created_at = $now,
    timestamp.expires_at = $expiration_date,
    timestamp.year = time::year($now),
    timestamp.week = time::week($now),
    timestamp.day = <string>$now.day
  ;

  -- Vérification du succès de la création
  IF array::len($created) > 0 {
    RETURN {
      success: true,
      reason_code: 'log_create_record_success',
      data: $return_data + { log_id: $created[0].id }
    };
  } ELSE {
    RETURN {
      success: false,
      reason_code: 'log_create_record_failed',
      data: $return_data
    };
  };
}
COMMENT 'Crée une entrée dans log en respectant la configuration (activation, sévérité, rétention).'
PERMISSIONS FULL;