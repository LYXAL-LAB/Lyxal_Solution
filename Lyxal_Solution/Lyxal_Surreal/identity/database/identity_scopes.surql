-- =====================================================
-- NAMESPACE : lyxal_solution
-- DATABASE : main
-- SCOPES pour identity (Authentification)
-- =====================================================

-- =================================================================================================
-- SCOPE : lyxal_user (Authentification utilisateur)
-- =================================================================================================

DEFINE SCOPE IF NOT EXISTS lyxal_user SESSION 24h
  SIGNUP (
    -- Création d'un nouveau compte
    -- Appelle la function de création pour validation complète
    LET $result = fn::create_identity(
      $email,
      $password,
      $first_name,
      $last_name,
      $language
    );
    
    -- Si erreur, retourne NONE (échec signup)
    IF !$result.success {
      RETURN NONE;
    };
    
    -- Retourne l'utilisateur créé
    RETURN $result.user;
  )
  SIGNIN (
    -- Connexion utilisateur existant
    -- Appelle la function d'authentification
    LET $result = fn::authenticate_identity(
      $email,
      $password,
      $ip
    );
    
    -- Si erreur, retourne NONE (échec signin)
    IF !$result.success {
      RETURN NONE;
    };
    
    -- Récupère l'utilisateur complet
    SELECT * FROM identity 
    WHERE email = $email 
      AND status IN [identity_status:verified, identity_status:active]
    LIMIT 1
  );

-- =================================================================================================
-- PERMISSIONS pour identity selon le scope
-- =================================================================================================

-- Les utilisateurs authentifiés peuvent lire leur propre profil
DEFINE FIELD IF NOT EXISTS identity ON identity
  PERMISSIONS 
    FOR SELECT WHERE $scope = "lyxal_user" AND id = $auth.id
    FOR UPDATE WHERE $scope = "lyxal_user" AND id = $auth.id
    FOR DELETE NONE;

-- =================================================================================================
-- EXEMPLE D'UTILISATION (Frontend)
-- =================================================================================================

-- Inscription :
-- const token = await db.signup({
--   namespace: 'lyxal_solution',
--   database: 'main',
--   scope: 'lyxal_user',
--   email: 'jean@example.com',
--   password: 'Password123!',
--   first_name: 'Jean',
--   last_name: 'Dupont',
--   language: 'fr'
-- });

-- Connexion :
-- const token = await db.signin({
--   namespace: 'lyxal_solution',
--   database: 'main',
--   scope: 'lyxal_user',
--   email: 'jean@example.com',
--   password: 'Password123!',
--   ip: '192.168.1.1'  // Optionnel
-- });

