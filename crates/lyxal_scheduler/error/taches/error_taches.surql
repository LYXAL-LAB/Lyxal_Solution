-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_scheduler, thème taches
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SCHEDULER_TASK_NOT_FOUND) THEN (
    CREATE error_definition:SCHEDULER_TASK_NOT_FOUND CONTENT {
        code: "SCHEDULER_TASK_NOT_FOUND",
        module: "scheduler",
        domain: "taches",
        category: "not_found",
        severity: "error",
        message: "Task not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Tâche introuvable",
                description: "Aucune tâche déclarée ne porte ce nom, ou vous ne pouvez pas la lire.",
                resolution: "Vérifiez le nom (<module>.<action>) avec la liste des tâches."
            },
            en: {
                label: "Task not found",
                description: "No declared task has this name, or you may not read it.",
                resolution: "Check the name (<module>.<action>) against the task list."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_TASK_DISABLED) THEN (
    CREATE error_definition:SCHEDULER_TASK_DISABLED CONTENT {
        code: "SCHEDULER_TASK_DISABLED",
        module: "scheduler",
        domain: "taches",
        category: "conflict",
        severity: "error",
        message: "Task disabled",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Tâche désactivée",
                description: "La tâche est désactivée : elle ne reçoit ni planification ni exécution.",
                resolution: "Attendez sa réactivation par l'exploitant."
            },
            en: {
                label: "Task disabled",
                description: "The task is disabled: it accepts no schedule and no run.",
                resolution: "Wait for the operator to enable it again."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_QUEUE_NOT_FOUND) THEN (
    CREATE error_definition:SCHEDULER_QUEUE_NOT_FOUND CONTENT {
        code: "SCHEDULER_QUEUE_NOT_FOUND",
        module: "scheduler",
        domain: "taches",
        category: "not_found",
        severity: "error",
        message: "Queue not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "File introuvable",
                description: "Aucune file d'exécution ne porte ce nom.",
                resolution: "Vérifiez le nom avec la liste des files."
            },
            en: {
                label: "Queue not found",
                description: "No execution queue has this name.",
                resolution: "Check the name against the queue list."
            }
        }
    }
) END;
