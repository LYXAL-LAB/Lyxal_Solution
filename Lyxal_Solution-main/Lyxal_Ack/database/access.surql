-- ============================================================
-- ACCESS: ack_signer
-- DESCRIPTION: Authentification Native Lyxal v3.0
-- ============================================================

DEFINE ACCESS IF NOT EXISTS ack_signer ON DATABASE
    TYPE RECORD
    USER user
    AUTHENTICATE {
        RETURN SELECT * FROM user WHERE email = $email AND pass::verify(password, $pass);
    }
    DURATION 
        FOR TOKEN 30d, 
        FOR SESSION 1d
    COMMENT "Portée d'authentification v3.0 pour les signataires Lyxal";




