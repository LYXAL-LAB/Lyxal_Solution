-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/username.surql
-- Fonction     : fn::validation_username
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom d'utilisateur technique : longueur configurable, caractères ASCII autorisés, absence de séparateur en début ou fin et absence de séparateurs répétés.
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
--   Nom d'utilisateur obligatoire.
--
-- $field: string
--   Nom technique utilisé pour les erreurs.
--
-- $min_length: int
--   Longueur minimale inclusive.
--
-- $max_length: int
--   Longueur maximale inclusive.
--
-- $force_lowercase: bool
--   Exige une valeur déjà en minuscules.
--
-- Valeur retournée
-- ----------------
-- string — nom d'utilisateur nettoyé et validé.
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
--   Le nom d'utilisateur est vide.
--
-- <FIELD>_TOO_SHORT
--   La longueur est inférieure au minimum.
--
-- <FIELD>_TOO_LONG
--   La longueur dépasse le maximum.
--
-- <FIELD>_INVALID_USERNAME
--   La forme générale est invalide.
--
-- <FIELD>_INVALID_BOUNDARY
--   La valeur commence ou finit par '.', '_' ou '-'.
--
-- <FIELD>_REPEATED_SEPARATOR
--   La valeur contient '..', '__' ou '--'.
--
-- <FIELD>_NOT_LOWERCASE
--   Les minuscules sont imposées mais la valeur contient des majuscules.
--
-- VALIDATION_INVALID_USERNAME_LENGTH
--   Les limites de longueur sont invalides.
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
--   - string::len()
--   - string::matches()
--   - string::starts_with()
--   - string::ends_with()
--   - string::contains()
--   - string::lowercase()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

--
-- Format accepté
-- --------------
--   - lettres ASCII A-Z et a-z ;
--   - chiffres 0-9 ;
--   - point, tiret bas et tiret ;
--   - aucun espace ;
--   - aucun séparateur en première ou dernière position ;
--   - aucun séparateur identique répété.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_username(
    $value: option<any>,
    $field: string,
    $min_length: int,
    $max_length: int,
    $force_lowercase: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $min_length < 1
        OR $max_length < 1
        OR $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_USERNAME_LENGTH";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);
    LET $length = string::len($clean_value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };
    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };
    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };
    IF !string::matches($clean_value, "^[A-Za-z0-9._-]+$") {
        THROW string::concat($clean_field, "_INVALID_USERNAME");
    };

    IF string::starts_with($clean_value, ".")
        OR string::starts_with($clean_value, "_")
        OR string::starts_with($clean_value, "-")
        OR string::ends_with($clean_value, ".")
        OR string::ends_with($clean_value, "_")
        OR string::ends_with($clean_value, "-")
    {
        THROW string::concat($clean_field, "_INVALID_BOUNDARY");
    };

    IF string::contains($clean_value, "..")
        OR string::contains($clean_value, "__")
        OR string::contains($clean_value, "--")
    {
        THROW string::concat($clean_field, "_REPEATED_SEPARATOR");
    };

    IF $force_lowercase
        AND $clean_value != string::lowercase($clean_value)
    {
        THROW string::concat($clean_field, "_NOT_LOWERCASE");
    };

    RETURN $clean_value;
}
COMMENT "
Valide un nom d'utilisateur ASCII composé de lettres, chiffres, point, tiret
bas et tiret. Contrôle la longueur, les limites, les séparateurs répétés et
facultativement l'usage exclusif des minuscules.
"
PERMISSIONS FULL;
