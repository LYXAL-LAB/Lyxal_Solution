-- ============================================================================
-- DÉFINITIONS D'ERREURS CANONIQUES — MODULE LYXAL_ERROR
-- DOMAINE : error
-- CONFORMITÉ : .agents/AGENTS.md & SurrealDB 3.2.0 (Idempotent)
-- ============================================================================

IF !record::exists(error_definition:ERROR_PARAM_REQUIRED) 
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_PARAM_REQUIRED" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_PARAM_REQUIRED CONTENT {
        code: "ERROR_PARAM_REQUIRED",
        module: "error",
        domain: "validation",
        category: "validation",
        severity: "error",
        message: "A required parameter is missing or empty",
        default_language: "en",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètre obligatoire manquant",
                description: "Un paramètre indispensable à l'exécution de l'opération n'a pas été renseigné ou est vide.",
                resolution: "Veuillez renseigner l'ensemble des champs obligatoires indiqués dans les détails."
            },
            en: {
                label: "Required parameter missing",
                description: "A parameter required to execute this operation was not provided or is empty.",
                resolution: "Please provide all required fields indicated in the details."
            }
        }
    }
) END;

IF !record::exists(error_definition:ERROR_DEFINITION_NOT_FOUND) 
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_DEFINITION_NOT_FOUND" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_DEFINITION_NOT_FOUND CONTENT {
        code: "ERROR_DEFINITION_NOT_FOUND",
        module: "error",
        domain: "definition",
        category: "not_found",
        severity: "error",
        message: "The requested error definition was not found",
        default_language: "en",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Définition d'erreur introuvable",
                description: "Aucune définition d'erreur ne correspond au code ou à l'identifiant spécifié.",
                resolution: "Vérifiez l'exactitude du code d'erreur ou assurez-vous qu'elle a bien été enregistrée."
            },
            en: {
                label: "Error definition not found",
                description: "No error definition matches the specified code or identifier.",
                resolution: "Check the error code or ensure it has been properly registered."
            }
        }
    }
) END;

IF !record::exists(error_definition:ERROR_DEFINITION_ALREADY_EXISTS) 
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_DEFINITION_ALREADY_EXISTS" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_DEFINITION_ALREADY_EXISTS CONTENT {
        code: "ERROR_DEFINITION_ALREADY_EXISTS",
        module: "error",
        domain: "definition",
        category: "conflict",
        severity: "error",
        message: "An error definition with this code already exists",
        default_language: "en",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code d'erreur déjà existant",
                description: "Une définition d'erreur portant ce code existe déjà dans le catalogue.",
                resolution: "Choisissez un autre code d'erreur ou mettez à jour la définition existante."
            },
            en: {
                label: "Error code already exists",
                description: "An error definition with this code already exists in the catalogue.",
                resolution: "Choose another error code or update the existing definition."
            }
        }
    }
) END;

IF !record::exists(error_definition:ERROR_MAPPING_NOT_FOUND) 
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_MAPPING_NOT_FOUND" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_MAPPING_NOT_FOUND CONTENT {
        code: "ERROR_MAPPING_NOT_FOUND",
        module: "error",
        domain: "mapping",
        category: "not_found",
        severity: "error",
        message: "The external error mapping was not found",
        default_language: "en",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mapping externe introuvable",
                description: "La règle de mapping externe demandée n'existe pas ou a été désactivée.",
                resolution: "Vérifiez l'identifiant de la règle de correspondance externe."
            },
            en: {
                label: "External mapping not found",
                description: "The requested external mapping rule does not exist or has been disabled.",
                resolution: "Check the identifier of the external mapping rule."
            }
        }
    }
) END;

IF !record::exists(error_definition:ERROR_OCCURRENCE_NOT_FOUND) 
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_OCCURRENCE_NOT_FOUND" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_OCCURRENCE_NOT_FOUND CONTENT {
        code: "ERROR_OCCURRENCE_NOT_FOUND",
        module: "error",
        domain: "occurrence",
        category: "not_found",
        severity: "error",
        message: "The error occurrence was not found",
        default_language: "en",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Occurrence d'erreur introuvable",
                description: "L'enregistrement d'occurrence d'erreur demandé est introuvable.",
                resolution: "Vérifiez l'identifiant d'occurrence ou l'intervalle de rétention."
            },
            en: {
                label: "Error occurrence not found",
                description: "The requested error occurrence record could not be found.",
                resolution: "Check the occurrence identifier or retention window."
            }
        }
    }
) END;

IF !record::exists(error_definition:CORE_ERROR_DEFINITION_NOT_FOUND) 
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "CORE_ERROR_DEFINITION_NOT_FOUND" LIMIT 1)) == 0 THEN (
    CREATE error_definition:CORE_ERROR_DEFINITION_NOT_FOUND CONTENT {
        code: "CORE_ERROR_DEFINITION_NOT_FOUND",
        module: "core",
        domain: "error",
        category: "internal",
        severity: "error",
        message: "The requested error definition was not found",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Une erreur inconnue est survenue",
                description: "Le code d'erreur n'a pas pu être résolu dans le référentiel.",
                resolution: "Réessayez ou contactez le support technique."
            },
            en: {
                label: "An unknown error occurred",
                description: "The error code could not be resolved in the repository.",
                resolution: "Retry or contact technical support."
            }
        }
    }
) END;
