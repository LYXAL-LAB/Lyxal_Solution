-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème sessions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_SESSION_REQUIRED) THEN (
    CREATE error_definition:AUTH_SESSION_REQUIRED CONTENT {
        code: "AUTH_SESSION_REQUIRED",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Session required",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Session requise",
                description: "Aucune session Lyxal valide n'est associée à l'appel.",
                resolution: "Connectez-vous."
            },
            en: {
                label: "Session required",
                description: "No valid Lyxal session is attached to the call.",
                resolution: "Sign in."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SESSION_REVOKED) THEN (
    CREATE error_definition:AUTH_SESSION_REVOKED CONTENT {
        code: "AUTH_SESSION_REVOKED",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Session revoked",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Session révoquée",
                description: "La session a été révoquée.",
                resolution: "Connectez-vous à nouveau."
            },
            en: {
                label: "Session revoked",
                description: "The session has been revoked.",
                resolution: "Sign in again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SESSION_EXPIRED) THEN (
    CREATE error_definition:AUTH_SESSION_EXPIRED CONTENT {
        code: "AUTH_SESSION_EXPIRED",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Session expired",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Session expirée",
                description: "La session a expiré.",
                resolution: "Connectez-vous à nouveau."
            },
            en: {
                label: "Session expired",
                description: "The session has expired.",
                resolution: "Sign in again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SESSION_STALE) THEN (
    CREATE error_definition:AUTH_SESSION_STALE CONTENT {
        code: "AUTH_SESSION_STALE",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Rights changed",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Droits à renouveler",
                description: "Les droits de l'identité ont changé depuis l'émission du jeton.",
                resolution: "Renouvelez la session."
            },
            en: {
                label: "Rights changed",
                description: "The identity's rights changed since the token was issued.",
                resolution: "Refresh the session."
            }
        }
    }
) END;
