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
    LET $value = $state.value;
    LET $options = $step.options;
    LET $result =
        IF $step.rule = "age_range" { fn::validation_age_range($value, $options.min_age, $options.max_age) }
        ELSE IF $step.rule = "allowed_types" { fn::validation_allowed_types($value, $options.allowed_types) }
        ELSE IF $step.rule = "alphanumeric" { fn::validation_alphanumeric($value, $options.trim_value) }
        ELSE IF $step.rule = "ape_naf_code" { fn::validation_ape_naf_code($value) }
        ELSE IF $step.rule = "api_key" { fn::validation_api_key($value, $options.min_length, $options.max_length, $options.allowed_prefixes) }
        ELSE IF $step.rule = "archive_entry_path" { fn::validation_archive_entry_path($value, $options.max_length) }
        ELSE IF $step.rule = "array" { fn::validation_array($value) }
        ELSE IF $step.rule = "array_integers" { fn::validation_array_integers($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "array_length" { fn::validation_array_length($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "array_non_empty" { fn::validation_array_non_empty($value) }
        ELSE IF $step.rule = "array_objects" { fn::validation_array_objects($value, $options.allow_empty_objects) }
        ELSE IF $step.rule = "array_of_records" { fn::validation_array_of_records($value, $options.expected_table, $options.require_exists) }
        ELSE IF $step.rule = "array_of_strings" { fn::validation_array_of_strings($value, $options.allow_empty, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "array_unique" { fn::validation_array_unique($value) }
        ELSE IF $step.rule = "array_without_none" { fn::validation_array_without_none($value) }
        ELSE IF $step.rule = "array_without_null" { fn::validation_array_without_null($value) }
        ELSE IF $step.rule = "ascii" { fn::validation_ascii($value, $options.trim_value, $options.allow_blank) }
        ELSE IF $step.rule = "base64" { fn::validation_base64($value, $options.url_safe, $options.require_padding) }
        ELSE IF $step.rule = "bearer_token" { fn::validation_bearer_token($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "bic" { fn::validation_bic($value, $options.allowed_countries) }
        ELSE IF $step.rule = "birthdate" { fn::validation_birthdate($value, $options.allow_today) }
        ELSE IF $step.rule = "boolean" { fn::validation_boolean($value) }
        ELSE IF $step.rule = "business_day" { fn::validation_business_day($value, $options.holidays) }
        ELSE IF $step.rule = "bytes" { fn::validation_bytes($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "card_pan" { fn::validation_card_pan($value, $options.allowed_networks) }
        ELSE IF $step.rule = "certificate_pem" { fn::validation_certificate_pem($value, $options.max_length) }
        ELSE IF $step.rule = "checksum" { fn::validation_checksum($value, $options.algorithm) }
        ELSE IF $step.rule = "cidr" { fn::validation_cidr($value, $options.allow_ipv4, $options.allow_ipv6) }
        ELSE IF $step.rule = "company_name" { fn::validation_company_name($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "contains" { fn::validation_contains($value, $options.needles, $options.case_sensitive, $options.trim_value) }
        ELSE IF $step.rule = "content_disposition_filename" { fn::validation_content_disposition_filename($value, $options.max_length) }
        ELSE IF $step.rule = "content_type" { fn::validation_content_type($value, $options.allowed_media_types) }
        ELSE IF $step.rule = "contract_version" { fn::validation_contract_version($value) }
        ELSE IF $step.rule = "country_code_iso2" { fn::validation_country_code_iso2($value, $options.allowed_codes) }
        ELSE IF $step.rule = "country_code_iso3" { fn::validation_country_code_iso3($value, $options.allowed_codes) }
        ELSE IF $step.rule = "cron_expression" { fn::validation_cron_expression($value, $options.allow_seconds, $options.allow_macros) }
        ELSE IF $step.rule = "currency_code" { fn::validation_currency_code($value, $options.allowed_codes) }
        ELSE IF $step.rule = "date" { fn::validation_date($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "date_string" { fn::validation_date_string($value) }
        ELSE IF $step.rule = "datetime" { fn::validation_datetime($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "datetime_string" { fn::validation_datetime_string($value, $options.format) }
        ELSE IF $step.rule = "decimal" { fn::validation_decimal($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "display_name" { fn::validation_display_name($value, $options.min_length, $options.max_length, $options.allow_emoji) }
        ELSE IF $step.rule = "domain" { fn::validation_domain($value, $options.allow_subdomains) }
        ELSE IF $step.rule = "duration" { fn::validation_duration($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "email" { fn::validation_email($value, $options.max_length) }
        ELSE IF $step.rule = "ends_with" { fn::validation_ends_with($value, $options.suffixes, $options.case_sensitive, $options.trim_value) }
        ELSE IF $step.rule = "enum" { fn::validation_enum($value, $options.allowed, $options.case_sensitive) }
        ELSE IF $step.rule = "enum_any" { fn::validation_enum_any($value, $options.allowed_values) }
        ELSE IF $step.rule = "etag" { fn::validation_etag($value, $options.allow_weak) }
        ELSE IF $step.rule = "even" { fn::validation_even($value) }
        ELSE IF $step.rule = "execution_priority" { fn::validation_execution_priority($value, $options.min_priority, $options.max_priority) }
        ELSE IF $step.rule = "execution_timeout" { fn::validation_execution_timeout($value, $options.min_timeout, $options.max_timeout) }
        ELSE IF $step.rule = "exists" { fn::validation_exists($value, $options.target_table, $options.target_field) }
        ELSE IF $step.rule = "extension" { fn::validation_extension($value, $options.allowed_extensions, $options.allow_leading_dot) }
        ELSE IF $step.rule = "filename" { fn::validation_filename($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "filesize" { fn::validation_filesize($value, $options.min_bytes, $options.max_bytes) }
        ELSE IF $step.rule = "first_name" { fn::validation_first_name($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "float" { fn::validation_float($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "forbidden_values" { fn::validation_forbidden_values($value, $options.forbidden_values, $options.case_sensitive, $options.trim_value) }
        ELSE IF $step.rule = "full_name" { fn::validation_full_name($value, $options.min_words, $options.max_words, $options.max_length) }
        ELSE IF $step.rule = "future_datetime" { fn::validation_future_datetime($value, $options.reference_value, $options.allow_equal, $options.min_advance, $options.max_advance) }
        ELSE IF $step.rule = "geohash" { fn::validation_geohash($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "geometry" { fn::validation_geometry($value, $options.allowed_types, $options.require_valid) }
        ELSE IF $step.rule = "gtin" { fn::validation_gtin($value) }
        ELSE IF $step.rule = "hexadecimal" { fn::validation_hexadecimal($value, $options.min_length, $options.max_length, $options.allow_prefix) }
        ELSE IF $step.rule = "hmac_signature" { fn::validation_hmac_signature($value, $options.encoding, $options.expected_length) }
        ELSE IF $step.rule = "hostname" { fn::validation_hostname($value, $options.allow_single_label) }
        ELSE IF $step.rule = "http_method" { fn::validation_http_method($value, $options.allowed_methods) }
        ELSE IF $step.rule = "http_url" { fn::validation_http_url($value, $options.allow_http, $options.allow_https) }
        ELSE IF $step.rule = "iban" { fn::validation_iban($value, $options.allowed_countries) }
        ELSE IF $step.rule = "idempotency_key" { fn::validation_idempotency_key($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "identifier" { fn::validation_identifier($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "image_height" { fn::validation_image_height($value, $options.min_height, $options.max_height) }
        ELSE IF $step.rule = "image_width" { fn::validation_image_width($value, $options.min_width, $options.max_width) }
        ELSE IF $step.rule = "initials" { fn::validation_initials($value, $options.min_count, $options.max_count) }
        ELSE IF $step.rule = "integer" { fn::validation_integer($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "invoice_number" { fn::validation_invoice_number($value, $options.min_length, $options.max_length, $options.allowed_prefixes) }
        ELSE IF $step.rule = "ip" { fn::validation_ip($value, $options.version) }
        ELSE IF $step.rule = "iso8601" { fn::validation_iso8601($value, $options.allow_fractional_seconds) }
        ELSE IF $step.rule = "jwt_compact" { fn::validation_jwt_compact($value, $options.max_length) }
        ELSE IF $step.rule = "language_code" { fn::validation_language_code($value, $options.allow_alpha3, $options.allowed_codes) }
        ELSE IF $step.rule = "last_name" { fn::validation_last_name($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "latitude" { fn::validation_latitude($value) }
        ELSE IF $step.rule = "locale" { fn::validation_locale($value, $options.require_region) }
        ELSE IF $step.rule = "longitude" { fn::validation_longitude($value) }
        ELSE IF $step.rule = "lowercase" { fn::validation_lowercase($value, $options.trim_value, $options.allow_blank) }
        ELSE IF $step.rule = "luhn" { fn::validation_luhn($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_bucket_name" { fn::validation_lyxal_bucket_name($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_database" { fn::validation_lyxal_database($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_event_name" { fn::validation_lyxal_event_name($value, $options.min_segments, $options.max_segments) }
        ELSE IF $step.rule = "lyxal_function_name" { fn::validation_lyxal_function_name($value, $options.require_namespace, $options.max_length) }
        ELSE IF $step.rule = "lyxal_instance_name" { fn::validation_lyxal_instance_name($value, $options.environment, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_module_name" { fn::validation_lyxal_module_name($value, $options.allowed_prefixes, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_namespace" { fn::validation_lyxal_namespace($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_permission_name" { fn::validation_lyxal_permission_name($value, $options.allowed_actions) }
        ELSE IF $step.rule = "lyxal_role_name" { fn::validation_lyxal_role_name($value, $options.reserved_roles, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "lyxal_storage_path" { fn::validation_lyxal_storage_path($value, $options.required_root, $options.allow_file_extension, $options.max_length) }
        ELSE IF $step.rule = "mac_address" { fn::validation_mac_address($value, $options.allow_hyphen, $options.allow_colon) }
        ELSE IF $step.rule = "max_length" { fn::validation_max_length($value, $options.max_length) }
        ELSE IF $step.rule = "mime_type" { fn::validation_mime_type($value, $options.allowed_types) }
        ELSE IF $step.rule = "min_length" { fn::validation_min_length($value, $options.min_length) }
        ELSE IF $step.rule = "money" { fn::validation_money($value, $options.min_value, $options.max_value, $options.max_scale) }
        ELSE IF $step.rule = "multiple_of" { fn::validation_multiple_of($value, $options.divisor) }
        ELSE IF $step.rule = "negative_number" { fn::validation_negative_number($value) }
        ELSE IF $step.rule = "non_negative_number" { fn::validation_non_negative_number($value) }
        ELSE IF $step.rule = "non_zero" { fn::validation_non_zero($value) }
        ELSE IF $step.rule = "nonce" { fn::validation_nonce($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "not_blank" { fn::validation_not_blank($value) }
        ELSE IF $step.rule = "number" { fn::validation_number($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "is_object" { fn::validation_object($value) }
        ELSE IF $step.rule = "object_keys" { fn::validation_object_keys($value, $options.required_keys, $options.allowed_keys) }
        ELSE IF $step.rule = "object_no_none" { fn::validation_object_no_none($value) }
        ELSE IF $step.rule = "object_no_null" { fn::validation_object_no_null($value) }
        ELSE IF $step.rule = "object_non_empty" { fn::validation_object_non_empty($value) }
        ELSE IF $step.rule = "object_values_type" { fn::validation_object_values_type($value, $options.expected_type, $options.allow_empty) }
        ELSE IF $step.rule = "odd" { fn::validation_odd($value) }
        ELSE IF $step.rule = "optional_string" { fn::validation_optional_string($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "origin" { fn::validation_origin($value, $options.allow_http, $options.allow_https, $options.allow_port) }
        ELSE IF $step.rule = "password_strength" { fn::validation_password_strength($value, $options.min_length, $options.max_length, $options.require_uppercase, $options.require_lowercase, $options.require_digit, $options.require_special) }
        ELSE IF $step.rule = "past_datetime" { fn::validation_past_datetime($value, $options.reference_value, $options.allow_equal, $options.min_age, $options.max_age) }
        ELSE IF $step.rule = "percentage" { fn::validation_percentage($value, $options.min_value, $options.max_value) }
        ELSE IF $step.rule = "phone" { fn::validation_phone($value) }
        ELSE IF $step.rule = "port" { fn::validation_port($value, $options.min_port, $options.max_port) }
        ELSE IF $step.rule = "positive_number" { fn::validation_positive_number($value) }
        ELSE IF $step.rule = "postal_code_fr" { fn::validation_postal_code_fr($value, $options.allow_cedex) }
        ELSE IF $step.rule = "private_key_pem" { fn::validation_private_key_pem($value, $options.allow_encrypted, $options.max_length) }
        ELSE IF $step.rule = "profile_identifier" { fn::validation_profile_identifier($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "public_alias" { fn::validation_public_alias($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "public_key_pem" { fn::validation_public_key_pem($value, $options.max_length) }
        ELSE IF $step.rule = "queue_name" { fn::validation_queue_name($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "record" { fn::validation_record($value, $options.expected_table) }
        ELSE IF $step.rule = "record_exists" { fn::validation_record_exists($value) }
        ELSE IF $step.rule = "record_id" { fn::validation_record_id($value, $options.allowed_tables) }
        ELSE IF $step.rule = "recovery_code" { fn::validation_recovery_code($value, $options.group_count, $options.group_length) }
        ELSE IF $step.rule = "regex" { fn::validation_regex($value, $options.pattern) }
        ELSE IF $step.rule = "required_if" { fn::validation_required_if($value, $options.condition, $options.allow_null) }
        ELSE IF $step.rule = "required_string" { fn::validation_required_string($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "required_unless" { fn::validation_required_unless($value, $options.unless_condition, $options.allow_null) }
        ELSE IF $step.rule = "reserved_words" { fn::validation_reserved_words($value, $options.reserved_words, $options.trim_value) }
        ELSE IF $step.rule = "retry_policy" { fn::validation_retry_policy($value, $options.max_attempts_limit, $options.max_backoff) }
        ELSE IF $step.rule = "semantic_version" { fn::validation_semantic_version($value, $options.allow_v_prefix) }
        ELSE IF $step.rule = "siren" { fn::validation_siren($value) }
        ELSE IF $step.rule = "siret" { fn::validation_siret($value) }
        ELSE IF $step.rule = "slug" { fn::validation_slug($value, $options.max_length) }
        ELSE IF $step.rule = "snake_case_name" { fn::validation_snake_case_name($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "socket_address" { fn::validation_socket_address($value, $options.allow_hostname, $options.allow_ipv4, $options.allow_ipv6) }
        ELSE IF $step.rule = "starts_with" { fn::validation_starts_with($value, $options.prefixes, $options.case_sensitive, $options.trim_value) }
        ELSE IF $step.rule = "storage_path" { fn::validation_storage_path($value, $options.allow_leading_slash, $options.allow_trailing_slash, $options.max_length) }
        ELSE IF $step.rule = "surql_field" { fn::validation_surql_field($value, $options.allow_id, $options.max_length) }
        ELSE IF $step.rule = "surql_field_path" { fn::validation_surql_field_path($value, $options.allow_array_wildcard, $options.allow_numeric_index, $options.max_segments) }
        ELSE IF $step.rule = "surql_function" { fn::validation_surql_function($value, $options.require_namespace, $options.max_segments) }
        ELSE IF $step.rule = "surql_parameter" { fn::validation_surql_parameter($value, $options.allow_reserved) }
        ELSE IF $step.rule = "surql_record_string" { fn::validation_surql_record_string($value, $options.expected_table) }
        ELSE IF $step.rule = "surql_variable" { fn::validation_surql_variable($value, $options.allow_reserved) }
        ELSE IF $step.rule = "time_of_day" { fn::validation_time_of_day($value) }
        ELSE IF $step.rule = "time_string" { fn::validation_time_string($value, $options.require_seconds) }
        ELSE IF $step.rule = "timezone" { fn::validation_timezone($value, $options.allow_utc) }
        ELSE IF $step.rule = "totp_code" { fn::validation_totp_code($value, $options.digits) }
        ELSE IF $step.rule = "totp_secret" { fn::validation_totp_secret($value, $options.min_length, $options.max_length) }
        ELSE IF $step.rule = "tuple_length" { fn::validation_tuple_length($value, $options.expected_length) }
        ELSE IF $step.rule = "tuple_types" { fn::validation_tuple_types($value, $options.expected_types) }
        ELSE IF $step.rule = "ulid" { fn::validation_ulid($value) }
        ELSE IF $step.rule = "unique" { fn::validation_unique($value, $options.target_table, $options.target_field, $options.exclude_record) }
        ELSE IF $step.rule = "unknown_keys_policy" { fn::validation_unknown_keys_policy($value, $options.allowed_keys, $options.policy) }
        ELSE IF $step.rule = "uppercase" { fn::validation_uppercase($value, $options.trim_value, $options.allow_blank) }
        ELSE IF $step.rule = "uri_scheme" { fn::validation_uri_scheme($value, $options.allowed_schemes) }
        ELSE IF $step.rule = "url" { fn::validation_url($value, $options.max_length) }
        ELSE IF $step.rule = "username" { fn::validation_username($value, $options.min_length, $options.max_length, $options.force_lowercase) }
        ELSE IF $step.rule = "uuid" { fn::validation_uuid($value) }
        ELSE IF $step.rule = "uuid_v7" { fn::validation_uuid_v7($value, $options.allow_string) }
        ELSE IF $step.rule = "value_type" { fn::validation_value_type($value, $options.expected_type) }
        ELSE IF $step.rule = "vat_number_fr" { fn::validation_vat_number_fr($value, $options.validate_numeric_key) }
        ELSE IF $step.rule = "webhook_path" { fn::validation_webhook_path($value, $options.allow_parameters, $options.allow_wildcard) }
        ELSE IF $step.rule = "weekday" { fn::validation_weekday($value, $options.allowed_days) }
        ELSE IF $step.rule = "workflow_delay" { fn::validation_workflow_delay($value, $options.min_delay, $options.max_delay, $options.allow_zero) }
        ELSE { THROW "CORE_UNSUPPORTED_OPTION" };
    RETURN IF $result.valid {
        object::extend($state, { value: $result.value })
    } ELSE {
        fn::utils_engine_issue($state, $step.rule, $result.code, $result.details)
    };
}
COMMENT "Aiguillage du domaine validations pour le moteur : appelle le validateur fn::validation_<règle> avec ses options ; un résultat valide remplace state.value par la valeur normalisée, un résultat invalide ajoute l'erreur (code CORE_VALIDATION_*, details) et arrête le pipeline du champ. Passée en closure à fn::utils_engine_run."
PERMISSIONS FULL;
