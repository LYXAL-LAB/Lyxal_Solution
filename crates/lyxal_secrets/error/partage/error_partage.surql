-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème partage
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_SHARE_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_SHARE_NOT_FOUND CONTENT {
        code: "SECRETS_SHARE_NOT_FOUND",
        module: "secrets",
        domain: "partage",
        category: "not_found",
        severity: "error",
        message: "Share not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Partage introuvable",
                description: "Ce partage n'existe pas ou n'est pas visible avec vos droits.",
                resolution: "Vérifiez l'identifiant du partage."
            },
            en: {
                label: "Share not found",
                description: "This share does not exist or is not visible with your permissions.",
                resolution: "Check the share identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SHARE_UNAVAILABLE) THEN (
    CREATE error_definition:SECRETS_SHARE_UNAVAILABLE CONTENT {
        code: "SECRETS_SHARE_UNAVAILABLE",
        module: "secrets",
        domain: "partage",
        category: "authorization",
        severity: "error",
        message: "Share unavailable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Partage indisponible",
                description: "Ce lien ne donne rien : il est faux, épuisé, échu, retiré, ou le mot de passe ne correspond pas.",
                resolution: "Demandez un nouveau lien à la personne qui vous l'a envoyé."
            },
            en: {
                label: "Share unavailable",
                description: "This link gives nothing: it is wrong, used up, expired, revoked, or the password does not match.",
                resolution: "Ask the sender for a new link."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SHARE_INVALID) THEN (
    CREATE error_definition:SECRETS_SHARE_INVALID CONTENT {
        code: "SECRETS_SHARE_INVALID",
        module: "secrets",
        domain: "partage",
        category: "validation",
        severity: "error",
        message: "Invalid share",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Partage invalide",
                description: "Le partage demandé n'est pas valable : durée ou nombre d'ouvertures au-delà des réglages, ou source incorrecte.",
                resolution: "Choisissez une durée et un nombre d'ouvertures dans les limites permises."
            },
            en: {
                label: "Invalid share",
                description: "The requested share is not valid: duration or number of openings beyond the settings, or incorrect source.",
                resolution: "Choose a duration and a number of openings within the allowed limits."
            }
        }
    }
) END;
