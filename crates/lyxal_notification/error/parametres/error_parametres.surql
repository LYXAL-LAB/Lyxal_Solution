-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème paramètres et droits
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_INVALID_INPUT) THEN (
    CREATE error_definition:NOTIFICATION_INVALID_INPUT CONTENT {
        code: "NOTIFICATION_INVALID_INPUT",
        module: "notification",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Invalid input",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Les paramètres fournis ne respectent pas le format attendu.",
                resolution: "Corrigez les champs signalés."
            },
            en: {
                label: "Invalid parameters",
                description: "The supplied parameters do not match the expected format.",
                resolution: "Fix the reported fields."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_PERMISSION_DENIED) THEN (
    CREATE error_definition:NOTIFICATION_PERMISSION_DENIED CONTENT {
        code: "NOTIFICATION_PERMISSION_DENIED",
        module: "notification",
        domain: "parametres",
        category: "authorization",
        severity: "error",
        message: "Permission denied",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Permission refusée",
                description: "L'identité connectée n'a pas la permission requise pour cette opération sur les notifications.",
                resolution: "Demandez la permission notification adaptée à un administrateur."
            },
            en: {
                label: "Permission denied",
                description: "The signed-in identity lacks the permission required for this notification operation.",
                resolution: "Ask an administrator for the appropriate notification permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:NOTIFICATION_WRITE_FORBIDDEN CONTENT {
        code: "NOTIFICATION_WRITE_FORBIDDEN",
        module: "notification",
        domain: "parametres",
        category: "authorization",
        severity: "error",
        message: "Write forbidden",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "Les permissions de la table ont refusé l'écriture.",
                resolution: "Vérifiez les droits de l'identité connectée."
            },
            en: {
                label: "Write forbidden",
                description: "The table permissions refused the write.",
                resolution: "Check the rights of the signed-in identity."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_NOT_FOUND CONTENT {
        code: "NOTIFICATION_NOT_FOUND",
        module: "notification",
        domain: "parametres",
        category: "not_found",
        severity: "error",
        message: "Not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Élément introuvable",
                description: "L'élément demandé (mise en page, gabarit, déclenchement, adresse) n'existe pas ou n'est pas visible.",
                resolution: "Vérifiez l'identifiant et la portée."
            },
            en: {
                label: "Not found",
                description: "The requested item (layout, template, run, address) does not exist or is not visible.",
                resolution: "Check the identifier and the scope."
            }
        }
    }
) END;
