-- =============================================================================================
-- | EVENT : time_unit_auto_create_i18n_keys
-- | Module : System / Reference
-- | Description : Événement qui crée automatiquement les clés i18n lors de la création d'une unité de temps
-- |
-- | Comportement :
-- |   - Se déclenche lors de la création d'une unité de temps dans la table `time_unit`
-- |   - Crée automatiquement les clés i18n :
-- |     * time_unit_{code}_label (obligatoire, toujours créée)
-- |     * time_unit_{code}_description (si description_i18n est référencé, utilise description_source)
-- |
-- | Remarques :
-- |   - Les vérifications d'existence sont gérées par les fonctions, pas par l'event
-- |   - Utilise la langue par défaut depuis i18n_config
-- =============================================================================================

DEFINE EVENT time_unit_auto_create_i18n_keys ON TABLE time_unit
    WHEN $event = "CREATE" THEN {
        LET $created_by= 'time_unit';
        -- Récupération de la langue par défaut depuis i18n_config
        LET $config = SELECT config.default_language FROM i18n_config LIMIT 1;
        LET $lang_record = $config[0].config.default_language;
        LET $lang_data = SELECT identity.slug FROM $lang_record LIMIT 1;
        LET $default_language = $lang_data[0].identity.slug;

        -- Récupération du code de l'unité (en lowercase pour le nom de la clé)
        LET $unit_code = string::replace($value.identity.value, '-', '_');
        
        -- Création de la clé i18n label (obligatoire) - utilise le label source
        LET $label_value = $value.content.label_source;
        LET $label_description = "Libellé de l'unité de temps " + $unit_code;
        fn::create_i18n_key("label", "time_unit", $unit_code, "system", true, $label_value, $label_description, $default_language, $created_by);
        
        -- Création de la clé i18n description (si référencé, créer la clé avec description_source)
        IF $value.presentation.description_i18n != NONE {
            LET $desc_value = $value.content.description_source;
            LET $desc_description = "Description de l'unité de temps " + $unit_code;
            fn::create_i18n_key("description", "time_unit", $unit_code, "system", true, $desc_value, $desc_description, $default_language, $created_by);
        };
    }
    COMMENT 'Crée automatiquement les clés i18n lors de la création d\'une unité de temps';

