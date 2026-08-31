-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/ascii.surql
-- Fonction     : fn::validation_ascii
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une chaîne obligatoire contient uniquement des caractères ASCII.
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
-- $trim_value: bool
--   Nettoie la valeur avant validation.
--
-- $allow_blank: bool
--   Autorise ou refuse une chaîne vide après nettoyage.
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
-- <FIELD>_BLANK_NOT_ALLOWED
--   La chaîne est vide alors que les chaînes vides sont interdites.
--
-- <FIELD>_NON_ASCII_CHARACTERS
--   La chaîne contient au moins un caractère non ASCII.
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
--   - string::is_ascii()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_ascii(
    $value: option<any>,
    $field: string,
    $trim_value: bool,
    $allow_blank: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = IF $trim_value { string::trim($value) } ELSE { $value };

    IF !$allow_blank AND $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };
    IF !string::is_ascii($clean_value) {
        THROW string::concat($clean_field, "_NON_ASCII_CHARACTERS");
    };

    RETURN $clean_value;
}
COMMENT "
Valide qu'une chaîne obligatoire contient uniquement des caractères ASCII.
"
PERMISSIONS FULL;
