-- lyxal-test: assertions
-- Permissions des tables : ce que chaque jeu de permissions ingestion.* lit, sessions révoquées ou périmées, et aucune suppression possible.
-- Données préparées en session système (hôte).
--
-- identité ingestion: { "id": "auth_session:ingestion", "pv": 1, "permissions": ["ingestion.read", "ingestion.batch.write"] }
-- identité qualif: { "id": "auth_session:qualif", "pv": 1, "permissions": ["ingestion.read", "ingestion.staged.qualify"] }
-- identité steward: { "id": "auth_session:steward", "pv": 1, "permissions": ["ingestion.read", "ingestion.rule.manage", "ingestion.manifest.approve"] }
-- identité sync: { "id": "auth_session:sync", "pv": 1, "permissions": ["ingestion.read", "ingestion.manifest.execute"] }
-- identité revoque: { "id": "auth_session:revoque", "pv": 1, "permissions": ["ingestion.read", "ingestion.batch.write", "ingestion.staged.qualify", "ingestion.rule.manage", "ingestion.manifest.approve", "ingestion.manifest.execute"] }
-- identité perimee: { "id": "auth_session:perimee", "pv": 0, "permissions": ["ingestion.read", "ingestion.batch.write", "ingestion.staged.qualify", "ingestion.rule.manage", "ingestion.manifest.approve", "ingestion.manifest.execute"] }
-- identité intrus: { "id": "auth_session:intrus", "pv": 1, "permissions": [] }

-- préparation: identités et sessions lyxal_auth (Data Steward en double facteur : AAL2 ; synchronisation : compte de service)
{
    CREATE auth_identity:ingestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "ingestion@exemple.fr" } };
    CREATE auth_identity:qualif CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "qualif@exemple.fr" } };
    CREATE auth_identity:steward CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "steward@exemple.fr" } };
    CREATE auth_identity:intrus CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "intrus@exemple.fr" } };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@exemple.fr" } };
    CREATE auth_session:revoque CONTENT { identity: auth_identity:admin, aal: 2, state: "revoked", revoked_at: time::now(), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:perimee CONTENT { identity: auth_identity:admin, aal: 2, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:ingestion CONTENT { identity: auth_identity:ingestion, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:qualif CONTENT { identity: auth_identity:qualif, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:steward CONTENT { identity: auth_identity:steward, aal: 2, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:sync CONTENT { application: auth_application:catalogue_sync, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:intrus CONTENT { identity: auth_identity:intrus, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: lot
RETURN fn::ingestion_batch_create({ id: "lot_p", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "p.csv", file_hash_blake3: crypto::blake3("p.csv") });

-- préparation: le banc réserve le lot lot_p (génération 1)
RETURN fn::ingestion_batch_claim({ id: "lot_p", owner: "banc" }).data.generation == 1;

-- préparation: ligne brute
RETURN fn::ingestion_raw_records_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_p", records: [{ ligne_numero: 1, row_hash: crypto::blake3("p1"), payload_brut: { reference: "BA13" } }] });

-- préparation: article
RETURN fn::ingestion_staged_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_p", rules_version: "1", items: [{ ligne_numero: 1, canonical_fingerprint: crypto::blake3("p1"), fabricant: "PLACO", reference_fabricant: "BA13", libelle_commercial: "Plaque BA13", unite_reference: "M2", conditionnement: {} }] });

-- préparation: anomalie
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_p", ligne_numero: 1, code_erreur: "INGESTION_UNIT_UNRESOLVED", champ_concerne: "unite_reference", cause_detaillee: "Unité à confirmer" });

-- préparation: manifeste scellé
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-P", batch_id: "lot_p", statut: "SEALED" });

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

-- test: une session sans permission d'ingestion ne lit rien
-- en tant que: intrus
RETURN fn::test_visible() == { lot: 0, brut: 0, article: 0, anomalie: 0, manifeste: 0, famille: false, alias: false };

-- test: une session révoquée ne lit rien, même avec toutes les permissions dans son jeton
-- en tant que: revoque
RETURN fn::test_visible() == { lot: 0, brut: 0, article: 0, anomalie: 0, manifeste: 0, famille: false, alias: false };

-- test: une session révoquée n'écrit rien
-- en tant que: revoque
RETURN (UPDATE ingestion_batch SET nom_fichier = "pirate.csv") == []
    AND fn::ingestion_batch_create({ id: "lot_revoque", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "r.csv", file_hash_blake3: crypto::blake3("r.csv") }).ok == false;

-- test: un jeton aux droits périmés (version dépassée) ne lit rien
-- en tant que: perimee
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
