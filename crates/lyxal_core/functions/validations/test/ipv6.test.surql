-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ipv6.test.surql
-- Fonction     : fn::validation_ipv6
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — IPv6 complète valide
-- Résultat attendu : valeur en minuscules
-- ============================================================================
RETURN fn::validation_ipv6(
    "2001:0DB8:85A3:0000:0000:8A2E:0370:7334",
    "IP_ADDRESS"
);

-- ============================================================================
-- TEST 2 — IPv6 compressée valide
-- Résultat attendu : "2001:db8::1"
-- ============================================================================
RETURN fn::validation_ipv6("2001:db8::1", "IP_ADDRESS");

-- ============================================================================
-- TEST 3 — Loopback IPv6 valide
-- Résultat attendu : "::1"
-- ============================================================================
RETURN fn::validation_ipv6("::1", "IP_ADDRESS");

-- ============================================================================
-- TEST 4 — IPv4 refusée
-- Erreur attendue : IP_ADDRESS_INVALID_IPV6
-- ============================================================================
RETURN fn::validation_ipv6("192.168.1.1", "IP_ADDRESS");
