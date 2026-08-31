-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/object_schema_v2.surql
-- Fonction     : fn::validation_object_schema_v2
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un schéma d'objet associant chaque champ à un schéma déclaratif.
--
-- Règles appliquées
-- -----------------
--   1. Le schéma racine doit être un objet non vide.
--   2. Chaque valeur doit être un objet de schéma de champ.
--   3. Chaque clé doit être un identifiant de champ simple.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_OBJECT_SCHEMA
-- <FIELD>_INVALID_SCHEMA_FIELD_NAME
-- <FIELD>_INVALID_FIELD_SCHEMA
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
-- fn::validation_field_schema()

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_schema_v2(
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

    IF type::is_null($value)
        OR !type::is_object($value)
        OR object::is_empty($value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_OBJECT_SCHEMA"
        );
    };

    LET $entries = object::entries($value);

    IF !array::all(
        $entries,
        |$entry|
            string::matches(
                $entry[0],
                "^[A-Za-z_][A-Za-z0-9_]*$"
            )
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_SCHEMA_FIELD_NAME"
        );
    };

    IF !array::all(
        $entries,
        |$entry|
            type::is_object($entry[1])
            AND !object::is_empty($entry[1])
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FIELD_SCHEMA"
        );
    };

    RETURN object::from_entries(
        array::map(
            $entries,
            |$entry| [
                $entry[0],
                fn::validation_field_schema(
                    $entry[1],
                    string::concat(
                        $clean_field,
                        "_",
                        string::uppercase($entry[0])
                    )
                )
            ]
        )
    );
}
COMMENT "
Valide et normalise un schéma déclaratif d'objet composé de schémas de champs.
"
PERMISSIONS FULL;
