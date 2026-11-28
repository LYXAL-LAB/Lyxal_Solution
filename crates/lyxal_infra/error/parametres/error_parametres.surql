-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_infra, thème parametres
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INFRA_INVALID_PARAMETERS) THEN (
    CREATE error_definition:INFRA_INVALID_PARAMETERS CONTENT {
        code: "INFRA_INVALID_PARAMETERS",
        module: "infra",
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
                description: "Les paramètres fournis ne respectent pas le format attendu (détail par champ : fields).",
                resolution: "Corrigez les champs signalés."
            },
            en: {
                label: "Invalid parameters",
                description: "The supplied parameters do not match the expected format (per-field detail: fields).",
                resolution: "Fix the reported fields."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PERMISSION_DENIED) THEN (
    CREATE error_definition:INFRA_PERMISSION_DENIED CONTENT {
        code: "INFRA_PERMISSION_DENIED",
        module: "infra",
        domain: "parametres",
        category: "authorization",
        severity: "error",
        message: "Permission denied",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Droit manquant",
                description: "L'appelant n'a pas la permission infra.* requise pour cette opération.",
                resolution: "Demandez la permission à l'administrateur de la plateforme."
            },
            en: {
                label: "Permission denied",
                description: "The caller lacks the infra.* permission required for this operation.",
                resolution: "Ask the platform administrator for the permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:INFRA_WRITE_FORBIDDEN CONTENT {
        code: "INFRA_WRITE_FORBIDDEN",
        module: "infra",
        domain: "parametres",
        category: "authorization",
        severity: "error",
        message: "Write forbidden by table permissions",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "L'écriture a été filtrée par les permissions de la table : rien n'a été enregistré.",
                resolution: "Vérifiez les permissions de la session qui écrit."
            },
            en: {
                label: "Write forbidden",
                description: "The write was filtered by the table permissions: nothing was saved.",
                resolution: "Check the permissions of the writing session."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_SETTINGS_INVALID) THEN (
    CREATE error_definition:INFRA_SETTINGS_INVALID CONTENT {
        code: "INFRA_SETTINGS_INVALID",
        module: "infra",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Invalid settings",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Réglage invalide",
                description: "Un réglage est hors de ses bornes ou contredit un autre réglage (détail : fields).",
                resolution: "Corrigez le réglage signalé."
            },
            en: {
                label: "Invalid setting",
                description: "A setting is out of bounds or contradicts another setting (detail: fields).",
                resolution: "Fix the reported setting."
            }
        }
    }
) END;
