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
