-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème domaines
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_DOMAIN_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_DOMAIN_NOT_FOUND CONTENT {
        code: "MAIL_DOMAIN_NOT_FOUND",
        module: "mail",
        domain: "domaines",
        category: "not_found",
        severity: "error",
        message: "Mail domain not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine introuvable",
                description: "Ce domaine n'existe pas ou n'est pas visible de votre session.",
                resolution: "Vérifiez le domaine choisi."
            },
            en: {
                label: "Domain not found",
                description: "This domain does not exist or is not visible to your session.",
                resolution: "Check the selected domain."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_DOMAIN_EXISTS) THEN (
    CREATE error_definition:MAIL_DOMAIN_EXISTS CONTENT {
        code: "MAIL_DOMAIN_EXISTS",
        module: "mail",
        domain: "domaines",
        category: "conflict",
        severity: "error",
        message: "Mail domain already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine déjà déclaré",
                description: "Un domaine de courrier existe déjà pour ce domaine ; il ne peut pas non plus être retiré de l'organisation tant qu'il sert au courrier.",
                resolution: "Utilisez le domaine de courrier existant, ou supprimez-le d'abord."
            },
            en: {
                label: "Domain already declared",
                description: "A mail domain already exists for this domain; it cannot be removed from the organization while it serves mail either.",
                resolution: "Use the existing mail domain, or delete it first."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_DOMAIN_NOT_VERIFIED) THEN (
    CREATE error_definition:MAIL_DOMAIN_NOT_VERIFIED CONTENT {
        code: "MAIL_DOMAIN_NOT_VERIFIED",
        module: "mail",
        domain: "domaines",
        category: "business",
        severity: "error",
        message: "Domain not verified",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine non vérifié",
                description: "Le domaine doit être vérifié dans l'organisation avant de recevoir du courrier.",
                resolution: "Publiez l'enregistrement DNS de vérification puis vérifiez le domaine."
            },
            en: {
                label: "Domain not verified",
                description: "The domain must be verified in the organization before it receives mail.",
                resolution: "Publish the DNS verification record, then verify the domain."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_DOMAIN_DISABLED) THEN (
    CREATE error_definition:MAIL_DOMAIN_DISABLED CONTENT {
        code: "MAIL_DOMAIN_DISABLED",
        module: "mail",
        domain: "domaines",
        category: "business",
        severity: "error",
        message: "Mail domain disabled",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine désactivé",
                description: "Ce domaine de courrier est désactivé.",
                resolution: "Réactivez le domaine avant d'y créer des adresses."
            },
            en: {
                label: "Domain disabled",
                description: "This mail domain is disabled.",
                resolution: "Enable the domain before creating addresses in it."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_DOMAIN_NOT_EMPTY) THEN (
    CREATE error_definition:MAIL_DOMAIN_NOT_EMPTY CONTENT {
        code: "MAIL_DOMAIN_NOT_EMPTY",
        module: "mail",
        domain: "domaines",
        category: "conflict",
        severity: "error",
        message: "Mail domain not empty",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine encore utilisé",
                description: "Ce domaine porte encore des adresses ou des alias.",
                resolution: "Retirez d'abord ses adresses et ses alias."
            },
            en: {
                label: "Domain still in use",
                description: "This domain still has addresses or aliases.",
                resolution: "Remove its addresses and aliases first."
            }
        }
    }
) END;
