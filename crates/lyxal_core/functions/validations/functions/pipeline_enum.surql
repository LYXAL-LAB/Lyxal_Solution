-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_enum.surql
-- Fonction     : fn::validation_pipeline_enum
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une contrainte enum stricte.
--
-- Règles appliquées
-- -----------------
--   1. NONE est retourné sans modification.
--   2. La liste doit être non vide.
--   3. La comparaison est stricte.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_values: array<any>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_VALUE_NOT_ALLOWED
-- VALIDATION_EMPTY_ENUM
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
-- Le pipeline utilise uniquement des étapes explicitement prises en charge.
-- Aucun nom de fonction arbitraire n'est exécuté.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_enum(
    $value: option<any>,
    $field: string,
    $allowed_values: array<any>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF array::len($allowed_values) = 0 {
        THROW "VALIDATION_EMPTY_ENUM";
    };

    IF $value IS NONE {
        RETURN $value;
    };

    IF !array::contains($allowed_values, $value) {
        THROW string::concat(
            $clean_field,
            "_VALUE_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Applique une contrainte enum stricte à une valeur présente.
"
PERMISSIONS FULL;
