-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_length.surql
-- Fonction     : fn::validation_pipeline_length
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une contrainte min_length ou max_length à une valeur.
--
-- Règles appliquées
-- -----------------
--   1. NONE est retourné sans modification.
--   2. Les types string, array et object sont pris en charge.
--   3. Le mode doit être min_length ou max_length.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $mode: string
-- $limit: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_LENGTH_NOT_SUPPORTED
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_LENGTH_LIMIT
-- VALIDATION_UNSUPPORTED_LENGTH_MODE
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
-- Le pipeline utilise uniquement des étapes explicitement prises en charge.
-- Aucun nom de fonction arbitraire n'est exécuté.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_length(
    $value: option<any>,
    $field: string,
    $mode: string,
    $limit: int
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $limit < 0 {
        THROW "VALIDATION_INVALID_LENGTH_LIMIT";
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

    LET $clean_mode = string::lowercase(string::trim($mode));

    IF $clean_mode = "min_length" {
        IF $length < $limit {
            THROW string::concat($clean_field, "_TOO_SHORT");
        };
        RETURN $value;
    };

    IF $clean_mode = "max_length" {
        IF $length > $limit {
            THROW string::concat($clean_field, "_TOO_LONG");
        };
        RETURN $value;
    };

    THROW "VALIDATION_UNSUPPORTED_LENGTH_MODE";
}
COMMENT "
Applique une étape min_length ou max_length.
"
PERMISSIONS FULL;
