-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème blocage
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_BLOCK_EXISTS) THEN (
    CREATE error_definition:MAIL_BLOCK_EXISTS CONTENT {
        code: "MAIL_BLOCK_EXISTS",
        module: "mail",
        domain: "blocage",
        category: "conflict",
        severity: "error",
        message: "Network already blocked",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Réseau déjà bloqué",
                description: "Ce réseau est déjà dans la liste de blocage.",
                resolution: "Retirez l'entrée existante avant d'en poser une autre."
            },
            en: {
                label: "Network already blocked",
                description: "This network is already in the block list.",
                resolution: "Remove the existing entry before adding another one."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_BLOCK_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_BLOCK_NOT_FOUND CONTENT {
        code: "MAIL_BLOCK_NOT_FOUND",
        module: "mail",
        domain: "blocage",
        category: "not_found",
        severity: "error",
        message: "Network not in the block list",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Réseau absent de la liste",
                description: "Ce réseau n'est pas dans la liste de blocage.",
                resolution: "Vérifiez le réseau (plage CIDR)."
            },
            en: {
                label: "Network not in the block list",
                description: "This network is not in the block list.",
                resolution: "Check the network (CIDR range)."
            }
        }
    }
) END;
