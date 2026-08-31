-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/object_keys.surql
-- Fonction     : fn::validation_object_keys
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide les clés obligatoires et les clés autorisées d'un objet.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $required_keys: option<array<string>>
-- $allowed_keys: option<array<string>>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_MISSING_REQUIRED_KEY
-- <FIELD>_UNKNOWN_KEY
-- VALIDATION_EMPTY_REQUIRED_KEY
-- VALIDATION_EMPTY_ALLOWED_KEY
-- VALIDATION_REQUIRED_KEY_NOT_ALLOWED
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
--   - type::is_object()
--   - object::keys()
--   - array::map()
--   - array::any()
--   - array::all()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_keys(
    $value: option<any>,
    $field: string,
    $required_keys: option<array<string>>,
    $allowed_keys: option<array<string>>
) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    LET $clean_required = IF $required_keys IS NONE {
        NONE
    } ELSE {
        array::map($required_keys, |$key| string::trim($key))
    };

    LET $clean_allowed = IF $allowed_keys IS NONE {
        NONE
    } ELSE {
        array::map($allowed_keys, |$key| string::trim($key))
    };

    IF $clean_required IS NOT NONE
        AND array::any($clean_required, |$key| $key = "")
    {
        THROW "VALIDATION_EMPTY_REQUIRED_KEY";
    };

    IF $clean_allowed IS NOT NONE
        AND array::any($clean_allowed, |$key| $key = "")
    {
        THROW "VALIDATION_EMPTY_ALLOWED_KEY";
    };

    IF $clean_required IS NOT NONE
        AND $clean_allowed IS NOT NONE
        AND !array::all(
            $clean_required,
            |$key| array::contains($clean_allowed, $key)
        )
    {
        THROW "VALIDATION_REQUIRED_KEY_NOT_ALLOWED";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $keys = object::keys($value);

    IF $clean_required IS NOT NONE
        AND !array::all(
            $clean_required,
            |$key| array::contains($keys, $key)
        )
    {
        THROW string::concat($clean_field, "_MISSING_REQUIRED_KEY");
    };

    IF $clean_allowed IS NOT NONE
        AND !array::all(
            $keys,
            |$key| array::contains($clean_allowed, $key)
        )
    {
        THROW string::concat($clean_field, "_UNKNOWN_KEY");
    };

    RETURN $value;
}
COMMENT "
Valide les clés obligatoires et facultativement les seules clés autorisées
d'un objet.
"
PERMISSIONS FULL;
