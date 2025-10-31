-- =============================================================================================
-- |
-- | Fichier : builder_i18n_key_create.surql
-- | Module : builder / builder_i18n_key
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
-- |   - Vérifie l'unicité via fn::builder_i18n_key_verify_unicity($name).
-- |   - Si libre, crée builder_i18n_key avec id = type::thing('builder_i18n_key', $name).
-- |   - Renseigne created_at/updated_at.
-- |   - Log via fn::builder_log_create_record.
-- |
-- | Retour : { success, reason_code, data, data_log }
-- |   - reason_code: 'i18n.key.created.success' | 'i18n.key.created.failed'
-- |   - data: { success, table:'builder_i18n_key', reason_code, key, description,
-- |             resource_id, failed_step, failed_reason, parent_run_id, run_id }
-- |
-- | Fonctions utilisées :
-- |   - fn::builder_i18n_key_verify_unicity
-- |   - fn::builder_log_create_record
-- |   - fn::builder_lib_return_error
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_key_create(
  $name: string,
  $description: option<string>,
  $langue_id: string,
  $parent_run_id: option<string>,
  $user_id: option<string>
) {

  -- Paramètres par défaut
  LET $parent_run_id = IF $parent_run_id != NONE THEN $parent_run_id ELSE NONE END;
  LET $run_id = rand::uuid();
  LET $reason_code_failed = 'i18n.key.created.failed';
  LET $now = time::now();
  LET $resource_table = 'builder_i18n_key';
  LET $resource_function_id = 'function_builder_i18n_key_create';
  LET $before = {};

  -- STEP 1 : On vérifie l'unicité de la i18n_key
  LET $key_exists = fn::builder_i18n_key_verify_unicity($name);
  IF $key_exists.success = false {
    LET $data_context = {
      key: $name,
      description: $description,
      failed_step: 'builder_i18n_key_verify_unicity',
      failed_reason: $key_exists.reason_code,
      parent_run_id: $parent_run_id,
      run_id: $run_id
    };
    RETURN fn::builder_lib_return_error(
      $reason_code_failed, $run_id, $resource_table, $resource_function_id,
      NONE, $user_id, $langue_id, $data_context, $before,
      NONE, NONE, NONE, NONE, NONE
    );
  };

  -- STEP 2 : On crée la clé i18n
  LET $create_key_result = CREATE type::thing('builder_i18n_key', $name) 
    SET  
    description = $description, 
    created_at = $now, 
    updated_at = $now;
  
  IF array::len($create_key_result) = 0 {
    LET $data_context = {
      key: $name,
      description: $description,
      failed_step: 'create_i18n_key',
      failed_reason: 'create.failed',
      parent_run_id: $parent_run_id,
      run_id: $run_id
    };
    RETURN fn::builder_lib_return_error(
      $reason_code_failed, $run_id, $resource_table, $resource_function_id,
      NONE, $user_id, $langue_id, $data_context, $before,
      NONE, NONE, NONE, NONE, NONE
    );
  };
  
  LET $resource_id = $create_key_result[0].id;

  -- STEP 3: On construit le logging et le return pour le succès
  LET $reason_code_success = 'i18n.key.created.success';
  LET $success = true;
  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code_success,
    key: $name,
    description: $description,
    resource_id: $resource_id,
    failed_step: '',
    failed_reason: '',
    parent_run_id: $parent_run_id,
    run_id: $run_id,
  };

  LET $after = $data;
  
  -- STEP 4: LOGGING ET RETURN pour le succès
  LET $log_result = fn::builder_log_create_record(
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