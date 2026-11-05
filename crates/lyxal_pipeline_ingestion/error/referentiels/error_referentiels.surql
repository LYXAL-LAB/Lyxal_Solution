-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, référentiels
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_RULE_FAMILY_INVALID) THEN (
    CREATE error_definition:INGESTION_RULE_FAMILY_INVALID CONTENT {
        code: "INGESTION_RULE_FAMILY_INVALID",
        module: "ingestion",
        domain: "rules",
        category: "validation",
        severity: "error",
        message: "Famille de produits invalide",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Famille invalide",
                description: "Le code et le libellé de la famille sont obligatoires.",
                resolution: "Compléter la famille de produits."
            },
            en: {
                label: "Invalid product family",
                description: "Family code and label are required.",
                resolution: "Complete the product family."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_SPEC_INVALID) THEN (
    CREATE error_definition:INGESTION_SPEC_INVALID CONTENT {
        code: "INGESTION_SPEC_INVALID",
        module: "ingestion",
        domain: "rules",
        category: "validation",
        severity: "error",
        message: "Spécification technique invalide",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Spécification invalide",
                description: "La clé d'identité technique et la famille sont obligatoires.",
                resolution: "Compléter la spécification technique."
            },
            en: {
                label: "Invalid technical specification",
                description: "The technical identity key and family are required.",
                resolution: "Complete the technical specification."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_SUBSTITUTION_RULE_INVALID) THEN (
    CREATE error_definition:INGESTION_SUBSTITUTION_RULE_INVALID CONTENT {
        code: "INGESTION_SUBSTITUTION_RULE_INVALID",
        module: "ingestion",
        domain: "rules",
        category: "validation",
        severity: "error",
        message: "Règle de substitution invalide",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Substitution invalide",
                description: "Une règle de substitution exige source, cible, contexte et certification.",
                resolution: "Compléter la règle de substitution."
            },
            en: {
                label: "Invalid substitution rule",
                description: "A substitution rule requires source, target, scope and certification.",
                resolution: "Complete the substitution rule."
            }
        }
    }
) END;
