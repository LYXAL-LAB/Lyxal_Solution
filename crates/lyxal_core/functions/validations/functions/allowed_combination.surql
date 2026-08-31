-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/allowed_combination.surql
-- Fonction     : fn::validation_allowed_combination
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'un tableau de valeurs correspond exactement à l'une des combinaisons autorisées.
--
-- Règles appliquées
-- -----------------
--   1. La liste des combinaisons autorisées doit être non vide.
--   2. L'ordre et les types sont significatifs.
--   3. La comparaison utilise l'égalité stricte SurrealQL.
--
-- Paramètres
-- ----------
-- $values: array<any>
-- $field: string
-- $allowed_combinations: array<array<any>>
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_COMBINATION_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_COMBINATIONS
-- VALIDATION_INVALID_ALLOWED_COMBINATION_LENGTH
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

DEFINE FUNCTION OVERWRITE fn::validation_allowed_combination(
    $values: array<any>,
    $field: string,
    $allowed_combinations: array<array<any>>
) -> array<any> {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF array::len($allowed_combinations) = 0 {
        THROW "VALIDATION_EMPTY_ALLOWED_COMBINATIONS";
    };

    LET $expected_length = array::len($values);

    IF array::any(
        $allowed_combinations,
        |$combination| array::len($combination) != $expected_length
    ) {
        THROW "VALIDATION_INVALID_ALLOWED_COMBINATION_LENGTH";
    };

    IF !array::any(
        $allowed_combinations,
        |$combination| $combination = $values
    ) {
        THROW string::concat(
            $clean_field,
            "_COMBINATION_NOT_ALLOWED"
        );
    };

    RETURN $values;
}
COMMENT "
Valide qu'un tuple de valeurs correspond exactement à une combinaison autorisée.
"
PERMISSIONS FULL;
