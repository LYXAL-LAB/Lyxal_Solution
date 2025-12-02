-- =============================================================================================
-- | EVENT : error_code_auto_create_i18n_keys
-- | Module : error
-- | Description : Événement qui crée automatiquement les clés i18n lors de la création d'un code d'erreur
-- |
-- | Comportement :
-- |   - Se déclenche lors de la création d'un code d'erreur dans la table `error_code`
-- |   - Crée automatiquement les clés i18n :
-- |     * error_code_{code}_message (obligatoire, toujours créée)
-- |     * error_code_{code}_label (si label_i18n est référencé, utilise label_source)
-- |     * error_code_{code}_description (si description_i18n est référencé, utilise description_source)
-- |
-- | Remarques :
-- |   - Les vérifications d'existence sont gérées par les fonctions, pas par l'event
-- |   - Utilise la langue par défaut depuis i18n_config
-- =============================================================================================

DEFINE EVENT error_code_auto_create_i18n_keys ON TABLE error_code
    WHEN $event = "CREATE" THEN {
        LET $created_by = 'error_code';
        -- Récupération de la langue par défaut depuis i18n_config
        LET $config = SELECT config.default_language FROM i18n_config LIMIT 1;
        LET $lang_record = $config[0].config.default_language;
        LET $lang_data = SELECT identity.slug FROM $lang_record LIMIT 1;
        LET $default_language = $lang_data[0].identity.slug;

        -- Récupération du code de l'erreur (en lowercase pour le nom de la clé)
        LET $error_code = string::replace($value.identity.value, '-', '_');
        
        -- Création de la clé i18n message (obligatoire) - utilise le message source
        LET $message_value = $value.content.message_source;
        LET $message_description = "Message d'erreur pour le code " + $error_code;
        fn::create_i18n_key("message", "error_code", $error_code, "error", true, $message_value, $message_description, $default_language, $created_by);

        -- Création de la clé i18n label (si référencé, créer la clé avec label_source)
        IF $value.presentation.label_i18n != NONE {
            LET $label_value = $value.content.label_source;
            LET $label_description = "Libellé du code d'erreur " + $error_code;
            fn::create_i18n_key("label", "error_code", $error_code, "error", true, $label_value, $label_description, $default_language, $created_by);
        };

        -- Création de la clé i18n description (si référencé, créer la clé avec description_source)
        IF $value.presentation.description_i18n != NONE {
            LET $desc_value = $value.content.description_source;
            LET $desc_description = "Description du code d'erreur " + $error_code;
            fn::create_i18n_key("description", "error_code", $error_code, "error", true, $desc_value, $desc_description, $default_language, $created_by);
        };
    }
    COMMENT 'Crée automatiquement les clés i18n lors de la création d\'un code d\'erreur';

