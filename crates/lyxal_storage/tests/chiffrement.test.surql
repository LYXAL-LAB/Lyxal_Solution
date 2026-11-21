-- lyxal-test: assertions
-- Buckets chiffrés : option fixée à la création, clé scellée exigée à la fin de l'écriture et
-- illisible des utilisateurs, taille stockée du flux chiffré, envoi reprenable refusé, clé
-- d'une fiche (session système, worker), rescellement après rotation. Compteurs de volume par
-- portée et par bucket : tenus à chaque écriture, quota contrôlé aussi en écriture directe,
-- contrôle de cohérence, aucune écriture directe, suppression avec l'organisation.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["storage.object.read", "storage.object.write", "storage.bucket.manage"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["storage.object.read", "storage.object.write", "storage.bucket.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["storage.worker"] }

-- préparation: organisations, identités et sessions lyxal_auth ; table de passage
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@lyxal.test" } };
    RELATE auth_identity:admin->auth_member_of->auth_organization:alpha;
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@lyxal.test" } };
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- test: bucket chiffré créé par l'administrateur ; option rendue, fixée à la création
-- en tant que: admin
{
    LET $b = fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "courrier", encrypted: true }).data;
    LET $clair = fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "plans" }).data;
    CREATE passe:ids SET chiffre = <string> $b.id, clair = <string> $clair.id;
    RETURN $b.encrypted == true AND $clair.encrypted == false
        AND fn::storage_bucket_update({ bucket: <string> $b.id, encrypted: false }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "autre", encrypted: "oui" }).error.code == "STORAGE_INVALID_PARAMETERS";
};

-- test: ouverture d'une écriture dans un bucket chiffré : encrypted rendu ; envoi reprenable refusé
-- en tant que: admin
{
    LET $bucket = (SELECT VALUE chiffre FROM ONLY passe:ids);
    LET $o = fn::storage_object_begin({ bucket: $bucket, key: "a/m1.eml", filename: "message.eml", declared_size: 100 }).data;
    UPSERT passe:objets SET m1 = <string> $o.id;
    RETURN $o.encrypted == true AND $o.state == "pending"
        AND fn::storage_object_begin({ bucket: $bucket, key: "a/m2.eml", filename: "message.eml", declared_size: 100, resumable: true }).error.{ code, fields: details.fields } == { code: "STORAGE_INVALID_PARAMETERS", fields: { resumable: ["encrypted_bucket"] } }
        AND fn::storage_object_begin({ bucket: (SELECT VALUE clair FROM ONLY passe:ids), key: "p.pdf", filename: "p.pdf" }).data.encrypted == false;
};

-- test: fin d'écriture : clé scellée exigée dans un bucket chiffré, refusée ailleurs
-- en tant que: admin
{
    LET $m1 = (SELECT VALUE m1 FROM ONLY passe:objets);
    LET $p = (SELECT VALUE id FROM ONLY storage_object WHERE key = "p.pdf" LIMIT 1);
    LET $hash = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262";
    RETURN fn::storage_object_commit({ object: $m1, size: 100, content_type: "message/rfc822", blake3: $hash }).error.details.fields == { content_key: ["required"] }
        AND fn::storage_object_commit({ object: <string> $p, size: 5, content_type: "application/pdf", blake3: $hash, content_key: "enc:v2:alpha-files-1:QUJD" }).error.details.fields == { content_key: ["not_allowed"] }
        AND fn::storage_object_commit({ object: $m1, size: 100, content_type: "message/rfc822", blake3: $hash, content_key: "pas-une-enveloppe" }).error.code == "STORAGE_INVALID_PARAMETERS";
};

-- test: la base exige aussi la clé scellée en écriture directe
-- en tant que: admin
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
UPDATE type::record((SELECT VALUE m1 FROM ONLY passe:objets)) SET state = "available", size = 100, content_type = "message/rfc822", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", pending_expires_at = NONE;

-- test: fin d'écriture chiffrée : clé rangée, identifiant de clé lisible, taille stockée du flux chiffré
-- en tant que: admin
{
    LET $done = fn::storage_object_commit({ object: (SELECT VALUE m1 FROM ONLY passe:objets), size: 100, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key: "enc:v2:alpha-files-1:QUJD" }).data;
    RETURN $done.{ state, size, stored_size, content_key_id, content_key } == { state: "available", size: 100, stored_size: 163, content_key_id: "alpha-files-1", content_key: NONE };
};

-- test: clé scellée illisible d'un utilisateur, même administrateur ; identifiant visible
-- en tant que: admin
{
    LET $m1 = type::record((SELECT VALUE m1 FROM ONLY passe:objets));
    RETURN (SELECT VALUE content_key FROM ONLY $m1) == NONE
        AND (SELECT VALUE content_key_id FROM ONLY $m1) == "alpha-files-1"
        AND array::len(SELECT VALUE id FROM storage_object WHERE content_key = "enc:v2:alpha-files-1:QUJD") == 0
        AND fn::storage_object_key_get({ object: <string> $m1 }).error.code == "STORAGE_PERMISSION_DENIED";
};

-- test: un utilisateur ne change pas la clé d'un fichier
-- en tant que: admin
-- attendu-erreur: STORAGE_PERMISSION_DENIED
UPDATE type::record((SELECT VALUE m1 FROM ONLY passe:objets)) SET content_key = "enc:v2:pirate:QUJD";

-- test: la clé scellée est servie à la session système et au worker
-- en tant que: worker
RETURN fn::storage_object_key_get({ object: (SELECT VALUE m1 FROM ONLY passe:objets) }).data.{ tenant, content_key } == { tenant: auth_organization:alpha, content_key: "enc:v2:alpha-files-1:QUJD" }
    AND fn::storage_object_key_get({ object: "storage_object:inconnu" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
    AND fn::storage_object_key_get({ object: "storage_bucket:x" }).error.code == "STORAGE_INVALID_PARAMETERS";

-- préparation: rotation de la clé « fichiers » : un second fichier scellé par l'ancienne clé, puis une écriture ouverte avant le retrait
{
    LET $bucket = type::record((SELECT VALUE chiffre FROM ONLY passe:ids));
    LET $m3 = (CREATE ONLY storage_object CONTENT { bucket: $bucket, tenant: auth_organization:alpha, key: "a/m3.eml", backend: "default", filename: "message.eml", declared_size: 10, state: "pending", pending_expires_at: time::now() + 1h });
    UPDATE $m3.id SET state = "available", size = 10, content_type = "message/rfc822", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key = "enc:v2:alpha-files-1:REVG", pending_expires_at = NONE;
    LET $m4 = (CREATE ONLY storage_object CONTENT { bucket: $bucket, tenant: auth_organization:alpha, key: "a/m4.eml", backend: "default", filename: "message.eml", declared_size: 10, state: "pending", pending_expires_at: time::now() + 1h });
    UPSERT passe:objets SET m3 = <string> $m3.id, m4 = <string> $m4.id, retired_at = time::now();
};

-- test: fiches à resceller pour une clé retirée, écriture en attente antérieure au retrait signalée
-- en tant que: worker
{
    LET $retired_at = (SELECT VALUE retired_at FROM ONLY passe:objets);
    LET $all = fn::storage_object_rekey_list({ key_id: "alpha-files-1", tenant: "auth_organization:alpha", retired_at: $retired_at }).data;
    LET $page = fn::storage_object_rekey_list({ key_id: "alpha-files-1", tenant: "auth_organization:alpha", retired_at: $retired_at, limit: 1, start: 1 }).data;
    RETURN array::len($all.items) == 2 AND $all.pending_writes == true
        AND $all.items[0].content_key IN ["enc:v2:alpha-files-1:QUJD", "enc:v2:alpha-files-1:REVG"]
        AND $all.items[0].tenant == auth_organization:alpha
        AND array::len($page.items) == 1 AND $page.items[0].id == $all.items[1].id
        AND fn::storage_object_rekey_list({ key_id: "alpha-files-1", tenant: "auth_organization:alpha", retired_at: time::now() - 1d }).data.pending_writes == false
        AND fn::storage_object_rekey_list({ key_id: "autre", tenant: "auth_organization:beta", retired_at: $retired_at }).data == { items: [], pending_writes: false };
};

-- test: rescellement conditionnel : clé attendue vérifiée, aucun octet réécrit
-- en tant que: worker
{
    LET $m1 = (SELECT VALUE m1 FROM ONLY passe:objets);
    LET $wrong = fn::storage_object_rekey({ object: $m1, expected_key_id: "inconnue", content_key: "enc:v2:alpha-files-2:WFla" });
    LET $ok = fn::storage_object_rekey({ object: $m1, expected_key_id: "alpha-files-1", content_key: "enc:v2:alpha-files-2:WFla" });
    LET $again = fn::storage_object_rekey({ object: $m1, expected_key_id: "alpha-files-1", content_key: "enc:v2:alpha-files-2:WFlb" });
    RETURN $wrong.error.{ code, current: details.content_key_id } == { code: "STORAGE_OBJECT_STATE_INVALID", current: "alpha-files-1" }
        AND $ok.data.content_key_id == "alpha-files-2" AND $again.error.code == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_rekey({ object: "storage_object:inconnu", expected_key_id: "alpha-files-1", content_key: "enc:v2:alpha-files-2:WFla" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
        AND fn::storage_object_rekey({ object: $m1, expected_key_id: "alpha-files-2", content_key: "clair" }).error.code == "STORAGE_INVALID_PARAMETERS";
};

-- test: après rescellement et fin des écritures en attente, la clé retirée ne sert plus
{
    fn::storage_object_rekey({ object: (SELECT VALUE m3 FROM ONLY passe:objets), expected_key_id: "alpha-files-1", content_key: "enc:v2:alpha-files-2:WFlc" });
    fn::storage_object_delete({ object: (SELECT VALUE m4 FROM ONLY passe:objets) });
    LET $list = fn::storage_object_rekey_list({ key_id: "alpha-files-1", tenant: "auth_organization:alpha", retired_at: (SELECT VALUE retired_at FROM ONLY passe:objets) }).data;
    RETURN $list == { items: [], pending_writes: false }
        AND (SELECT VALUE size FROM ONLY type::record((SELECT VALUE m3 FROM ONLY passe:objets))) == 10;
};

-- test: les opérations sur les clés de fichiers et le contrôle des compteurs sont réservés au worker
-- en tant que: admin
RETURN fn::storage_object_rekey_list({ key_id: "alpha-files-2", tenant: "auth_organization:alpha", retired_at: time::now() }).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_object_rekey({ object: (SELECT VALUE m1 FROM ONLY passe:objets), expected_key_id: "alpha-files-2", content_key: "enc:v2:pirate:QUJD" }).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_usage_verify({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: une fiche ne se crée pas avec une clé scellée ni en envoi reprenable dans un bucket chiffré
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
CREATE storage_object CONTENT { bucket: type::record((SELECT VALUE chiffre FROM ONLY passe:ids)), tenant: auth_organization:alpha, key: "a/m5.eml", backend: "default", filename: "m.eml", resumable: true, declared_size: 3, state: "pending", pending_expires_at: time::now() + 1h };

-- test: compteurs de la portée et des buckets tenus à chaque écriture
{
    LET $chiffre = type::record((SELECT VALUE chiffre FROM ONLY passe:ids));
    LET $clair = type::record((SELECT VALUE clair FROM ONLY passe:ids));
    RETURN (SELECT objects, bytes, reserved FROM ONLY storage_usage:["alpha"]) == { objects: 2, bytes: 110, reserved: 0 }
        AND (SELECT objects, bytes, reserved, bucket, tenant FROM ONLY type::record("storage_usage", ["alpha", record::id($chiffre)])) == { objects: 2, bytes: 110, reserved: 0, bucket: $chiffre, tenant: auth_organization:alpha }
        AND fn::storage_scope_usage({ tenant: auth_organization:alpha, bucket: $clair }) == { objects: 0, bytes: 0, reserved: 0 }
        AND fn::storage_object_usage({ tenant: "auth_organization:alpha" }).data == { objects: 2, bytes: 110, reserved_bytes: 0, quota_bytes: NONE }
        AND fn::storage_bucket_get({ bucket: <string> $chiffre }).data.usage == { objects: 2, bytes: 110 };
};

-- test: parts d'une fiche dans les compteurs (fonctions internes)
RETURN fn::storage_usage_share(NONE) == { objects: 0, bytes: 0, reserved: 0 }
    AND fn::storage_usage_share({ state: "available", size: 5 }) == { objects: 1, bytes: 5, reserved: 0 }
    AND fn::storage_usage_share({ state: "quarantined", size: 7 }) == { objects: 1, bytes: 7, reserved: 0 }
    AND fn::storage_usage_share({ state: "pending", declared_size: 9 }) == { objects: 0, bytes: 0, reserved: 9 }
    AND fn::storage_usage_share({ state: "deleted", size: 5 }) == { objects: 0, bytes: 0, reserved: 0 }
    AND fn::storage_usage_apply(NONE, NONE) == NONE
    AND fn::storage_usage_apply({ state: "deleted", size: 5 }, { state: "deleted", size: 5 }) == NONE;

-- test: compteurs cohérents avec les fiches
-- en tant que: worker
RETURN fn::storage_usage_verify({ tenant: "auth_organization:alpha" }).data.{ valid, checked, mismatches } == { valid: true, checked: 3, mismatches: [] }
    AND fn::storage_usage_verify({}).data.valid == true;

-- test: aucune écriture directe des compteurs par un utilisateur
-- en tant que: admin
RETURN (UPDATE storage_usage:["alpha"] SET bytes = 0) == []
    AND (CREATE storage_usage CONTENT { scope_key: "alpha", bytes: 1 }) == []
    AND (DELETE storage_usage:["alpha"] RETURN BEFORE) == []
    AND (SELECT VALUE bytes FROM ONLY storage_usage:["alpha"]) == 110;

-- test: une autre organisation ne lit pas les compteurs d'alpha
-- en tant que: autre
RETURN (SELECT VALUE id FROM storage_usage WHERE scope_key = "alpha") == [];

-- préparation: compteur faussé par une écriture de la session root
UPDATE storage_usage:["alpha"] SET bytes = 1;

-- test: le contrôle de cohérence signale l'écart sans le corriger
-- en tant que: worker
{
    LET $r = fn::storage_usage_verify({ tenant: "auth_organization:alpha" }).data;
    RETURN $r.valid == false AND array::len($r.mismatches) == 1 AND $r.mismatches[0].bucket == NONE
        AND $r.mismatches[0].counted.bytes == 110 AND $r.mismatches[0].recorded.bytes == 1;
};

-- préparation: compteur rétabli ; quota de l'organisation
{
    UPDATE storage_usage:["alpha"] SET bytes = 110;
    fn::storage_settings_set({ tenant: "auth_organization:alpha", quota_bytes: 150 });
};

-- test: quota contrôlé par la base aussi en écriture directe (taille annoncée en attente)
-- en tant que: admin
-- attendu-erreur: STORAGE_QUOTA_EXCEEDED
CREATE storage_object CONTENT { bucket: type::record((SELECT VALUE clair FROM ONLY passe:ids)), tenant: auth_organization:alpha, key: "gros.pdf", backend: "default", filename: "gros.pdf", declared_size: 41, state: "pending", pending_expires_at: time::now() + 1h };

-- test: sous le quota, l'écriture directe est acceptée et réservée
-- en tant que: admin
{
    CREATE storage_object CONTENT { bucket: type::record((SELECT VALUE clair FROM ONLY passe:ids)), tenant: auth_organization:alpha, key: "petit.pdf", backend: "default", filename: "petit.pdf", declared_size: 40, state: "pending", pending_expires_at: time::now() + 1h };
    RETURN fn::storage_object_usage({ tenant: "auth_organization:alpha" }).data.{ bytes, reserved_bytes } == { bytes: 110, reserved_bytes: 40 };
};

-- test: taille stockée du flux chiffré aux frontières des segments de 64 Kio
{
    LET $bucket = (CREATE ONLY storage_bucket CONTENT { tenant: auth_organization:beta, name: "coffre", encrypted: true }).id;
    LET $stored = array::map([0, 65535, 65536, 65537, 131072], |$size: int| {
        LET $object = (CREATE ONLY storage_object CONTENT { bucket: $bucket, tenant: auth_organization:beta, key: string::concat("f", <string> $size), backend: "default", filename: "f.eml", state: "pending", pending_expires_at: time::now() + 1h });
        RETURN (UPDATE ONLY $object.id SET state = "available", size = $size, content_type = "message/rfc822", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key = "enc:v2:beta-files-1:QUJD", pending_expires_at = NONE).stored_size;
    });
    RETURN $stored == [63, 65598, 65599, 65616, 131151]
        AND (SELECT objects, bytes FROM ONLY storage_usage:["beta"]) == { objects: 5, bytes: 327680 };
};

-- test: l'organisation supprimée emporte ses compteurs
{
    DELETE auth_organization:alpha;
    RETURN array::len(SELECT VALUE id FROM storage_usage WHERE scope_key = "alpha") == 0;
};
