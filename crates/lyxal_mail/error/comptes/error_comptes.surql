-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème comptes
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_ACCOUNT_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_ACCOUNT_NOT_FOUND CONTENT {
        code: "MAIL_ACCOUNT_NOT_FOUND",
        module: "mail",
        domain: "comptes",
        category: "not_found",
        severity: "error",
        message: "Mail account not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte introuvable",
                description: "Ce compte de courrier n'existe pas ou n'est pas visible de votre session.",
                resolution: "Vérifiez le compte choisi."
            },
            en: {
                label: "Account not found",
                description: "This mail account does not exist or is not visible to your session.",
                resolution: "Check the selected account."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ACCOUNT_EXISTS) THEN (
    CREATE error_definition:MAIL_ACCOUNT_EXISTS CONTENT {
        code: "MAIL_ACCOUNT_EXISTS",
        module: "mail",
        domain: "comptes",
        category: "conflict",
        severity: "error",
        message: "Mail account already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte déjà créé",
                description: "Ce membre a déjà un compte de courrier dans l'organisation.",
                resolution: "Ajoutez une adresse au compte existant."
            },
            en: {
                label: "Account already exists",
                description: "This member already has a mail account in the organization.",
                resolution: "Add an address to the existing account."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ACCOUNT_NOT_MEMBER) THEN (
    CREATE error_definition:MAIL_ACCOUNT_NOT_MEMBER CONTENT {
        code: "MAIL_ACCOUNT_NOT_MEMBER",
        module: "mail",
        domain: "comptes",
        category: "business",
        severity: "error",
        message: "Identity is not a member of the organization",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Personne hors de l'organisation",
                description: "Un compte de courrier ne se crée que pour un membre actif de l'organisation.",
                resolution: "Ajoutez d'abord la personne à l'organisation."
            },
            en: {
                label: "Not a member",
                description: "A mail account can only be created for an active member of the organization.",
                resolution: "Add the person to the organization first."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ACCOUNT_DISABLED) THEN (
    CREATE error_definition:MAIL_ACCOUNT_DISABLED CONTENT {
        code: "MAIL_ACCOUNT_DISABLED",
        module: "mail",
        domain: "comptes",
        category: "business",
        severity: "error",
        message: "Mail account disabled",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte désactivé",
                description: "Ce compte de courrier est désactivé : aucune écriture ni remise.",
                resolution: "Demandez sa réactivation à un administrateur."
            },
            en: {
                label: "Account disabled",
                description: "This mail account is disabled: no writes and no delivery.",
                resolution: "Ask an administrator to enable it again."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ACCOUNT_DELETING) THEN (
    CREATE error_definition:MAIL_ACCOUNT_DELETING CONTENT {
        code: "MAIL_ACCOUNT_DELETING",
        module: "mail",
        domain: "comptes",
        category: "conflict",
        severity: "error",
        message: "Mail account being deleted",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte en suppression",
                description: "Ce compte de courrier est en cours de suppression.",
                resolution: "Aucune action n'est possible sur ce compte."
            },
            en: {
                label: "Account being deleted",
                description: "This mail account is being deleted.",
                resolution: "No action is possible on this account."
            }
        }
    }
) END;
