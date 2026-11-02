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
    LET $value = $state.value;
    LET $options = $step.options;
    RETURN object::extend($state, { value:
        IF $step.rule = "absolute_url" { fn::sanitize_absolute_url($value, $options.default_scheme ?? "https") }
        ELSE IF $step.rule = "alphanumeric_upper" { fn::sanitize_alphanumeric_upper($value) }
        ELSE IF $step.rule = "array" { fn::sanitize_array($value) }
        ELSE IF $step.rule = "array_compact" { fn::sanitize_array_compact($value, $options.remove_null ?? true, $options.remove_blank_strings ?? true) }
        ELSE IF $step.rule = "array_flatten" { fn::sanitize_array_flatten($value) }
        ELSE IF $step.rule = "array_limit" { fn::sanitize_array_limit($value, $options.limit) }
        ELSE IF $step.rule = "array_numbers" { fn::sanitize_array_numbers($value) }
        ELSE IF $step.rule = "array_objects" { fn::sanitize_array_objects($value) }
        ELSE IF $step.rule = "array_sort" { fn::sanitize_array_sort($value, $options.direction ?? "asc") }
        ELSE IF $step.rule = "array_strings" { fn::sanitize_array_strings($value, $options.trim ?? true, $options.lowercase ?? false) }
        ELSE IF $step.rule = "array_unique" { fn::sanitize_array_unique($value) }
        ELSE IF $step.rule = "ascii" { fn::sanitize_ascii($value, $options.replacement ?? "") }
        ELSE IF $step.rule = "calendar" { fn::sanitize_calendar($value, $options.granularity) }
        ELSE IF $step.rule = "capitalize" { fn::sanitize_capitalize($value) }
        ELSE IF $step.rule = "clamp" { fn::sanitize_clamp($value, $options.min, $options.max) }
        ELSE IF $step.rule = "collapse_whitespace" { fn::sanitize_collapse_whitespace($value) }
        ELSE IF $step.rule = "country_code" { fn::sanitize_country_code($value) }
        ELSE IF $step.rule = "credit_card_mask" { fn::sanitize_credit_card_mask($value, $options.visible_digits ?? 4) }
        ELSE IF $step.rule = "currency" { fn::sanitize_currency($value, $options.decimal_separator ?? ".") }
        ELSE IF $step.rule = "date" { fn::sanitize_date($value) }
        ELSE IF $step.rule = "datetime" { fn::sanitize_datetime($value, $options.precision) }
        ELSE IF $step.rule = "decimal" { fn::sanitize_decimal($value) }
        ELSE IF $step.rule = "default_values" { fn::sanitize_default_values($value, $options.defaults) }
        ELSE IF $step.rule = "domain" { fn::sanitize_domain($value) }
        ELSE IF $step.rule = "duration" { fn::sanitize_duration($value, $options.precision) }
        ELSE IF $step.rule = "e164" { fn::sanitize_e164($value, $options.default_country_code ?? NONE) }
        ELSE IF $step.rule = "email" { fn::sanitize_email($value) }
        ELSE IF $step.rule = "email_domain" { fn::sanitize_email_domain($value) }
        ELSE IF $step.rule = "email_local" { fn::sanitize_email_local($value) }
        ELSE IF $step.rule = "float" { fn::sanitize_float($value, $options.decimal_separator ?? ".") }
        ELSE IF $step.rule = "fragment" { fn::sanitize_fragment($value) }
        ELSE IF $step.rule = "hostname" { fn::sanitize_hostname($value) }
        ELSE IF $step.rule = "html" { fn::sanitize_html($value) }
        ELSE IF $step.rule = "html_entities" { fn::sanitize_html_entities($value) }
        ELSE IF $step.rule = "integer" { fn::sanitize_integer($value) }
        ELSE IF $step.rule = "lowercase" { fn::sanitize_lowercase($value) }
        ELSE IF $step.rule = "markdown" { fn::sanitize_markdown($value) }
        ELSE IF $step.rule = "markdown_code" { fn::sanitize_markdown_code($value) }
        ELSE IF $step.rule = "markdown_headers" { fn::sanitize_markdown_headers($value) }
        ELSE IF $step.rule = "markdown_images" { fn::sanitize_markdown_images($value) }
        ELSE IF $step.rule = "markdown_links" { fn::sanitize_markdown_links($value) }
        ELSE IF $step.rule = "markdown_lists" { fn::sanitize_markdown_lists($value) }
        ELSE IF $step.rule = "markdown_quotes" { fn::sanitize_markdown_quotes($value) }
        ELSE IF $step.rule = "markdown_safe" { fn::sanitize_markdown_safe($value) }
        ELSE IF $step.rule = "markdown_tables" { fn::sanitize_markdown_tables($value) }
        ELSE IF $step.rule = "negative" { fn::sanitize_negative($value) }
        ELSE IF $step.rule = "normalize_unicode" { fn::sanitize_normalize_unicode($value, $options.collapse_whitespace ?? false) }
        ELSE IF $step.rule = "null_to_none" { fn::sanitize_null_to_none($value) }
        ELSE IF $step.rule = "object_or_empty" { fn::sanitize_object($value) }
        ELSE IF $step.rule = "object_clone" { fn::sanitize_object_clone($value) }
        ELSE IF $step.rule = "object_merge" { fn::sanitize_object_merge($value, $options.override) }
        ELSE IF $step.rule = "object_normalize" { fn::sanitize_object_normalize($value, $options.allowed_keys ?? NONE, $options.defaults ?? NONE, $options.remove_empty ?? false) }
        ELSE IF $step.rule = "percentage" { fn::sanitize_percentage($value) }
        ELSE IF $step.rule = "phone" { fn::sanitize_phone($value) }
        ELSE IF $step.rule = "port" { fn::sanitize_port($value) }
        ELSE IF $step.rule = "positive" { fn::sanitize_positive($value) }
        ELSE IF $step.rule = "postal_code" { fn::sanitize_postal_code($value) }
        ELSE IF $step.rule = "precision" { fn::sanitize_precision($value, $options.precision) }
        ELSE IF $step.rule = "query" { fn::sanitize_query($value) }
        ELSE IF $step.rule = "relative_url" { fn::sanitize_relative_url($value) }
        ELSE IF $step.rule = "remove_control_chars" { fn::sanitize_remove_control_chars($value, $options.preserve_layout ?? false) }
        ELSE IF $step.rule = "remove_empty" { fn::sanitize_remove_empty($value, $options.remove_null ?? true, $options.remove_blank_strings ?? true, $options.remove_empty_arrays ?? false, $options.remove_empty_objects ?? false) }
        ELSE IF $step.rule = "remove_multiple_spaces" { fn::sanitize_remove_multiple_spaces($value) }
        ELSE IF $step.rule = "remove_newlines" { fn::sanitize_remove_newlines($value, $options.replacement ?? " ") }
        ELSE IF $step.rule = "remove_tabs" { fn::sanitize_remove_tabs($value, $options.replacement ?? " ") }
        ELSE IF $step.rule = "remove_tracking" { fn::sanitize_remove_tracking($value) }
        ELSE IF $step.rule = "remove_unknown_keys" { fn::sanitize_remove_unknown_keys($value, $options.allowed_keys) }
        ELSE IF $step.rule = "rfc3339" { fn::sanitize_rfc3339($value) }
        ELSE IF $step.rule = "round" { fn::sanitize_round($value, $options.precision) }
        ELSE IF $step.rule = "safe_extension" { fn::sanitize_safe_extension($value) }
        ELSE IF $step.rule = "safe_filename" { fn::sanitize_safe_filename($value, $options.replacement ?? "_") }
        ELSE IF $step.rule = "safe_identifier" { fn::sanitize_safe_identifier($value) }
        ELSE IF $step.rule = "safe_path" { fn::sanitize_safe_path($value) }
        ELSE IF $step.rule = "safe_redirect" { fn::sanitize_safe_redirect($value, $options.fallback ?? "/") }
        ELSE IF $step.rule = "schedule" { fn::sanitize_schedule($value, $options.duration, $options.round_to) }
        ELSE IF $step.rule = "slug" { fn::sanitize_slug($value, $options.separator ?? "-") }
        ELSE IF $step.rule = "strip_comments" { fn::sanitize_strip_comments($value) }
        ELSE IF $step.rule = "strip_dangerous_attributes" { fn::sanitize_strip_dangerous_attributes($value) }
        ELSE IF $step.rule = "strip_event_handlers" { fn::sanitize_strip_event_handlers($value) }
        ELSE IF $step.rule = "strip_html" { fn::sanitize_strip_html($value) }
        ELSE IF $step.rule = "strip_iframes" { fn::sanitize_strip_iframes($value) }
        ELSE IF $step.rule = "strip_scripts" { fn::sanitize_strip_scripts($value) }
        ELSE IF $step.rule = "strip_styles" { fn::sanitize_strip_styles($value) }
        ELSE IF $step.rule = "strip_svg" { fn::sanitize_strip_svg($value) }
        ELSE IF $step.rule = "timestamp" { fn::sanitize_timestamp($value, $options.unit ?? "seconds") }
        ELSE IF $step.rule = "timezone" { fn::sanitize_timezone($value) }
        ELSE IF $step.rule = "title_case" { fn::sanitize_title_case($value) }
        ELSE IF $step.rule = "trim" { fn::sanitize_trim($value) }
        ELSE IF $step.rule = "trim_left" { fn::sanitize_trim_left($value) }
        ELSE IF $step.rule = "trim_right" { fn::sanitize_trim_right($value) }
        ELSE IF $step.rule = "uppercase" { fn::sanitize_uppercase($value) }
        ELSE IF $step.rule = "url" { fn::sanitize_url($value) }
        ELSE IF $step.rule = "default" { $value ?? $options.value }
        ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
    });
}
COMMENT "Aiguillage du domaine sanitize pour le moteur : applique l'étape à state.value en appelant la fonction de valeurs fn::sanitize_<règle> avec ses options (valeurs par défaut du catalogue). Passée en closure à fn::utils_engine_run."
PERMISSIONS FULL;
