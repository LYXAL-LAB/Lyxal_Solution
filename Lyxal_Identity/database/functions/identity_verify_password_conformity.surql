-- =================================================================================================
-- FUNCTION : Verify password conformity
-- Description: Vérifie la conformité du mot de passe
-- Parameters:
-- - $password: string - Le mot de passe à vérifier
-- Returns:
-- - success: bool - true si le mot de passe est conforme, false sinon
-- - code: string - Le code de l'erreur
-- - password: string - Le mot de passe vérifié
-- Namespace: lyxal_identity
-- Database: main
-- Table: identity
-- Field: password
-- Permission: NONE
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::identity_verify_password_conformity(
    $password: string) {

    -- 0. Vérification password vide
    IF string::len(string::trim($password)) = 0 {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_EMPTY'
        };
    };

    -- 1. Vérification password trop court
    IF string::len(string::trim($password)) < 12 {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_TOO_SHORT'
        };
    };

    -- 2. Vérification password trop long
    IF string::len(string::trim($password)) > 20 {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_TOO_LONG'
        };
    };

    -- 3. Vérification password contient au moins une majuscule
    IF !string::contains(string::trim($password), '[A-Z]') {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_NO_UPPERCASE'
        };
    };

    -- 4. Vérification password contient au moins une minuscule
    IF !string::contains(string::trim($password), '[a-z]') {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_NO_LOWERCASE'
        };
    };

    -- 5. Vérification password contient au moins un chiffre
    IF !string::contains(string::trim($password), '[0-9]') {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_NO_NUMBER'
        };
    };

    -- 6. Vérification password contient au moins un caractère spécial
    IF !string::contains(string::trim($password), '[!@#$%^&*()_+\-=\[\]{}|;:,.<>?/~`]') {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_NO_SPECIAL'
        };
    };

    -- 7. Vérification password contient au moins une lettre
    IF !string::contains(string::trim($password), '[A-Za-z]') {
        RETURN {
            success: false,
            code: 'IDENTITY_PASSWORD_NO_LETTER'
        };
    };

    RETURN {
        success: true,
        code: 'IDENTITY_PASSWORD_CONFORMITY_OK',
        password: $password,
    };
}
COMMENT 'Vérifie la conformité du mot de passe'
PERMISSIONS NONE;
