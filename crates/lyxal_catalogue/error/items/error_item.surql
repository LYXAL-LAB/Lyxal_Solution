-- ============================================================================
-- ERREURS CANONIQUES : Domaine ITEM (Articles, Produits, Ouvrages)
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_NOT_FOUND",
    module: "catalogue",
    domain: "item",
    category: "not_found",
    severity: "error",
    message: "Élément de catalogue introuvable",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Élément de catalogue introuvable",
            description: "L'élément de catalogue référencé n'existe pas en base.",
            resolution: "Vérifiez l'identifiant ou le code de l'élément."
        },
        en: {
            label: "Catalogue item not found",
            description: "The requested catalogue item does not exist.",
            resolution: "Check the item code or ID."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_ALREADY_EXISTS",
    module: "catalogue",
    domain: "item",
    category: "conflict",
    severity: "error",
    message: "Un élément avec ce code existe déjà",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Élément déjà existant",
            description: "Le code d'élément doit être unique au catalogue.",
            resolution: "Utilisez un code différent."
        },
        en: {
            label: "Item already exists",
            description: "The item code must be unique.",
            resolution: "Use a different code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_CODE_REQUIRED",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Le code de l'élément de catalogue est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code d'élément obligatoire",
            description: "Le code unique identifiant l'élément ne peut pas être vide.",
            resolution: "Fournissez une chaîne de caractères non vide pour le code."
        },
        en: {
            label: "Item code required",
            description: "The unique item identifier code cannot be empty.",
            resolution: "Provide a non-empty string for the code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_LIBELLE_REQUIRED",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Le libellé de l'élément de catalogue est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé d'élément obligatoire",
            description: "La désignation de l'élément de catalogue ne peut pas être vide.",
            resolution: "Renseignez un libellé textuel pour l'article ou ouvrage."
        },
        en: {
            label: "Item label required",
            description: "The item title or designation cannot be empty.",
            resolution: "Provide a descriptive label for the item."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_TYPE_NOT_FOUND",
    module: "catalogue",
    domain: "item",
    category: "not_found",
    severity: "error",
    message: "Type d'élément de catalogue introuvable ou inactif",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Type d'élément introuvable",
            description: "Le type spécifié (PRODUIT, SERVICE, OUVRAGE, RESSOURCE, ENSEMBLE) n'existe pas ou est désactivé.",
            resolution: "Sélectionnez un type fondamental actif."
        },
        en: {
            label: "Item type not found",
            description: "The specified item type does not exist or is inactive.",
            resolution: "Select an active fundamental type."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_UNITE_INVALID",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Unité de mesure de référence invalide ou inactive",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Unité de mesure invalide",
            description: "L'unité de référence doit exister dans base_unite et être active.",
            resolution: "Renseignez une unité de mesure valide du socle lyxal_base."
        },
        en: {
            label: "Invalid unit of measure",
            description: "The reference unit must exist in base_unite and be active.",
            resolution: "Provide a valid unit from lyxal_base."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_IN_USE",
    module: "catalogue",
    domain: "item",
    category: "conflict",
    severity: "error",
    message: "Impossible de supprimer un élément consommé dans des nomenclatures",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Élément en cours d'utilisation",
            description: "Cet article ou ressource est référencé dans des compositions actives.",
            resolution: "Retirez d'abord l'élément de toutes les compositions associées avant suppression."
        },
        en: {
            label: "Item in use",
            description: "This item is referenced in existing active compositions.",
            resolution: "Remove the item from all compositions before deleting."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_SYSTEM_IMMUTABLE",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Impossible de supprimer un élément de catalogue système immuable",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Élément système immuable",
            description: "Cet élément fait partie intégrante du socle système et ne peut être supprimé.",
            resolution: "Les éléments marqués is_system ne peuvent être altérés."
        },
        en: {
            label: "Immutable system item",
            description: "This item is part of the system core and cannot be deleted.",
            resolution: "System items cannot be modified or removed."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_PAGINATION_INVALID",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Paramètres de pagination invalides",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Pagination invalide",
            description: "Le paramètre limit doit être compris entre 1 et 200, et start doit être supérieur ou égal à 0.",
            resolution: "Ajustez les paramètres limit et start."
        },
        en: {
            label: "Invalid pagination",
            description: "Limit must be between 1 and 200, and start must be non-negative.",
            resolution: "Adjust limit and start parameters."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_SYNC_FIELD_PROTECTED",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Les spécifications maîtresses d'un article synchronisé ne peuvent être modifiées que par le flux Master officiel",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Champ maître synchronisé protégé",
            description: "Les caractéristiques intrinsèques d'un article synchronisé (libellé officiel, fabricant, marque, code-barres, conditionnement, documents) ne sont modifiables que par synchronisation Master. Pour une personnalisation locale, utilisez 'libelle_personnalise' ou 'code_interne_client'.",
            resolution: "Renseignez 'libelle_personnalise' ou demandez la mise à jour au gestionnaire du Master Catalogue."
        },
        en: {
            label: "Synchronized master field is protected",
            description: "Intrinsic properties of a synchronized item can only be modified by official Master sync. For local customizations, use 'libelle_personnalise' or 'code_interne_client'.",
            resolution: "Use custom local fields or update the master item in the central catalog."
        }
    }
};

