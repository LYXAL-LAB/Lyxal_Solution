-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_i18n, thème langues
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:I18N_LOCALE_NOT_FOUND) THEN (
    CREATE error_definition:I18N_LOCALE_NOT_FOUND CONTENT {
        code: "I18N_LOCALE_NOT_FOUND",
        module: "i18n",
        domain: "langues",
        category: "not_found",
        severity: "warning",
        message: "Locale not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Langue inconnue", description: "Cette langue ne fait pas partie du référentiel.", resolution: "Choisissez une langue de la liste." },
            en: { label: "Unknown language", description: "This language is not in the reference list.", resolution: "Choose a language from the list." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_LOCALE_INACTIVE) THEN (
    CREATE error_definition:I18N_LOCALE_INACTIVE CONTENT {
        code: "I18N_LOCALE_INACTIVE",
        module: "i18n",
        domain: "langues",
        category: "business",
        severity: "warning",
        message: "Locale inactive",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Langue inactive", description: "Cette langue n'est pas activée sur l'installation.", resolution: "Activez la langue avant de l'utiliser." },
            en: { label: "Inactive language", description: "This language is not enabled on the installation.", resolution: "Enable the language before using it." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_LOCALE_DEFAULT_REQUIRED) THEN (
    CREATE error_definition:I18N_LOCALE_DEFAULT_REQUIRED CONTENT {
        code: "I18N_LOCALE_DEFAULT_REQUIRED",
        module: "i18n",
        domain: "langues",
        category: "business",
        severity: "warning",
        message: "Default locale cannot be deactivated",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Langue par défaut", description: "La langue par défaut ou la langue source ne peut pas être désactivée.", resolution: "Changez d'abord la langue par défaut ou la langue source." },
            en: { label: "Default language", description: "The default or source language cannot be deactivated.", resolution: "Change the default or source language first." }
        }
    }
) END;
