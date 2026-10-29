-- ============================================================================
-- TESTS — fn::utils_encode_uri
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Espaces et caractères réservés ("Lyxal OS / Core" -> "Lyxal%20OS%20%2F%20Core")
RETURN fn::utils_encode_uri(
    "Lyxal OS / Core"
);

-- TEST 2 — Chaîne vide ("" -> "")
RETURN fn::utils_encode_uri(
    ""
);

-- TEST 3 — Caractères non réservés RFC 3986 ("abc-123_DEF.~" -> "abc-123_DEF.~")
RETURN fn::utils_encode_uri(
    "abc-123_DEF.~"
);

-- TEST 4 — UTF-8 multi-octets et réservés ("Équipe & Co=100%" -> "%C3%89quipe%20%26%20Co%3D100%25")
RETURN fn::utils_encode_uri(
    "Équipe & Co=100%"
);
