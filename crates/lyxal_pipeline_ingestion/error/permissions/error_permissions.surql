-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, permissions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_UNAUTHORIZED) THEN (
    CREATE error_definition:INGESTION_UNAUTHORIZED CONTENT {
        code: "INGESTION_UNAUTHORIZED",
        module: "ingestion",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Opération non autorisée pour cette identité",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Opération non autorisée",
                description: "L'identité de la session n'a pas le droit d'effectuer cette opération.",
                resolution: "Utiliser une identité autorisée."
            },
            en: {
                label: "Operation not allowed for this identity",
                description: "The session identity is not allowed to perform this operation.",
                resolution: "Use an authorised identity."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_UNAUTHORIZED_APPROVER) THEN (
    CREATE error_definition:INGESTION_UNAUTHORIZED_APPROVER CONTENT {
        code: "INGESTION_UNAUTHORIZED_APPROVER",
        module: "ingestion",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Action réservée au Data Steward",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Data Steward requis",
                description: "Seule une session détenant la permission ingestion.manifest.approve, au niveau d'assurance requis (double facteur), ou la session de l'hôte peut requalifier, résoudre une quarantaine ou approuver.",
                resolution: "Se connecter avec un compte ayant le rôle ingestion_steward, avec double facteur."
            },
            en: {
                label: "Data Steward action",
                description: "Only a session holding the ingestion.manifest.approve permission, at the required assurance level (second factor), or the host session can requalify, resolve quarantine or approve.",
                resolution: "Sign in with an account holding the ingestion_steward role, using a second factor."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:INGESTION_WRITE_FORBIDDEN CONTENT {
        code: "INGESTION_WRITE_FORBIDDEN",
        module: "ingestion",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Écriture refusée par les permissions du pipeline",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "L'identité de la session n'a pas le droit d'écrire cet enregistrement ; rien n'a été écrit.",
                resolution: "Utiliser une identité autorisée pour cette table."
            },
            en: {
                label: "Write forbidden",
                description: "The session identity may not write this record; nothing was written.",
                resolution: "Use an identity authorised for this table."
            }
        }
    }
) END;
