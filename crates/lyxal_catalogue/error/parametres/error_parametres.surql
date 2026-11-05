-- ============================================================================
-- MASTER DATA : définitions d'erreurs du catalogue, paramètres des fonctions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:CATALOGUE_INVALID_PARAMETERS) THEN (
    CREATE error_definition:CATALOGUE_INVALID_PARAMETERS CONTENT {
        code: "CATALOGUE_INVALID_PARAMETERS",
        module: "catalogue",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Un ou plusieurs paramètres sont absents ou invalides",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Un ou plusieurs paramètres sont absents, inconnus ou invalides (détail par champ dans details.fields).",
                resolution: "Corriger les champs indiqués dans details.fields."
            },
            en: {
                label: "Invalid parameters",
                description: "One or more parameters are missing, unknown or invalid (per-field detail in details.fields).",
                resolution: "Fix the fields listed in details.fields."
            }
        }
    }
) END;
