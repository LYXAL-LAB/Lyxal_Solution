-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/surql_field_path.surql
-- Fonction     : fn::validation_surql_field_path
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un chemin de champ SurrealQL simplifié avec points et sélecteurs de tableaux.
--
-- Règles appliquées
-- -----------------
--   1. Les propriétés sont séparées par des points.
--   2. Les sélecteurs [*] et [n] sont facultatifs.
--   3. Les opérateurs de graphe et expressions dynamiques sont interdits.
--   4. Le nombre de propriétés est limité.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_array_wildcard: bool
-- $allow_numeric_index: bool
-- $max_segments: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée, éventuellement normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_FIELD_PATH
-- <FIELD>_ARRAY_WILDCARD_NOT_ALLOWED
-- <FIELD>_NUMERIC_INDEX_NOT_ALLOWED
-- <FIELD>_TOO_MANY_SEGMENTS
-- VALIDATION_INVALID_FIELD_PATH_SEGMENTS
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

--
-- Portée
-- ------
-- Cette primitive couvre les chemins usuels comme profile.name,
-- addresses[*].city et items[0].price. Elle ne couvre pas les traversées de
-- graphe, les projections ou les expressions SurrealQL complètes.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_field_path(
    $value: option<any>,
    $field: string,
    $allow_array_wildcard: bool,
    $allow_numeric_index: bool,
    $max_segments: int
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

    IF $max_segments < 1 {
        THROW "VALIDATION_INVALID_FIELD_PATH_SEGMENTS";
    };

    IF !$allow_array_wildcard
        AND string::contains($clean_value, "[*]")
    {
        THROW string::concat(
            $clean_field,
            "_ARRAY_WILDCARD_NOT_ALLOWED"
        );
    };

    IF !$allow_numeric_index
        AND string::matches($clean_value, "\[[0-9]+\]")
    {
        THROW string::concat(
            $clean_field,
            "_NUMERIC_INDEX_NOT_ALLOWED"
        );
    };

    LET $selector = IF $allow_array_wildcard AND $allow_numeric_index {
        "(?:\[(?:\*|[0-9]+)\])*"
    } ELSE IF $allow_array_wildcard {
        "(?:\[\*\])*"
    } ELSE IF $allow_numeric_index {
        "(?:\[[0-9]+\])*"
    } ELSE {
        ""
    };

    LET $pattern = string::concat(
        "^[A-Za-z_][A-Za-z0-9_]*",
        $selector,
        "(?:\.[A-Za-z_][A-Za-z0-9_]*",
        $selector,
        ")*$"
    );

    IF !string::matches($clean_value, $pattern) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_PATH"
        );
    };

    LET $segments = string::split($clean_value, ".");

    IF array::len($segments) > $max_segments {
        THROW string::concat(
            $clean_field,
            "_TOO_MANY_SEGMENTS"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide un chemin de champ SurrealQL simplifié avec sélecteurs de tableaux.
"
PERMISSIONS FULL;
