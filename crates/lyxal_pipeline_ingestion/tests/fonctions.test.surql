-- lyxal-test: assertions
-- Fonctions du pipeline en session système (hôte) : lots, référentiels, consultation.
-- Les contrôles d'identité et d'approbation sont dans securite.test.surql.

-- test: création d'un lot
RETURN fn::ingestion_batch_create({ id: "lot_f", source_type: "CSV", fournisseur_id: "FOURN_ISOVER", nom_fichier: "isover.csv", file_hash_blake3: crypto::blake3("isover.csv"), statut: "RECEIVED" }).data == "lot_f";

-- test: transition de lot autorisée (RECEIVED → PARSING)
RETURN fn::ingestion_batch_transition({ id: "lot_f", nouveau_statut: "PARSING", transition: { from_state: "RECEIVED", to_state: "PARSING", triggered_by: "system", reason: "Début de lecture", transitioned_at: time::now() } }).ok;

-- test: transition de lot interdite (PARSING → PUBLISHED)
-- attendu-erreur: INGESTION_BATCH_ILLEGAL_STATE_TRANSITION
RETURN fn::ingestion_batch_transition({ id: "lot_f", nouveau_statut: "PUBLISHED", transition: { from_state: "PARSING", to_state: "PUBLISHED", triggered_by: "system", reason: "Saut d'étapes", transitioned_at: time::now() } });

-- test: lot inconnu
RETURN fn::ingestion_batch_transition({ id: "lot_inconnu", nouveau_statut: "PARSING", transition: {} }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- test: point de contrôle du lot
RETURN fn::ingestion_batch_checkpoint({ id: "lot_f", cursor_offset: 10, total_lignes: 10, lignes_verifiees: 8, lignes_a_confirmer: 1, lignes_rejetees: 1 }).ok AND (SELECT VALUE [cursor_offset, lignes_verifiees] FROM ONLY ingestion_batch:lot_f) == [10, 8];

-- test: résolution d'une unité par alias
RETURN fn::ingestion_resolve_unit({ raw_unit: "M2" }).data.canonical_code == "M2";

-- test: unité inconnue
RETURN fn::ingestion_resolve_unit({ raw_unit: "XYZ" }).error.code == "INGESTION_UNIT_UNRESOLVED";

-- test: résolution d'un fabricant par alias
RETURN fn::ingestion_resolve_manufacturer({ raw_name: "SAINT-GOBAIN PLACO" }).ok;

-- test: ajout d'une famille de produits
RETURN fn::ingestion_rule_family_add({ code: "COLLE_CARRELAGE", label: "Colles à carrelage", keywords: ["colle", "mortier colle"], standard_unit: "KG" }).data == "COLLE_CARRELAGE";

-- test: ajout d'une spécification technique
RETURN fn::ingestion_rule_spec_add({ technical_identity_key: "COLLE_C2_25KG", family_code: "COLLE_CARRELAGE", generic_title: "Colle C2 sac 25 kg", required_features: { classe: "C2" }, standard_norm: "NF EN 12004" }).ok;

-- test: ajout d'une règle de substitution
RETURN fn::ingestion_rule_substitution_add({ rule_id: "SUB_COLLE_01", source_mfg: "WEBER", source_ref: "COL-C2", target_mfg: "PAREXLANKO", target_ref: "LANKO-C2", system_scope: "Pose intérieure, sol", certification_body: "CSTB", certification_ref: "AT-2026-01", valid_until: d"2030-01-01T00:00:00Z" }).data == "SUB_COLLE_01";

-- test: indicateurs du tableau de bord
RETURN fn::ingestion_dashboard_metrics({}).data.batches.total >= 1;

-- test: liste des articles en staging (vide)
RETURN fn::ingestion_staged_list({ batch_id: "lot_f", limit: 10, start: 0 }).data.total == 0;

-- test: liste des quarantaines (vide)
RETURN fn::ingestion_quarantine_list({ batch_id: "lot_f", limit: 10, start: 0 }).data.total == 0;

-- test: liste des manifestes (vide)
RETURN fn::ingestion_manifest_list({ batch_id: "lot_f", limit: 10, start: 0 }).data.total == 0;

-- test: détail d'un manifeste inconnu
RETURN fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-INCONNU" }).error.code == "INGESTION_MANIFEST_NOT_FOUND";
