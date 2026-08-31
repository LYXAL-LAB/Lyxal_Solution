-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_pattern.surql
-- Fonction     : fn::validation_pipeline_pattern
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une expression régulière à une chaîne.
--
-- Règles appliquées
-- -----------------
--   1. NONE est retourné sans modification.
--   2. La valeur présente doit être une chaîne.
--   3. Le pattern doit être non vide.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $pattern: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_TYPE
-- <FIELD>_PATTERN_MISMATCH
-- VALIDATION_INVALID_PATTERN
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

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_pattern(
    $value: option<any>,
    $field: string,
    $pattern: string
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $clean_pattern = string::trim($pattern);

    IF $clean_pattern = "" {
        THROW "VALIDATION_INVALID_PATTERN";
    };

    IF $value IS NONE {
        RETURN $value;
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF !string::matches($value, $clean_pattern) {
        THROW string::concat(
            $clean_field,
            "_PATTERN_MISMATCH"
        );
    };

    RETURN $value;
}
COMMENT "
Applique une expression régulière à une chaîne présente.
"
PERMISSIONS FULL;
