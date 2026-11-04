-- ============================================================================
-- SEEDS : Types fondamentaux d'unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite_type
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; (Socle système is_system: true)
-- ============================================================================

IF !record::exists(base_unite_type:LONGUEUR) THEN (
    CREATE base_unite_type:LONGUEUR CONTENT {
        code: "LONGUEUR",
        libelle: "LONGUEUR",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite_type:SURFACE) THEN (
    CREATE base_unite_type:SURFACE CONTENT {
        code: "SURFACE",
        libelle: "SURFACE",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite_type:VOLUME) THEN (
    CREATE base_unite_type:VOLUME CONTENT {
        code: "VOLUME",
        libelle: "VOLUME",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite_type:MASSE) THEN (
    CREATE base_unite_type:MASSE CONTENT {
        code: "MASSE",
        libelle: "MASSE",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite_type:DUREE) THEN (
    CREATE base_unite_type:DUREE CONTENT {
        code: "DUREE",
        libelle: "DURÉE",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(base_unite_type:QUANTITE) THEN (
    CREATE base_unite_type:QUANTITE CONTENT {
        code: "QUANTITE",
        libelle: "QUANTITÉ / DÉCOMPTE",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
