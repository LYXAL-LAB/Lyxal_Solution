-- ============================================================================
-- DÉFINITIONS D'ERREURS CANONIQUES — MODULE LYXAL_ERROR
-- DOMAINE : error
-- CONFORMITÉ : .agents/AGENTS.md §5.5 & SurrealDB 3.3.4 (idempotent)
-- ============================================================================

IF !record::exists(error_definition:ERROR_INVALID_INPUT)
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_INVALID_INPUT" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_INVALID_INPUT CONTENT {
        code: "ERROR_INVALID_INPUT",
        module: "error",
        domain: "validation",
        category: "validation",
        severity: "error",
        message: "One or more input parameters are missing or invalid",
        default_language: "en",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Un ou plusieurs paramètres sont absents ou ne respectent pas le format attendu.",
                resolution: "Corrigez les champs indiqués dans les détails (details.fields)."
            },
            en: {
                label: "Invalid parameters",
                description: "One or more parameters are missing or do not match the expected format.",
                resolution: "Fix the fields listed in the details (details.fields)."
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

IF !record::exists(error_definition:ERROR_MAPPING_ALREADY_EXISTS)
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_MAPPING_ALREADY_EXISTS" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_MAPPING_ALREADY_EXISTS CONTENT {
        code: "ERROR_MAPPING_ALREADY_EXISTS",
        module: "error",
        domain: "mapping",
        category: "conflict",
        severity: "error",
        message: "An external error mapping with the same provider, service, code and matcher already exists",
        default_language: "en",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Correspondance déjà existante",
                description: "Une correspondance existe déjà pour ce fournisseur, ce service, ce code externe et ce mode.",
                resolution: "Modifiez la correspondance existante plutôt que d'en créer une nouvelle."
            },
            en: {
                label: "Mapping already exists",
                description: "A mapping already exists for this provider, service, external code and matcher.",
                resolution: "Update the existing mapping instead of creating a new one."
            }
        }
    }
) END;

IF !record::exists(error_definition:ERROR_DEFINITION_CODE_PREFIX_MISMATCH)
   AND array::len((SELECT VALUE id FROM error_definition WHERE code = "ERROR_DEFINITION_CODE_PREFIX_MISMATCH" LIMIT 1)) == 0 THEN (
    CREATE error_definition:ERROR_DEFINITION_CODE_PREFIX_MISMATCH CONTENT {
        code: "ERROR_DEFINITION_CODE_PREFIX_MISMATCH",
        module: "error",
        domain: "definition",
        category: "validation",
        severity: "error",
        message: "The error code must start with its module name in uppercase followed by an underscore",
        default_language: "en",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Préfixe du code incorrect",
                description: "Le code d'erreur doit commencer par le nom de son module en majuscules suivi de « _ ».",
                resolution: "Préfixez le code par le module (ex. module booking : BOOKING_…)."
            },
            en: {
                label: "Wrong code prefix",
                description: "The error code must start with its module name in uppercase followed by an underscore.",
                resolution: "Prefix the code with its module (e.g. module booking: BOOKING_…)."
            }
        }
    }
) END;
