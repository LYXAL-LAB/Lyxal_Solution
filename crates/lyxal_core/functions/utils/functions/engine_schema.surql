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
    LET $entries = object::entries($schema.fields);
    -- Représentation SurrealQL de chaque définition (types conservés) : deux définitions de même
    -- représentation sont normalisées une fois ; une représentation contenant « | » (fermeture
    -- possible, dont le texte ne dit pas les valeurs capturées) l'est toujours
    LET $keys = array::map($entries, |$entry| <string> $entry[1]);
    LET $firsts = array::map($keys, |$key, $index| IF string::contains($key, "|") { $index } ELSE { array::find_index($keys, $key) });
    -- Catalogue de plus de 32 règles réduit à celles dont le nom figure dans le texte des
    -- définitions (comme fn::utils_engine_pipeline)
    LET $rules = $catalog.rule;
    LET $whole = array::len($rules) <= 32 OR !string::matches(<string> $rules, "^\\[('[a-z0-9_]+'(, )?)*\\]$");
    LET $text = IF $whole { "" } ELSE { string::lowercase(array::join($keys, " ")) };
    LET $used = IF $whole { $catalog } ELSE { $catalog[WHERE rule IN ["each", "object", "when", "one_of"] OR string::contains($text, rule)] };
    LET $normalized = array::map($entries, |$entry, $index| {
        LET $definition = $entry[1];
        IF !type::is_object($definition)
            OR ($definition.pipeline IS NOT NONE AND !type::is_array($definition.pipeline))
            OR ($definition.required IS NOT NONE AND !type::is_bool($definition.required))
            OR ($definition.nullable IS NOT NONE AND !type::is_bool($definition.nullable))
        { THROW "CORE_INVALID_ARGUMENT"; };
        IF $firsts[$index] != $index { RETURN NONE; };
        LET $pipeline = fn::utils_engine_pipeline($definition.pipeline ?? [], $used, $max_steps);
        RETURN {
            pipeline: $pipeline,
            required: $definition.required ?? false,
            nullable: $definition.nullable ?? false,
            default: $definition.default
        };
    });
    LET $fields = IF array::len(array::distinct($firsts)) = array::len($firsts) { $normalized } ELSE { array::map($firsts, |$first| $normalized[$first]) };
    RETURN { name: $schema.name, version: $schema.version, fields: object::from_entries(array::transpose([object::keys($schema.fields), $fields])), unknown_keys: $policy };
}
COMMENT "Contrôle et normalise un schéma d'objet { name, version, fields: { <champ>: { pipeline, required, nullable, default } }, unknown_keys } : pipelines contrôlés contre le catalogue, required et nullable à false par défaut, unknown_keys = reject (défaut), strip ou keep."
PERMISSIONS FULL;
