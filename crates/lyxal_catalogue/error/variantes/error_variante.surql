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
