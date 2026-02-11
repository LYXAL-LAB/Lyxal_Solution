-- =============================================================================================
-- |
-- | Fichier : i18n_key_delete_record.surql
-- | Module : i18n / i18n_key
-- | Description : Supprime une clé i18n et toutes ses traductions, en transaction.
-- |
-- | Paramètres :
-- |   - $key: string                 (suffixe/id de la clé i18n)
-- |   - $langue_id: string           (pour traduire le message de retour, obligatoire)
-- |   - $parent_run_id: option<string>
-- |   - $user_id: option<string>
-- |
-- | Comportement :
-- |   - Vérifie l'utilisateur si fourni, puis l'existence de la clé.
-- |   - BEGIN: supprime d'abord toutes les traductions (edges in/out), puis la clé.
-- |   - COMMIT si succès; CANCEL si échec (rétablit les suppressions partielles).
-- |   - Log via fn::log_create_record.
-- |   - Message i18n via fn::error_get_by_id + fn::i18n_translation_get.
-- |
-- | Retour : { success, reason_code, message, data, data_log }
-- |   - reason_code: 'i18n.key.delete.success' | 'i18n.key.delete.failed'
-- |   - data: { success, table, reason_code, key, resource_id, failed_step, failed_reason,
-- |             parent_run_id, run_id }
-- |
-- | Fonctions utilisées :
-- |   - fn::user_verify_id
-- |   - fn::i18n_key_get_by_id
-- |   - fn::log_create_record
-- |   - fn::error_helper_return_error
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_delete_record(
  $key: string,
  $langue_id: option<string>,
  $parent_run_id: option<string>,
  $user_id: option<string>
) {
  LET $parent_run_id = IF $parent_run_id != NONE THEN $parent_run_id ELSE NONE END;
  LET $langue_id = IF $langue_id != NONE THEN $langue_id ELSE NONE END;
  LET $user_id = IF $user_id != NONE THEN $user_id ELSE NONE END;
  LET $run_id = rand::uuid();
  LET $reason_code_success = 'i18n.key.deleted.success';
  LET $reason_code_failed = 'i18n.key.deleted.failed';
  LET $resource_table = 'i18n_key';
  LET $resource_function_id = 'function_i18n_key_delete_record';
  LET $resource_id = type::thing($resource_table, $key);
  LET $before = {};

  -- STEP 1: VERIFICATION DE L'UTILISATEUR (plus tard permissions)
  IF $user_id != NONE {
    LET $user_result = fn::user_verify_id($user_id);
    IF $user_result.success = false {
      LET $data_context = {
        key: $key,
        failed_step: 'user_id_verify',
        failed_reason: $user_result.reason_code,
        user_id: $user_id,
        parent_run_id: $parent_run_id,
        run_id: $run_id
      };
      IF $parent_run_id = NONE {
        fn::lib_return_error($success,$reason_code_failed, $run_id, $resource_table,$resource_function_id, 
        $resource_id, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE)
      };
      RETURN fn::lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, $resource_id, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE, NONE);
    };
  };
  
  -- STEP 2 : On vérifie que la clé i18n existe
  LET $key_rec = fn::i18n_key_get_by_id($key);
  IF $key_rec.success = false {
    LET $data_context = {
      key: $key,
      failed_step: 'i18n_key_get_by_id',
      failed_reason: $key_rec.reason_code,
      run_id: $run_id
    };
    RETURN fn::error_helper_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, $resource_id, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
  };
  LET $before = $key_rec.data;

  -- STEP 3 : On supprime la clé i18n (via helper edges puis clé)
  LET $edge_ids = SELECT VALUE id FROM i18n_translation WHERE in = $resource_id;
  
  -- Si des traductions existent, on les supprime en premier dans une transaction.
  IF array::len($edge_ids) > 0 {
    BEGIN;
    LET $del_edges = fn::i18n_translation_delete_edges($edge_ids, $langue_id, $user_id, 
    $run_id, true);
    IF $del_edges.success = false {
      CANCEL;
      LET $data_context = {
        key: $key,
        failed_step: 'delete_edges',
        failed_reason: $del_edges.reason_code,
        run_id: $run_id
      };
      RETURN fn::error_helper_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, $resource_id, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
    };
    
    LET $delete_key_result = DELETE $resource_id;
    IF array::len($delete_key_result) = 0 {
      CANCEL;
      LET $data_context = {
        key: $key,
        failed_step: 'delete_key_with_edges',
        failed_reason: 'delete.failed',
        run_id: $run_id
      };
      RETURN fn::error_helper_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, $resource_id, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
    };
    COMMIT;
  } 
  -- S'il n'y a pas de traductions, on supprime directement la clé.
  ELSE {
    LET $delete_key_result = DELETE $resource_id;
    IF array::len($delete_key_result) = 0 {
      LET $data_context = {
        key: $key,
        failed_step: 'delete_key_without_edges',
        failed_reason: 'delete.failed',
        run_id: $run_id
      };
       RETURN fn::error_helper_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, $resource_id, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
    };
  };

  -- STEP 4 : On construit le logging et le return pour le succès
  LET $reason_code_success = 'i18n.key.delete.success';
  LET $success = true;

  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code_success,
    key: $key,
    resource_id: $resource_id,
    failed_step: '',
    failed_reason: '',
    parent_run_id: $parent_run_id,
    run_id: $run_id,
  };

  LET $after = $data;

  -- STEP 5 : On log le résultat
  LET $log_result = fn::log_create_record(
    $reason_code_success, $run_id, $resource_table, $resource_function_id, 
    $resource_id, NONE, NONE, NONE, NONE, $user_id, {}, $data, $before, $after
  );

  -- STEP 6 : On retourne le retour standard
  RETURN { 
    success: $success, 
    reason_code: $reason_code_success,  
    data: $data, 
    data_log: $log_result.data 
  };
}
COMMENT 'Supprime une clé i18n et ses traductions associées.'
PERMISSIONS FULL;