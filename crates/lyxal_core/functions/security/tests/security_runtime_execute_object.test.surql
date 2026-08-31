-- ============================================================================
-- TESTS — fn::security_runtime_execute_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_execute_object(
 {compiled_fields:{payload:{steps:[{rule:"detect_payload"}]}}},
 {payload:"<script>x</script>"},
 {}
);
