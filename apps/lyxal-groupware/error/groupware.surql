-- ============================================================================
-- MASTER DATA : définitions d'erreurs de l'hôte lyxal-groupware
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- Vérifiées contre le catalogue Rust (src/error.rs) par un test.
-- ============================================================================

IF !record::exists(error_definition:GROUPWARE_CONFIGURATION_INVALID) THEN (
    CREATE error_definition:GROUPWARE_CONFIGURATION_INVALID CONTENT {
        code: "GROUPWARE_CONFIGURATION_INVALID",
        module: "groupware",
        domain: "configuration",
        category: "internal",
        severity: "error",
        message: "Groupware host configuration is invalid",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Configuration de l'hôte groupware invalide",
                description: "La configuration chargée (fichiers et variables LYXAL_GROUPWARE__*) est absente, illisible ou incohérente : écoutes, limites, délais ou base.",
                resolution: "Corriger la configuration selon le détail du journal."
            },
            en: {
                label: "Invalid groupware host configuration",
                description: "Groupware host configuration is invalid.",
                resolution: "Fix the configuration according to the log detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:GROUPWARE_DATABASE_UNAVAILABLE) THEN (
    CREATE error_definition:GROUPWARE_DATABASE_UNAVAILABLE CONTENT {
        code: "GROUPWARE_DATABASE_UNAVAILABLE",
        module: "groupware",
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

IF !record::exists(error_definition:GROUPWARE_MODULE_INSTALL_FAILED) THEN (
    CREATE error_definition:GROUPWARE_MODULE_INSTALL_FAILED CONTENT {
        code: "GROUPWARE_MODULE_INSTALL_FAILED",
        module: "groupware",
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

IF !record::exists(error_definition:GROUPWARE_BIND_FAILED) THEN (
    CREATE error_definition:GROUPWARE_BIND_FAILED CONTENT {
        code: "GROUPWARE_BIND_FAILED",
        module: "groupware",
        domain: "network",
        category: "internal",
        severity: "error",
        message: "A listening address could not be bound",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse d'écoute indisponible",
                description: "L'hôte n'a pas pu ouvrir une adresse d'écoute (port de courrier ou port HTTP de santé).",
                resolution: "Vérifier listeners[].bind et http.bind, qu'aucun autre processus n'utilise le port et, pour un port inférieur à 1024, la capacité CAP_NET_BIND_SERVICE."
            },
            en: {
                label: "Address unavailable",
                description: "A listening address could not be bound.",
                resolution: "Check listeners[].bind and http.bind, that no other process uses the port and, below port 1024, the CAP_NET_BIND_SERVICE capability."
            }
        }
    }
) END;

IF !record::exists(error_definition:GROUPWARE_TLS_CERTIFICATE_INVALID) THEN (
    CREATE error_definition:GROUPWARE_TLS_CERTIFICATE_INVALID CONTENT {
        code: "GROUPWARE_TLS_CERTIFICATE_INVALID",
        module: "groupware",
        domain: "tls",
        category: "internal",
        severity: "error",
        message: "A TLS certificate could not be loaded",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Certificat TLS invalide",
                description: "Un certificat déclaré dans la section [tls] est illisible, invalide, ne couvre pas le nom pour lequel il est déclaré ou ne correspond pas à sa clé, ou bien le fichier de clé est lisible par le groupe ou les autres comptes. Au démarrage, l'hôte s'arrête ; au rechargement, l'ancien certificat reste en service et la santé passe à « dégradé ».",
                resolution: "Corriger le fichier indiqué dans le journal (chaîne PEM, clé non chiffrée, droits 0600 sur la clé) ; il est relu automatiquement."
            },
            en: {
                label: "Invalid TLS certificate",
                description: "A TLS certificate could not be loaded.",
                resolution: "Fix the file named in the log (PEM chain, unencrypted key, mode 0600 on the key); it is reloaded automatically."
            }
        }
    }
) END;

IF !record::exists(error_definition:GROUPWARE_MASTER_KEY_MISSING) THEN (
    CREATE error_definition:GROUPWARE_MASTER_KEY_MISSING CONTENT {
        code: "GROUPWARE_MASTER_KEY_MISSING",
        module: "groupware",
        domain: "secrets",
        category: "internal",
        severity: "error",
        message: "An encrypted bucket exists: the vault master key is required",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé maîtresse du coffre-fort absente",
                description: "Un bucket chiffré existe dans la base (le courrier en crée un par organisation), mais aucune clé maîtresse du coffre-fort n'est configurée : ses fichiers ne pourraient être ni écrits ni lus. L'hôte s'arrête après l'installation des modules, sans rien démarrer.",
                resolution: "Fournir la clé maîtresse de lyxal-server : variable LYXAL_GROUPWARE__SECRETS__MASTER_KEY (même valeur que LYXAL__SECRETS__MASTER_KEY) et secrets.master_key_id."
            },
            en: {
                label: "Vault master key missing",
                description: "An encrypted bucket exists: the vault master key is required.",
                resolution: "Provide the lyxal-server master key: LYXAL_GROUPWARE__SECRETS__MASTER_KEY (same value as LYXAL__SECRETS__MASTER_KEY) and secrets.master_key_id."
            }
        }
    }
) END;

IF !record::exists(error_definition:GROUPWARE_SHUTDOWN_SIGNAL_FAILED) THEN (
    CREATE error_definition:GROUPWARE_SHUTDOWN_SIGNAL_FAILED CONTENT {
        code: "GROUPWARE_SHUTDOWN_SIGNAL_FAILED",
        module: "groupware",
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
                description: "L'hôte n'a pas pu écouter SIGINT ou SIGTERM.",
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

IF !record::exists(error_definition:GROUPWARE_TELEMETRY_INIT_FAILED) THEN (
    CREATE error_definition:GROUPWARE_TELEMETRY_INIT_FAILED CONTENT {
        code: "GROUPWARE_TELEMETRY_INIT_FAILED",
        module: "groupware",
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
