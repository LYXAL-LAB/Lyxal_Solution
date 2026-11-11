-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_storage, thème permissions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:STORAGE_PERMISSION_DENIED) THEN (
    CREATE error_definition:STORAGE_PERMISSION_DENIED CONTENT {
        code: "STORAGE_PERMISSION_DENIED",
        module: "storage",
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
                description: "Votre session n'a pas la permission requise sur ces fichiers.",
                resolution: "Demandez la permission à un administrateur de l'organisation."
            },
            en: {
                label: "Action not allowed",
                description: "Your session lacks the required permission on these files.",
                resolution: "Ask an organization administrator for the permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:STORAGE_WRITE_FORBIDDEN CONTENT {
        code: "STORAGE_WRITE_FORBIDDEN",
        module: "storage",
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
                description: "L'écriture a été filtrée par les permissions de la table (détail : table). Rien n'a été modifié.",
                resolution: "Vérifiez vos droits sur cette portée."
            },
            en: {
                label: "Write refused",
                description: "The write was filtered by the table permissions (detail: table). Nothing was changed.",
                resolution: "Check your rights on this scope."
            }
        }
    }
) END;
