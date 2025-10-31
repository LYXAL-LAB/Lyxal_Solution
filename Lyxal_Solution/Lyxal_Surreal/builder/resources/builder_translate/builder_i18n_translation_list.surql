-- =============================================================================================
-- |
-- | Fichier : builder_i18n_translation_list.surql
-- | Module : builder / translate
-- | Description : Liste les traductions i18n avec filtres, tri et pagination natifs.
-- |               Optimisé pour la performance en utilisant WHERE, ORDER BY, LIMIT/START.
-- |               Enrichit les résultats en retournant les données des `key` et `language` liés.
-- |
-- | Paramètres :
-- |   - $key: option<string>           (ID de la clé i18n, ex: 'severity.info.label')
-- |   - $language: option<string>      (ID de la langue, ex: 'fr')
-- |   - $text_contains: option<string> (filtre sur le texte de la traduction)
-- |   - $sort_order: option<string>    ('asc' | 'desc', défaut 'asc')
-- |   - $offset: option<int>           (défaut 0)
-- |   - $limit: option<int>            (défaut 1000)
-- |   - $langue_id: string             (langue pour les messages d'erreur de la fonction)
-- |   - $user_id: option<string>       (ID de l'utilisateur pour le logging)
-- |   - $parent_run_id: option<string> (ID de l'exécution parente pour le logging)
-- |
-- | Comportement :
-- |   - Utilise une requête COUNT() pour obtenir le total, puis une requête SELECT avec
-- |     LIMIT/START pour ne récupérer que la page de données nécessaire.
-- |   - Si la liste est vide, retourne `success:false` avec un message traduit.
-- |   - Chaque item retourné inclut `key` et `language` en plus des champs de la traduction.
-- |
-- | Retour : { success, reason_code, message, data, data_log }
-- |   - reason_code: 'i18n.translation.list.success' | 'i18n.translation.list.failed'
-- |
-- | Fonctions utilisées :
-- |   - fn::builder_user_verify_id
-- |   - fn::builder_log_create_record
-- |   - fn::builder_lib_return_error
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_translation_list(
  $key: option<string>,
  $language: option<string>,
  $text_contains: option<string>,
  $sort_order: option<string>,
  $offset: option<int>,
  $limit: option<int>,
  $langue_id: string,
  $user_id: option<string>,
  $parent_run_id: option<string>
) {

  -- Paramètres par défaut
  LET $run_id = rand::uuid();
  LET $reason_code_failed = 'i18n.translation.list.failed';
  LET $resource_table = 'builder_i18n_translation';
  LET $resource_function_id = 'function_builder_i18n_translation_list';
  LET $before = {};

  -- STEP 1: VERIFICATION DE L'UTILISATEUR (plus tard permissions)
  IF $user_id != NONE {
    LET $user_result = fn::builder_user_verify_id($user_id);
    IF $user_result.success = false {
      LET $data_context = {
          filters: { key: $key, language: $language, text_contains: $text_contains },
          langue_id: $langue_id, user_id: $user_id, run_id: $run_id,
          failed_step: 'user_id_verify',
          failed_reason: $user_result.reason_code
      };
      RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
        $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
        NONE, NONE, NONE, NONE, NONE);
    };
  };

  -- STEP 2: VERIFICATION DE LA LANGUE POUR LES MESSAGES
  LET $langue_result = fn::builder_i18n_language_verify_id_active($langue_id, true);
  IF $langue_result.success = false {
    LET $data_context = {
      filters: { key: $key, language: $language, text_contains: $text_contains },
      langue_id: $langue_id, user_id: $user_id, run_id: $run_id,
      failed_step: 'langue_verify',
      failed_reason: $langue_result.reason_code
    };
    RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
    $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
    NONE, NONE, NONE, NONE, NONE);
  };

  -- STEP 3 : LOGIQUE DE RECUPERATION NATIVE (PERFORMANTE)
  LET $key_ref = IF $key != NONE THEN type::thing('builder_i18n_key', $key) ELSE NONE END;
  LET $lang_ref = IF $language != NONE THEN type::thing('i18n_language', $language) ELSE NONE END;
  LET $sort_norm = IF $sort_order = 'desc' THEN 'desc' ELSE 'asc' END;
  LET $use_offset = $offset OR 0;
  LET $use_limit = $limit OR 1000;

  LET $total = (
    SELECT count() FROM builder_i18n_translation 
    WHERE
      ($key_ref = NONE OR in = $key_ref) AND
      ($lang_ref = NONE OR out = $lang_ref) AND
      ($text_contains = NONE OR string::contains(string::lowercase(text), string::lowercase($text_contains)))
    GROUP ALL
  )[0].count OR 0;

  IF $total = 0 {
    LET $data_context = {
      filters: { key: $key, language: $language, text_contains: $text_contains },
      total: 0, offset: $use_offset, limit: $use_limit, count: 0, items: [],
      run_id: $run_id,
      failed_step: 'get_list',
      failed_reason: 'i18n.translation.list.empty'
    };
    RETURN fn::builder_lib_return_error($reason_code_failed, $run_id, $resource_table,
    $resource_function_id, NONE, $user_id, $langue_id, $data_context, $before,
    NONE, NONE, NONE, NONE, NONE);
  };

  LET $items = (
    IF $sort_order = 'desc' THEN (
      SELECT 
        id, text,
        in AS key_record, in.key AS key,
        out AS language_record, string::split(type::string(out), ':')[1] AS language
      FROM builder_i18n_translation 
      WHERE
        ($key_ref = NONE OR in = $key_ref) AND
        ($lang_ref = NONE OR out = $lang_ref) AND
        ($text_contains = NONE OR string::contains(string::lowercase(text), string::lowercase($text_contains)))
      ORDER BY text DESC, id DESC
      START $use_offset LIMIT $use_limit
    ) ELSE (
      SELECT 
        id, text,
        in AS key_record, in.key AS key,
        out AS language_record, string::split(type::string(out), ':')[1] AS language
      FROM builder_i18n_translation 
      WHERE
        ($key_ref = NONE OR in = $key_ref) AND
        ($lang_ref = NONE OR out = $lang_ref) AND
        ($text_contains = NONE OR string::contains(string::lowercase(text), string::lowercase($text_contains)))
      ORDER BY text ASC, id ASC
      START $use_offset LIMIT $use_limit
    ) END
  );

  -- STEP 4 : FORMATAGE DE LA REPONSE DE SUCCES
  LET $reason_code_success = 'i18n.translation.list.success';
  LET $data = {
    success: true,
    table: $resource_table,
    reason_code: $reason_code_success,
    filters: { key: $key, language: $language, text_contains: $text_contains, sort_order: $sort_norm },
    total: $total,
    offset: $use_offset,
    limit: $use_limit,
    count: array::len($items),
    items: $items,
    failed_step: '',
    failed_reason: '',
    run_id: $run_id
  };

  -- STEP 5 : LOGGING ET RETURN
  LET $after = $data;
  LET $log_result = fn::builder_log_create_record(
    $reason_code_success, $run_id, $resource_table, $resource_function_id,
    NONE, NONE, NONE, NONE, NONE, $user_id, {}, $data, $before, $after
  );

  RETURN {
    success: true,
    reason_code: $reason_code_success,
    data: $data,
    data_log: $log_result.data
  };
}
COMMENT 'Liste les traductions i18n avec filtres, tri et pagination natifs (performant).'
PERMISSIONS FULL;