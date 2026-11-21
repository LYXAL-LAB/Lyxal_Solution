-- ============================================================================
-- LYXAL OS — CORE VALIDATIONS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/step_apply.surql
-- Fonction : fn::validation_step_apply
--
-- Aiguillage du domaine validations pour le moteur : appelle le validateur
-- fn::validation_<règle> avec ses options ; un résultat valide remplace
-- state.value par la valeur normalisée, un résultat invalide ajoute l'erreur
-- (code CORE_VALIDATION_*, details) et arrête le pipeline du champ. Passée
-- en closure à fn::utils_engine_run.
--
-- Paramètres
--   $state : object
--   $step  : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions validations)
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : règle absente du catalogue (étape non contrôlée par fn::utils_engine_pipeline)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_step_apply(
    $state: object,
    $step: object
) -> object {
    LET $current = $state.value;
    LET $options = $step.options;
    -- Aiguillage en deux niveaux (initiale, puis règle) : une quinzaine de comparaisons au plus
    LET $rule = $step.rule;
    LET $result =
        IF $rule < "b" {
            IF $rule = "age_range" { fn::validation_age_range($current, $options.min_age, $options.max_age) }
            ELSE IF $rule = "allowed_types" { fn::validation_allowed_types($current, $options.allowed_types) }
            ELSE IF $rule = "alphanumeric" { fn::validation_alphanumeric($current, $options.trim_value) }
            ELSE IF $rule = "ape_naf_code" { fn::validation_ape_naf_code($current) }
            ELSE IF $rule = "api_key" { fn::validation_api_key($current, $options.min_length, $options.max_length, $options.allowed_prefixes) }
            ELSE IF $rule = "archive_entry_path" { fn::validation_archive_entry_path($current, $options.max_length) }
            ELSE IF $rule = "array" { fn::validation_array($current) }
            ELSE IF $rule = "array_integers" { fn::validation_array_integers($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "array_length" { fn::validation_array_length($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "array_non_empty" { fn::validation_array_non_empty($current) }
            ELSE IF $rule = "array_objects" { fn::validation_array_objects($current, $options.allow_empty_objects) }
            ELSE IF $rule = "array_of_records" { fn::validation_array_of_records($current, $options.expected_table, $options.require_exists) }
            ELSE IF $rule = "array_of_strings" { fn::validation_array_of_strings($current, $options.allow_empty, $options.min_length, $options.max_length) }
            ELSE IF $rule = "array_unique" { fn::validation_array_unique($current) }
            ELSE IF $rule = "array_without_none" { fn::validation_array_without_none($current) }
            ELSE IF $rule = "array_without_null" { fn::validation_array_without_null($current) }
            ELSE IF $rule = "ascii" { fn::validation_ascii($current, $options.trim_value, $options.allow_blank) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "c" {
            IF $rule = "base64" { fn::validation_base64($current, $options.url_safe, $options.require_padding) }
            ELSE IF $rule = "bearer_token" { fn::validation_bearer_token($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "bic" { fn::validation_bic($current, $options.allowed_countries) }
            ELSE IF $rule = "birthdate" { fn::validation_birthdate($current, $options.allow_today) }
            ELSE IF $rule = "boolean" { fn::validation_boolean($current) }
            ELSE IF $rule = "business_day" { fn::validation_business_day($current, $options.holidays) }
            ELSE IF $rule = "bytes" { fn::validation_bytes($current, $options.min_length, $options.max_length) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "d" {
            IF $rule = "card_pan" { fn::validation_card_pan($current, $options.allowed_networks) }
            ELSE IF $rule = "certificate_pem" { fn::validation_certificate_pem($current, $options.max_length) }
            ELSE IF $rule = "checksum" { fn::validation_checksum($current, $options.algorithm) }
            ELSE IF $rule = "cidr" { fn::validation_cidr($current, $options.allow_ipv4, $options.allow_ipv6) }
            ELSE IF $rule = "company_name" { fn::validation_company_name($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "contains" { fn::validation_contains($current, $options.needles, $options.case_sensitive, $options.trim_value) }
            ELSE IF $rule = "content_disposition_filename" { fn::validation_content_disposition_filename($current, $options.max_length) }
            ELSE IF $rule = "content_type" { fn::validation_content_type($current, $options.allowed_media_types) }
            ELSE IF $rule = "contract_version" { fn::validation_contract_version($current) }
            ELSE IF $rule = "country_code_iso2" { fn::validation_country_code_iso2($current, $options.allowed_codes) }
            ELSE IF $rule = "country_code_iso3" { fn::validation_country_code_iso3($current, $options.allowed_codes) }
            ELSE IF $rule = "cron_expression" { fn::validation_cron_expression($current, $options.allow_seconds, $options.allow_macros) }
            ELSE IF $rule = "currency_code" { fn::validation_currency_code($current, $options.allowed_codes) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "e" {
            IF $rule = "date" { fn::validation_date($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "date_string" { fn::validation_date_string($current) }
            ELSE IF $rule = "datetime" { fn::validation_datetime($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "datetime_string" { fn::validation_datetime_string($current, $options.format) }
            ELSE IF $rule = "decimal" { fn::validation_decimal($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "display_name" { fn::validation_display_name($current, $options.min_length, $options.max_length, $options.allow_emoji) }
            ELSE IF $rule = "domain" { fn::validation_domain($current, $options.allow_subdomains) }
            ELSE IF $rule = "duration" { fn::validation_duration($current, $options.min_value, $options.max_value) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "f" {
            IF $rule = "email" { fn::validation_email($current, $options.max_length) }
            ELSE IF $rule = "ends_with" { fn::validation_ends_with($current, $options.suffixes, $options.case_sensitive, $options.trim_value) }
            ELSE IF $rule = "enum" { fn::validation_enum($current, $options.allowed, $options.case_sensitive) }
            ELSE IF $rule = "enum_any" { fn::validation_enum_any($current, $options.allowed_values) }
            ELSE IF $rule = "etag" { fn::validation_etag($current, $options.allow_weak) }
            ELSE IF $rule = "even" { fn::validation_even($current) }
            ELSE IF $rule = "execution_priority" { fn::validation_execution_priority($current, $options.min_priority, $options.max_priority) }
            ELSE IF $rule = "execution_timeout" { fn::validation_execution_timeout($current, $options.min_timeout, $options.max_timeout) }
            ELSE IF $rule = "exists" { fn::validation_exists($current, $options.target_table, $options.target_field) }
            ELSE IF $rule = "extension" { fn::validation_extension($current, $options.allowed_extensions, $options.allow_leading_dot) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "h" {
            IF $rule = "filename" { fn::validation_filename($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "filesize" { fn::validation_filesize($current, $options.min_bytes, $options.max_bytes) }
            ELSE IF $rule = "first_name" { fn::validation_first_name($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "float" { fn::validation_float($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "forbidden_values" { fn::validation_forbidden_values($current, $options.forbidden_values, $options.case_sensitive, $options.trim_value) }
            ELSE IF $rule = "full_name" { fn::validation_full_name($current, $options.min_words, $options.max_words, $options.max_length) }
            ELSE IF $rule = "future_datetime" { fn::validation_future_datetime($current, $options.reference_value, $options.allow_equal, $options.min_advance, $options.max_advance) }
            ELSE IF $rule = "geohash" { fn::validation_geohash($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "geometry" { fn::validation_geometry($current, $options.allowed_types, $options.require_valid) }
            ELSE IF $rule = "gtin" { fn::validation_gtin($current) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "i" {
            IF $rule = "hexadecimal" { fn::validation_hexadecimal($current, $options.min_length, $options.max_length, $options.allow_prefix) }
            ELSE IF $rule = "hmac_signature" { fn::validation_hmac_signature($current, $options.encoding, $options.expected_length) }
            ELSE IF $rule = "hostname" { fn::validation_hostname($current, $options.allow_single_label) }
            ELSE IF $rule = "http_method" { fn::validation_http_method($current, $options.allowed_methods) }
            ELSE IF $rule = "http_url" { fn::validation_http_url($current, $options.allow_http, $options.allow_https) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "l" {
            IF $rule = "iban" { fn::validation_iban($current, $options.allowed_countries) }
            ELSE IF $rule = "idempotency_key" { fn::validation_idempotency_key($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "identifier" { fn::validation_identifier($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "image_height" { fn::validation_image_height($current, $options.min_height, $options.max_height) }
            ELSE IF $rule = "image_width" { fn::validation_image_width($current, $options.min_width, $options.max_width) }
            ELSE IF $rule = "initials" { fn::validation_initials($current, $options.min_count, $options.max_count) }
            ELSE IF $rule = "integer" { fn::validation_integer($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "invoice_number" { fn::validation_invoice_number($current, $options.min_length, $options.max_length, $options.allowed_prefixes) }
            ELSE IF $rule = "ip" { fn::validation_ip($current, $options.version) }
            ELSE IF $rule = "is_object" { fn::validation_object($current) }
            ELSE IF $rule = "iso8601" { fn::validation_iso8601($current, $options.allow_fractional_seconds) }
            ELSE IF $rule = "jwt_compact" { fn::validation_jwt_compact($current, $options.max_length) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "m" {
            IF $rule = "language_code" { fn::validation_language_code($current, $options.allow_alpha3, $options.allowed_codes) }
            ELSE IF $rule = "last_name" { fn::validation_last_name($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "latitude" { fn::validation_latitude($current) }
            ELSE IF $rule = "locale" { fn::validation_locale($current, $options.require_region) }
            ELSE IF $rule = "longitude" { fn::validation_longitude($current) }
            ELSE IF $rule = "lowercase" { fn::validation_lowercase($current, $options.trim_value, $options.allow_blank) }
            ELSE IF $rule = "luhn" { fn::validation_luhn($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_bucket_name" { fn::validation_lyxal_bucket_name($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_database" { fn::validation_lyxal_database($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_event_name" { fn::validation_lyxal_event_name($current, $options.min_segments, $options.max_segments) }
            ELSE IF $rule = "lyxal_function_name" { fn::validation_lyxal_function_name($current, $options.require_namespace, $options.max_length) }
            ELSE IF $rule = "lyxal_instance_name" { fn::validation_lyxal_instance_name($current, $options.environment, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_module_name" { fn::validation_lyxal_module_name($current, $options.allowed_prefixes, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_namespace" { fn::validation_lyxal_namespace($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_permission_name" { fn::validation_lyxal_permission_name($current, $options.allowed_actions) }
            ELSE IF $rule = "lyxal_role_name" { fn::validation_lyxal_role_name($current, $options.reserved_roles, $options.min_length, $options.max_length) }
            ELSE IF $rule = "lyxal_storage_path" { fn::validation_lyxal_storage_path($current, $options.required_root, $options.allow_file_extension, $options.max_length) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "o" {
            IF $rule = "mac_address" { fn::validation_mac_address($current, $options.allow_hyphen, $options.allow_colon) }
            ELSE IF $rule = "max_length" { fn::validation_max_length($current, $options.max_length) }
            ELSE IF $rule = "max_serialized_length" { fn::validation_max_serialized_length($current, $options.max_length) }
            ELSE IF $rule = "mime_type" { fn::validation_mime_type($current, $options.allowed_types) }
            ELSE IF $rule = "min_length" { fn::validation_min_length($current, $options.min_length) }
            ELSE IF $rule = "money" { fn::validation_money($current, $options.min_value, $options.max_value, $options.max_scale) }
            ELSE IF $rule = "multiple_of" { fn::validation_multiple_of($current, $options.divisor) }
            ELSE IF $rule = "negative_number" { fn::validation_negative_number($current) }
            ELSE IF $rule = "non_negative_number" { fn::validation_non_negative_number($current) }
            ELSE IF $rule = "non_zero" { fn::validation_non_zero($current) }
            ELSE IF $rule = "nonce" { fn::validation_nonce($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "not_blank" { fn::validation_not_blank($current) }
            ELSE IF $rule = "number" { fn::validation_number($current, $options.min_value, $options.max_value) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "p" {
            IF $rule = "object_keys" { fn::validation_object_keys($current, $options.required_keys, $options.allowed_keys) }
            ELSE IF $rule = "object_no_none" { fn::validation_object_no_none($current) }
            ELSE IF $rule = "object_no_null" { fn::validation_object_no_null($current) }
            ELSE IF $rule = "object_non_empty" { fn::validation_object_non_empty($current) }
            ELSE IF $rule = "object_values_type" { fn::validation_object_values_type($current, $options.expected_type, $options.allow_empty, $options.max_length) }
            ELSE IF $rule = "odd" { fn::validation_odd($current) }
            ELSE IF $rule = "optional_string" { fn::validation_optional_string($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "origin" { fn::validation_origin($current, $options.allow_http, $options.allow_https, $options.allow_port) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "r" {
            IF $rule = "password_strength" { fn::validation_password_strength($current, $options.min_length, $options.max_length, $options.require_uppercase, $options.require_lowercase, $options.require_digit, $options.require_special) }
            ELSE IF $rule = "past_datetime" { fn::validation_past_datetime($current, $options.reference_value, $options.allow_equal, $options.min_age, $options.max_age) }
            ELSE IF $rule = "percentage" { fn::validation_percentage($current, $options.min_value, $options.max_value) }
            ELSE IF $rule = "phone" { fn::validation_phone($current) }
            ELSE IF $rule = "port" { fn::validation_port($current, $options.min_port, $options.max_port) }
            ELSE IF $rule = "positive_number" { fn::validation_positive_number($current) }
            ELSE IF $rule = "postal_code_fr" { fn::validation_postal_code_fr($current, $options.allow_cedex) }
            ELSE IF $rule = "private_key_pem" { fn::validation_private_key_pem($current, $options.allow_encrypted, $options.max_length) }
            ELSE IF $rule = "profile_identifier" { fn::validation_profile_identifier($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "public_alias" { fn::validation_public_alias($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "public_key_pem" { fn::validation_public_key_pem($current, $options.max_length) }
            ELSE IF $rule = "queue_name" { fn::validation_queue_name($current, $options.min_length, $options.max_length) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "s" {
            IF $rule = "record" { fn::validation_record($current, $options.expected_table) }
            ELSE IF $rule = "record_exists" { fn::validation_record_exists($current) }
            ELSE IF $rule = "record_id" { fn::validation_record_id($current, $options.allowed_tables) }
            ELSE IF $rule = "recovery_code" { fn::validation_recovery_code($current, $options.group_count, $options.group_length) }
            ELSE IF $rule = "regex" { fn::validation_regex($current, $options.pattern) }
            ELSE IF $rule = "required_if" { fn::validation_required_if($current, $options.condition, $options.allow_null) }
            ELSE IF $rule = "required_string" { fn::validation_required_string($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "required_unless" { fn::validation_required_unless($current, $options.unless_condition, $options.allow_null) }
            ELSE IF $rule = "reserved_words" { fn::validation_reserved_words($current, $options.reserved_words, $options.trim_value) }
            ELSE IF $rule = "retry_policy" { fn::validation_retry_policy($current, $options.max_attempts_limit, $options.max_backoff) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "t" {
            IF $rule = "semantic_version" { fn::validation_semantic_version($current, $options.allow_v_prefix) }
            ELSE IF $rule = "siren" { fn::validation_siren($current) }
            ELSE IF $rule = "siret" { fn::validation_siret($current) }
            ELSE IF $rule = "slug" { fn::validation_slug($current, $options.max_length) }
            ELSE IF $rule = "snake_case_name" { fn::validation_snake_case_name($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "socket_address" { fn::validation_socket_address($current, $options.allow_hostname, $options.allow_ipv4, $options.allow_ipv6) }
            ELSE IF $rule = "starts_with" { fn::validation_starts_with($current, $options.prefixes, $options.case_sensitive, $options.trim_value) }
            ELSE IF $rule = "storage_path" { fn::validation_storage_path($current, $options.allow_leading_slash, $options.allow_trailing_slash, $options.max_length) }
            ELSE IF $rule = "surql_field" { fn::validation_surql_field($current, $options.allow_id, $options.max_length) }
            ELSE IF $rule = "surql_field_path" { fn::validation_surql_field_path($current, $options.allow_array_wildcard, $options.allow_numeric_index, $options.max_segments) }
            ELSE IF $rule = "surql_function" { fn::validation_surql_function($current, $options.require_namespace, $options.max_segments) }
            ELSE IF $rule = "surql_parameter" { fn::validation_surql_parameter($current, $options.allow_reserved) }
            ELSE IF $rule = "surql_record_string" { fn::validation_surql_record_string($current, $options.expected_table) }
            ELSE IF $rule = "surql_variable" { fn::validation_surql_variable($current, $options.allow_reserved) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE IF $rule < "u" {
            IF $rule = "time_of_day" { fn::validation_time_of_day($current) }
            ELSE IF $rule = "time_string" { fn::validation_time_string($current, $options.require_seconds) }
            ELSE IF $rule = "timezone" { fn::validation_timezone($current, $options.allow_utc) }
            ELSE IF $rule = "totp_code" { fn::validation_totp_code($current, $options.digits) }
            ELSE IF $rule = "totp_secret" { fn::validation_totp_secret($current, $options.min_length, $options.max_length) }
            ELSE IF $rule = "tuple_length" { fn::validation_tuple_length($current, $options.expected_length) }
            ELSE IF $rule = "tuple_types" { fn::validation_tuple_types($current, $options.expected_types) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        } ELSE {
            IF $rule = "ulid" { fn::validation_ulid($current) }
            ELSE IF $rule = "unique" { fn::validation_unique($current, $options.target_table, $options.target_field, $options.exclude_record) }
            ELSE IF $rule = "unknown_keys_policy" { fn::validation_unknown_keys_policy($current, $options.allowed_keys, $options.policy) }
            ELSE IF $rule = "uppercase" { fn::validation_uppercase($current, $options.trim_value, $options.allow_blank) }
            ELSE IF $rule = "uri_scheme" { fn::validation_uri_scheme($current, $options.allowed_schemes) }
            ELSE IF $rule = "url" { fn::validation_url($current, $options.max_length) }
            ELSE IF $rule = "username" { fn::validation_username($current, $options.min_length, $options.max_length, $options.force_lowercase) }
            ELSE IF $rule = "uuid" { fn::validation_uuid($current) }
            ELSE IF $rule = "uuid_v7" { fn::validation_uuid_v7($current, $options.allow_string) }
            ELSE IF $rule = "value_type" { fn::validation_value_type($current, $options.expected_type) }
            ELSE IF $rule = "vat_number_fr" { fn::validation_vat_number_fr($current, $options.validate_numeric_key) }
            ELSE IF $rule = "webhook_path" { fn::validation_webhook_path($current, $options.allow_parameters, $options.allow_wildcard) }
            ELSE IF $rule = "weekday" { fn::validation_weekday($current, $options.allowed_days) }
            ELSE IF $rule = "workflow_delay" { fn::validation_workflow_delay($current, $options.min_delay, $options.max_delay, $options.allow_zero) }
            ELSE { THROW "CORE_UNSUPPORTED_OPTION" }
        };
    RETURN IF $result.valid {
        object::extend($state, { value: $result.value })
    } ELSE {
        fn::utils_engine_issue($state, $step.rule, $result.code, $result.details)
    };
}
COMMENT "Aiguillage du domaine validations pour le moteur : appelle le validateur fn::validation_<règle> avec ses options ; un résultat valide remplace state.value par la valeur normalisée, un résultat invalide ajoute l'erreur (code CORE_VALIDATION_*, details) et arrête le pipeline du champ. Passée en closure à fn::utils_engine_run."
PERMISSIONS FULL;
