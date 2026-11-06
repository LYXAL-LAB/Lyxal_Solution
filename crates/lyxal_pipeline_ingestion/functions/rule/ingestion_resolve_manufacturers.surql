-- ============================================================================
-- FONCTION : fn::ingestion_resolve_manufacturers
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution d'un bloc de fabricants ou de marques par leurs alias
-- APPEL    : une fois par bloc (worker) ; entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_manufacturers($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            raw_names: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_length", options: { max_length: 500 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };

    -- Nom normalisé : majuscules, ponctuation (. , ;) remplacée par un espace, espaces réduits ;
    -- variante sans suffixe juridique ou géographique, retirés de la fin, dans cet ordre
    LET $suffixes = [" SAS", " SA", " SARL", " EURL", " GMBH", " LTD", " INC", " CORP", " SPA", " SL", " FRANCE", " EUROPE", " INTERNATIONAL", " DISTRIBUTION"];
    LET $pairs = array::distinct($report.value.raw_names).map(|$raw| {
        LET $exact = fn::sanitize_uppercase($raw);
        LET $key = fn::sanitize_trim(fn::sanitize_collapse_whitespace(string::replace(string::replace(string::replace($exact, ".", " "), ",", " "), ";", " ")));
        RETURN { raw: $raw, exact: $exact, key: $key };
    });
    LET $prepared = SELECT
        raw,
        exact,
        key,
        array::fold($suffixes, key, |$acc, $suffix| IF string::ends_with($acc, $suffix) { fn::sanitize_trim(string::slice($acc, 0, string::len($acc) - string::len($suffix))) } ELSE { $acc }) AS stripped
        FROM $pairs;

    -- Alias sur la forme exacte (majuscules, comme raw_alias est enregistré), puis sur le nom
    -- normalisé, puis sur le nom sans suffixe
    LET $rows = SELECT
        raw,
        stripped,
        (SELECT canonical_name, holding_or_group, is_verified FROM ingestion_manufacturer_alias WHERE raw_alias = $parent.exact LIMIT 1)[0]
            ?? (SELECT canonical_name, holding_or_group, is_verified FROM ingestion_manufacturer_alias WHERE raw_alias = $parent.key LIMIT 1)[0]
            ?? (SELECT canonical_name, holding_or_group, is_verified FROM ingestion_manufacturer_alias WHERE raw_alias = $parent.stripped LIMIT 1)[0] AS hit
        FROM $prepared;

    RETURN fn::result_ok(object::from_entries($rows.map(|$row| [
        $row.raw,
        IF $row.hit != NONE {
            { canonical_name: $row.hit.canonical_name, holding_or_group: $row.hit.holding_or_group, is_verified: $row.hit.is_verified, resolved: true }
        } ELSE {
            { canonical_name: $row.stripped, holding_or_group: NONE, is_verified: false, resolved: false }
        }
    ])));
} COMMENT "Résout un bloc de fabricants ou de marques (500 au plus) par leurs alias : forme exacte, puis nom normalisé, puis sans suffixe juridique ; un nom inconnu est renvoyé normalisé avec resolved = false";
