-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, quarantaine
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_RECORD_NOT_FOUND) THEN (
    CREATE error_definition:INGESTION_RECORD_NOT_FOUND CONTENT {
        code: "INGESTION_RECORD_NOT_FOUND",
        module: "ingestion",
        domain: "quarantine",
        category: "not_found",
        severity: "error",
        message: "Anomalie en quarantaine introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Anomalie introuvable",
                description: "Aucune anomalie ne correspond à l'identifiant fourni.",
                resolution: "Vérifier l'identifiant de l'anomalie."
            },
            en: {
                label: "Quarantine record not found",
                description: "No quarantine record matches the given identifier.",
                resolution: "Check the record identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_JUSTIFICATION_TOO_SHORT) THEN (
    CREATE error_definition:INGESTION_JUSTIFICATION_TOO_SHORT CONTENT {
        code: "INGESTION_JUSTIFICATION_TOO_SHORT",
        module: "ingestion",
        domain: "quarantine",
        category: "validation",
        severity: "error",
        message: "Justification absente ou trop courte",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Justification insuffisante",
                description: "Une justification de 10 caractères au moins est obligatoire.",
                resolution: "Rédiger une justification explicite."
            },
            en: {
                label: "Justification missing or too short",
                description: "A justification of at least 10 characters is required.",
                resolution: "Write an explicit justification."
            }
        }
    }
) END;
