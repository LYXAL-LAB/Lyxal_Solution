-- lyxal-test: assertions
-- Référentiel installé par les seeds : types et unités du socle système, codes alignés sur les
-- codes canoniques de l'ingestion (sans alias). Exécuté par scripts/ci/test_lyxal_modules.py.

-- test: 11 types d'unités, tous système et actifs
RETURN (SELECT count() AS n FROM base_unite_type WHERE is_system AND enabled GROUP ALL)[0].n == 11;

-- test: 30 unités, toutes système et actives
RETURN (SELECT count() AS n FROM base_unite WHERE is_system AND enabled GROUP ALL)[0].n == 30;

-- test: chaque unité est rattachée à un type existant
RETURN array::len(SELECT id FROM base_unite WHERE !record::exists(type)) == 0;

-- test: conditionnements
RETURN array::sort((SELECT VALUE code FROM base_unite WHERE type = base_unite_type:CONDITIONNEMENT)) == ["BTE", "CART", "PAL", "ROUL", "SAC"];

-- test: énergie, puissance, pression, débit
RETURN [base_unite:KWH.type, base_unite:W.type, base_unite:BAR.type, base_unite:M3H.type] == [base_unite_type:ENERGIE, base_unite_type:PUISSANCE, base_unite_type:PRESSION, base_unite_type:DEBIT];

-- test: gramme et litre sous leurs codes normalisés, sans ancien code
RETURN [record::exists(base_unite:G), record::exists(base_unite:LTR), record::exists(base_unite:GR), record::exists(base_unite:L)] == [true, true, false, false];

-- test: millimètre parmi les longueurs
RETURN fn::base_unite_get({ code: "mm", fetch_type: true }).data.{ libelle, abreviation, t: type_detail.code, usable } == { libelle: "Millimètre", abreviation: "mm", t: "LONGUEUR", usable: true };

-- test: libellés tels que saisis
RETURN fn::base_unite_type_get({ id: "base_unite_type:ENERGIE" }).data.libelle == "Énergie" AND fn::base_unite_get({ code: "M3H" }).data.libelle == "Mètre cube par heure";
