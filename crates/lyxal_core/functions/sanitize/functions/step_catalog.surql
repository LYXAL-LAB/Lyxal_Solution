-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/step_catalog.surql
-- Fonction : fn::sanitize_step_catalog
--
-- Catalogue des règles de sanitize utilisables dans un pipeline du moteur :
-- une règle par fonction de valeurs fn::sanitize_* (options = paramètres de
-- la fonction, avec leurs valeurs par défaut), plus « default » (remplace
-- NONE par options.value). fn::sanitize_object est exposée sous le nom
-- object_or_empty, object étant une règle du moteur ;
-- fn::sanitize_date_range (deux valeurs) n'est pas une étape. required liste
-- les options obligatoires ; idempotent marque les règles qu'appliquer deux
-- fois de suite revient à appliquer une fois (toutes sauf html_entities),
-- seules simplifiables par fn::utils_engine_optimize.
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions sanitize)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::sanitize_step_catalog() -> array<object> {
    RETURN [
        { rule: "absolute_url", cost: 1, idempotent: true },
        { rule: "alphanumeric_upper", cost: 1, idempotent: true },
        { rule: "array", cost: 1, idempotent: true },
        { rule: "array_compact", cost: 1, idempotent: true },
        { rule: "array_flatten", cost: 1, idempotent: true },
        { rule: "array_limit", cost: 1, idempotent: true, required: ["limit"] },
        { rule: "array_numbers", cost: 1, idempotent: true },
        { rule: "array_objects", cost: 1, idempotent: true },
        { rule: "array_sort", cost: 1, idempotent: true },
        { rule: "array_strings", cost: 1, idempotent: true },
        { rule: "array_unique", cost: 1, idempotent: true },
        { rule: "ascii", cost: 1, idempotent: true },
        { rule: "calendar", cost: 1, idempotent: true, required: ["granularity"] },
        { rule: "capitalize", cost: 1, idempotent: true },
        { rule: "clamp", cost: 1, idempotent: true, required: ["min", "max"] },
        { rule: "collapse_whitespace", cost: 1, idempotent: true },
        { rule: "country_code", cost: 1, idempotent: true },
        { rule: "credit_card_mask", cost: 1, idempotent: true },
        { rule: "currency", cost: 1, idempotent: true },
        { rule: "date", cost: 1, idempotent: true },
        { rule: "datetime", cost: 1, idempotent: true, required: ["precision"] },
        { rule: "decimal", cost: 1, idempotent: true },
        { rule: "default_values", cost: 1, idempotent: true, required: ["defaults"] },
        { rule: "domain", cost: 1, idempotent: true },
        { rule: "duration", cost: 1, idempotent: true, required: ["precision"] },
        { rule: "e164", cost: 1, idempotent: true },
        { rule: "email", cost: 1, idempotent: true },
        { rule: "email_domain", cost: 1, idempotent: true },
        { rule: "email_local", cost: 1, idempotent: true },
        { rule: "float", cost: 1, idempotent: true },
        { rule: "fragment", cost: 1, idempotent: true },
        { rule: "hostname", cost: 1, idempotent: true },
        { rule: "html", cost: 3, idempotent: true },
        { rule: "html_entities", cost: 1 },
        { rule: "integer", cost: 1, idempotent: true },
        { rule: "lowercase", cost: 1, idempotent: true },
        { rule: "markdown", cost: 3, idempotent: true },
        { rule: "markdown_code", cost: 1, idempotent: true },
        { rule: "markdown_headers", cost: 1, idempotent: true },
        { rule: "markdown_images", cost: 1, idempotent: true },
        { rule: "markdown_links", cost: 1, idempotent: true },
        { rule: "markdown_lists", cost: 1, idempotent: true },
        { rule: "markdown_quotes", cost: 1, idempotent: true },
        { rule: "markdown_safe", cost: 3, idempotent: true },
        { rule: "markdown_tables", cost: 1, idempotent: true },
        { rule: "negative", cost: 1, idempotent: true },
        { rule: "normalize_unicode", cost: 1, idempotent: true },
        { rule: "null_to_none", cost: 1, idempotent: true },
        { rule: "object_or_empty", cost: 1, idempotent: true },
        { rule: "object_clone", cost: 1, idempotent: true },
        { rule: "object_merge", cost: 1, idempotent: true, required: ["override"] },
        { rule: "object_normalize", cost: 1, idempotent: true },
        { rule: "percentage", cost: 1, idempotent: true },
        { rule: "phone", cost: 1, idempotent: true },
        { rule: "port", cost: 1, idempotent: true },
        { rule: "positive", cost: 1, idempotent: true },
        { rule: "postal_code", cost: 1, idempotent: true },
        { rule: "precision", cost: 1, idempotent: true, required: ["precision"] },
        { rule: "query", cost: 1, idempotent: true },
        { rule: "relative_url", cost: 1, idempotent: true },
        { rule: "remove_control_chars", cost: 1, idempotent: true },
        { rule: "remove_empty", cost: 1, idempotent: true },
        { rule: "remove_multiple_spaces", cost: 1, idempotent: true },
        { rule: "remove_newlines", cost: 1, idempotent: true },
        { rule: "remove_tabs", cost: 1, idempotent: true },
        { rule: "remove_tracking", cost: 1, idempotent: true },
        { rule: "remove_unknown_keys", cost: 1, idempotent: true, required: ["allowed_keys"] },
        { rule: "rfc3339", cost: 1, idempotent: true },
        { rule: "round", cost: 1, idempotent: true, required: ["precision"] },
        { rule: "safe_extension", cost: 1, idempotent: true },
        { rule: "safe_filename", cost: 1, idempotent: true },
        { rule: "safe_identifier", cost: 1, idempotent: true },
        { rule: "safe_path", cost: 1, idempotent: true },
        { rule: "safe_redirect", cost: 1, idempotent: true },
        { rule: "schedule", cost: 1, idempotent: true, required: ["duration", "round_to"] },
        { rule: "slug", cost: 1, idempotent: true },
        { rule: "strip_comments", cost: 1, idempotent: true },
        { rule: "strip_dangerous_attributes", cost: 3, idempotent: true },
        { rule: "strip_event_handlers", cost: 3, idempotent: true },
        { rule: "strip_html", cost: 3, idempotent: true },
        { rule: "strip_iframes", cost: 1, idempotent: true },
        { rule: "strip_scripts", cost: 1, idempotent: true },
        { rule: "strip_styles", cost: 1, idempotent: true },
        { rule: "strip_svg", cost: 1, idempotent: true },
        { rule: "timestamp", cost: 1, idempotent: true },
        { rule: "timezone", cost: 1, idempotent: true },
        { rule: "title_case", cost: 1, idempotent: true },
        { rule: "trim", cost: 1, idempotent: true },
        { rule: "trim_left", cost: 1, idempotent: true },
        { rule: "trim_right", cost: 1, idempotent: true },
        { rule: "uppercase", cost: 1, idempotent: true },
        { rule: "url", cost: 1, idempotent: true },
        { rule: "default", cost: 1, idempotent: true, required: ["value"] }
    ];
}
COMMENT "Catalogue des règles de sanitize utilisables dans un pipeline du moteur : une règle par fonction de valeurs fn::sanitize_* (options = paramètres de la fonction, avec leurs valeurs par défaut), plus « default » (remplace NONE par options.value). fn::sanitize_object est exposée sous le nom object_or_empty, object étant une règle du moteur ; fn::sanitize_date_range (deux valeurs) n'est pas une étape. required liste les options obligatoires ; idempotent marque les règles qu'appliquer deux fois de suite revient à appliquer une fois (toutes sauf html_entities), seules simplifiables par fn::utils_engine_optimize."
PERMISSIONS FULL;
