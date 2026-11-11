-- lyxal-test: assertions
-- Droits : fn::storage_can par action et par portée ; fichiers d'une organisation invisibles
-- d'une autre ; lecteur sans écriture ; membre sans permission ; installation ; écritures
-- filtrées par les permissions des tables ; rejeu des seeds.
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

-- préparation: buckets et fichiers d'alpha et de l'installation
{
    LET $a = fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "plans" }).data.id;
    LET $i = fn::storage_bucket_create({ name: "modeles" }).data.id;
    LET $oa = fn::storage_object_begin({ bucket: <string> $a, key: "a.pdf", filename: "a.pdf", declared_size: 5 }).data.id;
    LET $oi = fn::storage_object_begin({ bucket: <string> $i, key: "i.pdf", filename: "i.pdf", declared_size: 5 }).data.id;
    fn::storage_object_commit({ object: <string> $oa, size: 5, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" });
    fn::storage_object_commit({ object: <string> $oi, size: 5, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" });
};

-- test: permissions et rôles créés par le seed
RETURN (SELECT VALUE code FROM auth_permission WHERE module = "lyxal_storage" ORDER BY code) == ["storage.bucket.manage", "storage.installation.manage", "storage.object.read", "storage.object.write", "storage.worker"]
    AND array::sort((SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_admin).filter(|$c| string::starts_with($c, "storage."))) == ["storage.bucket.manage", "storage.object.read", "storage.object.write"]
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin).filter(|$c| string::starts_with($c, "storage.")) == ["storage.installation.manage"]
    AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨storage.worker⟩) == 0;

-- test: la session système peut tout
RETURN ["read", "write", "manage", "worker"].all(|$a| fn::storage_can({ action: $a, tenant: auth_organization:alpha }) AND fn::storage_can({ action: $a }));

-- test: administrateur d'organisation : tout dans son organisation, rien ailleurs
-- en tant que: admin
RETURN ["read", "write", "manage"].all(|$a| fn::storage_can({ action: $a, tenant: auth_organization:alpha }))
    AND !fn::storage_can({ action: "worker", tenant: auth_organization:alpha })
    AND !["read", "write", "manage"].any(|$a| fn::storage_can({ action: $a, tenant: auth_organization:beta }))
    AND !["read", "write", "manage", "worker"].any(|$a| fn::storage_can({ action: $a }))
    AND !fn::storage_can({ action: "inconnue", tenant: auth_organization:alpha });

-- test: lecteur : lecture seule
-- en tant que: lecteur
RETURN fn::storage_can({ action: "read", tenant: auth_organization:alpha })
    AND !fn::storage_can({ action: "write", tenant: auth_organization:alpha })
    AND !fn::storage_can({ action: "manage", tenant: auth_organization:alpha });

-- test: rédacteur : lecture et écriture, pas de gestion
-- en tant que: redacteur
RETURN fn::storage_can({ action: "read", tenant: auth_organization:alpha })
    AND fn::storage_can({ action: "write", tenant: auth_organization:alpha })
    AND !fn::storage_can({ action: "manage", tenant: auth_organization:alpha });

-- test: administrateur de l'installation : l'installation seulement
-- en tant que: plateforme
RETURN ["read", "write", "manage"].all(|$a| fn::storage_can({ action: $a }))
    AND !fn::storage_can({ action: "worker" })
    AND !fn::storage_can({ action: "read", tenant: auth_organization:alpha });

-- test: worker : lecture et écriture de toute portée, opérations de worker, pas de gestion
-- en tant que: worker
RETURN fn::storage_can({ action: "worker" })
    AND ["read", "write"].all(|$a| fn::storage_can({ action: $a, tenant: auth_organization:alpha }) AND fn::storage_can({ action: $a }))
    AND !fn::storage_can({ action: "manage", tenant: auth_organization:alpha })
    AND !fn::storage_can({ action: "manage" });

-- test: un lecteur lit les fichiers de son organisation, ne les écrit ni ne les supprime
-- en tant que: lecteur
{
    LET $b = (SELECT VALUE id FROM ONLY storage_bucket WHERE name = "plans" LIMIT 1);
    LET $o = (SELECT VALUE id FROM ONLY storage_object WHERE key = "a.pdf" LIMIT 1);
    RETURN fn::storage_object_get({ object: <string> $o }).data.key == "a.pdf"
        AND fn::storage_object_list({ bucket: <string> $b }).data.total == 1
        AND fn::storage_object_usage({ tenant: "auth_organization:alpha" }).data.bytes == 5
        AND fn::storage_object_begin({ bucket: <string> $b, key: "pirate.pdf", filename: "p.pdf" }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_object_delete({ object: <string> $o }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_object_commit({ object: <string> $o, size: 1, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_PERMISSION_DENIED"
        AND array::len(SELECT VALUE id FROM storage_object) == 1;
};

-- test: une autre organisation ne voit ni les buckets ni les fichiers d'alpha ou de l'installation
-- en tant que: autre
RETURN array::len(SELECT VALUE id FROM storage_object) == 0
    AND array::len(SELECT VALUE id FROM storage_bucket) == 0
    AND fn::storage_object_usage({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_object_usage({}).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_object_usage({ tenant: "auth_organization:beta" }).data == { objects: 0, bytes: 0, reserved_bytes: 0, quota_bytes: NONE };

-- test: une fiche invisible est introuvable, pas « interdite »
-- en tant que: autre
RETURN fn::storage_object_get({ object: <string> (SELECT VALUE id FROM ONLY storage_object LIMIT 1) ?? "storage_object:x" }).error.code == "STORAGE_OBJECT_NOT_FOUND"
    AND fn::storage_object_list({ bucket: "storage_bucket:x" }).error.code == "STORAGE_BUCKET_NOT_FOUND";

-- test: un membre sans permission ne voit rien
-- en tant que: membre
RETURN array::len(SELECT VALUE id FROM storage_object) == 0
    AND fn::storage_object_usage({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: l'administrateur de l'installation gère les fichiers de l'installation, pas ceux d'alpha
-- en tant que: plateforme
RETURN (SELECT VALUE key FROM storage_object) == ["i.pdf"]
    AND fn::storage_bucket_list({}).data.items.name == ["modeles"]
    AND fn::storage_object_usage({}).data.bytes == 5
    AND fn::storage_bucket_list({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: écritures directes filtrées par les permissions des tables
-- en tant que: lecteur
RETURN (UPDATE storage_object SET filename = "pirate.pdf") == []
    AND (DELETE storage_object RETURN BEFORE) == []
    AND (CREATE storage_object CONTENT { bucket: (SELECT VALUE id FROM ONLY storage_bucket LIMIT 1), tenant: auth_organization:alpha, key: "direct.pdf", filename: "d.pdf", backend: "default" }) == [];

-- test: rien n'a changé
RETURN (SELECT VALUE filename FROM storage_object ORDER BY key) == ["a.pdf", "i.pdf"];

-- préparation: écriture ouverte par l'administrateur d'alpha
-- en tant que: admin
fn::storage_object_begin({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE name = "plans" LIMIT 1), key: "en-cours.pdf", filename: "en-cours.pdf", declared_size: 5 });

-- test: écriture directe : un rédacteur ne rend pas disponible le fichier d'un autre
-- en tant que: redacteur
-- attendu-erreur: STORAGE_PERMISSION_DENIED
UPDATE storage_object SET state = "available", size = 5, content_type = "application/pdf", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", pending_expires_at = NONE WHERE key = "en-cours.pdf";

-- test: écriture directe : un rédacteur ne met pas un fichier en quarantaine
-- en tant que: redacteur
-- attendu-erreur: STORAGE_PERMISSION_DENIED
UPDATE storage_object SET state = "quarantined" WHERE key = "a.pdf";

-- test: écriture directe : un rédacteur ne change ni la taille ni l'empreinte d'un fichier
-- en tant que: redacteur
-- attendu-erreur: STORAGE_PERMISSION_DENIED
UPDATE storage_object SET size = 1 WHERE key = "a.pdf";

-- test: écriture directe : l'auteur ne rend pas son fichier disponible sans taille, type ni empreinte
-- en tant que: admin
-- attendu-erreur: STORAGE_OBJECT_STATE_INVALID
UPDATE storage_object SET state = "available" WHERE key = "en-cours.pdf";

-- test: écriture directe : un rédacteur ne supprime pas un fichier en écourtant sa conservation
-- en tant que: redacteur
-- attendu-erreur: STORAGE_PERMISSION_DENIED
UPDATE storage_object SET state = "deleted", deleted_at = time::now(), purge_after = time::now() WHERE key = "a.pdf";

-- test: rien n'a changé ; un rédacteur renomme un fichier (champ libre)
-- en tant que: redacteur
RETURN (SELECT VALUE [state, size] FROM storage_object ORDER BY key) == [["available", 5], ["pending", NONE]]
    AND (UPDATE storage_object SET filename = "A.pdf" WHERE key = "a.pdf" RETURN VALUE filename) == ["A.pdf"];

-- préparation: nom d'origine rétabli
UPDATE storage_object SET filename = "a.pdf" WHERE key = "a.pdf";

-- test: garde des modifications, appelée directement : transitions, contenu, session système
{
    LET $o = (SELECT * FROM ONLY storage_object WHERE key = "en-cours.pdf" LIMIT 1);
    RETURN fn::storage_object_update_refusal($o, object::extend($o, { state: "quarantined" })) == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_update_refusal($o, object::extend($o, { state: "available" })) == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_update_refusal($o, object::extend($o, { state: "available", size: 5, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" })) == NONE
        AND fn::storage_object_update_refusal($o, object::extend($o, { state: "deleted" })) == "STORAGE_OBJECT_STATE_INVALID"
        AND fn::storage_object_update_refusal($o, object::extend($o, { filename: "autre.pdf", size: 9 })) == NONE;
};

-- préparation: le bucket passe en lecture seule pendant l'écriture
-- en tant que: admin
fn::storage_bucket_update({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE name = "plans" LIMIT 1), readonly: true });

-- test: une écriture ouverte avant la lecture seule ne se termine plus
-- en tant que: admin
RETURN fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "en-cours.pdf" LIMIT 1), size: 5, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }).error.code == "STORAGE_BUCKET_READONLY";

-- test: la base la refuse aussi en écriture directe
-- en tant que: admin
-- attendu-erreur: STORAGE_BUCKET_READONLY
UPDATE storage_object SET state = "available", size = 5, content_type = "application/pdf", blake3 = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", pending_expires_at = NONE WHERE key = "en-cours.pdf";

-- préparation: le bucket redevient modifiable ; l'écriture est terminée par son auteur
-- en tant que: admin
{
    fn::storage_bucket_update({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE name = "plans" LIMIT 1), readonly: false });
    fn::storage_object_commit({ object: <string> (SELECT VALUE id FROM ONLY storage_object WHERE key = "en-cours.pdf" LIMIT 1), size: 5, content_type: "application/pdf", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" });
};

-- test: les deux fichiers d'alpha sont disponibles
RETURN (SELECT VALUE state FROM storage_object WHERE scope_key = "alpha" ORDER BY key) == ["available", "available"];

-- test: l'organisation supprimée emporte ses buckets, ses fichiers et ses réglages
{
    fn::storage_settings_set({ tenant: "auth_organization:alpha", quota_bytes: 10 });
    DELETE auth_organization:alpha;
    RETURN (SELECT VALUE scope_key FROM storage_object) == ["installation"]
        AND (SELECT VALUE scope_key FROM storage_bucket) == ["installation"]
        AND array::len(SELECT VALUE id FROM storage_settings) == 0;
};

-- test: les octets des buckets de l'organisation supprimée sont à retirer (un préfixe par bucket)
{
    LET $prefixes = (SELECT VALUE prefix FROM storage_reclaim);
    RETURN array::len($prefixes) >= 1
        AND array::all($prefixes, |$p| string::starts_with($p, "alpha/"))
        AND array::all((SELECT VALUE backend FROM storage_reclaim), |$b| $b == "default");
};

-- test: la liste des préfixes à retirer est réservée au worker ; aucune écriture directe
-- en tant que: plateforme
RETURN fn::storage_reclaim_list({}).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_reclaim_done({ reclaim: "storage_reclaim:x" }).error.code == "STORAGE_PERMISSION_DENIED"
    AND (SELECT VALUE id FROM storage_reclaim) == []
    AND (CREATE storage_reclaim CONTENT { backend: "default", prefix: "installation/x" }) == []
    AND (DELETE storage_reclaim RETURN BEFORE) == [];

-- test: le worker lit les préfixes, puis retire chaque ligne ; un rejeu n'est pas une erreur
-- en tant que: worker
{
    LET $items = fn::storage_reclaim_list({ limit: 10 }).data.items;
    LET $done = array::map($items, |$r| fn::storage_reclaim_done({ reclaim: <string> $r.id }).data.done);
    RETURN array::len($items) >= 1
        AND array::all($items, |$r| $r.backend == "default" AND string::starts_with($r.prefix, "alpha/"))
        AND array::all($done, |$d| $d == true)
        AND fn::storage_reclaim_done({ reclaim: <string> $items[0].id }).data == { done: false }
        AND fn::storage_reclaim_list({}).data.items == []
        AND fn::storage_reclaim_list({ limit: 0 }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_reclaim_done({}).error.code == "STORAGE_INVALID_PARAMETERS";
};
