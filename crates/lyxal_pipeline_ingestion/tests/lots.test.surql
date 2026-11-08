-- lyxal-test: assertions
-- Lots d'ingestion : création idempotente, lignes brutes immuables, machine à états,
-- points de reprise, sous l'identité de l'agent d'ingestion.
--
-- identité ingestion: { "id": "ingestion_session:ingestion", "sub": "service:ingestion", "role": "ingestion_agent", "scope": ["ingestion:batch:write"] }
-- identité qualif: { "id": "ingestion_session:qualif", "sub": "service:qualif", "role": "qualification_agent", "scope": ["ingestion:staged:qualify"] }
-- identité steward: { "id": "ingestion_session:steward", "sub": "user:steward", "role": "steward_admin", "scope": ["ingestion:manifest:approve"] }
-- identité intrus: { "id": "ingestion_session:intrus", "sub": "user:intrus", "role": "visiteur", "scope": [] }

-- test: l'agent d'ingestion crée un lot (format normalisé, état RECEIVED, transition journalisée)
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_a", source_type: "csv", fournisseur_id: " FOURN_PLACO ", nom_fichier: "placo.csv", file_hash_blake3: crypto::blake3("placo.csv"), taille_octets: 2048, chunk_size: 2 }).data == "lot_a"
    AND (fn::ingestion_batch_get({ id: "lot_a" }).data).{ source_type, fournisseur_id, statut, chunk_size, source_format_version, j: transitions.map(|$t| [$t.from_state, $t.to_state, $t.triggered_by]) }
        == { source_type: "CSV", fournisseur_id: "FOURN_PLACO", statut: "RECEIVED", chunk_size: 2, source_format_version: "1.0", j: [[NONE, "RECEIVED", "service:ingestion"]] };

-- préparation: le banc réserve le lot lot_a (génération 1)
RETURN fn::ingestion_batch_claim({ id: "lot_a", owner: "banc" }).data.generation == 1;

-- test: l'encodage déclaré par défaut est UTF-8
RETURN ingestion_batch:lot_a.source_encoding == "UTF-8";

-- test: un encodage déclaré est normalisé et conservé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_excel", source_type: "CSV", source_encoding: "windows-1252", fournisseur_id: "FOURN_PLACO", nom_fichier: "excel.csv", file_hash_blake3: crypto::blake3("excel.csv") }).ok
    AND ingestion_batch:lot_excel.source_encoding == "WINDOWS-1252";

-- test: un encodage inconnu est refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_ebcdic", source_type: "CSV", source_encoding: "EBCDIC", fournisseur_id: "FOURN_PLACO", nom_fichier: "e.csv", file_hash_blake3: crypto::blake3("e.csv") }).error.{ code, f: object::keys(details.fields) }
    == { code: "INGESTION_SOURCE_INVALID", f: ["source_encoding"] };

-- test: un fichier déjà reçu (même format, même empreinte) est refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_a_bis", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "placo_copie.csv", file_hash_blake3: crypto::blake3("placo.csv") }).error.{ code, batch_id: details.batch_id } == { code: "INGESTION_BATCH_DUPLICATE", batch_id: "lot_a" };

-- test: un identifiant de lot déjà pris est refusé
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_a", source_type: "XML", fournisseur_id: "FOURN_PLACO", nom_fichier: "autre.xml", file_hash_blake3: crypto::blake3("autre.xml") }).error.code == "INGESTION_BATCH_DUPLICATE";

-- test: format source inconnu
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_pdf", source_type: "PDF", fournisseur_id: "F", nom_fichier: "x.pdf", file_hash_blake3: crypto::blake3("x.pdf") }).error.code == "INGESTION_SOURCE_INVALID";

-- test: fournisseur absent
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_sans_fournisseur", source_type: "CSV", nom_fichier: "x.csv", file_hash_blake3: crypto::blake3("x.csv") }).error.code == "INGESTION_MANUFACTURER_REF_MISSING";

-- test: taille de bloc hors bornes
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_bloc", source_type: "CSV", fournisseur_id: "F", nom_fichier: "b.csv", file_hash_blake3: crypto::blake3("b.csv"), chunk_size: 0 }).error.{ code, f: object::keys(details.fields) } == { code: "INGESTION_INVALID_PARAMETERS", f: ["chunk_size"] };

-- test: un autre rôle ne crée pas de lot
-- en tant que: steward
RETURN fn::ingestion_batch_create({ id: "lot_steward", source_type: "CSV", fournisseur_id: "F", nom_fichier: "s.csv", file_hash_blake3: crypto::blake3("s.csv") }).error.code == "INGESTION_WRITE_FORBIDDEN";

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
RETURN fn::ingestion_batch_create({ id: "lot_b", source_type: "JSON", fournisseur_id: "FOURN_ISOVER", nom_fichier: "isover.json", file_hash_blake3: crypto::blake3("isover.json") });

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
RETURN fn::ingestion_batch_get({ id: fn::ingestion_batch_create({ source_type: "XML", fournisseur_id: "FOURN_KNAUF", nom_fichier: "knauf.xml", file_hash_blake3: crypto::blake3("knauf.xml") }).data }).data.{ statut, cle_texte: type::is_string(id) AND string::len(id) == 36 } == { statut: "RECEIVED", cle_texte: true };

-- test: un rôle inconnu ne voit aucun lot
-- en tant que: intrus
RETURN fn::ingestion_batch_get({ id: "lot_b" }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- test: un rôle inconnu ne fait pas avancer un lot
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
