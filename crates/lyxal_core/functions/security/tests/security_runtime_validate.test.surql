-- ============================================================================
-- TESTS — fn::security_runtime_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_validate(
 {name:"req",version:"v1",fields:{payload:{pipeline:[{rule:"detect_payload"}]}},default_action:"review"},
 {payload:"<script>x</script>"},
 "enforce",
 10,
 "req-1"
);
