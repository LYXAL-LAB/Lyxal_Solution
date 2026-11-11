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
        abreviation: "km",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:M) THEN (
    CREATE base_unite:M CONTENT {
        code: "M",
        abreviation: "m",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:ML) THEN (
    CREATE base_unite:ML CONTENT {
        code: "ML",
        abreviation: "ml",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:CM) THEN (
    CREATE base_unite:CM CONTENT {
        code: "CM",
        abreviation: "cm",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:MM) THEN (
    CREATE base_unite:MM CONTENT {
        code: "MM",
        abreviation: "mm",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 2. SURFACES (base_unite_type:SURFACE)
-- ============================================================================

IF !record::exists(base_unite:HA) THEN (
    CREATE base_unite:HA CONTENT {
        code: "HA",
        abreviation: "ha",
        type: base_unite_type:SURFACE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:M2) THEN (
    CREATE base_unite:M2 CONTENT {
        code: "M2",
        abreviation: "m²",
        type: base_unite_type:SURFACE,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 3. VOLUMES (base_unite_type:VOLUME)
-- ============================================================================

IF !record::exists(base_unite:M3) THEN (
    CREATE base_unite:M3 CONTENT {
        code: "M3",
        abreviation: "m³",
        type: base_unite_type:VOLUME,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:LTR) THEN (
    CREATE base_unite:LTR CONTENT {
        code: "LTR",
        abreviation: "L",
        type: base_unite_type:VOLUME,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 4. MASSES (base_unite_type:MASSE)
-- ============================================================================

IF !record::exists(base_unite:T) THEN (
    CREATE base_unite:T CONTENT {
        code: "T",
        abreviation: "t",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:KG) THEN (
    CREATE base_unite:KG CONTENT {
        code: "KG",
        abreviation: "kg",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:G) THEN (
    CREATE base_unite:G CONTENT {
        code: "G",
        abreviation: "g",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 5. DURÉES (base_unite_type:DUREE)
-- ============================================================================

IF !record::exists(base_unite:MOIS) THEN (
    CREATE base_unite:MOIS CONTENT {
        code: "MOIS",
        abreviation: "mois",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:SEM) THEN (
    CREATE base_unite:SEM CONTENT {
        code: "SEM",
        abreviation: "sem",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:J) THEN (
    CREATE base_unite:J CONTENT {
        code: "J",
        abreviation: "j",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:H) THEN (
    CREATE base_unite:H CONTENT {
        code: "H",
        abreviation: "h",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 6. QUANTITÉS ET DÉCOMPTES (base_unite_type:QUANTITE)
-- ============================================================================

IF !record::exists(base_unite:U) THEN (
    CREATE base_unite:U CONTENT {
        code: "U",
        abreviation: "U",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:PCE) THEN (
    CREATE base_unite:PCE CONTENT {
        code: "PCE",
        abreviation: "pce",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:ENS) THEN (
    CREATE base_unite:ENS CONTENT {
        code: "ENS",
        abreviation: "ens",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:PAIRE) THEN (
    CREATE base_unite:PAIRE CONTENT {
        code: "PAIRE",
        abreviation: "paire",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:FORFAIT) THEN (
    CREATE base_unite:FORFAIT CONTENT {
        code: "FORFAIT",
        abreviation: "forf",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 7. CONDITIONNEMENTS (base_unite_type:CONDITIONNEMENT)
-- ============================================================================

IF !record::exists(base_unite:ROUL) THEN (
    CREATE base_unite:ROUL CONTENT {
        code: "ROUL",
        abreviation: "roul",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:SAC) THEN (
    CREATE base_unite:SAC CONTENT {
        code: "SAC",
        abreviation: "sac",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:PAL) THEN (
    CREATE base_unite:PAL CONTENT {
        code: "PAL",
        abreviation: "pal",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:BTE) THEN (
    CREATE base_unite:BTE CONTENT {
        code: "BTE",
        abreviation: "bte",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:CART) THEN (
    CREATE base_unite:CART CONTENT {
        code: "CART",
        abreviation: "cart",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 8. ÉNERGIE (base_unite_type:ENERGIE)
-- ============================================================================

IF !record::exists(base_unite:KWH) THEN (
    CREATE base_unite:KWH CONTENT {
        code: "KWH",
        abreviation: "kWh",
        type: base_unite_type:ENERGIE,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 9. PUISSANCE (base_unite_type:PUISSANCE)
-- ============================================================================

IF !record::exists(base_unite:W) THEN (
    CREATE base_unite:W CONTENT {
        code: "W",
        abreviation: "W",
        type: base_unite_type:PUISSANCE,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 10. PRESSION (base_unite_type:PRESSION)
-- ============================================================================

IF !record::exists(base_unite:BAR) THEN (
    CREATE base_unite:BAR CONTENT {
        code: "BAR",
        abreviation: "bar",
        type: base_unite_type:PRESSION,
        enabled: true,
        is_system: true
    }
) END;

-- ============================================================================
-- 11. DÉBIT (base_unite_type:DEBIT)
-- ============================================================================

IF !record::exists(base_unite:M3H) THEN (
    CREATE base_unite:M3H CONTENT {
        code: "M3H",
        abreviation: "m³/h",
        type: base_unite_type:DEBIT,
        enabled: true,
        is_system: true
    }
) END;
