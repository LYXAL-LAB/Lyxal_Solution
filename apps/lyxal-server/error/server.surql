-- ============================================================================
-- MASTER DATA : définitions d'erreurs de l'hôte lyxal-server
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- Vérifiées contre le catalogue Rust (src/error.rs) par un test.
-- ============================================================================

IF !record::exists(error_definition:SERVER_CONFIGURATION_INVALID) THEN (
    CREATE error_definition:SERVER_CONFIGURATION_INVALID CONTENT {
        code: "SERVER_CONFIGURATION_INVALID",
        module: "server",
        domain: "configuration",
        category: "internal",
        severity: "error",
        message: "Server configuration is invalid",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Configuration du serveur invalide",
                description: "La configuration chargée (fichiers et variables LYXAL__*) est absente, illisible ou incohérente.",
                resolution: "Corriger la configuration selon le détail du journal."
            },
            en: {
                label: "Invalid server configuration",
                description: "Server configuration is invalid.",
                resolution: "Fix the configuration according to the log detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_DATABASE_UNAVAILABLE) THEN (
    CREATE error_definition:SERVER_DATABASE_UNAVAILABLE CONTENT {
        code: "SERVER_DATABASE_UNAVAILABLE",
        module: "server",
        domain: "database",
        category: "dependency",
        severity: "error",
        message: "Database is unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Base de données indisponible",
                description: "La connexion à SurrealDB ou sa sonde a échoué.",
                resolution: "Vérifier l'adresse, les identifiants et la disponibilité de SurrealDB."
            },
            en: {
                label: "Database unavailable",
                description: "Database is unavailable.",
                resolution: "Check the SurrealDB address, credentials and availability."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_MODULE_INSTALL_FAILED) THEN (
    CREATE error_definition:SERVER_MODULE_INSTALL_FAILED CONTENT {
        code: "SERVER_MODULE_INSTALL_FAILED",
        module: "server",
        domain: "modules",
        category: "internal",
        severity: "error",
        message: "A hosted module could not be installed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Installation d'un module impossible",
                description: "Le manifeste d'un module hébergé est invalide ou son installation par le runtime a échoué.",
                resolution: "Corriger le module indiqué dans le journal puis redémarrer."
            },
            en: {
                label: "Module installation failed",
                description: "A hosted module could not be installed.",
                resolution: "Fix the module named in the log, then restart."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_BIND_FAILED) THEN (
    CREATE error_definition:SERVER_BIND_FAILED CONTENT {
        code: "SERVER_BIND_FAILED",
        module: "server",
        domain: "http",
        category: "internal",
        severity: "error",
        message: "Server address could not be bound",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse d'écoute indisponible",
                description: "Le serveur n'a pas pu ouvrir son adresse d'écoute.",
                resolution: "Vérifier server.host et server.port, et qu'aucun autre processus n'utilise le port."
            },
            en: {
                label: "Address unavailable",
                description: "Server address could not be bound.",
                resolution: "Check server.host and server.port and that no other process uses the port."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_HTTP_SERVE_FAILED) THEN (
    CREATE error_definition:SERVER_HTTP_SERVE_FAILED CONTENT {
        code: "SERVER_HTTP_SERVE_FAILED",
        module: "server",
        domain: "http",
        category: "internal",
        severity: "error",
        message: "HTTP server stopped on an error",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Arrêt du serveur HTTP sur erreur",
                description: "Le serveur HTTP s'est arrêté sur une erreur d'entrée-sortie.",
                resolution: "Consulter le journal."
            },
            en: {
                label: "HTTP server failed",
                description: "HTTP server stopped on an error.",
                resolution: "Check the log."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_SHUTDOWN_SIGNAL_FAILED) THEN (
    CREATE error_definition:SERVER_SHUTDOWN_SIGNAL_FAILED CONTENT {
        code: "SERVER_SHUTDOWN_SIGNAL_FAILED",
        module: "server",
        domain: "shutdown",
        category: "internal",
        severity: "error",
        message: "Shutdown signal handler could not be installed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Signal d'arrêt indisponible",
                description: "Le serveur n'a pas pu écouter SIGINT ou SIGTERM.",
                resolution: "Consulter le journal."
            },
            en: {
                label: "Shutdown signal unavailable",
                description: "Shutdown signal handler could not be installed.",
                resolution: "Check the log."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_TELEMETRY_INIT_FAILED) THEN (
    CREATE error_definition:SERVER_TELEMETRY_INIT_FAILED CONTENT {
        code: "SERVER_TELEMETRY_INIT_FAILED",
        module: "server",
        domain: "telemetry",
        category: "internal",
        severity: "error",
        message: "Logging could not be initialized",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Journalisation non initialisée",
                description: "Le filtre ou l'abonné de journalisation n'a pas pu être installé.",
                resolution: "Corriger observability.log_filter."
            },
            en: {
                label: "Logging not initialized",
                description: "Logging could not be initialized.",
                resolution: "Fix observability.log_filter."
            }
        }
    }
) END;

IF !record::exists(error_definition:SERVER_AUTH_DISABLED) THEN (
    CREATE error_definition:SERVER_AUTH_DISABLED CONTENT {
        code: "SERVER_AUTH_DISABLED",
        module: "server",
        domain: "auth",
        category: "dependency",
        severity: "error",
        message: "Authentication is disabled on this server",
        default_language: "fr",
        http_status: 503,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Authentification désactivée",
                description: "Le serveur n'a pas de clé applicative (LYXAL__CRYPTO__APPLICATION_KEY) ou d'adresse publique (auth.public_url) : la connexion est indisponible.",
                resolution: "Renseigner la clé applicative et auth.public_url, puis redémarrer."
            },
            en: {
                label: "Authentication disabled",
                description: "The server has no application key or public address: sign-in is unavailable.",
                resolution: "Set the application key and auth.public_url, then restart."
            }
        }
    }
) END;
