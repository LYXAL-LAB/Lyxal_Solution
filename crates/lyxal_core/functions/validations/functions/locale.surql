-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/locale.surql
-- Fonction : fn::validation_locale
--
-- Valide une étiquette de langue BCP 47 langue[-Script][-RÉGION] (« fr », « fr-FR »,
-- « fr_FR », « zh-Hant-TW », « es-419 ») ; la région est exigée si demandé. La
-- valeur renvoyée est canonique : langue en minuscules, script en casse de titre,
-- région en majuscules (« zh-Hant-TW »). Les variantes et extensions sont refusées.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $require_region : bool — true pour exiger la région
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'étiquette canonique (« fr », « fr-FR », « zh-Hant-TW »), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $locale = fn::validation_locale($params.locale, false);
--   IF !$locale.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $locale.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_locale(
    $value: any,
    $require_region: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $parts = string::split(string::replace($clean, "_", "-"), "-");
    LET $count = array::len($parts);
    LET $language = string::lowercase($parts[0]);
    -- Deuxième segment : script (4 lettres) ou région ; troisième : région seulement
    LET $second = $parts[1];
    LET $has_script = $second IS NOT NONE AND string::matches($second, "^[A-Za-z]{4}$");
    LET $script = IF $has_script { string::uppercase(string::slice($second, 0, 1)) + string::lowercase(string::slice($second, 1)) } ELSE { NONE };
    LET $region_raw = IF $has_script { $parts[2] } ELSE IF $count = 2 { $second } ELSE { NONE };
    LET $region = IF $region_raw IS NONE { NONE } ELSE { string::uppercase($region_raw) };
    IF $count > 3 OR ($count = 3 AND !$has_script) OR !string::matches($language, "^[a-z]{2,3}$")
        OR ($region IS NOT NONE AND !string::matches($region, "^([A-Z]{2}|[0-9]{3})$")) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "locale" } };
    };
    IF $require_region AND $region IS NONE {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "locale", require_region: true } };
    };
    LET $tag = array::join(array::filter([$language, $script, $region], |$v| $v IS NOT NONE), "-");
    RETURN { valid: true, value: $tag, code: NONE, details: {} };
}
COMMENT "Valide une étiquette de langue BCP 47 langue[-Script][-RÉGION] (« fr », « fr_FR », « zh-Hant-TW », « es-419 ») ; la région est exigée si demandé. Valeur canonique (« zh-Hant-TW »). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
