-- =================================================================================================
-- FUNCTION : Génération token de vérification email
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::generate_verification_token() {
  -- Token sécurisé de 32 caractères
  RETURN string::concat(
    string::slice(rand::uuid::v4(), 0, 8),
    string::slice(rand::uuid::v4(), 0, 8),
    string::slice(rand::uuid::v4(), 0, 8),
    string::slice(rand::uuid::v4(), 0, 8)
  );
};

