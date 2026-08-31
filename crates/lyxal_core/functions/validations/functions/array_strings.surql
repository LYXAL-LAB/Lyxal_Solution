-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_strings.surql
-- Fonction     : fn::validation_array_strings
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que tous les éléments d'un tableau sont strictement de type string, avec chaînes vides facultativement interdites.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_blank: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_ITEM_TYPE
-- <FIELD>_BLANK_ITEM_NOT_ALLOWED
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
-- Primitive pure : aucune lecture ou écriture persistante, aucun accès réseau
-- et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - type::is_string()
--   - array::all()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_strings(
    $value: option<any>,
    $field: string,
    $allow_blank: bool
) -> array<string> {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF !array::all($value, |$item| type::is_string($item)) {
        THROW string::concat($clean_field, "_INVALID_ITEM_TYPE");
    };

    IF !$allow_blank
        AND array::any($value, |$item| string::trim($item) = "")
    {
        THROW string::concat($clean_field, "_BLANK_ITEM_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Valide que tous les éléments d'un tableau sont strictement de type string.
"
PERMISSIONS FULL;
