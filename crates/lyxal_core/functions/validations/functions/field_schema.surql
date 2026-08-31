-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/field_schema.surql
-- Fonction     : fn::validation_field_schema
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le schéma déclaratif complet d'un champ.
--
-- Règles appliquées
-- -----------------
--   1. Le schéma doit être un objet non vide.
--   2. Les clés prises en charge sont required, nullable, type, min_length,
--      max_length, min, max et enum.
--   3. Les bornes de longueur doivent être cohérentes.
--   4. enum doit être un tableau non vide.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_FIELD_SCHEMA
-- <FIELD>_UNKNOWN_SCHEMA_KEY
-- <FIELD>_INVALID_LENGTH_RANGE
-- <FIELD>_INVALID_ENUM
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
-- Sécurité
-- --------
-- Le moteur utilise un ensemble fermé de règles. Il n'exécute jamais un nom
-- de fonction arbitraire fourni dans un schéma.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_field_schema(
    $value: option<any>,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value)
        OR !type::is_object($value)
        OR object::is_empty($value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    LET $allowed_keys = [
        "required",
        "nullable",
        "type",
        "min_length",
        "max_length",
        "min",
        "max",
        "enum"
    ];

    IF !array::all(
        object::keys($value),
        |$key| array::contains($allowed_keys, $key)
    ) {
        THROW string::concat(
            $clean_field,
            "_UNKNOWN_SCHEMA_KEY"
        );
    };

    IF $value.required IS NOT NONE
        AND !type::is_bool($value.required)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    IF $value.nullable IS NOT NONE
        AND !type::is_bool($value.nullable)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    IF $value.type IS NOT NONE
        AND (
            !type::is_string($value.type)
            OR string::trim($value.type) = ""
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    IF $value.min_length IS NOT NONE
        AND (
            !type::is_int($value.min_length)
            OR $value.min_length < 0
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    IF $value.max_length IS NOT NONE
        AND (
            !type::is_int($value.max_length)
            OR $value.max_length < 0
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    IF $value.min_length IS NOT NONE
        AND $value.max_length IS NOT NONE
        AND $value.min_length > $value.max_length
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_LENGTH_RANGE"
        );
    };

    IF $value.enum IS NOT NONE
        AND (
            !type::is_array($value.enum)
            OR array::len($value.enum) = 0
        )
    {
        THROW string::concat($clean_field, "_INVALID_ENUM");
    };

    RETURN {
        required: IF $value.required IS NONE { false } ELSE { $value.required },
        nullable: IF $value.nullable IS NONE { false } ELSE { $value.nullable },
        type: $value.type,
        min_length: $value.min_length,
        max_length: $value.max_length,
        min: $value.min,
        max: $value.max,
        enum: $value.enum
    };
}
COMMENT "
Valide et normalise le schéma déclaratif complet d'un champ.
"
PERMISSIONS FULL;
