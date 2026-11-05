-- lyxal-test: assertions
-- Qualification : enregistrement des articles par blocs (idempotent, code-barres contrôlé par
-- lyxal_core), requalification par le Data Steward (preuve commerciale, transitions),
-- listes et indicateurs.
--
-- identité ingestion: { "id": "ingestion_session:ingestion", "sub": "service:ingestion", "role": "ingestion_agent", "scope": ["ingestion:batch:write"] }
-- identité qualif: { "id": "ingestion_session:qualif", "sub": "service:qualif", "role": "qualification_agent", "scope": ["ingestion:staged:qualify"] }
-- identité steward: { "id": "ingestion_session:steward", "sub": "user:steward", "role": "steward_admin", "scope": ["ingestion:manifest:approve"] }

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- préparation: lot
RETURN fn::ingestion_batch_create({ id: "lot_q", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "q.csv", file_hash_blake3: crypto::blake3("q.csv") });

-- test: un bloc d'articles : un résultat par article, dans l'ordre
-- en tant que: qualif
RETURN fn::ingestion_staged_save({ batch_id: "lot_q", rules_version: "2026.1", items: [
    { ligne_numero: 1, canonical_fingerprint: crypto::blake3("q1"), fabricant: " placo ", reference_fabricant: "BA13", code_barre_gtin: "3017620422003", libelle_commercial: "Plaque BA13", unite_reference: "m2", conditionnement: { unite_vente: "M2", quantite_par_colis: 1.0 }, qualification: "to_confirm", qualification_reason: "Preuve absente" },
    { ligne_numero: 2, canonical_fingerprint: crypto::blake3("q2"), fabricant: "PLACO", reference_fabricant: "BA18", code_barre_gtin: "3017620422009", libelle_commercial: "Plaque BA18", unite_reference: "M2", conditionnement: {} },
    { ligne_numero: 3, canonical_fingerprint: crypto::blake3("q3"), fabricant: "PLACO", reference_fabricant: "BA25", unite_reference: "M2", conditionnement: {} },
    { ligne_numero: 4, canonical_fingerprint: crypto::blake3("q4"), fabricant: "PLACO", reference_fabricant: "BA06", libelle_commercial: "Plaque BA06", unite_reference: "M2", conditionnement: {}, type_item: "service", publication_action: "update" }
] }).data.map(|$r| [$r.ok, $r.error.code, $r.error.details.field])
    == [[true, NONE, NONE], [false, "INGESTION_GTIN_INVALID", "code_barre_gtin"], [false, "INGESTION_INVALID_PARAMETERS", "libelle_commercial"], [true, NONE, NONE]];

-- test: article enregistré, normalisé par le schéma, rattaché à sa ligne brute
RETURN (SELECT VALUE [fabricant, unite_reference, qualification, code_barre_gtin, raw_record, rules_version, is_approved] FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA13" LIMIT 1)
    == ["PLACO", "M2", "TO_CONFIRM", "3017620422003", ingestion_raw_record:lot_q_1, "2026.1", false];

-- test: énumérations normalisées (type d'article, action de publication)
RETURN (SELECT VALUE [type_item, publication_action] FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA06" LIMIT 1) == ["SERVICE", "UPDATE"];

-- test: rejeu : même clé métier, même article ; un changement de qualification est journalisé
-- en tant que: qualif
RETURN fn::ingestion_staged_save({ batch_id: "lot_q", rules_version: "2026.1", items: [
    { ligne_numero: 1, canonical_fingerprint: crypto::blake3("q1"), fabricant: "PLACO", reference_fabricant: "BA13", code_barre_gtin: "3017620422003", libelle_commercial: "Plaque BA13", unite_reference: "M2", conditionnement: {}, qualification: "REJECTED", qualification_reason: "Prix incohérent" }
] }).data[0].ok
    AND count(SELECT id FROM ingestion_staged_item WHERE reference_fabricant = "BA13") == 1
    AND (SELECT VALUE transitions.map(|$t| [$t.from_state, $t.to_state, $t.triggered_by, $t.reason]) FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA13" LIMIT 1)
        == [[NONE, "TO_CONFIRM", "service:qualif", "Preuve absente"], ["TO_CONFIRM", "REJECTED", "service:qualif", "Prix incohérent"]];

-- test: rejeu sans changement de qualification : aucune transition ajoutée
-- en tant que: qualif
RETURN fn::ingestion_staged_save({ batch_id: "lot_q", rules_version: "2026.1", items: [
    { ligne_numero: 1, canonical_fingerprint: crypto::blake3("q1"), fabricant: "PLACO", reference_fabricant: "BA13", libelle_commercial: "Plaque BA13 bis", unite_reference: "M2", conditionnement: {}, qualification: "REJECTED" }
] }).data[0].ok
    AND (SELECT VALUE [array::len(transitions), libelle_commercial] FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA13" LIMIT 1) == [2, "Plaque BA13 bis"];

-- test: paramètre inconnu au niveau du bloc
-- en tant que: qualif
RETURN fn::ingestion_staged_save({ batch_id: "lot_q", rules_version: "1", items: [], transitions: [] }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: l'agent d'ingestion n'enregistre pas d'articles (le bloc entier est refusé)
-- en tant que: ingestion
RETURN fn::ingestion_staged_save({ batch_id: "lot_q", rules_version: "1", items: [
    { ligne_numero: 7, canonical_fingerprint: crypto::blake3("q7"), fabricant: "PLACO", reference_fabricant: "BA07", libelle_commercial: "Plaque", unite_reference: "M2", conditionnement: {} }
] }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: liste filtrée (qualification, fabricant) et paginée
-- en tant que: steward
RETURN [
    fn::ingestion_staged_list({ batch_id: "lot_q" }).data.total,
    fn::ingestion_staged_list({ batch_id: "lot_q", qualification: "rejected" }).data.items.reference_fabricant,
    fn::ingestion_staged_list({ batch_id: "lot_q", fabricant: "placo", limit: 1, start: 1 }).data.{ n: array::len(items), total, limit, start }
] == [2, ["BA13"], { n: 1, total: 2, limit: 1, start: 1 }];

-- test: pagination hors bornes refusée
-- en tant que: steward
RETURN fn::ingestion_staged_list({ limit: 5000 }).error.code == "INGESTION_INVALID_PARAMETERS";

-- préparation: identifiants des articles
CREATE test_ref:items SET
    ba13 = <string> (SELECT VALUE id FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA13" LIMIT 1),
    ba06 = <string> (SELECT VALUE id FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA06" LIMIT 1);

-- test: VERIFIED exige une preuve commerciale
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba06, new_qualification: "VERIFIED", justification: "Contrôle du bordereau effectué" }).error.code == "INGESTION_PROOF_MISSING";

-- test: preuve sans référence documentaire suffisante
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba06, new_qualification: "VERIFIED", justification: "Contrôle du bordereau effectué", proof: { proof_type: "SIGNED_VENDOR_CATALOG", proof_reference: "X", source_authority: "Placo" } }).error.code == "INGESTION_PROOF_INVALID";

-- test: type de preuve inconnu
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba06, new_qualification: "VERIFIED", justification: "Contrôle du bordereau effectué", proof: { proof_type: "COURRIEL", proof_reference: "MAIL-2026-01", source_authority: "Commercial Placo" } }).error.code == "INGESTION_PROOF_TYPE_UNKNOWN";

-- test: qualification cible inconnue
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba06, new_qualification: "PROBABLE", justification: "Qualification intermédiaire" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: article inconnu
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: "article_absent", new_qualification: "REJECTED", justification: "Article introuvable en base" }).error.code == "INGESTION_ITEM_NOT_FOUND";

-- test: un article rejeté ne passe pas directement en VERIFIED (garde des articles)
-- en tant que: steward
-- attendu-erreur: INGESTION_STAGED_ILLEGAL_QUALIFICATION_TRANSITION
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba13, new_qualification: "VERIFIED", justification: "Bordereau fabricant vérifié", proof: { proof_type: "SIGNED_VENDOR_CATALOG", proof_reference: "CAT-PLACO-2026", source_authority: "Saint-Gobain Placo" } });

-- test: rejeté → à confirmer → vérifié avec preuve ; approbation enregistrée
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba13, new_qualification: "to_confirm", justification: "Prix corrigé par le fabricant" }).ok
    AND fn::ingestion_staged_requalify({ item_id: test_ref:items.ba13, new_qualification: "VERIFIED", justification: "Bordereau fabricant vérifié", proof: { proof_type: "signed_vendor_catalog", proof_reference: "CAT-PLACO-2026", source_authority: "Saint-Gobain Placo" } }).ok
    AND (SELECT VALUE [qualification, is_approved, approved_by, commercial_proof.proof_reference, array::last(transitions).proof_reference] FROM ONLY <record> test_ref:items.ba13)
        == ["VERIFIED", true, "user:steward", "CAT-PLACO-2026", "CAT-PLACO-2026"];

-- test: une requalification hors VERIFIED ne touche pas à l'approbation
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.ba06, new_qualification: "REJECTED", justification: "Référence abandonnée au catalogue" }).ok
    AND (SELECT VALUE [qualification, is_approved, approved_by] FROM ONLY <record> test_ref:items.ba06) == ["REJECTED", false, NONE];

-- test: indicateurs du lot
-- en tant que: steward
RETURN fn::ingestion_dashboard_metrics({ batch_id: "lot_q" }).data.{ items, lots: batches.total } == { items: { total: 2, verified: 1, to_confirm: 0, rejected: 1, approved: 1 }, lots: 1 };

-- test: indicateurs : paramètre inconnu refusé
-- en tant que: steward
RETURN fn::ingestion_dashboard_metrics({ lot: "lot_q" }).error.code == "INGESTION_INVALID_PARAMETERS";
