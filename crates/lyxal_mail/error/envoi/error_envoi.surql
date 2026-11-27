-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème envoi
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_SENDER_FORBIDDEN) THEN (
    CREATE error_definition:MAIL_SENDER_FORBIDDEN CONTENT {
        code: "MAIL_SENDER_FORBIDDEN",
        module: "mail",
        domain: "envoi",
        category: "authorization",
        severity: "error",
        message: "Sender address not allowed",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse d'expéditeur interdite",
                description: "Le compte ou le module ne peut pas envoyer sous cette adresse.",
                resolution: "Utilisez une adresse de votre compte, ou un alias qui vous autorise à écrire en son nom."
            },
            en: {
                label: "Sender address not allowed",
                description: "The account or module cannot send under this address.",
                resolution: "Use an address of your account, or an alias that allows you to write on its behalf."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_SEND_LIMIT_EXCEEDED) THEN (
    CREATE error_definition:MAIL_SEND_LIMIT_EXCEEDED CONTENT {
        code: "MAIL_SEND_LIMIT_EXCEEDED",
        module: "mail",
        domain: "envoi",
        category: "rate_limit",
        severity: "error",
        message: "Sending limit reached",
        default_language: "fr",
        http_status: 429,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Limite d'envoi atteinte",
                description: "La limite d'envoi du compte, des modules ou des transferts de l'organisation est atteinte.",
                resolution: "Réessayez plus tard, ou demandez à l'administrateur de relever la limite."
            },
            en: {
                label: "Sending limit reached",
                description: "The sending limit of the account, of the modules or of the organization forwards is reached.",
                resolution: "Try again later, or ask the administrator to raise the limit."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_SUBMISSION_TOO_MANY_RECIPIENTS) THEN (
    CREATE error_definition:MAIL_SUBMISSION_TOO_MANY_RECIPIENTS CONTENT {
        code: "MAIL_SUBMISSION_TOO_MANY_RECIPIENTS",
        module: "mail",
        domain: "envoi",
        category: "validation",
        severity: "error",
        message: "Too many recipients",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trop de destinataires",
                description: "Le message a plus de destinataires que la limite de l'organisation.",
                resolution: "Envoyez le message en plusieurs fois."
            },
            en: {
                label: "Too many recipients",
                description: "The message has more recipients than the organization limit.",
                resolution: "Send the message in several parts."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_SUBMISSION_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_SUBMISSION_NOT_FOUND CONTENT {
        code: "MAIL_SUBMISSION_NOT_FOUND",
        module: "mail",
        domain: "envoi",
        category: "not_found",
        severity: "error",
        message: "Submission not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Envoi introuvable",
                description: "Cet envoi n'existe pas ou n'est pas visible.",
                resolution: "Vérifiez l'identifiant de l'envoi."
            },
            en: {
                label: "Submission not found",
                description: "This submission does not exist or is not visible.",
                resolution: "Check the submission identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_SUBMISSION_STATE_INVALID) THEN (
    CREATE error_definition:MAIL_SUBMISSION_STATE_INVALID CONTENT {
        code: "MAIL_SUBMISSION_STATE_INVALID",
        module: "mail",
        domain: "envoi",
        category: "conflict",
        severity: "error",
        message: "Submission state does not allow this operation",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État de l'envoi incompatible",
                description: "L'opération ne peut pas être faite dans l'état actuel de l'envoi.",
                resolution: "Relisez l'envoi avant de recommencer."
            },
            en: {
                label: "Submission state does not allow this operation",
                description: "The operation cannot be done in the current state of the submission.",
                resolution: "Read the submission again before retrying."
            }
        }
    }
) END;
