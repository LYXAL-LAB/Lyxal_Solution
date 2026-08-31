-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/cidr.test.surql
-- Fonction     : fn::validation_cidr
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — CIDR IPv4 valide
-- Résultat attendu : "192.168.1.0/24"
-- ============================================================================
RETURN fn::validation_cidr(
    "192.168.1.0/24", "CIDR", true, false
);

-- ============================================================================
-- TEST 2 — CIDR IPv6 valide
-- Résultat attendu : "2001:db8::/32"
-- ============================================================================
RETURN fn::validation_cidr(
    "2001:DB8::/32", "CIDR", false, true
);

-- ============================================================================
-- TEST 3 — Préfixe IPv4 trop grand
-- Erreur attendue : CIDR_INVALID_CIDR
-- ============================================================================
RETURN fn::validation_cidr(
    "192.168.1.0/33", "CIDR", true, false
);

-- ============================================================================
-- TEST 4 — IPv6 interdite
-- Erreur attendue : CIDR_CIDR_FAMILY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_cidr(
    "2001:db8::/32", "CIDR", true, false
);

-- ============================================================================
-- TEST 5 — Aucune famille autorisée
-- Erreur attendue : VALIDATION_NO_CIDR_FAMILY_ALLOWED
-- ============================================================================
RETURN fn::validation_cidr(
    "192.168.1.0/24", "CIDR", false, false
);
