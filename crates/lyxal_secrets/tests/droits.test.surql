-- lyxal-test: assertions
-- Droits : permissions et rôles créés par le seed (moindre privilège) ; fn::secrets_can par
-- action et par portée ; organisations isolées ; installation ; écritures filtrées par les
-- permissions (SECRETS_WRITE_FORBIDDEN) ; rejeu des seeds. Réglages : valeurs effectives, bornes.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.secret.delete", "secrets.secret.restore", "secrets.secret.purge", "secrets.audit.read", "secrets.settings.manage", "secrets.value.read"] }
-- identité redacteur: { "id": "auth_session:redacteur", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["secrets.secret.list"] }
-- identité humain: { "id": "auth_session:humain", "pv": 1, "permissions": ["secrets.secret.list", "secrets.value.read"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.secret.delete", "secrets.secret.restore", "secrets.secret.purge", "secrets.audit.read", "secrets.settings.manage", "secrets.value.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["secrets.installation.manage"] }
-- identité robot: { "id": "auth_session:robot", "pv": 1, "permissions": ["secrets.value.read"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["secrets.worker"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $n IN ["admin", "redacteur", "lecteur", "humain", "membre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    FOR $n IN ["plateforme", "worker"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    -- Compte de service d'alpha : session sans identité
    CREATE auth_application:robot CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-robot-alpha", name: "Robot", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:robot CONTENT { application: auth_application:robot, kind: "service", organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    -- Table de passage d'identifiants entre identités (lisible par tous)
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- test: permissions et rôles créés par le seed ; organization_admin sans lecture de valeur ni purge
RETURN (SELECT VALUE code FROM auth_permission WHERE module = "lyxal_secrets" ORDER BY code) == ["secrets.audit.read", "secrets.installation.manage", "secrets.secret.delete", "secrets.secret.list", "secrets.secret.purge", "secrets.secret.restore", "secrets.secret.write", "secrets.settings.manage", "secrets.value.read", "secrets.worker"]
    AND array::sort((SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_admin).filter(|$c| string::starts_with($c, "secrets."))) == ["secrets.audit.read", "secrets.secret.delete", "secrets.secret.list", "secrets.secret.restore", "secrets.secret.write", "secrets.settings.manage"]
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin).filter(|$c| string::starts_with($c, "secrets.")) == ["secrets.installation.manage"]
    AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨secrets.worker⟩) == 0;

-- test: rejeu des seeds sans doublon ni erreur
{
    IF !record::exists(auth_permission:⟨secrets.worker⟩) THEN (
        CREATE auth_permission:⟨secrets.worker⟩ CONTENT { code: "secrets.worker", module: "lyxal_secrets", scope: "installation", description: { fr: "x", en: "x" } }
    ) END;
    RETURN array::len(SELECT * FROM auth_permission WHERE module = "lyxal_secrets") = 10;
};

-- test: la session système peut tout ; le secret n'a d'existence qu'avec sa portée
RETURN ["list", "read_value", "write", "delete", "restore", "purge", "audit", "settings", "worker"].all(|$a| fn::secrets_can({ action: $a, tenant: auth_organization:alpha }) AND fn::secrets_can({ action: $a }))
    AND fn::secrets_caller().system AND fn::secrets_tenant_string(NONE) IS NONE AND fn::secrets_tenant_string(auth_organization:alpha) = "auth_organization:alpha";

-- test: administrateur : tout dans son organisation sauf ce qui est donné explicitement ; rien ailleurs
-- en tant que: admin
RETURN ["list", "read_value", "write", "delete", "restore", "purge", "audit", "settings"].all(|$a| fn::secrets_can({ action: $a, tenant: auth_organization:alpha }))
    AND !fn::secrets_can({ action: "worker", tenant: auth_organization:alpha })
    AND !["list", "read_value", "write"].any(|$a| fn::secrets_can({ action: $a, tenant: auth_organization:beta }))
    AND !["list", "write", "worker"].any(|$a| fn::secrets_can({ action: $a }))
    AND !fn::secrets_can({ action: "inconnue", tenant: auth_organization:alpha })
    AND fn::secrets_caller().identity = auth_identity:admin AND fn::secrets_caller().kind = "interactive";

-- test: lecteur : liste seulement
-- en tant que: lecteur
RETURN fn::secrets_can({ action: "list", tenant: auth_organization:alpha })
    AND !["read_value", "write", "delete", "restore", "purge", "audit", "settings"].any(|$a| fn::secrets_can({ action: $a, tenant: auth_organization:alpha }));

-- test: compte de service : son application, identifiant de consommateur
-- en tant que: robot
RETURN fn::secrets_caller().application = auth_application:robot AND fn::secrets_caller().consumer = "auth_application:robot"
    AND fn::secrets_caller().kind = "service" AND fn::secrets_can({ action: "read_value", tenant: auth_organization:alpha })
    AND !fn::secrets_can({ action: "list", tenant: auth_organization:alpha });

-- test: plateforme : l'installation seulement
-- en tant que: plateforme
RETURN ["list", "read_value", "write", "delete", "restore", "purge", "audit", "settings"].all(|$a| fn::secrets_can({ action: $a }))
    AND !fn::secrets_can({ action: "list", tenant: auth_organization:alpha })
    AND !fn::secrets_can({ action: "worker" });

-- test: secret de l'installation : créé et lu par la plateforme, invisible d'une organisation
-- en tant que: plateforme
{
    LET $s = fn::secrets_secret_create({ path: "smtp/relais", kind: "password" });
    CREATE passe:installation SET id_secret = $s.data.id;
    RETURN $s.ok AND $s.data.scope_key = "installation" AND fn::secrets_secret_list({}).data.total = 1;
};

-- test: un administrateur d'organisation ne voit pas les secrets de l'installation
-- en tant que: admin
RETURN fn::secrets_secret_list({}).error.code = "SECRETS_PERMISSION_DENIED"
    AND fn::secrets_secret_get({ secret: <string> (SELECT VALUE id_secret FROM ONLY passe:installation) }).error.code = "SECRETS_SECRET_NOT_FOUND";

-- test: membre sans permission : chaque fonction refuse
-- en tant que: membre
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:installation);
    LET $alpha = "auth_organization:alpha";
    RETURN [
        fn::secrets_settings_get({ tenant: $alpha }),
        fn::secrets_settings_set({ tenant: $alpha, max_versions: 3 }),
        fn::secrets_secret_create({ tenant: $alpha, path: "x", kind: "token" }),
        fn::secrets_secret_list({ tenant: $alpha }),
        fn::secrets_audit_list({ tenant: $alpha }),
        fn::secrets_audit_verify({ tenant: $alpha }),
        fn::secrets_purge_due({})
    ].all(|$r| $r.error.code = "SECRETS_PERMISSION_DENIED")
        AND [
            fn::secrets_secret_update({ secret: $s, description: "x" }),
            fn::secrets_secret_disable({ secret: $s }),
            fn::secrets_secret_enable({ secret: $s }),
            fn::secrets_secret_delete({ secret: $s }),
            fn::secrets_secret_restore({ secret: $s }),
            fn::secrets_secret_purge({ secret: $s }),
            fn::secrets_version_add({ secret: $s, number: 1, envelope: "enc:v2:k1:A", key_id: "k1" }),
            fn::secrets_version_list({ secret: $s }),
            fn::secrets_version_label({ secret: $s, label: "current", number: 1 }),
            fn::secrets_version_disable({ secret: $s, number: 1 }),
            fn::secrets_version_destroy({ secret: $s, number: 1 }),
            fn::secrets_read_begin({ secret: $s })
        ].all(|$r| $r.error.code IN ["SECRETS_SECRET_NOT_FOUND", "SECRETS_PERMISSION_DENIED"]);
};

-- préparation: table des réglages fermée à l'écriture, pour vérifier le contrôle de l'écriture principale
{
    DEFINE TABLE OVERWRITE secrets_settings TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update NONE FOR delete NONE;
};

-- test: réglages : écriture refusée par la table, erreur explicite
-- en tant que: admin
RETURN fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_versions: 3 }).error.code = "SECRETS_WRITE_FORBIDDEN";

-- préparation: permissions des réglages rétablies
{
    DEFINE TABLE OVERWRITE secrets_settings TYPE NORMAL SCHEMAFULL
        PERMISSIONS
            FOR select WHERE tenant IS NONE OR fn::secrets_can({ action: "list", tenant: tenant })
            FOR create, update WHERE fn::secrets_can({ action: "settings", tenant: tenant })
            FOR delete NONE;
};

-- test: réglages par défaut, puis surcharge de l'installation et de l'organisation
-- en tant que: admin
{
    LET $def = fn::secrets_settings_get({ tenant: "auth_organization:alpha" }).data;
    RETURN $def.own IS NONE AND $def.effective = { max_versions: 10, deleted_retention_days: 30, purge_protection: false, max_value_bytes: 65536, default_visibility: "restricted", expiry_warning_days: 30, tenant_key_rotation_days: 365 };
};

-- test: l'installation règle ses valeurs, héritées par les organisations
-- en tant que: plateforme
RETURN fn::secrets_settings_set({ max_versions: 20, default_visibility: "revealable" }).ok;

-- test: valeurs héritées puis surchargées ; effacement par clear ; bornes
-- en tant que: admin
{
    LET $h = fn::secrets_settings_get({ tenant: "auth_organization:alpha" }).data.effective;
    LET $own = fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_versions: 5, deleted_retention_days: 7, expiry_warning_days: 10 });
    LET $e = fn::secrets_settings_get({ tenant: "auth_organization:alpha" }).data.effective;
    LET $c = fn::secrets_settings_set({ tenant: "auth_organization:alpha", clear: ["max_versions"] });
    RETURN $h.max_versions = 20 AND $h.default_visibility = "revealable"
        AND $own.ok AND $e.max_versions = 5 AND $e.deleted_retention_days = 7 AND $e.expiry_warning_days = 10
        AND $c.data.max_versions IS NONE AND fn::secrets_settings_get({ tenant: "auth_organization:alpha" }).data.effective.max_versions = 20
        AND fn::secrets_settings_set({ tenant: "auth_organization:alpha", deleted_retention_days: 3 }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_versions: 101 }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_value_bytes: 2000000 }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_settings_set({ tenant: "auth_organization:alpha", clear: ["purge_protection"] }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: un nouveau secret prend la visibilité par défaut héritée
-- en tant que: admin
RETURN fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "herite", kind: "token" }).data.visibility = "revealable";

-- test: un rédacteur ne règle pas le coffre-fort
-- en tant que: redacteur
RETURN fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_versions: 3 }).error.code = "SECRETS_PERMISSION_DENIED"
    AND fn::secrets_settings_get({ tenant: "auth_organization:alpha" }).ok;

-- test: protection contre la purge de l'installation : appliquée à toutes les organisations
-- en tant que: plateforme
RETURN fn::secrets_settings_set({ purge_protection: true }).ok;

-- test: protection héritée
-- en tant que: admin
RETURN fn::secrets_settings_get({ tenant: "auth_organization:alpha" }).data.effective.purge_protection = true;
