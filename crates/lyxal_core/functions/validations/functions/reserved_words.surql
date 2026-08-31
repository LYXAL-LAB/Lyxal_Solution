-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/reserved_words.surql
-- Fonction     : fn::validation_reserved_words
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Refuse un identifiant textuel lorsqu'il correspond exactement à un mot réservé. La comparaison est volontairement insensible à la casse.
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
-- $reserved_words: array<string>
--   Liste non vide des mots réservés.
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
-- <FIELD>_RESERVED_WORD
--   La valeur correspond à un mot réservé.
--
-- VALIDATION_EMPTY_RESERVED_WORDS
--   La liste des mots réservés est vide.
--
-- VALIDATION_INVALID_RESERVED_WORD
--   Un mot réservé est vide.
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

DEFINE FUNCTION OVERWRITE fn::validation_reserved_words(
    $value: option<any>,
    $field: string,
    $reserved_words: array<string>,
    $trim_value: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF array::len($reserved_words) = 0 {
        THROW "VALIDATION_EMPTY_RESERVED_WORDS";
    };

    LET $clean_reserved = array::map(
        $reserved_words,
        |$word| string::lowercase(string::trim($word))
    );

    IF array::any($clean_reserved, |$word| $word = "") {
        THROW "VALIDATION_INVALID_RESERVED_WORD";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = IF $trim_value { string::trim($value) } ELSE { $value };
    LET $normalized_value = string::lowercase($clean_value);

    IF array::any($clean_reserved, |$word| $normalized_value = $word) {
        THROW string::concat($clean_field, "_RESERVED_WORD");
    };

    RETURN $clean_value;
}
COMMENT "
Refuse une chaîne lorsqu'elle correspond exactement, sans tenir compte de la
casse, à un mot réservé.
"
PERMISSIONS FULL;
