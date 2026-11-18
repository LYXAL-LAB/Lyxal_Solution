-- ============================================================================
-- SEEDS : Types fondamentaux d'unités de mesure
-- MODULE : lyxal_base
-- TABLE  : base_unite_type
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; (Socle système is_system: true)
-- UNITÉ DE BASE : base_unit désigne l'unité de facteur 1 du type, créée ensuite par
--                 unite_initial.surql (une référence vers un enregistrement à venir est acceptée).
--                 QUANTITE et CONDITIONNEMENT n'en ont pas : leurs unités ne sont pas convertibles.
-- ============================================================================

IF !record::exists(base_unite_type:LONGUEUR) THEN (
    CREATE base_unite_type:LONGUEUR CONTENT {
        code: "LONGUEUR",
        base_unit: base_unite:M,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:SURFACE) THEN (
    CREATE base_unite_type:SURFACE CONTENT {
        code: "SURFACE",
        base_unit: base_unite:M2,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:VOLUME) THEN (
    CREATE base_unite_type:VOLUME CONTENT {
        code: "VOLUME",
        base_unit: base_unite:M3,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:MASSE) THEN (
    CREATE base_unite_type:MASSE CONTENT {
        code: "MASSE",
        base_unit: base_unite:KG,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:DUREE) THEN (
    CREATE base_unite_type:DUREE CONTENT {
        code: "DUREE",
        base_unit: base_unite:H,
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
        base_unit: base_unite:KWH,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:PUISSANCE) THEN (
    CREATE base_unite_type:PUISSANCE CONTENT {
        code: "PUISSANCE",
        base_unit: base_unite:W,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:PRESSION) THEN (
    CREATE base_unite_type:PRESSION CONTENT {
        code: "PRESSION",
        base_unit: base_unite:BAR,
        enabled: true,
        is_system: true
    }
) END;

IF !record::exists(base_unite_type:DEBIT) THEN (
    CREATE base_unite_type:DEBIT CONTENT {
        code: "DEBIT",
        base_unit: base_unite:M3H,
        enabled: true,
        is_system: true
    }
) END;
