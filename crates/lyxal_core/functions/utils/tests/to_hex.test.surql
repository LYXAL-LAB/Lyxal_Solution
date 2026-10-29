-- ============================================================================
-- TESTS — fn::utils_to_hex
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Chaîne ASCII standard ("Lyxal" -> "4c7978616c")
RETURN fn::utils_to_hex(
    <bytes>"Lyxal"
);

-- TEST 2 — Bytes vide (b"" -> "")
RETURN fn::utils_to_hex(
    b""
);

-- TEST 3 — Bornes d'octets et zéros de tête ([0, 15, 16, 255] -> "000f10ff")
RETURN fn::utils_to_hex(
    <bytes>[0, 15, 16, 255]
);

-- TEST 4 — UTF-8 multi-octets ("É" -> "c389")
RETURN fn::utils_to_hex(
    <bytes>"É"
);
