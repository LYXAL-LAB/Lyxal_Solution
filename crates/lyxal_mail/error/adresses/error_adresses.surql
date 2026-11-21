-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème adresses
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_ADDRESS_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_ADDRESS_NOT_FOUND CONTENT {
        code: "MAIL_ADDRESS_NOT_FOUND",
        module: "mail",
        domain: "adresses",
        category: "not_found",
        severity: "error",
        message: "Mail address not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse introuvable",
                description: "Cette adresse n'existe pas ou n'est pas visible de votre session.",
                resolution: "Vérifiez l'adresse choisie."
            },
            en: {
                label: "Address not found",
                description: "This address does not exist or is not visible to your session.",
                resolution: "Check the selected address."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ADDRESS_EXISTS) THEN (
    CREATE error_definition:MAIL_ADDRESS_EXISTS CONTENT {
        code: "MAIL_ADDRESS_EXISTS",
        module: "mail",
        domain: "adresses",
        category: "conflict",
        severity: "error",
        message: "Mail address already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse déjà prise",
                description: "Cette adresse existe déjà.",
                resolution: "Choisissez une autre partie locale."
            },
            en: {
                label: "Address taken",
                description: "This address already exists.",
                resolution: "Choose another local part."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ADDRESS_IS_PRIMARY) THEN (
    CREATE error_definition:MAIL_ADDRESS_IS_PRIMARY CONTENT {
        code: "MAIL_ADDRESS_IS_PRIMARY",
        module: "mail",
        domain: "adresses",
        category: "conflict",
        severity: "error",
        message: "Primary address cannot be removed",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse principale",
                description: "L'adresse principale d'un compte ne se retire pas.",
                resolution: "Supprimez le compte pour retirer son adresse principale."
            },
            en: {
                label: "Primary address",
                description: "The primary address of an account cannot be removed.",
                resolution: "Delete the account to remove its primary address."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ADDRESS_LIMIT) THEN (
    CREATE error_definition:MAIL_ADDRESS_LIMIT CONTENT {
        code: "MAIL_ADDRESS_LIMIT",
        module: "mail",
        domain: "adresses",
        category: "business",
        severity: "error",
        message: "Address limit reached",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trop d'adresses",
                description: "Ce compte a atteint le nombre maximal d'adresses.",
                resolution: "Retirez une adresse ou relevez la limite dans les réglages."
            },
            en: {
                label: "Too many addresses",
                description: "This account has reached the maximum number of addresses.",
                resolution: "Remove an address or raise the limit in the settings."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_ALIAS_TARGET_INVALID) THEN (
    CREATE error_definition:MAIL_ALIAS_TARGET_INVALID CONTENT {
        code: "MAIL_ALIAS_TARGET_INVALID",
        module: "mail",
        domain: "adresses",
        category: "validation",
        severity: "error",
        message: "Invalid alias target",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Destinataires de l'alias invalides",
                description: "Un alias vise de 1 à 50 comptes actifs de la même organisation.",
                resolution: "Choisissez des comptes de l'organisation."
            },
            en: {
                label: "Invalid alias targets",
                description: "An alias targets 1 to 50 live accounts of the same organization.",
                resolution: "Choose accounts of the organization."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_RECIPIENT_UNKNOWN) THEN (
    CREATE error_definition:MAIL_RECIPIENT_UNKNOWN CONTENT {
        code: "MAIL_RECIPIENT_UNKNOWN",
        module: "mail",
        domain: "adresses",
        category: "not_found",
        severity: "error",
        message: "Unknown recipient",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Destinataire inconnu",
                description: "Aucun compte actif ne reçoit le courrier de cette adresse.",
                resolution: "Vérifiez l'adresse du destinataire."
            },
            en: {
                label: "Unknown recipient",
                description: "No active account receives mail for this address.",
                resolution: "Check the recipient address."
            }
        }
    }
) END;
