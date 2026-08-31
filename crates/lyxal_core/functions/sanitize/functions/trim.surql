-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/trim.surql
-- Fonction     : fn::sanitize_trim
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Supprime les caractères d'espacement placés au début et à la fin d'une chaîne.
--
-- Règles appliquées
-- -----------------
--   1. NONE, NULL et les types non textuels sont refusés.
--   2. Les espaces internes sont conservés.
--   3. La chaîne vide est autorisée après sanitation.
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

DEFINE FUNCTION OVERWRITE fn::sanitize_trim(
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

    RETURN string::trim($value);
}
COMMENT "
Supprime les espaces de début et de fin d'une chaîne.
"
PERMISSIONS FULL;
