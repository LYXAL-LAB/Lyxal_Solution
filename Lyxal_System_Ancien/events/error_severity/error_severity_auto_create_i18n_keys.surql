-- =============================================================================================
-- | EVENT : error_severity_auto_create_i18n_keys
-- | Module : error
-- | Description : Événement qui crée automatiquement les clés i18n lors de la création d'une sévérité
-- |
-- | Comportement :
-- |   - Se déclenche lors de la création d'une sévérité dans la table `error_severity`
-- |   - Crée automatiquement les clés i18n :
-- |     * error_severity_{code}_label (obligatoire, toujours créée)
-- |     * error_severity_{code}_description (si description_i18n est référencé, utilise description_source)
-- |     * error_severity_{code}_message (si message_i18n est référencé, utilise message_source)
-- |
-- | Remarques :
-- |   - Les vérifications d'existence sont gérées par les fonctions, pas par l'event
-- |   - Utilise la langue par défaut depuis i18n_config
-- =============================================================================================

DEFINE EVENT error_severity_auto_create_i18n_keys ON TABLE error_severity
    WHEN $event = "CREATE" THEN {
        LET $created_by= 'error_severity';
        -- Récupération de la langue par défaut depuis i18n_config
        LET $config = SELECT config.default_language FROM i18n_config LIMIT 1;
        LET $lang_record = $config[0].config.default_language;
        LET $lang_data = SELECT identity.slug FROM $lang_record LIMIT 1;
        LET $default_language = $lang_data[0].identity.slug;

        -- Récupération du code de la sévérité (en lowercase pour le nom de la clé)
        LET $severity_code = string::replace($value.identity.value, '-', '_');
        
        -- Création de la clé i18n label (obligatoire) - utilise le label source
        LET $label_value = $value.content.label_source;
        LET $label_description = "Libellé de la sévérité d'erreur " + $severity_code;
        fn::create_i18n_key("label", "error_severity", $severity_code, "error", true, $label_value, $label_description, $default_language, $created_by);
        
        -- Création de la clé i18n description (si référencé, créer la clé avec description_source)
        IF $value.presentation.description_i18n != NONE {
            LET $desc_value = $value.content.description_source;
            LET $desc_description = "Description de la sévérité d'erreur " + $severity_code;
            fn::create_i18n_key("description", "error_severity", $severity_code, "error", true, $desc_value, $desc_description, $default_language, $created_by);
        };

        -- Création de la clé i18n message (si référencé, créer la clé avec message_source)
        IF $value.presentation.message_i18n != NONE {
            LET $msg_value = $value.content.message_source;
            LET $msg_description = "Message générique pour la sévérité d'erreur " + $severity_code;
            fn::create_i18n_key("message", "error_severity", $severity_code, "error", true, $msg_value, $msg_description, $default_language, $created_by);
        };
    }
    COMMENT 'Crée automatiquement les clés i18n lors de la création d\'une sévérité d\'erreur';

