-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/username.test.surql
-- Fonction     : fn::validation_username
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution.
-- Dans Surrealist, sélectionner individuellement le test concerné lorsqu'une
-- erreur est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom simple valide
-- Résultat attendu : "yaniss"
-- ============================================================================
RETURN fn::validation_username(
    "yaniss", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 2 — Séparateurs valides
-- Résultat attendu : "yaniss.dubreucq_2026"
-- ============================================================================
RETURN fn::validation_username(
    "yaniss.dubreucq_2026", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 3 — Majuscules autorisées
-- Résultat attendu : "Yaniss"
-- ============================================================================
RETURN fn::validation_username(
    "Yaniss", "USERNAME", 3, 32, false
);

-- ============================================================================
-- TEST 4 — Majuscules interdites
-- Erreur attendue : USERNAME_NOT_LOWERCASE
-- ============================================================================
RETURN fn::validation_username(
    "Yaniss", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 5 — Trop court
-- Erreur attendue : USERNAME_TOO_SHORT
-- ============================================================================
RETURN fn::validation_username(
    "ya", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 6 — Espace interdit
-- Erreur attendue : USERNAME_INVALID_USERNAME
-- ============================================================================
RETURN fn::validation_username(
    "yaniss dubreucq", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 7 — Accent interdit
-- Erreur attendue : USERNAME_INVALID_USERNAME
-- ============================================================================
RETURN fn::validation_username(
    "yaníss", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 8 — Séparateur au début
-- Erreur attendue : USERNAME_INVALID_BOUNDARY
-- ============================================================================
RETURN fn::validation_username(
    "_yaniss", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 9 — Séparateur à la fin
-- Erreur attendue : USERNAME_INVALID_BOUNDARY
-- ============================================================================
RETURN fn::validation_username(
    "yaniss-", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 10 — Séparateur répété
-- Erreur attendue : USERNAME_REPEATED_SEPARATOR
-- ============================================================================
RETURN fn::validation_username(
    "yaniss__d", "USERNAME", 3, 32, true
);

-- ============================================================================
-- TEST 11 — Limites incohérentes
-- Erreur attendue : VALIDATION_INVALID_USERNAME_LENGTH
-- ============================================================================
RETURN fn::validation_username(
    "yaniss", "USERNAME", 32, 3, true
);

-- ============================================================================
-- TEST 12 — Enchaînement avec mots réservés
-- Résultat attendu : "yaniss"
-- ============================================================================
LET $username = fn::validation_username(
    "yaniss", "USERNAME", 3, 32, true
);

RETURN fn::validation_reserved_words(
    $username,
    "USERNAME",
    ["admin", "root", "system"],
    true
);

-- ============================================================================
-- TEST 13 — Nom valide mais réservé
-- Erreur attendue : USERNAME_RESERVED_WORD
-- ============================================================================
LET $username = fn::validation_username(
    "admin", "USERNAME", 3, 32, true
);

RETURN fn::validation_reserved_words(
    $username,
    "USERNAME",
    ["admin", "root", "system"],
    true
);
