-- lyxal-test: assertions
-- Réservation des lots : une seule exécution de traitement à la fois (prise, exclusion même
-- avec le même jeton, renouvellement par le point de reprise, cloisonnement des écritures,
-- reprise après expiration, libération).
--
-- identité ingestion: { "id": "ingestion_session:ingestion", "sub": "service:ingestion", "role": "ingestion_agent", "scope": ["ingestion:batch:write"] }
-- identité intrus: { "id": "ingestion_session:intrus", "sub": "user:intrus", "role": "visiteur", "scope": [] }

-- préparation: lot
RETURN fn::ingestion_batch_create({ id: "lot_r", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "r.csv", file_hash_blake3: crypto::blake3("r.csv") });

-- test: un lot libre est réservé (génération 1, échéance dans la durée demandée)
-- en tant que: ingestion
RETURN fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_1", ttl_seconds: 60 }).data.{ generation, ok_until: until > time::now() + 50s AND until <= time::now() + 60s }
    == { generation: 1, ok_until: true };

-- test: une réservation active est refusée, même présentée avec le même jeton
-- en tant que: ingestion
RETURN fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_1" }).error.{ code, a_echeance: details.until != NONE } == { code: "INGESTION_BATCH_ALREADY_CLAIMED", a_echeance: true }
    AND fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_2" }).error.code == "INGESTION_BATCH_ALREADY_CLAIMED"
    AND ingestion_batch:lot_r.{ claim_owner, claim_generation } == { claim_owner: "exec_1", claim_generation: 1 };

-- test: durée de réservation hors bornes
-- en tant que: ingestion
RETURN fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_2", ttl_seconds: 1 }).error.{ code, f: object::keys(details.fields) } == { code: "INGESTION_INVALID_PARAMETERS", f: ["ttl_seconds"] };

-- test: un rôle inconnu ne réserve pas de lot
-- en tant que: intrus
RETURN fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_x" }).error.code == "INGESTION_BATCH_NOT_FOUND";

-- test: une écriture du traitement sans réservation est refusée
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ id: "lot_r", cursor_offset: 1, total_lignes: 1, lignes_verifiees: 0, lignes_a_confirmer: 0, lignes_rejetees: 0 }).error.{ code, f: object::keys(details.fields) }
    == { code: "INGESTION_INVALID_PARAMETERS", f: ["claim"] };

-- préparation: réservation proche de son échéance
UPDATE ingestion_batch:lot_r SET claim_until = time::now() + 2s;

-- test: le point de reprise de l'exécution détentrice renouvelle la réservation
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ claim: { owner: "exec_1", generation: 1 }, id: "lot_r", cursor_offset: 2, total_lignes: 4, lignes_verifiees: 2, lignes_a_confirmer: 0, lignes_rejetees: 0 }).ok
    AND ingestion_batch:lot_r.claim_until > time::now() + 50s;

-- test: cloisonnement : un autre propriétaire ne fait pas reculer le point de reprise
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ claim: { owner: "exec_2", generation: 1 }, id: "lot_r", cursor_offset: 0, total_lignes: 4, lignes_verifiees: 0, lignes_a_confirmer: 0, lignes_rejetees: 0 }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND ingestion_batch:lot_r.cursor_offset == 2;

-- test: cloisonnement : une génération périmée n'écrit ni article ni transition
-- en tant que: ingestion
RETURN fn::ingestion_staged_save({ claim: { owner: "exec_1", generation: 2 }, batch_id: "lot_r", rules_version: "v1", items: [{ ligne_numero: 1, fabricant: "PLACO", reference_fabricant: "BA13" }] }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND fn::ingestion_batch_transition({ claim: { owner: "exec_1", generation: 2 }, id: "lot_r", nouveau_statut: "PARSING", reason: "Lecture" }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND array::len(SELECT * FROM ingestion_staged_item WHERE batch = ingestion_batch:lot_r) == 0
    AND ingestion_batch:lot_r.statut == "RECEIVED";

-- test: l'exécution détentrice fait avancer le lot
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "exec_1", generation: 1 }, id: "lot_r", nouveau_statut: "PARSING", reason: "Lecture" }).ok
    AND ingestion_batch:lot_r.statut == "PARSING";

-- préparation: l'exécution 1 s'arrête sans libérer (réservation expirée)
UPDATE ingestion_batch:lot_r SET claim_until = time::now() - 1s;

-- test: une réservation expirée n'autorise plus aucune écriture
-- en tant que: ingestion
RETURN fn::ingestion_raw_records_save({ claim: { owner: "exec_1", generation: 1 }, batch_id: "lot_r", records: [{ ligne_numero: 1, row_hash: crypto::blake3("r1"), payload_brut: { reference: "BA13" } }] }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND array::len(SELECT * FROM ingestion_raw_record WHERE batch = ingestion_batch:lot_r) == 0;

-- test: une réservation expirée est reprise par une autre exécution, génération supérieure
-- en tant que: ingestion
RETURN fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_2" }).data.generation == 2
    AND ingestion_batch:lot_r.claim_owner == "exec_2";

-- test: l'exécution écartée ne peut plus écrire, ni consigner d'anomalie
-- en tant que: ingestion
RETURN fn::ingestion_batch_checkpoint({ claim: { owner: "exec_1", generation: 1 }, id: "lot_r", cursor_offset: 0, total_lignes: 4, lignes_verifiees: 0, lignes_a_confirmer: 0, lignes_rejetees: 0 }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND fn::ingestion_quarantine_log({ claim: { owner: "exec_1", generation: 1 }, batch_id: "lot_r", ligne_numero: 1, code_erreur: "INGESTION_GTIN_INVALID", champ_concerne: "gtin", cause_detaillee: "Clé" }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND array::len(SELECT * FROM ingestion_quarantine_record WHERE batch = ingestion_batch:lot_r) == 0
    AND ingestion_batch:lot_r.cursor_offset == 2;

-- test: l'exécution écartée ne libère pas la réservation de la nouvelle
-- en tant que: ingestion
RETURN fn::ingestion_batch_release({ id: "lot_r", owner: "exec_1", generation: 1 }).error.code == "INGESTION_BATCH_CLAIM_LOST"
    AND ingestion_batch:lot_r.{ claim_owner, claim_generation } == { claim_owner: "exec_2", claim_generation: 2 };

-- test: l'exécution détentrice libère le lot
-- en tant que: ingestion
RETURN fn::ingestion_batch_release({ id: "lot_r", owner: "exec_2", generation: 2 }).ok
    AND ingestion_batch:lot_r.{ claim_owner, claim_until, claim_generation } == { claim_owner: NONE, claim_until: NONE, claim_generation: 2 };

-- test: une réservation libérée n'autorise plus d'écriture
-- en tant que: ingestion
RETURN fn::ingestion_batch_transition({ claim: { owner: "exec_2", generation: 2 }, id: "lot_r", nouveau_statut: "VALIDATING", reason: "Validation" }).error.code == "INGESTION_BATCH_CLAIM_LOST";

-- test: un lot libéré est de nouveau réservable (génération suivante)
-- en tant que: ingestion
RETURN fn::ingestion_batch_claim({ id: "lot_r", owner: "exec_3" }).data.generation == 3;

-- test: la génération de réservation ne recule jamais
-- attendu-erreur: INGESTION_BATCH_CLAIM_LOST
UPDATE ingestion_batch:lot_r SET claim_generation = 1;
