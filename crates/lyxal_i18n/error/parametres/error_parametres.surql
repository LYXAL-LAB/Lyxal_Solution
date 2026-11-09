-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_i18n, thème paramètres et droits
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:I18N_INVALID_PARAMETERS) THEN (
    CREATE error_definition:I18N_INVALID_PARAMETERS CONTENT {
        code: "I18N_INVALID_PARAMETERS",
        module: "i18n",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Invalid parameters",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Paramètres invalides", description: "Les paramètres fournis ne respectent pas le format attendu.", resolution: "Corrigez les champs signalés." },
            en: { label: "Invalid parameters", description: "The supplied parameters do not match the expected format.", resolution: "Fix the reported fields." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_PERMISSION_DENIED) THEN (
    CREATE error_definition:I18N_PERMISSION_DENIED CONTENT {
        code: "I18N_PERMISSION_DENIED",
        module: "i18n",
        domain: "parametres",
        category: "authorization",
        severity: "warning",
        message: "Permission denied",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Accès refusé", description: "Vous n'avez pas la permission de gérer les langues.", resolution: "Demandez la permission i18n.locale.manage à un administrateur." },
            en: { label: "Access denied", description: "You are not allowed to manage languages.", resolution: "Ask an administrator for the i18n.locale.manage permission." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:I18N_WRITE_FORBIDDEN CONTENT {
        code: "I18N_WRITE_FORBIDDEN",
        module: "i18n",
        domain: "parametres",
        category: "authorization",
        severity: "warning",
        message: "Write forbidden",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Écriture refusée", description: "La modification a été refusée par les droits de la base.", resolution: "Vérifiez vos permissions." },
            en: { label: "Write forbidden", description: "The change was refused by the database permissions.", resolution: "Check your permissions." }
        }
    }
) END;
