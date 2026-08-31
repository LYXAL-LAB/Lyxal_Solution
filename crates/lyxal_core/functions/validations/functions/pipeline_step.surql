-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_step.surql
-- Fonction     : fn::validation_pipeline_step
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide et normalise une étape élémentaire de pipeline.
--
-- Règles appliquées
-- -----------------
--   1. L'étape doit être un objet contenant la clé rule.
--   2. Les règles reconnues sont required, trim, lowercase, uppercase,
--      min_length, max_length, pattern, enum et default.
--   3. La clé value est requise pour les règles qui ont un paramètre.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_PIPELINE_STEP
-- <FIELD>_UNKNOWN_PIPELINE_RULE
-- <FIELD>_PIPELINE_RULE_VALUE_REQUIRED
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

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_step(
    $value: option<any>,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE
        OR type::is_null($value)
        OR !type::is_object($value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_PIPELINE_STEP"
        );
    };

    LET $keys = object::keys($value);

    IF !array::contains($keys, "rule")
        OR !type::is_string($value.rule)
        OR string::trim($value.rule) = ""
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_PIPELINE_STEP"
        );
    };

    LET $rule = string::lowercase(string::trim($value.rule));

    IF !array::contains(
        [
            "required",
            "trim",
            "lowercase",
            "uppercase",
            "min_length",
            "max_length",
            "pattern",
            "enum",
            "default"
        ],
        $rule
    ) {
        THROW string::concat(
            $clean_field,
            "_UNKNOWN_PIPELINE_RULE"
        );
    };

    IF array::contains(
        ["min_length", "max_length", "pattern", "enum", "default"],
        $rule
    )
        AND !array::contains($keys, "value")
    {
        THROW string::concat(
            $clean_field,
            "_PIPELINE_RULE_VALUE_REQUIRED"
        );
    };

    RETURN {
        rule: $rule,
        value: IF array::contains($keys, "value") {
            $value.value
        } ELSE {
            NONE
        }
    };
}
COMMENT "
Valide et normalise une étape élémentaire de Validation Pipeline.
"
PERMISSIONS FULL;
