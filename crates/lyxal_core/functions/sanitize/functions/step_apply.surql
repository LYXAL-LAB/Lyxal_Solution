-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/step_apply.surql
-- Fonction : fn::sanitize_step_apply
--
-- Aiguillage du domaine sanitize pour le moteur : applique l'étape à
-- state.value en appelant la fonction de valeurs fn::sanitize_<règle> avec
-- ses options (valeurs par défaut du catalogue). Passée en closure à
-- fn::utils_engine_run.
--
-- Paramètres
--   $state : object
--   $step  : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions sanitize)
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : règle absente du catalogue (étape non contrôlée par fn::utils_engine_pipeline)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::sanitize_step_apply(
    $state: object,
    $step: object
) -> object {
    LET $current = $state.value;
    LET $options = $step.options;
    -- Aiguillage en deux niveaux (initiale, puis règle) : une quinzaine de comparaisons au plus
    LET $rule = $step.rule;
    LET $cleaned =
        IF $rule < "c" {
            IF $rule = "absolute_url" { fn::sanitize_absolute_url($current, $options.default_scheme ?? "https") }
            ELSE IF $rule = "alphanumeric_upper" { fn::sanitize_alphanumeric_upper($current) }
            ELSE IF $rule = "array" { fn::sanitize_array($current) }
            ELSE IF $rule = "array_compact" { fn::sanitize_array_compact($current, $options.remove_null ?? true, $options.remove_blank_strings ?? true) }
            ELSE IF $rule = "array_flatten" { fn::sanitize_array_flatten($current) }
            ELSE IF $rule = "array_limit" { fn::sanitize_array_limit($current, $options.limit) }
            ELSE IF $rule = "array_numbers" { fn::sanitize_array_numbers($current) }
            ELSE IF $rule = "array_objects" { fn::sanitize_array_objects($current) }
            ELSE IF $rule = "array_sort" { fn::sanitize_array_sort($current, $options.direction ?? "asc") }
            ELSE IF $rule = "array_strings" { fn::sanitize_array_strings($current, $options.trim ?? true, $options.lowercase ?? false) }
            ELSE IF $rule = "array_unique" { fn::sanitize_array_unique($current) }
            ELSE IF $rule = "ascii" { fn::sanitize_ascii($current, $options.replacement ?? "") }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "d" {
            IF $rule = "calendar" { fn::sanitize_calendar($current, $options.granularity) }
            ELSE IF $rule = "capitalize" { fn::sanitize_capitalize($current) }
            ELSE IF $rule = "clamp" { fn::sanitize_clamp($current, $options.min, $options.max) }
            ELSE IF $rule = "collapse_whitespace" { fn::sanitize_collapse_whitespace($current) }
            ELSE IF $rule = "country_code" { fn::sanitize_country_code($current) }
            ELSE IF $rule = "credit_card_mask" { fn::sanitize_credit_card_mask($current, $options.visible_digits ?? 4) }
            ELSE IF $rule = "currency" { fn::sanitize_currency($current, $options.decimal_separator ?? ".") }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "f" {
            IF $rule = "date" { fn::sanitize_date($current) }
            ELSE IF $rule = "datetime" { fn::sanitize_datetime($current, $options.precision) }
            ELSE IF $rule = "decimal" { fn::sanitize_decimal($current) }
            ELSE IF $rule = "default" { IF $current IS NONE { $options.value } ELSE { $current } }
            ELSE IF $rule = "default_values" { fn::sanitize_default_values($current, $options.defaults) }
            ELSE IF $rule = "domain" { fn::sanitize_domain($current) }
            ELSE IF $rule = "duration" { fn::sanitize_duration($current, $options.precision) }
            ELSE IF $rule = "e164" { fn::sanitize_e164($current, $options.default_country_code ?? NONE) }
            ELSE IF $rule = "email" { fn::sanitize_email($current) }
            ELSE IF $rule = "email_domain" { fn::sanitize_email_domain($current) }
            ELSE IF $rule = "email_local" { fn::sanitize_email_local($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "m" {
            IF $rule = "float" { fn::sanitize_float($current, $options.decimal_separator ?? ".") }
            ELSE IF $rule = "fragment" { fn::sanitize_fragment($current) }
            ELSE IF $rule = "hostname" { fn::sanitize_hostname($current) }
            ELSE IF $rule = "html" { fn::sanitize_html($current) }
            ELSE IF $rule = "html_entities" { fn::sanitize_html_entities($current) }
            ELSE IF $rule = "integer" { fn::sanitize_integer($current) }
            ELSE IF $rule = "lowercase" { fn::sanitize_lowercase($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "o" {
            IF $rule = "markdown" { fn::sanitize_markdown($current) }
            ELSE IF $rule = "markdown_code" { fn::sanitize_markdown_code($current) }
            ELSE IF $rule = "markdown_headers" { fn::sanitize_markdown_headers($current) }
            ELSE IF $rule = "markdown_images" { fn::sanitize_markdown_images($current) }
            ELSE IF $rule = "markdown_links" { fn::sanitize_markdown_links($current) }
            ELSE IF $rule = "markdown_lists" { fn::sanitize_markdown_lists($current) }
            ELSE IF $rule = "markdown_quotes" { fn::sanitize_markdown_quotes($current) }
            ELSE IF $rule = "markdown_safe" { fn::sanitize_markdown_safe($current) }
            ELSE IF $rule = "markdown_tables" { fn::sanitize_markdown_tables($current) }
            ELSE IF $rule = "negative" { fn::sanitize_negative($current) }
            ELSE IF $rule = "normalize_unicode" { fn::sanitize_normalize_unicode($current, $options.collapse_whitespace ?? false) }
            ELSE IF $rule = "null_to_none" { fn::sanitize_null_to_none($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "r" {
            IF $rule = "object_clone" { fn::sanitize_object_clone($current) }
            ELSE IF $rule = "object_merge" { fn::sanitize_object_merge($current, $options.override) }
            ELSE IF $rule = "object_normalize" { fn::sanitize_object_normalize($current, $options.allowed_keys ?? NONE, $options.defaults ?? NONE, $options.remove_empty ?? false) }
            ELSE IF $rule = "object_or_empty" { fn::sanitize_object($current) }
            ELSE IF $rule = "percentage" { fn::sanitize_percentage($current) }
            ELSE IF $rule = "phone" { fn::sanitize_phone($current) }
            ELSE IF $rule = "port" { fn::sanitize_port($current) }
            ELSE IF $rule = "positive" { fn::sanitize_positive($current) }
            ELSE IF $rule = "postal_code" { fn::sanitize_postal_code($current) }
            ELSE IF $rule = "precision" { fn::sanitize_precision($current, $options.precision) }
            ELSE IF $rule = "query" { fn::sanitize_query($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "s" {
            IF $rule = "relative_url" { fn::sanitize_relative_url($current) }
            ELSE IF $rule = "remove_control_chars" { fn::sanitize_remove_control_chars($current, $options.preserve_layout ?? false) }
            ELSE IF $rule = "remove_empty" { fn::sanitize_remove_empty($current, $options.remove_null ?? true, $options.remove_blank_strings ?? true, $options.remove_empty_arrays ?? false, $options.remove_empty_objects ?? false) }
            ELSE IF $rule = "remove_multiple_spaces" { fn::sanitize_remove_multiple_spaces($current) }
            ELSE IF $rule = "remove_newlines" { fn::sanitize_remove_newlines($current, $options.replacement ?? " ") }
            ELSE IF $rule = "remove_tabs" { fn::sanitize_remove_tabs($current, $options.replacement ?? " ") }
            ELSE IF $rule = "remove_tracking" { fn::sanitize_remove_tracking($current) }
            ELSE IF $rule = "remove_unknown_keys" { fn::sanitize_remove_unknown_keys($current, $options.allowed_keys) }
            ELSE IF $rule = "replace_chars" { fn::sanitize_replace_chars($current, $options.remove ?? [], $options.replace ?? []) }
            ELSE IF $rule = "rfc3339" { fn::sanitize_rfc3339($current) }
            ELSE IF $rule = "round" { fn::sanitize_round($current, $options.precision) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "t" {
            IF $rule = "safe_extension" { fn::sanitize_safe_extension($current) }
            ELSE IF $rule = "safe_filename" { fn::sanitize_safe_filename($current, $options.replacement ?? "_") }
            ELSE IF $rule = "safe_identifier" { fn::sanitize_safe_identifier($current) }
            ELSE IF $rule = "safe_path" { fn::sanitize_safe_path($current) }
            ELSE IF $rule = "safe_redirect" { fn::sanitize_safe_redirect($current, $options.fallback ?? "/") }
            ELSE IF $rule = "schedule" { fn::sanitize_schedule($current, $options.duration, $options.round_to) }
            ELSE IF $rule = "slug" { fn::sanitize_slug($current, $options.separator ?? "-") }
            ELSE IF $rule = "strip_comments" { fn::sanitize_strip_comments($current) }
            ELSE IF $rule = "strip_dangerous_attributes" { fn::sanitize_strip_dangerous_attributes($current) }
            ELSE IF $rule = "strip_event_handlers" { fn::sanitize_strip_event_handlers($current) }
            ELSE IF $rule = "strip_html" { fn::sanitize_strip_html($current) }
            ELSE IF $rule = "strip_iframes" { fn::sanitize_strip_iframes($current) }
            ELSE IF $rule = "strip_scripts" { fn::sanitize_strip_scripts($current) }
            ELSE IF $rule = "strip_styles" { fn::sanitize_strip_styles($current) }
            ELSE IF $rule = "strip_svg" { fn::sanitize_strip_svg($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE {
            IF $rule = "timestamp" { fn::sanitize_timestamp($current, $options.unit ?? "seconds") }
            ELSE IF $rule = "timezone" { fn::sanitize_timezone($current) }
            ELSE IF $rule = "title_case" { fn::sanitize_title_case($current) }
            ELSE IF $rule = "trim" { fn::sanitize_trim($current) }
            ELSE IF $rule = "trim_left" { fn::sanitize_trim_left($current) }
            ELSE IF $rule = "trim_right" { fn::sanitize_trim_right($current) }
            ELSE IF $rule = "uppercase" { fn::sanitize_uppercase($current) }
            ELSE IF $rule = "url" { fn::sanitize_url($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        };
    RETURN object::extend($state, { value: $cleaned });
}
COMMENT "Aiguillage du domaine sanitize pour le moteur : applique l'étape à state.value en appelant la fonction de valeurs fn::sanitize_<règle> avec ses options (valeurs par défaut du catalogue). Passée en closure à fn::utils_engine_run."
PERMISSIONS FULL;
