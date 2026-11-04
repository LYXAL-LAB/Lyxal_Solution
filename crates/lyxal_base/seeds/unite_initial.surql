-- ============================================================================
-- SEEDS : Référentiel initial standard des unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; (Socle système is_system: true)
-- ============================================================================

-- ============================================================================
-- 1. LONGUEURS (base_unite_type:LONGUEUR)
-- ============================================================================

IF !record::exists(base_unite:KM) THEN (
    CREATE base_unite:KM CONTENT {
        code: "KM",
        libelle: "KILOMÈTRE",
        abreviation: "km",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:M) THEN (
    CREATE base_unite:M CONTENT {
        code: "M",
        libelle: "MÈTRE",
        abreviation: "m",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:ML) THEN (
    CREATE base_unite:ML CONTENT {
        code: "ML",
        libelle: "MÈTRE LINÉAIRE",
        abreviation: "ml",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:CM) THEN (
    CREATE base_unite:CM CONTENT {
        code: "CM",
        libelle: "CENTIMÈTRE",
        abreviation: "cm",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- ============================================================================
-- 2. SURFACES (base_unite_type:SURFACE)
-- ============================================================================

IF !record::exists(base_unite:HA) THEN (
    CREATE base_unite:HA CONTENT {
        code: "HA",
        libelle: "HECTARE",
        abreviation: "ha",
        type: base_unite_type:SURFACE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:M2) THEN (
    CREATE base_unite:M2 CONTENT {
        code: "M2",
        libelle: "MÈTRE CARRÉ",
        abreviation: "m²",
        type: base_unite_type:SURFACE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- ============================================================================
-- 3. VOLUMES (base_unite_type:VOLUME)
-- ============================================================================

IF !record::exists(base_unite:M3) THEN (
    CREATE base_unite:M3 CONTENT {
        code: "M3",
        libelle: "MÈTRE CUBE",
        abreviation: "m³",
        type: base_unite_type:VOLUME,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:L) THEN (
    CREATE base_unite:L CONTENT {
        code: "L",
        libelle: "LITRE",
        abreviation: "L",
        type: base_unite_type:VOLUME,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- ============================================================================
-- 4. MASSES (base_unite_type:MASSE)
-- ============================================================================

IF !record::exists(base_unite:T) THEN (
    CREATE base_unite:T CONTENT {
        code: "T",
        libelle: "TONNE",
        abreviation: "t",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:KG) THEN (
    CREATE base_unite:KG CONTENT {
        code: "KG",
        libelle: "KILOGRAMME",
        abreviation: "kg",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:GR) THEN (
    CREATE base_unite:GR CONTENT {
        code: "GR",
        libelle: "GRAMME",
        abreviation: "gr",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- ============================================================================
-- 5. DURÉES (base_unite_type:DUREE)
-- ============================================================================

IF !record::exists(base_unite:MOIS) THEN (
    CREATE base_unite:MOIS CONTENT {
        code: "MOIS",
        libelle: "MOIS",
        abreviation: "mois",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:SEM) THEN (
    CREATE base_unite:SEM CONTENT {
        code: "SEM",
        libelle: "SEMAINE",
        abreviation: "sem",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:J) THEN (
    CREATE base_unite:J CONTENT {
        code: "J",
        libelle: "JOUR",
        abreviation: "j",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:H) THEN (
    CREATE base_unite:H CONTENT {
        code: "H",
        libelle: "HEURE",
        abreviation: "h",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- ============================================================================
-- 6. QUANTITÉS, DÉCOMPTES & CONDITIONNEMENTS (base_unite_type:QUANTITE)
-- ============================================================================

IF !record::exists(base_unite:U) THEN (
    CREATE base_unite:U CONTENT {
        code: "U",
        libelle: "UNITÉ",
        abreviation: "U",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:PCE) THEN (
    CREATE base_unite:PCE CONTENT {
        code: "PCE",
        libelle: "PIÈCE",
        abreviation: "pce",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:ENS) THEN (
    CREATE base_unite:ENS CONTENT {
        code: "ENS",
        libelle: "ENSEMBLE",
        abreviation: "ens",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:PAIRE) THEN (
    CREATE base_unite:PAIRE CONTENT {
        code: "PAIRE",
        libelle: "PAIRE",
        abreviation: "paire",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite:FORFAIT) THEN (
    CREATE base_unite:FORFAIT CONTENT {
        code: "FORFAIT",
        libelle: "FORFAIT",
        abreviation: "forf",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
