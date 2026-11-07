-- lyxal-test: assertions
-- Quarantaine : consignation rejouable des anomalies par l'agent de qualification,
-- résolution auditable par le Data Steward avec corrections contrôlées.
--
-- identité ingestion: { "id": "ingestion_session:ingestion", "sub": "service:ingestion", "role": "ingestion_agent", "scope": ["ingestion:batch:write"] }
-- identité qualif: { "id": "ingestion_session:qualif", "sub": "service:qualif", "role": "qualification_agent", "scope": ["ingestion:staged:qualify"] }
-- identité steward: { "id": "ingestion_session:steward", "sub": "user:steward", "role": "steward_admin", "scope": ["ingestion:manifest:approve"] }

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- préparation: lot
RETURN fn::ingestion_batch_create({ id: "lot_z", source_type: "CSV", fournisseur_id: "FOURN_LEGRAND", nom_fichier: "z.csv", file_hash_blake3: crypto::blake3("z.csv") });

-- préparation: le banc réserve le lot lot_z (génération 1)
RETURN fn::ingestion_batch_claim({ id: "lot_z", owner: "banc" }).data.generation == 1;

-- préparation: article rejeté
RETURN fn::ingestion_staged_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", rules_version: "1", items: [
    { ligne_numero: 1, canonical_fingerprint: crypto::blake3("z1"), fabricant: "LEGRAND", reference_fabricant: "PRISE-2P", libelle_commercial: "Prise 2P+T", unite_reference: "PCE", conditionnement: {}, qualification: "REJECTED", qualification_reason: "Unité incohérente" }
] });

-- test: l'agent de qualification consigne une anomalie (sévérité normalisée)
-- en tant que: qualif
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", ligne_numero: 1, code_erreur: "ingestion_unit_unresolved", severite: "warning", champ_concerne: "unite_reference", valeur_fautive: "BOITE", cause_detaillee: "Unité inconnue du référentiel" }).ok
    AND (SELECT VALUE [code_erreur, severite, raw_record, is_resolved] FROM ONLY ingestion_quarantine_record LIMIT 1) == ["INGESTION_UNIT_UNRESOLVED", "WARNING", ingestion_raw_record:lot_z_1, false];

-- test: rejeu de la même ligne : l'anomalie ouverte n'est pas dupliquée
-- en tant que: qualif
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", ligne_numero: 1, code_erreur: "INGESTION_UNIT_UNRESOLVED", severite: "WARNING", champ_concerne: "unite_reference", valeur_fautive: "BOITE", cause_detaillee: "Unité inconnue du référentiel" }).data
    == <string> record::id((SELECT VALUE id FROM ONLY ingestion_quarantine_record LIMIT 1))
    AND count(SELECT id FROM ingestion_quarantine_record) == 1;

-- test: une autre anomalie sur la même ligne est consignée à part
-- en tant que: qualif
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", ligne_numero: 1, code_erreur: "INGESTION_GTIN_INVALID", severite: "ERROR", champ_concerne: "code_barre_gtin", valeur_fautive: "3017620422009", cause_detaillee: "Clé GS1 invalide" }).ok
    AND count(SELECT id FROM ingestion_quarantine_record) == 2;

-- test: sévérité inconnue
-- en tant que: qualif
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", ligne_numero: 1, code_erreur: "X", severite: "FATAL", champ_concerne: "x", cause_detaillee: "x" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: l'agent d'ingestion ne consigne pas d'anomalie
-- en tant que: ingestion
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", ligne_numero: 2, code_erreur: "INGESTION_GTIN_INVALID", champ_concerne: "code_barre_gtin", cause_detaillee: "Clé GS1 invalide" }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: liste filtrée par sévérité et par résolution
-- en tant que: steward
RETURN [
    fn::ingestion_quarantine_list({ batch_id: "lot_z" }).data.total,
    fn::ingestion_quarantine_list({ batch_id: "lot_z", severite: "warning" }).data.records.code_erreur,
    fn::ingestion_quarantine_list({ is_resolved: true }).data.total
] == [2, ["INGESTION_UNIT_UNRESOLVED"], 0];

-- préparation: identifiants
CREATE test_ref:q SET
    unite = <string> record::id((SELECT VALUE id FROM ONLY ingestion_quarantine_record WHERE code_erreur = "INGESTION_UNIT_UNRESOLVED" LIMIT 1)),
    gtin = <string> record::id((SELECT VALUE id FROM ONLY ingestion_quarantine_record WHERE code_erreur = "INGESTION_GTIN_INVALID" LIMIT 1)),
    article = <string> record::id((SELECT VALUE id FROM ONLY ingestion_staged_item LIMIT 1));

-- test: correction de code-barres invalide refusée
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:q.gtin, comment: "Code-barres corrigé par le fabricant", staged_item_id: test_ref:q.article, corrections: { corrected_gtin: "3017620422009" } }).error.code == "INGESTION_GTIN_INVALID";

-- test: correction d'unité inconnue refusée
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:q.unite, comment: "Unité corrigée d'après la fiche", staged_item_id: test_ref:q.article, corrections: { corrected_unit: "XYZ" } }).error.code == "INGESTION_UNIT_UNRESOLVED";

-- test: anomalie inconnue
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: "anomalie_absente", comment: "Résolution impossible" }).error.code == "INGESTION_RECORD_NOT_FOUND";

-- test: article lié inconnu
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:q.unite, comment: "Unité corrigée d'après la fiche", staged_item_id: "article_absent" }).error.code == "INGESTION_ITEM_NOT_FOUND";

-- test: commentaire de résolution trop court
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:q.unite, comment: "ok" }).error.code == "INGESTION_JUSTIFICATION_TOO_SHORT";

-- test: aucune écriture tant qu'une correction est refusée
RETURN (SELECT VALUE is_resolved FROM ingestion_quarantine_record) == [false, false];

-- test: résolution avec corrections : unité résolue par alias, article repassé à confirmer
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:q.unite, comment: "Unité corrigée d'après la fiche", staged_item_id: test_ref:q.article, corrections: { corrected_unit: "piece", corrected_gtin: "3017620422003" } }).ok
    AND (SELECT VALUE [is_resolved, resolved_by, resolution_comment] FROM ONLY type::record("ingestion_quarantine_record", test_ref:q.unite)) == [true, "user:steward", "Unité corrigée d'après la fiche"]
    AND (SELECT VALUE [qualification, unite_reference, conditionnement.unite_vente, code_barre_gtin, array::last(transitions).from_state, array::last(transitions).to_state] FROM ONLY type::record("ingestion_staged_item", test_ref:q.article))
        == ["TO_CONFIRM", "PCE", "PCE", "3017620422003", "REJECTED", "TO_CONFIRM"];

-- test: une fois l'anomalie résolue, une nouvelle occurrence est consignée à part
-- en tant que: qualif
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_z", ligne_numero: 1, code_erreur: "INGESTION_UNIT_UNRESOLVED", severite: "WARNING", champ_concerne: "unite_reference", valeur_fautive: "BOITE", cause_detaillee: "Unité de nouveau inconnue" }).ok
    AND count(SELECT id FROM ingestion_quarantine_record WHERE code_erreur = "INGESTION_UNIT_UNRESOLVED") == 2;

-- test: l'agent de qualification ne marque pas une anomalie résolue par écriture directe
-- en tant que: qualif
RETURN (UPDATE type::record("ingestion_quarantine_record", test_ref:q.gtin) SET is_resolved = true, resolved_by = "service:qualif") == []
    AND (SELECT VALUE is_resolved FROM ONLY type::record("ingestion_quarantine_record", test_ref:q.gtin)) == false;
