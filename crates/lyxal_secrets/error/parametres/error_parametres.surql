-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème parametres
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_INVALID_PARAMETERS) THEN (
    CREATE error_definition:SECRETS_INVALID_PARAMETERS CONTENT {
        code: "SECRETS_INVALID_PARAMETERS",
        module: "secrets",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Invalid parameters",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Les paramètres fournis ne respectent pas le format attendu (détail par champ : fields).",
                resolution: "Corrigez les champs signalés."
            },
            en: {
                label: "Invalid parameters",
                description: "The supplied parameters do not match the expected format (per-field detail: fields).",
                resolution: "Fix the reported fields."
            }
        }
    }
) END;
