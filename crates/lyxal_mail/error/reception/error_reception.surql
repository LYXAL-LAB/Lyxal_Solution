-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème reception
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================
-- Ces codes ne sont jamais rendus à un serveur expéditeur : la session SMTP les traduit en
-- codes SMTP. Ils servent au journal, aux essais et aux mesures.

IF !record::exists(error_definition:MAIL_DELIVERY_REJECTED) THEN (
    CREATE error_definition:MAIL_DELIVERY_REJECTED CONTENT {
        code: "MAIL_DELIVERY_REJECTED",
        module: "mail",
        domain: "reception",
        category: "business",
        severity: "error",
        message: "Message rejected by the reception policy",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Message refusé",
                description: "Le message est refusé par la politique de réception (authenticité de l'expéditeur, en-tête From absent ou multiple, boucle de courrier).",
                resolution: "L'expéditeur doit corriger son message ou la configuration de son domaine."
            },
            en: {
                label: "Message rejected",
                description: "The message is rejected by the reception policy (sender authenticity, missing or multiple From header, mail loop).",
                resolution: "The sender must fix the message or the configuration of their domain."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MESSAGE_INFECTED) THEN (
    CREATE error_definition:MAIL_MESSAGE_INFECTED CONTENT {
        code: "MAIL_MESSAGE_INFECTED",
        module: "mail",
        domain: "reception",
        category: "business",
        severity: "error",
        message: "Infected message",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Message infecté",
                description: "L'antivirus a trouvé un contenu malveillant : le message n'est pas remis.",
                resolution: "L'expéditeur doit envoyer un message sain."
            },
            en: {
                label: "Infected message",
                description: "The antivirus found malicious content: the message is not delivered.",
                resolution: "The sender must send a clean message."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_SCANNER_UNAVAILABLE) THEN (
    CREATE error_definition:MAIL_SCANNER_UNAVAILABLE CONTENT {
        code: "MAIL_SCANNER_UNAVAILABLE",
        module: "mail",
        domain: "reception",
        category: "dependency",
        severity: "error",
        message: "Antivirus unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Antivirus indisponible",
                description: "L'antivirus configuré ne répond pas : le message n'est pas remis sans analyse.",
                resolution: "Réessayez plus tard ; vérifiez le service antivirus."
            },
            en: {
                label: "Antivirus unavailable",
                description: "The configured antivirus does not answer: the message is not delivered without a scan.",
                resolution: "Try again later; check the antivirus service."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_DELIVERY_BATCH_TOO_LARGE) THEN (
    CREATE error_definition:MAIL_DELIVERY_BATCH_TOO_LARGE CONTENT {
        code: "MAIL_DELIVERY_BATCH_TOO_LARGE",
        module: "mail",
        domain: "reception",
        category: "validation",
        severity: "error",
        message: "Delivery batch too large",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot de remise trop grand",
                description: "Un lot de remise contient 32 messages au plus.",
                resolution: "Remettez les messages en plusieurs lots."
            },
            en: {
                label: "Delivery batch too large",
                description: "A delivery batch holds 32 messages at most.",
                resolution: "Deliver the messages in several batches."
            }
        }
    }
) END;
