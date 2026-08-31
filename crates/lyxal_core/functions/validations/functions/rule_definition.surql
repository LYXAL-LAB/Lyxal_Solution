-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/rule_definition.surql
-- Fonction     : fn::validation_rule_definition
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide et normalise la définition déclarative d'une règle élémentaire.
--
-- Règles appliquées
-- -----------------
--   1. La définition doit être un objet.
--   2. La clé rule est obligatoire.
--   3. Les règles reconnues sont required, type, min_length, max_length,
--      min, max et enum.
--   4. La clé value est obligatoire pour toutes les règles sauf required.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_RULE_DEFINITION
-- <FIELD>_UNKNOWN_RULE
-- <FIELD>_RULE_VALUE_REQUIRED
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

DEFINE FUNCTION OVERWRITE fn::validation_rule_definition(
    $value: option<any>,
    $field: string
) -> object {
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

    IF !type::is_object($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_RULE_DEFINITION"
        );
    };

    LET $keys = object::keys($value);

    IF !array::contains($keys, "rule")
        OR !type::is_string($value.rule)
        OR string::trim($value.rule) = ""
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_RULE_DEFINITION"
        );
    };

    LET $rule = string::lowercase(string::trim($value.rule));

    IF !array::contains(
        [
            "required",
            "type",
            "min_length",
            "max_length",
            "min",
            "max",
            "enum"
        ],
        $rule
    ) {
        THROW string::concat($clean_field, "_UNKNOWN_RULE");
    };

    IF $rule != "required"
        AND !array::contains($keys, "value")
    {
        THROW string::concat(
            $clean_field,
            "_RULE_VALUE_REQUIRED"
        );
    };

    RETURN {
        rule: $rule,
        value: IF array::contains($keys, "value") {
            $value.value
        } ELSE {
            true
        }
    };
}
COMMENT "
Valide et normalise une définition de règle élémentaire du Validation Engine.
"
PERMISSIONS FULL;
