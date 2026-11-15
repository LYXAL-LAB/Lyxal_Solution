-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_scheduler, thème planifications
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SCHEDULER_SCHEDULE_NOT_FOUND) THEN (
    CREATE error_definition:SCHEDULER_SCHEDULE_NOT_FOUND CONTENT {
        code: "SCHEDULER_SCHEDULE_NOT_FOUND",
        module: "scheduler",
        domain: "planifications",
        category: "not_found",
        severity: "error",
        message: "Schedule not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Planification introuvable",
                description: "La planification n'existe pas ou vous ne pouvez pas la lire.",
                resolution: "Vérifiez l'identifiant de la planification."
            },
            en: {
                label: "Schedule not found",
                description: "The schedule does not exist or you may not read it.",
                resolution: "Check the schedule identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_SCHEDULE_EXISTS) THEN (
    CREATE error_definition:SCHEDULER_SCHEDULE_EXISTS CONTENT {
        code: "SCHEDULER_SCHEDULE_EXISTS",
        module: "scheduler",
        domain: "planifications",
        category: "conflict",
        severity: "error",
        message: "Schedule already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Planification existante",
                description: "Une planification de ce nom existe déjà dans cette organisation.",
                resolution: "Choisissez un autre nom ou modifiez la planification existante."
            },
            en: {
                label: "Schedule already exists",
                description: "A schedule with this name already exists in this organization.",
                resolution: "Choose another name or update the existing schedule."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_SCHEDULE_STATE_INVALID) THEN (
    CREATE error_definition:SCHEDULER_SCHEDULE_STATE_INVALID CONTENT {
        code: "SCHEDULER_SCHEDULE_STATE_INVALID",
        module: "scheduler",
        domain: "planifications",
        category: "conflict",
        severity: "error",
        message: "Schedule state does not allow this operation",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État de la planification incompatible",
                description: "L'état de la planification (terminée, déjà en pause, champ réservé au moteur…) ne permet pas cette opération.",
                resolution: "Consultez l'état de la planification avant de réessayer."
            },
            en: {
                label: "Schedule state not compatible",
                description: "The schedule state (completed, already paused, engine-only field…) does not allow this operation.",
                resolution: "Check the schedule state before trying again."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_SPEC_INVALID) THEN (
    CREATE error_definition:SCHEDULER_SPEC_INVALID CONTENT {
        code: "SCHEDULER_SPEC_INVALID",
        module: "scheduler",
        domain: "planifications",
        category: "validation",
        severity: "error",
        message: "Schedule rules invalid",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Règles de dates invalides",
                description: "Les règles de dates sont invalides : au moins une règle cron, un intervalle ou une date unique, listes bornées, fuseau non vide, début avant la fin (détail : fields).",
                resolution: "Corrigez les règles de dates de la planification."
            },
            en: {
                label: "Date rules invalid",
                description: "The date rules are invalid: at least one cron rule, interval or single date, bounded lists, non-empty time zone, start before end (detail: fields).",
                resolution: "Fix the schedule date rules."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_BACKFILL_RUNNING) THEN (
    CREATE error_definition:SCHEDULER_BACKFILL_RUNNING CONTENT {
        code: "SCHEDULER_BACKFILL_RUNNING",
        module: "scheduler",
        domain: "planifications",
        category: "conflict",
        severity: "error",
        message: "Backfill already running",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Rejeu en cours",
                description: "Un rejeu de période est déjà en cours pour cette planification.",
                resolution: "Attendez la fin du rejeu en cours."
            },
            en: {
                label: "Backfill running",
                description: "A backfill is already running for this schedule.",
                resolution: "Wait for the current backfill to finish."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_CALENDAR_NOT_FOUND) THEN (
    CREATE error_definition:SCHEDULER_CALENDAR_NOT_FOUND CONTENT {
        code: "SCHEDULER_CALENDAR_NOT_FOUND",
        module: "scheduler",
        domain: "planifications",
        category: "not_found",
        severity: "error",
        message: "Calendar not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Calendrier introuvable",
                description: "Le calendrier n'existe pas, n'est pas lisible ou n'appartient pas à la même organisation.",
                resolution: "Vérifiez l'identifiant et l'organisation du calendrier."
            },
            en: {
                label: "Calendar not found",
                description: "The calendar does not exist, is not readable or belongs to another organization.",
                resolution: "Check the calendar identifier and organization."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_CALENDAR_EXISTS) THEN (
    CREATE error_definition:SCHEDULER_CALENDAR_EXISTS CONTENT {
        code: "SCHEDULER_CALENDAR_EXISTS",
        module: "scheduler",
        domain: "planifications",
        category: "conflict",
        severity: "error",
        message: "Calendar already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Calendrier existant",
                description: "Un calendrier de ce nom existe déjà dans cette organisation.",
                resolution: "Choisissez un autre nom ou modifiez le calendrier existant."
            },
            en: {
                label: "Calendar already exists",
                description: "A calendar with this name already exists in this organization.",
                resolution: "Choose another name or update the existing calendar."
            }
        }
    }
) END;

IF !record::exists(error_definition:SCHEDULER_CALENDAR_IN_USE) THEN (
    CREATE error_definition:SCHEDULER_CALENDAR_IN_USE CONTENT {
        code: "SCHEDULER_CALENDAR_IN_USE",
        module: "scheduler",
        domain: "planifications",
        category: "conflict",
        severity: "error",
        message: "Calendar in use",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Calendrier utilisé",
                description: "Le calendrier est utilisé par au moins une planification.",
                resolution: "Retirez-le des planifications qui l'utilisent avant de le supprimer."
            },
            en: {
                label: "Calendar in use",
                description: "The calendar is used by at least one schedule.",
                resolution: "Remove it from the schedules that use it before deleting it."
            }
        }
    }
) END;
