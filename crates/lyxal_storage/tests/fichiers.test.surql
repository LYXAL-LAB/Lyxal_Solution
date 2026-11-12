-- lyxal-test: assertions
-- Fichiers : écriture en deux temps (begin, commit), lecture, liste, adresse occupée, taille,
-- type et quota refusés, suppression, quarantaine, expiration, purge, transitions d'état,
-- événements.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["storage.object.read", "storage.object.write", "storage.bucket.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["storage.object.read"] }
-- identité redacteur: { "id": "auth_session:redacteur", "pv": 1, "permissions": ["storage.object.read", "storage.object.write"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["storage.object.read", "storage.object.write", "storage.bucket.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["storage.installation.manage"] }
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
    CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@lyxal.test" } };
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: bucket de l'organisation (1000 octets par fichier, PDF et PNG)
fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "plans", max_object_size: 1000, allowed_types: ["application/pdf", "image/png"] });

-- test: ouverture d'une écriture : fiche en attente, propriétaire, délai
-- en tant que: redacteur
{
    LET $o = fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "2026/plan-a.pdf", filename: "Plan A.pdf", declared_type: "application/pdf", declared_size: 400 }).data;
    RETURN $o.{ key, tenant, scope_key, owner, filename, state, declared_size, size, blake3, slot } == { key: "2026/plan-a.pdf", tenant: auth_organization:alpha, scope_key: "alpha", owner: auth_identity:redacteur, filename: "Plan A.pdf", state: "pending", declared_size: 400, size: NONE, blake3: NONE, slot: "2026/plan-a.pdf" }
        AND $o.pending_expires_at > time::now() + 23h
        AND $o.{ max_size, backend } == { max_size: 1000, backend: "default" }
        AND $o.path == string::concat("alpha/", <string> record::id($o.bucket), "/", <string> record::id($o.id));
};

-- test: un fichier en attente n'est pas servi
-- en tant que: lecteur
RETURN fn::storage_object_open({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "2026/plan-a.pdf" }).error.{ code, state: details.state } == { code: "STORAGE_OBJECT_NOT_AVAILABLE", state: "pending" };

-- test: adresse déjà occupée, même par une écriture en attente
-- en tant que: redacteur
RETURN fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "2026/plan-a.pdf", filename: "x.pdf" }).error.code == "STORAGE_OBJECT_EXISTS";

-- test: paramètres invalides : clé, nom, type, taille
-- en tant que: redacteur
RETURN fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "../etc/passwd", filename: "x" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "a b.pdf", filename: "x" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "a.pdf" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "a.pdf", filename: "x", declared_type: "pdf" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "a.pdf", filename: "x", declared_size: -1 }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_object_begin({ bucket: "storage_bucket:inconnu", key: "a.pdf", filename: "x" }).error.code == "STORAGE_BUCKET_NOT_FOUND";

-- test: taille et type annoncés refusés par le bucket
-- en tant que: redacteur
RETURN fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "gros.pdf", filename: "gros.pdf", declared_size: 1001 }).error.{ code, max: details.max_object_size } == { code: "STORAGE_OBJECT_TOO_LARGE", max: 1000 }
    AND fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "tableur.xlsx", filename: "t.xlsx", declared_type: "application/zip" }).error.code == "STORAGE_OBJECT_TYPE_REFUSED";

-- test: programme exécutable annoncé : refusé par les réglages, quel que soit le bucket
-- en tant que: redacteur
RETURN fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "outil.exe", filename: "outil.exe", declared_type: "application/x-msdownload" }).error.{ code, blocked: details.blocked } == { code: "STORAGE_OBJECT_TYPE_REFUSED", blocked: true };

-- test: un fichier en attente n'apparaît pas dans la liste par défaut
-- en tant que: lecteur
RETURN fn::storage_object_list({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1) }).data == { items: [], total: 0 }
    AND fn::storage_object_list({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), state: "pending" }).data.items.key == ["2026/plan-a.pdf"];

-- test: fin d'écriture refusée : empreinte invalide, taille ou type réels hors règles
-- en tant que: redacteur
{
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_object_commit({ object: <string> $o, size: 400, content_type: "application/pdf", blake3: "abc" }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_object_commit({ object: <string> $o, size: 400, content_type: "application/pdf" }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_object_commit({ object: <string> $o, size: 2000, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_OBJECT_TOO_LARGE"
        AND fn::storage_object_commit({ object: <string> $o, size: 400, content_type: "application/zip", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_OBJECT_TYPE_REFUSED"
        AND fn::storage_object_commit({ object: "storage_object:inconnu", size: 1, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND (SELECT VALUE state FROM ONLY $o) == "pending";
};

-- test: fin d'écriture par l'identité qui l'a ouverte : taille, type réel, empreinte, disponible
-- en tant que: redacteur
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1), size: 420, content_type: "application/pdf", blake3: "AF1349B9F5F9A1A6A0404DEA36DCC9499BCB25C9ADC112B7CC9A93CAE41F3262" }).data.{ state, size, content_type, blake3, pending_expires_at }
    == { state: "available", size: 420, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", pending_expires_at: NONE };

-- test: un fichier disponible ne se termine pas une seconde fois
-- en tant que: redacteur
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1), size: 420, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.{ code, state: details.state } == { code: "STORAGE_OBJECT_STATE_INVALID", state: "available" };

-- test: lecture par identifiant et par adresse ; liste par préfixe ; volume
-- en tant que: lecteur
{
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_object_get({ object: <string> $o }).data.key == "2026/plan-a.pdf"
        AND fn::storage_object_get({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "2026/plan-a.pdf" }).data.id == $o
        AND fn::storage_object_get({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "absent.pdf" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_get({ key: "2026/plan-a.pdf" }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_object_list({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), prefix: "2026" }).data.items.key == ["2026/plan-a.pdf"]
        AND fn::storage_object_list({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), prefix: "2025" }).data.total == 0
        AND fn::storage_object_usage({ tenant: "auth_organization:alpha" }).data == { objects: 1, bytes: 420, reserved_bytes: 0, quota_bytes: NONE }
        AND fn::storage_bucket_get({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1) }).data.usage == { objects: 1, bytes: 420 };
};

-- test: un fichier disponible est servi, par identifiant et par adresse ; refus hors droit de lecture ou sans adresse
-- en tant que: lecteur
{
    LET $b = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    LET $o = fn::storage_object_open({ bucket: <string> $b, key: "2026/plan-a.pdf" }).data;
    RETURN $o.{ state, backend } == { state: "available", backend: "default" }
        AND $o.path == string::concat("alpha/", <string> record::id($b), "/", <string> record::id($o.id))
        AND fn::storage_object_open({ object: <string> $o.id }).data.id == $o.id
        AND fn::storage_object_open({ object: "storage_object:inconnu" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_open({}).error.code == "STORAGE_INVALID_PARAMETERS";
};

-- test: une autre organisation ne se fait pas servir ce fichier
-- en tant que: autre
RETURN fn::storage_object_open({ object: <string> (SELECT VALUE id FROM ONLY storage_object LIMIT 1) ?? "storage_object:x" }).error.code == "STORAGE_OBJECT_NOT_FOUND";

-- test: événement storage.object.created publié, sans contenu
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "storage.object.created").{ key, tenant, size, content_type } == [{ key: "2026/plan-a.pdf", tenant: "auth_organization:alpha", size: 420, content_type: "application/pdf" }];

-- préparation: quota de l'organisation
fn::storage_settings_set({ tenant: "auth_organization:alpha", quota_bytes: 1000 });

-- test: quota : l'écriture annoncée compte, le dépassement est refusé à l'ouverture et à la fin
-- en tant que: redacteur
{
    LET $b = <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    LET $second = fn::storage_object_begin({ bucket: $b, key: "b.png", filename: "b.png", declared_type: "image/png", declared_size: 500 }).data;
    RETURN fn::storage_object_usage({ tenant: "auth_organization:alpha" }).data == { objects: 1, bytes: 420, reserved_bytes: 500, quota_bytes: 1000 }
        AND fn::storage_object_begin({ bucket: $b, key: "c.png", filename: "c.png", declared_size: 100 }).error.{ code, used: details.used_bytes } == { code: "STORAGE_QUOTA_EXCEEDED", used: 920 }
        AND fn::storage_object_commit({ object: <string> $second.id, size: 600, content_type: "image/png", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_QUOTA_EXCEEDED"
        AND fn::storage_object_commit({ object: <string> $second.id, size: 500, content_type: "image/png", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).data.state == "available"
        AND fn::storage_object_limits({ bucket: (SELECT * FROM ONLY (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1)), size: 81 }).code == "STORAGE_QUOTA_EXCEEDED"
        AND fn::storage_object_limits({ bucket: (SELECT * FROM ONLY (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1)), size: 80, content_type: "image/png" }) == NONE
        AND fn::storage_scope_usage({ tenant: auth_organization:alpha }) == { objects: 2, bytes: 920, reserved: 0 };
};

-- test: seule l'identité qui a ouvert l'écriture la termine
-- en tant que: admin
{
    LET $b = <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    fn::storage_object_begin({ bucket: $b, key: "admin.png", filename: "admin.png", declared_size: 10 });
    RETURN true;
};

-- test: un autre rédacteur ne termine pas l'écriture de l'administrateur ; le worker oui
-- en tant que: redacteur
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "admin.png" AND state != "deleted" LIMIT 1), size: 10, content_type: "image/png", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: le worker termine une écriture de toute portée
-- en tant que: worker
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "admin.png" AND state != "deleted" LIMIT 1), size: 10, content_type: "image/png", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).data.state == "available";

-- test: quarantaine réservée au worker ; un fichier en quarantaine reste compté, n'est plus listé
-- en tant que: admin
RETURN fn::storage_object_quarantine({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "admin.png" AND state != "deleted" LIMIT 1), reason: "virus" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: mise en quarantaine par le worker
-- en tant que: worker
{
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "admin.png" AND state != "deleted" LIMIT 1);
    RETURN fn::storage_object_quarantine({ object: <string> $o, reason: "Eicar-Test-Signature" }).data.{ state, quarantine_reason } == { state: "quarantined", quarantine_reason: "Eicar-Test-Signature" }
        AND fn::storage_object_quarantine({ object: <string> $o, reason: "encore" }).error.code == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_quarantine({ object: <string> $o }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_object_quarantine({ object: "storage_object:inconnu", reason: "x" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_list({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1) }).data.items.key == ["2026/plan-a.pdf", "b.png"]
        AND fn::storage_object_usage({ tenant: "auth_organization:alpha" }).data.{ objects, bytes } == { objects: 3, bytes: 930 };
};

-- préparation: une table d'un module consommateur référence un fichier
{
    DEFINE TABLE devis SCHEMAFULL PERMISSIONS FULL;
    DEFINE FIELD piece ON TABLE devis TYPE record<storage_object> REFERENCE ON DELETE REJECT;
    CREATE devis:1 CONTENT { piece: (SELECT VALUE id FROM ONLY storage_object WHERE key = "b.png" AND state != "deleted" LIMIT 1) };
};

-- test: un fichier référencé ne se supprime pas
-- en tant que: redacteur
RETURN fn::storage_object_delete({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "b.png" AND state != "deleted" LIMIT 1) }).error.{ code, references: details.references } == { code: "STORAGE_OBJECT_IN_USE", references: 1 };

-- préparation: la référence est retirée
DELETE devis:1;

-- test: suppression : état, adresse libérée, conservation de 7 jours, seconde suppression refusée
-- en tant que: redacteur
{
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "b.png" AND state != "deleted" LIMIT 1);
    LET $d = fn::storage_object_delete({ object: <string> $o }).data;
    RETURN $d.state == "deleted" AND $d.slot == <string> $o AND $d.purge_after > time::now() + 6d AND $d.purge_after < time::now() + 8d
        AND fn::storage_object_delete({ object: <string> $o }).error.code == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_delete({ object: "storage_object:inconnu" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_get({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "b.png" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_get({ object: <string> $o }).data.state == "deleted"
        AND fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), key: "b.png", filename: "b.png", declared_size: 1 }).data.state == "pending";
};

-- test: événements de quarantaine et de suppression publiés ; une écriture abandonnée n'en publie pas
RETURN (SELECT VALUE payload.key FROM event_outbox WHERE event_type = "storage.object.quarantined") == ["admin.png"]
    AND (SELECT VALUE payload.key FROM event_outbox WHERE event_type = "storage.object.deleted") == ["b.png"]
    AND array::len(SELECT VALUE id FROM event_outbox WHERE event_type = "storage.object.created") == 3;

-- test: bucket en lecture seule : ni écriture ni suppression
-- en tant que: admin
{
    LET $b = <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    fn::storage_bucket_update({ bucket: $b, readonly: true });
    LET $refused = fn::storage_object_begin({ bucket: $b, key: "z.pdf", filename: "z.pdf" }).error.code == "STORAGE_BUCKET_READONLY"
        AND fn::storage_object_delete({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1) }).error.code == "STORAGE_BUCKET_READONLY";
    fn::storage_bucket_update({ bucket: $b, readonly: false });
    RETURN $refused;
};

-- test: transitions interdites refusées par la base, même en écriture directe
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
UPDATE storage_object SET state = "pending" WHERE key = "2026/plan-a.pdf";

-- test: une fiche ne se crée pas directement dans un autre état que pending
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
CREATE storage_object CONTENT { bucket: (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), tenant: auth_organization:alpha, key: "direct.pdf", filename: "d.pdf", backend: "default", state: "available" };

-- test: ni sur un autre support que celui de son bucket
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
CREATE storage_object CONTENT { bucket: (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1), tenant: auth_organization:alpha, key: "direct.pdf", filename: "d.pdf", backend: "ailleurs" };

-- préparation: le délai de l'écriture en attente est passé ; le fichier supprimé a fini sa conservation
{
    UPDATE storage_object SET pending_expires_at = time::now() - 1m WHERE key = "b.png" AND state = "pending";
    UPDATE storage_object SET purge_after = time::now() - 1m WHERE key = "b.png" AND state = "deleted";
};

-- test: une écriture hors délai ne se termine plus
-- en tant que: redacteur
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "b.png" AND state != "deleted" LIMIT 1), size: 1, content_type: "image/png", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_OBJECT_STATE_INVALID";

-- test: expiration et purge réservées au worker
-- en tant que: admin
RETURN fn::storage_object_expire({}).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_object_purge_list({}).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_object_purge({ object: "storage_object:x" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: le worker abandonne les écritures hors délai, liste les fichiers à purger et retire leur fiche
-- en tant que: worker
{
    LET $expired = fn::storage_object_expire({ limit: 10 }).data;
    LET $list = fn::storage_object_purge_list({ limit: 10 }).data.items;
    LET $second = fn::storage_object_purge_list({ limit: 10, start: 1 }).data.items;
    LET $available = (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1);
    LET $purged = array::map($list, |$o| fn::storage_object_purge({ object: <string> $o.id }).data.purged);
    RETURN $expired == { expired: 1 }
        AND fn::storage_object_expire({}).data == { expired: 0 }
        AND array::len($list) == 2
        AND $second.id == [$list[1].id]
        AND array::all($list, |$o| $o.backend == "default" AND $o.path == string::concat("alpha/", <string> record::id((SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1)), "/", <string> record::id($o.id)))
        AND $purged == [true, true]
        AND fn::storage_object_purge_list({}).data.items == []
        AND fn::storage_object_purge({ object: <string> $available }).error.code == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_purge({ object: "storage_object:inconnu" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_expire({ limit: 0 }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_object_purge_list({ limit: 0 }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_object_purge_list({ start: -1 }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND array::len(SELECT VALUE id FROM storage_object WHERE key = "b.png") == 0;
};

-- test: un fichier supprimé dont la conservation n'est pas écoulée n'est pas purgé
-- en tant que: worker
{
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "2026/plan-a.pdf" AND state != "deleted" LIMIT 1);
    fn::storage_object_delete({ object: <string> $o });
    RETURN fn::storage_object_purge({ object: <string> $o }).error.code == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_purge_list({}).data.items == [];
};
