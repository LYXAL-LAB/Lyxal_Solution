-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_base, paramètres des fonctions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:BASE_INVALID_PARAMETERS) THEN (
    CREATE error_definition:BASE_INVALID_PARAMETERS CONTENT {
        code: "BASE_INVALID_PARAMETERS",
        module: "base",
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

IF !record::exists(error_definition:BASE_NO_UPDATABLE_FIELDS_PROVIDED) THEN (
    CREATE error_definition:BASE_NO_UPDATABLE_FIELDS_PROVIDED CONTENT {
        code: "BASE_NO_UPDATABLE_FIELDS_PROVIDED",
        module: "base",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Aucun champ modifiable n'a été fourni",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Aucun champ à modifier",
                description: "La requête de mise à jour ne contient aucun champ modifiable.",
                resolution: "Fournissez au moins un champ valide à mettre à jour."
            },
            en: {
                label: "No updatable fields",
                description: "The update request does not contain any modifiable field.",
                resolution: "Provide at least one valid field to update."
            }
        }
    }
) END;
