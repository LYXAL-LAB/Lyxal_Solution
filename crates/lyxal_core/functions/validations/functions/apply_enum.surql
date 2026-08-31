-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/apply_enum.surql
-- Fonction     : fn::validation_apply_enum
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une contrainte d'appartenance à une liste de valeurs.
--
-- Règles appliquées
-- -----------------
--   1. NONE ignore la règle.
--   2. Une liste absente ignore la règle.
--   3. Une liste présente doit être non vide.
--   4. La comparaison est stricte.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_values: option<array<any>>
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
-- Le moteur utilise un ensemble fermé de règles. Il n'exécute jamais un nom
-- de fonction arbitraire fourni dans un schéma.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_apply_enum(
    $value: option<any>,
    $field: string,
    $allowed_values: option<array<any>>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE OR $allowed_values IS NONE {
        RETURN $value;
    };

    IF array::len($allowed_values) = 0 {
        THROW "VALIDATION_EMPTY_ENUM";
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
