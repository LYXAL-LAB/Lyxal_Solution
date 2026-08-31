-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/apply_type.surql
-- Fonction     : fn::validation_apply_type
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une contrainte de type SurrealDB à une valeur présente.
--
-- Règles appliquées
-- -----------------
--   1. NONE ignore la règle de type.
--   2. Une absence de type attendu ignore la règle.
--   3. Le type réel est obtenu avec type::of().
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_type: option<string>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_EXPECTED_TYPE
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

DEFINE FUNCTION OVERWRITE fn::validation_apply_type(
    $value: option<any>,
    $field: string,
    $expected_type: option<string>
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE OR $expected_type IS NONE {
        RETURN $value;
    };

    LET $clean_type = string::lowercase(
        string::trim($expected_type)
    );

    IF $clean_type = "" {
        THROW "VALIDATION_INVALID_EXPECTED_TYPE";
    };

    IF string::lowercase(type::of($value)) != $clean_type {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    RETURN $value;
}
COMMENT "
Applique une contrainte de type SurrealDB à une valeur présente.
"
PERMISSIONS FULL;
