-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème parametres
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_INVALID_PARAMETERS) THEN (
    CREATE error_definition:MAIL_INVALID_PARAMETERS CONTENT {
        code: "MAIL_INVALID_PARAMETERS",
        module: "mail",
        domain: "parametres",
        category: "validation",
        severity: "error",
        message: "Invalid mail parameters",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Un ou plusieurs paramètres sont absents ou mal formés ; le détail par champ est dans details.fields.",
                resolution: "Corrigez les champs signalés puis recommencez."
            },
            en: {
                label: "Invalid parameters",
                description: "One or more parameters are missing or malformed; per-field details are in details.fields.",
                resolution: "Fix the reported fields and try again."
            }
        }
    }
) END;
