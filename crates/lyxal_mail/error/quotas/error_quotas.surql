-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème quotas
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_QUOTA_EXCEEDED) THEN (
    CREATE error_definition:MAIL_QUOTA_EXCEEDED CONTENT {
        code: "MAIL_QUOTA_EXCEEDED",
        module: "mail",
        domain: "quotas",
        category: "business",
        severity: "error",
        message: "Mail quota exceeded",
        default_language: "fr",
        http_status: 507,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Quota dépassé",
                description: "Ce compte a atteint son espace de courrier.",
                resolution: "Supprimez des messages ou demandez un quota plus grand."
            },
            en: {
                label: "Quota exceeded",
                description: "This account has reached its mail space.",
                resolution: "Delete messages or ask for a larger quota."
            }
        }
    }
) END;
