-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/mac_address.test.surql
-- Fonction     : fn::validation_mac_address
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — MAC avec deux-points
-- Résultat attendu : "aa:bb:cc:dd:ee:ff"
-- ============================================================================
RETURN fn::validation_mac_address(
    "AA:BB:CC:DD:EE:FF", "MAC_ADDRESS", false, true
);

-- ============================================================================
-- TEST 2 — MAC avec tirets
-- Résultat attendu : "aa-bb-cc-dd-ee-ff"
-- ============================================================================
RETURN fn::validation_mac_address(
    "AA-BB-CC-DD-EE-FF", "MAC_ADDRESS", true, false
);

-- ============================================================================
-- TEST 3 — Mélange de séparateurs
-- Erreur attendue : MAC_ADDRESS_INVALID_MAC_ADDRESS
-- ============================================================================
RETURN fn::validation_mac_address(
    "AA:BB-CC:DD:EE:FF", "MAC_ADDRESS", true, true
);

-- ============================================================================
-- TEST 4 — Groupe trop court
-- Erreur attendue : MAC_ADDRESS_INVALID_MAC_ADDRESS
-- ============================================================================
RETURN fn::validation_mac_address(
    "A:BB:CC:DD:EE:FF", "MAC_ADDRESS", false, true
);
