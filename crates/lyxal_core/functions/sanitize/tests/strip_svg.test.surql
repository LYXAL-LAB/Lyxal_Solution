-- ============================================================================
-- TESTS — fn::sanitize_strip_svg
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_svg("<svg><script>x</script></svg><p>ok</p>","HTML");
