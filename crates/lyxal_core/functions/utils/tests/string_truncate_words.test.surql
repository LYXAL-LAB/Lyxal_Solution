-- ============================================================================
-- TESTS — fn::utils_string_truncate_words
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_string_truncate_words(
    "Lyxal est un système modulaire très complet",
    4,
    "…"
);
