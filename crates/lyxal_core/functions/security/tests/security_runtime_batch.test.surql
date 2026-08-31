-- ============================================================================
-- TESTS — fn::security_runtime_batch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_batch(
 {compiled_fields:{payload:{steps:[{rule:"detect_payload"}]}}},
 [{payload:"safe"},{payload:"<script>x</script>"}],
 {}
);
