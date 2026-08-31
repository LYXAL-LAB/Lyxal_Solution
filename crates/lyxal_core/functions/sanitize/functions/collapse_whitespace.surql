-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/collapse_whitespace.surql
-- Fonction     : fn::sanitize_collapse_whitespace
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Remplace toute suite de caractères d'espacement par un espace ASCII unique.
--
-- Règles appliquées
-- -----------------
--   1. Les espaces, tabulations et retours à la ligne sont regroupés.
--   2. Un trim final supprime l'espace produit aux extrémités.
--   3. Le contenu non blanc est conservé.
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

DEFINE FUNCTION OVERWRITE fn::sanitize_collapse_whitespace(
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

    RETURN string::trim(
        string::replace(
            $value,
            <regex>"\s+",
            " "
        )
    );
}
COMMENT "
Réduit toutes les suites d'espacement à un espace ASCII unique.
"
PERMISSIONS FULL;
