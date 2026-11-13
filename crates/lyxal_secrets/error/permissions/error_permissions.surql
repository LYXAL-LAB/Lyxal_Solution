-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème permissions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_PERMISSION_DENIED) THEN (
    CREATE error_definition:SECRETS_PERMISSION_DENIED CONTENT {
        code: "SECRETS_PERMISSION_DENIED",
        module: "secrets",
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
                label: "Droit insuffisant",
                description: "Votre session n'a pas le droit d'effectuer cette opération sur ce secret ou dans cette organisation.",
                resolution: "Demandez la permission secrets.* nécessaire à un administrateur."
            },
            en: {
                label: "Permission denied",
                description: "Your session may not perform this operation on this secret or in this organization.",
                resolution: "Ask an administrator for the required secrets.* permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:SECRETS_WRITE_FORBIDDEN CONTENT {
        code: "SECRETS_WRITE_FORBIDDEN",
        module: "secrets",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Write refused by permissions",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "L'écriture a été refusée par les permissions de la table (détail : table).",
                resolution: "Vérifiez les droits de la session sur le coffre-fort."
            },
            en: {
                label: "Write refused",
                description: "The write was refused by the table permissions (detail: table).",
                resolution: "Check the session rights on the secrets vault."
            }
        }
    }
) END;
