-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_scheduler, thème executions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SCHEDULER_RUN_NOT_FOUND) THEN (
    CREATE error_definition:SCHEDULER_RUN_NOT_FOUND CONTENT {
        code: "SCHEDULER_RUN_NOT_FOUND",
        module: "scheduler",
        domain: "executions",
        category: "not_found",
        severity: "error",
        message: "Run not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Exécution introuvable",
                description: "L'exécution n'existe pas ou vous ne pouvez pas la lire.",
                resolution: "Vérifiez l'identifiant de l'exécution."
            },
            en: {
                label: "Run not found",
                description: "The run does not exist or you may not read it.",
                resolution: "Check the run identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_RUN_STATE_INVALID) THEN (
    CREATE error_definition:SCHEDULER_RUN_STATE_INVALID CONTENT {
        code: "SCHEDULER_RUN_STATE_INVALID",
        module: "scheduler",
        domain: "executions",
        category: "conflict",
        severity: "error",
        message: "Run state does not allow this operation",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État de l'exécution incompatible",
                description: "L'état de l'exécution ne permet pas cette opération (transition interdite, champ figé, exécution déjà terminée…).",
                resolution: "Consultez l'état de l'exécution avant de réessayer."
            },
            en: {
                label: "Run state not compatible",
                description: "The run state does not allow this operation (forbidden transition, frozen field, run already finished…).",
                resolution: "Check the run state before trying again."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_LEASE_LOST) THEN (
    CREATE error_definition:SCHEDULER_LEASE_LOST CONTENT {
        code: "SCHEDULER_LEASE_LOST",
        module: "scheduler",
        domain: "executions",
        category: "conflict",
        severity: "error",
        message: "Lease lost",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Bail perdu",
                description: "Le jeton de bail ne correspond plus à l'exécution en cours : un autre nœud l'a reprise ou elle est terminée.",
                resolution: "Abandonnez cette tentative ; le moteur reprend l'exécution."
            },
            en: {
                label: "Lease lost",
                description: "The lease token no longer matches the running run: another node took it over or it finished.",
                resolution: "Drop this attempt; the engine takes the run over."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_RUN_TIMEOUT) THEN (
    CREATE error_definition:SCHEDULER_RUN_TIMEOUT CONTENT {
        code: "SCHEDULER_RUN_TIMEOUT",
        module: "scheduler",
        domain: "executions",
        category: "timeout",
        severity: "error",
        message: "Run exceeded the task timeout",
        default_language: "fr",
        http_status: 504,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Délai maximal dépassé",
                description: "La tentative a dépassé le délai maximal de la tâche : le moteur a cessé de l'attendre.",
                resolution: "Une nouvelle tentative est prévue s'il en reste ; la tâche doit rester idempotente."
            },
            en: {
                label: "Timeout exceeded",
                description: "The attempt exceeded the task timeout: the engine stopped waiting for it.",
                resolution: "A new attempt is planned if any remain; the task must stay idempotent."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_HANDLER_NOT_FOUND) THEN (
    CREATE error_definition:SCHEDULER_HANDLER_NOT_FOUND CONTENT {
        code: "SCHEDULER_HANDLER_NOT_FOUND",
        module: "scheduler",
        domain: "executions",
        category: "dependency",
        severity: "error",
        message: "No handler registered for the task",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Aucun handler inscrit",
                description: "Aucun nœud n'a inscrit le code de cette tâche pendant son délai maximal.",
                resolution: "Vérifiez que le module qui déclare la tâche est hébergé et inscrit son handler."
            },
            en: {
                label: "No handler registered",
                description: "No node registered the code of this task during its timeout.",
                resolution: "Check that the module declaring the task is hosted and registers its handler."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_EXECUTOR_FAILED) THEN (
    CREATE error_definition:SCHEDULER_EXECUTOR_FAILED CONTENT {
        code: "SCHEDULER_EXECUTOR_FAILED",
        module: "scheduler",
        domain: "executions",
        category: "internal",
        severity: "error",
        message: "Executor technical failure",
        default_language: "fr",
        http_status: 500,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Échec technique de l'exécuteur",
                description: "L'exécuteur n'a pas pu mener la tentative à son terme (base indisponible, résultat illisible).",
                resolution: "Une nouvelle tentative est prévue s'il en reste ; consultez les journaux du nœud."
            },
            en: {
                label: "Executor technical failure",
                description: "The executor could not complete the attempt (database unavailable, unreadable result).",
                resolution: "A new attempt is planned if any remain; check the node logs."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_LEADER_FENCED) THEN (
    CREATE error_definition:SCHEDULER_LEADER_FENCED CONTENT {
        code: "SCHEDULER_LEADER_FENCED",
        module: "scheduler",
        domain: "executions",
        category: "conflict",
        severity: "error",
        message: "Operation refused: the node no longer holds the scheduler leader lease",
        default_language: "fr",
        http_status: 412,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Planificateur n'est plus élu",
                description: "Le nœud ne détient plus le bail du planificateur (autre nœud, autre génération ou bail expiré) : il n'écrit plus rien.",
                resolution: "Aucune action : le nœud qui détient le bail reprend la planification."
            },
            en: {
                label: "Scheduler no longer elected",
                description: "The node no longer holds the scheduler lease (other node, other generation or expired lease): it writes nothing.",
                resolution: "No action: the node holding the lease takes over scheduling."
            }
        }
    }
) END;
