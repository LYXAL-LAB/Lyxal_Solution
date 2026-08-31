-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/contains.surql
-- Fonction     : fn::validation_contains
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une chaîne obligatoire contient au moins une sous-chaîne attendue.
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
-- $needles: array<string>
--   Liste non vide des sous-chaînes recherchées.
--
-- $case_sensitive: bool
--   Active ou désactive la sensibilité à la casse.
--
-- $trim_value: bool
--   Nettoie la valeur avant validation.
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
-- <FIELD>_REQUIRED_CONTENT_MISSING
--   Aucune sous-chaîne attendue n'a été trouvée.
--
-- VALIDATION_EMPTY_NEEDLES
--   La liste des sous-chaînes est vide.
--
-- VALIDATION_INVALID_NEEDLE
--   Une sous-chaîne recherchée est vide.
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
--   - string::contains()
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

DEFINE FUNCTION OVERWRITE fn::validation_contains(
    $value: option<any>,
    $field: string,
    $needles: array<string>,
    $case_sensitive: bool,
    $trim_value: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF array::len($needles) = 0 { THROW "VALIDATION_EMPTY_NEEDLES"; };

    LET $clean_needles = array::map(
        $needles,
        |$needle| string::trim($needle)
    );

    IF array::any($clean_needles, |$needle| $needle = "") {
        THROW "VALIDATION_INVALID_NEEDLE";
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

    LET $matches = array::any(
        $clean_needles,
        |$needle| string::contains(
            $comparison_value,
            IF $case_sensitive { $needle } ELSE { string::lowercase($needle) }
        )
    );

    IF !$matches {
        THROW string::concat($clean_field, "_REQUIRED_CONTENT_MISSING");
    };

    RETURN $clean_value;
}
COMMENT "
Valide qu'une chaîne obligatoire contient au moins une sous-chaîne attendue.
"
PERMISSIONS FULL;
