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
-- |   1. Récupère la configuration `app_configuration:main`.
-- |   2. Si le logging est désactivé, retourne un succès sans rien faire.
-- |   3. Compare la sévérité de l'événement (`$result.reason_key.severity.rank`) avec le
-- |      niveau minimum configuré (`app_config.log_configuration.level.rank`).
-- |   4. Si la sévérité est trop basse, retourne un succès sans rien faire.
-- |   5. Calcule la date d'expiration en se basant sur `app_config.log_configuration.hot_retention`.
-- |   6. Crée l'enregistrement de log.
-- |
-- | Retour :
-- |   - { success: true, reason_code: "log.create.success", data: { log_id, run_id } }
-- |   - { success: true, reason_code: "log.create.disabled", ... }
-- |   - { success: true, reason_code: "log.create.skipped.severity_too_low", ... }
-- |   - { success: false, reason_code: "log.create.failed", ... }
-- |   - { success: false, reason_code: "log.create.failed.config_not_found", ... }
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

  -- Étape 1: Récupérer la configuration de l'application
  LET $config = (SELECT * FROM app_configuration:default)[0];
  IF $config IS NONE {
    RETURN { success: false, reason_code: 'log.create.failed.config_not_found', data: $return_data };
  };

  -- Étape 2: Vérifier si le logging est activé
  IF $config.log_configuration.enabled = false {
    RETURN { success: true, reason_code: 'log.create.disabled', data: $return_data };
  };

  -- Étape 3: Comparer les niveaux de sévérité
  LET $event_severity_rank = (SELECT VALUE severity.rank FROM $result.reason_key)[0];
  LET $min_severity_rank = (SELECT VALUE rank FROM $config.log_configuration.level)[0];
  
  -- Si une des sévérités n'a pas pu être récupérée, on log par défaut (sécurité)
  IF $event_severity_rank IS NOT NONE AND $min_severity_rank IS NOT NONE {
    IF $event_severity_rank < $min_severity_rank {
      RETURN { success: true, reason_code: 'log.create.skipped.severity_too_low', data: $return_data };
    }
  };

  -- Étape 4: Calculer la date d'expiration et l'objet log_date
  LET $now = time::now();
  LET $retention_unit = $config.log_configuration.hot_retention.unit;
  LET $retention_value = $config.log_configuration.hot_retention.value;
  LET $retention_duration = 
      IF $retention_unit = 'seconds' { <duration>::from_secs($retention_value) }
      ELSE IF $retention_unit = 'minutes' { <duration>::from_mins($retention_value) }
      ELSE IF $retention_unit = 'hours' { <duration>::from_hours($retention_value) }
      ELSE IF $retention_unit = 'days' { <duration>::from_days($retention_value) }
      ELSE IF $retention_unit = 'weeks' { <duration>::from_weeks($retention_value) }
      ELSE { <duration>::from_days(30) } -- Fallback de sécurité
  ;
  LET $expiration_date = $now + $retention_duration;
  
  LET $log_date = {
      timestamp: $now,
      year: time::year($now),
      week: time::week($now),
      day: <string>$now.day,
      expires_at: $expiration_date
  };

  -- Étape 5: Création de l'entrée de log
  LET $created = CREATE log SET
    result = $result,
    operation = $operation,
    resource = $resource,
    target = $target,
    message = $message,
    user_id = $user_id,
    meta = $meta OR {} || { session_id: session::id() },
    data = $data OR {},
    before = $before,
    after = $after,
    log_date = $log_date
  ;

  -- Vérification du succès de la création
  IF array::len($created) > 0 {
    RETURN {
      success: true,
      reason_code: 'log.create.success',
      data: object::extend($return_data, { log_id: $created[0].id })
    };
  } ELSE {
    RETURN {
      success: false,
      reason_code: 'log.create.failed',
      data: $return_data
    };
  };
}
COMMENT 'Crée une entrée dans log en respectant la configuration (activation, sévérité, rétention).'
PERMISSIONS FULL;