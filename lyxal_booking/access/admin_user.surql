-- Access pour les hôtes et administrateurs du système de réservation
DEFINE ACCESS IF NOT EXISTS admin_user ON DATABASE TYPE RECORD
    SIGNIN ( SELECT * FROM booking_account WHERE email = $email AND crypto::argon2::compare(password, $password) )
    COMMENT "Accès hôte et administrateur avec mot de passe haché Argon2";
