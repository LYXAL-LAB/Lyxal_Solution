-- =================================================================================================
-- FUNCTION : Vérification email disponible
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::is_email_available($email: string) {
  LET $existing = SELECT * FROM identity WHERE connexion.email = $email LIMIT 1;
  RETURN array::len($existing) = 0;
};

