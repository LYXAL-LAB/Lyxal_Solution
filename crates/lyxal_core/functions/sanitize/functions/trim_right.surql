-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/trim_right.surql
-- Fonction     : fn::sanitize_trim_right
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Supprime uniquement les caractères d'espacement placés à la fin d'une chaîne.
--
-- Règles appliquées
-- -----------------
--   1. Les espaces de début sont conservés.
--   2. La suppression repose sur une expression régulière ancrée à la fin.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
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

DEFINE FUNCTION OVERWRITE fn::sanitize_trim_right(
    $value: option<any>,
    $field: string
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

    RETURN string::replace(
        $value,
        <regex>"\s+$",
        ""
    );
}
COMMENT "
Supprime uniquement les espaces placés à la fin d'une chaîne.
"
PERMISSIONS FULL;
