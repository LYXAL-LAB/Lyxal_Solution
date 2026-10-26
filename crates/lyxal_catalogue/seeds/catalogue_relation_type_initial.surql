-- ============================================================================
-- SEEDS : Types fondamentaux de relations inter-éléments
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS (is_system: true)
-- ============================================================================

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:ACCESSOIRE,
    code: "ACCESSOIRE",
    libelle: "Accessoire complémentaire recommandé",
    is_bidirectionnelle: false,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:SUBSTITUT,
    code: "SUBSTITUT",
    libelle: "Article de remplacement ou équivalent technique",
    is_bidirectionnelle: true,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:SIMILAIRE,
    code: "SIMILAIRE",
    libelle: "Article similaire de gamme comparable",
    is_bidirectionnelle: true,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:COMPATIBLE,
    code: "COMPATIBLE",
    libelle: "Composant compatible",
    is_bidirectionnelle: true,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:OBLIGATOIRE,
    code: "OBLIGATOIRE",
    libelle: "Composant indissociable obligatoire pour fonctionnement",
    is_bidirectionnelle: false,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    code: "COMMERCIAL_SPECIFICATION",
    libelle: "Spécification commerciale d'un article générique normatif",
    is_bidirectionnelle: false,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_relation_type CONTENT {
    id: catalogue_relation_type:REMPLACEMENT,
    code: "REMPLACEMENT",
    libelle: "Article de remplacement d'une référence obsolète ou abandonnée",
    is_bidirectionnelle: false,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

