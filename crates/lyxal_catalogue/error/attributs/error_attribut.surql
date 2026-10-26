-- ============================================================================
-- ERREURS CANONIQUES : Domaine ATTRIBUT (Caractéristiques et valeurs typées)
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ATTRIBUT_CODE_REQUIRED",
    module: "catalogue",
    domain: "attribut",
    category: "validation",
    severity: "error",
    message: "Le code de l'attribut est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code d'attribut obligatoire",
            description: "Le code de la caractéristique ne peut être vide.",
            resolution: "Fournissez un code pour l'attribut."
        },
        en: {
            label: "Attribute code required",
            description: "The attribute code cannot be empty.",
            resolution: "Provide an attribute code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ATTRIBUT_LIBELLE_REQUIRED",
    module: "catalogue",
    domain: "attribut",
    category: "validation",
    severity: "error",
    message: "Le libellé de l'attribut est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé d'attribut obligatoire",
            description: "La désignation de l'attribut ne peut être vide.",
            resolution: "Renseignez un libellé pour l'attribut."
        },
        en: {
            label: "Attribute label required",
            description: "The attribute label cannot be empty.",
            resolution: "Provide an attribute label."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ATTRIBUT_TYPE_INVALID",
    module: "catalogue",
    domain: "attribut",
    category: "validation",
    severity: "error",
    message: "Type de donnée d'attribut invalide (STRING, NUMBER, BOOLEAN, DATE, COLOR requis)",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Type de donnée invalide",
            description: "Le type doit faire partie des types autorisés : STRING, NUMBER, BOOLEAN, DATE, COLOR.",
            resolution: "Utilisez un type de donnée valide."
        },
        en: {
            label: "Invalid attribute data type",
            description: "The data type must be one of: STRING, NUMBER, BOOLEAN, DATE, COLOR.",
            resolution: "Use a supported data type."
        }
    }
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ATTRIBUT_VALEUR_CODE_REQUIRED",
    module: "catalogue",
    domain: "attribut",
    category: "validation",
    severity: "error",
    message: "Le code de la valeur d'attribut est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code de valeur obligatoire",
            description: "Le code de la valeur d'attribut ne peut pas être vide.",
            resolution: "Renseignez un code pour la valeur."
        },
        en: {
            label: "Value code required",
            description: "The attribute value code cannot be empty.",
            resolution: "Provide a value code."
        }
    }
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};
