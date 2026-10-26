-- ============================================================================
-- SEEDS  : 03_initial_aliases.surql
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Alias initiaux des fabricants BTP et unités raccordées à base_unite
-- STANDARD : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ALIAS FABRICANTS & ENTITÉS JURIDIQUES DISTINCTES
-- ----------------------------------------------------------------------------

IF !record::exists(ingestion_manufacturer_alias:SAINT_GOBAIN_PLACO) THEN (
    CREATE ingestion_manufacturer_alias:SAINT_GOBAIN_PLACO CONTENT {
        raw_alias: "SAINT-GOBAIN PLACO",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:PLACOPLATRE) THEN (
    CREATE ingestion_manufacturer_alias:PLACOPLATRE CONTENT {
        raw_alias: "PLACOPLATRE",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:PLACO) THEN (
    CREATE ingestion_manufacturer_alias:PLACO CONTENT {
        raw_alias: "PLACO",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:SAINT_GOBAIN_ISOVER) THEN (
    CREATE ingestion_manufacturer_alias:SAINT_GOBAIN_ISOVER CONTENT {
        raw_alias: "SAINT-GOBAIN ISOVER",
        canonical_name: "ISOVER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:ISOVER) THEN (
    CREATE ingestion_manufacturer_alias:ISOVER CONTENT {
        raw_alias: "ISOVER",
        canonical_name: "ISOVER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:SAINT_GOBAIN_WEBER) THEN (
    CREATE ingestion_manufacturer_alias:SAINT_GOBAIN_WEBER CONTENT {
        raw_alias: "SAINT-GOBAIN WEBER",
        canonical_name: "WEBER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:WEBER) THEN (
    CREATE ingestion_manufacturer_alias:WEBER CONTENT {
        raw_alias: "WEBER",
        canonical_name: "WEBER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:KNAUF_SAS) THEN (
    CREATE ingestion_manufacturer_alias:KNAUF_SAS CONTENT {
        raw_alias: "KNAUF SAS",
        canonical_name: "KNAUF",
        holding_or_group: "KNAUF GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:KNAUF) THEN (
    CREATE ingestion_manufacturer_alias:KNAUF CONTENT {
        raw_alias: "KNAUF",
        canonical_name: "KNAUF",
        holding_or_group: "KNAUF GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:SINIAT_FRANCE) THEN (
    CREATE ingestion_manufacturer_alias:SINIAT_FRANCE CONTENT {
        raw_alias: "SINIAT FRANCE",
        canonical_name: "SINIAT",
        holding_or_group: "ETEX GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:SINIAT) THEN (
    CREATE ingestion_manufacturer_alias:SINIAT CONTENT {
        raw_alias: "SINIAT",
        canonical_name: "SINIAT",
        holding_or_group: "ETEX GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:LEGRAND_FRANCE) THEN (
    CREATE ingestion_manufacturer_alias:LEGRAND_FRANCE CONTENT {
        raw_alias: "LEGRAND FRANCE",
        canonical_name: "LEGRAND",
        holding_or_group: "LEGRAND GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:LEGRAND) THEN (
    CREATE ingestion_manufacturer_alias:LEGRAND CONTENT {
        raw_alias: "LEGRAND",
        canonical_name: "LEGRAND",
        holding_or_group: "LEGRAND GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:SCHNEIDER_ELECTRIC) THEN (
    CREATE ingestion_manufacturer_alias:SCHNEIDER_ELECTRIC CONTENT {
        raw_alias: "SCHNEIDER ELECTRIC",
        canonical_name: "SCHNEIDER",
        holding_or_group: "SCHNEIDER GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:SCHNEIDER) THEN (
    CREATE ingestion_manufacturer_alias:SCHNEIDER CONTENT {
        raw_alias: "SCHNEIDER",
        canonical_name: "SCHNEIDER",
        holding_or_group: "SCHNEIDER GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:ROCKWOOL_FRANCE) THEN (
    CREATE ingestion_manufacturer_alias:ROCKWOOL_FRANCE CONTENT {
        raw_alias: "ROCKWOOL FRANCE",
        canonical_name: "ROCKWOOL",
        holding_or_group: "ROCKWOOL GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:ROCKWOOL) THEN (
    CREATE ingestion_manufacturer_alias:ROCKWOOL CONTENT {
        raw_alias: "ROCKWOOL",
        canonical_name: "ROCKWOOL",
        holding_or_group: "ROCKWOOL GROUP",
        is_verified: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- ----------------------------------------------------------------------------
-- 2. ALIAS D'UNITÉS RACCORDÉS À base_unite
-- ----------------------------------------------------------------------------

IF !record::exists(ingestion_unit_alias:M2) THEN (
    CREATE ingestion_unit_alias:M2 CONTENT {
        raw_alias: "M2",
        canonical_unit: "M2",
        comment: "Mètre carré",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:SQM) THEN (
    CREATE ingestion_unit_alias:SQM CONTENT {
        raw_alias: "SQM",
        canonical_unit: "M2",
        comment: "Square meter (anglais)",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:MTK) THEN (
    CREATE ingestion_unit_alias:MTK CONTENT {
        raw_alias: "MTK",
        canonical_unit: "M2",
        comment: "UN/CEFACT square metre",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:PCE) THEN (
    CREATE ingestion_unit_alias:PCE CONTENT {
        raw_alias: "PCE",
        canonical_unit: "PCE",
        comment: "Pièce",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:PIECE) THEN (
    CREATE ingestion_unit_alias:PIECE CONTENT {
        raw_alias: "PIECE",
        canonical_unit: "PCE",
        comment: "Pièce",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:C62) THEN (
    CREATE ingestion_unit_alias:C62 CONTENT {
        raw_alias: "C62",
        canonical_unit: "PCE",
        comment: "UN/CEFACT one/piece",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:M) THEN (
    CREATE ingestion_unit_alias:M CONTENT {
        raw_alias: "M",
        canonical_unit: "M",
        comment: "Mètre",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:MTR) THEN (
    CREATE ingestion_unit_alias:MTR CONTENT {
        raw_alias: "MTR",
        canonical_unit: "M",
        comment: "UN/CEFACT metre",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:ML) THEN (
    CREATE ingestion_unit_alias:ML CONTENT {
        raw_alias: "ML",
        canonical_unit: "ML",
        comment: "Mètre linéaire",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:KG) THEN (
    CREATE ingestion_unit_alias:KG CONTENT {
        raw_alias: "KG",
        canonical_unit: "KG",
        comment: "Kilogramme",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(ingestion_unit_alias:KGM) THEN (
    CREATE ingestion_unit_alias:KGM CONTENT {
        raw_alias: "KGM",
        canonical_unit: "KG",
        comment: "UN/CEFACT kilogram",
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
