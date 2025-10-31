DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_delete(
  $category_id: string,
  $langue_id: string,
  $user_id: option<string>
) {
  LET $run_id = rand::uuid();

  -- on construit le return standard
  LET $success = false;
  LET $reason_code = '';
  LET $message = '';
  LET $data = { 
    table: 'builder_action_category', 
    category_id: $category_id 
    };

  -- On vérifie que la langue existe et est active pour l'utilisation de la fonction
  LET $langue_result = fn::builder_i18n_language_verify_id_active($langue_id, true);
  -- si la langue n'existe pas ou n'est pas active, on retourne l'erreur
  IF $langue_result.success = false {
    -- on récupére la clé i18n de l'erreur
    LET $error_key = fn::builder_error_get_by_code($langue_result.reason_code);
    -- on recupere la traduction de l'erreur
    LET $error_translation = fn::builder_i18n_translation_get($error_key.data.message_key, 
    $langue_id);
    -- on retourne l'erreur
    LET $success = false;
    LET $reason_code = $langue_result.reason_code;
    LET $message = $error_translation.message;
  }
  ELSE IF $langue_result.success = true
  {
    -- on vérifie que le code existe
    LET $result = fn::builder_action_category_get_by_id($category_id);
    -- si la catégorie n'existe pas, on retourne l'erreur
    IF $result.success = false {
      -- on récupére la clé i18n de l'erreur
      LET $error_key = fn::builder_error_get_by_code($result.reason_code);
      -- on recupere la traduction de l'erreur
      LET $error_translation = fn::builder_i18n_translation_get($error_key.data.message_key, 
      $langue_id);
      -- on retourne l'erreur
      LET $success = false;
      LET $reason_code = $result.reason_code;
      LET $message = $error_translation.message;
      LET $data = $result.data;
    }
    -- la catégorie existe, on lance le processus de suppression
    ELSE IF $result.success = true
    {
      -- on vérifie si des actions sont rattachées à cette catégorie
      LET $actions = SELECT * FROM builder_action WHERE category_id = $category_id;
      -- si des actions sont rattachées à cette catégorie, on retourne ne supprime pas
      -- la catégorie, on la désactive
      IF array::len($actions) > 0 {
        BEGIN;
        -- on désactive la catégorie et toutes ses actions
        LET $updated_category = UPDATE $result.data.id SET is_active = false, 
        updated_on = time::now(), updated_by = $user_id;
        -- on désactive toutes les actions
        LET $updated_actions = UPDATE builder_action SET is_active = false, updated_on = time::now(), updated_by = $user_id WHERE category_id = $category_id;
        COMMIT;

        -- on retourne le retour standard
        LET $success = true;
        LET $reason_code = 'CATEGORY_DEACTIVATED';
        LET $message = 'catégorie désactivée';
        LET $data = $result.data;
      }
      ELSE
      {
        -- on supprime la catégorie
        DELETE $result.data.id;
      }
      };
      };
  RETURN { success: true, message: 'catégorie supprimée', run_id: $run_id };
}
COMMENT 'Supprime une catégorie d\'action par code'
PERMISSIONS FULL;
