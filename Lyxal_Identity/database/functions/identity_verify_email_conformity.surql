-- =================================================================================================
-- FUNCTION : Verify email conformity
-- Description: Vérifie la conformité de l'email
-- Parameters:
-- - $email: string - L'email à vérifier
-- Returns:
-- - success: bool - true si l'email est conforme, false sinon
-- - code: string - Le code de l'erreur
-- - email: string - L'email vérifié
-- Namespace: lyxal_identity
-- Database: main
-- Table: identity
-- Field: email
-- Permission: NONE
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::identity_verify_email_conformity($email: string) {
    -- 0. Vérification email vide
    IF string::len(string::trim($email)) = 0 {
        RETURN {
            success: false,
            code: 'IDENTITY_EMAIL_EMPTY'
        };
    };

    -- 1. Vérification email invalide
    IF !string::is_email($email) {
        RETURN {
            success: false,
            code: 'IDENTITY_EMAIL_INVALID'
        };
    };

    -- 3. Vérification email unique
        IF (SELECT COUNT(*) FROM identity WHERE email = $email) > 0 {
        RETURN {
            success: false,
            code: 'IDENTITY_EMAIL_ALREADY_EXISTS'
        };
    };

    RETURN {
        success: true,
        code: 'IDENTITY_EMAIL_CONFORMITY_OK',
        email: $email,
    };
}
COMMENT 'Vérifie la conformité de l\'email'
PERMISSIONS NONE;