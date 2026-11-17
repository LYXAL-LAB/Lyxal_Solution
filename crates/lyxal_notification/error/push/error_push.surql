-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème push (appareils inscrits,
-- contenu d'une notification push)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_DEVICE_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_DEVICE_INVALID CONTENT {
        code: "NOTIFICATION_DEVICE_INVALID",
        module: "notification",
        domain: "push",
        category: "validation",
        severity: "error",
        message: "Invalid device registration",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Inscription de l'appareil refusée",
                description: "L'inscription est mal formée (jeton, clés du navigateur, empreinte ou plateforme), les valeurs ne sont pas scellées, ou l'adresse Web Push n'est pas une adresse HTTPS d'un service push connu.",
                resolution: "Inscrivez l'appareil par la route de l'hôte (qui scelle le jeton), avec l'abonnement donné par le navigateur ou le jeton donné par Firebase ou Apple."
            },
            en: {
                label: "Device registration refused",
                description: "The registration is malformed (token, browser keys, fingerprint or platform), the values are not sealed, or the Web Push address is not an HTTPS address of a known push service.",
                resolution: "Register the device through the host route (which seals the token), with the subscription given by the browser or the token given by Firebase or Apple."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_DEVICE_LIMIT) THEN (
    CREATE error_definition:NOTIFICATION_DEVICE_LIMIT CONTENT {
        code: "NOTIFICATION_DEVICE_LIMIT",
        module: "notification",
        domain: "push",
        category: "conflict",
        severity: "error",
        message: "Too many devices",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trop d'appareils",
                description: "La personne a déjà 10 appareils inscrits pour les notifications push.",
                resolution: "Retirez un appareil inutilisé avant d'en inscrire un autre."
            },
            en: {
                label: "Too many devices",
                description: "The person already has 10 devices registered for push notifications.",
                resolution: "Remove an unused device before registering another one."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_DEVICE_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_DEVICE_NOT_FOUND CONTENT {
        code: "NOTIFICATION_DEVICE_NOT_FOUND",
        module: "notification",
        domain: "push",
        category: "not_found",
        severity: "error",
        message: "Device not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Appareil introuvable",
                description: "Aucun appareil n'a cet identifiant pour cette personne, ou il a déjà été retiré.",
                resolution: "Relisez la liste de vos appareils."
            },
            en: {
                label: "Device not found",
                description: "No device has this identifier for this person, or it has already been removed.",
                resolution: "Read your list of devices again."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_PUSH_TOO_LARGE) THEN (
    CREATE error_definition:NOTIFICATION_PUSH_TOO_LARGE CONTENT {
        code: "NOTIFICATION_PUSH_TOO_LARGE",
        module: "notification",
        domain: "push",
        category: "validation",
        severity: "error",
        message: "Push notification too large",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Notification push trop grande",
                description: "Le titre, le lien, l'icône et les données de la notification dépassent 4 Kio une fois chiffrés, même après avoir tronqué le texte.",
                resolution: "Raccourcissez le titre, le lien ou les données du gabarit de l'étape push."
            },
            en: {
                label: "Push notification too large",
                description: "The title, link, icon and data of the notification exceed 4 KiB once encrypted, even after truncating the text.",
                resolution: "Shorten the title, link or data of the push step template."
            }
        }
    }
) END;
