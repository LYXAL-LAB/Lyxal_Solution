-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, paramètres
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_INVALID_PARAMETERS) THEN (
    CREATE error_definition:INGESTION_INVALID_PARAMETERS CONTENT {
        code: "INGESTION_INVALID_PARAMETERS",
        module: "ingestion",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Paramètres invalides",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Un ou plusieurs paramètres sont absents, mal typés ou hors des bornes admises ; le détail indique les champs concernés.",
                resolution: "Corriger les champs signalés puis renvoyer la demande."
            },
            en: {
                label: "Invalid parameters",
                description: "One or more parameters are missing, mistyped or out of range; the details list the fields concerned.",
                resolution: "Fix the reported fields and send the request again."
            }
        }
    }
) END;
