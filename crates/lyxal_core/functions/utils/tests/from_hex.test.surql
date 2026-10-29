-- ============================================================================
-- TESTS — fn::utils_from_hex
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Aller-retour avec fn::utils_to_hex (<bytes>"Lyxal")
RETURN fn::utils_from_hex(
    fn::utils_to_hex(<bytes>"Lyxal")
);

-- TEST 2 — Insensibilité à la casse ("4C7978616C" -> <bytes>"Lyxal")
RETURN fn::utils_from_hex(
    "4C7978616C"
);

-- TEST 3 — Chaîne vide ("" -> b"")
RETURN fn::utils_from_hex(
    ""
);

-- TEST 4 — Longueur impaire invalide
-- Erreur attendue : UTILS_INVALID_HEX_STRING
RETURN fn::utils_from_hex(
    "4c7"
);

-- TEST 5 — Caractère non hexadécimal invalide
-- Erreur attendue : UTILS_INVALID_HEX_STRING
RETURN fn::utils_from_hex(
    "4c7z"
);
