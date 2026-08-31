-- ============================================================================
-- TESTS — fn::utils_to_csv
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_to_csv(
    [
        {name:"Lyxal",version:1},
        {name:"Core",version:2}
    ],
    ["name","version"],
    ",",
    true
);
