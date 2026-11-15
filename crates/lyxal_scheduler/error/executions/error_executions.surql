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
