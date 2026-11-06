-- lyxal-test: assertions
-- Permissions des tables : ce que chaque rôle lit, et aucune suppression possible.
-- Données préparées en session système (hôte).
--
-- identité ingestion: { "id": "ingestion_session:ingestion", "sub": "service:ingestion", "role": "ingestion_agent", "scope": ["ingestion:batch:write"] }
-- identité qualif: { "id": "ingestion_session:qualif", "sub": "service:qualif", "role": "qualification_agent", "scope": ["ingestion:staged:qualify"] }
-- identité steward: { "id": "ingestion_session:steward", "sub": "user:steward", "role": "steward_admin", "scope": ["ingestion:manifest:approve"] }
-- identité sync: { "id": "ingestion_session:sync", "sub": "service:sync", "role": "catalogue_sync_agent", "scope": ["catalogue:sync:write"] }
-- identité intrus: { "id": "ingestion_session:intrus", "sub": "user:intrus", "role": "visiteur", "scope": [] }

-- préparation: lot
RETURN fn::ingestion_batch_create({ id: "lot_p", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "p.csv", file_hash_blake3: crypto::blake3("p.csv") });

-- préparation: ligne brute
RETURN fn::ingestion_raw_records_save({ batch_id: "lot_p", records: [{ ligne_numero: 1, row_hash: crypto::blake3("p1"), payload_brut: { reference: "BA13" } }] });

-- préparation: article
RETURN fn::ingestion_staged_save({ batch_id: "lot_p", rules_version: "1", items: [{ ligne_numero: 1, canonical_fingerprint: crypto::blake3("p1"), fabricant: "PLACO", reference_fabricant: "BA13", libelle_commercial: "Plaque BA13", unite_reference: "M2", conditionnement: {} }] });

-- préparation: anomalie
RETURN fn::ingestion_quarantine_log({ batch_id: "lot_p", ligne_numero: 1, code_erreur: "INGESTION_UNIT_UNRESOLVED", champ_concerne: "unite_reference", cause_detaillee: "Unité à confirmer" });

-- préparation: manifeste scellé
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-P", batch_id: "lot_p", seal_hash: crypto::blake3("MAN-P"), statut: "SEALED" });

-- préparation: table de lecture commune aux tests
DEFINE FUNCTION fn::test_visible() {
    RETURN {
        lot: count(SELECT id FROM ingestion_batch),
        brut: count(SELECT id FROM ingestion_raw_record),
        article: count(SELECT id FROM ingestion_staged_item),
        anomalie: count(SELECT id FROM ingestion_quarantine_record),
        manifeste: count(SELECT id FROM ingestion_publication_manifest),
        famille: count(SELECT id FROM ingestion_family_rule) > 0,
        alias: count(SELECT id FROM ingestion_unit_alias) > 0
    };
} PERMISSIONS FULL;

-- test: l'agent d'ingestion lit les lots et les lignes brutes, pas la suite du pipeline
-- en tant que: ingestion
RETURN fn::test_visible() == { lot: 1, brut: 1, article: 0, anomalie: 0, manifeste: 0, famille: true, alias: true };

-- test: l'agent de qualification lit lots, lignes brutes, articles et anomalies
-- en tant que: qualif
RETURN fn::test_visible() == { lot: 1, brut: 1, article: 1, anomalie: 1, manifeste: 0, famille: true, alias: true };

-- test: le steward lit tout le pipeline
-- en tant que: steward
RETURN fn::test_visible() == { lot: 1, brut: 1, article: 1, anomalie: 1, manifeste: 1, famille: true, alias: true };

-- test: l'agent de synchronisation lit lots, articles et manifestes, pas les lignes brutes ni les anomalies
-- en tant que: sync
RETURN fn::test_visible() == { lot: 1, brut: 0, article: 1, anomalie: 0, manifeste: 1, famille: true, alias: true };

-- test: un rôle inconnu ne lit rien
-- en tant que: intrus
RETURN fn::test_visible() == { lot: 0, brut: 0, article: 0, anomalie: 0, manifeste: 0, famille: false, alias: false };

-- test: les indicateurs suivent les droits de lecture
-- en tant que: intrus
RETURN fn::ingestion_dashboard_metrics({}).data.{ l: batches.total, a: items.total, q: quarantine.total, m: manifests.total } == { l: 0, a: 0, q: 0, m: 0 };

-- test: le steward ne supprime rien
-- en tant que: steward
RETURN [
    (DELETE ingestion_batch RETURN BEFORE),
    (DELETE ingestion_raw_record RETURN BEFORE),
    (DELETE ingestion_staged_item RETURN BEFORE),
    (DELETE ingestion_quarantine_record RETURN BEFORE),
    (DELETE ingestion_publication_manifest RETURN BEFORE),
    (DELETE ingestion_family_rule RETURN BEFORE)
] == [[], [], [], [], [], []];

-- test: les agents ne suppriment rien non plus
-- en tant que: qualif
RETURN [(DELETE ingestion_staged_item RETURN BEFORE), (DELETE ingestion_quarantine_record RETURN BEFORE)] == [[], []];

-- test: tout est encore en place
RETURN [count(SELECT id FROM ingestion_batch), count(SELECT id FROM ingestion_raw_record), count(SELECT id FROM ingestion_staged_item), count(SELECT id FROM ingestion_quarantine_record), count(SELECT id FROM ingestion_publication_manifest)] == [1, 1, 1, 1, 1];

-- test: l'agent de synchronisation ne modifie pas un article
-- en tant que: sync
RETURN (UPDATE ingestion_staged_item SET libelle_commercial = "Modifié") == []
    AND (SELECT VALUE libelle_commercial FROM ingestion_staged_item) == ["Plaque BA13"];

-- test: l'agent d'ingestion ne modifie pas un manifeste
-- en tant que: ingestion
RETURN (UPDATE ingestion_publication_manifest SET nb_articles_insert = 99) == [];

-- test: l'agent de qualification n'administre pas les alias
-- en tant que: qualif
RETURN (CREATE ingestion_unit_alias CONTENT { raw_alias: "BIDON", canonical_unit: "PCE", created_at: time::now(), updated_at: time::now() }) == []
    AND count(SELECT id FROM ingestion_unit_alias WHERE raw_alias = "BIDON") == 0;
