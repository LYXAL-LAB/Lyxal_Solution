-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/remove_control_chars.surql
-- Fonction     : fn::sanitize_remove_control_chars
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Supprime les caractères de contrôle ASCII, avec conservation facultative des tabulations et retours à la ligne.
--
-- Règles appliquées
-- -----------------
--   1. Les plages U+0000–U+001F et U+007F sont visées.
--   2. Lorsque preserve_layout est vrai, TAB, LF et CR sont conservés.
--   3. Les caractères Unicode invisibles sont traités par sanitize_normalize_unicode.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $preserve_layout: bool
--
-- Valeur retournée
-- ----------------
-- Retourne une chaîne nettoyée.
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Propriétés
-- -----------
--   - fonction pure ;
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune conversion implicite d'un type non textuel ;
--   - résultat déterministe pour une même entrée.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_control_chars(
    $value: option<any>,
    $field: string,
    $preserve_layout: bool
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_string($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    LET $pattern = IF $preserve_layout {
        "[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]"
    } ELSE {
        "[\x00-\x1F\x7F]"
    };

    RETURN string::replace(
        $value,
        <regex>$pattern,
        ""
    );
}
COMMENT "
Supprime les caractères de contrôle ASCII avec conservation de mise en page
facultative.
"
PERMISSIONS FULL;
