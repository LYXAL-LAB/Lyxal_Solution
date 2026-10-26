-- ============================================================================
-- SEEDS : Types fondamentaux d'unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite_type
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS (Socle système is_system: true)
-- ============================================================================

CREATE base_unite_type CONTENT {
    id: base_unite_type:LONGUEUR,
    code: "LONGUEUR",
    libelle: "LONGUEUR",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite_type CONTENT {
    id: base_unite_type:SURFACE,
    code: "SURFACE",
    libelle: "SURFACE",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite_type CONTENT {
    id: base_unite_type:VOLUME,
    code: "VOLUME",
    libelle: "VOLUME",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite_type CONTENT {
    id: base_unite_type:MASSE,
    code: "MASSE",
    libelle: "MASSE",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite_type CONTENT {
    id: base_unite_type:DUREE,
    code: "DUREE",
    libelle: "DURÉE",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite_type CONTENT {
    id: base_unite_type:QUANTITE,
    code: "QUANTITE",
    libelle: "QUANTITÉ / DÉCOMPTE",
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};
