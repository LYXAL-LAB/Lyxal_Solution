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
-- ============================================================================
-- ERREURS CANONIQUES : Domaine VARIANTE (Déclinaisons, Attributs, Empreintes)
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_NOT_FOUND",
    module: "catalogue",
    domain: "variante",
    category: "not_found",
    severity: "error",
    message: "Déclinaison de variante introuvable",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Variante introuvable",
            description: "La variante spécifiée n'existe pas.",
            resolution: "Vérifiez l'identifiant de la variante."
        },
        en: {
            label: "Variant not found",
            description: "The specified variant does not exist.",
            resolution: "Check variant ID."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_CODE_REQUIRED",
    module: "catalogue",
    domain: "variante",
    category: "validation",
    severity: "error",
    message: "Le code de la déclinaison variante est obligatoire",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code variante obligatoire",
            description: "Le code SKU de la variante ne peut pas être vide.",
            resolution: "Fournissez un code pour la variante."
        },
        en: {
            label: "Variant code required",
            description: "The variant SKU code cannot be empty.",
            resolution: "Provide a variant code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_ALREADY_EXISTS",
    module: "catalogue",
    domain: "variante",
    category: "conflict",
    severity: "error",
    message: "Une variante avec ce code existe déjà",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code variante déjà existant",
            description: "Le code de la déclinaison doit être unique.",
            resolution: "Utilisez un code de déclinaison distinct."
        },
        en: {
            label: "Variant code already exists",
            description: "The variant code must be unique.",
            resolution: "Use a different variant code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_ITEM_MISMATCH",
    module: "catalogue",
    domain: "variante",
    category: "validation",
    severity: "error",
    message: "La variante ne correspond pas à l'élément parent spécifié",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Discordance variante / item",
            description: "La variante n'est pas une déclinaison de l'article parent indiqué.",
            resolution: "Vérifiez la concordance entre la variante et l'article parent."
        },
        en: {
            label: "Variant item mismatch",
            description: "The variant does not belong to the specified parent item.",
            resolution: "Ensure variant matches the parent item."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_DUPLICATE_COMBINAISON",
    module: "catalogue",
    domain: "variante",
    category: "conflict",
    severity: "error",
    message: "Une variante avec cette exacte combinaison d'attributs existe déjà",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Combinaison d'attributs en doublon",
            description: "L'empreinte SHA-256 de cette combinaison est déjà assignée à une autre variante de cet item.",
            resolution: "Choisissez une combinaison distinctive d'attributs."
        },
        en: {
            label: "Duplicate variant combination",
            description: "The SHA-256 fingerprint for this combination is already in use by another variant.",
            resolution: "Select a distinct combination of attributes."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_REQUIRES_SPECIFIC",
    module: "catalogue",
    domain: "variante",
    category: "validation",
    severity: "error",
    message: "L'élément possède des variantes : une déclinaison précise doit être spécifiée",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Variante précise requise",
            description: "L'article consommé possède des déclinaisons actives ; le champ composant_variante est obligatoire.",
            resolution: "Indiquez l'identifiant de la déclinaison précise à consommer."
        },
        en: {
            label: "Specific variant required",
            description: "The item has variants; composant_variante must be specified.",
            resolution: "Provide the specific variant to consume."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_VARIANTE_FINGERPRINT_FORBIDDEN",
    module: "catalogue",
    domain: "variante",
    category: "authorization",
    severity: "error",
    message: "Modification directe de l'empreinte interdite : l'empreinte doit correspondre aux attributs réels",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Altération d'empreinte interdite",
            description: "L'empreinte canonique est calculée exclusivement par les événements moteur.",
            resolution: "Passez par la fonction métier fn::catalogue_variante_set_attributs."
        },
        en: {
            label: "Fingerprint alteration forbidden",
            description: "Canonical fingerprint is computed exclusively by engine events.",
            resolution: "Use fn::catalogue_variante_set_attributs."
        }
    }
};
-- ============================================================================
-- ERREURS CANONIQUES : Domaine COMPOSITION (Nomenclatures, Ouvrages, Cycles)
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_NOT_FOUND",
    module: "catalogue",
    domain: "composition",
    category: "not_found",
    severity: "error",
    message: "Composition de nomenclature introuvable",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Composition introuvable",
            description: "La composition demandée n'existe pas en base.",
            resolution: "Vérifiez l'identifiant de la composition."
        },
        en: {
            label: "Composition not found",
            description: "The requested composition does not exist.",
            resolution: "Check composition ID."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_NOT_DRAFT",
    module: "catalogue",
    domain: "composition",
    category: "validation",
    severity: "error",
    message: "Seule une composition en statut DRAFT peut être éditée ou publiée",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Statut non éditable",
            description: "Une composition scellée (PUBLISHED ou ARCHIVED) ne peut être altérée.",
            resolution: "Clonez la version vers un nouveau brouillon via fn::catalogue_composition_clone_version."
        },
        en: {
            label: "Composition not in draft",
            description: "A sealed composition (PUBLISHED or ARCHIVED) cannot be modified.",
            resolution: "Clone to a new draft using fn::catalogue_composition_clone_version."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_EMPTY",
    module: "catalogue",
    domain: "composition",
    category: "validation",
    severity: "error",
    message: "Une composition ne peut pas être publiée sans comporter au moins une ligne de composant",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Composition vide",
            description: "L'ouvrage ou ensemble doit comporter au moins un article ou prestation composant.",
            resolution: "Ajoutez au moins un composant via fn::catalogue_composition_add_line avant de publier."
        },
        en: {
            label: "Empty composition",
            description: "The composition must contain at least one line before publication.",
            resolution: "Add at least one component before publishing."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_IMMUTABLE",
    module: "catalogue",
    domain: "composition",
    category: "authorization",
    severity: "error",
    message: "Une composition scellée est strictement immuable (verrou moteur actif)",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Composition scellée immuable",
            description: "Les modifications, ajouts et suppressions de lignes sont interdits sur une version publiée.",
            resolution: "Créez une nouvelle version via clonage pour apporter des ajustements."
        },
        en: {
            label: "Sealed composition immutable",
            description: "Modifications and deletions are forbidden on published compositions.",
            resolution: "Clone into a new version to make adjustments."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_CYCLE_DETECTED",
    module: "catalogue",
    domain: "composition",
    category: "validation",
    severity: "error",
    message: "Cycle interdit détecté dans l'arborescence des compositions",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Boucle de nomenclature détectée",
            description: "Un ouvrage ne peut pas se consommer lui-même directement ou indirectement.",
            resolution: "Vérifiez l'arborescence des composants pour éviter toute circularité."
        },
        en: {
            label: "Composition cycle detected",
            description: "An item cannot consume itself directly or indirectly.",
            resolution: "Check component tree to eliminate circular dependencies."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_CYCLE_DEPTH_EXCEEDED",
    module: "catalogue",
    domain: "composition",
    category: "validation",
    severity: "error",
    message: "Limite technique de profondeur atteinte lors du contrôle anti-cycle des compositions",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Profondeur d'analyse dépassée",
            description: "La chaîne de dépendances dépasse la profondeur maximale analysable par le moteur.",
            resolution: "Vérifiez la structure de l'arborescence pour simplifier les niveaux d'imbrication."
        },
        en: {
            label: "Cycle check depth exceeded",
            description: "The dependency chain exceeds maximum supported depth limit.",
            resolution: "Verify composition hierarchy to reduce nesting levels."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_COMPOSITION_UNITE_INCOMPATIBLE",
    module: "catalogue",
    domain: "composition",
    category: "validation",
    severity: "error",
    message: "Unité de consommation incompatible ou invalide",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Unité de consommation invalide",
            description: "L'unité indiquée pour la ligne de composant n'existe pas ou est inactive.",
            resolution: "Renseignez une unité valide."
        },
        en: {
            label: "Incompatible consumption unit",
            description: "The specified unit does not exist or is inactive.",
            resolution: "Provide a valid unit."
        }
    }
};
-- ============================================================================
-- ERREURS CANONIQUES : Domaine RELATION (Liaisons transversales inter-éléments)
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_SELF_REFERENCED",
    module: "catalogue",
    domain: "relation",
    category: "validation",
    severity: "error",
    message: "Une relation ne peut pas lier un élément à lui-même",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Auto-liaison interdite",
            description: "L'élément source et l'élément cible d'une relation doivent être distincts.",
            resolution: "Sélectionnez deux éléments différents."
        },
        en: {
            label: "Self-referencing relation forbidden",
            description: "Source and target items of a relation must be distinct.",
            resolution: "Select two distinct items."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_TYPE_NOT_FOUND",
    module: "catalogue",
    domain: "relation",
    category: "not_found",
    severity: "error",
    message: "Type de relation inter-éléments introuvable ou inactif",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Type de relation introuvable",
            description: "Le type de relation spécifié n'existe pas dans catalogue_relation_type ou est inactif.",
            resolution: "Sélectionnez un type de relation actif (ACCESSOIRE, SUBSTITUT, SIMILAIRE, COMPATIBLE, OBLIGATOIRE)."
        },
        en: {
            label: "Relation type not found",
            description: "The specified relation type does not exist or is inactive.",
            resolution: "Select an active relation type."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_NOT_FOUND",
    module: "catalogue",
    domain: "relation",
    category: "not_found",
    severity: "error",
    message: "Relation inter-éléments introuvable",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Relation introuvable",
            description: "La liaison demandée n'existe pas.",
            resolution: "Vérifiez l'identifiant de la relation."
        },
        en: {
            label: "Relation not found",
            description: "The requested relation does not exist.",
            resolution: "Check relation ID."
        }
    }
};

-- ============================================================================
-- ERREURS MASTER CATALOGUE : Références commerciales & Synchronisation
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Un article générique ne peut comporter ni fabricant, ni marque, ni référence usine, ni code-barres",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Générique avec marque interdit",
            description: "Une référence générique normative doit rester neutre sans données de fabricant ou code-barres.",
            resolution: "Supprimez les informations de fabricant ou définissez la nature sur COMMERCIALE."
        },
        en: {
            label: "Generic item cannot have brand data",
            description: "A generic normative item must remain neutral without manufacturer data or barcode.",
            resolution: "Remove brand/manufacturer fields or set nature to COMMERCIALE."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Un article commercial doit obligatoirement spécifier un fabricant ou une marque",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Fabricant ou marque obligatoire",
            description: "Toute référence marchande commerciale doit être rattachée à un industriel ou une marque.",
            resolution: "Renseignez le champ fabricant ou marque."
        },
        en: {
            label: "Commercial item requires brand or manufacturer",
            description: "Every commercial item must be linked to a manufacturer or brand.",
            resolution: "Provide manufacturer or brand field."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_NATURE_INVALID",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Nature de référence invalide (doit être GENERIQUE ou COMMERCIALE)",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Nature de référence invalide",
            description: "La nature de référence doit obligatoirement valoir GENERIQUE ou COMMERCIALE.",
            resolution: "Indiquez GENERIQUE ou COMMERCIALE."
        },
        en: {
            label: "Invalid item nature",
            description: "Item nature must be either GENERIQUE or COMMERCIALE.",
            resolution: "Set nature to GENERIQUE or COMMERCIALE."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_GTIN_INVALID",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Code-barres GTIN/EAN invalide (clé de contrôle GS1 Modulo 10 incorrecte)",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code GTIN invalide",
            description: "Le code GTIN/EAN ne respecte pas l'algorithme officiel de contrôle GS1 Modulo 10.",
            resolution: "Vérifiez le code-barres et sa clé de contrôle terminale."
        },
        en: {
            label: "Invalid GTIN/EAN checksum",
            description: "The provided barcode fails GS1 Modulo 10 checksum verification.",
            resolution: "Verify the barcode digits and checksum."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_GTIN_ALREADY_EXISTS",
    module: "catalogue",
    domain: "item",
    category: "conflict",
    severity: "error",
    message: "Un article avec ce code-barres GTIN/EAN existe déjà au catalogue",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Code-barres déjà attribué",
            description: "L'identifiant GS1 GTIN/EAN doit être universellement unique.",
            resolution: "Vérifiez si l'article n'est pas déjà enregistré au catalogue."
        },
        en: {
            label: "Duplicate GTIN barcode",
            description: "The GTIN/EAN code is globally unique and already assigned.",
            resolution: "Search for the existing item or verify barcode."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_FAB_REF_DUPLICATE",
    module: "catalogue",
    domain: "item",
    category: "conflict",
    severity: "error",
    message: "Cette référence fabricant existe déjà pour ce fabricant",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Référence fabricant dupliquée",
            description: "Un fabricant ne peut pas posséder deux articles distincts avec la même référence usine.",
            resolution: "Vérifiez la référence fabricant ou mettez à jour l'article existant."
        },
        en: {
            label: "Duplicate manufacturer SKU",
            description: "A manufacturer cannot have multiple items with the same reference code.",
            resolution: "Check manufacturer reference code."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_MASTER_ID_DUPLICATE",
    module: "catalogue",
    domain: "item",
    category: "conflict",
    severity: "error",
    message: "Une référence locale est déjà associée à cet identifiant maître de synchronisation",
    default_language: "fr",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Article maître déjà synchronisé",
            description: "Une base cliente ne peut pas synchroniser deux fois la même référence maîtresse.",
            resolution: "Mettez à jour la référence locale existante au lieu d'en créer une nouvelle."
        },
        en: {
            label: "Duplicate master reference ID",
            description: "A tenant database cannot synchronize the same master item twice.",
            resolution: "Update the existing local synced item instead."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_MASTER_ID_IMMUTABLE",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "L'identifiant maître d'un article synchronisé est strictement immuable",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Identifiant maître immuable",
            description: "Il est interdit de modifier la référence vers le catalogue maître une fois établie.",
            resolution: "Conservez le lien maître d'origine."
        },
        en: {
            label: "Master reference ID is immutable",
            description: "The master catalogue identifier cannot be altered once bound.",
            resolution: "Preserve original master linkage."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_SYNC_CANNOT_CONVERT_CUSTOM",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Un article synchronisé du Master ne peut pas être converti en article privé",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Conversion en article privé interdite",
            description: "Un article rattaché au Master Catalogue ne peut pas devenir privé.",
            resolution: "Créez un nouvel article privé avec is_custom: true et master_id: NONE."
        },
        en: {
            label: "Cannot convert synced item to custom",
            description: "A synchronized master item cannot be changed into a private custom item.",
            resolution: "Create a separate custom item instead."
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


-- ============================================================================
-- ERREURS MASTER CATALOGUE : Relations générique / commerciale & remplacement
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID",
    module: "catalogue",
    domain: "relation",
    category: "validation",
    severity: "error",
    message: "La relation COMMERCIAL_SPECIFICATION exige une source commerciale et une cible générique",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Liaison commerciale/générique invalide",
            description: "Une spécification commerciale doit relier un article COMMERCIAL vers un article GÉNÉRIQUE.",
            resolution: "Vérifiez la nature de la source (COMMERCIALE) et de la cible (GENERIQUE)."
        },
        en: {
            label: "Invalid commercial specification link",
            description: "A commercial specification must link a COMMERCIAL source to a GENERIQUE target.",
            resolution: "Verify item natures."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID",
    module: "catalogue",
    domain: "relation",
    category: "validation",
    severity: "error",
    message: "L'article cible de remplacement doit être actif et non obsolète",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Cible de remplacement invalide",
            description: "Un article de remplacement doit être activé et ne peut pas être lui-même obsolète.",
            resolution: "Sélectionnez un article de substitution actif."
        },
        en: {
            label: "Invalid replacement target",
            description: "A replacement target must be active and not obsolete.",
            resolution: "Select an active substitute item."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_REMPLACEMENT_CYCLE",
    module: "catalogue",
    domain: "relation",
    category: "validation",
    severity: "error",
    message: "Détection d'un cycle de remplacement direct ou indirect interdit",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Cycle de remplacement interdit",
            description: "La chaîne de remplacement forme une boucle fermée (A remplace B qui remplace A).",
            resolution: "Supprimez la boucle de substitution."
        },
        en: {
            label: "Replacement cycle detected",
            description: "The replacement sequence forms a closed loop.",
            resolution: "Break the replacement loop."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_RELATION_CYCLE_DEPTH_EXCEEDED",
    module: "catalogue",
    domain: "relation",
    category: "internal",
    severity: "error",
    message: "Limite de profondeur atteinte lors du contrôle anti-cycle de relation",
    default_language: "fr",
    http_status: 500,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Profondeur de relation dépassée",
            description: "Le parcours de contrôle anti-cycle a atteint sa limite technique maximale.",
            resolution: "Vérifiez la structure du graphe de relations."
        },
        en: {
            label: "Relation depth exceeded",
            description: "Anti-cycle traversal reached the maximum depth limit.",
            resolution: "Inspect graph structure."
        }
    }
};

-- ============================================================================
-- ERREURS CANONIQUES : Domaine ITEM (Isolation Multi-Tenant et Propriété Privée)
-- ============================================================================

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_TENANT_REQUIRED",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Identité cliente avec tenant_id valide obligatoire pour toute opération sur article privé",
    default_language: "fr",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Propriétaire client obligatoire",
            description: "La création, modification ou suppression d'un article privé exige un tenant_id valide déduit de l'identité authentifiée.",
            resolution: "Authentifiez-vous avec une identité cliente valide contenant un tenant_id."
        },
        en: {
            label: "Tenant ID required",
            description: "Custom item operations require a valid authenticated tenant_id.",
            resolution: "Authenticate with a tenant account."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_TENANT_FORBIDDEN",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Accès ou opération interdite : cet article privé appartient à une autre organisation",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Accès inter-organisations interdit",
            description: "Un locataire ne peut pas accéder, modifier ou supprimer les articles privés d'une autre entreprise.",
            resolution: "Vérifiez vos autorisations d'accès."
        },
        en: {
            label: "Tenant access forbidden",
            description: "Access to private items belonging to another organisation is strictly denied.",
            resolution: "Verify your organisation credentials."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_TENANT_ID_IMMUTABLE",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Le propriétaire tenant_id d'un article est strictement immuable",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Propriétaire immuable",
            description: "Le champ tenant_id ne peut jamais être modifié après la création de l'article.",
            resolution: "La propriété d'un article ne peut pas être transférée."
        },
        en: {
            label: "Tenant ID immutable",
            description: "The tenant_id field cannot be altered once created.",
            resolution: "Item ownership cannot be transferred."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_TENANT_ORPHAN",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Article privé orphelin sans propriétaire vérifiable : opération interdite",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Article privé orphelin",
            description: "Cet article privé ne possède aucun identifiant de propriétaire vérifiable en base.",
            resolution: "Contactez l'administrateur système pour réconciliation."
        },
        en: {
            label: "Orphan custom item",
            description: "This custom item has no verifiable tenant owner.",
            resolution: "Contact system administrator."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Le service catalogue_sync_agent ne doit pas lire, modifier ou supprimer les articles privés des clients",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Accès agent sync interdit sur articles privés",
            description: "L'agent de synchronisation du Master Catalogue est strictement confiné aux articles maîtres.",
            resolution: "Le service de synchronisation ne traite que les flux de données maîtresses."
        },
        en: {
            label: "Sync agent cannot access custom items",
            description: "Master catalogue sync agent is strictly restricted to master items.",
            resolution: "Sync operations cannot target custom client items."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Le service catalogue_sync_agent ne peut pas créer d'articles privés pour les clients",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Création d'article privé interdite pour l'agent sync",
            description: "L'agent de synchronisation ne peut injecter que des articles maîtres (is_custom = false).",
            resolution: "Spécifiez is_custom = false pour les imports de l'agent de synchronisation."
        },
        en: {
            label: "Sync agent cannot create custom items",
            description: "Sync agent can only create master items.",
            resolution: "Use is_custom = false for sync imports."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Les articles synchronisés du Master Catalogue ne peuvent pas être supprimés localement",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Suppression d'article maître interdite",
            description: "Un article issu du Master Catalogue ne peut pas être supprimé localement. Utilisez la désactivation (enabled = false).",
            resolution: "Désactivez l'article localement au lieu de le supprimer."
        },
        en: {
            label: "Master item deletion forbidden",
            description: "Items synchronized from Master Catalogue cannot be deleted locally.",
            resolution: "Disable the item instead of deleting it."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID",
    module: "catalogue",
    domain: "item",
    category: "validation",
    severity: "error",
    message: "Un article privé ne peut pas avoir d'identifiant maître",
    default_language: "fr",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Identifiant maître interdit sur article privé",
            description: "Un article privé créé localement par un client ne peut pas référencer un master_id.",
            resolution: "Omettez master_id lors de la création d'articles privés."
        },
        en: {
            label: "Custom item cannot have master ID",
            description: "A private custom item cannot have a master_id.",
            resolution: "Omit master_id for custom items."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER",
    module: "catalogue",
    domain: "item",
    category: "authorization",
    severity: "error",
    message: "Un article privé ne peut pas être converti en article maître",
    default_language: "fr",
    http_status: 403,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Conversion en article maître interdite",
            description: "La nature privée d'un article local (is_custom = true) est immuable et ne peut être altérée.",
            resolution: "Créez un nouvel article via le flux Master officiel."
        },
        en: {
            label: "Cannot convert custom item to master",
            description: "A private custom item cannot be transformed into a master item.",
            resolution: "Create master items via the official Master pipeline."
        }
    }
};


