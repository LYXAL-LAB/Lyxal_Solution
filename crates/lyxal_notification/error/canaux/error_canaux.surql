-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème canaux (SMS, messageries
-- d'équipe, adresses web, sécurité des appels sortants)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_ENDPOINT_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_ENDPOINT_NOT_FOUND CONTENT {
        code: "NOTIFICATION_ENDPOINT_NOT_FOUND",
        module: "notification",
        domain: "canaux",
        category: "not_found",
        severity: "error",
        message: "Endpoint not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse introuvable",
                description: "Aucune adresse de messagerie ou web n'a cet identifiant pour cet abonné, ou elle n'est pas lisible.",
                resolution: "Vérifiez l'identifiant de l'adresse et l'abonné."
            },
            en: {
                label: "Endpoint not found",
                description: "No chat or web endpoint has this identifier for this subscriber, or it is not readable.",
                resolution: "Check the endpoint identifier and the subscriber."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_ENDPOINT_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_ENDPOINT_INVALID CONTENT {
        code: "NOTIFICATION_ENDPOINT_INVALID",
        module: "notification",
        domain: "canaux",
        category: "validation",
        severity: "error",
        message: "Invalid endpoint",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse refusée",
                description: "L'adresse n'est pas une adresse HTTPS du service choisi, son hôte n'est pas autorisé, l'identifiant du salon Telegram est invalide, la valeur n'est pas scellée, ou l'abonné a déjà le nombre maximal d'adresses pour ce canal.",
                resolution: "Donnez l'adresse HTTPS fournie par le service (hôte officiel), passez par la route de l'hôte qui la scelle, ou retirez une adresse existante."
            },
            en: {
                label: "Endpoint refused",
                description: "The address is not an HTTPS address of the chosen service, its host is not allowed, the Telegram chat identifier is invalid, the value is not sealed, or the subscriber already has the maximum number of endpoints for this channel.",
                resolution: "Provide the HTTPS address given by the service (official host), use the host route that seals it, or remove an existing endpoint."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_DESTINATION_FORBIDDEN) THEN (
    CREATE error_definition:NOTIFICATION_DESTINATION_FORBIDDEN CONTENT {
        code: "NOTIFICATION_DESTINATION_FORBIDDEN",
        module: "notification",
        domain: "canaux",
        category: "authorization",
        severity: "error",
        message: "Destination forbidden",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Destination interdite",
                description: "Au moment de l'envoi, l'hôte de l'adresse se résout en une adresse privée, locale, partagée ou de la plateforme, n'est pas en HTTPS, n'est pas un hôte officiel du service ou n'est pas dans la liste des hôtes autorisés de l'installation.",
                resolution: "Corrigez l'adresse chez le destinataire ou la liste des hôtes autorisés (réglage allowed_hosts de l'installation)."
            },
            en: {
                label: "Destination forbidden",
                description: "At send time, the endpoint host resolves to a private, local, shared or platform address, is not HTTPS, is not an official host of the service, or is not in the installation's allowed hosts.",
                resolution: "Fix the endpoint at the recipient or the installation's allowed hosts (allowed_hosts setting)."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SMS_TOO_LONG) THEN (
    CREATE error_definition:NOTIFICATION_SMS_TOO_LONG CONTENT {
        code: "NOTIFICATION_SMS_TOO_LONG",
        module: "notification",
        domain: "canaux",
        category: "validation",
        severity: "error",
        message: "SMS too long",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "SMS trop long",
                description: "Le texte dépasse 10 parties de SMS (GSM-7 : 160 caractères, 153 par partie ; sinon UCS-2 : 70, 67 par partie).",
                resolution: "Raccourcissez le texte du gabarit ou évitez les caractères hors de l'alphabet GSM (accents rares, emoji)."
            },
            en: {
                label: "SMS too long",
                description: "The text exceeds 10 SMS parts (GSM-7: 160 characters, 153 per part; otherwise UCS-2: 70, 67 per part).",
                resolution: "Shorten the template text or avoid characters outside the GSM alphabet (rare accents, emoji)."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SUBSCRIBER_NO_PHONE) THEN (
    CREATE error_definition:NOTIFICATION_SUBSCRIBER_NO_PHONE CONTENT {
        code: "NOTIFICATION_SUBSCRIBER_NO_PHONE",
        module: "notification",
        domain: "canaux",
        category: "validation",
        severity: "error",
        message: "Subscriber has no phone number",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Abonné sans téléphone",
                description: "Le parcours n'envoie que des SMS et l'abonné n'a pas de numéro de téléphone (E.164).",
                resolution: "Ajoutez le numéro de l'abonné (format international, ex. +33612345678) avant de déclencher."
            },
            en: {
                label: "Subscriber has no phone number",
                description: "The workflow only sends SMS and the subscriber has no phone number (E.164).",
                resolution: "Add the subscriber's number (international format, e.g. +33612345678) before triggering."
            }
        }
    }
) END;
