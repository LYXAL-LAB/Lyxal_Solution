-- ============================================================================
-- SEEDS  : 01_initial_families.surql
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Définition initiale des 4 familles industrielles clés du BTP
-- STANDARD : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

IF !record::exists(ingestion_family_rule:CLOISON_PLAQUE_PLATRE) THEN (
    CREATE ingestion_family_rule:CLOISON_PLAQUE_PLATRE CONTENT {
        code: "CLOISON_PLAQUE_PLATRE",
        label: "Plaques de plâtre et systèmes de doublage",
        keywords: ["plaque", "placo", "ba13", "plâtre", "platre", "pregyplac", "gyproc"],
        standard_unit: "M2",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_family_rule:OSSATURE_METALLIQUE) THEN (
    CREATE ingestion_family_rule:OSSATURE_METALLIQUE CONTENT {
        code: "OSSATURE_METALLIQUE",
        label: "Profilés et ossatures métalliques pour cloisons et plafonds",
        keywords: ["rail", "montant", "r48", "m48", "r70", "m70", "fourrure", "f530"],
        standard_unit: "ML",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_family_rule:APPAREILLAGE_ELECTRIQUE) THEN (
    CREATE ingestion_family_rule:APPAREILLAGE_ELECTRIQUE CONTENT {
        code: "APPAREILLAGE_ELECTRIQUE",
        label: "Appareillages électriques terminaux basse tension",
        keywords: ["prise", "interrupteur", "2p+t", "va-et-vient", "poussoir", "mosaic", "odace"],
        standard_unit: "PCE",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_family_rule:ISOLATION_THERMIQUE_ACOUSTIQUE) THEN (
    CREATE ingestion_family_rule:ISOLATION_THERMIQUE_ACOUSTIQUE CONTENT {
        code: "ISOLATION_THERMIQUE_ACOUSTIQUE",
        label: "Isolants thermiques et acoustiques minéraux et biosourcés",
        keywords: ["isol", "laine", "gr32", "ibr", "verre", "roche", "rockwool", "panneau rouleau"],
        standard_unit: "M2",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
