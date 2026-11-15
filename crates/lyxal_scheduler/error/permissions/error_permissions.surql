-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_scheduler, thème permissions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SCHEDULER_PERMISSION_DENIED) THEN (
    CREATE error_definition:SCHEDULER_PERMISSION_DENIED CONTENT {
        code: "SCHEDULER_PERMISSION_DENIED",
        module: "scheduler",
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
                description: "Votre session n'a pas le droit d'effectuer cette opération du planificateur, ou n'a pas la permission propre de la tâche.",
                resolution: "Demandez la permission scheduler.* nécessaire, et celle de la tâche, à un administrateur."
            },
            en: {
                label: "Permission denied",
                description: "Your session may not perform this scheduler operation, or lacks the task's own permission.",
                resolution: "Ask an administrator for the required scheduler.* permission and the task permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:SCHEDULER_WRITE_FORBIDDEN CONTENT {
        code: "SCHEDULER_WRITE_FORBIDDEN",
        module: "scheduler",
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
                resolution: "Vérifiez les droits de la session sur le planificateur."
            },
            en: {
                label: "Write refused",
                description: "The write was refused by the table permissions (detail: table).",
                resolution: "Check the session rights on the scheduler."
            }
        }
    }
) END;
