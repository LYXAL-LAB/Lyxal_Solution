-- ============================================================================
-- SEEDS : Types fondamentaux d'unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite_type
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; (Socle système is_system: true)
-- ============================================================================

IF !record::exists(base_unite_type:LONGUEUR) THEN (
    CREATE base_unite_type:LONGUEUR CONTENT {
        code: "LONGUEUR",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:SURFACE) THEN (
    CREATE base_unite_type:SURFACE CONTENT {
        code: "SURFACE",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:VOLUME) THEN (
    CREATE base_unite_type:VOLUME CONTENT {
        code: "VOLUME",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:MASSE) THEN (
    CREATE base_unite_type:MASSE CONTENT {
        code: "MASSE",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:DUREE) THEN (
    CREATE base_unite_type:DUREE CONTENT {
        code: "DUREE",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:QUANTITE) THEN (
    CREATE base_unite_type:QUANTITE CONTENT {
        code: "QUANTITE",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:CONDITIONNEMENT) THEN (
    CREATE base_unite_type:CONDITIONNEMENT CONTENT {
        code: "CONDITIONNEMENT",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:ENERGIE) THEN (
    CREATE base_unite_type:ENERGIE CONTENT {
        code: "ENERGIE",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:PUISSANCE) THEN (
    CREATE base_unite_type:PUISSANCE CONTENT {
        code: "PUISSANCE",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:PRESSION) THEN (
    CREATE base_unite_type:PRESSION CONTENT {
        code: "PRESSION",
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:DEBIT) THEN (
    CREATE base_unite_type:DEBIT CONTENT {
        code: "DEBIT",
        enabled: true,
        is_system: true
    }
) END;
