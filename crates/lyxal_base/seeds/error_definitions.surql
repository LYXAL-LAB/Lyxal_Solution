-- ============================================================================
-- SEEDS : Catalogue canonique des erreurs du module lyxal_base
-- MODULE : lyxal_base
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_TYPE_CODE_REQUIRED",
    module: "base",
    domain: "unite_type",
    category: "validation",
    severity: "error",
    message: "Le code du type d'unité est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code obligatoire",
            description: "Le code technique du type d'unité n'a pas été renseigné.",
            resolution: "Renseignez un code technique pour ce type d'unité."
        },
        en: {
            label: "Code required",
            description: "The technical code for the unit type was not provided.",
            resolution: "Provide a technical code for this unit type."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_TYPE_CODE_INVALID",
    module: "base",
    domain: "unite_type",
    category: "validation",
    severity: "error",
    message: "Le code du type d'unité est invalide",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code invalide",
            description: "Le code doit être alphanumérique et comporter entre 1 et 32 caractères.",
            resolution: "Corrigez le code pour respecter les contraintes alphanumériques (1-32 caractères)."
        },
        en: {
            label: "Invalid code",
            description: "Code must be alphanumeric and between 1 and 32 characters long.",
            resolution: "Fix code to respect alphanumeric constraints (1-32 characters)."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_TYPE_LIBELLE_REQUIRED",
    module: "base",
    domain: "unite_type",
    category: "validation",
    severity: "error",
    message: "Le libellé du type d'unité est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé obligatoire",
            description: "Le libellé du type d'unité n'a pas été renseigné.",
            resolution: "Renseignez un libellé descriptif pour le type d'unité."
        },
        en: {
            label: "Label required",
            description: "The label for the unit type was not provided.",
            resolution: "Provide a descriptive label for this unit type."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_TYPE_LIBELLE_INVALID",
    module: "base",
    domain: "unite_type",
    category: "validation",
    severity: "error",
    message: "Le libellé du type d'unité est invalide",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé invalide",
            description: "Le libellé doit comporter entre 1 et 128 caractères.",
            resolution: "Ajustez la taille du libellé pour respecter la limite de 128 caractères."
        },
        en: {
            label: "Invalid label",
            description: "Label must be between 1 and 128 characters long.",
            resolution: "Adjust label size to respect 128 characters limit."
        }
    }
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_TYPE_DISABLED",
    module: "base",
    domain: "unite_type",
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_CODE_REQUIRED",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "Le code de l'unité est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code obligatoire",
            description: "Le code technique de l'unité est manquant.",
            resolution: "Renseignez un code technique pour l'unité."
        },
        en: {
            label: "Code required",
            description: "The technical code for the unit was not provided.",
            resolution: "Provide a technical code for the unit."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_CODE_INVALID",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "Le code de l'unité est invalide",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code invalide",
            description: "Le code de l'unité doit être alphanumérique et comporter entre 1 et 32 caractères.",
            resolution: "Corrigez le code pour respecter les contraintes alphanumériques (1-32 caractères)."
        },
        en: {
            label: "Invalid code",
            description: "Unit code must be alphanumeric and between 1 and 32 characters long.",
            resolution: "Fix code to respect alphanumeric constraints (1-32 characters)."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_LIBELLE_REQUIRED",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "Le libellé de l'unité est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé obligatoire",
            description: "Le libellé de l'unité n'a pas été renseigné.",
            resolution: "Renseignez un libellé pour l'unité."
        },
        en: {
            label: "Label required",
            description: "Unit label was not provided.",
            resolution: "Provide a label for the unit."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_LIBELLE_INVALID",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "Le libellé de l'unité est invalide",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé invalide",
            description: "Le libellé doit comporter entre 1 et 128 caractères.",
            resolution: "Ajustez la taille du libellé pour respecter la limite de 128 caractères."
        },
        en: {
            label: "Invalid label",
            description: "Label must be between 1 and 128 characters long.",
            resolution: "Adjust label size to respect 128 characters limit."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_ABREVIATION_REQUIRED",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "L'abréviation de l'unité est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Abréviation obligatoire",
            description: "L'abréviation de l'unité n'a pas été fournie.",
            resolution: "Renseignez une abréviation courte pour l'unité (ex: m, m², kg)."
        },
        en: {
            label: "Abbreviation required",
            description: "Unit abbreviation was not provided.",
            resolution: "Provide a short abbreviation for the unit (e.g. m, m², kg)."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_ABREVIATION_INVALID",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "L'abréviation de l'unité est invalide",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Abréviation invalide",
            description: "L'abréviation doit comporter entre 1 et 10 caractères.",
            resolution: "Ajustez l'abréviation pour respecter la limite de 10 caractères."
        },
        en: {
            label: "Invalid abbreviation",
            description: "Abbreviation must be between 1 and 10 characters long.",
            resolution: "Adjust abbreviation to respect 10 characters limit."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_UNITE_TYPE_REQUIRED",
    module: "base",
    domain: "unite",
    category: "validation",
    severity: "error",
    message: "La référence vers un type d'unité est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Type d'unité obligatoire",
            description: "L'unité doit obligatoirement être rattachée à un type d'unité.",
            resolution: "Spécifiez le champ type (ex: unite_type:LONGUEUR)."
        },
        en: {
            label: "Unit type required",
            description: "Unit must be linked to a unit type.",
            resolution: "Specify the type field (e.g. unite_type:LONGUEUR)."
        }
    }
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
    code: "BASE_NO_UPDATABLE_FIELDS_PROVIDED",
    module: "base",
    domain: "general",
    category: "validation",
    severity: "error",
    message: "Aucun champ modifiable n'a été fourni",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Aucun champ à modifier",
            description: "La requête de mise à jour ne contient aucun champ modifiable.",
            resolution: "Fournissez au moins un champ valide à mettre à jour."
        },
        en: {
            label: "No updatable fields",
            description: "The update request does not contain any modifiable field.",
            resolution: "Provide at least one valid field to update."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BASE_PAGINATION_INVALID",
    module: "base",
    domain: "general",
    category: "validation",
    severity: "error",
    message: "Paramètres de pagination invalides",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Pagination invalide",
            description: "La valeur de limit doit être comprise entre 1 et 200, et start doit être supérieur ou égal à 0.",
            resolution: "Corrigez les paramètres limit et start."
        },
        en: {
            label: "Invalid pagination",
            description: "Limit must be between 1 and 200, and start must be greater than or equal to 0.",
            resolution: "Fix limit and start parameters."
        }
    }
};

CREATE error_definition CONTENT {
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
};

CREATE error_definition CONTENT {
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
};
