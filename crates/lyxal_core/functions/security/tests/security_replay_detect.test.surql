-- ============================================================================
-- TESTS — fn::security_replay_detect
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_replay_detect(
    [],
    "nonce123456789012",
    "webhook:client-a",
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T12:01:00Z",
    5m
);
