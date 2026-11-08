-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème applications
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_APPLICATION_NOT_FOUND) THEN (
    CREATE error_definition:AUTH_APPLICATION_NOT_FOUND CONTENT {
        code: "AUTH_APPLICATION_NOT_FOUND",
        module: "auth",
        domain: "applications",
        category: "not_found",
        severity: "error",
        message: "Application not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Application introuvable",
                description: "Cette application n'existe pas ou n'est pas visible.",
                resolution: "Vérifiez l'identifiant."
            },
            en: {
                label: "Application not found",
                description: "This application does not exist or is not visible.",
                resolution: "Check the identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APPLICATION_INACTIVE) THEN (
    CREATE error_definition:AUTH_APPLICATION_INACTIVE CONTENT {
        code: "AUTH_APPLICATION_INACTIVE",
        module: "auth",
        domain: "applications",
        category: "authorization",
        severity: "error",
        message: "Application inactive",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Application désactivée",
                description: "Cette application est désactivée.",
                resolution: "Réactivez l'application."
            },
            en: {
                label: "Application disabled",
                description: "This application is disabled.",
                resolution: "Re-enable the application."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_CLIENT_CREDENTIALS_INVALID) THEN (
    CREATE error_definition:AUTH_CLIENT_CREDENTIALS_INVALID CONTENT {
        code: "AUTH_CLIENT_CREDENTIALS_INVALID",
        module: "auth",
        domain: "applications",
        category: "authentication",
        severity: "error",
        message: "Invalid client credentials",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiants client incorrects",
                description: "L'identifiant client ou le secret est incorrect, révoqué ou expiré.",
                resolution: "Vérifiez l'identifiant client et le secret."
            },
            en: {
                label: "Invalid client credentials",
                description: "The client identifier or secret is incorrect, revoked or expired.",
                resolution: "Check the client identifier and secret."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_API_KEY_INVALID) THEN (
    CREATE error_definition:AUTH_API_KEY_INVALID CONTENT {
        code: "AUTH_API_KEY_INVALID",
        module: "auth",
        domain: "applications",
        category: "authentication",
        severity: "error",
        message: "Invalid API key",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé d'API invalide",
                description: "La clé d'API est incorrecte ou révoquée.",
                resolution: "Créez une nouvelle clé."
            },
            en: {
                label: "Invalid API key",
                description: "The API key is incorrect or revoked.",
                resolution: "Create a new key."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_API_KEY_EXPIRED) THEN (
    CREATE error_definition:AUTH_API_KEY_EXPIRED CONTENT {
        code: "AUTH_API_KEY_EXPIRED",
        module: "auth",
        domain: "applications",
        category: "authentication",
        severity: "error",
        message: "API key expired",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé d'API expirée",
                description: "La clé d'API a expiré.",
                resolution: "Créez une nouvelle clé."
            },
            en: {
                label: "API key expired",
                description: "The API key has expired.",
                resolution: "Create a new key."
            }
        }
    }
) END;
