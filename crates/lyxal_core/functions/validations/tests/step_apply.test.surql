-- lyxal-test: assertions
-- Tests de fn::validation_step_apply (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur valide normalisée
RETURN fn::validation_step_apply(fn::utils_engine_state(" A@Example.com ", "f", NONE), { rule: "email", options: { max_length: 254 } }).value == "A@Example.com";

-- test: valeur invalide : erreur et arrêt
RETURN fn::validation_step_apply(fn::utils_engine_state("x", "f", NONE), { rule: "email", options: { max_length: 254 } }).issues == [{ path: "f", rule: "email", code: "CORE_VALIDATION_FORMAT", details: { expected: "email" } }];

-- test: arrêt positionné
RETURN fn::validation_step_apply(fn::utils_engine_state("x", "f", NONE), { rule: "email", options: { max_length: 254 } }).stop;

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_step_apply(fn::utils_engine_state(1, "", NONE), { rule: "inconnue", options: {} });

-- test: aiguillage : une règle de chaque groupe d'initiales atteinte
RETURN ["age_range", "array_without_null", "bic", "bytes", "card_pan", "currency_code", "date", "duration", "email", "even", "filesize", "gtin", "http_method", "iban", "ip", "latitude", "lyxal_permission_name", "mime_type", "number", "object_no_null", "odd", "phone", "positive_number", "record_id", "required_string", "siren", "surql_record_string", "time_of_day", "ulid", "uuid", "weekday"].all(|$rule| fn::validation_step_apply(fn::utils_engine_state(NONE, "f", NONE), { rule: $rule, options: {} }).path == "f");
