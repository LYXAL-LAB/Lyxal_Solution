-- ============================================================================
-- MASTER DATA : définitions d'erreurs du catalogue, domaine `attribut`
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_NOT_FOUND CONTENT {
        code: "CATALOGUE_ATTRIBUT_NOT_FOUND",
        module: "catalogue",
        domain: "attribut",
        category: "not_found",
        severity: "error",
        message: "Attribut ou caractéristique introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Attribut introuvable",
                description: "La caractéristique technique spécifiée n'existe pas.",
                resolution: "Vérifiez l'identifiant de l'attribut."
            },
            en: {
                label: "Attribute not found",
                description: "The specified attribute does not exist.",
                resolution: "Check attribute identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_ALREADY_EXISTS) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_ALREADY_EXISTS CONTENT {
        code: "CATALOGUE_ATTRIBUT_ALREADY_EXISTS",
        module: "catalogue",
        domain: "attribut",
        category: "conflict",
        severity: "error",
        message: "Un attribut avec ce code existe déjà",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Attribut déjà existant",
                description: "Le code d'attribut doit être unique au catalogue.",
                resolution: "Choisissez un code unique."
            },
            en: {
                label: "Attribute already exists",
                description: "The attribute code must be unique.",
                resolution: "Choose a unique code."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_UNITE_INVALID) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_UNITE_INVALID CONTENT {
        code: "CATALOGUE_ATTRIBUT_UNITE_INVALID",
        module: "catalogue",
        domain: "attribut",
        category: "validation",
        severity: "error",
        message: "Unité de mesure associée à l'attribut invalide ou inactive",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité d'attribut invalide",
                description: "L'unité doit exister dans base_unite et être active.",
                resolution: "Spécifiez une unité de mesure existante."
            },
            en: {
                label: "Invalid attribute unit",
                description: "Unit must exist in base_unite and be active.",
                resolution: "Specify a valid unit."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_VALEUR_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_VALEUR_NOT_FOUND CONTENT {
        code: "CATALOGUE_ATTRIBUT_VALEUR_NOT_FOUND",
        module: "catalogue",
        domain: "attribut",
        category: "not_found",
        severity: "error",
        message: "Valeur d'attribut introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Valeur d'attribut introuvable",
                description: "La valeur d'attribut sélectionnée n'existe pas en base.",
                resolution: "Vérifiez l'identifiant de la valeur d'attribut."
            },
            en: {
                label: "Attribute value not found",
                description: "The specified attribute value does not exist.",
                resolution: "Check attribute value ID."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_TYPE_MISMATCH) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_TYPE_MISMATCH CONTENT {
        code: "CATALOGUE_ATTRIBUT_TYPE_MISMATCH",
        module: "catalogue",
        domain: "attribut",
        category: "validation",
        severity: "error",
        message: "La valeur ne correspond pas au type de donnée attendu",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type de valeur incompatible",
                description: "Le champ de valeur fourni ne concorde pas avec le type_donnee de l'attribut.",
                resolution: "Renseignez le champ correspondant (valeur_texte, valeur_nombre, valeur_booleen ou valeur_date)."
            },
            en: {
                label: "Value type mismatch",
                description: "Provided value field does not match the attribute's data type.",
                resolution: "Fill the appropriate value field."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_VALEUR_INVALID) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_VALEUR_INVALID CONTENT {
        code: "CATALOGUE_ATTRIBUT_VALEUR_INVALID",
        module: "catalogue",
        domain: "attribut",
        category: "validation",
        severity: "error",
        message: "La valeur n'appartient pas à l'attribut spécifié",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Valeur hors attribut",
                description: "La valeur affectée doit être rattachée à cet attribut précis.",
                resolution: "Sélectionnez une valeur autorisée de l'attribut."
            },
            en: {
                label: "Invalid attribute value association",
                description: "The value must belong to the specified attribute.",
                resolution: "Select an allowed value for the attribute."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ATTRIBUT_NOT_VARIANT_DRIVER) THEN (
    CREATE error_definition:CATALOGUE_ATTRIBUT_NOT_VARIANT_DRIVER CONTENT {
        code: "CATALOGUE_ATTRIBUT_NOT_VARIANT_DRIVER",
        module: "catalogue",
        domain: "attribut",
        category: "validation",
        severity: "error",
        message: "Cet attribut n'est pas configuré comme pilote de déclinaison",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Attribut non déclinant",
                description: "Seuls les attributs avec is_variant_driver = true peuvent différencier des variantes.",
                resolution: "Activez le drapeau is_variant_driver sur l'attribut ou utilisez-le en attribut statique."
            },
            en: {
                label: "Attribute not a variant driver",
                description: "Only attributes with is_variant_driver = true can differentiate variants.",
                resolution: "Set is_variant_driver to true or use as a static attribute."
            }
        }
    }
) END;
