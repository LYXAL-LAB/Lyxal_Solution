-- ============================================================================
-- FONCTION : fn::base_unite_type_create
-- MODULE   : lyxal_base
-- RÔLE     : Création d'un type d'unité de mesure
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_type_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }, { rule: "alphanumeric", options: { trim_value: true } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: { code: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 40);
    LET $language = $p.language;
    LET $record_id = type::record("base_unite_type", $p.code);

    IF record::exists($record_id) {
        RETURN fn::error_result("BASE_UNITE_TYPE_ALREADY_EXISTS", $language, { code: $p.code });
    };

    LET $created = (CREATE ONLY $record_id CONTENT { code: $p.code, enabled: true });
    IF $created == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite_type" });
    };
    -- Libellé : texte source de la clé lyxal_i18n ; son échec annule la création
    LET $failure = fn::base_libelle_create("unite_type", $p.code, $p.libelle);
    IF $failure IS NOT NONE {
        DELETE $record_id;
        RETURN fn::error_result("BASE_LIBELLE_WRITE_FAILED", $language, { cause: $failure });
    };
    RETURN fn::result_ok(object::extend($created, { libelle: $p.libelle }));
} COMMENT "Crée un type d'unité de mesure (code alphanumérique en majuscules, unique ; libellé : texte source de la clé base.unite_type_<code> de lyxal_i18n)";
