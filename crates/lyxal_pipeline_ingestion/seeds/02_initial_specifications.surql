-- ============================================================================
-- SEEDS  : 02_initial_specifications.surql
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Spécifications techniques patronnes de référence et tolérances BTP
-- STANDARD : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

IF !record::exists(ingestion_specification:SPEC_GEN_PLAQUE_BA13_2500x1200) THEN (
    CREATE ingestion_specification:SPEC_GEN_PLAQUE_BA13_2500x1200 CONTENT {
        technical_identity_key: "SPEC_GEN_PLAQUE_BA13_2500x1200",
        family_code: "CLOISON_PLAQUE_PLATRE",
        generic_title: "Plaque de plâtre standard type A 2500x1200x12.5mm bords amincis",
        nominal_dimensions: {
            length_mm: 2500.0,
            width_mm: 1200.0,
            height_mm: 12.5
        },
        tolerances: {
            length_tol_mm: 5.0,
            width_tol_mm: 5.0,
            height_tol_mm: 1.0,
            weight_tol_pct: 5.0
        },
        standard_norm: "NF EN 520",
        fire_rating: "A2-S1,D0",
        required_features: {
            edge_type: "BA"
        },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_specification:SPEC_GEN_RAIL_R48_3M) THEN (
    CREATE ingestion_specification:SPEC_GEN_RAIL_R48_3M CONTENT {
        technical_identity_key: "SPEC_GEN_RAIL_R48_3M",
        family_code: "OSSATURE_METALLIQUE",
        generic_title: "Rail métallique profilé en U pour ossature R48 longueur 3.00m",
        nominal_dimensions: {
            length_mm: 3000.0,
            width_mm: 48.0,
            height_mm: 0.6
        },
        tolerances: {
            length_tol_mm: 10.0,
            width_tol_mm: 2.0,
            height_tol_mm: 0.1,
            weight_tol_pct: 5.0
        },
        standard_norm: "NF EN 14195",
        fire_rating: "A1",
        required_features: {
            profile_width_mm: "48"
        },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_specification:SPEC_GEN_PRISE_2PT_16A_ENC) THEN (
    CREATE ingestion_specification:SPEC_GEN_PRISE_2PT_16A_ENC CONTENT {
        technical_identity_key: "SPEC_GEN_PRISE_2PT_16A_ENC",
        family_code: "APPAREILLAGE_ELECTRIQUE",
        generic_title: "Socle de prise de courant 2P+T 16A 230V avec éclipses encastré",
        nominal_dimensions: NONE,
        tolerances: {
            length_tol_mm: 0.0,
            width_tol_mm: 0.0,
            height_tol_mm: 0.0,
            weight_tol_pct: 0.0
        },
        standard_norm: "NF C 15-100",
        fire_rating: NONE,
        required_features: {
            amperage_a: "16",
            voltage_v: "230",
            pole_configuration: "2P+T"
        },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_specification:SPEC_GEN_LAINE_VERRE_GR32_100MM) THEN (
    CREATE ingestion_specification:SPEC_GEN_LAINE_VERRE_GR32_100MM CONTENT {
        technical_identity_key: "SPEC_GEN_LAINE_VERRE_GR32_100MM",
        family_code: "ISOLATION_THERMIQUE_ACOUSTIQUE",
        generic_title: "Panneau roulé de laine de verre semi-rigide lambda 0.032 épaisseur 100mm R=3.15",
        nominal_dimensions: {
            length_mm: 2700.0,
            width_mm: 1200.0,
            height_mm: 100.0
        },
        tolerances: {
            length_tol_mm: 20.0,
            width_tol_mm: 10.0,
            height_tol_mm: 5.0,
            weight_tol_pct: 5.0
        },
        standard_norm: "NF EN 13162",
        fire_rating: "A1",
        required_features: {
            insulation_material: "LAINE_DE_VERRE",
            thermal_lambda: "0.032"
        },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_specification:SPEC_GEN_LAINE_ROCHE_100MM) THEN (
    CREATE ingestion_specification:SPEC_GEN_LAINE_ROCHE_100MM CONTENT {
        technical_identity_key: "SPEC_GEN_LAINE_ROCHE_100MM",
        family_code: "ISOLATION_THERMIQUE_ACOUSTIQUE",
        generic_title: "Panneau rigide de laine de roche lambda 0.035 épaisseur 100mm R=2.85",
        nominal_dimensions: {
            length_mm: 1200.0,
            width_mm: 600.0,
            height_mm: 100.0
        },
        tolerances: {
            length_tol_mm: 10.0,
            width_tol_mm: 10.0,
            height_tol_mm: 5.0,
            weight_tol_pct: 5.0
        },
        standard_norm: "NF EN 13162",
        fire_rating: "A1",
        required_features: {
            insulation_material: "LAINE_DE_ROCHE",
            thermal_lambda: "0.035"
        },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
