-- lyxal-test: assertions
-- Fonctions du pipeline en session système (hôte) : lots, référentiels, consultation.
-- Les contrôles d'identité et d'approbation sont dans securite.test.surql.

-- test: création d'un lot
RETURN fn::ingestion_batch_create({ id: "lot_f", source_type: "CSV", fournisseur_id: "FOURN_ISOVER", nom_fichier: "isover.csv", file_hash_blake3: crypto::blake3("isover.csv") }).data == "lot_f";

-- test: transition de lot autorisée (RECEIVED → PARSING)
RETURN fn::ingestion_batch_transition({ id: "lot_f", nouveau_statut: "PARSING", reason: "Début de lecture" }).ok;

-- test: transition de lot interdite (PARSING → PUBLISHED)
-- attendu-erreur: INGESTION_BATCH_ILLEGAL_STATE_TRANSITION
RETURN fn::ingestion_batch_transition({ id: "lot_f", nouveau_statut: "PUBLISHED", reason: "Saut d'étapes" });

-- test: lot inconnu
RETURN fn::ingestion_batch_transition({ id: "lot_inconnu", nouveau_statut: "PARSING", reason: "Lot absent" }).error.code == "INGESTION_BATCH_NOT_FOUND";

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

-- test: un fichier déjà reçu (même format, même empreinte) est refusé
RETURN fn::ingestion_batch_create({ id: "lot_f_bis", source_type: "csv", fournisseur_id: "FOURN_ISOVER", nom_fichier: "isover.csv", file_hash_blake3: crypto::blake3("isover.csv") }).error.code == "INGESTION_BATCH_DUPLICATE";

-- test: lot sans identifiant fourni, retrouvé par l'identifiant renvoyé
RETURN fn::ingestion_batch_get({ id: fn::ingestion_batch_create({ source_type: "XML", fournisseur_id: "FOURN_KNAUF", nom_fichier: "knauf.xml", file_hash_blake3: crypto::blake3("knauf.xml") }).data }).data.{ statut, cle_texte: type::is_string(id) AND string::len(id) == 36 } == { statut: "RECEIVED", cle_texte: true };

-- test: paramètre inconnu refusé à la création d'un lot
RETURN fn::ingestion_batch_create({ id: "lot_x", source_type: "CSV", fournisseur_id: "F", nom_fichier: "x.csv", file_hash_blake3: crypto::blake3("x.csv"), statut: "PUBLISHED" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: une empreinte de fichier invalide est refusée
RETURN fn::ingestion_batch_create({ id: "lot_court", source_type: "CSV", fournisseur_id: "FOURN_ISOVER", nom_fichier: "court.csv", file_hash_blake3: "abc" }).error.code == "INGESTION_SOURCE_INVALID";

-- test: lecture d'un lot et de son journal de transitions
RETURN (fn::ingestion_batch_get({ id: "lot_f" }).data) .{ id, statut, cursor_offset, etats: transitions.map(|$t| [$t.from_state, $t.to_state]) } == { id: "lot_f", statut: "PARSING", cursor_offset: 10, etats: [[NONE, "RECEIVED"], ["RECEIVED", "PARSING"]] };

-- test: lot inconnu en lecture
RETURN fn::ingestion_batch_get({ id: "lot_inconnu" }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- test: enregistrement d'un bloc de lignes brutes
RETURN fn::ingestion_raw_records_save({ batch_id: "lot_f", records: [
    { ligne_numero: 1, row_hash: crypto::blake3("l1"), payload_brut: { ref: "IBR-100" } },
    { ligne_numero: 2, row_hash: crypto::blake3("l2"), payload_brut: { ref: "IBR-200" } }
] }).data == 2;

-- test: une ligne brute déjà enregistrée n'est jamais réécrite (reprise)
RETURN fn::ingestion_raw_records_save({ batch_id: "lot_f", records: [{ ligne_numero: 1, row_hash: crypto::blake3("autre"), payload_brut: {} }] }).data == 0
    AND (SELECT VALUE row_hash FROM ONLY ingestion_raw_record:lot_f_1) == crypto::blake3("l1");

-- test: ligne brute sans numéro valide
RETURN fn::ingestion_raw_records_save({ batch_id: "lot_f", records: [{ ligne_numero: 0, row_hash: crypto::blake3("l0"), payload_brut: {} }] }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: article en staging avec code-barres normalisé par lyxal_core
RETURN fn::ingestion_staged_save({ batch_id: "lot_f", rules_version: "1", items: [{ ligne_numero: 1, canonical_fingerprint: crypto::blake3("ibr100"), fabricant: "isover", reference_fabricant: "IBR-100", code_barre_gtin: " 301-7620-422003 ", libelle_commercial: "Laine de verre IBR 100 mm", unite_reference: "m2", conditionnement: { unite_vente: "M2", quantite_par_colis: 1.0 }, qualification: "to_confirm", qualification_reason: "Preuve commerciale absente" }] }).ok
    AND (SELECT VALUE [code_barre_gtin, fabricant, unite_reference, qualification, transitions[0].to_state] FROM ONLY ingestion_staged_item WHERE reference_fabricant = "IBR-100" LIMIT 1) == ["3017620422003", "ISOVER", "M2", "TO_CONFIRM", "TO_CONFIRM"];

-- test: code-barres dont la clé GS1 est fausse
RETURN fn::ingestion_staged_save({ batch_id: "lot_f", rules_version: "1", items: [{ ligne_numero: 2, canonical_fingerprint: crypto::blake3("ibr200"), fabricant: "ISOVER", reference_fabricant: "IBR-200", code_barre_gtin: "3017620422004", libelle_commercial: "Laine de verre IBR 200 mm", unite_reference: "M2", conditionnement: {} }] }).data[0].error.code == "INGESTION_GTIN_INVALID";

-- test: article sans référence fabricant
RETURN fn::ingestion_staged_save({ batch_id: "lot_f", rules_version: "1", items: [{ ligne_numero: 2, canonical_fingerprint: crypto::blake3("ibr200"), fabricant: "ISOVER", reference_fabricant: "  ", libelle_commercial: "Laine de verre IBR 200 mm", unite_reference: "M2", conditionnement: {} }] }).data[0].error.code == "INGESTION_MANUFACTURER_REF_MISSING";

-- test: article sans conditionnement
RETURN fn::ingestion_staged_save({ batch_id: "lot_f", rules_version: "1", items: [{ ligne_numero: 2, canonical_fingerprint: crypto::blake3("ibr200"), fabricant: "ISOVER", reference_fabricant: "IBR-200", libelle_commercial: "Laine de verre IBR 200 mm", unite_reference: "M2" }] }).data[0].error.{ code, field: details.field } == { code: "INGESTION_INVALID_PARAMETERS", field: "conditionnement" };

-- test: bloc d'articles sans lot valide
RETURN fn::ingestion_staged_save({ batch_id: "", rules_version: "1", items: [] }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: anomalie consignée puis listée
RETURN fn::ingestion_quarantine_log({ batch_id: "lot_f", ligne_numero: 2, code_erreur: "INGESTION_GTIN_INVALID", severite: "error", champ_concerne: "code_barre_gtin", valeur_fautive: "3017620422004", cause_detaillee: "Clé GS1 invalide" }).ok
    AND fn::ingestion_quarantine_list({ batch_id: "lot_f", severite: "ERROR" }).data.records.map(|$r| [$r.batch, $r.raw_record, $r.ligne_numero]) == [["lot_f", "lot_f_2", 2]];

-- test: liste des articles d'un lot (types natifs, identifiants courts)
RETURN fn::ingestion_staged_list({ batch_id: "lot_f", fabricant: " isover " }).data.items.map(|$i| [$i.batch, $i.raw_record, $i.reference_fabricant]) == [["lot_f", "lot_f_1", "IBR-100"]];

-- test: paramètre inconnu refusé par le moteur de lyxal_core
RETURN fn::ingestion_staged_list({ batch_id: "lot_f", page: 2 }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: famille avec paramètre mal typé
RETURN fn::ingestion_rule_family_add({ code: "ISOLANT", label: "Isolants", keywords: "laine" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: spécification d'une famille inconnue
RETURN fn::ingestion_rule_spec_add({ technical_identity_key: "INCONNUE_01", family_code: "FAMILLE_ABSENTE", generic_title: "Spécification orpheline" }).error.code == "INGESTION_SPEC_INVALID";

-- test: règle révoquée sans motif
RETURN fn::ingestion_rule_substitution_add({ rule_id: "SUB_REVOQUEE", source_mfg: "WEBER", source_ref: "A", target_mfg: "LANKO", target_ref: "B", system_scope: "Sol", certification_body: "CSTB", certification_ref: "AT-1", valid_until: d"2030-01-01T00:00:00Z", is_revoked: true }).error.code == "INGESTION_SUBSTITUTION_RULE_INVALID";

-- test: chargement des référentiels de regroupement technique
RETURN fn::ingestion_rules_load({}).data.{ f: families[WHERE code = "COLLE_CARRELAGE"].label, s: specifications[WHERE technical_identity_key = "COLLE_C2_25KG"].family_code, r: substitutions[WHERE rule_id = "SUB_COLLE_01"].target_manufacturer } == { f: ["Colles à carrelage"], s: ["COLLE_CARRELAGE"], r: ["PAREXLANKO"] };

-- test: manifeste scellé du lot, approuvé par la session système
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-F", batch_id: "lot_f", seal_hash: crypto::blake3("MAN-F"), statut: "SEALED", nb_articles_insert: 1 }).data == "MAN-F"
    AND fn::ingestion_manifest_approve({ manifest_ref: "MAN-F", justification: "Contrôle de cohérence effectué" }).ok;

-- test: un manifeste approuvé n'est plus modifiable
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-F", batch_id: "lot_f", seal_hash: crypto::blake3("MAN-F2"), statut: "SEALED" }).error.code == "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION";

-- test: exécution d'un article journalisée et comptée
RETURN fn::ingestion_manifest_execution_item_update({ manifest_ref: "MAN-F", item_ref: "IBR-100", action: "insert", success: true }).ok
    AND (SELECT VALUE [items_committed, items_failed, execution_items[0].action] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-F" LIMIT 1) == [1, 0, "INSERT"];

-- test: détail d'un manifeste et de son lot
RETURN fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-F" }).data.{ m: manifest.batch, b: batch.id, e: execution_count, t: transition_count } == { m: "lot_f", b: "lot_f", e: 1, t: 2 };
