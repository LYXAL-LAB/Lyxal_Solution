-- ============================================================================
-- DÉFINITIONS D'ERREURS — MODULE LYXAL_SURREAL
-- ============================================================================
-- Codes des erreurs de transport émises par `LyxalSurrealError` (réponse HTTP
-- de la fonctionnalité `axum`). Ce sont des erreurs du serveur, jamais de la
-- requête du client. Chaque module porte ses propres définitions (§5.5) ;
-- elles s'écrivent dans la table `error_definition` de `lyxal_error` et
-- s'installent après les schémas. Forme idempotente non destructive.
-- ============================================================================

IF !record::exists(error_definition:SURREAL_DATABASE_ERROR) THEN (
    CREATE error_definition:SURREAL_DATABASE_ERROR CONTENT {
        code: "SURREAL_DATABASE_ERROR",
        module: "surreal",
        domain: "database",
        category: "internal",
        severity: "error",
        message: "A database error occurred",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Erreur de base de données",
                description: "La base de données a renvoyé une erreur (réseau, requête ou authentification).",
                resolution: "Consultez les journaux du serveur pour le détail de l'erreur SurrealDB."
            },
            en: {
                label: "Database error",
                description: "The database returned an error (network, query or authentication).",
                resolution: "Check the server logs for the SurrealDB error details."
            }
        }
    }
) END;

IF !record::exists(error_definition:SURREAL_INVALID_FUNCTION_NAME) THEN (
    CREATE error_definition:SURREAL_INVALID_FUNCTION_NAME CONTENT {
        code: "SURREAL_INVALID_FUNCTION_NAME",
        module: "surreal",
        domain: "function",
        category: "internal",
        severity: "error",
        message: "A SurrealQL function name was refused before execution",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Nom de fonction refusé",
                description: "Le nom de fonction SurrealQL demandé contient des caractères non autorisés (minuscules, chiffres et tirets bas uniquement).",
                resolution: "Corrigez le nom passé à call_fn dans le module appelant."
            },
            en: {
                label: "Function name refused",
                description: "The requested SurrealQL function name contains forbidden characters (lowercase letters, digits and underscores only).",
                resolution: "Fix the name passed to call_fn in the calling module."
            }
        }
    }
) END;

IF !record::exists(error_definition:SURREAL_UNSUPPORTED_ENDPOINT) THEN (
    CREATE error_definition:SURREAL_UNSUPPORTED_ENDPOINT CONTENT {
        code: "SURREAL_UNSUPPORTED_ENDPOINT",
        module: "surreal",
        domain: "endpoint",
        category: "internal",
        severity: "error",
        message: "The database endpoint scheme is not supported",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse de base de données non prise en charge",
                description: "L'adresse de la base de données n'utilise pas un schéma autorisé (ws://, wss://, mem:// ou memory).",
                resolution: "Corrigez l'adresse de la base de données dans la configuration du serveur."
            },
            en: {
                label: "Unsupported database endpoint",
                description: "The database endpoint does not use an allowed scheme (ws://, wss://, mem:// or memory).",
                resolution: "Fix the database endpoint in the server configuration."
            }
        }
    }
) END;

IF !record::exists(error_definition:SURREAL_MISSING_CREDENTIALS) THEN (
    CREATE error_definition:SURREAL_MISSING_CREDENTIALS CONTENT {
        code: "SURREAL_MISSING_CREDENTIALS",
        module: "surreal",
        domain: "credentials",
        category: "internal",
        severity: "error",
        message: "Root credentials are required for a remote database endpoint",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiants de base de données manquants",
                description: "Une connexion distante (ws:// ou wss://) exige un identifiant et un mot de passe Root.",
                resolution: "Renseignez les identifiants Root de la base de données dans la configuration du serveur."
            },
            en: {
                label: "Missing database credentials",
                description: "A remote connection (ws:// or wss://) requires a Root username and password.",
                resolution: "Set the database Root credentials in the server configuration."
            }
        }
    }
) END;

IF !record::exists(error_definition:SURREAL_CONNECT_TIMEOUT) THEN (
    CREATE error_definition:SURREAL_CONNECT_TIMEOUT CONTENT {
        code: "SURREAL_CONNECT_TIMEOUT",
        module: "surreal",
        domain: "connection",
        category: "timeout",
        severity: "error",
        message: "Connection to the database timed out",
        default_language: "en",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Délai de connexion à la base de données dépassé",
                description: "La connexion, l'authentification ou la sélection du namespace et de la base n'ont pas abouti dans le délai prévu.",
                resolution: "Vérifiez que la base de données est joignable, puis réessayez."
            },
            en: {
                label: "Database connection timed out",
                description: "Connection, authentication or namespace and database selection did not complete in time.",
                resolution: "Check that the database is reachable, then retry."
            }
        }
    }
) END;
