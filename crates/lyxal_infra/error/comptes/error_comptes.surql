-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_infra, thème comptes
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INFRA_ACCOUNT_NOT_FOUND) THEN (
    CREATE error_definition:INFRA_ACCOUNT_NOT_FOUND CONTENT {
        code: "INFRA_ACCOUNT_NOT_FOUND",
        module: "infra",
        domain: "comptes",
        category: "not_found",
        severity: "error",
        message: "Provider account not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte introuvable",
                description: "Le compte d'hébergeur demandé n'existe pas.",
                resolution: "Vérifiez l'identifiant du compte."
            },
            en: {
                label: "Account not found",
                description: "The requested provider account does not exist.",
                resolution: "Check the account identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ACCOUNT_EXISTS) THEN (
    CREATE error_definition:INFRA_ACCOUNT_EXISTS CONTENT {
        code: "INFRA_ACCOUNT_EXISTS",
        module: "infra",
        domain: "comptes",
        category: "conflict",
        severity: "error",
        message: "Provider account already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte déjà existant",
                description: "Un compte d'hébergeur porte déjà cette clé.",
                resolution: "Choisissez une autre clé ou modifiez le compte existant."
            },
            en: {
                label: "Account already exists",
                description: "A provider account already has this key.",
                resolution: "Choose another key or update the existing account."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ACCOUNT_IN_USE) THEN (
    CREATE error_definition:INFRA_ACCOUNT_IN_USE CONTENT {
        code: "INFRA_ACCOUNT_IN_USE",
        module: "infra",
        domain: "comptes",
        category: "conflict",
        severity: "error",
        message: "Provider account still carries zones",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte utilisé",
                description: "Le compte porte encore des zones rattachées : il ne peut pas être supprimé.",
                resolution: "Détachez d'abord ses zones."
            },
            en: {
                label: "Account in use",
                description: "The account still carries attached zones: it cannot be deleted.",
                resolution: "Detach its zones first."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ACCOUNT_SECRET_INVALID) THEN (
    CREATE error_definition:INFRA_ACCOUNT_SECRET_INVALID CONTENT {
        code: "INFRA_ACCOUNT_SECRET_INVALID",
        module: "infra",
        domain: "comptes",
        category: "validation",
        severity: "error",
        message: "Invalid account secret",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret du compte invalide",
                description: "Le secret de la clé d'API est absent, hors du dossier infra/ ou illisible par l'appelant.",
                resolution: "Rangez la clé dans le coffre-fort de l'installation sous infra/ et vérifiez vos droits sur les secrets."
            },
            en: {
                label: "Invalid account secret",
                description: "The API key secret is missing, outside the infra/ folder or not readable by the caller.",
                resolution: "Store the key in the installation vault under infra/ and check your rights on secrets."
            }
        }
    }
) END;
