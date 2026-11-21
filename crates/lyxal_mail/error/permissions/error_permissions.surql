-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème permissions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_PERMISSION_DENIED) THEN (
    CREATE error_definition:MAIL_PERMISSION_DENIED CONTENT {
        code: "MAIL_PERMISSION_DENIED",
        module: "mail",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Permission denied",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Action non autorisée",
                description: "Votre session n'a pas la permission requise sur ce courrier.",
                resolution: "Demandez la permission à un administrateur de l'organisation."
            },
            en: {
                label: "Action not allowed",
                description: "Your session lacks the required permission on this mail.",
                resolution: "Ask an organization administrator for the permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:MAIL_WRITE_FORBIDDEN CONTENT {
        code: "MAIL_WRITE_FORBIDDEN",
        module: "mail",
        domain: "permissions",
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
                description: "L'écriture a été refusée par les droits ou par les règles du courrier.",
                resolution: "Passez par les fonctions du module avec une session autorisée."
            },
            en: {
                label: "Write refused",
                description: "The write was refused by the permissions or the mail rules.",
                resolution: "Use the module functions with an authorized session."
            }
        }
    }
) END;
