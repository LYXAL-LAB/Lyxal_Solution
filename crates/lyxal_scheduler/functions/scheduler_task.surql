-- ============================================================================
-- FONCTIONS : tâches déclarées par les modules
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Une tâche est un type d'action qu'un module sait exécuter. Elle est déclarée par le seed de
-- son module (session système) ; aucune fonction ne la crée. Les gardes valent aussi pour une
-- écriture directe dans la table.

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_create_refusal (interne, garde de déclaration)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_create_refusal($after: object) -> option<string> {
    IF !fn::auth_session_valid({}).system { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    LET $name = record::id($after.id);
    LET $checked = fn::validation_lyxal_event_name($name, 2, 2);
    IF !$checked.valid OR $checked.value != $name { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    LET $short = string::split($name, ".")[0];
    IF $after.module != "lyxal_" + $short { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    -- Module déclarant installé : release du runtime en cours d'installation (seed du module) ou
    -- installée (contrats publics fn::runtime_release_list et fn::runtime_module_list, Y3)
    LET $releases = fn::runtime_release_list({ module_id: $after.module });
    IF !$releases.ok OR !array::any($releases.data, |$r| $r.status IN ["Installing", "Installed", "Active"]) { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    -- Cible du même module seulement : nom complet du module suivi d'un séparateur
    LET $separator = IF $after.executor = "function" { "_" } ELSE { "." };
    LET $as_function = fn::validation_lyxal_function_name($after.target, false, 128);
    LET $as_event = fn::validation_lyxal_event_name($after.target, 2, IF $after.executor = "handler" { 2 } ELSE { 5 });
    LET $target = IF $after.executor = "function" {
        $as_function.valid AND $as_function.value == $after.target AND string::starts_with($after.target, $short + $separator)
    } ELSE {
        $as_event.valid AND $as_event.value == $after.target AND string::starts_with($after.target, $short + $separator)
    };
    IF !$target { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    -- Un module dont le nom est le début du nom d'un autre module connu du runtime ne vise jamais
    -- les fonctions ou les événements de cet autre module (lyxal_pipeline ↛ pipeline_ingestion_*)
    LET $modules = fn::runtime_module_list({});
    IF !$modules.ok { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    LET $foreign = array::any($modules.data.module_id, |$other| $other != $after.module
        AND string::starts_with($other, $after.module + "_")
        AND string::starts_with($after.target, string::slice($other, 6) + $separator));
    IF $foreign { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    -- Un handler est inscrit et retrouvé par le nom de sa tâche : sa cible est ce nom
    IF $after.executor = "handler" AND $after.target != $name { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    IF $after.permission IS NOT NONE AND !record::exists(type::record("auth_permission", $after.permission)) { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    LET $retry = fn::validation_retry_policy($after.retry, 10, 24h);
    IF !$retry.valid OR $retry.value != $after.retry { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    IF !record::exists($after.queue) { RETURN "SCHEDULER_QUEUE_NOT_FOUND"; };
    -- Schéma des arguments : contrôlé par le moteur du Core (CORE_INVALID_ARGUMENT s'il est faux)
    IF $after.args_schema IS NOT NONE { fn::utils_engine_schema($after.args_schema, fn::validation_step_catalog(), 100); };
    RETURN NONE;
} COMMENT "Interne : refus d'une déclaration de tâche ($after) : session système seulement ; identifiant ⟨module.action⟩ en minuscules, module = lyxal_<module> ; module installé (release du runtime Installing, Installed ou Active) ; cible du même module (handler : le nom même de la tâche, fonction <module>_<action>, événement <module>.…), jamais celle d'un autre module connu du runtime dont le nom commence par celui du module (Y3) ; permission existante ; politique de tentatives normalisée (10 tentatives, 24 h au plus) ; file existante ; schéma des arguments valide pour le moteur du Core. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_update_refusal (interne, garde de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_update_refusal($before: object, $after: object) -> option<string> {
    IF !fn::auth_session_valid({}).system { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    LET $frozen = ["module", "description", "executor", "target", "permission", "args_schema", "queue", "priority", "retry", "timeout", "unique_for", "scope", "created_at"];
    IF array::any($frozen, |$f| $before[$f] != $after[$f]) { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    RETURN NONE;
} COMMENT "Interne : refus d'une modification de tâche ($before, $after) : session système seulement, et seul l'état (active, disabled) change. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_record (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_record($name: string) -> record<scheduler_task> {
    RETURN type::record("scheduler_task", $name);
} COMMENT "Interne : enregistrement d'une tâche d'après son nom (<module>.<action>)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_args_check (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_args_check($task: object, $args: any, $tenant: option<record<auth_organization>>) -> object {
    LET $value = $args ?? {};
    IF !type::is_object($value) { RETURN { valid: false, value: NONE, details: { args: [{ code: "CORE_VALIDATION_TYPE" }] } }; };
    LET $report = IF $task.args_schema IS NONE {
        IF object::is_empty($value) { { valid: true, value: {}, by_field: {} } } ELSE { { valid: false, value: NONE, by_field: { args: [{ code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "no_arguments" } }] } } }
    } ELSE {
        fn::validation_object_execute($value, $task.args_schema, 100)
    };
    IF !$report.valid { RETURN { valid: false, value: NONE, details: $report.by_field }; };
    LET $max = fn::scheduler_settings_effective({ tenant: $tenant }).max_args_bytes;
    LET $size = bytes::len(<bytes> <string> $report.value);
    IF $size > $max { RETURN { valid: false, value: NONE, details: { args: [{ code: "CORE_VALIDATION_TOO_LARGE", details: { max_bytes: $max, bytes: $size } }] } }; };
    RETURN { valid: true, value: $report.value, details: {} };
} COMMENT "Interne : contrôle les arguments d'une planification ou d'une exécution ($task, $args, $tenant) : objet conforme au schéma de la tâche (fn::validation_object_execute ; sans schéma : objet vide), taille au plus max_args_bytes des réglages. { valid, value (arguments normalisés), details (par champ) }";

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_usable (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_usable($task: option<object>, $tenant: option<record<auth_organization>>) -> option<string> {
    IF $task == NONE { RETURN "SCHEDULER_TASK_NOT_FOUND"; };
    IF $task.state != "active" { RETURN "SCHEDULER_TASK_DISABLED"; };
    -- Portée : une tâche d'organisation se planifie pour une organisation, une tâche d'installation pour l'installation
    IF ($task.scope = "organization") != ($tenant IS NOT NONE) { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    RETURN NONE;
} COMMENT "Interne : refus d'utiliser une tâche ($task lue, $tenant) : introuvable ou illisible, désactivée, ou portée différente (tâche d'organisation sans organisation, tâche d'installation pour une organisation). NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            module: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 64 } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "catalog" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $all = (SELECT * FROM scheduler_task
        WHERE ($p.module IS NONE OR module = $p.module) AND ($p.state IS NONE OR state = $p.state)
        ORDER BY id ASC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Tâches déclarées ({ module, state, limit (500 au plus), start }) : { items, total }. Droit : lecture ou écriture dans l'organisation active, installation ou moteur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            task: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "catalog" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $task = (SELECT * FROM ONLY fn::scheduler_task_record($p.task));
    IF $task == NONE { RETURN fn::error_result("SCHEDULER_TASK_NOT_FOUND", $p.language, { task: $p.task }); };
    RETURN fn::result_ok($task);
} COMMENT "Tâche d'après son nom ({ task : <module>.<action> }). Droit : lecture ou écriture dans l'organisation active, installation ou moteur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_task_set_state
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_task_set_state($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            task: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $id = fn::scheduler_task_record($p.task);
    IF !record::exists($id) { RETURN fn::error_result("SCHEDULER_TASK_NOT_FOUND", $p.language, { task: $p.task }); };
    LET $updated = (UPDATE ONLY $id SET state = $p.state);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_task" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Active ou désactive une tâche ({ task, state : active, disabled }) ; une tâche désactivée ne reçoit ni planification ni exécution, et ses exécutions en attente ne sont pas réservées. Droit : session système seulement";
