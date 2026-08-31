-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_definition.surql
-- Fonction     : fn::validation_pipeline_definition
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une liste ordonnée d'étapes de pipeline.
--
-- Règles appliquées
-- -----------------
--   1. Le pipeline doit être un tableau non vide.
--   2. Chaque élément est validé par validation_pipeline_step.
--   3. Le nombre maximal d'étapes est configurable.
--   4. Les étapes sont retournées dans leur ordre d'origine.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $max_steps: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_PIPELINE
-- <FIELD>_TOO_MANY_STEPS
-- VALIDATION_INVALID_PIPELINE_MAX_STEPS
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
-- fn::validation_pipeline_step()

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_definition(
    $value: option<any>,
    $field: string,
    $max_steps: int
) -> array<object> {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $max_steps < 1 {
        THROW "VALIDATION_INVALID_PIPELINE_MAX_STEPS";
    };

    IF $value IS NONE
        OR type::is_null($value)
        OR !type::is_array($value)
        OR array::len($value) = 0
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_PIPELINE"
        );
    };

    IF array::len($value) > $max_steps {
        THROW string::concat(
            $clean_field,
            "_TOO_MANY_STEPS"
        );
    };

    RETURN array::map(
        $value,
        |$step| fn::validation_pipeline_step(
            $step,
            string::concat($clean_field, "_STEP")
        )
    );
}
COMMENT "
Valide et normalise une définition ordonnée de Validation Pipeline.
"
PERMISSIONS FULL;
