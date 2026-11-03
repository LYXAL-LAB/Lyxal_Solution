-- ============================================================================
-- MASTER DATA : définitions d'erreurs du module lyxal_runtime
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:RUNTIME_INVALID_PARAMETERS) THEN (
    CREATE error_definition:RUNTIME_INVALID_PARAMETERS CONTENT {
        code: "RUNTIME_INVALID_PARAMETERS",
        module: "runtime",
        domain: "parameters",
        category: "validation",
        severity: "error",
        message: "One or more runtime function parameters are missing or invalid",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres du runtime invalides",
                description: "Un ou plusieurs paramètres d'une fonction du runtime sont absents ou invalides (détail par champ dans details.fields).",
                resolution: "Corriger l'appel : les valeurs viennent du code du runtime, pas d'un utilisateur."
            },
            en: {
                label: "Invalid runtime parameters",
                description: "One or more parameters of a runtime function are missing or invalid (per-field detail in details.fields).",
                resolution: "Fix the call: these values come from the runtime code, not from a user."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RELEASE_NOT_FOUND) THEN (
    CREATE error_definition:RUNTIME_RELEASE_NOT_FOUND CONTENT {
        code: "RUNTIME_RELEASE_NOT_FOUND",
        module: "runtime",
        domain: "release",
        category: "not_found",
        severity: "error",
        message: "Module release was not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Release de module introuvable",
                description: "Aucune release n'est enregistrée pour ce module et cette version.",
                resolution: "Enregistrer la release avant de changer son statut."
            },
            en: {
                label: "Module release not found",
                description: "No release is registered for this module and version.",
                resolution: "Register the release before changing its status."
            }
        }
    }
) END;
