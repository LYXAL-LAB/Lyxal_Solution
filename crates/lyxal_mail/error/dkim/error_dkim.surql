-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème clés DKIM
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_DKIM_KEY_EXISTS) THEN (
    CREATE error_definition:MAIL_DKIM_KEY_EXISTS CONTENT {
        code: "MAIL_DKIM_KEY_EXISTS",
        module: "mail",
        domain: "dkim",
        category: "conflict",
        severity: "error",
        message: "DKIM selector already used",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Sélecteur DKIM déjà pris",
                description: "Ce sélecteur est déjà utilisé pour le domaine.",
                resolution: "Choisissez un autre sélecteur."
            },
            en: {
                label: "DKIM selector already used",
                description: "This selector is already used for the domain.",
                resolution: "Choose another selector."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_DKIM_KEY_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_DKIM_KEY_NOT_FOUND CONTENT {
        code: "MAIL_DKIM_KEY_NOT_FOUND",
        module: "mail",
        domain: "dkim",
        category: "not_found",
        severity: "error",
        message: "DKIM key not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé DKIM introuvable",
                description: "Cette clé DKIM n'existe pas.",
                resolution: "Vérifiez l'identifiant de la clé."
            },
            en: {
                label: "DKIM key not found",
                description: "This DKIM key does not exist.",
                resolution: "Check the key identifier."
            }
        }
    }
) END;
