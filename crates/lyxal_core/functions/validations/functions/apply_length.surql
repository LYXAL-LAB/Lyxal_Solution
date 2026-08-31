-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/apply_length.surql
-- Fonction     : fn::validation_apply_length
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique des bornes de longueur à une chaîne, un tableau ou un objet.
--
-- Règles appliquées
-- -----------------
--   1. NONE ignore la règle.
--   2. Les types pris en charge sont string, array et object.
--   3. La plage est inclusive.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_length: option<int>
-- $max_length: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_LENGTH_NOT_SUPPORTED
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_LENGTH_RANGE
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
-- Sécurité
-- --------
-- Le moteur utilise un ensemble fermé de règles. Il n'exécute jamais un nom
-- de fonction arbitraire fourni dans un schéma.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_apply_length(
    $value: option<any>,
    $field: string,
    $min_length: option<int>,
    $max_length: option<int>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_length IS NOT NONE AND $min_length < 0 {
        THROW "VALIDATION_INVALID_LENGTH_RANGE";
    };

    IF $max_length IS NOT NONE AND $max_length < 0 {
        THROW "VALIDATION_INVALID_LENGTH_RANGE";
    };

    IF $min_length IS NOT NONE
        AND $max_length IS NOT NONE
        AND $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_LENGTH_RANGE";
    };

    IF $value IS NONE {
        RETURN $value;
    };

    LET $length =
        IF type::is_string($value) {
            string::len($value)
        }
        ELSE IF type::is_array($value) {
            array::len($value)
        }
        ELSE IF type::is_object($value) {
            object::len($value)
        }
        ELSE {
            NONE
        };

    IF $length IS NONE {
        THROW string::concat(
            $clean_field,
            "_LENGTH_NOT_SUPPORTED"
        );
    };

    IF $min_length IS NOT NONE AND $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $max_length IS NOT NONE AND $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    RETURN $value;
}
COMMENT "
Applique des bornes de longueur à une chaîne, un tableau ou un objet.
"
PERMISSIONS FULL;
