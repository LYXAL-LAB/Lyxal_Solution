-- ============================================================================
-- SEEDS : Référentiel initial standard des unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS (Socle système is_system: true)
-- ============================================================================

-- ============================================================================
-- 1. LONGUEURS (base_unite_type:LONGUEUR)
-- ============================================================================

CREATE base_unite CONTENT {
    id: base_unite:KM,
    code: "KM",
    libelle: "KILOMÈTRE",
    abreviation: "km",
    type: base_unite_type:LONGUEUR,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:M,
    code: "M",
    libelle: "MÈTRE",
    abreviation: "m",
    type: base_unite_type:LONGUEUR,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:ML,
    code: "ML",
    libelle: "MÈTRE LINÉAIRE",
    abreviation: "ml",
    type: base_unite_type:LONGUEUR,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:CM,
    code: "CM",
    libelle: "CENTIMÈTRE",
    abreviation: "cm",
    type: base_unite_type:LONGUEUR,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 2. SURFACES (base_unite_type:SURFACE)
-- ============================================================================

CREATE base_unite CONTENT {
    id: base_unite:HA,
    code: "HA",
    libelle: "HECTARE",
    abreviation: "ha",
    type: base_unite_type:SURFACE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:M2,
    code: "M2",
    libelle: "MÈTRE CARRÉ",
    abreviation: "m²",
    type: base_unite_type:SURFACE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 3. VOLUMES (base_unite_type:VOLUME)
-- ============================================================================

CREATE base_unite CONTENT {
    id: base_unite:M3,
    code: "M3",
    libelle: "MÈTRE CUBE",
    abreviation: "m³",
    type: base_unite_type:VOLUME,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:L,
    code: "L",
    libelle: "LITRE",
    abreviation: "L",
    type: base_unite_type:VOLUME,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 4. MASSES (base_unite_type:MASSE)
-- ============================================================================

CREATE base_unite CONTENT {
    id: base_unite:T,
    code: "T",
    libelle: "TONNE",
    abreviation: "t",
    type: base_unite_type:MASSE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:KG,
    code: "KG",
    libelle: "KILOGRAMME",
    abreviation: "kg",
    type: base_unite_type:MASSE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:GR,
    code: "GR",
    libelle: "GRAMME",
    abreviation: "gr",
    type: base_unite_type:MASSE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 5. DURÉES (base_unite_type:DUREE)
-- ============================================================================

CREATE base_unite CONTENT {
    id: base_unite:MOIS,
    code: "MOIS",
    libelle: "MOIS",
    abreviation: "mois",
    type: base_unite_type:DUREE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:SEM,
    code: "SEM",
    libelle: "SEMAINE",
    abreviation: "sem",
    type: base_unite_type:DUREE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:J,
    code: "J",
    libelle: "JOUR",
    abreviation: "j",
    type: base_unite_type:DUREE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:H,
    code: "H",
    libelle: "HEURE",
    abreviation: "h",
    type: base_unite_type:DUREE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 6. QUANTITÉS, DÉCOMPTES & CONDITIONNEMENTS (base_unite_type:QUANTITE)
-- ============================================================================

CREATE base_unite CONTENT {
    id: base_unite:U,
    code: "U",
    libelle: "UNITÉ",
    abreviation: "U",
    type: base_unite_type:QUANTITE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:PCE,
    code: "PCE",
    libelle: "PIÈCE",
    abreviation: "pce",
    type: base_unite_type:QUANTITE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:ENS,
    code: "ENS",
    libelle: "ENSEMBLE",
    abreviation: "ens",
    type: base_unite_type:QUANTITE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:PAIRE,
    code: "PAIRE",
    libelle: "PAIRE",
    abreviation: "paire",
    type: base_unite_type:QUANTITE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};

CREATE base_unite CONTENT {
    id: base_unite:FORFAIT,
    code: "FORFAIT",
    libelle: "FORFAIT",
    abreviation: "forf",
    type: base_unite_type:QUANTITE,
    enabled: true,
    is_system: true,
    created_at: time::now(),
    updated_at: time::now()
};
