-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème fil (messages dans
-- l'application, canal in_app, décisions F1 à F8)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_FEED_ITEM_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_FEED_ITEM_NOT_FOUND CONTENT {
        code: "NOTIFICATION_FEED_ITEM_NOT_FOUND",
        module: "notification",
        domain: "fil",
        category: "not_found",
        severity: "error",
        message: "Feed item not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Message introuvable",
                description: "Ce message n'existe pas dans votre fil (il a pu être supprimé ou purgé).",
                resolution: "Rechargez votre fil de notifications."
            },
            en: {
                label: "Message not found",
                description: "This message is not in your feed (it may have been deleted or purged).",
                resolution: "Reload your notification feed."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_FEED_ACTION_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_FEED_ACTION_INVALID CONTENT {
        code: "NOTIFICATION_FEED_ACTION_INVALID",
        module: "notification",
        domain: "fil",
        category: "validation",
        severity: "error",
        message: "Feed action not available",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bouton absent",
                description: "Ce message n'a pas le bouton demandé.",
                resolution: "Utilisez un bouton affiché sur le message (principal ou secondaire)."
            },
            en: {
                label: "Button not available",
                description: "This message does not have the requested button.",
                resolution: "Use a button shown on the message (primary or secondary)."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SNOOZE_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_SNOOZE_INVALID CONTENT {
        code: "NOTIFICATION_SNOOZE_INVALID",
        module: "notification",
        domain: "fil",
        category: "validation",
        severity: "error",
        message: "Invalid snooze duration",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Durée de mise en sommeil refusée",
                description: "Un message se met en sommeil de 3 minutes à 90 jours.",
                resolution: "Choisissez une fin de sommeil entre 3 minutes et 90 jours à partir de maintenant."
            },
            en: {
                label: "Snooze duration refused",
                description: "A message can be snoozed from 3 minutes to 90 days.",
                resolution: "Choose a snooze end between 3 minutes and 90 days from now."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_FEED_NO_ACCOUNT) THEN (
    CREATE error_definition:NOTIFICATION_FEED_NO_ACCOUNT CONTENT {
        code: "NOTIFICATION_FEED_NO_ACCOUNT",
        module: "notification",
        domain: "fil",
        category: "authorization",
        severity: "error",
        message: "No notification feed for this session",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Aucun fil de notifications",
                description: "Le fil est réservé à une personne connectée avec son compte ; cette session n'a pas de compte, ou aucun message ne lui a encore été adressé dans cette organisation.",
                resolution: "Connectez-vous avec votre compte personnel, dans l'organisation voulue."
            },
            en: {
                label: "No notification feed",
                description: "The feed is reserved to a person signed in with their account; this session has no account, or no message has been sent to it yet in this organization.",
                resolution: "Sign in with your personal account, in the intended organization."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_FEED_STREAM_LIMIT) THEN (
    CREATE error_definition:NOTIFICATION_FEED_STREAM_LIMIT CONTENT {
        code: "NOTIFICATION_FEED_STREAM_LIMIT",
        module: "notification",
        domain: "fil",
        category: "rate_limit",
        severity: "warning",
        message: "Too many open feed streams",
        default_language: "fr",
        http_status: 429,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Trop de fils ouverts",
                description: "Une personne garde au plus 5 flux du fil ouverts en même temps (onglets, appareils).",
                resolution: "Fermez un onglet ou un appareil ouvert sur l'application, puis réessayez."
            },
            en: {
                label: "Too many open feeds",
                description: "A person keeps at most 5 feed streams open at the same time (tabs, devices).",
                resolution: "Close a tab or a device open on the application, then try again."
            }
        }
    }
) END;
