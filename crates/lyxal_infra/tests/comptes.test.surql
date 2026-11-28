-- lyxal-test: assertions
-- Comptes d'hébergeur : création (secret absent, hors infra/, illisible par l'appelant),
-- modification, lecture sans secret, essai demandé et résultat, suppression refusée tant qu'une
-- zone l'utilise ; réglages (bornes, cohérence, écriture filtrée).
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["infra.read", "infra.manage", "secrets.installation.manage"] }
-- identité gestion_sans_coffre: { "id": "auth_session:gestion_sans_coffre", "pv": 1, "permissions": ["infra.read", "infra.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["infra.read"] }

-- préparation: identités, sessions et secrets du coffre-fort
{
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:gestion_sans_coffre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "gestion@lyxal.test" } };
    CREATE auth_session:gestion_sans_coffre CONTENT { identity: auth_identity:gestion_sans_coffre, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:lecteur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lecteur@lyxal.test" } };
    CREATE auth_session:lecteur CONTENT { identity: auth_identity:lecteur, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_secret_create({ path: "infra/scaleway-main", kind: "api_key" });
    fn::secrets_secret_create({ path: "infra/scaleway-other", kind: "api_key" });
    fn::secrets_secret_create({ path: "notification/smtp", kind: "password" });
};

-- test: création par l'administrateur de la plateforme : clé, fournisseur, réglages par défaut, essai demandé
-- en tant que: plateforme
{
    LET $r = fn::infra_account_create({ key: "scw_main", name: "Scaleway principal", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    RETURN $r.ok AND $r.data.id == infra_account:⟨scw_main⟩ AND $r.data.provider == "scaleway" AND $r.data.state == "active"
        AND $r.data.settings == { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11", default_zone: "fr-par-1", default_region: "fr-par" }
        AND $r.data.test_requested_at IS NOT NONE AND $r.data.discovered_zones == [];
};

-- test: même clé : INFRA_ACCOUNT_EXISTS
-- en tant que: plateforme
RETURN fn::infra_account_create({ key: "scw_main", name: "Doublon", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }).error.code == "INFRA_ACCOUNT_EXISTS";

-- test: secret absent, hors infra/, ou d'un autre dossier : INFRA_ACCOUNT_SECRET_INVALID
-- en tant que: plateforme
RETURN [
    fn::infra_account_create({ key: "absent", name: "A", credentials_path: "infra/inconnu", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }),
    fn::infra_account_create({ key: "ailleurs", name: "A", credentials_path: "notification/smtp", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } })
].all(|$r| $r.error.code == "INFRA_ACCOUNT_SECRET_INVALID");

-- test: sans droit sur les secrets de l'installation : secret refusé, même existant
-- en tant que: gestion_sans_coffre
RETURN fn::infra_account_create({ key: "sans_coffre", name: "A", credentials_path: "infra/scaleway-other", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }).error.code == "INFRA_ACCOUNT_SECRET_INVALID";

-- test: paramètres refusés par lyxal_core (clé, projet, champ inconnu, compte imposé)
-- en tant que: plateforme
RETURN [
    fn::infra_account_create({ key: "Pas Un Slug", name: "A", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }),
    fn::infra_account_create({ key: "a", name: "A", credentials_path: "infra/scaleway-main", settings: { project_id: "pas-un-uuid" } }),
    fn::infra_account_create({ key: "a", name: "A", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" }, inconnu: 1 }),
    fn::infra_account_create({ key: "a", name: "A", credentials_path: "infra/scaleway-main" }),
    fn::infra_account_create({ account: "infra_account:a", key: "a", name: "A", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }),
    fn::infra_account_create({ key: "a", name: "A", provider: "ovhcloud", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" }, language: "en" })
].all(|$r| $r.error.code == "INFRA_INVALID_PARAMETERS");

-- test: un lecteur lit les comptes sans secret, ne crée ni ne modifie
-- en tant que: lecteur
{
    LET $get = fn::infra_account_get({ account: "infra_account:scw_main" });
    RETURN $get.ok AND $get.data.credentials_path == "infra/scaleway-main" AND $get.data.zones == 0
        AND fn::infra_account_list({}).data.items.key == ["scw_main"]
        AND fn::infra_account_create({ key: "x", name: "A", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_account_update({ account: "infra_account:scw_main", name: "X" }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_account_test_request({ account: "infra_account:scw_main" }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_account_delete({ account: "infra_account:scw_main" }).error.code == "INFRA_PERMISSION_DENIED";
};

-- test: modification : nom, réglages partiels, nouvelle clé (nouvel essai), clé et fournisseur fixes
-- en tant que: plateforme
{
    UPDATE infra_account:⟨scw_main⟩ SET test_requested_at = NONE;
    LET $renamed = fn::infra_account_update({ account: "infra_account:scw_main", name: "Scaleway Paris", settings: { default_zone: "fr-par-2" } });
    LET $rekeyed = fn::infra_account_update({ account: "infra_account:scw_main", credentials_path: "infra/scaleway-other" });
    RETURN $renamed.data.name == "Scaleway Paris" AND $renamed.data.settings.default_zone == "fr-par-2"
        AND $renamed.data.settings.project_id == u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" AND $renamed.data.test_requested_at IS NONE
        AND $rekeyed.data.credentials_path == "infra/scaleway-other" AND $rekeyed.data.test_requested_at IS NOT NONE
        AND fn::infra_account_update({ account: "infra_account:scw_main", key: "autre" }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_account_update({ account: "infra_account:scw_main", provider: "scaleway" }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_account_update({ account: "infra_account:inconnu", name: "X" }).error.code == "INFRA_ACCOUNT_NOT_FOUND"
        AND fn::infra_account_update({ account: "infra_account:scw_main", credentials_path: "infra/inconnu" }).error.code == "INFRA_ACCOUNT_SECRET_INVALID";
};

-- test: écriture directe du chemin de la clé : mêmes contrôles (garde)
-- en tant que: gestion_sans_coffre
-- attendu-erreur: INFRA_ACCOUNT_SECRET_INVALID
UPDATE infra_account:⟨scw_main⟩ SET credentials_path = "infra/scaleway-main";

-- test: désactivé puis réactivé : un essai est redemandé
-- en tant que: plateforme
{
    UPDATE infra_account:⟨scw_main⟩ SET test_requested_at = NONE;
    LET $off = fn::infra_account_update({ account: "infra_account:scw_main", state: "disabled" });
    LET $on = fn::infra_account_update({ account: "infra_account:scw_main", state: "active" });
    RETURN $off.data.state == "disabled" AND $off.data.test_requested_at IS NONE AND $on.data.state == "active" AND $on.data.test_requested_at IS NOT NONE;
};

-- test: essai demandé, lu par le worker, puis son résultat : zones visibles, compte actif
{
    LET $requested = fn::infra_account_test_request({ account: "infra_account:scw_main" });
    LET $due = fn::infra_account_due({});
    LET $result = fn::infra_account_test_result({ account: "infra_account:scw_main", ok: true, zones: [{ name: "Exemple.FR", status: "active" }, { name: "essai.lyxal.test", status: "pending" }] });
    LET $later = fn::infra_account_get({ account: "infra_account:scw_main" }).data;
    RETURN $requested.ok AND $due.data.items[0].account == infra_account:⟨scw_main⟩ AND $due.data.items[0].credentials_path == "infra/scaleway-other"
        AND $result.data == { account: infra_account:⟨scw_main⟩, state: "active", zones: 2 }
        AND $later.discovered_zones == [{ name: "exemple.fr", status: "active" }, { name: "essai.lyxal.test", status: "pending" }]
        AND $later.last_test.ok AND $later.test_requested_at IS NONE AND array::len(fn::infra_account_due({}).data.items) == 0;
};

-- test: essai refusé par l'hébergeur : compte failing, zones visibles conservées ; code exigé, nom de zone contrôlé
{
    LET $failed = fn::infra_account_test_result({ account: "infra_account:scw_main", ok: false, code: "INFRA_PROVIDER_AUTH" });
    LET $later = fn::infra_account_get({ account: "infra_account:scw_main" }).data;
    LET $ok = fn::infra_account_test_result({ account: "infra_account:scw_main", ok: true, zones: [{ name: "exemple.fr", status: "active" }, { name: "essai.lyxal.test", status: "active" }, { name: "autre.test", status: "active" }] });
    RETURN $failed.data.state == "failing" AND $later.last_test == { at: $later.last_test.at, ok: false, code: "INFRA_PROVIDER_AUTH" } AND array::len($later.discovered_zones) == 2
        AND $ok.data.state == "active"
        AND fn::infra_account_test_result({ account: "infra_account:scw_main", ok: false }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_account_test_result({ account: "infra_account:scw_main", ok: true, zones: [{ name: "_pas.une.zone", status: "active" }] }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_account_test_result({ account: "infra_account:inconnu", ok: true }).error.code == "INFRA_ACCOUNT_NOT_FOUND";
};

-- test: suppression refusée tant qu'une zone l'utilise, puis acceptée
-- en tant que: plateforme
{
    LET $zone = fn::infra_zone_attach({ account: "infra_account:scw_main", name: "autre.test" }).data.id;
    LET $refused = fn::infra_account_delete({ account: "infra_account:scw_main" });
    LET $detached = fn::infra_zone_detach({ zone: <string> $zone });
    LET $deleted = fn::infra_account_delete({ account: "infra_account:scw_main" });
    RETURN $refused.error.code == "INFRA_ACCOUNT_IN_USE" AND $refused.error.details.zones == 1 AND $detached.ok
        AND $deleted.data.deleted == infra_account:⟨scw_main⟩ AND !record::exists(infra_account:⟨scw_main⟩)
        AND fn::infra_account_delete({ account: "infra_account:scw_main" }).error.code == "INFRA_ACCOUNT_NOT_FOUND"
        AND fn::infra_account_get({ account: "infra_account:scw_main" }).error.code == "INFRA_ACCOUNT_NOT_FOUND"
        AND fn::infra_account_test_request({ account: "infra_account:scw_main" }).error.code == "INFRA_ACCOUNT_NOT_FOUND";
};

-- test: réglages par défaut du seed, lus par un lecteur
-- en tant que: lecteur
RETURN fn::infra_settings_get({}).data == { reconcile_minutes: 15, default_ttl: 3600, min_ttl: 60, max_deletions: 10, max_deletion_percent: 30, verify_timeout_hours: 24, requests_per_second: 5, change_retention_days: 400, released_retention_days: 30 }
    AND fn::infra_settings_update({ max_deletions: 5 }).error.code == "INFRA_PERMISSION_DENIED";

-- test: réglages modifiés, bornes et cohérence (min_ttl au plus default_ttl)
-- en tant que: plateforme
{
    LET $saved = fn::infra_settings_update({ max_deletions: 5, default_ttl: 600 });
    RETURN $saved.data.max_deletions == 5 AND $saved.data.default_ttl == 600 AND $saved.data.reconcile_minutes == 15
        AND fn::infra_settings_update({ min_ttl: 900 }).error.code == "INFRA_SETTINGS_INVALID"
        AND fn::infra_settings_update({ max_deletion_percent: 101 }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_settings_update({ inconnu: 1 }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- préparation: table des réglages fermée à l'écriture, pour vérifier le contrôle de l'écriture principale
{
    DEFINE TABLE OVERWRITE infra_settings TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update NONE FOR delete NONE;
};

-- test: réglages : écriture refusée par la table, erreur explicite
-- en tant que: plateforme
RETURN fn::infra_settings_update({ max_deletions: 7 }).error.code == "INFRA_WRITE_FORBIDDEN";

-- préparation: table des comptes fermée à l'écriture
{
    DEFINE TABLE OVERWRITE infra_account TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
};

-- test: comptes : création refusée par la table, erreur explicite
-- en tant que: plateforme
RETURN fn::infra_account_create({ key: "ferme", name: "A", credentials_path: "infra/scaleway-main", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } }).error.code == "INFRA_WRITE_FORBIDDEN";
