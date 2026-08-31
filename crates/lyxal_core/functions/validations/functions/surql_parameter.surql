-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/surql_parameter.surql
-- Fonction     : fn::validation_surql_parameter
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le nom d'un paramètre global SurrealQL sans son préfixe dollar.
--
-- Règles appliquées
-- -----------------
--   1. La valeur ne doit pas commencer par $.
--   2. L'identifiant doit être simple.
--   3. Les noms réservés courants peuvent être interdits.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_reserved: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée, éventuellement normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_DOLLAR_PREFIX_NOT_ALLOWED
-- <FIELD>_INVALID_PARAMETER_NAME
-- <FIELD>_RESERVED_PARAMETER_NAME
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucune création de schéma SurrealDB ;
--   - aucune exécution de requête dynamique ;
--   - aucune vérification d'existence des objets validés.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_parameter(
    $value: option<any>,
    $field: string,
    $allow_reserved: bool
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

    IF string::starts_with($clean_value, "$") {
        THROW string::concat(
            $clean_field,
            "_DOLLAR_PREFIX_NOT_ALLOWED"
        );
    };

    IF !string::matches(
        $clean_value,
        "^[A-Za-z_][A-Za-z0-9_]*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_PARAMETER_NAME"
        );
    };

    IF !$allow_reserved
        AND array::contains(
            [
                "auth",
                "session",
                "token",
                "before",
                "after",
                "event",
                "value",
                "this",
                "input"
            ],
            string::lowercase($clean_value)
        )
    {
        THROW string::concat(
            $clean_field,
            "_RESERVED_PARAMETER_NAME"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide le nom d'un paramètre SurrealQL sans le préfixe dollar.
"
PERMISSIONS FULL;
