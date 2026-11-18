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
    RETURN object::extend($state, { value:
        IF $step.rule = "absolute_url" { fn::sanitize_absolute_url($current, $options.default_scheme ?? "https") }
        ELSE IF $step.rule = "alphanumeric_upper" { fn::sanitize_alphanumeric_upper($current) }
        ELSE IF $step.rule = "array" { fn::sanitize_array($current) }
        ELSE IF $step.rule = "array_compact" { fn::sanitize_array_compact($current, $options.remove_null ?? true, $options.remove_blank_strings ?? true) }
        ELSE IF $step.rule = "array_flatten" { fn::sanitize_array_flatten($current) }
        ELSE IF $step.rule = "array_limit" { fn::sanitize_array_limit($current, $options.limit) }
        ELSE IF $step.rule = "array_numbers" { fn::sanitize_array_numbers($current) }
        ELSE IF $step.rule = "array_objects" { fn::sanitize_array_objects($current) }
        ELSE IF $step.rule = "array_sort" { fn::sanitize_array_sort($current, $options.direction ?? "asc") }
        ELSE IF $step.rule = "array_strings" { fn::sanitize_array_strings($current, $options.trim ?? true, $options.lowercase ?? false) }
        ELSE IF $step.rule = "array_unique" { fn::sanitize_array_unique($current) }
        ELSE IF $step.rule = "ascii" { fn::sanitize_ascii($current, $options.replacement ?? "") }
        ELSE IF $step.rule = "calendar" { fn::sanitize_calendar($current, $options.granularity) }
        ELSE IF $step.rule = "capitalize" { fn::sanitize_capitalize($current) }
        ELSE IF $step.rule = "clamp" { fn::sanitize_clamp($current, $options.min, $options.max) }
        ELSE IF $step.rule = "collapse_whitespace" { fn::sanitize_collapse_whitespace($current) }
        ELSE IF $step.rule = "country_code" { fn::sanitize_country_code($current) }
        ELSE IF $step.rule = "credit_card_mask" { fn::sanitize_credit_card_mask($current, $options.visible_digits ?? 4) }
        ELSE IF $step.rule = "currency" { fn::sanitize_currency($current, $options.decimal_separator ?? ".") }
        ELSE IF $step.rule = "date" { fn::sanitize_date($current) }
        ELSE IF $step.rule = "datetime" { fn::sanitize_datetime($current, $options.precision) }
        ELSE IF $step.rule = "decimal" { fn::sanitize_decimal($current) }
        ELSE IF $step.rule = "default_values" { fn::sanitize_default_values($current, $options.defaults) }
        ELSE IF $step.rule = "domain" { fn::sanitize_domain($current) }
        ELSE IF $step.rule = "duration" { fn::sanitize_duration($current, $options.precision) }
        ELSE IF $step.rule = "e164" { fn::sanitize_e164($current, $options.default_country_code ?? NONE) }
        ELSE IF $step.rule = "email" { fn::sanitize_email($current) }
        ELSE IF $step.rule = "email_domain" { fn::sanitize_email_domain($current) }
        ELSE IF $step.rule = "email_local" { fn::sanitize_email_local($current) }
        ELSE IF $step.rule = "float" { fn::sanitize_float($current, $options.decimal_separator ?? ".") }
        ELSE IF $step.rule = "fragment" { fn::sanitize_fragment($current) }
        ELSE IF $step.rule = "hostname" { fn::sanitize_hostname($current) }
        ELSE IF $step.rule = "html" { fn::sanitize_html($current) }
        ELSE IF $step.rule = "html_entities" { fn::sanitize_html_entities($current) }
        ELSE IF $step.rule = "integer" { fn::sanitize_integer($current) }
        ELSE IF $step.rule = "lowercase" { fn::sanitize_lowercase($current) }
        ELSE IF $step.rule = "markdown" { fn::sanitize_markdown($current) }
        ELSE IF $step.rule = "markdown_code" { fn::sanitize_markdown_code($current) }
        ELSE IF $step.rule = "markdown_headers" { fn::sanitize_markdown_headers($current) }
        ELSE IF $step.rule = "markdown_images" { fn::sanitize_markdown_images($current) }
        ELSE IF $step.rule = "markdown_links" { fn::sanitize_markdown_links($current) }
        ELSE IF $step.rule = "markdown_lists" { fn::sanitize_markdown_lists($current) }
        ELSE IF $step.rule = "markdown_quotes" { fn::sanitize_markdown_quotes($current) }
        ELSE IF $step.rule = "markdown_safe" { fn::sanitize_markdown_safe($current) }
        ELSE IF $step.rule = "markdown_tables" { fn::sanitize_markdown_tables($current) }
        ELSE IF $step.rule = "negative" { fn::sanitize_negative($current) }
        ELSE IF $step.rule = "normalize_unicode" { fn::sanitize_normalize_unicode($current, $options.collapse_whitespace ?? false) }
        ELSE IF $step.rule = "null_to_none" { fn::sanitize_null_to_none($current) }
        ELSE IF $step.rule = "object_or_empty" { fn::sanitize_object($current) }
        ELSE IF $step.rule = "object_clone" { fn::sanitize_object_clone($current) }
        ELSE IF $step.rule = "object_merge" { fn::sanitize_object_merge($current, $options.override) }
        ELSE IF $step.rule = "object_normalize" { fn::sanitize_object_normalize($current, $options.allowed_keys ?? NONE, $options.defaults ?? NONE, $options.remove_empty ?? false) }
        ELSE IF $step.rule = "percentage" { fn::sanitize_percentage($current) }
        ELSE IF $step.rule = "phone" { fn::sanitize_phone($current) }
        ELSE IF $step.rule = "port" { fn::sanitize_port($current) }
        ELSE IF $step.rule = "positive" { fn::sanitize_positive($current) }
        ELSE IF $step.rule = "postal_code" { fn::sanitize_postal_code($current) }
        ELSE IF $step.rule = "precision" { fn::sanitize_precision($current, $options.precision) }
        ELSE IF $step.rule = "query" { fn::sanitize_query($current) }
        ELSE IF $step.rule = "relative_url" { fn::sanitize_relative_url($current) }
        ELSE IF $step.rule = "remove_control_chars" { fn::sanitize_remove_control_chars($current, $options.preserve_layout ?? false) }
        ELSE IF $step.rule = "remove_empty" { fn::sanitize_remove_empty($current, $options.remove_null ?? true, $options.remove_blank_strings ?? true, $options.remove_empty_arrays ?? false, $options.remove_empty_objects ?? false) }
        ELSE IF $step.rule = "remove_multiple_spaces" { fn::sanitize_remove_multiple_spaces($current) }
        ELSE IF $step.rule = "remove_newlines" { fn::sanitize_remove_newlines($current, $options.replacement ?? " ") }
        ELSE IF $step.rule = "remove_tabs" { fn::sanitize_remove_tabs($current, $options.replacement ?? " ") }
        ELSE IF $step.rule = "remove_tracking" { fn::sanitize_remove_tracking($current) }
        ELSE IF $step.rule = "remove_unknown_keys" { fn::sanitize_remove_unknown_keys($current, $options.allowed_keys) }
        ELSE IF $step.rule = "replace_chars" { fn::sanitize_replace_chars($current, $options.remove ?? [], $options.replace ?? []) }
        ELSE IF $step.rule = "rfc3339" { fn::sanitize_rfc3339($current) }
        ELSE IF $step.rule = "round" { fn::sanitize_round($current, $options.precision) }
        ELSE IF $step.rule = "safe_extension" { fn::sanitize_safe_extension($current) }
        ELSE IF $step.rule = "safe_filename" { fn::sanitize_safe_filename($current, $options.replacement ?? "_") }
        ELSE IF $step.rule = "safe_identifier" { fn::sanitize_safe_identifier($current) }
        ELSE IF $step.rule = "safe_path" { fn::sanitize_safe_path($current) }
        ELSE IF $step.rule = "safe_redirect" { fn::sanitize_safe_redirect($current, $options.fallback ?? "/") }
        ELSE IF $step.rule = "schedule" { fn::sanitize_schedule($current, $options.duration, $options.round_to) }
        ELSE IF $step.rule = "slug" { fn::sanitize_slug($current, $options.separator ?? "-") }
        ELSE IF $step.rule = "strip_comments" { fn::sanitize_strip_comments($current) }
        ELSE IF $step.rule = "strip_dangerous_attributes" { fn::sanitize_strip_dangerous_attributes($current) }
        ELSE IF $step.rule = "strip_event_handlers" { fn::sanitize_strip_event_handlers($current) }
        ELSE IF $step.rule = "strip_html" { fn::sanitize_strip_html($current) }
        ELSE IF $step.rule = "strip_iframes" { fn::sanitize_strip_iframes($current) }
        ELSE IF $step.rule = "strip_scripts" { fn::sanitize_strip_scripts($current) }
        ELSE IF $step.rule = "strip_styles" { fn::sanitize_strip_styles($current) }
        ELSE IF $step.rule = "strip_svg" { fn::sanitize_strip_svg($current) }
        ELSE IF $step.rule = "timestamp" { fn::sanitize_timestamp($current, $options.unit ?? "seconds") }
        ELSE IF $step.rule = "timezone" { fn::sanitize_timezone($current) }
        ELSE IF $step.rule = "title_case" { fn::sanitize_title_case($current) }
        ELSE IF $step.rule = "trim" { fn::sanitize_trim($current) }
        ELSE IF $step.rule = "trim_left" { fn::sanitize_trim_left($current) }
        ELSE IF $step.rule = "trim_right" { fn::sanitize_trim_right($current) }
        ELSE IF $step.rule = "uppercase" { fn::sanitize_uppercase($current) }
        ELSE IF $step.rule = "url" { fn::sanitize_url($current) }
        ELSE IF $step.rule = "default" { IF $current IS NONE { $options.value } ELSE { $current } }
        ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
    });
}
COMMENT "Aiguillage du domaine sanitize pour le moteur : applique l'étape à state.value en appelant la fonction de valeurs fn::sanitize_<règle> avec ses options (valeurs par défaut du catalogue). Passée en closure à fn::utils_engine_run."
PERMISSIONS FULL;
