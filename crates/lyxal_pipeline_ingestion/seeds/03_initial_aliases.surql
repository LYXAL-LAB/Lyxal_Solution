-- ============================================================================
-- SEEDS  : 03_initial_aliases.surql
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Alias initiaux des fabricants BTP et des libellés d'unités fournisseurs
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5)
--
-- Fabricants : nom normalisé (majuscules, ponctuation remplacée, espaces réduits) vers le nom
-- canonique ; les suffixes juridiques et géographiques (SAS, FRANCE…) sont retirés par
-- fn::ingestion_resolve_manufacturers, sans alias. is_verified = false : groupe sans entité
-- déterminée (le fabricant n'est pas vérifié).
-- Unités : libellés commerciaux vers un code de lyxal_base. Les codes Lyxal (M2, PCE…) et les
-- codes d'échange normalisés (MTK, C62, RO…) sont résolus par lyxal_base, sans alias.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ALIAS DE FABRICANTS
-- ----------------------------------------------------------------------------

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN PLACO⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN PLACO⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN PLACO",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN PLACO⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN PLACO⟩ CONTENT {
        raw_alias: "SAINT GOBAIN PLACO",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PLACOPLATRE⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PLACOPLATRE⟩ CONTENT {
        raw_alias: "PLACOPLATRE",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨BPB PLACO⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨BPB PLACO⟩ CONTENT {
        raw_alias: "BPB PLACO",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PLACO⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PLACO⟩ CONTENT {
        raw_alias: "PLACO",
        canonical_name: "PLACO",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨ISOVER SAINT-GOBAIN⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨ISOVER SAINT-GOBAIN⟩ CONTENT {
        raw_alias: "ISOVER SAINT-GOBAIN",
        canonical_name: "ISOVER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN ISOVER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN ISOVER⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN ISOVER",
        canonical_name: "ISOVER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN ISOVER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN ISOVER⟩ CONTENT {
        raw_alias: "SAINT GOBAIN ISOVER",
        canonical_name: "ISOVER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨ISOVER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨ISOVER⟩ CONTENT {
        raw_alias: "ISOVER",
        canonical_name: "ISOVER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN WEBER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN WEBER⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN WEBER",
        canonical_name: "WEBER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN WEBER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN WEBER⟩ CONTENT {
        raw_alias: "SAINT GOBAIN WEBER",
        canonical_name: "WEBER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨WEBER ET BROUTIN⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨WEBER ET BROUTIN⟩ CONTENT {
        raw_alias: "WEBER ET BROUTIN",
        canonical_name: "WEBER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨WEBER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨WEBER⟩ CONTENT {
        raw_alias: "WEBER",
        canonical_name: "WEBER",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN PAM⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN PAM⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN PAM",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN PAM⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN PAM⟩ CONTENT {
        raw_alias: "SAINT GOBAIN PAM",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN PAM PONT-A-MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN PAM PONT-A-MOUSSON⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN PAM PONT-A-MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN PAM PONT-À-MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN PAM PONT-À-MOUSSON⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN PAM PONT-À-MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN PAM PONT A MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN PAM PONT A MOUSSON⟩ CONTENT {
        raw_alias: "SAINT GOBAIN PAM PONT A MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN PAM PONT À MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN PAM PONT À MOUSSON⟩ CONTENT {
        raw_alias: "SAINT GOBAIN PAM PONT À MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PONT-A-MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PONT-A-MOUSSON⟩ CONTENT {
        raw_alias: "PONT-A-MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PONT-À-MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PONT-À-MOUSSON⟩ CONTENT {
        raw_alias: "PONT-À-MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PONT A MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PONT A MOUSSON⟩ CONTENT {
        raw_alias: "PONT A MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PONT À MOUSSON⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PONT À MOUSSON⟩ CONTENT {
        raw_alias: "PONT À MOUSSON",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨PAM⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨PAM⟩ CONTENT {
        raw_alias: "PAM",
        canonical_name: "PAM",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN GLASS⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN GLASS⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN GLASS",
        canonical_name: "SAINT-GOBAIN GLASS",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN GLASS⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN GLASS⟩ CONTENT {
        raw_alias: "SAINT GOBAIN GLASS",
        canonical_name: "SAINT-GOBAIN GLASS",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT-GOBAIN⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT-GOBAIN⟩ CONTENT {
        raw_alias: "SAINT-GOBAIN",
        canonical_name: "SAINT-GOBAIN",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: false
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SAINT GOBAIN⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SAINT GOBAIN⟩ CONTENT {
        raw_alias: "SAINT GOBAIN",
        canonical_name: "SAINT-GOBAIN",
        holding_or_group: "SAINT-GOBAIN",
        is_verified: false
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨KNAUF INSULATION⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨KNAUF INSULATION⟩ CONTENT {
        raw_alias: "KNAUF INSULATION",
        canonical_name: "KNAUF INSULATION",
        holding_or_group: "KNAUF GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨KNAUF⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨KNAUF⟩ CONTENT {
        raw_alias: "KNAUF",
        canonical_name: "KNAUF",
        holding_or_group: "KNAUF GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SINIAT⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SINIAT⟩ CONTENT {
        raw_alias: "SINIAT",
        canonical_name: "SINIAT",
        holding_or_group: "ETEX GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨LAFARGE PLATRES⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨LAFARGE PLATRES⟩ CONTENT {
        raw_alias: "LAFARGE PLATRES",
        canonical_name: "SINIAT",
        holding_or_group: "ETEX GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SEMIN⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SEMIN⟩ CONTENT {
        raw_alias: "SEMIN",
        canonical_name: "SEMIN",
        holding_or_group: NONE,
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨URSA⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨URSA⟩ CONTENT {
        raw_alias: "URSA",
        canonical_name: "URSA",
        holding_or_group: NONE,
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨ROCKWOOL⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨ROCKWOOL⟩ CONTENT {
        raw_alias: "ROCKWOOL",
        canonical_name: "ROCKWOOL",
        holding_or_group: "ROCKWOOL GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨LEGRAND⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨LEGRAND⟩ CONTENT {
        raw_alias: "LEGRAND",
        canonical_name: "LEGRAND",
        holding_or_group: "LEGRAND GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨BTICINO⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨BTICINO⟩ CONTENT {
        raw_alias: "BTICINO",
        canonical_name: "BTICINO",
        holding_or_group: "LEGRAND GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨LEGRAND BTICINO⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨LEGRAND BTICINO⟩ CONTENT {
        raw_alias: "LEGRAND BTICINO",
        canonical_name: "BTICINO",
        holding_or_group: "LEGRAND GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SCHNEIDER ELECTRIC⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SCHNEIDER ELECTRIC⟩ CONTENT {
        raw_alias: "SCHNEIDER ELECTRIC",
        canonical_name: "SCHNEIDER ELECTRIC",
        holding_or_group: "SCHNEIDER GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SCHNEIDER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SCHNEIDER⟩ CONTENT {
        raw_alias: "SCHNEIDER",
        canonical_name: "SCHNEIDER ELECTRIC",
        holding_or_group: "SCHNEIDER GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨MERLIN GERIN⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨MERLIN GERIN⟩ CONTENT {
        raw_alias: "MERLIN GERIN",
        canonical_name: "MERLIN GERIN",
        holding_or_group: "SCHNEIDER GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨TELEMECANIQUE⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨TELEMECANIQUE⟩ CONTENT {
        raw_alias: "TELEMECANIQUE",
        canonical_name: "TELEMECANIQUE",
        holding_or_group: "SCHNEIDER GROUP",
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨HAGER⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨HAGER⟩ CONTENT {
        raw_alias: "HAGER",
        canonical_name: "HAGER",
        holding_or_group: NONE,
        is_verified: true
    }
) END;

IF !record::exists(ingestion_manufacturer_alias:⟨SOPREMA⟩) THEN (
    CREATE ingestion_manufacturer_alias:⟨SOPREMA⟩ CONTENT {
        raw_alias: "SOPREMA",
        canonical_name: "SOPREMA",
        holding_or_group: NONE,
        is_verified: true
    }
) END;

-- ----------------------------------------------------------------------------
-- 2. ALIAS D'UNITÉS (libellés fournisseurs vers un code de lyxal_base)
-- ----------------------------------------------------------------------------

IF !record::exists(ingestion_unit_alias:⟨PC⟩) THEN (
    CREATE ingestion_unit_alias:⟨PC⟩ CONTENT {
        raw_alias: "PC",
        canonical_unit: "PCE",
        comment: "Pièce (abréviation)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨PIECE⟩) THEN (
    CREATE ingestion_unit_alias:⟨PIECE⟩ CONTENT {
        raw_alias: "PIECE",
        canonical_unit: "PCE",
        comment: "Pièce"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨PIÈCE⟩) THEN (
    CREATE ingestion_unit_alias:⟨PIÈCE⟩ CONTENT {
        raw_alias: "PIÈCE",
        canonical_unit: "PCE",
        comment: "Pièce"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨PIECES⟩) THEN (
    CREATE ingestion_unit_alias:⟨PIECES⟩ CONTENT {
        raw_alias: "PIECES",
        canonical_unit: "PCE",
        comment: "Pièces"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨PIÈCES⟩) THEN (
    CREATE ingestion_unit_alias:⟨PIÈCES⟩ CONTENT {
        raw_alias: "PIÈCES",
        canonical_unit: "PCE",
        comment: "Pièces"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨EACH⟩) THEN (
    CREATE ingestion_unit_alias:⟨EACH⟩ CONTENT {
        raw_alias: "EACH",
        canonical_unit: "PCE",
        comment: "Each (anglais)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨UN⟩) THEN (
    CREATE ingestion_unit_alias:⟨UN⟩ CONTENT {
        raw_alias: "UN",
        canonical_unit: "U",
        comment: "Unité"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨UNIT⟩) THEN (
    CREATE ingestion_unit_alias:⟨UNIT⟩ CONTENT {
        raw_alias: "UNIT",
        canonical_unit: "U",
        comment: "Unit (anglais)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨UNITE⟩) THEN (
    CREATE ingestion_unit_alias:⟨UNITE⟩ CONTENT {
        raw_alias: "UNITE",
        canonical_unit: "U",
        comment: "Unité"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨UNITÉ⟩) THEN (
    CREATE ingestion_unit_alias:⟨UNITÉ⟩ CONTENT {
        raw_alias: "UNITÉ",
        canonical_unit: "U",
        comment: "Unité"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨METRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨METRE⟩ CONTENT {
        raw_alias: "METRE",
        canonical_unit: "M",
        comment: "Mètre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MÈTRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨MÈTRE⟩ CONTENT {
        raw_alias: "MÈTRE",
        canonical_unit: "M",
        comment: "Mètre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨METRE LINEAIRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨METRE LINEAIRE⟩ CONTENT {
        raw_alias: "METRE LINEAIRE",
        canonical_unit: "ML",
        comment: "Mètre linéaire"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MÈTRE LINÉAIRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨MÈTRE LINÉAIRE⟩ CONTENT {
        raw_alias: "MÈTRE LINÉAIRE",
        canonical_unit: "ML",
        comment: "Mètre linéaire"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨CENTIMETRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨CENTIMETRE⟩ CONTENT {
        raw_alias: "CENTIMETRE",
        canonical_unit: "CM",
        comment: "Centimètre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨CENTIMÈTRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨CENTIMÈTRE⟩ CONTENT {
        raw_alias: "CENTIMÈTRE",
        canonical_unit: "CM",
        comment: "Centimètre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MILLIMETRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨MILLIMETRE⟩ CONTENT {
        raw_alias: "MILLIMETRE",
        canonical_unit: "MM",
        comment: "Millimètre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MILLIMÈTRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨MILLIMÈTRE⟩ CONTENT {
        raw_alias: "MILLIMÈTRE",
        canonical_unit: "MM",
        comment: "Millimètre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨M²⟩) THEN (
    CREATE ingestion_unit_alias:⟨M²⟩ CONTENT {
        raw_alias: "M²",
        canonical_unit: "M2",
        comment: "Mètre carré (exposant)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MQ⟩) THEN (
    CREATE ingestion_unit_alias:⟨MQ⟩ CONTENT {
        raw_alias: "MQ",
        canonical_unit: "M2",
        comment: "Mètre carré (italien)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨SQM⟩) THEN (
    CREATE ingestion_unit_alias:⟨SQM⟩ CONTENT {
        raw_alias: "SQM",
        canonical_unit: "M2",
        comment: "Square meter (anglais)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨METRE CARRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨METRE CARRE⟩ CONTENT {
        raw_alias: "METRE CARRE",
        canonical_unit: "M2",
        comment: "Mètre carré"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MÈTRE CARRÉ⟩) THEN (
    CREATE ingestion_unit_alias:⟨MÈTRE CARRÉ⟩ CONTENT {
        raw_alias: "MÈTRE CARRÉ",
        canonical_unit: "M2",
        comment: "Mètre carré"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨M³⟩) THEN (
    CREATE ingestion_unit_alias:⟨M³⟩ CONTENT {
        raw_alias: "M³",
        canonical_unit: "M3",
        comment: "Mètre cube (exposant)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨METRE CUBE⟩) THEN (
    CREATE ingestion_unit_alias:⟨METRE CUBE⟩ CONTENT {
        raw_alias: "METRE CUBE",
        canonical_unit: "M3",
        comment: "Mètre cube"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨MÈTRE CUBE⟩) THEN (
    CREATE ingestion_unit_alias:⟨MÈTRE CUBE⟩ CONTENT {
        raw_alias: "MÈTRE CUBE",
        canonical_unit: "M3",
        comment: "Mètre cube"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨L⟩) THEN (
    CREATE ingestion_unit_alias:⟨L⟩ CONTENT {
        raw_alias: "L",
        canonical_unit: "LTR",
        comment: "Litre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨LT⟩) THEN (
    CREATE ingestion_unit_alias:⟨LT⟩ CONTENT {
        raw_alias: "LT",
        canonical_unit: "LTR",
        comment: "Litre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨LITRE⟩) THEN (
    CREATE ingestion_unit_alias:⟨LITRE⟩ CONTENT {
        raw_alias: "LITRE",
        canonical_unit: "LTR",
        comment: "Litre"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨LITRES⟩) THEN (
    CREATE ingestion_unit_alias:⟨LITRES⟩ CONTENT {
        raw_alias: "LITRES",
        canonical_unit: "LTR",
        comment: "Litres"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨KILO⟩) THEN (
    CREATE ingestion_unit_alias:⟨KILO⟩ CONTENT {
        raw_alias: "KILO",
        canonical_unit: "KG",
        comment: "Kilogramme"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨KILOGRAMME⟩) THEN (
    CREATE ingestion_unit_alias:⟨KILOGRAMME⟩ CONTENT {
        raw_alias: "KILOGRAMME",
        canonical_unit: "KG",
        comment: "Kilogramme"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨TONNE⟩) THEN (
    CREATE ingestion_unit_alias:⟨TONNE⟩ CONTENT {
        raw_alias: "TONNE",
        canonical_unit: "T",
        comment: "Tonne"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨GR⟩) THEN (
    CREATE ingestion_unit_alias:⟨GR⟩ CONTENT {
        raw_alias: "GR",
        canonical_unit: "G",
        comment: "Gramme"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨GRAMME⟩) THEN (
    CREATE ingestion_unit_alias:⟨GRAMME⟩ CONTENT {
        raw_alias: "GRAMME",
        canonical_unit: "G",
        comment: "Gramme"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨ROULEAU⟩) THEN (
    CREATE ingestion_unit_alias:⟨ROULEAU⟩ CONTENT {
        raw_alias: "ROULEAU",
        canonical_unit: "ROUL",
        comment: "Rouleau"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨ROLL⟩) THEN (
    CREATE ingestion_unit_alias:⟨ROLL⟩ CONTENT {
        raw_alias: "ROLL",
        canonical_unit: "ROUL",
        comment: "Roll (anglais)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨RL⟩) THEN (
    CREATE ingestion_unit_alias:⟨RL⟩ CONTENT {
        raw_alias: "RL",
        canonical_unit: "ROUL",
        comment: "Rouleau (abréviation)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨BOITE⟩) THEN (
    CREATE ingestion_unit_alias:⟨BOITE⟩ CONTENT {
        raw_alias: "BOITE",
        canonical_unit: "BTE",
        comment: "Boîte"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨BOÎTE⟩) THEN (
    CREATE ingestion_unit_alias:⟨BOÎTE⟩ CONTENT {
        raw_alias: "BOÎTE",
        canonical_unit: "BTE",
        comment: "Boîte"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨BOX⟩) THEN (
    CREATE ingestion_unit_alias:⟨BOX⟩ CONTENT {
        raw_alias: "BOX",
        canonical_unit: "BTE",
        comment: "Box (anglais)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨BAG⟩) THEN (
    CREATE ingestion_unit_alias:⟨BAG⟩ CONTENT {
        raw_alias: "BAG",
        canonical_unit: "SAC",
        comment: "Bag (anglais)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨SA⟩) THEN (
    CREATE ingestion_unit_alias:⟨SA⟩ CONTENT {
        raw_alias: "SA",
        canonical_unit: "SAC",
        comment: "Sac (abréviation)"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨ENSEMBLE⟩) THEN (
    CREATE ingestion_unit_alias:⟨ENSEMBLE⟩ CONTENT {
        raw_alias: "ENSEMBLE",
        canonical_unit: "ENS",
        comment: "Ensemble"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨PALETTE⟩) THEN (
    CREATE ingestion_unit_alias:⟨PALETTE⟩ CONTENT {
        raw_alias: "PALETTE",
        canonical_unit: "PAL",
        comment: "Palette"
    }
) END;

IF !record::exists(ingestion_unit_alias:⟨CARTON⟩) THEN (
    CREATE ingestion_unit_alias:⟨CARTON⟩ CONTENT {
        raw_alias: "CARTON",
        canonical_unit: "CART",
        comment: "Carton"
    }
) END;
