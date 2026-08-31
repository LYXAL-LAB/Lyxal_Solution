-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/validate_object.surql
-- Fonction     : fn::validation_validate_object
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un objet complet à partir d'un schéma déclaratif de champs.
--
-- Règles appliquées
-- -----------------
--   1. Le schéma est validé avant l'objet.
--   2. Chaque champ déclaré est validé avec validation_validate_field.
--   3. Les clés inconnues peuvent être autorisées ou refusées.
--   4. Le premier échec déclenche un THROW.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $schema: object
-- $allow_unknown_keys: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_UNKNOWN_KEY
-- <FIELD>_INVALID_TYPE
-- Les erreurs de champ sont propagées.
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
-- fn::validation_object_schema_v2()
-- fn::validation_validate_field()

--
-- Mode d'erreur
-- -------------
-- Cette version est fail-fast. La collecte de toutes les erreurs sera fournie
-- par le lot Validation Report.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validate_object(
    $value: option<any>,
    $field: string,
    $schema: object,
    $allow_unknown_keys: bool
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $normalized_schema = fn::validation_object_schema_v2(
        $schema,
        string::concat($clean_field, "_SCHEMA")
    );

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $schema_keys = object::keys($normalized_schema);
    LET $value_keys = object::keys($value);

    IF !$allow_unknown_keys
        AND !array::all(
            $value_keys,
            |$key| array::contains($schema_keys, $key)
        )
    {
        THROW string::concat($clean_field, "_UNKNOWN_KEY");
    };

    RETURN object::from_entries(
        array::map(
            $schema_keys,
            |$key| [
                $key,
                fn::validation_validate_field(
                    $value[$key],
                    string::uppercase($key),
                    $normalized_schema[$key]
                )
            ]
        )
    );
}
COMMENT "
Valide un objet complet à partir d'un schéma déclaratif en mode fail-fast.
"
PERMISSIONS FULL;
