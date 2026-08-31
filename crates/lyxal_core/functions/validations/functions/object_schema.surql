-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/object_schema.surql
-- Fonction     : fn::validation_object_schema
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un objet selon un schéma simple clé vers type attendu.
--
-- Règles appliquées
-- -----------------
--   1. Le schéma associe chaque clé à un nom de type SurrealDB.
--   2. Les clés obligatoires doivent être présentes.
--   3. Les clés inconnues peuvent être autorisées ou refusées.
--   4. Les valeurs présentes sont vérifiées avec type::of().
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $schema: object
-- $required_keys: array<string>
-- $allow_unknown_keys: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_MISSING_REQUIRED_KEY
-- <FIELD>_UNKNOWN_KEY
-- <FIELD>_SCHEMA_TYPE_MISMATCH
-- VALIDATION_INVALID_SCHEMA
-- VALIDATION_REQUIRED_KEY_NOT_IN_SCHEMA
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun appel réseau ;
--   - aucune exécution dynamique de code ;
--   - aucun effet secondaire.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_schema(
    $value: option<any>,
    $field: string,
    $schema: object,
    $required_keys: array<string>,
    $allow_unknown_keys: bool
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF object::is_empty($schema) {
        THROW "VALIDATION_INVALID_SCHEMA";
    };

    LET $schema_keys = object::keys($schema);

    IF !array::all(
        object::values($schema),
        |$type_name|
            type::is_string($type_name)
            AND string::trim($type_name) != ""
    ) {
        THROW "VALIDATION_INVALID_SCHEMA";
    };

    IF !array::all(
        $required_keys,
        |$key| array::contains($schema_keys, $key)
    ) {
        THROW "VALIDATION_REQUIRED_KEY_NOT_IN_SCHEMA";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $value_keys = object::keys($value);

    IF !array::all(
        $required_keys,
        |$key| array::contains($value_keys, $key)
    ) {
        THROW string::concat(
            $clean_field,
            "_MISSING_REQUIRED_KEY"
        );
    };

    IF !$allow_unknown_keys
        AND !array::all(
            $value_keys,
            |$key| array::contains($schema_keys, $key)
        )
    {
        THROW string::concat(
            $clean_field,
            "_UNKNOWN_KEY"
        );
    };

    IF !array::all(
        $value_keys,
        |$key|
            !array::contains($schema_keys, $key)
            OR string::lowercase(type::of($value[$key]))
                = string::lowercase(string::trim($schema[$key]))
    ) {
        THROW string::concat(
            $clean_field,
            "_SCHEMA_TYPE_MISMATCH"
        );
    };

    RETURN $value;
}
COMMENT "
Valide un objet selon un schéma simple clé vers type SurrealDB attendu.
"
PERMISSIONS FULL;
