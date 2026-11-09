-- ============================================================================
-- SEEDS : réglages des langues de l'installation
-- MODULE : lyxal_i18n
-- ============================================================================
-- Rejouable et non destructif : créés seulement s'ils n'existent pas (après le référentiel).

IF !record::exists(i18n_settings:installation) THEN (
    CREATE i18n_settings:installation CONTENT { default_locale: i18n_locale:⟨fr⟩, source_locale: i18n_locale:⟨fr⟩ }
) END;
