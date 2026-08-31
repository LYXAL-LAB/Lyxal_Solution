-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/postal_code_fr.surql
-- Fonction     : fn::validation_postal_code_fr
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un code postal français à cinq chiffres.
--
-- Règles appliquées
-- -----------------
--   1. Le code principal contient exactement cinq chiffres.
--   2. Lorsque CEDEX est autorisé, le suffixe textuel peut suivre le code.
--   3. La fonction ne vérifie pas l'existence réelle de la commune ou du bureau postal.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_cedex: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et, lorsque cela est indiqué, normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_POSTAL_CODE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur ne possède pas le type attendu.
--
-- <FIELD>_BLANK_NOT_ALLOWED
--   La chaîne est vide après string::trim().
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune résolution géographique externe ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::uppercase()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_postal_code_fr(
    $value: option<any>,
    $field: string,
    $allow_cedex: bool
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
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

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    LET $postal_code = string::uppercase($clean_value);

    LET $pattern = IF $allow_cedex {
        "^[0-9]{5}(?: CEDEX(?: [0-9]{1,2})?)?$"
    } ELSE {
        "^[0-9]{5}$"
    };

    IF !string::matches($postal_code, $pattern) {
        THROW string::concat(
            $clean_field,
            "_INVALID_POSTAL_CODE"
        );
    };

    RETURN $postal_code;
}
COMMENT "
Valide lexicalement un code postal français à cinq chiffres, avec CEDEX
facultatif.
"
PERMISSIONS FULL;
