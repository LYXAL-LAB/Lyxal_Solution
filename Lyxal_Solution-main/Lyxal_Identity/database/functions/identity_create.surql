-- Cette fonction est le workflow de création d'une identité.
-- Elle doit être executer avec un access root donné à Lyxal_identity

DEFINE FUNCTION IF NOT EXISTS fn::create_identity(
    $email: string,
    $password: string,
    $password_hash: string
) {
    -- 1. Vérification email
    LET $email_conformity = fn::verify_email_conformity($email);
    IF $email_conformity.success = false {
        RETURN {
            success: false,
            code_error: $email_conformity.code_error,
            message: $email_conformity.message
        };
    };

    -- 2. Vérification password
    LET $password_conformity = fn::verify_password_conformity($password, $password_hash);
    IF $password_conformity.success = false {
        RETURN {
            success: false,
            code_error: $password_conformity.code_error,
            message: $password_conformity.message
        };
    };
    LET $password_hash = crypto::argon2::generate($password);

    -- 3. Création de l'identité en utilisant begin_transaction
    BEGIN TRANSACTION;

    -- 3.1 Création du namespace
    -- Génération du nom du namespace
    LET $namespace_generated = fn::identity_generate_name_namespace()
    IF $namespace_generated.success = false {
        RETURN {
            success: false,
            code_error: $namespace_generated.code_error,
            message: $namespace_generated.message
        };
    };
    LET $namespace_created = fn::identity_create_namespace($namespace_generated.namespace_name);
    IF $namespace_created.success = false {
        RETURN {
            success: false,
            code_error: $namespace_created.code_error,
            message: $namespace_created.message
        };
    };
    -- 3.2. Création de l'identité
    CREATE identity SET
        email = $email,
        -- password_hash = $password_hash, -- TODO: Stocké dans le vault
        vault_namespace = $namespace_created.namespace;




    COMMIT TRANSACTION;
};