-- lyxal-test: assertions
-- Codes d'échange normalisés (UN/ECE Rec. 20 et Rec. 21) et résolution d'un bloc de codes bruts.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "base_session:utilisateur", "sub": "user:alpha", "iss": "lyxal-os", "role": "tenant_user", "tenant_id": "alpha" }

-- test: 31 codes seedés : 26 Rec. 20 et 5 Rec. 21
RETURN (SELECT count() AS n FROM base_unite_code WHERE norme = "UNECE_REC20" GROUP ALL)[0].n == 26
    AND (SELECT count() AS n FROM base_unite_code WHERE norme = "UNECE_REC21" GROUP ALL)[0].n == 5;

-- test: chaque unité du socle a au moins un code d'échange
RETURN array::len(SELECT id FROM base_unite WHERE is_system AND count(SELECT id FROM base_unite_code WHERE unite = $parent.id) == 0) == 0;

-- test: code unique par norme
RETURN (INFO FOR TABLE base_unite_code).indexes.idx_base_unite_code_norme_code.contains("UNIQUE");

-- test: lecture d'une unité avec ses codes
RETURN fn::base_unite_get({ code: "PCE" }).data.codes == [{ norme: "UNECE_REC20", code: "EA" }, { norme: "UNECE_REC20", code: "H87" }];

-- test: résolution par code Lyxal, code Rec. 20 et code Rec. 21 (clé : code brut sans espaces périphériques)
RETURN fn::base_unite_resolve({ codes: ["m2", " MTK ", "kgm", "RO", "LTR"] }).data == {
    "m2": { code: "M2", usable: true },
    "MTK": { code: "M2", usable: true },
    "kgm": { code: "KG", usable: true },
    "RO": { code: "ROUL", usable: true },
    "LTR": { code: "LTR", usable: true }
};

-- test: code inconnu absent du résultat
RETURN fn::base_unite_resolve({ codes: ["ROULEAU", "M2"] }).data == { "M2": { code: "M2", usable: true } };

-- test: doublons résolus une fois
RETURN fn::base_unite_resolve({ codes: ["H87", "H87", "EA"] }).data == { "H87": { code: "PCE", usable: true }, "EA": { code: "PCE", usable: true } };

-- test: bloc vide
RETURN fn::base_unite_resolve({ codes: [] }).data == {};

-- test: lecture et résolution sous toute identité
-- en tant que: utilisateur
RETURN fn::base_unite_resolve({ codes: ["MTR"] }).data.MTR.code == "M" AND fn::base_unite_get({ code: "M" }).data.codes == [{ norme: "UNECE_REC20", code: "MTR" }];

-- test: un utilisateur n'écrit pas de code d'échange
-- en tant que: utilisateur
RETURN (CREATE base_unite_code:["UNECE_REC20", "XXX"] CONTENT { norme: "UNECE_REC20", code: "XXX", unite: base_unite:M }) == [];

-- test: codes non textuels refusés
RETURN fn::base_unite_resolve({ codes: ["M", 2] }).error.code == "BASE_INVALID_PARAMETERS";

-- test: plus de 500 codes refusés
RETURN fn::base_unite_resolve({ codes: (<array> (0..501)).map(|$i| <string> $i) }).error.details.fields.codes != NONE;

-- test: liste de codes obligatoire
RETURN fn::base_unite_resolve({}).error.details.fields == { codes: ["CORE_VALIDATION_REQUIRED"] };

-- préparation: type d'énergie désactivé
fn::base_unite_type_update({ id: "base_unite_type:ENERGIE", enabled: false });

-- test: unité d'un type inactif résolue mais inutilisable
RETURN fn::base_unite_resolve({ codes: ["KWH"] }).data == { "KWH": { code: "KWH", usable: false } };

-- préparation: type d'énergie réactivé
fn::base_unite_type_update({ id: "base_unite_type:ENERGIE", enabled: true });

-- préparation: unité non système portant un code d'échange
fn::base_unite_create({ code: "DAM", libelle: "Décamètre", abreviation: "dam", type: "base_unite_type:LONGUEUR" });

-- préparation: code d'échange de l'unité non système
CREATE base_unite_code:["UNECE_REC20", "A45"] CONTENT { norme: "UNECE_REC20", code: "A45", unite: base_unite:DAM };

-- test: ses codes d'échange ne l'empêchent pas d'être supprimée ; ils disparaissent avec elle
RETURN fn::base_unite_delete({ id: "base_unite:DAM" }).data.deleted == true AND !record::exists(base_unite_code:["UNECE_REC20", "A45"]);
