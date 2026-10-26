-- ============================================================================
-- ERREURS CANONIQUES : Domaine CATEGORIE (Taxonomie arborescente)
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_NOT_FOUND",
    module: "catalogue",
    domain: "categorie",
    category: "not_found",
    severity: "error",
    message: "Catégorie de catalogue introuvable",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Catégorie introuvable",
            description: "La catégorie demandée n'existe pas en base.",
            resolution: "Vérifiez l'identifiant de la catégorie."
        },
        en: {
            label: "Category not found",
            description: "The requested catalogue category does not exist.",
            resolution: "Check category identifier."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_CODE_REQUIRED",
    module: "catalogue",
    domain: "categorie",
    category: "validation",
    severity: "error",
    message: "Le code de la catégorie est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code catégorie obligatoire",
            description: "Le code identifiant la catégorie ne peut être vide.",
            resolution: "Fournissez un code pour la catégorie."
        },
        en: {
            label: "Category code required",
            description: "The category identifier code cannot be empty.",
            resolution: "Provide a category code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_LIBELLE_REQUIRED",
    module: "catalogue",
    domain: "categorie",
    category: "validation",
    severity: "error",
    message: "Le libellé de la catégorie est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Libellé catégorie obligatoire",
            description: "Le nom ou libellé de la catégorie ne peut être vide.",
            resolution: "Renseignez un libellé descriptif pour la catégorie."
        },
        en: {
            label: "Category label required",
            description: "The category label cannot be empty.",
            resolution: "Provide a category label."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_ALREADY_EXISTS",
    module: "catalogue",
    domain: "categorie",
    category: "conflict",
    severity: "error",
    message: "Une catégorie avec ce code existe déjà",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code catégorie déjà existant",
            description: "Chaque catégorie doit avoir un code unique.",
            resolution: "Choisissez un code unique pour cette catégorie."
        },
        en: {
            label: "Category code already exists",
            description: "Each category must have a unique code.",
            resolution: "Choose a unique code for this category."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_CYCLE_DETECTED",
    module: "catalogue",
    domain: "categorie",
    category: "validation",
    severity: "error",
    message: "Boucle cyclique détectée dans la hiérarchie des catégories",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Cycle hiérarchique détecté",
            description: "Une catégorie ne peut pas devenir descendante d'elle-même.",
            resolution: "Sélectionnez un parent hiérarchiquement compatible."
        },
        en: {
            label: "Category hierarchy cycle detected",
            description: "A category cannot be a descendant of itself.",
            resolution: "Select a valid parent category."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_SYSTEM_IMMUTABLE",
    module: "catalogue",
    domain: "categorie",
    category: "authorization",
    severity: "error",
    message: "Impossible de supprimer une catégorie système immuable",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Catégorie système immuable",
            description: "Cette catégorie est protégée par le système et ne peut être supprimée.",
            resolution: "Les catégories socle ne sont pas supprimables."
        },
        en: {
            label: "System category immutable",
            description: "This category is protected and cannot be deleted.",
            resolution: "Base system categories cannot be deleted."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_HAS_CHILDREN",
    module: "catalogue",
    domain: "categorie",
    category: "conflict",
    severity: "error",
    message: "Impossible de supprimer une catégorie qui possède des sous-catégories",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Catégorie parente active",
            description: "Supprimez ou déplacez d'abord les sous-catégories enfants.",
            resolution: "Détachez les enfants avant suppression."
        },
        en: {
            label: "Category has children",
            description: "Remove or reassign child subcategories before deletion.",
            resolution: "Reassign child categories first."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_CATEGORIE_IN_USE",
    module: "catalogue",
    domain: "categorie",
    category: "conflict",
    severity: "error",
    message: "Impossible de supprimer une catégorie contenant des éléments associés",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Catégorie non vide",
            description: "Des articles du catalogue sont rattachés à cette catégorie.",
            resolution: "Détachez les éléments de la catégorie avant sa suppression."
        },
        en: {
            label: "Category in use",
            description: "Catalogue items are assigned to this category.",
            resolution: "Detach items from category before deletion."
        }
    }
};
