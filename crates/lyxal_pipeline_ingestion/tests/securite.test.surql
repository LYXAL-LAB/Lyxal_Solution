-- lyxal-test: assertions
-- Sécurité : identité lue uniquement dans la session (jamais dans les paramètres),
-- approbations réservées à la permission ingestion.manifest.approve (AAL2), gardes des articles et des manifestes.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité ingestion: { "id": "auth_session:ingestion", "pv": 1, "permissions": ["ingestion.read", "ingestion.batch.write"] }
-- identité qualif: { "id": "auth_session:qualif", "pv": 1, "permissions": ["ingestion.read", "ingestion.staged.qualify"] }
-- identité steward: { "id": "auth_session:steward", "pv": 1, "permissions": ["ingestion.read", "ingestion.rule.manage", "ingestion.manifest.approve"] }
-- identité sync: { "id": "auth_session:sync", "pv": 1, "permissions": ["ingestion.read", "ingestion.manifest.execute"] }

-- préparation: identités et sessions lyxal_auth (Data Steward en double facteur : AAL2 ; synchronisation : compte de service)
{
    CREATE auth_identity:ingestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "ingestion@exemple.fr" } };
    CREATE auth_identity:qualif CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "qualif@exemple.fr" } };
    CREATE auth_identity:steward CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "steward@exemple.fr" } };
    CREATE auth_session:ingestion CONTENT { identity: auth_identity:ingestion, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:qualif CONTENT { identity: auth_identity:qualif, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:steward CONTENT { identity: auth_identity:steward, aal: 2, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:sync CONTENT { application: auth_application:catalogue_sync, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- test: l'agent d'ingestion crée un lot
-- en tant que: ingestion
RETURN fn::ingestion_batch_create({ id: "lot_sec", source_type: "CSV", fournisseur_id: "FOURN_PLACO", nom_fichier: "placo.csv", file_hash_blake3: crypto::blake3("placo.csv") }).data == "lot_sec";

-- préparation: le banc réserve le lot lot_sec (génération 1)
RETURN fn::ingestion_batch_claim({ id: "lot_sec", owner: "banc" }).data.generation == 1;

-- préparation: lignes brutes du fichier (écrites par le worker)
FOR $n IN [1, 2, 3] { CREATE type::record("ingestion_raw_record", string::concat("lot_sec_", <string> $n)) CONTENT { batch: ingestion_batch:lot_sec, ligne_numero: $n, row_hash: crypto::blake3(<string> $n), payload_brut: {}, created_at: time::now() }; };

-- test: l'agent de qualification enregistre deux articles, jamais approuvés à la création
-- en tant que: qualif
RETURN fn::ingestion_staged_save({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_sec", rules_version: "1", items: [
    { ligne_numero: 1, canonical_fingerprint: crypto::blake3("a1"), fabricant: "PLACO", reference_fabricant: "BA13", libelle_commercial: "Plaque BA13", type_item: "PRODUIT", unite_reference: "PCE", conditionnement: { unite_vente: "PCE", quantite_par_colis: 1.0 }, qualification: "TO_CONFIRM", publication_action: "INSERT" },
    { ligne_numero: 2, canonical_fingerprint: crypto::blake3("a2"), fabricant: "PLACO", reference_fabricant: "BA18", libelle_commercial: "Plaque BA18", type_item: "PRODUIT", unite_reference: "PCE", conditionnement: { unite_vente: "PCE", quantite_par_colis: 1.0 }, qualification: "TO_CONFIRM", publication_action: "INSERT", is_approved: true, approved_by: "pirate" }
] }).data.ok == [true, true];

-- test: une approbation passée en paramètre est ignorée
RETURN (SELECT VALUE [is_approved, approved_by] FROM ingestion_staged_item ORDER BY ligne_numero) == [[false, NONE], [false, NONE]];

-- préparation: identifiants des articles
CREATE test_ref:items SET
    a1 = <string> (SELECT VALUE id FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA13" LIMIT 1),
    a2 = <string> (SELECT VALUE id FROM ONLY ingestion_staged_item WHERE reference_fabricant = "BA18" LIMIT 1);

-- test: un rôle forgé dans les paramètres ne donne aucun droit
-- en tant que: qualif
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.a1, new_qualification: "REJECTED", justification: "Rejet par usurpation de rôle", _session_auth: { role: "steward_admin", user_id: "pirate" } }).error.code == "INGESTION_UNAUTHORIZED_APPROVER";

-- test: l'agent de synchronisation ne requalifie pas
-- en tant que: sync
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.a1, new_qualification: "REJECTED", justification: "Requalification illégitime" }).error.code == "INGESTION_UNAUTHORIZED_APPROVER";

-- test: le steward requalifie avec preuve ; son identité est enregistrée
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.a1, new_qualification: "VERIFIED", justification: "Bordereau fabricant vérifié", proof: { proof_type: "SIGNED_VENDOR_CATALOG", proof_reference: "CAT-PLACO-2026", source_authority: "Saint-Gobain Placo" } }).ok;

-- test: approbation enregistrée au nom du steward de la session
RETURN (SELECT VALUE [qualification, is_approved, approved_by] FROM ONLY <record> test_ref:items.a1) == ["VERIFIED", true, "auth_identity:steward"];

-- test: l'agent de qualification n'approuve pas un article en écrivant les champs lui-même
-- en tant que: qualif
-- attendu-erreur: INGESTION_STAGED_APPROVAL_REQUIRES_STEWARD
UPDATE <record> test_ref:items.a2 SET qualification = "VERIFIED", is_approved = true, approved_by = "auth_identity:steward";

-- test: un article n'est jamais créé déjà approuvé
-- en tant que: qualif
-- attendu-erreur: INGESTION_STAGED_APPROVAL_REQUIRES_STEWARD
CREATE ingestion_staged_item CONTENT { batch: ingestion_batch:lot_sec, raw_record: ingestion_raw_record:lot_sec_3, ligne_numero: 3, canonical_fingerprint: crypto::blake3("a3"), rules_version: "1", fabricant: "PLACO", reference_fabricant: "BA25", libelle_commercial: "Plaque BA25", type_item: "PRODUIT", unite_reference: "PCE", conditionnement: { unite_vente: "PCE", quantite_par_colis: 1.0 }, qualification: "VERIFIED", publication_action: "INSERT", transitions: [], is_approved: true, approved_by: "auth_identity:steward", created_at: time::now(), updated_at: time::now() };

-- test: le steward enregistre un manifeste scellé
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-SEC", batch_id: "lot_sec", statut: "SEALED", nb_articles_insert: 1 }).ok;

-- test: le contenu figé contient l'article VERIFIED avec sa charge utile catalogue et sa preuve
-- en tant que: steward
RETURN (fn::ingestion_manifest_get_detail({ manifest_ref: "MAN-SEC" }).data).{
        valide: seal_valid,
        refs: manifest.contenu.map(|$e| $e.catalogue.reference_fabricant),
        item: manifest.contenu[0].catalogue.{ libelle, unite_reference, unite_conditionnement, nature_reference, q: conditionnement.quantite },
        code_stable: manifest.contenu[0].item_ref == manifest.contenu[0].catalogue.code AND manifest.contenu[0].item_ref == manifest.contenu[0].catalogue.master_id,
        preuve: manifest.contenu[0].commercial_proof.proof_reference
    } == {
        valide: true,
        refs: ["BA13"],
        item: { libelle: "Plaque BA13", unite_reference: "PCE", unite_conditionnement: "base_unite:PCE", nature_reference: "COMMERCIALE", q: 1.0 },
        code_stable: true,
        preuve: "CAT-PLACO-2026"
    };

-- test: le contenu figé est celui que construit fn::ingestion_manifest_content
-- en tant que: steward
RETURN fn::ingestion_manifest_content({ batch_id: "lot_sec" }).data.map(|$e| [$e.item_ref, $e.catalogue.libelle])
    == (SELECT VALUE contenu FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-SEC" LIMIT 1).map(|$e| [$e.item_ref, $e.catalogue.libelle]);

-- test: la fonction n'enregistre qu'un manifeste brouillon ou scellé
-- en tant que: steward
RETURN fn::ingestion_manifest_save({ manifest_ref: "MAN-PIRATE", batch_id: "lot_sec", manifest_version: 2, statut: "APPROVED" }).error.code == "INGESTION_INVALID_PARAMETERS";

-- test: un manifeste n'est jamais créé déjà approuvé par écriture directe
-- en tant que: steward
-- attendu-erreur: INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION
CREATE ingestion_publication_manifest CONTENT { batch: ingestion_batch:lot_sec, manifest_ref: "MAN-PIRATE", manifest_version: 2, seal_hash: crypto::blake3("MAN-PIRATE"), is_sealed: true, statut: "APPROVED", approved_by: "auth_identity:steward" };

-- test: un rôle d'approbateur passé en paramètre ne donne aucun droit
-- en tant que: sync
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-SEC", justification: "Approbation par usurpation", approver_role: "steward_admin", approved_by: "pirate" }).error.code == "INGESTION_UNAUTHORIZED_APPROVER";

-- test: l'agent de synchronisation n'approuve pas en écrivant les champs lui-même
-- en tant que: sync
-- attendu-erreur: INGESTION_MANIFEST_APPROVAL_REQUIRES_STEWARD
UPDATE ingestion_publication_manifest SET statut = "APPROVED", approved_by = "auth_identity:steward" WHERE manifest_ref = "MAN-SEC";

-- test: le steward n'approuve pas au nom d'un autre opérateur (approbateur = opérateur de la session)
-- en tant que: steward
-- attendu-erreur: INGESTION_MANIFEST_APPROVAL_REQUIRES_STEWARD
UPDATE ingestion_publication_manifest SET statut = "APPROVED", approved_by = "auth_identity:autre" WHERE manifest_ref = "MAN-SEC";

-- test: une justification trop courte est refusée
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-SEC", justification: "court" }).error.code == "INGESTION_JUSTIFICATION_TOO_SHORT";

-- test: le steward approuve ; son identité et sa justification sont enregistrées
-- en tant que: steward
RETURN fn::ingestion_manifest_approve({ manifest_ref: "MAN-SEC", justification: "Lot contrôlé et conforme au bordereau" }).ok;

-- test: approbation du manifeste au nom du steward de la session
RETURN (SELECT VALUE [statut, approved_by, array::last(transitions).reason] FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-SEC" LIMIT 1) == ["APPROVED", "auth_identity:steward", "Lot contrôlé et conforme au bordereau"];

-- test: l'approbation publie ingestion.manifest.approved dans l'outbox
RETURN (SELECT VALUE payload.manifest_ref FROM event_outbox WHERE event_type = "ingestion.manifest.approved") == ["MAN-SEC"];

-- test: le steward n'exécute pas la publication
-- en tant que: steward
RETURN fn::ingestion_manifest_record_exec({ manifest_ref: "MAN-SEC", statut: "COMMITTED", items_committed: 1, items_failed: 0 }).error.code == "INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED";

-- test: le steward ne passe pas un manifeste en exécution par écriture directe
-- en tant que: steward
-- attendu-erreur: INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED
UPDATE ingestion_publication_manifest SET statut = "EXECUTING" WHERE manifest_ref = "MAN-SEC";

-- test: l'agent de synchronisation enregistre l'exécution (APPROVED → EXECUTING → COMMITTED)
-- en tant que: sync
RETURN fn::ingestion_manifest_record_exec({ manifest_ref: "MAN-SEC", statut: "COMMITTED", items_committed: 1, items_failed: 0 }).ok;

-- test: transitions du manifeste journalisées au nom des identités de session
RETURN (SELECT VALUE transitions.map(|$t| [$t.from_state, $t.to_state, $t.triggered_by]) FROM ONLY ingestion_publication_manifest WHERE manifest_ref = "MAN-SEC" LIMIT 1) == [[NONE, "SEALED", "auth_identity:steward"], ["SEALED", "APPROVED", "auth_identity:steward"], ["APPROVED", "EXECUTING", "auth_application:catalogue_sync"], ["EXECUTING", "COMMITTED", "auth_application:catalogue_sync"]];

-- test: un manifeste exécuté ne reçoit pas de second compte rendu
-- en tant que: sync
RETURN fn::ingestion_manifest_record_exec({ manifest_ref: "MAN-SEC", statut: "COMMITTED", items_committed: 1, items_failed: 0 }).error.code == "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION";

-- test: le passage à COMMITTED émet ingestion.manifest.published une seule fois
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "ingestion.manifest.published")
    == [{ manifest_ref: "MAN-SEC", batch_id: "ingestion_batch:lot_sec", items_committed: 1, items_failed: 0, publisher_agent: "auth_application:catalogue_sync" }];

-- test: l'agent de qualification consigne une anomalie en quarantaine
-- en tant que: qualif
RETURN fn::ingestion_quarantine_log({ claim: { owner: "banc", generation: 1 }, batch_id: "lot_sec", ligne_numero: 2, code_erreur: "INGESTION_QUALIFICATION_REJECTED", severite: "ERROR", champ_concerne: "gtin", valeur_fautive: "123", cause_detaillee: "Clé GS1 invalide" }).ok;

-- préparation: identifiant de l'anomalie
CREATE test_ref:quarantaine SET id_q = <string> (SELECT VALUE id FROM ONLY ingestion_quarantine_record LIMIT 1);

-- test: l'agent de qualification ne résout pas une quarantaine
-- en tant que: qualif
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:quarantaine.id_q, comment: "Résolution illégitime", _session_auth: { role: "steward_admin", user_id: "pirate" } }).error.code == "INGESTION_UNAUTHORIZED_APPROVER";

-- test: le lot publié est verrouillé : le steward ne corrige plus son article par la quarantaine
-- en tant que: steward
RETURN fn::ingestion_quarantine_resolve({ quarantine_id: test_ref:quarantaine.id_q, comment: "GTIN corrigé d'après la fiche fabricant", staged_item_id: test_ref:items.a2 }).error.{ code, ref: details.manifest_ref }
    == { code: "INGESTION_STAGED_ITEM_SEALED", ref: "MAN-SEC" };

-- test: ni par requalification
-- en tant que: steward
RETURN fn::ingestion_staged_requalify({ item_id: test_ref:items.a2, new_qualification: "TO_CONFIRM", justification: "Correction après publication" }).error.code == "INGESTION_STAGED_ITEM_SEALED";

-- test: ni par écriture directe
-- en tant que: qualif
-- attendu-erreur: INGESTION_STAGED_ITEM_SEALED
UPDATE <record> test_ref:items.a2 SET libelle_commercial = "Libellé corrigé";

-- test: anomalie non résolue et article inchangé
RETURN (SELECT VALUE is_resolved FROM ONLY <record> test_ref:quarantaine.id_q) == false
    AND (SELECT VALUE libelle_commercial FROM ONLY <record> test_ref:items.a2) != "Libellé corrigé";

-- test: opérateur d'une session interactive : son identité
-- en tant que: steward
RETURN fn::ingestion_operator({}) == "auth_identity:steward";

-- test: opérateur d'un compte de service : son application
-- en tant que: sync
RETURN fn::ingestion_operator({}) == "auth_application:catalogue_sync";

-- test: opérateur de la session système de l'hôte
RETURN fn::ingestion_operator({}) == "system";
