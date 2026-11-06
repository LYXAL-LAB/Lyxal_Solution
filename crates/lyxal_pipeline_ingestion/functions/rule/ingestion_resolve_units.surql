-- ============================================================================
-- FONCTION : fn::ingestion_resolve_units
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution d'un bloc d'unités fournisseurs vers le référentiel de lyxal_base
-- APPEL    : une fois par bloc (worker), et par la résolution de quarantaine ; entrées
--            contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_units($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            raw_units: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_length", options: { max_length: 500 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };

    -- Clé d'alias : majuscules, sans point, tiret ni souligné (« m.l. » → « ML »)
    LET $pairs = array::distinct($report.value.raw_units).map(|$raw| {
        raw: $raw,
        key: string::replace(string::replace(string::replace(fn::sanitize_uppercase($raw), ".", ""), "-", ""), "_", "")
    }).filter(|$pair| $pair.key != "");

    -- 1. Alias de l'ingestion (libellés commerciaux), sinon la clé elle-même
    LET $lookups = SELECT raw, (SELECT VALUE canonical_unit FROM ingestion_unit_alias WHERE raw_alias = $parent.key LIMIT 1)[0] ?? key AS lookup FROM $pairs;

    -- 2. Référentiel de lyxal_base (code Lyxal ou code d'échange) ; seule une unité utilisable est retenue
    LET $base = fn::base_unite_resolve({ codes: IF array::len($lookups) > 0 { array::distinct($lookups.lookup) } ELSE { [] } });
    IF !$base.ok {
        RETURN $base;
    };
    LET $resolved = $base.data;
    LET $rows = SELECT raw, $resolved[lookup] AS hit FROM $lookups;

    RETURN fn::result_ok(object::from_entries(
        $rows.filter(|$row| $row.hit.usable ?? false).map(|$row| [$row.raw, $row.hit.code])
    ));
} COMMENT "Résout un bloc d'unités fournisseurs (500 au plus) : alias de l'ingestion, puis référentiel de lyxal_base (fn::base_unite_resolve) ; renvoie { <brut>: <code> } pour les seules unités utilisables";
