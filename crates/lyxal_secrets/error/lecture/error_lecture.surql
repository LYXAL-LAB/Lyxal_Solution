-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème lecture
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_REVEAL_FORBIDDEN) THEN (
    CREATE error_definition:SECRETS_REVEAL_FORBIDDEN CONTENT {
        code: "SECRETS_REVEAL_FORBIDDEN",
        module: "secrets",
        domain: "lecture",
        category: "authorization",
        severity: "error",
        message: "Value cannot be revealed",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Valeur non révélable",
                description: "Ce secret est en visibilité restreinte : seuls les programmes autorisés lisent sa valeur.",
                resolution: "Utilisez le secret depuis un programme autorisé, ou faites-le déclarer révélable par un administrateur."
            },
            en: {
                label: "Value cannot be revealed",
                description: "This secret has restricted visibility: only authorized programs read its value.",
                resolution: "Use the secret from an authorized program, or have an administrator declare it revealable."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_CONSUMER_NOT_ALLOWED) THEN (
    CREATE error_definition:SECRETS_CONSUMER_NOT_ALLOWED CONTENT {
        code: "SECRETS_CONSUMER_NOT_ALLOWED",
        module: "secrets",
        domain: "lecture",
        category: "authorization",
        severity: "error",
        message: "Consumer not allowed",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Consommateur non prévu",
                description: "Ce programme ne figure pas parmi les consommateurs prévus du secret (détail : consumer).",
                resolution: "Ajoutez le programme aux consommateurs du secret si son accès est voulu."
            },
            en: {
                label: "Consumer not allowed",
                description: "This program is not one of the secret's intended consumers (detail: consumer).",
                resolution: "Add the program to the secret consumers if its access is intended."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_READ_TICKET_INVALID) THEN (
    CREATE error_definition:SECRETS_READ_TICKET_INVALID CONTENT {
        code: "SECRETS_READ_TICKET_INVALID",
        module: "secrets",
        domain: "lecture",
        category: "conflict",
        severity: "error",
        message: "Invalid read ticket",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Ticket de lecture invalide",
                description: "Le ticket de lecture est inconnu, déjà utilisé, expiré, ou le secret n'est plus lisible.",
                resolution: "Ouvrez une nouvelle lecture."
            },
            en: {
                label: "Invalid read ticket",
                description: "The read ticket is unknown, already used, expired, or the secret can no longer be read.",
                resolution: "Start a new read."
            }
        }
    }
) END;
