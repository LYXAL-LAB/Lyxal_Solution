-- lyxal-test: assertions
-- Buckets : création, nom, doublon, portées, modification, liste, suppression (vide seulement),
-- droits.
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

-- test: création d'un bucket d'organisation, types sans doublon
-- en tant que: admin
RETURN fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "plans", description: "Plans de chantier", max_object_size: 1000, allowed_types: ["application/pdf", "image/png", "application/pdf"] }).data.{ name, scope_key, description, max_object_size, allowed_types, readonly }
    == { name: "plans", scope_key: "alpha", description: "Plans de chantier", max_object_size: 1000, allowed_types: ["application/pdf", "image/png"], readonly: false };

-- test: nom déjà pris dans la portée ; même nom libre dans une autre portée
-- en tant que: admin
RETURN fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "plans" }).error.code == "STORAGE_BUCKET_EXISTS";

-- test: l'installation et une autre organisation ont leur propre bucket « plans »
RETURN fn::storage_bucket_create({ name: "plans" }).data.scope_key == "installation"
    AND fn::storage_bucket_create({ tenant: "auth_organization:beta", name: "plans" }).data.scope_key == "beta";

-- test: noms et types invalides refusés
-- en tant que: admin
RETURN fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "Plans Chantier" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "ab" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "a--b" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_bucket_create({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "photos", allowed_types: ["pas un type"] }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "photos", max_object_size: 0 }).error.code == "STORAGE_INVALID_PARAMETERS";

-- test: modification : champ absent conservé, clear efface, lecture seule
-- en tant que: admin
{
    LET $b = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    RETURN fn::storage_bucket_update({ bucket: <string> $b, readonly: true, allowed_types: [] }).data.{ description, max_object_size, allowed_types, readonly } == { description: "Plans de chantier", max_object_size: 1000, allowed_types: [], readonly: true }
        AND fn::storage_bucket_update({ bucket: <string> $b, readonly: false, clear: ["description", "max_object_size"] }).data.{ description, max_object_size, readonly } == { description: NONE, max_object_size: NONE, readonly: false }
        AND fn::storage_bucket_update({ bucket: <string> $b, clear: ["name"] }).error.code == "STORAGE_INVALID_PARAMETERS"
        AND fn::storage_bucket_update({ bucket: "storage_bucket:inconnu", readonly: true }).error.code == "STORAGE_BUCKET_NOT_FOUND";
};

-- test: lecture et liste d'une portée, triée par nom
-- en tant que: admin
{
    fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "archives" });
    LET $b = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    RETURN fn::storage_bucket_get({ bucket: <string> $b }).data.{ name, usage } == { name: "plans", usage: { objects: 0, bytes: 0 } }
        AND fn::storage_bucket_list({ tenant: "auth_organization:alpha" }).data.{ names: items.name, total } == { names: ["archives", "plans"], total: 2 }
        AND fn::storage_bucket_list({ tenant: "auth_organization:alpha", limit: 1, start: 1 }).data.items.name == ["plans"]
        AND fn::storage_bucket_get({ bucket: "storage_bucket:inconnu" }).error.code == "STORAGE_BUCKET_NOT_FOUND";
};

-- test: un lecteur voit les buckets de son organisation, ne les crée ni ne les modifie
-- en tant que: lecteur
{
    LET $b = (SELECT VALUE id FROM ONLY storage_bucket WHERE name = "plans" LIMIT 1);
    RETURN fn::storage_bucket_list({ tenant: "auth_organization:alpha" }).data.total == 2
        AND fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "pirate" }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_bucket_update({ bucket: <string> $b, readonly: true }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_bucket_delete({ bucket: <string> $b }).error.code == "STORAGE_PERMISSION_DENIED"
        AND fn::storage_bucket_list({}).error.code == "STORAGE_PERMISSION_DENIED";
};

-- test: une autre organisation ne voit pas ces buckets
-- en tant que: autre
RETURN fn::storage_bucket_list({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED"
    AND (SELECT VALUE scope_key FROM storage_bucket) == ["beta"]
    AND fn::storage_bucket_get({ bucket: <string> (SELECT VALUE id FROM ONLY storage_bucket:⟨inexistant⟩) ?? "storage_bucket:x" }).error.code == "STORAGE_BUCKET_NOT_FOUND";

-- test: un membre sans permission ne voit rien
-- en tant que: membre
RETURN array::len(SELECT VALUE id FROM storage_bucket) == 0 AND fn::storage_bucket_list({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: écriture directe filtrée par les permissions de la table
-- en tant que: lecteur
RETURN (CREATE storage_bucket CONTENT { tenant: auth_organization:alpha, name: "direct" }) == [];

-- préparation: un fichier dans le bucket archives
{
    LET $b = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "archives" LIMIT 1);
    fn::storage_object_begin({ bucket: <string> $b, key: "a.txt", filename: "a.txt" });
};

-- test: un bucket qui contient un fichier ne se supprime pas ; un bucket vide oui
-- en tant que: admin
{
    LET $archives = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "archives" LIMIT 1);
    LET $plans = (SELECT VALUE id FROM ONLY storage_bucket WHERE scope_key = "alpha" AND name = "plans" LIMIT 1);
    RETURN fn::storage_bucket_delete({ bucket: <string> $archives }).error.{ code, objects: details.objects } == { code: "STORAGE_BUCKET_NOT_EMPTY", objects: 1 }
        AND fn::storage_bucket_delete({ bucket: <string> $plans }).data.deleted == true
        AND fn::storage_bucket_delete({ bucket: <string> $plans }).error.code == "STORAGE_BUCKET_NOT_FOUND"
        AND fn::storage_bucket_list({ tenant: "auth_organization:alpha" }).data.items.name == ["archives"];
};

-- test: la base refuse aussi la suppression directe d'un bucket non vide
-- attendu-erreur: STORAGE_BUCKET_NOT_EMPTY
DELETE storage_bucket WHERE name = "archives";

-- test: le bucket et son fichier sont intacts
RETURN array::len(SELECT VALUE id FROM storage_bucket WHERE name = "archives") == 1 AND array::len(SELECT VALUE id FROM storage_object) == 1;
