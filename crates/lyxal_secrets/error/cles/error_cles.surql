-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème cles
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_CRYPTO_UNAVAILABLE) THEN (
    CREATE error_definition:SECRETS_CRYPTO_UNAVAILABLE CONTENT {
        code: "SECRETS_CRYPTO_UNAVAILABLE",
        module: "secrets",
        domain: "cles",
        category: "dependency",
        severity: "error",
        message: "Encryption unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Chiffrement indisponible",
                description: "Le serveur n'a pas de clé maîtresse : aucune valeur ne peut être écrite ni lue (les fiches restent consultables).",
                resolution: "Fournissez la clé maîtresse au serveur (variable LYXAL__SECRETS__MASTER_KEY) puis redémarrez-le."
            },
            en: {
                label: "Encryption unavailable",
                description: "The server has no master key: no value can be written or read (records remain readable).",
                resolution: "Provide the master key to the server (LYXAL__SECRETS__MASTER_KEY variable) and restart it."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_VALUE_TOO_LARGE) THEN (
    CREATE error_definition:SECRETS_VALUE_TOO_LARGE CONTENT {
        code: "SECRETS_VALUE_TOO_LARGE",
        module: "secrets",
        domain: "cles",
        category: "validation",
        severity: "error",
        message: "Value too large",
        default_language: "fr",
        http_status: 413,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Valeur trop grande",
                description: "La valeur dépasse la taille maximale permise (détail : max_value_bytes).",
                resolution: "Réduisez la valeur ou demandez l'augmentation du réglage max_value_bytes."
            },
            en: {
                label: "Value too large",
                description: "The value exceeds the maximum allowed size (detail: max_value_bytes).",
                resolution: "Shorten the value or ask for a higher max_value_bytes setting."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_VALUE_CORRUPTED) THEN (
    CREATE error_definition:SECRETS_VALUE_CORRUPTED CONTENT {
        code: "SECRETS_VALUE_CORRUPTED",
        module: "secrets",
        domain: "cles",
        category: "internal",
        severity: "error",
        message: "Value cannot be opened",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Valeur illisible",
                description: "La valeur scellée ne s'ouvre pas : elle a été altérée, ou la clé qui l'a scellée n'est plus disponible.",
                resolution: "Signalez l'incident ; remplacez la valeur par une nouvelle version."
            },
            en: {
                label: "Value cannot be opened",
                description: "The sealed value cannot be opened: it was altered, or the key that sealed it is no longer available.",
                resolution: "Report the incident; replace the value with a new version."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_TENANT_KEY_UNAVAILABLE) THEN (
    CREATE error_definition:SECRETS_TENANT_KEY_UNAVAILABLE CONTENT {
        code: "SECRETS_TENANT_KEY_UNAVAILABLE",
        module: "secrets",
        domain: "cles",
        category: "dependency",
        severity: "error",
        message: "Organization key unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de l'organisation indisponible",
                description: "La clé de chiffrement de l'organisation est introuvable, détruite ou dans un état qui ne permet pas cette opération.",
                resolution: "Signalez l'incident à l'administrateur de la plateforme."
            },
            en: {
                label: "Organization key unavailable",
                description: "The organization encryption key is missing, destroyed or in a state that does not allow this operation.",
                resolution: "Report the incident to the platform administrator."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_TENANT_KEY_CONFLICT) THEN (
    CREATE error_definition:SECRETS_TENANT_KEY_CONFLICT CONTENT {
        code: "SECRETS_TENANT_KEY_CONFLICT",
        module: "secrets",
        domain: "cles",
        category: "conflict",
        severity: "error",
        message: "Organization key conflict",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Conflit de clé d'organisation",
                description: "Une autre opération a changé la clé de l'organisation entre-temps (création, rotation ou rescellement).",
                resolution: "Recommencez l'opération."
            },
            en: {
                label: "Organization key conflict",
                description: "Another operation changed the organization key meanwhile (creation, rotation or reseal).",
                resolution: "Retry the operation."
            }
        }
    }
) END;
