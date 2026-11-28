-- lyxal-test: assertions
-- Droits : fn::infra_can par action pour l'administrateur de la plateforme, l'administrateur et
-- le membre d'une organisation, les comptes de service (avec et sans infra.records.declare, du
-- worker) et la session système ; permissions des tables (lecture, écriture directe) ; seeds
-- (permissions, rôle platform_admin, réglages, tâches) et leur rejeu.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["infra.read", "infra.manage"] }
-- identité orga_admin: { "id": "auth_session:orga_admin", "pv": 1, "permissions": ["storage.object.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité declarant: { "id": "auth_session:declarant", "pv": 1, "permissions": ["infra.records.declare"] }
-- identité service_sans: { "id": "auth_session:service_sans", "pv": 1, "permissions": [] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["infra.worker"] }

-- préparation: organisation, identités et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:orga_admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@lyxal.test" } };
    RELATE auth_identity:orga_admin->auth_member_of->auth_organization:alpha;
    CREATE auth_session:orga_admin CONTENT { identity: auth_identity:orga_admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@lyxal.test" } };
    RELATE auth_identity:membre->auth_member_of->auth_organization:alpha;
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_application:declarant CONTENT { client_id: "lyxal-test-declarant", name: "Courrier", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:declarant CONTENT { application: auth_application:declarant, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_application:service_sans CONTENT { client_id: "lyxal-test-sans-droit", name: "Sans droit", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:service_sans CONTENT { application: auth_application:service_sans, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_application:worker CONTENT { client_id: "lyxal-test-worker", name: "Worker", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:worker CONTENT { application: auth_application:worker, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });
    fn::infra_account_create({ key: "scw", name: "Scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [{ name: "exemple.fr", status: "active" }] });
    fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" });
    fn::infra_records_declare({ owner: "lyxal_mail", subject: "d1", records: [{ fqdn: "exemple.fr", type: "MX", values: ["10 mx.exemple.fr"], mode: "exclusive" }] });
};

-- test: permissions, rôle platform_admin et tâches créés par les seeds
RETURN (SELECT VALUE code FROM auth_permission WHERE module = "lyxal_infra" ORDER BY code) == ["infra.manage", "infra.read", "infra.records.declare", "infra.worker"]
    AND (SELECT VALUE scope FROM auth_permission WHERE module = "lyxal_infra").all(|$s| $s = "installation")
    AND array::sort((SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin).filter(|$c| string::starts_with($c, "infra."))) == ["infra.manage", "infra.read"]
    AND array::len(SELECT * FROM auth_role_grants WHERE out IN [auth_permission:⟨infra.worker⟩, auth_permission:⟨infra.records.declare⟩]) == 0
    AND (SELECT VALUE id FROM scheduler_task WHERE module = "lyxal_infra" ORDER BY id) == [scheduler_task:⟨infra.purge⟩, scheduler_task:⟨infra.tick⟩, scheduler_task:⟨infra.zone_reconcile⟩]
    AND (SELECT VALUE permission FROM scheduler_task WHERE module = "lyxal_infra").all(|$p| $p = "infra.worker")
    AND record::exists(infra_settings:installation);

-- test: rejeu des seeds sans erreur ni doublon, réglage modifié conservé
{
    UPDATE infra_settings:installation SET max_deletions = 3;
    IF !record::exists(infra_settings:installation) THEN ( CREATE infra_settings:installation CONTENT { max_deletions: 10 } ) END;
    IF !record::exists(auth_permission:⟨infra.read⟩) THEN ( CREATE auth_permission:⟨infra.read⟩ CONTENT { code: "infra.read", module: "lyxal_infra", scope: "installation", description: { fr: "x", en: "x" } } ) END;
    RETURN (SELECT VALUE max_deletions FROM ONLY infra_settings:installation) == 3 AND count(SELECT id FROM auth_permission WHERE module = "lyxal_infra") == 4;
};

-- test: la session système peut tout
RETURN ["read", "manage", "declare", "worker"].all(|$a| fn::infra_can({ action: $a })) AND fn::auth_session_valid({}).system;

-- test: administrateur de la plateforme : lecture et gestion, ni déclaration de module ni worker
-- en tant que: plateforme
RETURN fn::infra_can({ action: "read" }) AND fn::infra_can({ action: "manage" })
    AND !fn::infra_can({ action: "declare" }) AND !fn::infra_can({ action: "worker" }) AND !fn::infra_can({ action: "inconnue" })
    AND count(SELECT id FROM infra_record) == 1 AND count(SELECT id FROM infra_account) == 1;

-- test: administrateur et membre d'une organisation : aucun droit, rien de visible
-- en tant que: orga_admin
RETURN !["read", "manage", "declare", "worker"].any(|$a| fn::infra_can({ action: $a }))
    AND count(SELECT id FROM infra_record) == 0 AND count(SELECT id FROM infra_zone) == 0 AND count(SELECT id FROM infra_account) == 0
    AND count(SELECT id FROM infra_change) == 0 AND count(SELECT id FROM infra_settings) == 0
    AND fn::infra_zone_list({}).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_health({}).error.code == "INFRA_PERMISSION_DENIED";

-- test: membre : aucun droit
-- en tant que: membre
RETURN !["read", "manage", "declare", "worker"].any(|$a| fn::infra_can({ action: $a }))
    AND fn::infra_settings_get({}).error.code == "INFRA_PERMISSION_DENIED";

-- test: compte de service avec infra.records.declare : contrat public, lecture des zones et enregistrements, aucune administration
-- en tant que: declarant
RETURN fn::infra_can({ action: "declare" }) AND !fn::infra_can({ action: "read" }) AND !fn::infra_can({ action: "manage" })
    AND count(SELECT id FROM infra_zone) == 1 AND count(SELECT id FROM infra_account) == 0 AND count(SELECT id FROM infra_change) == 0
    AND fn::infra_records_status({ owner: "lyxal_mail", subjects: ["d1"] }).data.items[0].type == "MX"
    AND fn::infra_record_get({ record: <string> fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX") }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_change_list({}).error.code == "INFRA_PERMISSION_DENIED";

-- test: compte de service sans permission : ni déclaration ni lecture
-- en tant que: service_sans
RETURN !["read", "manage", "declare", "worker"].any(|$a| fn::infra_can({ action: $a }))
    AND fn::infra_records_declare({ owner: "lyxal_mail", subject: "d1", records: [] }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_records_subjects({ owner: "lyxal_mail" }).error.code == "INFRA_PERMISSION_DENIED"
    AND count(SELECT id FROM infra_record) == 0;

-- test: compte de service du worker : fonctions du worker et sonde, aucune administration ni déclaration
-- en tant que: worker
RETURN fn::infra_can({ action: "worker" }) AND !fn::infra_can({ action: "manage" }) AND !fn::infra_can({ action: "declare" })
    AND fn::infra_health({}).ok AND fn::infra_zone_due({}).ok
    AND fn::infra_account_create({ key: "w", name: "W", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }).error.code == "INFRA_PERMISSION_DENIED";

-- test: écriture directe d'un membre dans une table : filtrée (rien n'est écrit)
-- en tant que: membre
{
    CREATE infra_record:pirate CONTENT { owner: "manual", subject: "x", fqdn: "x.exemple.fr", type: "A", values: ["192.0.2.1"], ttl: 3600, mode: "exclusive", state: "pending" };
    UPDATE infra_settings:installation SET max_deletions = 1000;
    RETURN true;
};

-- test: les écritures directes du membre n'ont rien changé
RETURN !record::exists(infra_record:pirate) AND (SELECT VALUE max_deletions FROM ONLY infra_settings:installation) == 3;

-- test: un compte de service déclarant ne peut pas écrire un enregistrement manual en direct
-- en tant que: declarant
{
    CREATE infra_record:faux CONTENT { owner: "manual", subject: "x", fqdn: "x.exemple.fr", type: "A", values: ["192.0.2.1"], ttl: 3600, mode: "exclusive", state: "pending" };
    RETURN !record::exists(infra_record:faux);
};
