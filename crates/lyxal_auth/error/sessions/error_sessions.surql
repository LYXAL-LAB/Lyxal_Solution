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

IF !record::exists(error_definition:AUTH_REFRESH_INVALID) THEN (
    CREATE error_definition:AUTH_REFRESH_INVALID CONTENT {
        code: "AUTH_REFRESH_INVALID",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Invalid refresh token",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Session à renouveler",
                description: "Le jeton de renouvellement est invalide ou expiré.",
                resolution: "Reconnectez-vous."
            },
            en: {
                label: "Invalid refresh token",
                description: "The refresh token is invalid or expired.",
                resolution: "Sign in again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_REFRESH_REUSED) THEN (
    CREATE error_definition:AUTH_REFRESH_REUSED CONTENT {
        code: "AUTH_REFRESH_REUSED",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Refresh token reused",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Session interrompue par sécurité",
                description: "Un jeton de renouvellement déjà utilisé a été présenté : la session a été fermée par sécurité.",
                resolution: "Reconnectez-vous ; changez votre mot de passe si vous n'êtes pas à l'origine de cette alerte."
            },
            en: {
                label: "Session stopped for security",
                description: "An already used refresh token was presented: the session was closed for security.",
                resolution: "Sign in again; change your password if you did not cause this alert."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SIGNING_KEY_UNAVAILABLE) THEN (
    CREATE error_definition:AUTH_SIGNING_KEY_UNAVAILABLE CONTENT {
        code: "AUTH_SIGNING_KEY_UNAVAILABLE",
        module: "auth",
        domain: "sessions",
        category: "internal",
        severity: "error",
        message: "Signing key unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de signature indisponible",
                description: "Aucune clé de signature active : les jetons ne peuvent pas être émis.",
                resolution: "Vérifiez la clé applicative de l'hôte."
            },
            en: {
                label: "Signing key unavailable",
                description: "No active signing key: tokens cannot be issued.",
                resolution: "Check the host application key."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SIGNING_KEY_ROTATION_TOO_SOON) THEN (
    CREATE error_definition:AUTH_SIGNING_KEY_ROTATION_TOO_SOON CONTENT {
        code: "AUTH_SIGNING_KEY_ROTATION_TOO_SOON",
        module: "auth",
        domain: "sessions",
        category: "conflict",
        severity: "error",
        message: "Signing key rotation too soon",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Changement de clé trop rapproché",
                description: "Des jetons signés avec la clé à remplacer peuvent encore être valides.",
                resolution: "Attendez la date indiquée ou forcez le remplacement en cas de clé compromise."
            },
            en: {
                label: "Key rotation too soon",
                description: "Tokens signed with the key to replace may still be valid.",
                resolution: "Wait until the given date, or force the replacement if the key is compromised."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_AAL_INSUFFICIENT) THEN (
    CREATE error_definition:AUTH_AAL_INSUFFICIENT CONTENT {
        code: "AUTH_AAL_INSUFFICIENT",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Assurance level insufficient",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Second facteur requis",
                description: "Cette action demande une session confirmée par un second facteur.",
                resolution: "Confirmez votre identité avec un second facteur, puis réessayez."
            },
            en: {
                label: "Second factor required",
                description: "This action requires a session confirmed with a second factor.",
                resolution: "Confirm your identity with a second factor, then try again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_REAUTHENTICATION_REQUIRED) THEN (
    CREATE error_definition:AUTH_REAUTHENTICATION_REQUIRED CONTENT {
        code: "AUTH_REAUTHENTICATION_REQUIRED",
        module: "auth",
        domain: "sessions",
        category: "authentication",
        severity: "error",
        message: "Reauthentication required",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Confirmation requise",
                description: "Cette action sensible demande une authentification récente.",
                resolution: "Confirmez votre identité, puis réessayez."
            },
            en: {
                label: "Confirmation required",
                description: "This sensitive action requires a recent authentication.",
                resolution: "Confirm your identity, then try again."
            }
        }
    }
) END;
