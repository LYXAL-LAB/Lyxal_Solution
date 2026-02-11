-- =============================================================================================
-- | EVENT : language_auto_activate_default
-- | Module : i18n
-- | Description : Événement qui active automatiquement la langue par défaut lors de sa création
-- |
-- | Comportement :
-- |   - Se déclenche lors de la création d'une langue dans la table `language`
-- |   - Vérifie si la langue créée correspond à la langue par défaut définie dans `i18n_config`
-- |   - Si oui, active automatiquement la langue (metadata.status.is_active = true)
-- |
-- | Remarques :
-- |   - L'événement utilise AFTER CREATE pour s'assurer que la langue est bien créée
-- |   - La vérification se fait par comparaison de l'ID de la langue avec config.default_language
-- =============================================================================================

DEFINE EVENT language_auto_activate_default ON TABLE language
    WHEN $event = "CREATE" THEN {
        -- Récupération de la configuration i18n
        LET $config = SELECT id, config.default_language, config.default_language_is_active FROM i18n_config LIMIT 1;
        
        -- Vérification si une configuration existe et si elle a une langue par défaut
        IF array::len($config) > 0 AND $config[0].config.default_language != NONE {
            -- Récupération de l'ID de la langue par défaut
            LET $default_language_id = $config[0].config.default_language;
            
            -- Vérification si la langue créée correspond à la langue par défaut
            IF $value.id = $default_language_id {
                -- Activation automatique de la langue par défaut
                UPDATE $value.id SET metadata.status.is_active = true;
                
                -- Mise à jour du flag dans la configuration pour indiquer que la langue est activée
                UPDATE $config[0].id SET config.default_language_is_active = true;
            };
        };
    }
    COMMENT 'Active automatiquement la langue par défaut lors de sa création et met à jour le flag de configuration';

