-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/validate_field.surql
-- Fonction     : fn::validation_validate_field
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Exécute l'ensemble fermé des règles d'un schéma sur une valeur.
--
-- Règles appliquées
-- -----------------
--   1. Le schéma est d'abord normalisé.
--   2. required/nullable sont appliqués avant les autres règles.
--   3. Une valeur absente ou NULL autorisée arrête proprement le pipeline.
--   4. Les règles type, longueur, plage et enum sont ensuite appliquées.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $schema: object
--
-- Erreurs spécifiques
-- --------------------
-- Les erreurs des fonctions appelées sont propagées.
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
-- fn::validation_field_schema()
-- fn::validation_apply_required()
-- fn::validation_apply_type()
-- fn::validation_apply_length()
-- fn::validation_apply_range()
-- fn::validation_apply_enum()

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validate_field(
    $value: option<any>,
    $field: string,
    $schema: object
) -> any {
    LET $normalized_schema = fn::validation_field_schema(
        $schema,
        string::concat(string::trim($field), "_SCHEMA")
    );

    LET $checked_presence = fn::validation_apply_required(
        $value,
        $field,
        $normalized_schema.required,
        $normalized_schema.nullable
    );

    IF $checked_presence IS NONE
        OR type::is_null($checked_presence)
    {
        RETURN $checked_presence;
    };

    LET $checked_type = fn::validation_apply_type(
        $checked_presence,
        $field,
        $normalized_schema.type
    );

    LET $checked_length = fn::validation_apply_length(
        $checked_type,
        $field,
        $normalized_schema.min_length,
        $normalized_schema.max_length
    );

    LET $checked_range = fn::validation_apply_range(
        $checked_length,
        $field,
        $normalized_schema.min,
        $normalized_schema.max
    );

    RETURN fn::validation_apply_enum(
        $checked_range,
        $field,
        $normalized_schema.enum
    );
}
COMMENT "
Exécute le pipeline fermé de validation d'un champ à partir de son schéma.
"
PERMISSIONS FULL;
