-- ============================================================================
-- SEEDS : Codes d'échange normalisés des unités du socle
-- MODULE : lyxal_base
-- TABLE  : base_unite_code
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5)
-- UNECE_REC20 : UN/ECE Recommandation 20 (unités de mesure)
-- UNECE_REC21 : UN/ECE Recommandation 21 (types d'emballage), pour les conditionnements
-- ============================================================================

-- UNECE_REC20

IF !record::exists(base_unite_code:["UNECE_REC20", "KMT"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "KMT"] CONTENT {
        norme: "UNECE_REC20",
        code: "KMT",
        unite: base_unite:KM
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "MTR"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "MTR"] CONTENT {
        norme: "UNECE_REC20",
        code: "MTR",
        unite: base_unite:M
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "LM"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "LM"] CONTENT {
        norme: "UNECE_REC20",
        code: "LM",
        unite: base_unite:ML
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "CMT"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "CMT"] CONTENT {
        norme: "UNECE_REC20",
        code: "CMT",
        unite: base_unite:CM
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "MMT"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "MMT"] CONTENT {
        norme: "UNECE_REC20",
        code: "MMT",
        unite: base_unite:MM
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "HAR"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "HAR"] CONTENT {
        norme: "UNECE_REC20",
        code: "HAR",
        unite: base_unite:HA
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "MTK"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "MTK"] CONTENT {
        norme: "UNECE_REC20",
        code: "MTK",
        unite: base_unite:M2
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "MTQ"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "MTQ"] CONTENT {
        norme: "UNECE_REC20",
        code: "MTQ",
        unite: base_unite:M3
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "LTR"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "LTR"] CONTENT {
        norme: "UNECE_REC20",
        code: "LTR",
        unite: base_unite:LTR
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "TNE"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "TNE"] CONTENT {
        norme: "UNECE_REC20",
        code: "TNE",
        unite: base_unite:T
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "KGM"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "KGM"] CONTENT {
        norme: "UNECE_REC20",
        code: "KGM",
        unite: base_unite:KG
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "GRM"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "GRM"] CONTENT {
        norme: "UNECE_REC20",
        code: "GRM",
        unite: base_unite:G
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "MON"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "MON"] CONTENT {
        norme: "UNECE_REC20",
        code: "MON",
        unite: base_unite:MOIS
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "WEE"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "WEE"] CONTENT {
        norme: "UNECE_REC20",
        code: "WEE",
        unite: base_unite:SEM
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "DAY"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "DAY"] CONTENT {
        norme: "UNECE_REC20",
        code: "DAY",
        unite: base_unite:J
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "HUR"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "HUR"] CONTENT {
        norme: "UNECE_REC20",
        code: "HUR",
        unite: base_unite:H
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "C62"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "C62"] CONTENT {
        norme: "UNECE_REC20",
        code: "C62",
        unite: base_unite:U
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "H87"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "H87"] CONTENT {
        norme: "UNECE_REC20",
        code: "H87",
        unite: base_unite:PCE
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "EA"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "EA"] CONTENT {
        norme: "UNECE_REC20",
        code: "EA",
        unite: base_unite:PCE
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "SET"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "SET"] CONTENT {
        norme: "UNECE_REC20",
        code: "SET",
        unite: base_unite:ENS
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "PR"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "PR"] CONTENT {
        norme: "UNECE_REC20",
        code: "PR",
        unite: base_unite:PAIRE
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "LS"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "LS"] CONTENT {
        norme: "UNECE_REC20",
        code: "LS",
        unite: base_unite:FORFAIT
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "KWH"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "KWH"] CONTENT {
        norme: "UNECE_REC20",
        code: "KWH",
        unite: base_unite:KWH
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "WTT"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "WTT"] CONTENT {
        norme: "UNECE_REC20",
        code: "WTT",
        unite: base_unite:W
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "BAR"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "BAR"] CONTENT {
        norme: "UNECE_REC20",
        code: "BAR",
        unite: base_unite:BAR
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC20", "MQH"]) THEN (
    CREATE base_unite_code:["UNECE_REC20", "MQH"] CONTENT {
        norme: "UNECE_REC20",
        code: "MQH",
        unite: base_unite:M3H
    }
) END;

-- UNECE_REC21

IF !record::exists(base_unite_code:["UNECE_REC21", "RO"]) THEN (
    CREATE base_unite_code:["UNECE_REC21", "RO"] CONTENT {
        norme: "UNECE_REC21",
        code: "RO",
        unite: base_unite:ROUL
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC21", "BG"]) THEN (
    CREATE base_unite_code:["UNECE_REC21", "BG"] CONTENT {
        norme: "UNECE_REC21",
        code: "BG",
        unite: base_unite:SAC
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC21", "PX"]) THEN (
    CREATE base_unite_code:["UNECE_REC21", "PX"] CONTENT {
        norme: "UNECE_REC21",
        code: "PX",
        unite: base_unite:PAL
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC21", "BX"]) THEN (
    CREATE base_unite_code:["UNECE_REC21", "BX"] CONTENT {
        norme: "UNECE_REC21",
        code: "BX",
        unite: base_unite:BTE
    }
) END;

IF !record::exists(base_unite_code:["UNECE_REC21", "CT"]) THEN (
    CREATE base_unite_code:["UNECE_REC21", "CT"] CONTENT {
        norme: "UNECE_REC21",
        code: "CT",
        unite: base_unite:CART
    }
) END;
