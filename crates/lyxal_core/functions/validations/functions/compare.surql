-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/compare.surql
-- Fonction     : fn::validation_compare
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Compare deux valeurs avec un opérateur explicitement autorisé.
--
-- Règles appliquées
-- -----------------
--   1. Les deux valeurs sont obligatoires.
--   2. Les opérateurs pris en charge sont eq, neq, gt, gte, lt et lte.
--   3. La comparaison utilise la sémantique native SurrealQL.
--
-- Paramètres
-- ----------
-- $left: option<any>
-- $right: option<any>
-- $field: string
-- $operator: string
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_COMPARISON_FAILED
-- VALIDATION_UNSUPPORTED_COMPARISON_OPERATOR
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun appel réseau ;
--   - aucune exécution dynamique de code ;
--   - aucun effet secondaire.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compare(
    $left: option<any>,
    $right: option<any>,
    $field: string,
    $operator: string
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $left IS NONE OR $right IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    LET $clean_operator = string::lowercase(
        string::trim($operator)
    );

    LET $valid = IF $clean_operator = "eq" {
        $left = $right
    } ELSE IF $clean_operator = "neq" {
        $left != $right
    } ELSE IF $clean_operator = "gt" {
        $left > $right
    } ELSE IF $clean_operator = "gte" {
        $left >= $right
    } ELSE IF $clean_operator = "lt" {
        $left < $right
    } ELSE IF $clean_operator = "lte" {
        $left <= $right
    } ELSE {
        NONE
    };

    IF $valid IS NONE {
        THROW "VALIDATION_UNSUPPORTED_COMPARISON_OPERATOR";
    };

    IF !$valid {
        THROW string::concat(
            $clean_field,
            "_COMPARISON_FAILED"
        );
    };

    RETURN {
        left: $left,
        right: $right,
        operator: $clean_operator
    };
}
COMMENT "
Compare deux valeurs avec un opérateur explicitement autorisé.
"
PERMISSIONS FULL;
