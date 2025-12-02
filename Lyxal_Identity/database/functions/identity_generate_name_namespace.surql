-- =================================================================================================
-- FUNCTION : Generate name namespace
-- Description: Génère le nom du namespace pour l'identité
-- Parameters:
-- Returns:
-- - success: bool - true si le namespace est généré avec succès, false sinon
-- - code: string - Le code de l'erreur
-- - namespace: string - Le nom du namespace
-- Namespace: lyxal_identity
-- Database: main
-- Table: identity
-- Field: vault_namespace
-- Permission: NONE
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::identity_generate_name_namespace() {

    -- Génération du nom du namespace
    LET $clean_uuid = string::replace(rand::uuid::v4(), "-", "");
    LET $namespace_name = string::concat("IDENTITY_", string::slice($clean_uuid, 0, 12));
    LET $namespace_result = SELECT * FROM identity WHERE vault_namespace = $namespace_name
    LIMIT 1;
    IF array::len($namespace_result) > 0 {
        fn::identity_generate_name_namespace();
    }
    RETURN {
        success: true,
        code: 'IDENTITY_NAMESPACE_GENERATED_SUCCESSFULLY',
        namespace: $namespace_name,
    };
}
COMMENT 'Génère le nom du namespace pour l\'identité'
PERMISSIONS NONE;