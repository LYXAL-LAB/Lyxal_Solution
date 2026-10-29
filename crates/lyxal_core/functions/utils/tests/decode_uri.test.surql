-- ============================================================================
-- TESTS — fn::utils_decode_uri
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Aller-retour nominal ("Lyxal OS / Core")
RETURN fn::utils_decode_uri(
    fn::utils_encode_uri("Lyxal OS / Core")
);

-- TEST 2 — Décodage UTF-8 multi-octets et réservés ("Équipe & Co=100%")
RETURN fn::utils_decode_uri(
    "%C3%89quipe%20%26%20Co%3D100%25"
);

-- TEST 3 — Séquence % tronquée en fin de chaîne
-- Erreur attendue : UTILS_INVALID_URI_ENCODING
RETURN fn::utils_decode_uri(
    "Lyxal%2"
);

-- TEST 4 — Séquence % non hexadécimale
-- Erreur attendue : UTILS_INVALID_URI_ENCODING
RETURN fn::utils_decode_uri(
    "Lyxal%ZZ"
);

-- TEST 5 — Séquence d'octets UTF-8 invalide (octet isolé %C3)
-- Erreur attendue : UTILS_INVALID_URI_ENCODING
RETURN fn::utils_decode_uri(
    "%C3"
);
