-- lyxal-test: assertions
-- Manifestes de publication : brouillon, scellement, approbation par le Data Steward,
-- exécution par l'agent de synchronisation (articles, compte rendu, échec), consultation.
--
-- identité qualif: { "id": "auth_session:qualif", "pv": 1, "permissions": ["ingestion.read", "ingestion.staged.qualify"] }
-- identité steward: { "id": "auth_session:steward", "pv": 1, "permissions": ["ingestion.read", "ingestion.rule.manage", "ingestion.manifest.approve"] }
-- identité sync: { "id": "auth_session:sync", "pv": 1, "permissions": ["ingestion.read", "ingestion.manifest.execute"] }
-- identité steward_aal1: { "id": "auth_session:steward_aal1", "pv": 1, "permissions": ["ingestion.read", "ingestion.rule.manage", "ingestion.manifest.approve"] }
-- identité steward_revoque: { "id": "auth_session:steward_revoque", "pv": 1, "permissions": ["ingestion.read", "ingestion.rule.manage", "ingestion.manifest.approve"] }

-- préparation: identités et sessions lyxal_auth (Data Steward en double facteur : AAL2 ; synchronisation : compte de service)
{
    CREATE auth_identity:qualif CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "qualif@exemple.fr" } };
    CREATE auth_identity:steward CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "steward@exemple.fr" } };
    CREATE auth_session:qualif CONTENT { identity: auth_identity:qualif, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:steward CONTENT { identity: auth_identity:steward, aal: 2, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:steward_aal1 CONTENT { identity: auth_identity:steward, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:steward_revoque CONTENT { identity: auth_identity:steward, aal: 2, state: "revoked", revoked_at: time::now(), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:sync CONTENT { application: auth_application:catalogue_sync, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: lot
RETURN fn::ingestion_batch_create({ id: "lot_m", source_type: "CSV", fournisseur_id: "FOURN_ISOVER", nom_fichier: "m.csv", file_hash_blake3: crypto::blake3("m.csv") });

-- test: le steward enregistre un brouillon
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: " MAN-M1 ", batch_id: "lot_m", nb_articles_insert: 2 }).data == "MAN-M1"
    AND (fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-M1" }).data).{ s: manifest.statut, is_sealed, transition_count, execution_count, lot: batch.id }
        == { s: "DRAFT", is_sealed: false, transition_count: 1, execution_count: 0, lot: "lot_m" };

-- test: un brouillon n'est pas approuvé
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-M1", justification: "Approbation prématurée du brouillon" }).error.code == "INGESTION_MANIFEST_UNSEALED";

-- test: scellement du brouillon ; la transition est journalisée
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1", batch_id: "lot_m", statut: "sealed", nb_articles_insert: 2 }).ok
    AND (SELECT VALUE [statut, is_sealed, contenu, seal_hash == crypto::blake3(<string> contenu), transitions.map(|$t| [$t.from_state, $t.to_state])] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1)
        == ["SEALED", true, [], true, [[NONE, "DRAFT"], ["DRAFT", "SEALED"]]];

-- test: le scellement verrouille le lot
RETURN ingestion_batch:lot_m.sealed_manifest == "MAN-M1";

-- test: une seconde version de même numéro pour le lot est refusée
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1-BIS", batch_id: "lot_m", statut: "SEALED" }).error.{ code, ref: details.manifest_ref } == { code: "INGESTION_MANIFEST_VERSION_DUPLICATE", ref: "MAN-M1" };

-- test: un manifeste rattaché à un autre lot n'est pas réaffecté
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1", batch_id: "lot_autre", statut: "SEALED" }).error.code == "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION";

-- test: un sceau fourni par l'appelant est refusé (calculé par le serveur seulement)
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M2", batch_id: "lot_m", manifest_version: 2, seal_hash: crypto::blake3("sceau"), statut: "SEALED" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: un second manifeste ne se scelle pas sur un lot déjà verrouillé
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M2", batch_id: "lot_m", manifest_version: 2, statut: "SEALED" }).error.{ code, ref: details.manifest_ref } == { code: "INGESTION_STAGED_ITEM_SEALED", ref: "MAN-M1" };

-- test: remis en brouillon, le manifeste perd contenu et sceau, et le lot est déverrouillé
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1", batch_id: "lot_m", nb_articles_insert: 2 }).ok
    AND (SELECT VALUE [statut, is_sealed, contenu, seal_hash] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1) == ["DRAFT", false, NONE, NONE]
    AND ingestion_batch:lot_m.sealed_manifest == NONE;

-- test: rescellé, il fige de nouveau son contenu et reverrouille le lot
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1", batch_id: "lot_m", statut: "SEALED", nb_articles_insert: 2 }).ok
    AND fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-M1" }).data.seal_valid
    AND ingestion_batch:lot_m.sealed_manifest == "MAN-M1";

-- test: le verrou du lot ne se pose ni ne se retire hors du steward
-- en tant que: qualif
-- attendu-erreur: INGESTION_STAGED_ITEM_SEALED
UPDATE ingestion_batch:lot_m SET sealed_manifest = NONE;

-- test: l'agent de qualification n'enregistre pas de manifeste
-- en tant que: qualif
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-QUALIF", batch_id: "lot_m", manifest_version: 3 }).error.code == "INGESTION_WRITE_FORBIDDEN";

-- test: approbation d'un manifeste inconnu
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-ABSENT", justification: "Manifeste introuvable en base" }).error.code == "INGESTION_MANIFEST_NOT_FOUND";

-- test: approbation : paramètre inconnu refusé
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-M1", justification: "Lot contrôlé et conforme", approved_by: "pirate" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: approbation refusée à une session du steward sans double facteur (AAL1)
-- en tant que: steward_aal1
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-M1", justification: "Lot contrôlé et conforme" }).error.{ code, permission: details.permission }
    == { code: "INGESTION_UNAUTHORIZED_APPROVER", permission: "ingestion.manifest.approve" };

-- test: sans double facteur, l'approbation par écriture directe n'a aucun effet
-- en tant que: steward_aal1
RETURN (UPDATE ingestion_publication_manifest SET statut = "APPROVED", approved_by = "auth_identity:steward" WHERE manifest_ref = "MAN-M1") == []
    AND (SELECT VALUE statut FROM ingestion_publication_manifest WHERE manifest_ref = "MAN-M1") == ["SEALED"];

-- test: une session révoquée n'a plus aucun droit, même en double facteur
-- en tant que: steward_revoque
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-M1", justification: "Lot contrôlé et conforme" }).error.code == "INGESTION_UNAUTHORIZED_APPROVER"
    AND count(SELECT id FROM ingestion_publication_manifest) == 0
    AND count(SELECT id FROM ingestion_batch) == 0;

-- test: le manifeste est toujours scellé, non approuvé
RETURN (SELECT VALUE statut FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1) == "SEALED";

-- test: le steward approuve le manifeste scellé (session en double facteur, AAL2)
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-M1", justification: "Lot contrôlé et conforme" }).ok;

-- test: l'approbation est enregistrée au nom de l'identité de la session
RETURN (SELECT VALUE [statut, approved_by, array::last(transitions).triggered_by] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1)
    == ["APPROVED", "auth_identity:steward", "auth_identity:steward"];

-- test: un manifeste approuvé n'est plus modifiable
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1", batch_id: "lot_m", statut: "SEALED" }).error.code == "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION";

-- test: le steward ne journalise pas l'exécution d'un article
-- en tant que: steward
RETURN fn::ingestion_manifest_execution_item_update({ manifest_ref: "MAN-M1", item_ref: "IBR-100", action: "INSERT", success: true }).error.code == "INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED";

-- test: action de publication inconnue
-- en tant que: sync
RETURN fn::ingestion_manifest_execution_item_update({ manifest_ref: "MAN-M1", item_ref: "IBR-100", action: "MERGE", success: true }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: l'agent de synchronisation journalise un succès et un échec
-- en tant que: sync
RETURN fn::ingestion_manifest_execution_item_update({ manifest_ref: "MAN-M1", item_ref: "IBR-100", action: "insert", success: true }).ok
    AND fn::ingestion_manifest_execution_item_update({ manifest_ref: "MAN-M1", item_ref: "IBR-200", action: "INSERT", success: false, error: "Catalogue indisponible" }).ok
    AND (SELECT VALUE [items_committed, items_failed, execution_items.map(|$e| [$e.item_ref, $e.action, $e.success, $e.error])] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1)
        == [1, 1, [["IBR-100", "INSERT", true, NONE], ["IBR-200", "INSERT", false, "Catalogue indisponible"]]];

-- test: compte rendu d'échec : APPROVED → EXECUTING → FAILED
-- en tant que: sync
RETURN fn::ingestion_manifest_record_exec({ manifest_ref: "MAN-M1", statut: "failed", items_committed: 1, items_failed: 1 }).ok
    AND (SELECT VALUE [statut, executed_at != NONE, transitions.map(|$t| $t.to_state)] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1)
        == ["FAILED", true, ["DRAFT", "SEALED", "DRAFT", "SEALED", "APPROVED", "EXECUTING", "FAILED"]];

-- test: plus aucune exécution d'article sur un manifeste en échec
-- en tant que: sync
RETURN fn::ingestion_manifest_execution_item_update({ manifest_ref: "MAN-M1", item_ref: "IBR-300", action: "INSERT", success: true }).error.code == "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION";

-- test: compte rendu : statut final inconnu
-- en tant que: sync
RETURN fn::ingestion_manifest_record_exec({ manifest_ref: "MAN-M1", statut: "APPROVED", items_committed: 0, items_failed: 0 }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: compte rendu d'un manifeste inconnu
-- en tant que: sync
RETURN fn::ingestion_manifest_record_exec({ manifest_ref: "MAN-ABSENT", statut: "COMMITTED", items_committed: 0, items_failed: 0 }).error.code == "INGESTION_MANIFEST_NOT_FOUND";

-- test: un manifeste en échec ne se rescelle pas directement (remise en brouillon d'abord)
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-M1", batch_id: "lot_m", statut: "SEALED" }).error.code == "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION";

-- test: contenu et sceau d'un manifeste approuvé ou en échec ne se modifient pas directement
-- attendu-erreur: INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION
UPDATE ingestion_publication_manifest SET contenu = [{ item_ref: "PIRATE" }] WHERE manifest_ref = "MAN-M1";

-- test: un manifeste en échec est réapprouvé par le steward
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-M1", justification: "Nouvel essai après incident catalogue" }).ok
    AND (SELECT VALUE statut FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-M1" LIMIT 1) == "APPROVED";

-- test: listes par statut et par lot
-- en tant que: sync
RETURN [
    fn::ingestion_manifest_list({ statut: "approved" }).data.manifests.map(|$m| [$m.manifest_ref, $m.batch]),
    fn::ingestion_manifest_list({ batch_id: "lot_m", statut: "COMMITTED" }).data.total
] == [[["MAN-M1", "lot_m"]], 0];

-- test: statut de liste inconnu
-- en tant que: sync
RETURN fn::ingestion_manifest_list({ statut: "ARCHIVED" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: détail d'un manifeste inconnu
-- en tant que: steward
RETURN fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-ABSENT" }).error.code == "INGESTION_MANIFEST_NOT_FOUND";

-- test: l'agent de qualification ne voit pas les manifestes
-- en tant que: qualif
RETURN fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-M1" }).error.code == "INGESTION_MANIFEST_NOT_FOUND"
    AND fn::ingestion_manifest_list({}).data.total == 0;
