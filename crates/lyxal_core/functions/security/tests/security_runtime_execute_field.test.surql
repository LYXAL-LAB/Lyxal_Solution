-- ============================================================================
-- TESTS — fn::security_runtime_execute_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_execute_field({name:"payload",steps:[{rule:"detect_payload"}]},"<script>x</script>",{});
