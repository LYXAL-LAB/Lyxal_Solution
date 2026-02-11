-- =============================================================================================
-- |
-- | Fichier : builder_i18n_translation_create.surql
-- | Module : builder / translate
-- | Description : Crée une traduction i18n (clé -> langue) via RELATE (edge in/out).
-- | Paramètres :
-- |   - $key: string           (suffixe de la clé i18n)
-- |   - $language: string      (suffixe de la langue)
-- |   - $text: string          (texte de la traduction)
-- |   - $langue_id: string      (langue pour les messages de retour, obligatoire)
-- |   - $user_id: option<string>
-- |   - $parent_run_id: option<string>
-- |
-- | Comportement :
-- |   - Vérifie l'utilisateur si fourni.
-- |   - Récupère la clé i18n (doit exister) et son RID.
-- |   - Vérifie la langue (existence) et récupère son RID (sans imposer is_active).
-- |   - Vérifie l'unicité (in/out) sur `builder_i18n_translation`.
-- |   - Si absente, RELATE $key_id -> builder_i18n_translation -> $language_id avec text.
-- |   - Log standard via `fn::builder_log_create_record`.
-- |
-- | Retour : { success, reason_code, message, data, data_log }
-- |   - reason_code: 'i18n.translation.created.success' | 'i18n.translation.created.failed'
-- |
-- | Fonctions utilisées :
-- |   - fn::builder_user_verify_id
-- |   - fn::builder_i18n_key_get_by_code
-- |   - fn::builder_i18n_language_verify_id_active
-- |   - fn::builder_log_create_record
-- |   - fn::builder_lib_return_error
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_translation_create(
  $key: string,
  $language: string,
  $text: string,
  $langue_id: string,
  $user_id: option<string>,
  $parent_run_id: option<string>
) {

  -- Paramètres de la fonction
  LET $run_id = rand::uuid();
  LET $reason_code_failed = 'i18n.translation.created.failed';
  
  -- on construit le retour par défaut
  LET $resource_table = 'builder_i18n_translation';
  LET $resource_function_id = 'function_builder_i18n_translation_create';
  LET $before = {};

  -- STEP 1: VERIFICATION DE L'UTILISATEUR (plus tard permissions)
  IF $user_id != NONE {
    LET $user_result = fn::builder_user_verify_id($user_id);
    IF $user_result.success = false {
      LET $data_context = {
        key: $key, language: $language, text: $text,
        failed_step: 'user_id_verify',
        failed_reason: $user_result.reason_code,
        run_id: $run_id
      };
      RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
    };
  };

  -- STEP 2: VERIFICATION DE LA LANGUE
  LET $langue_result = fn::builder_i18n_language_verify_id_active($language, false);
  IF $langue_result.success = false {
    LET $data_context = {
      key: $key, language: $language, text: $text,
      failed_step: 'language_verify',
      failed_reason: $langue_result.reason_code,
      run_id: $run_id
    };
    RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
  };
  LET $language_id = $langue_result.data.data.id;

  -- STEP 3 : On vérifie que la clé existe
  LET $key_rec = fn::builder_i18n_key_get_by_code($key);
  IF $key_rec.success = false {
    LET $data_context = {
      key: $key, language: $language, text: $text,
      failed_step: 'builder_i18n_key_get_by_code',
      failed_reason: $key_rec.reason_code,
      run_id: $run_id
    };
    RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
  };
  LET $key_id = $key_rec.data.data.id;
 
  -- STEP 4 : On vérifie que la traduction n'existe pas déjà
  LET $existing = SELECT * FROM builder_i18n_translation WHERE in = $key_id AND out = $language_id LIMIT 1;
  IF array::len($existing) > 0 {
    LET $data_context = {
      key: $key, language: $language, text: $text,
      failed_step: 'check_existing_translation',
      failed_reason: 'i18n.translation.already.exists',
      run_id: $run_id
    };
    RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
  };

  -- STEP 5 : On crée la traduction
  LET $translation = RELATE $key_id->builder_i18n_translation->$language_id SET text = $text;
  IF array::len($translation) = 0 {
    LET $data_context = {
      key: $key, language: $language, text: $text,
      failed_step: 'create_translation_relate',
      failed_reason: 'relate.failed',
      run_id: $run_id
    };
    RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
  };
  LET $resource_id = $translation[0].id;

  -- STEP 6 : On construit le return et le logging pour le succès
  LET $reason_code_success = 'i18n.translation.created.success';
  LET $success = true;

  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code_success,
    key: $key,
    language: $language,
    text: $text,
    failed_step: '',
    failed_reason: '',
    run_id: $run_id
  };

  LET $after = $data;

  -- STEP 7 : On log le résultat
  LET $log_result = fn::builder_log_create_record(
    $reason_code_success, $run_id, $resource_table, $resource_function_id, 
    $resource_id, NONE, NONE, NONE, NONE, $user_id, {}, $data, $before, $after
  );

  -- STEP 8 : On retourne le retour standard
  RETURN { 
    success: $success, 
    reason_code: $reason_code_success,
    data: $data,
    data_log: $log_result.data
  };
}
COMMENT 'Crée une traduction i18n via relation (échoue si déjà existante).'
PERMISSIONS FULL;