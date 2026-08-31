-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/forbidden_values.surql
-- Fonction     : fn::validation_forbidden_values
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Refuse une chaîne lorsque sa valeur complète appartient à une liste interdite.
--
-- Principes
-- ----------
--   - validation stricte du type reçu ;
--   - aucune conversion implicite ;
--   - codes d'erreur stables construits depuis le nom technique du champ ;
--   - aucune lecture ni écriture persistante ;
--   - retour de la chaîne validée, éventuellement nettoyée avec string::trim().
--
-- Paramètres
-- ----------
-- $value: option<any>
--   Chaîne obligatoire à contrôler.
--
-- $field: string
--   Nom technique utilisé pour les erreurs.
--
-- $forbidden_values: array<string>
--   Liste des valeurs complètes interdites.
--
-- $case_sensitive: bool
--   Active ou désactive la sensibilité à la casse.
--
-- $trim_value: bool
--   Nettoie la valeur avant comparaison.
--
-- Valeur retournée
-- ----------------
-- string — chaîne validée.
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur n'est pas strictement de type string.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- <FIELD>_FORBIDDEN_VALUE
--   La valeur appartient à la liste interdite.
--
-- VALIDATION_EMPTY_FORBIDDEN_VALUES
--   La liste interdite est vide.
--
-- VALIDATION_INVALID_FORBIDDEN_VALUE
--   Une valeur interdite est vide.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure. Elle ne consulte aucune table, ne
-- modifie aucune donnée et ne dépend pas du contexte d'authentification.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::lowercase()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - array::len()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_forbidden_values(
    $value: option<any>,
    $field: string,
    $forbidden_values: array<string>,
    $case_sensitive: bool,
    $trim_value: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF array::len($forbidden_values) = 0 {
        THROW "VALIDATION_EMPTY_FORBIDDEN_VALUES";
    };

    LET $clean_forbidden = array::map(
        $forbidden_values,
        |$item| string::trim($item)
    );

    IF array::any($clean_forbidden, |$item| $item = "") {
        THROW "VALIDATION_INVALID_FORBIDDEN_VALUE";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = IF $trim_value { string::trim($value) } ELSE { $value };
    LET $comparison_value = IF $case_sensitive {
        $clean_value
    } ELSE {
        string::lowercase($clean_value)
    };

    LET $is_forbidden = array::any(
        $clean_forbidden,
        |$item| $comparison_value =
            IF $case_sensitive { $item } ELSE { string::lowercase($item) }
    );

    IF $is_forbidden {
        THROW string::concat($clean_field, "_FORBIDDEN_VALUE");
    };

    RETURN $clean_value;
}
COMMENT "
Refuse une chaîne lorsque sa valeur complète appartient à une liste interdite.
"
PERMISSIONS FULL;
