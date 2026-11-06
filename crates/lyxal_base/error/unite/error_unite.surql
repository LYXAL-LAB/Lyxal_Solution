-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_base, unités
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:BASE_UNITE_NOT_FOUND) THEN (
    CREATE error_definition:BASE_UNITE_NOT_FOUND CONTENT {
        code: "BASE_UNITE_NOT_FOUND",
        module: "base",
        domain: "unite",
        category: "not_found",
        severity: "error",
        message: "Unité de mesure introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité introuvable",
                description: "L'unité demandée n'existe pas dans le référentiel.",
                resolution: "Vérifiez l'identifiant ou le code de l'unité."
            },
            en: {
                label: "Unit not found",
                description: "The requested unit does not exist in repository.",
                resolution: "Check the unit identifier or code."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_ALREADY_EXISTS) THEN (
    CREATE error_definition:BASE_UNITE_ALREADY_EXISTS CONTENT {
        code: "BASE_UNITE_ALREADY_EXISTS",
        module: "base",
        domain: "unite",
        category: "conflict",
        severity: "error",
        message: "Une unité avec ce code existe déjà",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité déjà existante",
                description: "Une unité avec ce code technique existe déjà dans le référentiel.",
                resolution: "Utilisez un code différent ou utilisez l'unité existante."
            },
            en: {
                label: "Unit already exists",
                description: "A unit with this technical code already exists in repository.",
                resolution: "Use a different code or use the existing unit."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_IS_SYSTEM) THEN (
    CREATE error_definition:BASE_UNITE_IS_SYSTEM CONTENT {
        code: "BASE_UNITE_IS_SYSTEM",
        module: "base",
        domain: "unite",
        category: "authorization",
        severity: "error",
        message: "Cette unité fait partie du socle système standard et ne peut être supprimée physiquement",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité système protégée",
                description: "Les unités natives du socle Lyxal OS ne peuvent pas être supprimées physiquement.",
                resolution: "Désactivez l'unité (enabled = false) pour la masquer des formulaires et devis."
            },
            en: {
                label: "System unit protected",
                description: "Native Lyxal OS system units cannot be physically deleted.",
                resolution: "Disable the unit (enabled = false) to hide it from forms and quotes."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_IN_USE) THEN (
    CREATE error_definition:BASE_UNITE_IN_USE CONTENT {
        code: "BASE_UNITE_IN_USE",
        module: "base",
        domain: "unite",
        category: "conflict",
        severity: "error",
        message: "Cette unité est référencée dans des documents ou modules métier et ne peut être supprimée",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité utilisée",
                description: "Cette unité est liée à des documents historiques ou métrés. La suppression physique est interdite.",
                resolution: "Désactivez l'unité plutôt que de la supprimer pour préserver l'historique."
            },
            en: {
                label: "Unit in use",
                description: "This unit is linked to historical documents. Physical deletion is prohibited.",
                resolution: "Disable the unit rather than deleting it to preserve history."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_TYPE_INVALID) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_INVALID CONTENT {
        code: "BASE_UNITE_TYPE_INVALID",
        module: "base",
        domain: "unite",
        category: "validation",
        severity: "error",
        message: "Le type d'unité référencé est inexistant",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'unité inexistant",
                description: "Le type d'unité référencé n'existe pas dans le référentiel.",
                resolution: "Sélectionnez un type d'unité valide et existant."
            },
            en: {
                label: "Invalid unit type",
                description: "Referenced unit type does not exist in repository.",
                resolution: "Select a valid and existing unit type."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_TYPE_DISABLED) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_DISABLED CONTENT {
        code: "BASE_UNITE_TYPE_DISABLED",
        module: "base",
        domain: "unite",
        category: "validation",
        severity: "error",
        message: "Le type d'unité sélectionné est désactivé et ne peut accepter de nouvelles unités actives",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'unité inactif",
                description: "Il est interdit de créer ou d'activer une unité sur un type d'unité désactivé.",
                resolution: "Réactivez le type d'unité parent ou choisissez un autre type d'unité actif."
            },
            en: {
                label: "Unit type disabled",
                description: "Cannot create or activate a unit on a disabled unit type.",
                resolution: "Re-enable parent unit type or select another active unit type."
            }
        }
    }
) END;
