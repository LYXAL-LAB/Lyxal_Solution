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
        libelle: "Kilomètre",
        abreviation: "km",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:M) THEN (
    CREATE base_unite:M CONTENT {
        code: "M",
        libelle: "Mètre",
        abreviation: "m",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:ML) THEN (
    CREATE base_unite:ML CONTENT {
        code: "ML",
        libelle: "Mètre linéaire",
        abreviation: "ml",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:CM) THEN (
    CREATE base_unite:CM CONTENT {
        code: "CM",
        libelle: "Centimètre",
        abreviation: "cm",
        type: base_unite_type:LONGUEUR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:MM) THEN (
    CREATE base_unite:MM CONTENT {
        code: "MM",
        libelle: "Millimètre",
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
        libelle: "Hectare",
        abreviation: "ha",
        type: base_unite_type:SURFACE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:M2) THEN (
    CREATE base_unite:M2 CONTENT {
        code: "M2",
        libelle: "Mètre carré",
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
        libelle: "Mètre cube",
        abreviation: "m³",
        type: base_unite_type:VOLUME,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:LTR) THEN (
    CREATE base_unite:LTR CONTENT {
        code: "LTR",
        libelle: "Litre",
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
        libelle: "Tonne",
        abreviation: "t",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:KG) THEN (
    CREATE base_unite:KG CONTENT {
        code: "KG",
        libelle: "Kilogramme",
        abreviation: "kg",
        type: base_unite_type:MASSE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:G) THEN (
    CREATE base_unite:G CONTENT {
        code: "G",
        libelle: "Gramme",
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
        libelle: "Mois",
        abreviation: "mois",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:SEM) THEN (
    CREATE base_unite:SEM CONTENT {
        code: "SEM",
        libelle: "Semaine",
        abreviation: "sem",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:J) THEN (
    CREATE base_unite:J CONTENT {
        code: "J",
        libelle: "Jour",
        abreviation: "j",
        type: base_unite_type:DUREE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:H) THEN (
    CREATE base_unite:H CONTENT {
        code: "H",
        libelle: "Heure",
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
        libelle: "Unité",
        abreviation: "U",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:PCE) THEN (
    CREATE base_unite:PCE CONTENT {
        code: "PCE",
        libelle: "Pièce",
        abreviation: "pce",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:ENS) THEN (
    CREATE base_unite:ENS CONTENT {
        code: "ENS",
        libelle: "Ensemble",
        abreviation: "ens",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:PAIRE) THEN (
    CREATE base_unite:PAIRE CONTENT {
        code: "PAIRE",
        libelle: "Paire",
        abreviation: "paire",
        type: base_unite_type:QUANTITE,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:FORFAIT) THEN (
    CREATE base_unite:FORFAIT CONTENT {
        code: "FORFAIT",
        libelle: "Forfait",
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
        libelle: "Rouleau",
        abreviation: "roul",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:SAC) THEN (
    CREATE base_unite:SAC CONTENT {
        code: "SAC",
        libelle: "Sac",
        abreviation: "sac",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:PAL) THEN (
    CREATE base_unite:PAL CONTENT {
        code: "PAL",
        libelle: "Palette",
        abreviation: "pal",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:BTE) THEN (
    CREATE base_unite:BTE CONTENT {
        code: "BTE",
        libelle: "Boîte",
        abreviation: "bte",
        type: base_unite_type:CONDITIONNEMENT,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite:CART) THEN (
    CREATE base_unite:CART CONTENT {
        code: "CART",
        libelle: "Carton",
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
        libelle: "Kilowatt-heure",
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
        libelle: "Watt",
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
        libelle: "Bar",
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
        libelle: "Mètre cube par heure",
        abreviation: "m³/h",
        type: base_unite_type:DEBIT,
        enabled: true,
        is_system: true
    }
) END;
