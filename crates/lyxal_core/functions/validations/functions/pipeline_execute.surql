-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_execute.surql
-- Fonction     : fn::validation_pipeline_execute
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Exécute séquentiellement un pipeline fermé sur une valeur.
--
-- Règles appliquées
-- -----------------
--   1. Le pipeline est validé avant exécution.
--   2. Chaque étape reçoit la valeur produite par l'étape précédente.
--   3. Les transformations et validations sont exécutées dans l'ordre.
--   4. La première erreur déclenche un THROW.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $pipeline: array<object>
-- $max_steps: int
--
-- Erreurs spécifiques
-- --------------------
-- Les erreurs des étapes sont propagées.
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
-- fn::validation_pipeline_definition()
-- fn::validation_pipeline_required()
-- fn::validation_pipeline_trim()
-- fn::validation_pipeline_case()
-- fn::validation_pipeline_length()
-- fn::validation_pipeline_pattern()
-- fn::validation_pipeline_enum()
-- fn::validation_pipeline_default()

--
-- Mode d'exécution
-- ----------------
-- Cette version est fail-fast. Le lot Validation Report ajoutera la collecte
-- d'erreurs sans arrêt immédiat.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_execute(
    $value: option<any>,
    $field: string,
    $pipeline: array<object>,
    $max_steps: int
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $steps = fn::validation_pipeline_definition(
        $pipeline,
        string::concat($clean_field, "_PIPELINE"),
        $max_steps
    );

    RETURN array::reduce(
        $steps,
        |$current, $step| {
            IF $step.rule = "required" {
                fn::validation_pipeline_required(
                    $current,
                    $clean_field
                )
            }
            ELSE IF $step.rule = "trim" {
                fn::validation_pipeline_trim(
                    $current,
                    $clean_field
                )
            }
            ELSE IF $step.rule = "lowercase"
                OR $step.rule = "uppercase"
            {
                fn::validation_pipeline_case(
                    $current,
                    $clean_field,
                    $step.rule
                )
            }
            ELSE IF $step.rule = "min_length"
                OR $step.rule = "max_length"
            {
                fn::validation_pipeline_length(
                    $current,
                    $clean_field,
                    $step.rule,
                    $step.value
                )
            }
            ELSE IF $step.rule = "pattern" {
                fn::validation_pipeline_pattern(
                    $current,
                    $clean_field,
                    $step.value
                )
            }
            ELSE IF $step.rule = "enum" {
                fn::validation_pipeline_enum(
                    $current,
                    $clean_field,
                    $step.value
                )
            }
            ELSE IF $step.rule = "default" {
                fn::validation_pipeline_default(
                    $current,
                    $clean_field,
                    $step.value
                )
            }
            ELSE {
                $current
            }
        },
        $value
    );
}
COMMENT "
Exécute séquentiellement un Validation Pipeline fermé en mode fail-fast.
"
PERMISSIONS FULL;
