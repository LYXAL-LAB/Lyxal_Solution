-- ============================================================================
-- TESTS — fn::sanitize_safe_redirect
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_safe_redirect("/dashboard","REDIRECT","/");
RETURN fn::sanitize_safe_redirect("https://evil.test","REDIRECT","/");
