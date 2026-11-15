-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_scheduler, thème parametres
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SCHEDULER_INVALID_PARAMETERS) THEN (
    CREATE error_definition:SCHEDULER_INVALID_PARAMETERS CONTENT {
        code: "SCHEDULER_INVALID_PARAMETERS",
        module: "scheduler",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Invalid parameters",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Un ou plusieurs paramètres sont absents ou invalides (détail par champ : fields).",
                resolution: "Corrigez les champs signalés et renvoyez la demande."
            },
            en: {
                label: "Invalid parameters",
                description: "One or more parameters are missing or invalid (per-field detail: fields).",
                resolution: "Fix the reported fields and send the request again."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_ARGS_INVALID) THEN (
    CREATE error_definition:SCHEDULER_ARGS_INVALID CONTENT {
        code: "SCHEDULER_ARGS_INVALID",
        module: "scheduler",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Task arguments invalid",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Arguments refusés",
                description: "Les arguments ne respectent pas le schéma déclaré par la tâche ou dépassent la taille permise (détail : fields).",
                resolution: "Passez les arguments attendus par la tâche, sans dépasser la taille réglée."
            },
            en: {
                label: "Arguments refused",
                description: "The arguments do not match the schema declared by the task or exceed the allowed size (detail: fields).",
                resolution: "Pass the arguments the task expects, within the configured size."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_LIMIT_REACHED) THEN (
    CREATE error_definition:SCHEDULER_LIMIT_REACHED CONTENT {
        code: "SCHEDULER_LIMIT_REACHED",
        module: "scheduler",
        domain: "parametres",
        category: "rate_limit",
        severity: "error",
        message: "Limit reached",
        default_language: "fr",
        http_status: 429,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Limite atteinte",
                description: "L'organisation a atteint sa limite de planifications ou d'exécutions en attente (détail : limit).",
                resolution: "Supprimez des planifications ou attendez la fin des exécutions, ou faites relever la limite dans les réglages."
            },
            en: {
                label: "Limit reached",
                description: "The organization reached its limit of schedules or pending runs (detail: limit).",
                resolution: "Delete schedules or wait for runs to finish, or have the limit raised in the settings."
            }
        }
    }
) END;
