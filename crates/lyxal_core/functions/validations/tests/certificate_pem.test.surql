-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : crates/lyxal_core/functions/validations/tests/certificate_pem.test.surql
-- Fonction     : fn::validation_certificate_pem
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Certificat PEM valide
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_certificate_pem(
    "-----BEGIN CERTIFICATE-----\nQUJDRA==\n-----END CERTIFICATE-----",
    "CERTIFICATE",
    32768
);

-- ============================================================================
-- TEST 2 — Bloc public key refusé
-- Erreur attendue : CERTIFICATE_INVALID_CERTIFICATE_PEM
-- ============================================================================
RETURN fn::validation_certificate_pem(
    "-----BEGIN PUBLIC KEY-----\nQUJDRA==\n-----END PUBLIC KEY-----",
    "CERTIFICATE",
    32768
);
