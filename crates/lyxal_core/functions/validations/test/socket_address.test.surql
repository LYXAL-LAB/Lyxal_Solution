-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/socket_address.test.surql
-- Fonction     : fn::validation_socket_address
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Hostname et port
-- Résultat attendu : "api.lyxal.com:443"
-- ============================================================================
RETURN fn::validation_socket_address(
    "api.lyxal.com:443", "SOCKET", true, false, false
);

-- ============================================================================
-- TEST 2 — IPv4 et port
-- Résultat attendu : "127.0.0.1:8000"
-- ============================================================================
RETURN fn::validation_socket_address(
    "127.0.0.1:8000", "SOCKET", false, true, false
);

-- ============================================================================
-- TEST 3 — IPv6 entre crochets
-- Résultat attendu : "[2001:db8::1]:443"
-- ============================================================================
RETURN fn::validation_socket_address(
    "[2001:DB8::1]:443", "SOCKET", false, false, true
);

-- ============================================================================
-- TEST 4 — IPv6 sans crochets
-- Erreur attendue : SOCKET_INVALID_SOCKET_ADDRESS
-- ============================================================================
RETURN fn::validation_socket_address(
    "2001:db8::1:443", "SOCKET", false, false, true
);

-- ============================================================================
-- TEST 5 — Port invalide
-- Erreur attendue : SOCKET_INVALID_SOCKET_ADDRESS
-- ============================================================================
RETURN fn::validation_socket_address(
    "127.0.0.1:70000", "SOCKET", false, true, false
);
