-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, erreurs techniques
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_DB_ERROR) THEN (
    CREATE error_definition:INGESTION_DB_ERROR CONTENT {
        code: "INGESTION_DB_ERROR",
        module: "ingestion",
        domain: "technical",
        category: "dependency",
        severity: "error",
        message: "Erreur de la base de données",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Base indisponible",
                description: "SurrealDB a renvoyé une erreur ou est inaccessible.",
                resolution: "Réessayer ; vérifier l'état de la base si l'erreur persiste."
            },
            en: {
                label: "Database error",
                description: "SurrealDB returned an error or is unreachable.",
                resolution: "Retry; check the database if it persists."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_STORAGE_ERROR) THEN (
    CREATE error_definition:INGESTION_STORAGE_ERROR CONTENT {
        code: "INGESTION_STORAGE_ERROR",
        module: "ingestion",
        domain: "technical",
        category: "dependency",
        severity: "error",
        message: "Erreur de persistance",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Persistance en échec",
                description: "Une lecture ou une écriture du pipeline a échoué.",
                resolution: "Réessayer ; consulter le journal si l'erreur persiste."
            },
            en: {
                label: "Storage error",
                description: "A pipeline read or write failed.",
                resolution: "Retry; check the log if it persists."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_CALL_ERROR) THEN (
    CREATE error_definition:INGESTION_CALL_ERROR CONTENT {
        code: "INGESTION_CALL_ERROR",
        module: "ingestion",
        domain: "technical",
        category: "internal",
        severity: "critical",
        message: "Erreur d'appel d'une fonction Lyxal",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Appel en échec",
                description: "Un appel de fonction a renvoyé une erreur inattendue.",
                resolution: "Consulter le journal avec l'identifiant de trace."
            },
            en: {
                label: "Lyxal call error",
                description: "A function call returned an unexpected error.",
                resolution: "Check the log with the trace identifier."
            }
        }
    }
) END;
