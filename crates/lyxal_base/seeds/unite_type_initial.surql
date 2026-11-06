-- ============================================================================
-- SEEDS : Types fondamentaux d'unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite_type
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; (Socle système is_system: true)
-- ============================================================================

IF !record::exists(base_unite_type:LONGUEUR) THEN (
    CREATE base_unite_type:LONGUEUR CONTENT {
        code: "LONGUEUR",
        libelle: "Longueur",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:SURFACE) THEN (
    CREATE base_unite_type:SURFACE CONTENT {
        code: "SURFACE",
        libelle: "Surface",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:VOLUME) THEN (
    CREATE base_unite_type:VOLUME CONTENT {
        code: "VOLUME",
        libelle: "Volume",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:MASSE) THEN (
    CREATE base_unite_type:MASSE CONTENT {
        code: "MASSE",
        libelle: "Masse",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:DUREE) THEN (
    CREATE base_unite_type:DUREE CONTENT {
        code: "DUREE",
        libelle: "Durée",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:QUANTITE) THEN (
    CREATE base_unite_type:QUANTITE CONTENT {
        code: "QUANTITE",
        libelle: "Quantité / décompte",
        enabled: true,
        is_system: true
    }
) END;
