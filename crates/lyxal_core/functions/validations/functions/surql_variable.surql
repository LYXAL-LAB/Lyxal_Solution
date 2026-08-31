-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/surql_variable.surql
-- Fonction     : fn::validation_surql_variable
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le nom d'une variable locale SurrealQL sans le préfixe dollar.
--
-- Règles appliquées
-- -----------------
--   1. Le préfixe $ ne doit pas être inclus.
--   2. Le nom doit être un identifiant simple.
--   3. Les variables de contexte réservées peuvent être interdites.
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
-- <FIELD>_INVALID_VARIABLE_NAME
-- <FIELD>_RESERVED_VARIABLE_NAME
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

DEFINE FUNCTION OVERWRITE fn::validation_surql_variable(
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
            "_INVALID_VARIABLE_NAME"
        );
    };

    IF !$allow_reserved
        AND array::contains(
            [
                "auth",
                "before",
                "after",
                "event",
                "value",
                "this",
                "input",
                "parent",
                "root"
            ],
            string::lowercase($clean_value)
        )
    {
        THROW string::concat(
            $clean_field,
            "_RESERVED_VARIABLE_NAME"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide le nom d'une variable locale SurrealQL sans le préfixe dollar.
"
PERMISSIONS FULL;
