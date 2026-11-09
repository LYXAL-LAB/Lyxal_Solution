-- ============================================================================
-- FONCTIONS : choix de la langue d'une requête
-- MODULE    : lyxal_i18n
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_chain (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_chain($tag: string) -> array<string> {
    LET $known = (SELECT VALUE fallback FROM ONLY type::record("i18n_locale", $tag));
    IF $known IS NOT NONE { RETURN array::concat([$tag], $known); };
    -- Étiquette absente du référentiel : troncature (RFC 4647, correspondance « lookup »)
    LET $parts = string::split($tag, "-");
    RETURN array::map(<array> (0..array::len($parts)), |$i| array::join(array::slice($parts, 0, array::len($parts) - $i), "-"));
} COMMENT "Interne : l'étiquette suivie de sa chaîne de repli (référentiel CLDR, sinon troncature)";

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_resolve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            candidates: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $default = (SELECT VALUE default_locale.tag FROM ONLY i18n_settings:installation);
    -- Première langue active d'un candidat ou de sa chaîne de repli ; les candidats invalides sont ignorés
    LET $tags = array::filter(array::map($p.candidates, |$c| fn::validation_locale($c, false).value), |$t| $t IS NOT NONE);
    LET $found = array::find(array::flatten(array::map($tags, |$t| fn::i18n_locale_chain($t))),
        |$t| (SELECT VALUE active FROM ONLY type::record("i18n_locale", $t)) = true);
    LET $locale = $found ?? $default;
    LET $record = (SELECT language, fallback FROM ONLY type::record("i18n_locale", $locale));
    RETURN fn::result_ok({
        locale: $locale,
        language: $record.language,
        fallback: array::distinct(array::concat($record.fallback, [$default])).filter(|$t| $t != $locale),
        matched: $found IS NOT NONE
    });
} COMMENT "Choisit la langue d'une requête parmi des candidats par ordre de préférence ({ candidates, au plus 20 }) : première langue active d'un candidat ou de sa chaîne de repli CLDR, sinon la langue par défaut. { locale, language, fallback (jusqu'à la langue par défaut), matched }";
