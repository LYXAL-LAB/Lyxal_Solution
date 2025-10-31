-- =============================================================================================
-- |
-- | Fichier : i18n_key_create.surql
-- | Module : i18n / i18n_key
-- | Description : Crée une clé i18n (échoue si la clé existe déjà).
-- |
-- | Paramètres :
-- |   - $name: string               (suffixe/id de la clé i18n)
-- |   - $description: option<string>
-- |   - $langue_id: string          (langue pour les messages de retour, obligatoire)
-- |   - $parent_run_id: option<string> (propagation du run parent)
-- |   - $user_id: option<string>       (utilisé pour le logging)
-- |
-- | Comportement :
-- |   - Vérifie l'unicité via fn::i18n_key_verify_unicity($name).
-- |   - Si libre, crée i18n_key avec id = type::thing('i18n_key', $name).
-- |   - Renseigne created_at/updated_at.
-- |   - Log via fn::builder_log_create_record.
-- |
-- | Retour : { success, reason_code, data, data_log }
-- |   - reason_code: 'i18n.key.created.success' | 'i18n.key.created.failed'
-- |   - data: { success, table:'i18n_key', reason_code, key, description,
-- |             resource_id, failed_step, failed_reason, parent_run_id, run_id }
-- |
-- | Fonctions utilisées :
-- |   - fn::i18n_key_verify_unicity
-- |   - fn::log_create_record
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_create(
  $value: string,
  $prefix: string,
  $suffix: string,
  $description: option<string>
  $parent_run_id: option<string>,
  $user_id: option<string>,
  $langue_id: option<string>
) {

  -- Paramètres pour la fonction
  LET $parent_run_id = IF $parent_run_id != NONE THEN $parent_run_id ELSE NONE END;
  LET $run_id = rand::uuid();
  LET $reason_code_failed = 'i18n.key.created.failed';
  LET $now = time::now();
  LET $resource_table = 'i18n_key';
  LET $resource_function_id = 'function_i18n_key_create';
  LET $before = {};

  -- STEP 1 : Génération de la clé i18n
  LET $key_generated = fn::i18n_key_generate($value, $prefix, $suffix);
  -- Vérification que la clé i18n a été générée avec succès
  -- Si ce n'est pas le cas, on retourne l'erreur
  IF $key_generated.success = false {
    LET $data_context = {
      value: $value,
      prefix: $prefix,
      suffix: $suffix,
      key_i18n: '',
      description: $description,
      failed_step: $key_generated.failed_step,
      failed_reason: $key_generated.failed_reason,
      parent_run_id: $parent_run_id,
      run_id: $run_id
    };
    -- Si la fonction n'est pas appelée par une autre fonction, on log et on retourne l'erreur
    IF $user_id != NONE {
      LET $log_result = fn::lib_return_error($reason_code_failed, $run_id, $resource_table, 
        $resource_function_id,$resource_id, $user_id, $langue_id, $data_context, $before, $target_table,
        $target_function_id,$target_id, $message_vars, $meta );
    };
    RETURN { success: false, reason_code: 'i18n.key.created.failed', failed_reason: 
    $key_generated.failed_reason, failed_step: $key_generated.failed_step, data: $key_generated.data };
  };
  LET $key = $key_generated.data.key_i18n;

  -- STEP 2 : Vérification que la clé i18n existe déjà
  LET $key_exists = fn::i18n_key_verify_unicity($key);
  -- Si la clé i18n existe, on retourne l'erreur
  IF $key_exists.success = false {
    RETURN { success: false, reason_code: 'i18n.key.created.failed', failed_reason: 
    $key_exists.reason_code, failed_step: $key_exists.failed_step, data: $key_exists.data };
  };

  -- STEP 3 : On crée la clé i18n
  LET $create_key_result = CREATE type::thing('i18n_key', $key) 
    SET  
    description = $description, 
    created_at = $now, 
    updated_at = $now;
  
  IF array::len($create_key_result) = 0 {
    LET $data_context = {
      value: $value,
      prefix: $prefix,
      suffix: $suffix,
      key_i18n: $key,
      description: $description,
      failed_step: 'create_i18n_key',
      failed_reason: 'i18n.key.create.failed',
      parent_run_id: $parent_run_id,
      run_id: $run_id
    };
    RETURN fn::lib_return_error( $reason_code_failed, $run_id, $resource_table, $resource_function_id,
      $resource_id, $user_id, $langue_id, $data_context, $before,$target_table, $target_function_id,
      $target_id, $message_vars, $meta );
  };
  
  LET $resource_id = $create_key_result[0].id;

  -- STEP 3: On construit le logging et le return pour le succès
  LET $reason_code_success = 'i18n.key.created.success';
  LET $success = true;
  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code_success,
    key: $key,
    description: $description,
    resource_id: $resource_id,
    failed_step: '',
    failed_reason: '',
    parent_run_id: $parent_run_id,
    run_id: $run_id,
  };

  LET $after = $data;
  
  -- STEP 4: LOGGING ET RETURN pour le succès
  LET $log_result = fn::log_create_record(
    $reason_code_success, $run_id, $resource_table, $resource_function_id,
    $resource_id, NONE, NONE, NONE, NONE, $user_id, {}, $data, $before, $after
  );

  RETURN { 
    success: $success, 
    reason_code: $reason_code_success,  
    data: $data, 
    data_log: $log_result.data 
  };
}
COMMENT 'Crée une clé i18n; échoue si la clé existe déjà.'
PERMISSIONS FULL;