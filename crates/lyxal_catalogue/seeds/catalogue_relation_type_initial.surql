-- ============================================================================
-- SEEDS : Types fondamentaux de relations inter-éléments
-- MODULE : lyxal_catalogue
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; is_system: true
-- ============================================================================

IF !record::exists(catalogue_relation_type:ACCESSOIRE) THEN (
    CREATE catalogue_relation_type:ACCESSOIRE CONTENT {
        code: "ACCESSOIRE",
        libelle: "Accessoire complémentaire recommandé",
        is_bidirectionnelle: false,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_relation_type:SUBSTITUT) THEN (
    CREATE catalogue_relation_type:SUBSTITUT CONTENT {
        code: "SUBSTITUT",
        libelle: "Article de remplacement ou équivalent technique",
        is_bidirectionnelle: true,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_relation_type:SIMILAIRE) THEN (
    CREATE catalogue_relation_type:SIMILAIRE CONTENT {
        code: "SIMILAIRE",
        libelle: "Article similaire de gamme comparable",
        is_bidirectionnelle: true,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_relation_type:COMPATIBLE) THEN (
    CREATE catalogue_relation_type:COMPATIBLE CONTENT {
        code: "COMPATIBLE",
        libelle: "Composant compatible",
        is_bidirectionnelle: true,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_relation_type:OBLIGATOIRE) THEN (
    CREATE catalogue_relation_type:OBLIGATOIRE CONTENT {
        code: "OBLIGATOIRE",
        libelle: "Composant indissociable obligatoire pour fonctionnement",
        is_bidirectionnelle: false,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_relation_type:COMMERCIAL_SPECIFICATION) THEN (
    CREATE catalogue_relation_type:COMMERCIAL_SPECIFICATION CONTENT {
        code: "COMMERCIAL_SPECIFICATION",
        libelle: "Spécification commerciale d'un article générique normatif",
        is_bidirectionnelle: false,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_relation_type:REMPLACEMENT) THEN (
    CREATE catalogue_relation_type:REMPLACEMENT CONTENT {
        code: "REMPLACEMENT",
        libelle: "Article de remplacement d'une référence obsolète ou abandonnée",
        is_bidirectionnelle: false,
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

