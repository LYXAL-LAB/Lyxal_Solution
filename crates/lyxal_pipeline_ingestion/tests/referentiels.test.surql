-- lyxal-test: assertions
-- Référentiels : résolution des unités et des fabricants, familles, spécifications et règles
-- de substitution administrées par le Data Steward, chargement par le moteur de regroupement.
--
-- identité qualif: { "id": "ingestion_session:qualif", "sub": "service:qualif", "role": "qualification_agent", "scope": ["ingestion:staged:qualify"] }
-- identité steward: { "id": "ingestion_session:steward", "sub": "user:steward", "role": "steward_admin", "scope": ["ingestion:manifest:approve"] }
-- identité sync: { "id": "ingestion_session:sync", "sub": "service:sync", "role": "catalogue_sync_agent", "scope": ["catalogue:sync:write"] }

-- test: bloc d'unités : alias commerciaux, codes Lyxal, codes d'échange, clé sans points
-- en tant que: qualif
RETURN fn::ingestion_resolve_units({ raw_units: [" sqm ", "m3", "Rouleau", "M²", "c62", "RO", "m.l.", "Mètre carré"] }).data == {
    "sqm": "M2", "m3": "M3", "Rouleau": "ROUL", "M²": "M2", "c62": "U", "RO": "ROUL", "m.l.": "ML", "Mètre carré": "M2"
};

-- test: unités inconnues absentes du résultat
-- en tant que: qualif
RETURN fn::ingestion_resolve_units({ raw_units: ["XYZ", "...", "KG"] }).data == { "KG": "KG" };

-- test: bloc d'unités vide
-- en tant que: qualif
RETURN fn::ingestion_resolve_units({ raw_units: [] }).data == {};

-- test: unités non textuelles refusées
-- en tant que: qualif
RETURN fn::ingestion_resolve_units({ raw_units: "M2" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: chaque alias d'unité seedé pointe vers une unité utilisable
RETURN object::len(fn::ingestion_resolve_units({ raw_units: (SELECT VALUE raw_alias FROM ingestion_unit_alias) }).data) == count(SELECT id FROM ingestion_unit_alias);

-- préparation: alias vers une unité dont le type est désactivé
fn::base_unite_type_update({ id: "base_unite_type:ENERGIE", enabled: false });

-- test: unité d'un type désactivé non résolue
-- en tant que: qualif
RETURN fn::ingestion_resolve_units({ raw_units: ["KWH"] }).data == {};

-- préparation: type réactivé
fn::base_unite_type_update({ id: "base_unite_type:ENERGIE", enabled: true });

-- test: bloc de fabricants : alias, groupe, suffixes juridiques et ponctuation retirés
-- en tant que: qualif
RETURN fn::ingestion_resolve_manufacturers({ raw_names: ["Saint-Gobain Isover", "Knauf SAS", "Schneider Electric, France", " Fabricant  Local SARL "] }).data.{
    a: `Saint-Gobain Isover`,
    b: `Knauf SAS`,
    c: `Schneider Electric, France`,
    d: `Fabricant  Local SARL`.{ canonical_name, is_verified, resolved }
} == {
    a: { canonical_name: "ISOVER", holding_or_group: "SAINT-GOBAIN", is_verified: true, resolved: true },
    b: { canonical_name: "KNAUF", holding_or_group: "KNAUF GROUP", is_verified: true, resolved: true },
    c: { canonical_name: "SCHNEIDER ELECTRIC", holding_or_group: "SCHNEIDER GROUP", is_verified: true, resolved: true },
    d: { canonical_name: "FABRICANT LOCAL", is_verified: false, resolved: false }
};

-- test: groupe sans entité déterminée : résolu mais non vérifié
-- en tant que: qualif
RETURN fn::ingestion_resolve_manufacturers({ raw_names: ["Saint Gobain"] }).data["Saint Gobain"] == { canonical_name: "SAINT-GOBAIN", holding_or_group: "SAINT-GOBAIN", is_verified: false, resolved: true };

-- test: fabricant absent refusé
-- en tant que: qualif
RETURN fn::ingestion_resolve_manufacturers({ raw_names: [""] }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: le steward ajoute une famille (code normalisé)
-- en tant que: steward
RETURN fn::ingestion_rule_family_add({ code: " colle_carrelage ", label: "Colles à carrelage", keywords: ["colle", "mortier colle"], standard_unit: "kg" }).data == "COLLE_CARRELAGE"
    AND (SELECT VALUE [label, keywords, standard_unit] FROM ONLY ingestion_family_rule:COLLE_CARRELAGE) == ["Colles à carrelage", ["colle", "mortier colle"], "KG"];

-- test: mise à jour de la famille sous le même code
-- en tant que: steward
RETURN fn::ingestion_rule_family_add({ code: "COLLE_CARRELAGE", label: "Colles et mortiers-colles", keywords: ["colle"] }).ok
    AND (SELECT VALUE [label, keywords] FROM ONLY ingestion_family_rule:COLLE_CARRELAGE) == ["Colles et mortiers-colles", ["colle"]]
    AND count(SELECT id FROM ingestion_family_rule WHERE code = "COLLE_CARRELAGE") == 1;

-- test: famille avec mots-clés mal typés
-- en tant que: steward
RETURN fn::ingestion_rule_family_add({ code: "ISOLANT", label: "Isolants", keywords: "laine" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: l'agent de qualification n'administre pas les familles
-- en tant que: qualif
RETURN fn::ingestion_rule_family_add({ code: "PIRATE", label: "Famille pirate" }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: spécification d'une famille existante, tolérances par défaut
-- en tant que: steward
RETURN fn::ingestion_rule_spec_add({ technical_identity_key: "colle_c2_25kg", family_code: "colle_carrelage", generic_title: "Colle C2 sac 25 kg", nominal_weight: 25, required_features: { classe: "C2" }, standard_norm: " NF EN 12004 " }).data == "COLLE_C2_25KG"
    AND (SELECT VALUE [family_code, tolerances.length_tol_mm, nominal_weight, standard_norm, required_features.classe] FROM ONLY ingestion_specification:COLLE_C2_25KG)
        == ["COLLE_CARRELAGE", 5.0, 25.0, "NF EN 12004", "C2"];

-- test: spécification d'une famille inconnue
-- en tant que: steward
RETURN fn::ingestion_rule_spec_add({ technical_identity_key: "INCONNUE_01", family_code: "FAMILLE_ABSENTE", generic_title: "Spécification orpheline" }).error.code == "INGESTION_SPEC_INVALID";

-- test: critères requis non textuels refusés
-- en tant que: steward
RETURN fn::ingestion_rule_spec_add({ technical_identity_key: "COLLE_C1", family_code: "COLLE_CARRELAGE", generic_title: "Colle C1", required_features: { classe: 1 } }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: l'agent de qualification n'administre pas les spécifications
-- en tant que: qualif
RETURN fn::ingestion_rule_spec_add({ technical_identity_key: "PIRATE_01", family_code: "COLLE_CARRELAGE", generic_title: "Spécification pirate" }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: règle de substitution certifiée (valeurs normalisées)
-- en tant que: steward
RETURN fn::ingestion_rule_substitution_add({ rule_id: "sub_colle_01", source_mfg: "weber", source_ref: "COL-C2", target_mfg: "parexlanko", target_ref: "LANKO-C2", system_scope: "Pose intérieure, sol", certification_body: "cstb", certification_ref: "AT-2026-01", valid_until: d"2030-01-01T00:00:00Z" }).data == "SUB_COLLE_01"
    AND (SELECT VALUE [source_mfg, target_mfg, system_scope, certification_body, is_revoked] FROM ONLY ingestion_substitution_rule:SUB_COLLE_01) == ["WEBER", "PAREXLANKO", "POSE INTÉRIEURE, SOL", "CSTB", false];

-- test: révocation avec motif
-- en tant que: steward
RETURN fn::ingestion_rule_substitution_add({ rule_id: "SUB_COLLE_01", source_mfg: "WEBER", source_ref: "COL-C2", target_mfg: "PAREXLANKO", target_ref: "LANKO-C2", system_scope: "Pose intérieure, sol", certification_body: "CSTB", certification_ref: "AT-2026-01", valid_until: d"2030-01-01T00:00:00Z", is_revoked: true, revocation_reason: "Avis technique retiré" }).ok
    AND (SELECT VALUE [is_revoked, revocation_reason] FROM ONLY ingestion_substitution_rule:SUB_COLLE_01) == [true, "Avis technique retiré"];

-- test: révocation sans motif refusée
-- en tant que: steward
RETURN fn::ingestion_rule_substitution_add({ rule_id: "SUB_REVOQUEE", source_mfg: "WEBER", source_ref: "A", target_mfg: "LANKO", target_ref: "B", system_scope: "Sol", certification_body: "CSTB", certification_ref: "AT-1", valid_until: d"2030-01-01T00:00:00Z", is_revoked: true }).error.code == "INGESTION_SUBSTITUTION_RULE_INVALID";

-- test: date de validité non datée refusée
-- en tant que: steward
RETURN fn::ingestion_rule_substitution_add({ rule_id: "SUB_DATE", source_mfg: "WEBER", source_ref: "A", target_mfg: "LANKO", target_ref: "B", system_scope: "Sol", certification_body: "CSTB", certification_ref: "AT-1", valid_until: "bientôt" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: chargement des référentiels par le moteur de regroupement
-- en tant que: sync
RETURN fn::ingestion_rules_load({}).data.{
    f: families[WHERE code = "COLLE_CARRELAGE"].label,
    seeds: count(families) >= 4,
    s: specifications[WHERE technical_identity_key = "COLLE_C2_25KG"].nominal_weight,
    r: substitutions[WHERE rule_id = "SUB_COLLE_01"].{ target_manufacturer, certification_reference, is_revoked }
} == { f: ["Colles et mortiers-colles"], seeds: true, s: [{ net_weight_kg: 25.0 }], r: [{ target_manufacturer: "PAREXLANKO", certification_reference: "AT-2026-01", is_revoked: true }] };
