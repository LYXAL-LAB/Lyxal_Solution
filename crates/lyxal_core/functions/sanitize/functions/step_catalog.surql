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
-- les options obligatoires ; idempotent marque les seules règles
-- qu'appliquer deux fois de suite revient à appliquer une fois pour toute
-- entrée (trim, trim_left, trim_right, lowercase, uppercase,
-- collapse_whitespace, default), seules simplifiables par
-- fn::utils_engine_optimize.
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions sanitize)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::sanitize_step_catalog() -> array<object> {
    RETURN [
        { rule: "absolute_url", cost: 1 },
        { rule: "alphanumeric_upper", cost: 1 },
        { rule: "array", cost: 1 },
        { rule: "array_compact", cost: 1 },
        { rule: "array_flatten", cost: 1 },
        { rule: "array_limit", cost: 1, required: ["limit"] },
        { rule: "array_numbers", cost: 1 },
        { rule: "array_objects", cost: 1 },
        { rule: "array_sort", cost: 1 },
        { rule: "array_strings", cost: 1 },
        { rule: "array_unique", cost: 1 },
        { rule: "ascii", cost: 1 },
        { rule: "calendar", cost: 1, required: ["granularity"] },
        { rule: "capitalize", cost: 1 },
        { rule: "clamp", cost: 1, required: ["min", "max"] },
        { rule: "collapse_whitespace", cost: 1, idempotent: true },
        { rule: "country_code", cost: 1 },
        { rule: "credit_card_mask", cost: 1 },
        { rule: "currency", cost: 1 },
        { rule: "date", cost: 1 },
        { rule: "datetime", cost: 1, required: ["precision"] },
        { rule: "decimal", cost: 1 },
        { rule: "default_values", cost: 1, required: ["defaults"] },
        { rule: "domain", cost: 1 },
        { rule: "duration", cost: 1, required: ["precision"] },
        { rule: "e164", cost: 1 },
        { rule: "email", cost: 1 },
        { rule: "email_domain", cost: 1 },
        { rule: "email_local", cost: 1 },
        { rule: "float", cost: 1 },
        { rule: "fragment", cost: 1 },
        { rule: "hostname", cost: 1 },
        { rule: "html", cost: 3 },
        { rule: "html_entities", cost: 1 },
        { rule: "integer", cost: 1 },
        { rule: "lowercase", cost: 1, idempotent: true },
        { rule: "markdown", cost: 3 },
        { rule: "markdown_code", cost: 1 },
        { rule: "markdown_headers", cost: 1 },
        { rule: "markdown_images", cost: 1 },
        { rule: "markdown_links", cost: 1 },
        { rule: "markdown_lists", cost: 1 },
        { rule: "markdown_quotes", cost: 1 },
        { rule: "markdown_safe", cost: 3 },
        { rule: "markdown_tables", cost: 1 },
        { rule: "negative", cost: 1 },
        { rule: "normalize_unicode", cost: 1 },
        { rule: "null_to_none", cost: 1 },
        { rule: "object_or_empty", cost: 1 },
        { rule: "object_clone", cost: 1 },
        { rule: "object_merge", cost: 1, required: ["override"] },
        { rule: "object_normalize", cost: 1 },
        { rule: "percentage", cost: 1 },
        { rule: "phone", cost: 1 },
        { rule: "port", cost: 1 },
        { rule: "positive", cost: 1 },
        { rule: "postal_code", cost: 1 },
        { rule: "precision", cost: 1, required: ["precision"] },
        { rule: "query", cost: 1 },
        { rule: "relative_url", cost: 1 },
        { rule: "remove_control_chars", cost: 1 },
        { rule: "remove_empty", cost: 1 },
        { rule: "remove_multiple_spaces", cost: 1 },
        { rule: "remove_newlines", cost: 1 },
        { rule: "remove_tabs", cost: 1 },
        { rule: "remove_tracking", cost: 1 },
        { rule: "remove_unknown_keys", cost: 1, required: ["allowed_keys"] },
        { rule: "rfc3339", cost: 1 },
        { rule: "round", cost: 1, required: ["precision"] },
        { rule: "safe_extension", cost: 1 },
        { rule: "safe_filename", cost: 1 },
        { rule: "safe_identifier", cost: 1 },
        { rule: "safe_path", cost: 1 },
        { rule: "safe_redirect", cost: 1 },
        { rule: "schedule", cost: 1, required: ["duration", "round_to"] },
        { rule: "slug", cost: 1 },
        { rule: "strip_comments", cost: 1 },
        { rule: "strip_dangerous_attributes", cost: 3 },
        { rule: "strip_event_handlers", cost: 3 },
        { rule: "strip_html", cost: 3 },
        { rule: "strip_iframes", cost: 1 },
        { rule: "strip_scripts", cost: 1 },
        { rule: "strip_styles", cost: 1 },
        { rule: "strip_svg", cost: 1 },
        { rule: "timestamp", cost: 1 },
        { rule: "timezone", cost: 1 },
        { rule: "title_case", cost: 1 },
        { rule: "trim", cost: 1, idempotent: true },
        { rule: "trim_left", cost: 1, idempotent: true },
        { rule: "trim_right", cost: 1, idempotent: true },
        { rule: "uppercase", cost: 1, idempotent: true },
        { rule: "url", cost: 1 },
        { rule: "default", cost: 1, idempotent: true, required: ["value"] }
    ];
}
COMMENT "Catalogue des règles de sanitize utilisables dans un pipeline du moteur : une règle par fonction de valeurs fn::sanitize_* (options = paramètres de la fonction, avec leurs valeurs par défaut), plus « default » (remplace NONE par options.value). fn::sanitize_object est exposée sous le nom object_or_empty, object étant une règle du moteur ; fn::sanitize_date_range (deux valeurs) n'est pas une étape. required liste les options obligatoires ; idempotent marque les seules règles qu'appliquer deux fois de suite revient à appliquer une fois pour toute entrée (trim, trim_left, trim_right, lowercase, uppercase, collapse_whitespace, default), seules simplifiables par fn::utils_engine_optimize."
PERMISSIONS FULL;
