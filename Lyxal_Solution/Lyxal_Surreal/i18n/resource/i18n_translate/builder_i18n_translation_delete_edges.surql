-- =============================================================================================
-- |
-- | Fichier : builder_i18n_translation_delete_edges.surql
-- | Module : builder / translate
-- | Description : Supprime une ou plusieurs traductions i18n (edges) via leurs IDs, en transaction.
-- |
-- | Paramètres :
-- |   - $edge_ids: array<string>     (liste des IDs record des edges à supprimer)
-- |   - $langue_id: option<string>   (langue pour message i18n; optionnel)
-- |   - $user_id: option<string>
-- |   - $parent_run_id: option<string>
-- |   - $use_parent_tx: option<bool> (si true, n'ouvre pas de transaction interne)
-- |
-- | Comportement :
-- |   - Vérifie l'utilisateur si fourni.
-- |   - Pré-valide la liste (non vide). Capture l'état avant (count existants).
-- |   - BEGIN; DELETE builder_i18n_translation WHERE id IN $edge_ids; COMMIT si tout supprimé,
-- |     sinon CANCEL et échec agrégé.
-- |   - Log via fn::builder_log_create_record.
-- |   - Message i18n via fn::builder_error_get_by_code + fn::builder_i18n_translation_get (si langue).
-- |
-- | Retour : { success, reason_code, message, data, data_log }
-- |   - reason_code: 'i18n.translation.deleted.success' | 'i18n.translation.deleted.failed'
-- |   - data: { success, table:'builder_i18n_translation', reason_code,
-- |             requested_count, existing_count, deleted_count,
-- |             failed_step, failed_reason, parent_run_id, run_id }
-- |
-- | Fonctions utilisées :
-- |   - fn::builder_user_verify_id
-- |   - fn::builder_log_create_record
-- |   - fn::builder_error_get_by_code
-- |   - fn::builder_i18n_translation_get
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_translation_delete_edges(
  $edge_ids: array<string>,
  $langue_id: option<string>,
  $user_id: option<string>,
  $parent_run_id: option<string>,
  $use_parent_tx: option<bool>
) {

  -- Paramètres par défaut
  LET $parent_run_id = IF $parent_run_id != NONE THEN $parent_run_id ELSE NONE END;
  LET $run_id = rand::uuid();
  LET $step_valid = true;
  LET $failed_step = '';
  LET $failed_reason = '';
  LET $reason_code_success = 'i18n.translation.deleted.success';
  LET $reason_code_failed = 'i18n.translation.deleted.failed';

  -- Retour standard et logging
  LET $success = true;
  LET $reason_code = '';
  LET $resource_table = 'builder_i18n_translation';
  LET $resource_function_id = 'function_builder_i18n_translation_delete_edges';
  LET $resource_id = NONE;
  LET $target_table = NONE;
  LET $target_function_id = NONE;
  LET $target_id = NONE;
  LET $message_vars = NONE;
  LET $meta = {};
  LET $before = {};
  LET $after = {};
  LET $message = '';
  LET $data = {};

  -- STEP 0 : Vérification utilisateur (optionnelle)
  IF $step_valid = true {
    LET $user_rec = fn::builder_user_verify_id($user_id);
    IF $user_rec.success = false {
      LET $step_valid = false;
      LET $success = false;
      LET $failed_step = 'builder_user_verify_id';
      LET $failed_reason = $user_rec.reason_code;
    };
  };

  -- STEP 1 : Pré-validation des IDs
  IF $step_valid = true {
    LET $requested_count = array::len($edge_ids);
    IF $requested_count = 0 {
      LET $step_valid = false;
      LET $success = false;
      LET $failed_step = 'validate_edge_ids';
      LET $failed_reason = 'EDGES.EMPTY';
    };
  };

  -- STEP 2 : État avant suppression
  IF $step_valid = true {
    LET $existing_before = SELECT id FROM builder_i18n_translation WHERE id IN $edge_ids;
    LET $existing_count = array::len($existing_before);
    LET $before = {
      requested_count: array::len($edge_ids),
      existing_count: $existing_count
    };
  };

  -- STEP 3 : Suppression transactionnelle (parent ou interne)
  IF $step_valid = true {
    IF $use_parent_tx = true {
      LET $deleted_edges = DELETE builder_i18n_translation WHERE id IN $edge_ids;
      LET $deleted_count = array::len($deleted_edges);
      IF $deleted_count < $existing_count {
        LET $step_valid = false;
        LET $success = false;
        LET $failed_step = 'delete_edges';
        LET $failed_reason = 'DELETE.PARTIAL';
      };
    }
    ELSE {
      BEGIN;
      LET $deleted_edges = DELETE builder_i18n_translation WHERE id IN $edge_ids;
      LET $deleted_count = array::len($deleted_edges);
      IF $deleted_count < $existing_count {
        CANCEL;
        LET $step_valid = false;
        LET $success = false;
        LET $failed_step = 'delete_edges';
        LET $failed_reason = 'DELETE.PARTIAL';
      }
      ELSE {
        COMMIT;
      };
    };
  };

  -- STEP 4 : Construction du retour et logging
  IF $success = true { LET $reason_code = $reason_code_success; }
  ELSE { LET $reason_code = $reason_code_failed; };

  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code,
    requested_count: IF $edge_ids != NONE THEN array::len($edge_ids) ELSE 0 END,
    existing_count: IF $before != {} THEN $before.existing_count ELSE 0 END,
    deleted_count: IF $success = true THEN $deleted_count ELSE 0 END,
    failed_step: $failed_step,
    failed_reason: $failed_reason,
    parent_run_id: $parent_run_id,
    run_id: $run_id
  };

  LET $after = $data;

  LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table,
    $resource_function_id, $resource_id, $target_table, $target_function_id,
    $target_id, $message_vars, $user_id, $meta, $data, $before, $after);

  IF $langue_id != NONE {
    LET $error_key = fn::builder_error_get_by_code($reason_code);
    LET $error_translation = fn::builder_i18n_translation_get($error_key.data.message_key, $langue_id);
    LET $message = $error_translation.message;
  };

  RETURN {
    success: $success,
    reason_code: $reason_code,
    message: $message,
    data: $data,
    data_log: $log_result.data
  };
}
COMMENT 'Supprime des edges de traduction i18n par tableau d\'IDs, transactionnel.'
PERMISSIONS FULL;