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
