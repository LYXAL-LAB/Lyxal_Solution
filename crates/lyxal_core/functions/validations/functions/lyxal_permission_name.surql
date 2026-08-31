-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_permission_name.surql
-- Fonction     : fn::validation_lyxal_permission_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom de permission Lyxal structuré par ressource et action.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Le format canonique est ressource.action ou domaine.ressource.action.
--   3. Le dernier segment représente l'action.
--   4. Une liste facultative peut limiter les actions autorisées.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_actions: option<array<string>>
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_PERMISSION_NAME
-- <FIELD>_PERMISSION_ACTION_NOT_ALLOWED
-- VALIDATION_EMPTY_PERMISSION_ACTIONS
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune dépendance à l'authentification ;
--   - aucune création de ressource Lyxal ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_permission_name(
    $value: option<any>,
    $field: string,
    $allowed_actions: option<array<string>>
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

    LET $permission = string::lowercase($clean_value);

    IF !string::matches(
        $permission,
        "^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)+$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_PERMISSION_NAME"
        );
    };

    LET $segments = string::split($permission, ".");
    LET $action = $segments[array::len($segments) - 1];

    IF $allowed_actions IS NOT NONE {
        IF array::len($allowed_actions) = 0 {
            THROW "VALIDATION_EMPTY_PERMISSION_ACTIONS";
        };

        LET $actions = array::map(
            $allowed_actions,
            |$item| string::lowercase(string::trim($item))
        );

        IF !array::contains($actions, $action) {
            THROW string::concat(
                $clean_field,
                "_PERMISSION_ACTION_NOT_ALLOWED"
            );
        };
    };

    RETURN $permission;
}
COMMENT "
Valide un nom de permission Lyxal structuré par segments et action finale.
"
PERMISSIONS FULL;
