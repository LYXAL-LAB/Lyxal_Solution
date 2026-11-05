-- ============================================================================
-- MASTER DATA : définitions d'erreurs du catalogue, domaine `variante`
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:CATALOGUE_VARIANTE_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_VARIANTE_NOT_FOUND CONTENT {
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
    }
) END;

IF !record::exists(error_definition:CATALOGUE_VARIANTE_ALREADY_EXISTS) THEN (
    CREATE error_definition:CATALOGUE_VARIANTE_ALREADY_EXISTS CONTENT {
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
    }
) END;

IF !record::exists(error_definition:CATALOGUE_VARIANTE_ITEM_MISMATCH) THEN (
    CREATE error_definition:CATALOGUE_VARIANTE_ITEM_MISMATCH CONTENT {
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
    }
) END;

IF !record::exists(error_definition:CATALOGUE_VARIANTE_REQUIRES_SPECIFIC) THEN (
    CREATE error_definition:CATALOGUE_VARIANTE_REQUIRES_SPECIFIC CONTENT {
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
    }
) END;

IF !record::exists(error_definition:CATALOGUE_VARIANTE_FINGERPRINT_FORBIDDEN) THEN (
    CREATE error_definition:CATALOGUE_VARIANTE_FINGERPRINT_FORBIDDEN CONTENT {
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
    }
) END;
