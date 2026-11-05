-- ============================================================================
-- SEEDS  : 04_carrelage_demo.surql
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Configuration de démonstration famille Carrelage (Validation CTO 7.1)
-- STANDARD : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

-- 1. Déclaration de la famille Carrelage sans aucune recompilation Rust
IF !record::exists(ingestion_family_rule:CARRELAGE_REVETEMENT_SOL) THEN (
    CREATE ingestion_family_rule:CARRELAGE_REVETEMENT_SOL CONTENT {
        code: "CARRELAGE_REVETEMENT_SOL",
        label: "Carrelages et revêtements de sols céramiques",
        keywords: ["carrelage", "gres", "grès", "cerame", "cérame", "faience", "faïence", "dalle sol"],
        standard_unit: "M2",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- 2. Spécification technique patronne 60x60cm
IF !record::exists(ingestion_specification:SPEC_GEN_CARRELAGE_GRES_60X60) THEN (
    CREATE ingestion_specification:SPEC_GEN_CARRELAGE_GRES_60X60 CONTENT {
        technical_identity_key: "SPEC_GEN_CARRELAGE_GRES_60X60",
        family_code: "CARRELAGE_REVETEMENT_SOL",
        generic_title: "Carrelage sol grès cérame émaillé 60x60cm épaisseur 10mm",
        nominal_dimensions: {
            length_mm: 600.0,
            width_mm: 600.0,
            height_mm: 10.0
        },
        tolerances: {
            length_tol_mm: 2.0,
            width_tol_mm: 2.0,
            height_tol_mm: 1.0,
            weight_tol_pct: 5.0
        },
        standard_norm: "NF EN 14411",
        fire_rating: "A1_FL",
        required_features: {
            material: "GRES_CERAME"
        },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- 3. Alias fabricant Marazzi
IF !record::exists(ingestion_manufacturer_alias:MARAZZI_GROUP) THEN (
    CREATE ingestion_manufacturer_alias:MARAZZI_GROUP CONTENT {
        raw_alias: "MARAZZI GROUP",
        canonical_name: "MARAZZI",
        holding_or_group: "MOHAWK INDUSTRIES",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
