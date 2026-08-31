-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ipv4.test.surql
-- Fonction     : fn::validation_ipv4
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — IPv4 valide
-- Résultat attendu : "192.168.1.10"
-- ============================================================================
RETURN fn::validation_ipv4("192.168.1.10", "IP_ADDRESS");

-- ============================================================================
-- TEST 2 — Loopback valide
-- Résultat attendu : "127.0.0.1"
-- ============================================================================
RETURN fn::validation_ipv4("127.0.0.1", "IP_ADDRESS");

-- ============================================================================
-- TEST 3 — Octet trop élevé
-- Erreur attendue : IP_ADDRESS_INVALID_IPV4
-- ============================================================================
RETURN fn::validation_ipv4("256.1.1.1", "IP_ADDRESS");

-- ============================================================================
-- TEST 4 — IPv6 refusée
-- Erreur attendue : IP_ADDRESS_INVALID_IPV4
-- ============================================================================
RETURN fn::validation_ipv4("2001:db8::1", "IP_ADDRESS");
