-- =============================================================================================
-- |
-- | Fichier : builder_i18n_translation_update_text.surql
-- | Module : builder / translate
-- | Description : Met à jour uniquement le champ `text` d'une traduction i18n (edge),
-- |               en respectant la méthodologie standard (step_valid, agrégation, logging).
-- |
-- | Paramètres :
-- |   - $edge_id: string            (suffixe/id de l'edge builder_i18n_translation)
-- |   - $text: string               (nouvelle valeur; doit être non vide après trim)
-- |   - $etag: int                  (contrôle optimiste; doit correspondre à l'etag courant)
-- |   - $langue_id: option<string>  (langue pour message i18n)
-- |   - $user_id: option<string>
-- |   - $parent_run_id: option<string>
-- |
-- | Comportement :
-- |   - Vérifie l'utilisateur si fourni.
-- |   - Vérifie que le texte est non vide (trim > 0).
-- |   - Charge l'edge (before). UPDATE text et etag (+1) en transaction. Charge after.
-- |   - Log via fn::builder_log_create_record.
-- |   - Message i18n via fn::builder_error_get_by_code + fn::builder_i18n_translation_get.
-- |
-- | Retour : { success, reason_code, message, data, data_log }
-- |   - reason_code: 'I18N_TRANSLATION_UPDATED' | 'I18N_TRANSLATION_UPDATE_FAILED'
-- |   - data: { success, table:'builder_i18n_translation', reason_code,
-- |             edge_id, before, after, failed_step, failed_reason, run_id }
-- |
-- | Fonctions utilisées :
-- |   - fn::builder_user_verify_id
-- |   - fn::builder_log_create_record
-- |   - fn::builder_error_get_by_code
-- |   - fn::builder_i18n_translation_get
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_translation_update_text(
  $edge_id: string,
  $text: string,
  $etag: int,
  $langue_id: option<string>,
  $user_id: option<string>,
  $parent_run_id: option<string>
) {

  -- Paramètres par défaut
  LET $parent_run_id = IF $parent_run_id != NONE THEN $parent_run_id ELSE NONE END;
  LET $run_id = rand::uuid();
  LET $failed_step = '';
  LET $failed_reason = '';
  LET $reason_code_success = 'i18n.translation.updated.success';
  LET $reason_code_failed = 'i18n.translation.updated.failed';
  LET $resource_table = 'builder_i18n_translation';
  LET $resource_function_id = 'function_builder_i18n_translation_update_text';
  LET $resource_id = $edge_id;
  LET $target_table = NONE;
  LET $target_function_id = NONE;
  LET $target_id = NONE;
  LET $message_vars = NONE;
  LET $meta = {};
  LET $before = {};

  -- STEP 1 : On vérifie l'unicité de la i18n_key dans la langue
  LET $key_exists = fn::builder_i18n_key_verify_unicity($name);
    IF $key_exists.success = false {
      LET $success = false;
      LET $failed_step = 'builder_i18n_key_verify_unicity';
      LET $failed_reason = $key_exists.reason_code;
      LET $reason_code = $reason_code_failed;
      LET $data = {
        success: $success,
        table: $resource_table,
        reason_code: $reason_code,
        key: $name,
        description: $description,
        resource_id: $resource_id,
        failed_step: $failed_step,
        failed_reason: $failed_reason,
        parent_run_id: $parent_run_id,
        run_id: $run_id,
      };
      LET $after = $data;
      -- LOGGING ET MESSAGE I18N
      LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
      $resource_function_id, $resource_id, $target_table, $target_function_id,
      $target_id, $message_vars, $user_id, $meta, $data, $before, $after);
      LET $error_key = fn::builder_i18n_key_get_by_id($reason_code);     
      LET $msg_key_str = string::split(type::string($error_key.data.message_key), ':')[1];
      LET $error_translation = fn::builder_i18n_translation_get($msg_key_str, $langue_id);
      LET $message = $error_translation.message;
      -- RETURN
      RETURN {
        success: $success,
        message: $message,
        reason_code: $reason_code,
        data: $data,
        data_log: $log_result.data
      };
    };

  -- STEP 2: VERIFICATION DE LA LANGUE
  LET $langue_result = fn::builder_i18n_language_verify_id_active($langue_id, true);
  IF $langue_result.success = false {
    LET $success = false;
    LET $failed_step = 'langue_verify';
    LET $failed_reason = $langue_result.reason_code;
    LET $reason_code = $reason_code_failed ;
    LET $data = {
      success: $success,
      table: $resource_table,
      reason_code: $reason_code,
      key: $key,
      language: $language,
      text: $text,
      failed_step: $failed_step,
      failed_reason: $failed_reason,
      run_id: $run_id
    };
    LET $after = $data;
    --  LOGGING ET MESSAGE I18N
    LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
    $resource_function_id, $resource_id, $target_table, $target_function_id,
    $target_id, $message_vars, $user_id, $meta, $data, $before, $after);
    LET $error_key = fn::builder_error_get_by_code($reason_code);
    LET $msg_key_str = string::split(type::string($error_key.data.message_key), ':')[1];
    LET $error_translation = fn::builder_i18n_translation_get($msg_key_str, $langue_id);
    LET $message = $error_translation.message;
    --  RETURN
    RETURN {
      success: $success,
      reason_code: $reason_code,
      data: $data,
      data_log: $log_result.data
    };
  };

  -- STEP 3 : Validation du texte (non vide)
  LET $trimmed = string::trim($text);
  IF string::len($trimmed) = 0 {
    LET $step_valid = false;
    LET $success = false;
    LET $failed_step = 'validate_text_non_empty';
    LET $failed_reason = 'i18n.translation.text.empty';
  };

  -- STEP 3 : Chargement de l'edge (before)
  LET $edge_ref = type::thing('builder_i18n_translation', $edge_id);
  LET $current = SELECT * FROM builder_i18n_translation WHERE id = $edge_ref LIMIT 1;
  IF array::len($current) = 0 {
    LET $success = false;
    LET $failed_step = 'load_edge';
    LET $failed_reason = 'i18n.translation.not.found';
    LET $reason_code = $reason_code_failed;
    LET $data = {
      success: $success,
      table: $resource_table,
      reason_code: $reason_code,
      edge_id: $edge_id,
      failed_step: $failed_step,
      failed_reason: $failed_reason,
      run_id: $run_id
    };
    LET $after = $data;
    -- LOGGING ET MESSAGE I18N
    LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
    $resource_function_id, $resource_id, $target_table, $target_function_id,
    $target_id, $message_vars, $user_id, $meta, $data, $before, $after);
    LET $error_key = fn::builder_error_get_by_code($reason_code);
    LET $msg_key_str = string::split(type::string($error_key.data.message_key), ':')[1];
    LET $error_translation = fn::builder_i18n_translation_get($msg_key_str, $langue_id);
    LET $message = $error_translation.message;
    RETURN {
      success: $success,
      reason_code: $reason_code,
      message: $message,
      data: $data,
      data_log: $log_result.data
    };    
  };
  LET $before = $current[0];

  -- STEP 2b : Vérification de l'etag (contrôle optimiste)
  IF $etag != $before.etag {
    LET $success = false;
    LET $failed_step = 'etag_check';
    LET $failed_reason = 'i18n.translation.etag.mismatch';
    LET $reason_code = $reason_code_failed;
    LET $data = {
      success: $success,
      table: $resource_table,
      reason_code: $reason_code,
      edge_id: $edge_id,
      failed_step: $failed_step,
      failed_reason: $failed_reason,
      run_id: $run_id
    };
    LET $after = $data;
    -- LOGGING ET MESSAGE I18N
    LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
    $resource_function_id, $resource_id, $target_table, $target_function_id,
    $target_id, $message_vars, $user_id, $meta, $data, $before, $after);
    LET $error_key = fn::builder_error_get_by_code($reason_code);
    LET $msg_key_str = string::split(type::string($error_key.data.message_key), ':')[1];
    LET $error_translation = fn::builder_i18n_translation_get($msg_key_str, $langue_id);
    LET $message = $error_translation.message;
    RETURN {
      success: $success,
      reason_code: $reason_code,
      message: $message,
      data: $data,
      data_log: $log_result.data
    };
  };

  -- STEP 3 : UPDATE transactionnel du text (+ etag)
  BEGIN;
  LET $updated = UPDATE builder_i18n_translation SET
    text = $trimmed,
    etag = IF etag != NONE THEN etag + 1 ELSE 1 END
    WHERE id = $edge_ref AND etag = $etag;
  IF array::len($updated) = 0 {
    CANCEL;
    LET $success = false;
    LET $failed_step = 'update_text';
    LET $failed_reason = $reason_code_failed;
    LET $reason_code = $reason_code_failed;
    LET $data = {
      success: $success,
      table: $resource_table,
      reason_code: $reason_code,
      edge_id: $edge_id,
      failed_step: $failed_step,
      failed_reason: $failed_reason,
      run_id: $run_id
    };
    LET $after = $data;
    -- LOGGING ET MESSAGE I18N
    LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
    $resource_function_id, $resource_id, $target_table, $target_function_id,
    $target_id, $message_vars, $user_id, $meta, $data, $before, $after);
    LET $error_key = fn::builder_error_get_by_code($reason_code);
    LET $msg_key_str = string::split(type::string($error_key.data.message_key), ':')[1];
    LET $error_translation = fn::builder_i18n_translation_get($msg_key_str, $langue_id);
    LET $message = $error_translation.message;
    -- RETURN
    RETURN {
      success: $success,
      message: $message,
      reason_code: $reason_code,
      data: $data,
      data_log: $log_result.data
    };
  };
  COMMIT;

  -- STEP 4 : Raison, data et logging
  LET $success = true;
  LET $reason_code = $reason_code_success;
  LET $after = $updated[0];

  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code,
    edge_id: $edge_id,
    before: $before,
    after: $after,
    failed_step: $failed_step,
    failed_reason: $failed_reason,
    parent_run_id: $parent_run_id,
    run_id: $run_id
  };

  LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
    $resource_function_id, $resource_id, $target_table, $target_function_id,
    $target_id, $message_vars, $user_id, $meta, $data, $before, $after);
  LET $error_key = fn::builder_error_get_by_code($reason_code);
  LET $msg_key_str = string::split(type::string($error_key.data.message_key), ':')[1];
  LET $error_translation = fn::builder_i18n_translation_get($msg_key_str, $langue_id);
  LET $message = $error_translation.message;

  RETURN {
    success: $success,
    reason_code: $reason_code,
    message: $message,
    data: $data,
    data_log: $log_result.data
  };
}
COMMENT 'Met à jour uniquement text sur builder_i18n_translation (edge), transactionnel.'
PERMISSIONS FULL;