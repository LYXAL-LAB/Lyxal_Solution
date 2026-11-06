-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_base, types d'unités
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:BASE_UNITE_TYPE_NOT_FOUND) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_NOT_FOUND CONTENT {
        code: "BASE_UNITE_TYPE_NOT_FOUND",
        module: "base",
        domain: "unite_type",
        category: "not_found",
        severity: "error",
        message: "Type d'unité introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'unité introuvable",
                description: "Le type d'unité demandé n'existe pas.",
                resolution: "Vérifiez l'identifiant ou le code du type d'unité."
            },
            en: {
                label: "Unit type not found",
                description: "The requested unit type does not exist.",
                resolution: "Check the unit type identifier or code."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_TYPE_ALREADY_EXISTS) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_ALREADY_EXISTS CONTENT {
        code: "BASE_UNITE_TYPE_ALREADY_EXISTS",
        module: "base",
        domain: "unite_type",
        category: "conflict",
        severity: "error",
        message: "Un type d'unité avec ce code existe déjà",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'unité déjà existant",
                description: "Un type d'unité utilisant ce code existe déjà dans le référentiel.",
                resolution: "Utilisez un code différent ou réutilisez le type existant."
            },
            en: {
                label: "Unit type already exists",
                description: "A unit type with this code already exists in repository.",
                resolution: "Use a different code or use the existing type."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_TYPE_IS_SYSTEM) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_IS_SYSTEM CONTENT {
        code: "BASE_UNITE_TYPE_IS_SYSTEM",
        module: "base",
        domain: "unite_type",
        category: "authorization",
        severity: "error",
        message: "Ce type d'unité fait partie du socle système standard et ne peut être supprimé physiquement",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'unité système protégé",
                description: "Les types d'unités du socle Lyxal OS ne peuvent pas être supprimés physiquement.",
                resolution: "Désactivez le type d'unité (enabled = false) si vous souhaitez le masquer."
            },
            en: {
                label: "System unit type protected",
                description: "Native Lyxal OS system unit types cannot be physically deleted.",
                resolution: "Disable the unit type (enabled = false) if you wish to hide it."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_TYPE_IN_USE) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_IN_USE CONTENT {
        code: "BASE_UNITE_TYPE_IN_USE",
        module: "base",
        domain: "unite_type",
        category: "conflict",
        severity: "error",
        message: "Ce type d'unité est rattaché à une ou plusieurs unités et ne peut être supprimé",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'unité utilisé",
                description: "Des unités de mesure dépendent de ce type. La suppression physique est bloquée.",
                resolution: "Supprimez ou réaffectez d'abord les unités dépendantes, ou désactivez le type d'unité."
            },
            en: {
                label: "Unit type in use",
                description: "Units depend on this unit type. Physical deletion is blocked.",
                resolution: "Delete or reassign dependent units first, or disable this unit type."
            }
        }
    }
) END;
