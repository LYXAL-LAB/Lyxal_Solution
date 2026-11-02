-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_schema.surql
-- Fonction : fn::utils_engine_schema
--
-- Contrôle et normalise un schéma d'objet { name, version, fields: {
-- <champ>: { pipeline, required, nullable, default } }, unknown_keys } :
-- pipelines contrôlés contre le catalogue, required et nullable à false par
-- défaut, unknown_keys = reject (défaut), strip ou keep.
--
-- Paramètres
--   $schema    : object
--   $catalog   : array<object>
--   $max_steps : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : fields absent ou vide, définition de champ mal formée, pipeline invalide
--   CORE_UNSUPPORTED_OPTION : unknown_keys autre que reject, strip ou keep
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_schema(
    $schema: object,
    $catalog: array<object>,
    $max_steps: int
) -> object {
    IF !type::is_object($schema.fields) OR object::is_empty($schema.fields) { THROW "CORE_INVALID_ARGUMENT"; };
    LET $unknown_keys = $schema.unknown_keys ?? "reject";
    IF !type::is_string($unknown_keys) { THROW "CORE_INVALID_ARGUMENT"; };
    LET $policy = string::lowercase(string::trim($unknown_keys));
    IF $policy NOT IN ["reject", "strip", "keep"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    LET $fields = object::from_entries(array::map(object::entries($schema.fields), |$entry| {
        LET $definition = $entry[1];
        IF !type::is_object($definition)
            OR ($definition.pipeline IS NOT NONE AND !type::is_array($definition.pipeline))
            OR ($definition.required IS NOT NONE AND !type::is_bool($definition.required))
            OR ($definition.nullable IS NOT NONE AND !type::is_bool($definition.nullable))
        { THROW "CORE_INVALID_ARGUMENT"; };
        RETURN [$entry[0], {
            pipeline: fn::utils_engine_pipeline($definition.pipeline ?? [], $catalog, $max_steps),
            required: $definition.required ?? false,
            nullable: $definition.nullable ?? false,
            default: $definition.default
        }];
    }));
    RETURN { name: $schema.name, version: $schema.version, fields: $fields, unknown_keys: $policy };
}
COMMENT "Contrôle et normalise un schéma d'objet { name, version, fields: { <champ>: { pipeline, required, nullable, default } }, unknown_keys } : pipelines contrôlés contre le catalogue, required et nullable à false par défaut, unknown_keys = reject (défaut), strip ou keep."
PERMISSIONS FULL;
