-- ============================================================================
-- TESTS — fn::sanitize_strip_dangerous_attributes
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_dangerous_attributes("<a href=\"javascript:alert(1)\" style=\"x\">ok</a>","HTML");
