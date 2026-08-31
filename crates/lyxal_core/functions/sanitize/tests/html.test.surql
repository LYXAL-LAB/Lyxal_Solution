-- ============================================================================
-- TESTS — fn::sanitize_html
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_html("<p onclick=\"x()\">ok</p><script>alert(1)</script>","HTML");
