-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème versions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_VERSION_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_VERSION_NOT_FOUND CONTENT {
        code: "SECRETS_VERSION_NOT_FOUND",
        module: "secrets",
        domain: "versions",
        category: "not_found",
        severity: "error",
        message: "Version not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version introuvable",
                description: "Aucune version ne correspond à ce numéro ou à cette étiquette.",
                resolution: "Vérifiez le numéro ou l'étiquette de la version."
            },
            en: {
                label: "Version not found",
                description: "No version matches this number or label.",
                resolution: "Check the version number or label."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_VERSION_CONFLICT) THEN (
    CREATE error_definition:SECRETS_VERSION_CONFLICT CONTENT {
        code: "SECRETS_VERSION_CONFLICT",
        module: "secrets",
        domain: "versions",
        category: "conflict",
        severity: "error",
        message: "Version conflict",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Conflit de version",
                description: "Une autre écriture est passée entre-temps : le numéro de version ou la clé attendus ne sont plus les bons (détail : expected).",
                resolution: "Relisez le secret puis recommencez l'écriture."
            },
            en: {
                label: "Version conflict",
                description: "Another write happened meanwhile: the expected version number or key is no longer current (detail: expected).",
                resolution: "Read the secret again, then retry the write."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_VERSION_STATE_INVALID) THEN (
    CREATE error_definition:SECRETS_VERSION_STATE_INVALID CONTENT {
        code: "SECRETS_VERSION_STATE_INVALID",
        module: "secrets",
        domain: "versions",
        category: "conflict",
        severity: "error",
        message: "Invalid version state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État de la version incompatible",
                description: "La version n'est pas dans un état qui permet cette opération (détail : state).",
                resolution: "Consultez l'état de la version avant de recommencer."
            },
            en: {
                label: "Invalid version state",
                description: "The version is not in a state that allows this operation (detail: state).",
                resolution: "Check the version state before trying again."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_VERSION_LABELED) THEN (
    CREATE error_definition:SECRETS_VERSION_LABELED CONTENT {
        code: "SECRETS_VERSION_LABELED",
        module: "secrets",
        domain: "versions",
        category: "conflict",
        severity: "error",
        message: "Version is labeled",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version étiquetée",
                description: "La version porte une étiquette (current, previous, pending…) : elle ne peut pas être détruite.",
                resolution: "Déplacez ou retirez d'abord ses étiquettes."
            },
            en: {
                label: "Version is labeled",
                description: "The version carries a label (current, previous, pending…): it cannot be destroyed.",
                resolution: "Move or remove its labels first."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_LABEL_INVALID) THEN (
    CREATE error_definition:SECRETS_LABEL_INVALID CONTENT {
        code: "SECRETS_LABEL_INVALID",
        module: "secrets",
        domain: "versions",
        category: "validation",
        severity: "error",
        message: "Invalid label",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Étiquette invalide",
                description: "L'étiquette ne peut pas être posée ou retirée : current ne se retire pas, 20 étiquettes au plus, version non détruite.",
                resolution: "Choisissez une autre étiquette ou une autre version."
            },
            en: {
                label: "Invalid label",
                description: "The label cannot be set or removed: current cannot be removed, 20 labels at most, version not destroyed.",
                resolution: "Choose another label or another version."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_ENVELOPE_INVALID) THEN (
    CREATE error_definition:SECRETS_ENVELOPE_INVALID CONTENT {
        code: "SECRETS_ENVELOPE_INVALID",
        module: "secrets",
        domain: "versions",
        category: "validation",
        severity: "error",
        message: "Invalid envelope",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Enveloppe invalide",
                description: "La valeur scellée ne respecte pas le format enc:v2 ou ne correspond pas à l'identifiant de clé annoncé.",
                resolution: "La valeur doit être scellée par le service lyxal_secrets."
            },
            en: {
                label: "Invalid envelope",
                description: "The sealed value does not follow the enc:v2 format or does not match the announced key identifier.",
                resolution: "The value must be sealed by the lyxal_secrets service."
            }
        }
    }
) END;
