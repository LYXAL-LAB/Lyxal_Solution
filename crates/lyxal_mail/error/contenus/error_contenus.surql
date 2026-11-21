-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème contenus
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_CONTENT_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_CONTENT_NOT_FOUND CONTENT {
        code: "MAIL_CONTENT_NOT_FOUND",
        module: "mail",
        domain: "contenus",
        category: "not_found",
        severity: "error",
        message: "Message content not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Contenu introuvable",
                description: "Le contenu de ce message n'existe pas ou n'est pas visible de votre session.",
                resolution: "Recommencez le dépôt du message."
            },
            en: {
                label: "Content not found",
                description: "This message content does not exist or is not visible to your session.",
                resolution: "Deposit the message again."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_CONTENT_STATE_INVALID) THEN (
    CREATE error_definition:MAIL_CONTENT_STATE_INVALID CONTENT {
        code: "MAIL_CONTENT_STATE_INVALID",
        module: "mail",
        domain: "contenus",
        category: "conflict",
        severity: "error",
        message: "Message content in an invalid state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Contenu dans un état inattendu",
                description: "Le contenu n'est pas dans l'état attendu pour cette étape du dépôt (délai dépassé, fichier différent, déjà inscrit).",
                resolution: "Recommencez le dépôt du message."
            },
            en: {
                label: "Content in an unexpected state",
                description: "The content is not in the state expected for this step of the deposit (deadline passed, different file, already registered).",
                resolution: "Deposit the message again."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_CONTENT_UNAVAILABLE) THEN (
    CREATE error_definition:MAIL_CONTENT_UNAVAILABLE CONTENT {
        code: "MAIL_CONTENT_UNAVAILABLE",
        module: "mail",
        domain: "contenus",
        category: "dependency",
        severity: "error",
        message: "Message content unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Contenu indisponible",
                description: "Le contenu du message ne peut pas être lu ou écrit pour l'instant (stockage ou clés de chiffrement absents).",
                resolution: "Réessayez dans quelques instants."
            },
            en: {
                label: "Content unavailable",
                description: "The message content cannot be read or written right now (storage or encryption keys missing).",
                resolution: "Try again in a moment."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_CONTENT_CORRUPTED) THEN (
    CREATE error_definition:MAIL_CONTENT_CORRUPTED CONTENT {
        code: "MAIL_CONTENT_CORRUPTED",
        module: "mail",
        domain: "contenus",
        category: "internal",
        severity: "error",
        message: "Message content corrupted",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Contenu altéré",
                description: "Le fichier du message ne correspond plus à ce qui a été enregistré.",
                resolution: "Signalez l'incident à l'administrateur de la plateforme."
            },
            en: {
                label: "Content corrupted",
                description: "The message file no longer matches what was stored.",
                resolution: "Report the incident to the platform administrator."
            }
        }
    }
) END;
