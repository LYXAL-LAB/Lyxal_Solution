-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/apply_range.surql
-- Fonction     : fn::validation_apply_range
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique des bornes minimale et maximale à une valeur comparable.
--
-- Règles appliquées
-- -----------------
--   1. NONE ignore la règle.
--   2. Les bornes absentes sont ignorées.
--   3. Les comparaisons utilisent la sémantique native SurrealQL.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_value: option<any>
-- $max_value: option<any>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SMALL
-- <FIELD>_TOO_LARGE
-- VALIDATION_INVALID_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_apply_range(
    $value: option<any>,
    $field: string,
    $min_value: option<any>,
    $max_value: option<any>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_RANGE";
    };

    IF $value IS NONE {
        RETURN $value;
    };

    IF $min_value IS NOT NONE AND $value < $min_value {
        THROW string::concat($clean_field, "_TOO_SMALL");
    };

    IF $max_value IS NOT NONE AND $value > $max_value {
        THROW string::concat($clean_field, "_TOO_LARGE");
    };

    RETURN $value;
}
COMMENT "
Applique des bornes minimale et maximale à une valeur comparable.
"
PERMISSIONS FULL;
