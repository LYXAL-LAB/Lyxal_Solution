-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_case.surql
-- Fonction     : fn::validation_pipeline_case
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une normalisation de casse à une chaîne.
--
-- Règles appliquées
-- -----------------
--   1. NONE est retourné sans modification.
--   2. Les modes reconnus sont lowercase et uppercase.
--   3. La valeur présente doit être une chaîne.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $mode: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_TYPE
-- VALIDATION_UNSUPPORTED_CASE_MODE
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

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_case(
    $value: option<any>,
    $field: string,
    $mode: string
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        RETURN $value;
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_mode = string::lowercase(string::trim($mode));

    IF $clean_mode = "lowercase" {
        RETURN string::lowercase($value);
    };

    IF $clean_mode = "uppercase" {
        RETURN string::uppercase($value);
    };

    THROW "VALIDATION_UNSUPPORTED_CASE_MODE";
}
COMMENT "
Applique une normalisation lowercase ou uppercase à une chaîne.
"
PERMISSIONS FULL;
