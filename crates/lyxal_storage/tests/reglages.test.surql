-- lyxal-test: assertions
-- Réglages du stockage : valeurs par défaut, installation, surcharge d'une organisation,
-- effacement d'un champ, bornes, droits.
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

-- test: valeurs par défaut du module
RETURN fn::storage_settings_get({}).data == { own: NONE, effective: { max_object_size: 104857600, quota_bytes: NONE, pending_ttl_seconds: 86400, upload_ttl_seconds: 86400, deleted_retention_days: 7, blocked_types: ["application/vnd.microsoft.portable-executable", "application/x-executable", "application/x-mach-binary", "application/x-msdownload"] } }
    AND fn::storage_settings_effective({ tenant: auth_organization:alpha }).max_object_size == 104857600;

-- test: l'administrateur de l'installation règle l'installation
-- en tant que: plateforme
RETURN fn::storage_settings_set({ max_object_size: 52428800, deleted_retention_days: 30 }).data.{ scope_key, max_object_size, deleted_retention_days } == { scope_key: "installation", max_object_size: 52428800, deleted_retention_days: 30 };

-- test: l'organisation surcharge un champ ; les autres viennent de l'installation
-- en tant que: admin
RETURN fn::storage_settings_set({ tenant: "auth_organization:alpha", quota_bytes: 1000, pending_ttl_seconds: 600 }).data.scope_key == "alpha"
    AND fn::storage_settings_get({ tenant: "auth_organization:alpha" }).data.effective == { max_object_size: 52428800, quota_bytes: 1000, pending_ttl_seconds: 600, upload_ttl_seconds: 86400, deleted_retention_days: 30, blocked_types: ["application/vnd.microsoft.portable-executable", "application/x-executable", "application/x-mach-binary", "application/x-msdownload"] };

-- test: un champ fourni est remplacé, un champ nommé dans clear est effacé, les autres sont conservés
-- en tant que: admin
RETURN fn::storage_settings_set({ tenant: "auth_organization:alpha", max_object_size: 2048, clear: ["quota_bytes"] }).data.{ max_object_size, quota_bytes, pending_ttl_seconds } == { max_object_size: 2048, quota_bytes: NONE, pending_ttl_seconds: 600 }
    AND array::len(SELECT VALUE id FROM storage_settings) == 2;

-- test: valeurs hors bornes et champ inconnu refusés
-- en tant que: admin
RETURN fn::storage_settings_set({ tenant: "auth_organization:alpha", max_object_size: 0 }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_settings_set({ tenant: "auth_organization:alpha", max_object_size: 6000000000 }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_settings_set({ tenant: "auth_organization:alpha", pending_ttl_seconds: 10 }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_settings_set({ tenant: "auth_organization:alpha", clear: ["tenant"] }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_settings_set({ tenant: "auth_organization:alpha", inconnu: 1 }).error.code == "STORAGE_INVALID_PARAMETERS"
    AND fn::storage_settings_get({ tenant: "auth_role:x" }).error.code == "STORAGE_INVALID_PARAMETERS";

-- test: un lecteur lit les réglages de son organisation, ne les modifie pas
-- en tant que: lecteur
RETURN fn::storage_settings_get({ tenant: "auth_organization:alpha" }).data.effective.max_object_size == 2048
    AND fn::storage_settings_set({ tenant: "auth_organization:alpha", quota_bytes: 5 }).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_settings_set({ quota_bytes: 5 }).error.code == "STORAGE_PERMISSION_DENIED";

-- test: une autre organisation ne lit ni ne modifie ces réglages
-- en tant que: autre
RETURN fn::storage_settings_get({ tenant: "auth_organization:alpha" }).error.code == "STORAGE_PERMISSION_DENIED"
    AND fn::storage_settings_set({ tenant: "auth_organization:alpha", quota_bytes: 5 }).error.code == "STORAGE_PERMISSION_DENIED"
    AND (SELECT VALUE scope_key FROM storage_settings) == ["installation"];

-- test: écriture directe filtrée par les permissions de la table
-- en tant que: lecteur
RETURN (UPDATE ONLY storage_settings:alpha SET quota_bytes = 1) == NONE;

-- test: les réglages sont intacts
RETURN (SELECT VALUE quota_bytes FROM ONLY storage_settings:alpha) == NONE;

-- test: types refusés : surcharge par organisation, liste vide, effacement (retour à l'installation), valeur invalide
{
    LET $own = fn::storage_settings_set({ tenant: "auth_organization:alpha", blocked_types: ["application/zip"] }).data.blocked_types;
    LET $effective = fn::storage_settings_effective({ tenant: auth_organization:alpha }).blocked_types;
    LET $installation = fn::storage_settings_set({ blocked_types: [] }).data.blocked_types;
    LET $cleared = fn::storage_settings_set({ tenant: "auth_organization:alpha", clear: ["blocked_types"] }).data.blocked_types;
    RETURN $own == ["application/zip"] AND $effective == ["application/zip"]
        AND $installation == [] AND $cleared == NONE
        AND fn::storage_settings_effective({ tenant: auth_organization:alpha }).blocked_types == []
        AND fn::storage_settings_set({ blocked_types: ["pas un type"] }).error.code == "STORAGE_INVALID_PARAMETERS";
};
