-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème mfa (seconds facteurs)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_MFA_REQUIRED) THEN (
    CREATE error_definition:AUTH_MFA_REQUIRED CONTENT {
        code: "AUTH_MFA_REQUIRED",
        module: "auth",
        domain: "mfa",
        category: "authentication",
        severity: "error",
        message: "Second factor required",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Second facteur requis",
                description: "Cette connexion ou cette action demande un second facteur.",
                resolution: "Présentez un code de votre application d'authentification, une passkey ou un code de secours."
            },
            en: {
                label: "Second factor required",
                description: "This sign-in or action requires a second factor.",
                resolution: "Provide a code from your authenticator app, a passkey or a recovery code."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_MFA_INVALID) THEN (
    CREATE error_definition:AUTH_MFA_INVALID CONTENT {
        code: "AUTH_MFA_INVALID",
        module: "auth",
        domain: "mfa",
        category: "authentication",
        severity: "error",
        message: "Second factor invalid",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Second facteur invalide",
                description: "Le second facteur présenté n'a pas pu être vérifié.",
                resolution: "Réessayez avec un nouveau code ou un autre moyen."
            },
            en: {
                label: "Second factor invalid",
                description: "The second factor provided could not be verified.",
                resolution: "Try again with a new code or another method."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_MFA_NOT_ENROLLED) THEN (
    CREATE error_definition:AUTH_MFA_NOT_ENROLLED CONTENT {
        code: "AUTH_MFA_NOT_ENROLLED",
        module: "auth",
        domain: "mfa",
        category: "not_found",
        severity: "error",
        message: "Second factor not enrolled",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Second facteur absent",
                description: "Ce moyen de second facteur n'est pas configuré.",
                resolution: "Configurez-le d'abord dans vos paramètres de sécurité."
            },
            en: {
                label: "Second factor not enrolled",
                description: "This second-factor method is not set up.",
                resolution: "Set it up first in your security settings."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_MFA_ALREADY_ENROLLED) THEN (
    CREATE error_definition:AUTH_MFA_ALREADY_ENROLLED CONTENT {
        code: "AUTH_MFA_ALREADY_ENROLLED",
        module: "auth",
        domain: "mfa",
        category: "conflict",
        severity: "error",
        message: "Second factor already enrolled",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Second facteur déjà configuré",
                description: "Ce moyen de second facteur est déjà actif.",
                resolution: "Retirez-le avant d'en configurer un nouveau."
            },
            en: {
                label: "Second factor already enrolled",
                description: "This second-factor method is already active.",
                resolution: "Remove it before setting up a new one."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_MFA_METHOD_DISABLED) THEN (
    CREATE error_definition:AUTH_MFA_METHOD_DISABLED CONTENT {
        code: "AUTH_MFA_METHOD_DISABLED",
        module: "auth",
        domain: "mfa",
        category: "business",
        severity: "error",
        message: "Second-factor method disabled",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Méthode désactivée",
                description: "Ce moyen de second facteur n'est pas autorisé par la politique de sécurité.",
                resolution: "Utilisez un autre moyen ou contactez votre administrateur."
            },
            en: {
                label: "Method disabled",
                description: "This second-factor method is not allowed by the security policy.",
                resolution: "Use another method or contact your administrator."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_MFA_LAST_FACTOR) THEN (
    CREATE error_definition:AUTH_MFA_LAST_FACTOR CONTENT {
        code: "AUTH_MFA_LAST_FACTOR",
        module: "auth",
        domain: "mfa",
        category: "business",
        severity: "error",
        message: "Last second factor",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dernier second facteur",
                description: "Le double facteur est exigé : votre dernier second facteur ne peut pas être retiré.",
                resolution: "Ajoutez un autre moyen avant de retirer celui-ci."
            },
            en: {
                label: "Last second factor",
                description: "Two-factor authentication is required: your last second factor cannot be removed.",
                resolution: "Add another method before removing this one."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PASSKEY_INVALID) THEN (
    CREATE error_definition:AUTH_PASSKEY_INVALID CONTENT {
        code: "AUTH_PASSKEY_INVALID",
        module: "auth",
        domain: "mfa",
        category: "authentication",
        severity: "error",
        message: "Passkey invalid",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Passkey invalide",
                description: "La passkey présentée n'a pas pu être vérifiée.",
                resolution: "Réessayez, ou utilisez un autre moyen de connexion."
            },
            en: {
                label: "Passkey invalid",
                description: "The passkey provided could not be verified.",
                resolution: "Try again, or use another sign-in method."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PASSKEY_TAKEN) THEN (
    CREATE error_definition:AUTH_PASSKEY_TAKEN CONTENT {
        code: "AUTH_PASSKEY_TAKEN",
        module: "auth",
        domain: "mfa",
        category: "conflict",
        severity: "error",
        message: "Passkey already registered",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Passkey déjà enregistrée",
                description: "Cette passkey est déjà enregistrée.",
                resolution: "Utilisez une autre passkey."
            },
            en: {
                label: "Passkey already registered",
                description: "This passkey is already registered.",
                resolution: "Use another passkey."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PASSKEY_UNAVAILABLE) THEN (
    CREATE error_definition:AUTH_PASSKEY_UNAVAILABLE CONTENT {
        code: "AUTH_PASSKEY_UNAVAILABLE",
        module: "auth",
        domain: "mfa",
        category: "dependency",
        severity: "error",
        message: "Passkeys unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Passkeys indisponibles",
                description: "Les passkeys ne sont pas configurées sur ce serveur.",
                resolution: "Utilisez un autre moyen ou contactez votre administrateur."
            },
            en: {
                label: "Passkeys unavailable",
                description: "Passkeys are not configured on this server.",
                resolution: "Use another method or contact your administrator."
            }
        }
    }
) END;
