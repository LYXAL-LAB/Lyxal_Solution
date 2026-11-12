-- lyxal-test: assertions
-- Envois reprenables : ouverture, parties, position, refus (mauvaise position, dépassement,
-- autre appelant, écriture directe), réservation de l'assemblage, fin, abandon, expiration,
-- retrait des parties et inscription de leur dossier à retirer, liste du worker, réglage du délai.
--
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["storage.object.read", "storage.object.write", "storage.bucket.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["storage.object.read"] }
-- identité redacteur: { "id": "auth_session:redacteur", "pv": 1, "permissions": ["storage.object.read", "storage.object.write"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["storage.object.read", "storage.object.write", "storage.bucket.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["storage.installation.manage"] }
-- identité second: { "id": "auth_session:second", "pv": 1, "permissions": ["storage.object.read", "storage.object.write"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["storage.worker"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@lyxal.test" } };
    RELATE auth_identity:admin->auth_member_of->auth_organization:alpha;
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:lecteur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lecteur@lyxal.test" } };
    RELATE auth_identity:lecteur->auth_member_of->auth_organization:alpha;
    CREATE auth_session:lecteur CONTENT { identity: auth_identity:lecteur, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:redacteur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "redacteur@lyxal.test" } };
    RELATE auth_identity:redacteur->auth_member_of->auth_organization:alpha;
    CREATE auth_session:redacteur CONTENT { identity: auth_identity:redacteur, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@lyxal.test" } };
    RELATE auth_identity:membre->auth_member_of->auth_organization:alpha;
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:second CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "second@lyxal.test" } };
    RELATE auth_identity:second->auth_member_of->auth_organization:alpha;
    CREATE auth_session:second CONTENT { identity: auth_identity:second, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@lyxal.test" } };
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: bucket de l'organisation (1000 octets par fichier)
fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "videos", max_object_size: 1000 });

-- test: un envoi reprenable annonce sa taille
-- en tant que: redacteur
RETURN fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "a.bin", filename: "a.bin", resumable: true }).error.{ code, fields: details.fields } == { code: "STORAGE_INVALID_PARAMETERS", fields: { declared_size: ["required"] } };

-- test: ouverture d'un envoi reprenable : fiche en attente, délai de 24 h, position 0
-- en tant que: redacteur
{
    LET $o = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "a.bin", filename: "a.bin", declared_size: 300, resumable: true }).data;
    LET $u = fn::storage_upload_get({ object: <string> $o.id }).data;
    RETURN $o.resumable AND $o.state == "pending" AND $o.pending_expires_at > time::now() + 23h
        AND $u.{ id, state, length, offset, complete, max_size, backend, path } == { id: $o.id, state: "pending", length: 300, offset: 0, complete: false, max_size: 1000, backend: "default", path: $o.path }
        AND $u.expires_at == $o.pending_expires_at;
};

-- test: parties inscrites à la suite : la position avance
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    LET $a = fn::storage_upload_part_add({ object: $o, offset: 0, size: 100, name: rand::uuid::v7() });
    LET $b = fn::storage_upload_part_add({ object: $o, offset: 100, size: 100, name: rand::uuid::v7() });
    RETURN $a.data.{ offset, complete } == { offset: 100, complete: false } AND $b.data.{ offset, complete } == { offset: 200, complete: false }
        AND fn::storage_upload_get({ object: $o }).data.offset == 200;
};

-- test: fonctions internes : position, réservation, droit de poursuivre, état, garde d'une partie
-- en tant que: redacteur
{
    LET $o = (SELECT * FROM ONLY (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1));
    RETURN fn::storage_upload_offset($o.id, NONE) == 200
        AND fn::storage_upload_offset($o.id, (SELECT VALUE id FROM ONLY storage_upload_part WHERE object = $o.id AND offset = 100 LIMIT 1)) == 100
        AND fn::storage_upload_claimed($o) == false
        AND fn::storage_upload_claimed(object::extend($o, { upload_claimed_until: time::now() + 1m })) == true
        AND fn::storage_upload_allowed($o) == true
        AND fn::storage_upload_view($o).{ offset, length, complete } == { offset: 200, length: 300, complete: false }
        AND fn::storage_upload_part_refusal({ id: NONE, object: $o.id, offset: 200, size: 100 }) IS NONE
        AND fn::storage_upload_part_refusal({ id: NONE, object: $o.id, offset: 100, size: 100 }).code == "STORAGE_UPLOAD_OFFSET_MISMATCH";
};

-- test: fonctions internes : un autre rédacteur ne peut pas poursuivre l'envoi
-- en tant que: second
RETURN fn::storage_upload_allowed((SELECT * FROM ONLY (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1))) == false;

-- test: mauvaise position refusée, la position courante est rendue
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_upload_part_add({ object: $o, offset: 0, size: 50, name: rand::uuid::v7() }).error.{ code, offset: details.offset } == { code: "STORAGE_UPLOAD_OFFSET_MISMATCH", offset: 200 }
        AND fn::storage_upload_part_add({ object: $o, offset: 250, size: 50, name: rand::uuid::v7() }).error.{ code, offset: details.offset } == { code: "STORAGE_UPLOAD_OFFSET_MISMATCH", offset: 200 };
};

-- test: dépassement de la taille annoncée et paramètres invalides refusés
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_upload_part_add({ object: $o, offset: 200, size: 101, name: rand::uuid::v7() }).error.code == "STORAGE_CONTENT_MISMATCH"
        AND fn::storage_upload_part_add({ object: $o, offset: 200, size: 0, name: rand::uuid::v7() }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_upload_part_add({ object: $o, offset: 200, size: 10, name: "partie" }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_upload_get({ object: "storage_object:absent" }).error.code == "STORAGE_OBJECT_NOT_FOUND";
};

-- test: un autre rédacteur de l'organisation ne poursuit pas l'envoi d'autrui
-- en tant que: second
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_upload_get({ object: $o }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_upload_part_add({ object: $o, offset: 200, size: 10, name: rand::uuid::v7() }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_upload_part_list({ object: $o }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_upload_claim({ object: $o }).error.code == "STORAGE_PERMISSION_DENIED";
};

-- test: ni un lecteur
-- en tant que: lecteur
RETURN fn::storage_upload_get({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1) }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: écriture directe d'une partie par un autre rédacteur refusée
-- en tant que: second
-- attendu-erreur: STORAGE_PERMISSION_DENIED
CREATE storage_upload_part CONTENT { object: (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1), offset: 200, size: 10, name: rand::uuid::v7() };

-- test: écriture directe à une mauvaise position refusée, même par l'auteur
-- en tant que: redacteur
-- attendu-erreur: STORAGE_UPLOAD_OFFSET_MISMATCH
CREATE storage_upload_part CONTENT { object: (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1), offset: 250, size: 10, name: rand::uuid::v7() };

-- test: une partie inscrite ne se modifie pas et ne se retire pas directement
-- en tant que: redacteur
{
    LET $changed = (UPDATE storage_upload_part SET size = 1);
    LET $removed = (DELETE storage_upload_part RETURN BEFORE);
    RETURN array::len($changed) == 0 AND array::len($removed) == 0
        AND fn::storage_upload_get({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1) }).data.offset == 200;
};

-- test: un envoi incomplet ne se réserve pas et ne se termine pas
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_upload_claim({ object: $o }).error.{ code, offset: details.offset } == { code: "STORAGE_UPLOAD_OFFSET_MISMATCH", offset: 200 }
        AND fn::storage_object_commit({ object: $o, size: 200, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_commit({ object: $o, size: 300, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_OBJECT_STATE_INVALID";
};

-- test: un envoi incomplet ne se termine pas non plus par écriture directe
-- en tant que: redacteur
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
UPDATE (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1) SET state = "available", size = 300, content_type = "application/pdf", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262";

-- test: aucun envoi complet à assembler pour le worker
-- en tant que: worker
RETURN fn::storage_upload_ready_list({}).data.items == [];

-- test: la liste des envois complets est réservée au worker
-- en tant que: redacteur
RETURN fn::storage_upload_ready_list({}).error.code == "STORAGE_PERMISSION_DENIED";

-- test: dernière partie : envoi complet, parties rendues dans l'ordre
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    LET $last = fn::storage_upload_part_add({ object: $o, offset: 200, size: 100, name: rand::uuid::v7() });
    LET $parts = fn::storage_upload_part_list({ object: $o }).data.items;
    RETURN $last.data.{ offset, complete } == { offset: 300, complete: true }
        AND $parts.offset == [0, 100, 200] AND $parts.size == [100, 100, 100] AND array::all($parts.name, |$n| type::is_uuid($n));
};

-- test: le worker voit l'envoi complet
-- en tant que: worker
RETURN fn::storage_upload_ready_list({}).data.items == [(SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1)];

-- test: réservation de l'assemblage : un seul assembleur, plus aucune partie
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    LET $claimed = fn::storage_upload_claim({ object: $o, seconds: 600 });
    RETURN $claimed.data.{ offset, complete, length } == { offset: 300, complete: true, length: 300 }
        AND type::is_uuid($claimed.data.claim)
        -- Prolongation par le détenteur ; un autre jeton est refusé
        AND fn::storage_upload_claim({ object: $o, claim: $claimed.data.claim, seconds: 900 }).data.claim == $claimed.data.claim
        AND fn::storage_upload_claim({ object: $o, claim: rand::uuid::v7() }).error.code == "STORAGE_UPLOAD_BUSY"
        AND fn::storage_upload_release({ object: $o, claim: rand::uuid::v7() }).error.code == "STORAGE_UPLOAD_BUSY"
        AND fn::storage_object_commit({ object: $o, size: 300, content_type: "application/octet-stream", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_UPLOAD_BUSY"
        AND fn::storage_object_commit({ object: $o, size: 300, content_type: "application/octet-stream", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", claim: rand::uuid::v7() }).error.code == "STORAGE_UPLOAD_BUSY"
        AND fn::storage_upload_claim({ object: $o }).error.code == "STORAGE_UPLOAD_BUSY"
        AND fn::storage_upload_part_add({ object: $o, offset: 300, size: 1, name: rand::uuid::v7() }).error.code == "STORAGE_UPLOAD_BUSY";
};

-- test: un envoi réservé n'est plus proposé au worker ; rendu, il l'est de nouveau
-- en tant que: worker
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    LET $hidden = fn::storage_upload_ready_list({}).data.items;
    LET $released = fn::storage_upload_release({ object: $o, claim: (SELECT VALUE upload_claim FROM ONLY <record> $o) });
    RETURN $hidden == [] AND $released.data == { released: true, abandoned: false } AND array::len(fn::storage_upload_ready_list({}).data.items) == 1
        AND fn::storage_upload_claim({ object: $o }).ok;
};

-- test: fin de l'envoi : fichier disponible, parties retirées, dossier des parties à retirer
-- en tant que: redacteur
{
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1);
    LET $done = fn::storage_object_commit({ object: <string> $o, size: 300, content_type: "application/octet-stream", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", claim: (SELECT VALUE upload_claim FROM ONLY $o) });
    LET $u = fn::storage_upload_get({ object: <string> $o }).data;
    RETURN $done.data.state == "available" AND $u.{ state, offset, complete } == { state: "available", offset: 300, complete: true }
        AND fn::storage_upload_part_list({ object: <string> $o }).data.items == [];
};

-- test: le dossier des parties de l'envoi terminé est inscrit pour le worker
{
    LET $o = (SELECT * FROM ONLY (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.bin" AND state != "deleted" LIMIT 1));
    RETURN (SELECT backend, prefix FROM storage_reclaim) == [{ backend: "default", prefix: string::concat($o.path, ".parts") }]
        AND array::len(SELECT * FROM storage_upload_part) == 0;
};

-- test: abandon d'un envoi : introuvable, parties retirées, dossier inscrit
-- en tant que: redacteur
{
    LET $o = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "b.bin", filename: "b.bin", declared_size: 50, resumable: true }).data.id;
    LET $part = fn::storage_upload_part_add({ object: <string> $o, offset: 0, size: 20, name: rand::uuid::v7() });
    LET $deleted = fn::storage_object_delete({ object: <string> $o });
    RETURN $part.ok AND $deleted.data.state == "deleted"
        AND fn::storage_upload_get({ object: <string> $o }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_upload_part_add({ object: <string> $o, offset: 20, size: 20, name: rand::uuid::v7() }).error.code == "STORAGE_OBJECT_STATE_INVALID";
};

-- test: deux dossiers de parties à retirer, aucune partie restante
RETURN array::len(SELECT * FROM storage_reclaim) == 2 AND array::len(SELECT * FROM storage_upload_part) == 0;

-- test: un nouvel envoi en cours
-- en tant que: redacteur
{
    LET $o = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "c.bin", filename: "c.bin", declared_size: 50, resumable: true }).data.id;
    RETURN fn::storage_upload_part_add({ object: <string> $o, offset: 0, size: 20, name: rand::uuid::v7() }).ok;
};

-- préparation: son délai est passé
UPDATE (SELECT VALUE id FROM ONLY storage_object WHERE key = "c.bin" AND state != "deleted" LIMIT 1) SET pending_expires_at = time::now() - 1m;

-- test: envoi hors délai refusé
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "c.bin" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_upload_get({ object: $o }).error.code == "STORAGE_UPLOAD_EXPIRED"
        AND fn::storage_upload_part_add({ object: $o, offset: 20, size: 30, name: rand::uuid::v7() }).error.code == "STORAGE_UPLOAD_EXPIRED";
};

-- test: le worker abandonne l'envoi hors délai : parties retirées, dossier inscrit
-- en tant que: worker
RETURN fn::storage_object_expire({}).data.expired == 1;

-- test: trois dossiers de parties à retirer
RETURN array::len(SELECT * FROM storage_reclaim) == 3 AND array::len(SELECT * FROM storage_upload_part) == 0;

-- test: un envoi complet, réservé pour l'assemblage
-- en tant que: redacteur
{
    LET $o = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "d.bin", filename: "d.bin", declared_size: 10, resumable: true }).data.id;
    LET $part = fn::storage_upload_part_add({ object: <string> $o, offset: 0, size: 10, name: rand::uuid::v7() });
    RETURN $part.data.complete AND fn::storage_upload_claim({ object: <string> $o }).ok;
};

-- préparation: son délai passe pendant l'assemblage
UPDATE (SELECT VALUE id FROM ONLY storage_object WHERE key = "d.bin" AND state != "deleted" LIMIT 1) SET pending_expires_at = time::now() - 1m;

-- test: un envoi en cours d'assemblage n'est pas abandonné par le worker
-- en tant que: worker
RETURN fn::storage_object_expire({}).data.expired == 0;

-- test: et son assemblage se termine
-- en tant que: redacteur
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "d.bin" AND state != "deleted" LIMIT 1), size: 10, content_type: "application/octet-stream", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", claim: (SELECT VALUE upload_claim FROM ONLY (SELECT VALUE id FROM ONLY storage_object WHERE key = "d.bin" AND state != "deleted" LIMIT 1)) }).data.state == "available";

-- test: délai des envois reprenables réglable par organisation
-- en tant que: admin
{
    LET $set = fn::storage_settings_set({ tenant: "auth_organization:alpha", upload_ttl_seconds: 3600 });
    RETURN $set.data.upload_ttl_seconds == 3600
        AND fn::storage_settings_get({ tenant: "auth_organization:alpha" }).data.effective.upload_ttl_seconds == 3600
        AND fn::storage_settings_set({ tenant: "auth_organization:alpha", upload_ttl_seconds: 10 }).error.code == "STORAGE_INVALID_PARAMETERS";
};

-- test: le délai réglé s'applique aux envois reprenables, pas aux écritures simples
-- en tant que: redacteur
{
    LET $r = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "e.bin", filename: "e.bin", declared_size: 10, resumable: true }).data;
    LET $s = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "f.bin", filename: "f.bin", declared_size: 10 }).data;
    RETURN $r.pending_expires_at < time::now() + 2h AND $s.pending_expires_at > time::now() + 23h AND !$s.resumable
        AND fn::storage_upload_get({ object: <string> $s.id }).error.code == "STORAGE_OBJECT_NOT_FOUND";
};

-- test: contenu refusé à l'assemblage : le détenteur de la réservation abandonne l'envoi
-- en tant que: redacteur
{
    LET $o = <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "e.bin" AND state != "deleted" LIMIT 1);
    LET $part = fn::storage_upload_part_add({ object: $o, offset: 0, size: 10, name: rand::uuid::v7() });
    LET $claim = fn::storage_upload_claim({ object: $o }).data.claim;
    LET $abandoned = fn::storage_upload_release({ object: $o, claim: $claim, abandon: true });
    RETURN $part.data.complete AND $abandoned.data == { released: true, abandoned: true }
        AND fn::storage_upload_get({ object: $o }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_upload_release({ object: $o, claim: $claim }).error.code == "STORAGE_UPLOAD_BUSY";
};

-- test: un envoi complet ne se termine pas par écriture directe sans réservation
-- en tant que: redacteur
-- attendu-erreur: STORAGE_UPLOAD_BUSY
{
    LET $o = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "videos" LIMIT 1), key: "g.bin", filename: "g.bin", declared_size: 10, resumable: true }).data.id;
    fn::storage_upload_part_add({ object: <string> $o, offset: 0, size: 10, name: rand::uuid::v7() });
    UPDATE $o SET state = "available", size = 10, content_type = "application/octet-stream", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262";
};
