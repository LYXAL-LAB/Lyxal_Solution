-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème parcours, gabarits et mises en page
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_WORKFLOW_KEY_TAKEN) THEN (
    CREATE error_definition:NOTIFICATION_WORKFLOW_KEY_TAKEN CONTENT {
        code: "NOTIFICATION_WORKFLOW_KEY_TAKEN",
        module: "notification",
        domain: "parcours",
        category: "conflict",
        severity: "error",
        message: "Workflow key taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de parcours déjà utilisée",
                description: "Un parcours de cette portée utilise déjà cette clé.",
                resolution: "Choisissez une autre clé."
            },
            en: {
                label: "Workflow key already used",
                description: "A workflow in this scope already uses this key.",
                resolution: "Choose another key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_WORKFLOW_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_WORKFLOW_NOT_FOUND CONTENT {
        code: "NOTIFICATION_WORKFLOW_NOT_FOUND",
        module: "notification",
        domain: "parcours",
        category: "not_found",
        severity: "error",
        message: "Workflow not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Parcours introuvable",
                description: "Aucun parcours correspondant n'existe dans cette portée ni dans l'installation.",
                resolution: "Vérifiez la clé ou l'événement déclencheur."
            },
            en: {
                label: "Workflow not found",
                description: "No matching workflow exists in this scope or in the installation.",
                resolution: "Check the key or the trigger event."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_WORKFLOW_INACTIVE) THEN (
    CREATE error_definition:NOTIFICATION_WORKFLOW_INACTIVE CONTENT {
        code: "NOTIFICATION_WORKFLOW_INACTIVE",
        module: "notification",
        domain: "parcours",
        category: "conflict",
        severity: "error",
        message: "Workflow inactive",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Parcours inactif",
                description: "Le parcours existe mais n'est pas actif.",
                resolution: "Activez le parcours avant de le déclencher."
            },
            en: {
                label: "Workflow inactive",
                description: "The workflow exists but is not active.",
                resolution: "Activate the workflow before triggering it."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_PAYLOAD_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_PAYLOAD_INVALID CONTENT {
        code: "NOTIFICATION_PAYLOAD_INVALID",
        module: "notification",
        domain: "parcours",
        category: "validation",
        severity: "error",
        message: "Payload invalid",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Variables invalides",
                description: "Les variables fournies ne respectent pas le schéma du parcours.",
                resolution: "Corrigez les champs signalés."
            },
            en: {
                label: "Invalid payload",
                description: "The supplied variables do not match the workflow schema.",
                resolution: "Fix the reported fields."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_TEMPLATE_EXISTS) THEN (
    CREATE error_definition:NOTIFICATION_TEMPLATE_EXISTS CONTENT {
        code: "NOTIFICATION_TEMPLATE_EXISTS",
        module: "notification",
        domain: "parcours",
        category: "conflict",
        severity: "error",
        message: "Template exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Gabarit déjà existant",
                description: "Cette étape a déjà un gabarit.",
                resolution: "Modifiez le gabarit existant."
            },
            en: {
                label: "Template already exists",
                description: "This step already has a template.",
                resolution: "Update the existing template."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_LAYOUT_KEY_TAKEN) THEN (
    CREATE error_definition:NOTIFICATION_LAYOUT_KEY_TAKEN CONTENT {
        code: "NOTIFICATION_LAYOUT_KEY_TAKEN",
        module: "notification",
        domain: "parcours",
        category: "conflict",
        severity: "error",
        message: "Layout key taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de mise en page déjà utilisée",
                description: "Une mise en page de cette portée utilise déjà cette clé.",
                resolution: "Choisissez une autre clé."
            },
            en: {
                label: "Layout key already used",
                description: "A layout in this scope already uses this key.",
                resolution: "Choose another key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING) THEN (
    CREATE error_definition:NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING CONTENT {
        code: "NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING",
        module: "notification",
        domain: "parcours",
        category: "validation",
        severity: "error",
        message: "Layout content slot missing",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Emplacement du contenu absent",
                description: "Le HTML et le texte d'une mise en page doivent contenir {{ content }}.",
                resolution: "Ajoutez {{ content }} à l'endroit où le message doit apparaître."
            },
            en: {
                label: "Content slot missing",
                description: "A layout's HTML and text must contain {{ content }}.",
                resolution: "Add {{ content }} where the message should appear."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_TEMPLATE_REQUIRED) THEN (
    CREATE error_definition:NOTIFICATION_TEMPLATE_REQUIRED CONTENT {
        code: "NOTIFICATION_TEMPLATE_REQUIRED",
        module: "notification",
        domain: "parcours",
        category: "conflict",
        severity: "error",
        message: "Template required",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Gabarit obligatoire",
                description: "Chaque étape d'un parcours actif doit avoir un gabarit.",
                resolution: "Créez le gabarit de chaque étape avant d'activer ou de modifier le parcours."
            },
            en: {
                label: "Template required",
                description: "Each step of an active workflow needs a template.",
                resolution: "Create the template of each step before activating or changing the workflow."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_TEMPLATE_KEY_UNKNOWN) THEN (
    CREATE error_definition:NOTIFICATION_TEMPLATE_KEY_UNKNOWN CONTENT {
        code: "NOTIFICATION_TEMPLATE_KEY_UNKNOWN",
        module: "notification",
        domain: "parcours",
        category: "validation",
        severity: "error",
        message: "Template key unknown",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de traduction inconnue",
                description: "Le gabarit déclare une clé de traduction qui n'existe pas dans lyxal_i18n (détail : keys).",
                resolution: "Créez la clé dans les traductions ou retirez-la du gabarit."
            },
            en: {
                label: "Unknown translation key",
                description: "The template declares a translation key that does not exist in lyxal_i18n (detail: keys).",
                resolution: "Create the key in the translations or remove it from the template."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_STEP_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_STEP_INVALID CONTENT {
        code: "NOTIFICATION_STEP_INVALID",
        module: "notification",
        domain: "parcours",
        category: "validation",
        severity: "error",
        message: "Workflow step invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Étape de parcours invalide",
                description: "Une étape du parcours est mal formée pour son type, ou l'ordre des étapes est refusé (détail par étape et par champ, ou raison : duplicate_key, delay_form, no_channel_step, no_channel_after).",
                resolution: "Corrigez l'étape signalée : une attente a une durée ou une date des données, un regroupement ou une limitation précède une étape de canal, et le parcours a au moins une étape de canal."
            },
            en: {
                label: "Invalid workflow step",
                description: "A workflow step is malformed for its type, or the step order is refused (detail per step and field, or reason: duplicate_key, delay_form, no_channel_step, no_channel_after).",
                resolution: "Fix the reported step: a delay has a duration or a date from the data, a digest or throttle precedes a channel step, and the workflow has at least one channel step."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_WAIT_TOO_LONG) THEN (
    CREATE error_definition:NOTIFICATION_WAIT_TOO_LONG CONTENT {
        code: "NOTIFICATION_WAIT_TOO_LONG",
        module: "notification",
        domain: "parcours",
        category: "validation",
        severity: "error",
        message: "Wait too long",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Attente trop longue",
                description: "Une attente, une fenêtre de regroupement ou de limitation dépasse le réglage max_wait_days (détail : step, max_days).",
                resolution: "Raccourcissez la durée, ou relevez max_wait_days dans les réglages (366 jours au plus)."
            },
            en: {
                label: "Wait too long",
                description: "A wait, a digest or throttle window exceeds the max_wait_days setting (detail: step, max_days).",
                resolution: "Shorten the duration, or raise max_wait_days in the settings (366 days at most)."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_RUN_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_RUN_NOT_FOUND CONTENT {
        code: "NOTIFICATION_RUN_NOT_FOUND",
        module: "notification",
        domain: "parcours",
        category: "not_found",
        severity: "error",
        message: "No run in progress",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Aucun déclenchement en cours",
                description: "Aucun déclenchement en cours ou en attente ne porte cette clé d'idempotence dans cette portée.",
                resolution: "Vérifiez la clé et la portée ; un déclenchement terminé ne peut plus être annulé."
            },
            en: {
                label: "No run in progress",
                description: "No pending or waiting run has this idempotency key in this scope.",
                resolution: "Check the key and the scope; a finished run can no longer be canceled."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_OVERRIDE_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_OVERRIDE_INVALID CONTENT {
        code: "NOTIFICATION_OVERRIDE_INVALID",
        module: "notification",
        domain: "parcours",
        category: "validation",
        severity: "error",
        message: "Override invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Surcharge invalide",
                description: "Une surcharge du déclenchement vise une étape inconnue du parcours, ou change un réglage que son type ne permet pas (détail : step, fields).",
                resolution: "Toute étape peut être sautée (skip) ; une attente reçoit amount et unit ; un regroupement reçoit window."
            },
            en: {
                label: "Invalid override",
                description: "A trigger override targets a step unknown to the workflow, or changes a setting its type does not allow (detail: step, fields).",
                resolution: "Any step can be skipped (skip); a delay takes amount and unit; a digest takes window."
            }
        }
    }
) END;
