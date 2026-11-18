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

IF !record::exists(error_definition:BASE_LIBELLE_WRITE_FAILED) THEN (
    CREATE error_definition:BASE_LIBELLE_WRITE_FAILED CONTENT {
        code: "BASE_LIBELLE_WRITE_FAILED",
        module: "base",
        domain: "unite",
        category: "business",
        severity: "error",
        message: "Libellé non enregistré",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Libellé non enregistré",
                description: "Le libellé n'a pas pu être écrit dans les traductions (cause : code d'erreur reçu de lyxal_i18n). Rien n'a été modifié.",
                resolution: "Vérifiez vos droits sur les traductions et le libellé saisi."
            },
            en: {
                label: "Label not saved",
                description: "The label could not be written to the translations (cause: error code received from lyxal_i18n). Nothing was changed.",
                resolution: "Check your rights on translations and the label entered."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_LIBELLE_READ_FAILED) THEN (
    CREATE error_definition:BASE_LIBELLE_READ_FAILED CONTENT {
        code: "BASE_LIBELLE_READ_FAILED",
        module: "base",
        domain: "unite",
        category: "business",
        severity: "error",
        message: "Libellé illisible",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Libellé illisible",
                description: "Le libellé n'a pas pu être lu dans les traductions (cause : code d'erreur reçu de lyxal_i18n).",
                resolution: "Vérifiez la langue demandée."
            },
            en: {
                label: "Label unreadable",
                description: "The label could not be read from the translations (cause: error code received from lyxal_i18n).",
                resolution: "Check the requested language."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_TYPE_MISMATCH) THEN (
    CREATE error_definition:BASE_UNITE_TYPE_MISMATCH CONTENT {
        code: "BASE_UNITE_TYPE_MISMATCH",
        module: "base",
        domain: "unite",
        category: "validation",
        severity: "error",
        message: "Les deux unités ne sont pas du même type",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unités de types différents",
                description: "Une quantité ne se convertit qu'entre deux unités du même type (deux longueurs, deux masses…).",
                resolution: "Choisissez deux unités du même type d'unité."
            },
            en: {
                label: "Units of different types",
                description: "A quantity can only be converted between two units of the same type (two lengths, two masses…).",
                resolution: "Choose two units of the same unit type."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_NOT_CONVERTIBLE) THEN (
    CREATE error_definition:BASE_UNITE_NOT_CONVERTIBLE CONTENT {
        code: "BASE_UNITE_NOT_CONVERTIBLE",
        module: "base",
        domain: "unite",
        category: "validation",
        severity: "error",
        message: "Cette unité n'est pas convertible",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité non convertible",
                description: "L'unité n'a pas de facteur de conversion, son type n'a pas d'unité de base, ou l'unité ou son type est désactivé (détail reason : no_factor, no_base_unit, disabled).",
                resolution: "Utilisez une unité active dotée d'un facteur de conversion, ou saisissez la quantité directement dans l'unité voulue."
            },
            en: {
                label: "Unit not convertible",
                description: "The unit has no conversion factor, its type has no base unit, or the unit or its type is disabled (detail reason: no_factor, no_base_unit, disabled).",
                resolution: "Use an active unit with a conversion factor, or enter the quantity directly in the target unit."
            }
        }
    }
) END;

IF !record::exists(error_definition:BASE_UNITE_BASE_INVALID) THEN (
    CREATE error_definition:BASE_UNITE_BASE_INVALID CONTENT {
        code: "BASE_UNITE_BASE_INVALID",
        module: "base",
        domain: "unite",
        category: "validation",
        severity: "error",
        message: "Unité de base invalide",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité de base invalide",
                description: "L'unité de base d'un type est une unité de ce type, de facteur 1 ; tant qu'elle est l'unité de base, elle garde ce facteur et ce type (détail reason : not_found, other_type, factor_not_one, base_unit_factor, base_unit_type).",
                resolution: "Désignez une unité du même type dont le facteur vaut 1, ou désignez d'abord une autre unité de base pour le type."
            },
            en: {
                label: "Invalid base unit",
                description: "The base unit of a type is a unit of that type with factor 1; while it is the base unit, it keeps that factor and that type (detail reason: not_found, other_type, factor_not_one, base_unit_factor, base_unit_type).",
                resolution: "Designate a unit of the same type whose factor is 1, or first designate another base unit for the type."
            }
        }
    }
) END;
