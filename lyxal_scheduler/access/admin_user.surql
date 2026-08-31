-- Access pour les administrateurs et le tableau de bord Lyxal Scheduler
DEFINE ACCESS IF NOT EXISTS admin_user ON DATABASE TYPE RECORD
    SIGNIN ( SELECT * FROM user WHERE username = $username AND crypto::argon2::compare(password, $password) )
    COMMENT "Accès utilisateur/administrateur avec mot de passe haché Argon2";
