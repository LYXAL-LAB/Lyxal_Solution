-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/step_apply.surql
-- Fonction : fn::security_step_apply
--
-- Aiguillage du domaine security pour le moteur : les règles de masquage et
-- d'empreinte remplacent state.value ; les détections enregistrent leur
-- résultat comme constat (kind « finding ») ; permission_check enregistre sa
-- décision (kind « decision »). Une valeur NONE traverse les règles de
-- valeur sans effet. Passée en closure à fn::utils_engine_run.
--
-- Paramètres
--   $state : object
--   $step  : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : valeur d'un type inattendu pour la règle (chaîne, objet pour redact_object, tableau pour redact_array)
--   CORE_UNSUPPORTED_OPTION : règle absente du catalogue (étape non contrôlée par fn::utils_engine_pipeline)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_step_apply(
    $state: object,
    $step: object
) -> object {
    LET $current = $state.value;
    LET $options = $step.options;
    IF $step.rule = "permission_check" {
        RETURN fn::utils_engine_record($state, $step.rule, "decision",
            fn::security_permission_check($options.permissions, $options.resource, $options.action, $options.context));
    };
    IF $current IS NONE { RETURN $state; };
    LET $expected = IF $step.rule = "redact_object" { "object" } ELSE IF $step.rule = "redact_array" { "array" } ELSE { "string" };
    IF type::of($current) != $expected { THROW "CORE_INVALID_ARGUMENT"; };
    IF $step.rule IN ["detect_payload", "detect_sql_injection", "detect_xss", "detect_path_traversal", "detect_command_injection", "detect_header_injection", "detect_open_redirect", "detect_file_attack"] {
        RETURN fn::utils_engine_record($state, $step.rule, "finding",
        IF $step.rule = "detect_payload" { fn::security_detect_payload($current) }
        ELSE IF $step.rule = "detect_sql_injection" { fn::security_detect_sql_injection($current) }
        ELSE IF $step.rule = "detect_xss" { fn::security_detect_xss($current) }
        ELSE IF $step.rule = "detect_path_traversal" { fn::security_detect_path_traversal($current) }
        ELSE IF $step.rule = "detect_command_injection" { fn::security_detect_command_injection($current) }
        ELSE IF $step.rule = "detect_header_injection" { fn::security_detect_header_injection($current) }
        ELSE IF $step.rule = "detect_open_redirect" { fn::security_detect_open_redirect($current) }
        ELSE IF $step.rule = "detect_file_attack" { fn::security_detect_file_attack($current, $options.mime) }
        ELSE { THROW "CORE_UNSUPPORTED_OPTION" });
    };
    RETURN object::extend($state, { value:
        IF $step.rule = "redact_card" { fn::security_redact_card($current) }
        ELSE IF $step.rule = "redact_email" { fn::security_redact_email($current) }
        ELSE IF $step.rule = "redact_ip" { fn::security_redact_ip($current) }
        ELSE IF $step.rule = "redact_log" { fn::security_redact_log($current) }
        ELSE IF $step.rule = "redact_phone" { fn::security_redact_phone($current, $options.visible_end ?? 4) }
        ELSE IF $step.rule = "redact_object" { fn::security_redact_object($current, $options.sensitive_keys) }
        ELSE IF $step.rule = "redact_array" { fn::security_redact_array($current, $options.indexes) }
        ELSE IF $step.rule = "secret_mask" { fn::security_secret_mask($current, $options.visible_start ?? 0, $options.visible_end ?? 4, $options.mask ?? "*") }
        ELSE IF $step.rule = "scope" { fn::security_scope($current) }
        ELSE IF $step.rule = "hash_sha256" { fn::security_hash_sha256($current) }
        ELSE IF $step.rule = "hash_sha512" { fn::security_hash_sha512($current) }
        ELSE IF $step.rule = "hash_blake3" { fn::security_hash_blake3($current) }
        ELSE IF $step.rule = "hash_string" { fn::security_hash_string($current, $options.algorithm) }
        ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
    });
}
COMMENT "Aiguillage du domaine security pour le moteur : les règles de masquage et d'empreinte remplacent state.value ; les détections enregistrent leur résultat comme constat (kind « finding ») ; permission_check enregistre sa décision (kind « decision »). Une valeur NONE traverse les règles de valeur sans effet. Passée en closure à fn::utils_engine_run."
PERMISSIONS FULL;
