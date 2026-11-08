-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème file d'envoi et SMTP
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_JOB_CLAIM_LOST) THEN (
    CREATE error_definition:NOTIFICATION_JOB_CLAIM_LOST CONTENT {
        code: "NOTIFICATION_JOB_CLAIM_LOST",
        module: "notification",
        domain: "envoi",
        category: "conflict",
        severity: "error",
        message: "Job claim lost",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Réservation perdue",
                description: "L'étape n'est plus réservée par ce jeton (réservation expirée et reprise par un autre worker).",
                resolution: "Aucune action : l'autre worker termine l'envoi."
            },
            en: {
                label: "Job claim lost",
                description: "The step is no longer claimed with this token (claim expired and taken by another worker).",
                resolution: "No action: the other worker completes the delivery."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_JOB_LEASE_EXPIRED) THEN (
    CREATE error_definition:NOTIFICATION_JOB_LEASE_EXPIRED CONTENT {
        code: "NOTIFICATION_JOB_LEASE_EXPIRED",
        module: "notification",
        domain: "envoi",
        category: "timeout",
        severity: "error",
        message: "Job lease expired",
        default_language: "fr",
        http_status: 504,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Réservation expirée",
                description: "La réservation de la dernière tentative a expiré sans résultat (worker arrêté pendant l'envoi).",
                resolution: "Vérifiez l'état du worker d'envoi et du serveur SMTP."
            },
            en: {
                label: "Job lease expired",
                description: "The claim of the last attempt expired without a result (worker stopped during delivery).",
                resolution: "Check the delivery worker and the SMTP server."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_RUN_EXPIRED) THEN (
    CREATE error_definition:NOTIFICATION_RUN_EXPIRED CONTENT {
        code: "NOTIFICATION_RUN_EXPIRED",
        module: "notification",
        domain: "envoi",
        category: "business",
        severity: "error",
        message: "Run expired",
        default_language: "fr",
        http_status: 410,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Déclenchement expiré",
                description: "Le code ou le lien a expiré avant l'envoi ; le message n'est pas envoyé en retard.",
                resolution: "Demandez un nouveau code ou lien."
            },
            en: {
                label: "Run expired",
                description: "The code or link expired before delivery; the message is not sent late.",
                resolution: "Request a new code or link."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SECRET_UNAVAILABLE) THEN (
    CREATE error_definition:NOTIFICATION_SECRET_UNAVAILABLE CONTENT {
        code: "NOTIFICATION_SECRET_UNAVAILABLE",
        module: "notification",
        domain: "envoi",
        category: "internal",
        severity: "error",
        message: "Secret unavailable",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret illisible",
                description: "Le secret scellé du message ne peut pas être ouvert (clé absente, contexte différent ou enveloppe altérée).",
                resolution: "Vérifiez la clé applicative de l'hôte."
            },
            en: {
                label: "Secret unavailable",
                description: "The sealed secret cannot be opened (missing key, different context or altered envelope).",
                resolution: "Check the host application key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_RENDER_FAILED) THEN (
    CREATE error_definition:NOTIFICATION_RENDER_FAILED CONTENT {
        code: "NOTIFICATION_RENDER_FAILED",
        module: "notification",
        domain: "envoi",
        category: "validation",
        severity: "error",
        message: "Render failed",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rendu impossible",
                description: "Le gabarit n'a pas pu être rendu (syntaxe, variable inconnue ou budget dépassé).",
                resolution: "Corrigez le gabarit puis relancez le parcours."
            },
            en: {
                label: "Render failed",
                description: "The template could not be rendered (syntax, unknown variable or budget exceeded).",
                resolution: "Fix the template then trigger the workflow again."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SMTP_TRANSIENT) THEN (
    CREATE error_definition:NOTIFICATION_SMTP_TRANSIENT CONTENT {
        code: "NOTIFICATION_SMTP_TRANSIENT",
        module: "notification",
        domain: "envoi",
        category: "network",
        severity: "error",
        message: "SMTP transient failure",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Échec temporaire du serveur SMTP",
                description: "Le serveur SMTP est injoignable ou a répondu par un refus temporaire (4xx).",
                resolution: "Aucune action : l'envoi est retenté automatiquement."
            },
            en: {
                label: "Temporary SMTP failure",
                description: "The SMTP server is unreachable or answered with a temporary refusal (4xx).",
                resolution: "No action: delivery is retried automatically."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SMTP_PERMANENT) THEN (
    CREATE error_definition:NOTIFICATION_SMTP_PERMANENT CONTENT {
        code: "NOTIFICATION_SMTP_PERMANENT",
        module: "notification",
        domain: "envoi",
        category: "dependency",
        severity: "error",
        message: "SMTP permanent failure",
        default_language: "fr",
        http_status: 502,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Refus définitif du serveur SMTP",
                description: "Le serveur SMTP a refusé définitivement le message (5xx).",
                resolution: "Vérifiez la configuration SMTP et le message."
            },
            en: {
                label: "Permanent SMTP failure",
                description: "The SMTP server permanently refused the message (5xx).",
                resolution: "Check the SMTP configuration and the message."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SMTP_RECIPIENT_REJECTED) THEN (
    CREATE error_definition:NOTIFICATION_SMTP_RECIPIENT_REJECTED CONTENT {
        code: "NOTIFICATION_SMTP_RECIPIENT_REJECTED",
        module: "notification",
        domain: "envoi",
        category: "business",
        severity: "error",
        message: "SMTP recipient rejected",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Destinataire refusé",
                description: "Le serveur SMTP a refusé l'adresse du destinataire (550, 551, 553) ; elle est ajoutée à la liste de suppression.",
                resolution: "Corrigez l'adresse puis retirez-la de la liste de suppression."
            },
            en: {
                label: "Recipient rejected",
                description: "The SMTP server refused the recipient address (550, 551, 553); it is added to the suppression list.",
                resolution: "Fix the address then remove it from the suppression list."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SMTP_NOT_CONFIGURED) THEN (
    CREATE error_definition:NOTIFICATION_SMTP_NOT_CONFIGURED CONTENT {
        code: "NOTIFICATION_SMTP_NOT_CONFIGURED",
        module: "notification",
        domain: "envoi",
        category: "dependency",
        severity: "error",
        message: "SMTP not configured",
        default_language: "fr",
        http_status: 503,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Serveur SMTP non configuré",
                description: "L'hôte n'a pas de configuration SMTP ou de clé applicative : aucun e-mail n'est envoyé.",
                resolution: "Renseignez la configuration notification.smtp et la clé applicative de l'hôte."
            },
            en: {
                label: "SMTP not configured",
                description: "The host has no SMTP configuration or application key: no email is sent.",
                resolution: "Set the notification.smtp configuration and the host application key."
            }
        }
    }
) END;
