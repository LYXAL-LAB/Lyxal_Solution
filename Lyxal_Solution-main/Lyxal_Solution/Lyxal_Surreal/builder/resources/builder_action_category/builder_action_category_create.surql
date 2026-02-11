-- =============================================================================
-- FONCTION: fn::builder_action_category_create
-- =============================================================================
-- RÔLE
--   Créer une catégorie d'action dans `builder_action_category` avec validations
--   (code/name/description), génération des clés i18n, traductions et logging.
-- PARAMÈTRES
--   - $code: string                 (code source; normalisé en MAJUSCULES avec '.')
--   - $name: string                 (libellé; normalisé)
--   - $description: option<string>  (libellé; normalisé si fourni)
--   - $langue_id: string            (langue de travail; doit exister et être active)
--   - $is_active: option<bool>      (par défaut true)
--   - $metadata: option<object>     (par défaut {})
--   - $payload: option<object>      (par défaut {})
--   - $user_id: option<string>      (créateur; ignoré s'il n'existe pas)
-- COMPORTEMENT
--   0) Vérifie l'utilisateur si fourni (existance).
--   1) Vérifie la langue (existence + active).
--   2) code: sanitize → validate_length → verify_unicity → `$code_final`.
--   3) name: sanitize → validate_length → i18n_key_generate → verify_unicity → `$key_i18n_name`.
--   4) description (optionnel): sanitize → validate_length → i18n_key_generate → verify_unicity → `$key_i18n_description`.
--   5) BEGIN; CREATE record avec id = type::thing('builder_action_category', `$code_final`)
--      puis création des clés i18n et des traductions (name puis description si présente);
--      COMMIT; CANCEL à la première erreur.
-- RETOURS
--   - success: bool (optimiste; passe à false au premier échec)
--   - reason_code: 'ACTION.CATEGORY.CREATE.SUCCESS' | 'ACTION.CATEGORY.CREATE.FAILED'
--   - message: traduction de `reason_code` via i18n
--   - data: {
--       success, table: 'builder_action_category', reason_code,
--       code, name, key_i18n_name, key_i18n_description,
--       resource_id: code court, failed_step, failed_reason, run_id
--     }
-- LOGGING
--   - Appel de `fn::builder_action_category_log(...)` avec `resource_id = code court`.
-- FONCTIONS UTILISÉES
--   - fn::builder_user_verify_id
--   - fn::builder_i18n_language_verify_id_active
--   - fn::builder_action_category_sanitize
--   - fn::builder_action_category_validate_length
--   - fn::builder_action_category_verify_unicity
--   - fn::builder_action_category_i18n_key_generate
--   - fn::builder_i18n_key_create
--   - fn::builder_i18n_translation_create
--   - fn::builder_error_get_by_code
--   - fn::builder_i18n_translation_get
--   - fn::builder_action_category_log
-- =============================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_create(
  $code:string,
  $name: string,
  $description: option<string>,
  $langue_id: string,
  $is_active: option<bool>,
  $metadata: option<object>,
  $payload: option<object>,
  $user_id: option<string>
) {

  -- paramètres par défaut
  LET $run_id = rand::uuid(); -- run_id pour la transaction
  LET $step_valid = true; -- step_valid pour les validations
  LET $code_final = $code; -- code final pour la création
  LET $name_final = $name; -- name final pour la création
  LET $description_final = $description; -- description final pour la création
  LET $key_i18n_name = NONE; -- key_i18n_name pour la création
  LET $key_i18n_description = NONE; -- key_i18n_description pour la création
  LET $reason_code_success = 'ACTION.CATEGORY.CREATE.SUCCESS';
  LET $reason_code_failed = 'ACTION.CATEGORY.CREATE.FAILED';
  LET $failed_step = '';
  LET $failed_reason = '';

  -- on construit le return standard et le logging standard
  LET $success = true;
  LET $reason_code = '';
  LET $resource_table = 'builder_action_category';
  LET $resource_function_id = 'function_builder_action_category_create';
  LET $resource_id = NONE;
  LET $target_table = NONE;
  LET $target_function_id = NONE;
  LET $target_id = NONE;
  LET $message_vars = NONE;
  LET $meta = {};
  LET $before = {};
  LET $after = {};
  LET $message = '';
  LET $data = { };


  -- VALIDATIONS PREALABLES

  -- STEP 0: VERIFICATION DE L'UTILISATEUR (plus tard on ajoutera les permissions)
  IF $step_valid = true {
    -- on vérifie que l'utilisateur existe
    LET $user_result = fn::builder_user_verify_id($user_id);
    -- si l'utilisateur n'existe pas, on retourne l'erreur
    IF $user_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'user_id_verify';
      LET $failed_reason = $user_result.reason_code;
    }
    ELSE IF $user_result.success = true {
      LET $user_id = $user_result.data.user_id;
    };
  };

  -- STEP 1: VERIFICATION DE LA LANGUE
  IF $step_valid = true {
    -- On vérifie que la langue existe et est active pour l'utilisation de la fonction
    LET $langue_result = fn::builder_i18n_language_verify_id_active($langue_id, true);
    -- si la langue n'existe pas ou n'est pas active, on retourne l'erreur
    IF $langue_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'langue_verify';
      LET $failed_reason = $langue_result.reason_code;
    };
  };

  -- STEP 2: SANITIZATION DU CODE
  IF $step_valid = true {
    -- Vérification de la conformité du code
    -- on sanitize le code
    LET $code_result = fn::builder_action_category_sanitize('code', $code_final);
    -- si la sanitization échoue, on retourne l'erreur
    IF $code_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'code_sanitize';
      LET $failed_reason = $code_result.reason_code;
    }
    ELSE IF $code_result.success = true {
      LET $code_final = $code_result.data.sanitized;
    };
  };

  -- STEP 3: VALIDATION DE LA LONGUEUR DU CODE
  IF $step_valid = true {
    -- on valide la longueur du code
    LET $code_length_result = fn::builder_action_category_validate_length('code', $code_final);
    -- si la validation de la longueur échoue, on retourne l'erreur
    IF $code_length_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'code_validate_length';
      LET $failed_reason = $code_length_result.reason_code;
    };
  };

  -- STEP 4: VERIFICATION DE L'UNICITE DU CODE
  IF $step_valid = true {
    -- on verifie l'unicité du code de la catégorie
    LET $category_exists = fn::builder_action_category_verify_unicity($code_final);
    -- si la catégorie existe, on retourne l'erreur
    IF $category_exists.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'code_verify_unicity';
      LET $failed_reason = $category_exists.reason_code;
    };
  };

  -- STEP 5: SANITIZATION DU NAME
  IF $step_valid = true {
    -- on sanitize le name
    LET $name_result = fn::builder_action_category_sanitize('name', $name_final);
    -- si la sanitization échoue, on retourne l'erreur
    IF $name_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'name_sanitize';
      LET $failed_reason = $name_result.reason_code;
    }
    ELSE IF $name_result.success = true
    {
      LET $name_final = $name_result.data.sanitized;
    };
  };

  -- STEP 6: VALIDATION DE LA LONGUEUR DU NAME
  IF $step_valid = true {
    -- on valide la longueur du name
    LET $name_length_result = fn::builder_action_category_validate_length('name',$name_final);
    -- si la validation de la longueur échoue, on retourne l'erreur
    IF $name_length_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'name_validate_length';
      LET $failed_reason = $name_length_result.reason_code;
    };
  };

  -- STEP 7: GENERATION DE LA CLE I18N DU NAME
  IF $step_valid = true {
    -- on génère la clé i18n du name
    LET $name_key_result = fn::builder_action_category_i18n_key_generate($name_final, 'name');
    -- si la génération de la clé i18n échoue, on retourne l'erreur
    IF $name_key_result.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'name_i18n_key_generate';
      LET $failed_reason = $name_key_result.reason_code;
    }
    -- si la génération de la clé i18n réussit, on enregistre la clé i18n
    ELSE IF $name_key_result.success = true
    {
      LET $key_i18n_name = $name_key_result.data.key_i18n;
    };
  };
  -- STEP 8: VERIFICATION DE L'UNICITE DE LA CLE I18N DU NAME
  IF $step_valid = true {
    -- on vérifie l'unicité de la clé i18n du name
    LET $name_key_exists = fn::builder_i18n_key_verify_unicity($key_i18n_name);
    -- si la clé i18n du name existe, on retourne l'erreur
    IF $name_key_exists.success = false {
      -- on rend les steps suivants false
      LET $step_valid = false;
      -- on retourne l'erreur pour le return et le logging
      LET $success = false;
      LET $failed_step = 'name_i18n_key_verify_unicity';
      LET $failed_reason = $name_key_exists.reason_code;
    };
  };

  -- TRAITEMENT DE LA DESCRIPTION OPTIONNELLE : SI DESCRIPTION EST RENSEIGNE
  IF $description_final != NONE {
    -- STEP 9: SANITIZATION DE LA DESCRIPTION
    IF $step_valid = true {
      -- Vérification de la conformité de la description
      LET $description_result = fn::builder_action_category_sanitize('description', 
      $description_final);
      -- si la sanitization échoue, on retourne l'erreur
      IF $description_result.success = false {
        -- on rend les steps suivants false
        LET $step_valid = false;
        -- on retourne l'erreur pour le return et le logging
        LET $success = false;
        LET $failed_step = 'description_sanitize';
        LET $failed_reason = $description_result.reason_code;
      }
      ELSE IF $description_result.success = true
      {
        LET $description_final = $description_result.data.sanitized;
      };
    };

    -- STEP 10: VALIDATION DE LA LONGUEUR DE LA DESCRIPTION
    IF $step_valid = true {
      -- on valide la longueur de la description
      LET $description_length_result = fn::builder_action_category_validate_length('description', 
      $description_final);
      -- si la validation de la longueur échoue, on retourne l'erreur
      IF $description_length_result.success = false {
        -- on rend les steps suivants false
        LET $step_valid = false;
        -- on retourne l'erreur pour le return et le logging
        LET $success = false;
        LET $failed_step = 'description_validate_length';
        LET $failed_reason = $description_length_result.reason_code;
      };
    };

    -- STEP 11: GENERATION DE LA CLE I18N DE LA DESCRIPTION
    IF $step_valid = true {
      -- on génère la clé i18n de la description
      LET $description_key_result = fn::builder_action_category_i18n_key_generate(
      $description_final, 'description');
      -- si la génération de la clé i18n échoue, on retourne l'erreur
      IF $description_key_result.success = false {
        -- on rend les steps suivants false
        LET $step_valid = false;
        -- on retourne l'erreur pour le return et le logging
        LET $success = false;
        LET $failed_step = 'description_i18n_key_generate';
        LET $failed_reason = $description_key_result.reason_code;
      }
      ELSE IF $description_key_result.success = true
      {
        LET $key_i18n_description = $description_key_result.data.key_i18n;
      };
    };

    -- STEP 12: VERIFICATION DE L'UNICITE DE LA CLE I18N DE LA DESCRIPTION
    IF $step_valid = true {
      -- on vérifie l'unicité de la clé i18n de la description
      LET $description_key_exists = fn::builder_i18n_key_verify_unicity($key_i18n_description);
      -- si la clé i18n de la description existe, on retourne l'erreur
      IF $description_key_exists.success = false {
        -- on rend les steps suivants false
        LET $step_valid = false;
        -- on retourne l'erreur pour le return et le logging
        LET $success = false;
        LET $failed_step = 'description_i18n_key_verify_unicity';
        LET $failed_reason = $description_key_exists.reason_code;
      };
    };
  }
  -- FIN DU TRAITEMENT DE LA DESCRIPTION OPTIONNELLE
  ELSE IF $description_final = NONE {
    LET $key_i18n_description = NONE;
  };
  

  -- STEP 13: CREATION DE LA CATÉGORIE
  IF $step_valid = true {

    -- On lance la procédure de création de la catégorie
    BEGIN;
    -- On crée la catégorie
    -- création de l'id de la catégorie
    LET $resource_id = type::thing('builder_action_category', $code_final);
    LET $rec_id = 
    CREATE $resource_id SET
      key = {
        name: $key_i18n_name,
        description: $key_i18n_description
      },
      is_active = IF $is_active = NONE THEN true ELSE $is_active END,
      metadata = IF $metadata = NONE THEN {} ELSE $metadata END,
      payload = IF $payload = NONE THEN {} ELSE $payload END,
      created_at = time::now(),
      created_by = $user_id;

    -- si la catégorie n'est pas créée, on stop la transaction et on retourne l'erreur
    IF $rec_id = NONE {
      CANCEL;
      LET $step_valid = false;
      LET $success = false;
      LET $failed_step = 'create_category';
      LET $failed_reason = 'ACTION.CATEGORY.CREATE.FAILED';
    };
  };

  -- STEP 14: CREATION DE LA CLE I18N DU NAME
  IF $step_valid = true {
    -- On crée la clé i18n name
    LET $key_result = fn::builder_i18n_key_create($key_i18n_name, 'Clé i18n nom de la catégorie',
    $run_id, $user_id);
    -- si la création de la clé i18n échoue, on stop la transaction et on retourne l'erreur
    IF $key_result.success = false {
      CANCEL;
      -- on retourne l'erreur
      LET $step_valid = false;
      LET $success = false;
      LET $failed_step = 'key_i18n_name_create';
      LET $failed_reason = $key_result.reason_code;
    };
  };

  -- STEP 15: CREATION DE LA TRADUCTION DU NAME
  IF $step_valid = true {
    -- si la création de la clé i18n réussit, on enregistre la traduction
    LET $translation_result = fn::builder_i18n_translation_create($key_i18n_name, $langue_id,
    $name_final, $user_id, $run_id);
    -- si la création de la traduction échoue, on stop la transaction et on retourne l'erreur
    IF $translation_result.success = false {
      CANCEL;
      LET $step_valid = false;
      LET $success = false;
      LET $failed_step = 'translation_name_create';
      LET $failed_reason = $translation_result.reason_code;
    };
  };

  -- STEP 16: CREATION DE LA CLE I18N DE LA DESCRIPTION
  IF $key_i18n_description != NONE {
    IF $step_valid = true {
      -- On crée la clé i18n description
      LET $key_result = fn::builder_i18n_key_create($key_i18n_description,
      'Clé i18n description de la catégorie', $run_id, $user_id);
      -- si la création de la clé i18n échoue, on stop la transaction et on retourne l'erreur
      IF $key_result.success = false {
        CANCEL;
        LET $step_valid = false;
        LET $success = false;
        LET $failed_step = 'key_i18n_description_create';
        LET $failed_reason = $key_result.reason_code;
      };
    };

    -- STEP 17: CREATION DE LA TRADUCTION DE LA DESCRIPTION
    IF $step_valid = true {
      -- si la création de la clé i18n réussit, on enregistre la traduction
      LET $translation_result = fn::builder_i18n_translation_create($key_i18n_description, 
      $langue_id, $description_final, $user_id, $run_id);
      -- si la création de la traduction échoue, on stop la transaction et on retourne l'erreur
      IF $translation_result.success = false {
        CANCEL;
        LET $step_valid = false;
        LET $success = false;
        LET $failed_step = 'translation_description_create';
        LET $failed_reason = $translation_result.reason_code;
      };
    };
  };
  -- STEP 18: COMMIT
  IF $step_valid = true {
    -- on commit la transaction
    COMMIT;
  };

  -- STEP 19: On construit le logginq et le return
  IF $success = true {
    LET $reason_code = $reason_code_success;
  }
  ELSE IF $success = false {
    LET $reason_code = $reason_code_failed;
  };

  LET $data = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code,
    code: $code_final,
    name: $name_final,
    key_i18n_name: $key_i18n_name,
    key_i18n_description: $key_i18n_description,
    resource_id: $code_final,
    failed_step: $failed_step,
    failed_reason: $failed_reason,
    run_id: $run_id,
  };

  LET $after = {
    success: $success,
    table: $resource_table,
    reason_code: $reason_code,
    code: $code_final,
    name: $name_final,
    key_i18n_name: $key_i18n_name,
    key_i18n_description: $key_i18n_description,
    resource_id: $code_final,
    failed_step: $failed_step,
    failed_reason: $failed_reason,
    run_id: $run_id,
  };



  -- STEP 20: LOGGING ET RETURN
  -- on log le résultat de la création de la catégorie
  LET $log_result = fn::builder_log_create_record($reason_code, $run_id, $resource_table, 
  $resource_function_id, $resource_id, $target_table, $target_function_id, 
  $target_id, $message_vars, $user_id, $meta, $data, $before, $after);

  -- on récupère la clé i18n de l'erreur et la traduction correspondante
  LET $error_key = fn::builder_error_get_by_code($reason_code);
  LET $error_translation = fn::builder_i18n_translation_get($error_key.data.message_key, 
  $langue_id);
  LET $message = $error_translation.message;

  -- on retourne le résultat complet dans la langue demandée
  RETURN {
    success: $success, 
    message: $error_translation.message, 
    reason_code: $reason_code, 
    data: $data,
    data_log: $log_result.data
  };
}
COMMENT 'Créer une catégorie d\'action builder'
PERMISSIONS FULL;