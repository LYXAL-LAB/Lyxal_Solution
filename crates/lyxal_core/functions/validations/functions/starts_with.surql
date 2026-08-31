-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/starts_with.surql
-- Fonction     : fn::validation_starts_with
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une chaîne obligatoire commence par au moins un préfixe autorisé. La comparaison peut être sensible ou insensible à la casse.
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
-- $prefixes: array<string>
--   Liste non vide des préfixes autorisés.
--
-- $case_sensitive: bool
--   Active ou désactive la sensibilité à la casse.
--
-- $trim_value: bool
--   Nettoie la valeur avec string::trim() avant validation.
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
-- <FIELD>_INVALID_PREFIX
--   La chaîne ne commence par aucun préfixe autorisé.
--
-- VALIDATION_EMPTY_PREFIXES
--   La liste des préfixes est vide.
--
-- VALIDATION_INVALID_PREFIX
--   Un préfixe est vide après nettoyage.
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
--   - string::starts_with()
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

DEFINE FUNCTION OVERWRITE fn::validation_starts_with(
    $value: option<any>,
    $field: string,
    $prefixes: array<string>,
    $case_sensitive: bool,
    $trim_value: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF array::len($prefixes) = 0 { THROW "VALIDATION_EMPTY_PREFIXES"; };

    LET $clean_prefixes = array::map(
        $prefixes,
        |$prefix| string::trim($prefix)
    );

    IF array::any($clean_prefixes, |$prefix| $prefix = "") {
        THROW "VALIDATION_INVALID_PREFIX";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = IF $trim_value {
        string::trim($value)
    } ELSE {
        $value
    };

    LET $comparison_value = IF $case_sensitive {
        $clean_value
    } ELSE {
        string::lowercase($clean_value)
    };

    LET $matches = array::any(
        $clean_prefixes,
        |$prefix| string::starts_with(
            $comparison_value,
            IF $case_sensitive { $prefix } ELSE { string::lowercase($prefix) }
        )
    );

    IF !$matches {
        THROW string::concat($clean_field, "_INVALID_PREFIX");
    };

    RETURN $clean_value;
}
COMMENT "
Valide qu'une chaîne obligatoire commence par au moins un préfixe autorisé.
La comparaison peut être sensible ou insensible à la casse.
"
PERMISSIONS FULL;
