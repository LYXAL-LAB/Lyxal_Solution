-- ============================================================================
-- SEEDS : Types fondamentaux du catalogue universel
-- MODULE : lyxal_catalogue
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5) ; is_system: true
-- ============================================================================

IF !record::exists(catalogue_type:PRODUIT) THEN (
    CREATE catalogue_type:PRODUIT CONTENT {
        code: "PRODUIT",
        libelle: "Produit physique ou fourniture marchande",
        description: "Matériaux, composants, consommables et marchandises physiques stockables ou livrables.",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_type:SERVICE) THEN (
    CREATE catalogue_type:SERVICE CONTENT {
        code: "SERVICE",
        libelle: "Prestation ou service immatériel",
        description: "Interventions, missions de conseil, études, formation ou prestations externalisées.",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_type:OUVRAGE) THEN (
    CREATE catalogue_type:OUVRAGE CONTENT {
        code: "OUVRAGE",
        libelle: "Ouvrage technique ou unité d'exécution",
        description: "Assemblage technique combinant fournitures et main d'œuvre de pose (ex: m² de cloison, fenêtre posée).",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_type:RESSOURCE) THEN (
    CREATE catalogue_type:RESSOURCE CONTENT {
        code: "RESSOURCE",
        libelle: "Moyen de production et d'exécution",
        description: "Main d'œuvre interne (compagnons), engins, outillage lourd ou matériel de production amorti.",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(catalogue_type:ENSEMBLE) THEN (
    CREATE catalogue_type:ENSEMBLE CONTENT {
        code: "ENSEMBLE",
        libelle: "Ensemble commercial, pack ou kit",
        description: "Regroupement commercial ou logistique d'articles vendus sous une référence unique.",
        enabled: true,
        is_system: true,
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
