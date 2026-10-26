-- ============================================================================
-- SEEDS : Types fondamentaux du catalogue universel
-- MODULE : lyxal_catalogue
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS (is_system: true)
-- ============================================================================

CREATE catalogue_type CONTENT {
    id: catalogue_type:PRODUIT,
    code: "PRODUIT",
    libelle: "Produit physique ou fourniture marchande",
    description: "Matériaux, composants, consommables et marchandises physiques stockables ou livrables.",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_type CONTENT {
    id: catalogue_type:SERVICE,
    code: "SERVICE",
    libelle: "Prestation ou service immatériel",
    description: "Interventions, missions de conseil, études, formation ou prestations externalisées.",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_type CONTENT {
    id: catalogue_type:OUVRAGE,
    code: "OUVRAGE",
    libelle: "Ouvrage technique ou unité d'exécution",
    description: "Assemblage technique combinant fournitures et main d'œuvre de pose (ex: m² de cloison, fenêtre posée).",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_type CONTENT {
    id: catalogue_type:RESSOURCE,
    code: "RESSOURCE",
    libelle: "Moyen de production et d'exécution",
    description: "Main d'œuvre interne (compagnons), engins, outillage lourd ou matériel de production amorti.",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE catalogue_type CONTENT {
    id: catalogue_type:ENSEMBLE,
    code: "ENSEMBLE",
    libelle: "Ensemble commercial, pack ou kit",
    description: "Regroupement commercial ou logistique d'articles vendus sous une référence unique.",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};
