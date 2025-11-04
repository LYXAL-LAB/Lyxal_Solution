-- ============================================================================
-- Fichier : knowledge/function/training/fn_knowledge_export_auto_version.surql
-- Module : knowledge
-- Fonction : fn::knowledge_export_auto_version()
-- Description : Génère automatiquement la prochaine version pour un domaine
-- ============================================================================
-- Usage :
--   SELECT * FROM fn::knowledge_export_auto_version("SURREAL_DB");
-- ============================================================================

DEFINE FUNCTION fn::knowledge_export_auto_version(
    $domain_code: string
) {
    -- Vérifier que le domaine existe
    LET $domain = (SELECT * FROM knowledge_domain WHERE identity.code = $domain_code AND metadata.is_active = true LIMIT 1)[0];
    
    IF $domain = NONE {
        RETURN {
            success: false,
            error: "Domain not found",
            domain_code: $domain_code
        };
    };

    -- Récupérer la dernière version pour ce domaine
    LET $last_export = (
        SELECT identity.version
        FROM knowledge_dataset_export
        WHERE domain = $domain.id
            AND metadata.is_active = true
        ORDER BY metadata.created_at DESC
        LIMIT 1
    )[0];

    -- Si aucune version précédente, commencer à v1.0
    IF $last_export = NONE {
        RETURN {
            success: true,
            domain_code: $domain_code,
            current_version: NONE,
            next_version: "v1.0",
            is_first_version: true
        };
    };

    -- Extraire le numéro de version et incrémenter
    LET $version_str = $last_export.identity.version;
    LET $version_num = string::replace($version_str, "v", "");
    LET $parts = string::split($version_num, ".");
    
    IF array::len($parts) < 2 {
        RETURN {
            success: false,
            error: "Invalid version format",
            version: $version_str
        };
    };

    LET $major = number::parse($parts[0]);
    LET $minor = number::parse($parts[1]);
    
    -- Incrémenter la version mineure
    LET $new_minor = $minor + 1;
    LET $next_version = string::concat("v", string::concat($major, string::concat(".", $new_minor)));

    RETURN {
        success: true,
        domain_code: $domain_code,
        current_version: $version_str,
        next_version: $next_version,
        is_first_version: false,
        version_history: (
            SELECT identity.version, metadata.created_at
            FROM knowledge_dataset_export
            WHERE domain = $domain.id
                AND metadata.is_active = true
            ORDER BY metadata.created_at DESC
            LIMIT 10
        )
    };
};

