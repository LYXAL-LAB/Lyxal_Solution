-- lyxal-test: assertions
-- Lots d'ingestion : création idempotente, lignes brutes immuables, machine à états,
-- points de reprise, sous l'identité de l'agent d'ingestion.
--
-- identité ingestion: { "id": "auth_session:ingestion", "pv": 1, "permissions": ["ingestion.read", "ingestion.batch.write", "storage.installation.manage"] }
-- identité qualif: { "id": "auth_session:qualif", "pv": 1, "permissions": ["ingestion.read", "ingestion.staged.qualify"] }
-- identité steward: { "id": "auth_session:steward", "pv": 1, "permissions": ["ingestion.read", "ingestion.rule.manage", "ingestion.manifest.approve", "storage.installation.manage"] }
-- identité intrus: { "id": "auth_session:intrus", "pv": 1, "permissions": [] }

-- préparation: fichiers sources dans lyxal_storage (fonction du banc : un fichier disponible dont l'empreinte est celle du contenu donné ; rend sa fiche)
{
    DEFINE FUNCTION OVERWRITE fn::test_source($name: string, $content: string) {
        IF array::len(SELECT VALUE id FROM storage_bucket WHERE scope_key = "installation" AND name = "ingestion-sources") = 0 {
            fn::storage_bucket_create({ name: "ingestion-sources" });
        };
        LET $bucket = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "installation" AND name = "ingestion-sources" LIMIT 1);
        LET $begun = fn::storage_object_begin({ bucket: <string> $bucket, key: $name, filename: $name, declared_size: 2048 });
        LET $done = fn::storage_object_commit({ object: <string> $begun.data.id, size: 2048, content_type: "text/csv", blake3: crypto::blake3($content) });
        RETURN <string> $done.data.id;
    };
};

-- préparation: identités et sessions lyxal_auth (Data Steward en double facteur : AAL2 ; synchronisation : compte de service)
{
    CREATE auth_identity:ingestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "ingestion@exemple.fr" } };
    CREATE auth_identity:qualif CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "qualif@exemple.fr" } };
    CREATE auth_identity:steward CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "steward@exemple.fr" } };
    CREATE auth_identity:intrus CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "intrus@exemple.fr" } };
    CREATE auth_session:ingestion CONTENT { identity: auth_identity:ingestion, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:qualif CONTENT { identity: auth_identity:qualif, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:steward CONTENT { identity: auth_identity:steward, aal: 2, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:intrus CONTENT { identity: auth_identity:intrus, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: l'agent d'ingestion crée un lot (format normalisé, état RECEIVED, transition journalisée)
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_a", source_type: "csv", fournisseur_id: " FOURN_PLACO ", source_object: fn::test_source("placo.csv", "placo.csv"), chunk_size: 2 }).data == "lot_a"
    AND (fn::ingestion_batch_get({ id: "lot_a" }).data).{ source_type, fournisseur_id, statut, chunk_size, source_format_version, j: transitions.map(|$t| [$t.from_state, $t.to_state, $t.triggered_by]) }
        == { source_type: "CSV", fournisseur_id: "FOURN_PLACO", statut: "RECEIVED", chunk_size: 2, source_format_version: "1.0", j: [[NONE, "RECEIVED", "auth_identity:ingestion"]] };

-- préparation: le banc réserve le lot lot_a (génération 1)
RETURN fn::ingestion_batch_claim({ id: "lot_a", owner: "banc" }).data.generation == 1;

-- test: l'encodage déclaré par défaut est UTF-8
RETURN ingestion_batch:lot_a.source_encoding == "UTF-8";

-- test: le nom, la taille et l'empreinte du lot sont lus sur la fiche du fichier source
{
    LET $lot = (SELECT * FROM ONLY ingestion_batch:lot_a);
    LET $fiche = (SELECT * FROM ONLY $lot.source_object);
    RETURN $lot.{ nom_fichier, taille_octets, file_hash_blake3 } == { nom_fichier: "placo.csv", taille_octets: 2048, file_hash_blake3: crypto::blake3("placo.csv") }
        AND $fiche.{ filename, size, blake3, state } == { filename: "placo.csv", size: 2048, blake3: crypto::blake3("placo.csv"), state: "available" }
        AND $lot.commercial_proof IS NONE;
};

-- test: le fichier source d'un lot ne se supprime pas tant que le lot existe
-- en tant que: ingestion
RETURN fn::storage_object_delete({ object: <string> ingestion_batch:lot_a.source_object }).error.code == "STORAGE_OBJECT_IN_USE";

-- test: fichier source absent, ou dont l'envoi n'est pas terminé : lot refusé
-- en tant que: ingestion
{
    LET $bucket = <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "installation" AND name = "ingestion-sources" LIMIT 1);
    LET $pending = <string> fn::storage_object_begin({ bucket: $bucket, key: "en-cours.csv", filename: "en-cours.csv" }).data.id;
    RETURN fn::ingestion_batch_create({ id: "lot_absent", source_type: "CSV", fournisseur_id: "F", source_object: "storage_object:absent" }).error.{ code, cause: details.cause } == { code: "INGESTION_SOURCE_NOT_AVAILABLE", cause: "STORAGE_OBJECT_NOT_FOUND" }
        AND fn::ingestion_batch_create({ id: "lot_en_cours", source_type: "CSV", fournisseur_id: "F", source_object: $pending }).error.{ code, cause: details.cause } == { code: "INGESTION_SOURCE_NOT_AVAILABLE", cause: "pending" }
        AND fn::ingestion_batch_create({ id: "lot_sans_fichier", source_type: "CSV", fournisseur_id: "F" }).error.{ code, f: object::keys(details.fields) } == { code: "INGESTION_SOURCE_INVALID", f: ["source_object"] }
        AND array::len(SELECT VALUE id FROM ingestion_batch WHERE id IN [ingestion_batch:lot_absent, ingestion_batch:lot_en_cours, ingestion_batch:lot_sans_fichier]) == 0;
};

-- test: sans droit de lecture sur le fichier, l'agent de qualification ne crée pas de lot
-- en tant que: qualif
RETURN fn::ingestion_batch_create({ id: "lot_qualif", source_type: "CSV", fournisseur_id: "F", source_object: <string> ingestion_batch:lot_a.source_object }).error.{ code, cause: details.cause } == { code: "INGESTION_SOURCE_NOT_AVAILABLE", cause: "STORAGE_OBJECT_NOT_FOUND" };

-- test: la preuve commerciale jointe à la création est conservée sur le lot
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_preuve", source_type: "CSV", fournisseur_id: "FOURN_PLACO", source_object: fn::test_source("preuve.csv", "preuve.csv"), commercial_proof: { proof_type: "EDI_BORDEREAU", proof_reference: "EDI-BORD-2026-0012", source_authority: "EDI_HUB", verified_by: "steward", verified_at: "2026-11-12T10:00:00Z" } }).ok
    AND ingestion_batch:lot_preuve.commercial_proof.proof_reference == "EDI-BORD-2026-0012";

-- test: lots à traiter : reçus et sans réservation, du plus ancien au plus récent (lot_a est réservé par le banc)
-- en tant que: ingestion
RETURN fn::ingestion_batch_pending_list({}).data.items == ["lot_preuve"]
    AND fn::ingestion_batch_pending_list({ limit: 0 }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: la liste des lots à traiter est réservée au traitement des lots
-- en tant que: qualif
RETURN fn::ingestion_batch_pending_list({}).error.code == "INGESTION_UNAUTHORIZED";

-- test: un encodage déclaré est normalisé et conservé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_excel", source_type: "CSV", source_encoding: "windows-1252", fournisseur_id: "FOURN_PLACO", source_object: fn::test_source("excel.csv", "excel.csv") }).ok
    AND ingestion_batch:lot_excel.source_encoding == "WINDOWS-1252";

-- test: un encodage inconnu est refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_ebcdic", source_type: "CSV", source_encoding: "EBCDIC", fournisseur_id: "FOURN_PLACO", source_object: fn::test_source("e.csv", "e.csv") }).error.{ code, f: object::keys(details.fields) }
    == { code: "INGESTION_SOURCE_INVALID", f: ["source_encoding"] };

-- test: un fichier déjà reçu (même format, même empreinte) est refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_a_bis", source_type: "CSV", fournisseur_id: "FOURN_PLACO", source_object: fn::test_source("placo_copie.csv", "placo.csv") }).error.{ code, batch_id: details.batch_id } == { code: "INGESTION_BATCH_DUPLICATE", batch_id: "lot_a" };

-- test: un identifiant de lot déjà pris est refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_a", source_type: "XML", fournisseur_id: "FOURN_PLACO", source_object: fn::test_source("autre.xml", "autre.xml") }).error.code == "INGESTION_BATCH_DUPLICATE";

-- test: format source inconnu
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_pdf", source_type: "PDF", fournisseur_id: "F", source_object: fn::test_source("x.pdf", "x.pdf") }).error.code == "INGESTION_SOURCE_INVALID";

-- test: fournisseur absent
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_sans_fournisseur", source_type: "CSV", source_object: fn::test_source("x.csv", "x.csv") }).error.code == "INGESTION_MANUFACTURER_REF_MISSING";

-- test: taille de bloc hors bornes
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_bloc", source_type: "CSV", fournisseur_id: "F", source_object: fn::test_source("b.csv", "b.csv"), chunk_size: 0 }).error.{ code, f: object::keys(details.fields) } == { code: "INGESTION_INVALID_PARAMETERS", f: ["chunk_size"] };

-- test: sans la permission ingestion.batch.write, le steward ne crée pas de lot
-- en tant que: steward
RETURN fn::ingestion_batch_create({ id: "lot_steward", source_type: "CSV", fournisseur_id: "F", source_object: fn::test_source("s.csv", "s.csv") }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: l'agent d'ingestion enregistre les lignes brutes d'un bloc
-- en tant que: ingestion
RETURN fn::ingestion_raw_records_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_a", records: [
    { ligne_numero: 1, row_hash: crypto::blake3("l1"), payload_brut: { reference: "BA13" } },
    { ligne_numero: 2, row_hash: crypto::blake3("l2"), payload_brut: { reference: "BA18" } }
] }).data == 2;

-- test: reprise : une ligne déjà enregistrée n'est jamais réécrite, la suivante est ajoutée
-- en tant que: ingestion
RETURN fn::ingestion_raw_records_save({ claim: { owner: "banc", generation: 1 }, batch_id: "ingestion_batch:lot_a", records: [
    { ligne_numero: 2, row_hash: crypto::blake3("modifiée"), payload_brut: { reference: "PIRATE" } },
    { ligne_numero: 3, row_hash: crypto::blake3("l3"), payload_brut: { reference: "BA25" } }
] }).data == 1
    AND (SELECT VALUE [ligne_numero, payload_brut.reference] FROM ingestion_raw_record WHERE batch = ingestion_batch:lot_a ORDER BY ligne_numero) == [[1, "BA13"], [2, "BA18"], [3, "BA25"]];

-- test: une ligne brute mal formée est refusée
-- en tant que: ingestion
RETURN fn::ingestion_raw_records_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_a", records: [{ ligne_numero: 4, row_hash: "court", payload_brut: {} }] }).error.{ code, field: details.field } == { code: "INGESTION_INVALID_PARAMETERS", field: "records.row_hash" };

-- test: l'agent de qualification n'écrit pas de lignes brutes
-- en tant que: qualif
RETURN fn::ingestion_raw_records_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_a", records: [{ ligne_numero: 9, row_hash: crypto::blake3("l9"), payload_brut: {} }] }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: une ligne brute est immuable, même pour l'agent d'ingestion
-- en tant que: ingestion
RETURN (UPDATE ingestion_raw_record:lot_a_1 SET payload_brut = { reference: "PIRATE" }) == []
    AND (SELECT VALUE payload_brut.reference FROM ONLY ingestion_raw_record:lot_a_1) == "BA13";

-- test: machine à états d'un lot jusqu'à la publication
-- en tant que: ingestion
RETURN [
    fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_a", nouveau_statut: "parsing", reason: "Lecture" }).ok,
    fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_a", nouveau_statut: "VALIDATING", reason: "Validation" }).ok,
    fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_a", nouveau_statut: "STAGED", reason: "Staging" }).ok,
    fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_a", nouveau_statut: "PUBLISHED", reason: "Publication" }).ok
] == [true, true, true, true];

-- test: journal des transitions et date d'achèvement
-- en tant que: ingestion
RETURN (fn::ingestion_batch_get({ id: "lot_a" }).data).{ statut, termine: completed_at != NONE, j: transitions.map(|$t| [$t.from_state, $t.to_state, $t.reason]) }
    == { statut: "PUBLISHED", termine: true, j: [[NONE, "RECEIVED", "Réception du fichier"], ["RECEIVED", "PARSING", "Lecture"], ["PARSING", "VALIDATING", "Validation"], ["VALIDATING", "STAGED", "Staging"], ["STAGED", "PUBLISHED", "Publication"]] };

-- test: un lot publié est terminal
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_a", nouveau_statut: "FAILED", reason: "Trop tard", error_code: "INGESTION_TEST_FAILURE" }).error.code == "INGESTION_BATCH_TERMINAL_STATE";

-- test: le passage à STAGED émet ingestion.batch.staged une seule fois (pas à la publication)
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "ingestion.batch.staged")
    == [{ batch_id: "ingestion_batch:lot_a", source_type: "CSV", total_lignes: 0, verified_count: 0, to_confirm_count: 0, rejected_count: 0 }];

-- préparation: second lot
RETURN fn::ingestion_batch_create({ id: "lot_b", source_type: "JSON", fournisseur_id: "FOURN_ISOVER", source_object: fn::test_source("isover.json", "isover.json") });

-- préparation: le banc réserve le lot lot_b (génération 1)
RETURN fn::ingestion_batch_claim({ id: "lot_b", owner: "banc" }).data.generation == 1;

-- test: saut d'étape refusé par la garde du lot
-- en tant que: ingestion
-- attendu-erreur: INGESTION_BATCH_ILLEGAL_STATE_TRANSITION
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "STAGED", reason: "Raccourci" });

-- test: le passage à FAILED exige son code d'erreur
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "FAILED", reason: "Fichier tronqué" }).error.{ code, f: details.fields.error_code }
    == { code: "INGESTION_INVALID_PARAMETERS", f: ["CORE_VALIDATION_REQUIRED"] };

-- test: un code d'erreur est refusé hors passage à FAILED
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "PARSING", reason: "Lecture", error_code: "INGESTION_TEST_FAILURE" }).error.{ code, f: details.fields.error_code }
    == { code: "INGESTION_INVALID_PARAMETERS", f: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: un lot en échec est repris (FAILED puis PARSING)
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "FAILED", reason: "Fichier tronqué", error_code: "INGESTION_SOURCE_TRUNCATED" }).ok
    AND fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "PARSING", reason: "Nouvel essai" }).ok
    AND fn::ingestion_batch_get({ id: "lot_b" }).data.statut == "PARSING";

-- test: le code d'erreur est journalisé dans la transition vers FAILED
RETURN (SELECT VALUE transitions[WHERE to_state = "FAILED"].map(|$t| [$t.error_code, $t.reason]) FROM ONLY ingestion_batch:lot_b) == [["INGESTION_SOURCE_TRUNCATED", "Fichier tronqué"]];

-- test: le passage à FAILED émet ingestion.batch.failed avec le code et le motif
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "ingestion.batch.failed")
    == [{ batch_id: "ingestion_batch:lot_b", error_code: "INGESTION_SOURCE_TRUNCATED", message: "Fichier tronqué" }];

-- test: statut inconnu
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "ARCHIVED", reason: "x" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: motif de transition obligatoire
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "VALIDATING" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: point de reprise enregistré
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ claim: { owner: "banc", generation: 1 }, id: "lot_b", cursor_offset: 200, total_lignes: 500, lignes_verifiees: 150, lignes_a_confirmer: 40, lignes_rejetees: 10 }).ok
    AND (fn::ingestion_batch_get({ id: "lot_b" }).data).{ cursor_offset, total_lignes, lignes_verifiees, lignes_a_confirmer, lignes_rejetees }
        == { cursor_offset: 200, total_lignes: 500, lignes_verifiees: 150, lignes_a_confirmer: 40, lignes_rejetees: 10 };

-- test: compteur négatif refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ claim: { owner: "banc", generation: 1 }, id: "lot_b", cursor_offset: -1, total_lignes: 500, lignes_verifiees: 0, lignes_a_confirmer: 0, lignes_rejetees: 0 }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: point de reprise d'un lot inconnu
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ claim: { owner: "banc", generation: 1 }, id: "lot_absent", cursor_offset: 0, total_lignes: 0, lignes_verifiees: 0, lignes_a_confirmer: 0, lignes_rejetees: 0 }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- test: identifiant d'une autre table refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_get({ id: "catalogue_item:lot_b" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: lot sans identifiant fourni, retrouvé par l'identifiant renvoyé (clé texte)
-- en tant que: ingestion
RETURN fn::ingestion_batch_get({ id: fn::ingestion_batch_create({ source_type: "XML", fournisseur_id: "FOURN_KNAUF", source_object: fn::test_source("knauf.xml", "knauf.xml") }).data }).data.{ statut, cle_texte: type::is_string(id) AND string::len(id) == 36 } == { statut: "RECEIVED", cle_texte: true };

-- test: une session sans permission d'ingestion ne voit aucun lot
-- en tant que: intrus
RETURN fn::ingestion_batch_get({ id: "lot_b" }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- test: une session sans permission d'ingestion ne fait pas avancer un lot
-- en tant que: intrus
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "VALIDATING", reason: "Intrusion" }).error.code == "INGESTION_BATCH_NOT_FOUND"
    AND fn::ingestion_batch_get({ id: "lot_b" }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- préparation: le bus d'événements refuse toute publication
DEFINE FUNCTION OVERWRITE fn::event_publish($params: object) { RETURN fn::error_result("EVENT_INVALID_PARAMETERS", NONE, {}); } PERMISSIONS FULL;

-- préparation: lot repris jusqu'à la validation
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "VALIDATING", reason: "Validation" });

-- test: une publication refusée annule le passage à STAGED
-- en tant que: ingestion
-- attendu-erreur: EVENT_INVALID_PARAMETERS
RETURN fn::ingestion_batch_transition({ claim: { owner: "banc", generation: 1 }, id: "lot_b", nouveau_statut: "STAGED", reason: "Staging" });

-- test: le lot reste en validation, sans événement
RETURN ingestion_batch:lot_b.statut == "VALIDATING"
    AND array::len(SELECT * FROM event_outbox WHERE event_type = "ingestion.batch.staged" AND payload.batch_id = "ingestion_batch:lot_b") == 0;
