-- ============================================================================
-- FONCTIONS : comptes d'hébergeur
-- MODULE    : lyxal_infra
-- ============================================================================
-- La clé d'API reste dans lyxal_secrets (installation, chemin sous infra/) : un compte n'en porte
-- que le chemin. Le droit de l'appelant sur ce secret est contrôlé comme pour lyxal_notification
-- (fn::secrets_secret_get au nom de l'appelant, secrets.installation.manage).

-- ----------------------------------------------------------------------------
-- fn::infra__account_secret_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__account_secret_refusal($path: any) -> option<string> {
    IF !type::is_string($path) OR !string::starts_with($path, "infra/") { RETURN "INFRA_ACCOUNT_SECRET_INVALID"; };
    -- Droit de gérer les secrets de l'installation (contrats publics de lyxal_auth et lyxal_secrets) ;
    -- la session système de l'hôte n'a pas de droit à prouver
    IF !fn::auth_session_valid({}).system AND !fn::auth_has_permission({ permission: "secrets.installation.manage" }) {
        RETURN "INFRA_ACCOUNT_SECRET_INVALID";
    };
    -- Existence de la fiche, au nom de l'appelant (fiche invisible : absente)
    LET $secret = fn::secrets_secret_get({ path: $path });
    IF !$secret.ok OR $secret.data.state = "deleted" { RETURN "INFRA_ACCOUNT_SECRET_INVALID"; };
    RETURN NONE;
} COMMENT "Interne : NONE si le secret ($path) est sous infra/, existe dans l'installation (lyxal_secrets, fn::secrets_secret_get au nom de l'appelant) et si l'appelant peut gérer les secrets de l'installation (secrets.installation.manage ; session système dispensée) ; sinon INFRA_ACCOUNT_SECRET_INVALID";

-- ----------------------------------------------------------------------------
-- fn::infra__account_fields (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__account_fields($create: bool) -> object {
    LET $settings = {
        fields: {
            project_id: { pipeline: [{ rule: "uuid" }], required: $create },
            organization_id: { pipeline: [{ rule: "uuid" }] },
            default_zone: { pipeline: [{ rule: "enum", options: { allowed: ["fr-par-1", "fr-par-2", "fr-par-3", "nl-ams-1", "nl-ams-2", "nl-ams-3", "pl-waw-1", "pl-waw-2", "pl-waw-3"], case_sensitive: true } }], default: IF $create { "fr-par-1" } ELSE { NONE } },
            default_region: { pipeline: [{ rule: "enum", options: { allowed: ["fr-par", "nl-ams", "pl-waw"], case_sensitive: true } }], default: IF $create { "fr-par" } ELSE { NONE } }
        },
        unknown_keys: "reject"
    };
    RETURN {
        account: { pipeline: [{ rule: "record", options: { expected_table: "infra_account" } }], required: !$create },
        key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: $create },
        name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: $create },
        provider: { pipeline: [{ rule: "enum", options: { allowed: ["scaleway"], case_sensitive: true } }], default: IF $create { "scaleway" } ELSE { NONE } },
        credentials_path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: false, max_length: 256 } }], required: $create },
        settings: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: $settings } }], required: $create },
        state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }] },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
    };
} COMMENT "Interne : champs contrôlés par fn::validation_object_execute pour la création ($create) ou la modification d'un compte";

-- ----------------------------------------------------------------------------
-- fn::infra__account_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__account_view($account: object) -> object {
    RETURN $account.{ id, key, name, provider, credentials_path, settings, state, last_test, test_requested_at, discovered_zones, created_at, updated_at };
} COMMENT "Interne : vue publique d'un compte (chemin du secret, jamais de valeur)";

-- ----------------------------------------------------------------------------
-- fn::infra_account_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_create($params: object) {
    IF $params.account IS NOT NONE { RETURN fn::infra__invalid($params, { account: [{ code: "CORE_VALIDATION_NOT_ALLOWED", details: {} }] }); };
    LET $report = fn::validation_object_execute($params, { fields: fn::infra__account_fields(true), unknown_keys: "reject" }, 40);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $id = type::record("infra_account", $p.key);
    IF record::exists($id) { RETURN fn::error_result("INFRA_ACCOUNT_EXISTS", $p.language, { account: <string> $id }); };
    LET $refusal = fn::infra__account_secret_refusal($p.credentials_path);
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal, $p.language, { path: $p.credentials_path }); };
    LET $created = (CREATE $id CONTENT {
        key: $p.key,
        name: $p.name,
        provider: $p.provider,
        credentials_path: $p.credentials_path,
        settings: $p.settings,
        state: "active",
        test_requested_at: time::now()
    });
    IF array::len($created) = 0 { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_account" }); };
    RETURN fn::result_ok(fn::infra__account_view($created[0]));
} COMMENT "Crée un compte d'hébergeur ({ key (snake_case, 64 caractères au plus), name, provider : scaleway, credentials_path (secret de l'installation sous infra/, valeur JSON { secret_key, access_key }), settings : { project_id (UUID), organization_id, default_zone (fr-par-1), default_region (fr-par) } }) : secret existant et gérable par l'appelant ; un essai est demandé (le worker lit les zones visibles). Droit infra.manage et secrets.installation.manage";

-- ----------------------------------------------------------------------------
-- fn::infra_account_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_update($params: object) {
    IF $params.key IS NOT NONE OR $params.provider IS NOT NONE {
        RETURN fn::infra__invalid($params, object::from_entries(array::map(array::filter(["key", "provider"], |$f| $params[$f] IS NOT NONE), |$f| [$f, [{ code: "CORE_VALIDATION_NOT_ALLOWED", details: {} }]])));
    };
    LET $report = fn::validation_object_execute($params, { fields: fn::infra__account_fields(false), unknown_keys: "reject" }, 40);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $current = (SELECT * FROM ONLY $p.account);
    IF $current == NONE { RETURN fn::error_result("INFRA_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    IF $p.credentials_path IS NOT NONE AND $p.credentials_path != $current.credentials_path {
        LET $refusal = fn::infra__account_secret_refusal($p.credentials_path);
        IF $refusal IS NOT NONE { RETURN fn::error_result($refusal, $p.language, { path: $p.credentials_path }); };
    };
    LET $changed_key = $p.credentials_path IS NOT NONE AND $p.credentials_path != $current.credentials_path;
    LET $updated = (UPDATE ONLY $current.id SET
        name = $p.name ?? name,
        credentials_path = $p.credentials_path ?? credentials_path,
        settings = IF $p.settings IS NONE { settings } ELSE { object::extend(settings, $p.settings) },
        state = $p.state ?? state,
        -- Nouvelle clé ou compte réactivé : nouvel essai
        test_requested_at = IF $changed_key OR ($p.state = "active" AND $current.state != "active") { time::now() } ELSE { test_requested_at });
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_account" }); };
    RETURN fn::result_ok(fn::infra__account_view($updated));
} COMMENT "Modifie un compte ({ account, name, credentials_path, settings (champs fournis remplacés), state : active ou disabled }) ; clé et fournisseur fixes. Nouvelle clé ou compte réactivé : un essai est demandé. Droit infra.manage (et secrets.installation.manage pour changer de secret)";

-- ----------------------------------------------------------------------------
-- fn::infra_account_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "infra_account" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $account = (SELECT * FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("INFRA_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    RETURN fn::result_ok(object::extend(fn::infra__account_view($account), {
        zones: count(SELECT id FROM infra_zone WHERE account = $account.id)
    }));
} COMMENT "Compte ({ account }), sans secret, avec le nombre de zones rattachées (zones). Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_account_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled", "failing"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM infra_account WHERE $p.state IS NONE OR state = $p.state ORDER BY key ASC);
    RETURN fn::result_ok({ items: array::map($rows, |$a| fn::infra__account_view($a)) });
} COMMENT "Comptes ({ state }), par clé : { items }, sans secret. Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_account_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "infra_account" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.account) { RETURN fn::error_result("INFRA_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    LET $zones = count(SELECT id FROM infra_zone WHERE account = $p.account);
    IF $zones > 0 { RETURN fn::error_result("INFRA_ACCOUNT_IN_USE", $p.language, { account: <string> $p.account, zones: $zones }); };
    LET $deleted = (DELETE $p.account RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_account" }); };
    RETURN fn::result_ok({ deleted: $p.account });
} COMMENT "Supprime un compte ({ account }) qui ne porte plus aucune zone (INFRA_ACCOUNT_IN_USE sinon) ; le secret du coffre-fort n'est pas touché. Droit infra.manage";

-- ----------------------------------------------------------------------------
-- fn::infra_account_test_request
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_test_request($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "infra_account" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.account) { RETURN fn::error_result("INFRA_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    LET $updated = (UPDATE ONLY $p.account SET test_requested_at = time::now());
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_account" }); };
    RETURN fn::result_ok(fn::infra__account_view($updated));
} COMMENT "Demande un essai du compte ({ account }) : le worker lit les zones visibles (discovered_zones) et note le résultat (last_test). Droit infra.manage";
