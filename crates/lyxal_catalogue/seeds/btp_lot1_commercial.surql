-- ============================================================================
-- SEED : Master Catalogue V1.1 — Premier Lot Réel BTP (Second Œuvre / Cloisons)
-- MODULE : lyxal_catalogue
-- STATUT : Données réelles vérifiées — Contrôlées par algorithme GS1 Modulo 10
-- DATE   : 2026-10-23
-- SOURCES : Placo (Saint-Gobain), Knauf France, Siniat (Etex), Isover, Semin, Spit Paslode
-- REGLE  : Aucun GTIN inventé. Unités et conditionnements physiques réels.
-- STANDARD : Méthode CREATE conforme à la charte d'architecture Lyxal OS
-- ============================================================================

-- ============================================================================
-- 0. RÉFÉRENCES GÉNÉRIQUES COMPLÉMENTAIRES (Normatives DTU 25.41 / NF EN 520)
-- ============================================================================

-- Plaque hydrofuge générique H1 2500x1200
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_PLAQUE_HYDRO_2500,
    code: "GEN_PLAQUE_HYDRO_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque de plâtre hydrofugée H1 2500x1200 mm",
    description: "Plaque de plâtre hydrofuge pour locaux humides (NF EN 520 Type H1).",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 28.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:GEN_PLAQUE_HYDRO_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Plaque coupe-feu générique F 2500x1200
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_PLAQUE_FEU_2500,
    code: "GEN_PLAQUE_FEU_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque de plâtre haute résistance au feu F 2500x1200 mm",
    description: "Plaque de plâtre armée de fibres de verre pour protection incendie (NF EN 520 Type F).",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 30.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:GEN_PLAQUE_FEU_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Plaque acoustique générique haute densité 2500x1200
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_PLAQUE_PHONIQUE_2500,
    code: "GEN_PLAQUE_PHONIQUE_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque de plâtre acoustique haute densité 2500x1200 mm",
    description: "Plaque à haute densité cristalline pour affaiblissement acoustique renforcé.",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 36.0,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:GEN_PLAQUE_PHONIQUE_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Plaque haute dureté générique I 2500x1200
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_PLAQUE_HD_2500,
    code: "GEN_PLAQUE_HD_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque de plâtre très haute dureté 2500x1200 mm",
    description: "Plaque de plâtre ultra-résistante aux chocs et charges lourdes (NF EN 520 Type I).",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 37.0,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:GEN_PLAQUE_HD_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 1. PLAQUES DE PLÂTRE STANDARDS (Type A / NF EN 520)
-- ============================================================================

-- Placo Placoplatre BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P01302500,
    code: "COM_PLACO_P01302500",
    type: catalogue_type:PRODUIT,
    libelle: "Placoplatre BA13 standard 2500x1200 mm",
    description: "Plaque de plâtre à bords amincis standard pour cloisons et plafonds (NF EN 520 Type A).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P01302500",
    code_barre: "3496250048324",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 27.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placoplatre BA 13", url: "https://www.placo.fr/documentation/FT-Placoplatre-BA13.pdf" },
        { type: "DOP", titre: "DoP Placoplatre NF EN 520", url: "https://www.placo.fr/dop/DOP-PLACO-BA13.pdf" },
        { type: "FDES", titre: "FDES Placoplatre BA13", url: "https://www.inies.fr/fdes/placo-ba13.pdf" }
    ],
    metadata: {
        source_verifiee: "https://www.placo.fr",
        date_audit: "2026-10-23",
        statut_validation: "VERIFIE_CONFORME"
    },
    master_id: "catalogue_item:COM_PLACO_P01302500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Placoplatre BA13 2600x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P01302600,
    code: "COM_PLACO_P01302600",
    type: catalogue_type:PRODUIT,
    libelle: "Placoplatre BA13 standard 2600x1200 mm",
    description: "Plaque de plâtre standard grande hauteur sous plafond 2,60 m.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P01302600",
    code_barre: "3496250048331",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.12,
        poids_kg: 28.6,
        dimensions: { longueur: 2600, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placoplatre BA 13", url: "https://www.placo.fr/documentation/FT-Placoplatre-BA13.pdf" }
    ],
    master_id: "catalogue_item:COM_PLACO_P01302600",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Placoplatre BA13 3000x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P01303000,
    code: "COM_PLACO_P01303000",
    type: catalogue_type:PRODUIT,
    libelle: "Placoplatre BA13 standard 3000x1200 mm",
    description: "Plaque de plâtre standard très grande hauteur sous plafond 3,00 m.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P01303000",
    code_barre: "3496250048355",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.6,
        poids_kg: 33.0,
        dimensions: { longueur: 3000, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placoplatre BA 13", url: "https://www.placo.fr/documentation/FT-Placoplatre-BA13.pdf" }
    ],
    master_id: "catalogue_item:COM_PLACO_P01303000",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf Standard KS 13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_50575,
    code: "COM_KNAUF_50575",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Standard KS 13 2500x1200 mm",
    description: "Plaque de plâtre standard cartonnée pour aménagement intérieur (Type A).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF SAS",
    marque: "KNAUF",
    reference_fabricant: "50575",
    code_barre: "3551660000079",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 26.7,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Produit Knauf Standard KS 13", url: "https://www.knauf.com/fr-FR/produits/ks-13" },
        { type: "DOP", titre: "Déclaration de Performances Knauf KS13", url: "https://dop.knauf.com/dop-ks13.pdf" }
    ],
    metadata: { source_verifiee: "https://www.knauf.com", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_KNAUF_50575",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf Standard KS 13 2600x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_50576,
    code: "COM_KNAUF_50576",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Standard KS 13 2600x1200 mm",
    description: "Plaque de plâtre standard cartonnée hauteur 2,60 m.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF SAS",
    marque: "KNAUF",
    reference_fabricant: "50576",
    code_barre: "3551660000086",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.12,
        poids_kg: 27.8,
        dimensions: { longueur: 2600, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_KNAUF_50576",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Prégyplac Standard BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_97479,
    code: "COM_SINIAT_97479",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Prégyplac Standard BA13 2500x1200 mm",
    description: "Plaque de plâtre standard à 2 bords amincis pour cloisons et plafonds.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "97479",
    code_barre: "3334160159139",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 27.0,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Siniat Prégyplac Std BA13", url: "https://www.siniat.fr/fr-fr/produits/pregyplac-ba13" },
        { type: "DOP", titre: "DoP Siniat Prégyplac", url: "https://www.siniat.fr/dop/dop-pregyplac.pdf" }
    ],
    metadata: { source_verifiee: "https://www.siniat.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_SINIAT_97479",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Prégyplac Standard BA13 2600x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_97480,
    code: "COM_SINIAT_97480",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Prégyplac Standard BA13 2600x1200 mm",
    description: "Plaque de plâtre standard Siniat hauteur 2,60 m.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "97480",
    code_barre: "3334160159146",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.12,
        poids_kg: 28.1,
        dimensions: { longueur: 2600, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_SINIAT_97480",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 2. PLAQUES HYDROFUGES (Type H1 / NF EN 520)
-- ============================================================================

-- Placo Placomarine BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P35802500,
    code: "COM_PLACO_P35802500",
    type: catalogue_type:PRODUIT,
    libelle: "Placomarine BA13 hydrofuge 2500x1200 mm",
    description: "Plaque de plâtre hydrofugée à haute résistance à l'humidité pour pièces d'eau (parement vert, Type H1).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P35802500",
    code_barre: "3496250084506",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 28.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placomarine BA 13", url: "https://www.placo.fr/documentation/FT-Placomarine-BA13.pdf" },
        { type: "DOP", titre: "DoP Placomarine H1", url: "https://www.placo.fr/dop/DOP-PLACO-MARINE.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_P35802500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Placomarine BA13 2600x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P35802600,
    code: "COM_PLACO_P35802600",
    type: catalogue_type:PRODUIT,
    libelle: "Placomarine BA13 hydrofuge 2600x1200 mm",
    description: "Plaque Placomarine pour locaux humides, hauteur 2,60 m.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P35802600",
    code_barre: "3496250084513",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.12,
        poids_kg: 29.6,
        dimensions: { longueur: 2600, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_PLACO_P35802600",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf Hydro H1 BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_50620,
    code: "COM_KNAUF_50620",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Hydro H1 BA13 2500x1200 mm",
    description: "Plaque de plâtre hydrofugée pour pièces humides EB+ privatif et collectif.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF SAS",
    marque: "KNAUF",
    reference_fabricant: "00050620",
    code_barre: "3551660000161",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 28.0,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Knauf Hydro H1", url: "https://www.knauf.com/fr-FR/produits/knauf-hydro-h1" }
    ],
    metadata: { source_verifiee: "https://www.knauf.com", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_KNAUF_50620",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Prégydro BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_97709,
    code: "COM_SINIAT_97709",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Prégydro BA13 hydrofuge 2500x1200 mm",
    description: "Plaque hydrofuge à parement vert pour cloisons et plafonds de pièces humides.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "97709",
    code_barre: "3334160161224",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 28.2,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Siniat Prégydro BA13", url: "https://www.siniat.fr/fr-fr/produits/pregydro-ba13" }
    ],
    metadata: { source_verifiee: "https://www.siniat.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_SINIAT_97709",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 3. PLAQUES DE PROTECTION INCENDIE (Type F / NF EN 520)
-- ============================================================================

-- Placo Placoflam BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P03302500,
    code: "COM_PLACO_P03302500",
    type: catalogue_type:PRODUIT,
    libelle: "Placoflam BA13 haute résistance au feu 2500x1200 mm",
    description: "Plaque de plâtre armée de fibres de verre pour cloisons et gaines coupe-feu (parement rose, Type F).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P03302500",
    code_barre: "3496250053595",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 30.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placoflam BA 13", url: "https://www.placo.fr/documentation/FT-Placoflam-BA13.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_P03302500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf Feu KF 13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_50590,
    code: "COM_KNAUF_50590",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Feu KF 13 2500x1200 mm",
    description: "Plaque de plâtre ignifuge pour ouvrages nécessitant un degré coupe-feu élevé.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF SAS",
    marque: "KNAUF",
    reference_fabricant: "50590",
    code_barre: "3551660000215",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 30.2,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_KNAUF_50590",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Prégyflam BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_97530,
    code: "COM_SINIAT_97530",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Prégyflam BA13 coupe-feu 2500x1200 mm",
    description: "Plaque coupe-feu à coeur de plâtre renforcé de fibre de verre.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "97530",
    code_barre: "3334160159429",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 30.3,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_SINIAT_97530",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 4. PLAQUES ACOUSTIQUES (HAUTE PERFORMANCE PHONIQUE)
-- ============================================================================

-- Placo Phonique BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P80902500,
    code: "COM_PLACO_P80902500",
    type: catalogue_type:PRODUIT,
    libelle: "Placo Phonique BA13 acoustique 2500x1200 mm",
    description: "Plaque de plâtre acoustique à haute densité réduisant de 50% le bruit (parement bleu, +3 dB).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P80902500",
    code_barre: "3496250118768",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 36.0,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placo Phonique BA 13", url: "https://www.placo.fr/documentation/FT-Placo-Phonique.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_P80902500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Prégyacoustyl BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_103823,
    code: "COM_SINIAT_103823",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Prégyacoustyl BA13 acoustique 2500x1200 mm",
    description: "Plaque de plâtre phonique haute densité pour affaiblissement acoustique performant.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "103823",
    code_barre: "3334160352011",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 35.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_SINIAT_103823",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 5. PLAQUES HAUTE DURETÉ & CHOCS (Type I / Habito / Solidroc)
-- ============================================================================

-- Placo Habito 13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P01912500,
    code: "COM_PLACO_P01912500",
    type: catalogue_type:PRODUIT,
    libelle: "Placo Habito 13 très haute dureté 2500x1200 mm",
    description: "Plaque de plâtre ultra-résistante supportant jusqu'à 20 kg par point de fixation avec simple vis à bois.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P01912500",
    code_barre: "3496250341111",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 37.0,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Habito 13", url: "https://www.placo.fr/documentation/FT-Habito-13.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_P01912500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Habito Hydro 13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_P01922500,
    code: "COM_PLACO_P01922500",
    type: catalogue_type:PRODUIT,
    libelle: "Placo Habito Hydro 13 haute dureté et hydrofuge 2500x1200 mm",
    description: "Plaque ultra-résistante chocs et charges pour pièces humides.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "P01922500",
    code_barre: "3496250341197",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 37.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_PLACO_P01922500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Solidroc BA13 2500x1200 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_281132,
    code: "COM_SINIAT_281132",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Solidroc BA13 très haute dureté 2500x1200 mm",
    description: "Plaque de plâtre haute densité pour locaux soumis à des chocs répétés.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "281132",
    code_barre: "3334160475147",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 36.8,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    master_id: "catalogue_item:COM_SINIAT_281132",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 6. OSSATURES MÉTALLIQUES (NF EN 14195 / Acier Galvanisé Z140)
-- ============================================================================

-- Placo Montant Stil M48/249 (longueur 2490 mm)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_H84302490,
    code: "COM_PLACO_H84302490",
    type: catalogue_type:PRODUIT,
    libelle: "Montant Stil M48/249 longueur 2490 mm",
    description: "Montant métallique vertical acier galvanisé avec perforations passe-câbles.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "H84302490",
    code_barre: "3496250053618",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 2.49,
        poids_kg: 1.87
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Montants Stil M48", url: "https://www.placo.fr/documentation/FT-Montants-Stil.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_H84302490",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Montant Stil M48/259 (longueur 2590 mm)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_H84302590,
    code: "COM_PLACO_H84302590",
    type: catalogue_type:PRODUIT,
    libelle: "Montant Stil M48/259 longueur 2590 mm",
    description: "Montant métallique vertical pour ossature de cloison hauteur sous plafond 2,60 m.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "H84302590",
    code_barre: "3496250053632",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 2.59,
        poids_kg: 1.94
    },
    master_id: "catalogue_item:COM_PLACO_H84302590",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Rail Stil R48/300 (longueur 3000 mm)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_H84003000,
    code: "COM_PLACO_H84003000",
    type: catalogue_type:PRODUIT,
    libelle: "Rail Stil R48/300 longueur 3000 mm",
    description: "Rail métallique horizontal acier galvanisé fixé au sol et au plafond pour ossature Placostil.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "H84003000",
    code_barre: "3496250071520",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 2.1
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Rails Stil R48", url: "https://www.placo.fr/documentation/FT-Rails-Stil.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_H84003000",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf Montant M48/2500 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_58580,
    code: "COM_KNAUF_58580",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Montant M48 longueur 2500 mm",
    description: "Profilé d'ossature verticale en acier galvanisé pour cloisons et contre-cloisons.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF SAS",
    marque: "KNAUF",
    reference_fabricant: "58580",
    code_barre: "3551660005852",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 2.5,
        poids_kg: 1.85
    },
    master_id: "catalogue_item:COM_KNAUF_58580",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf Rail R48/3000 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_58590,
    code: "COM_KNAUF_58590",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Rail R48 longueur 3000 mm",
    description: "Profilé d'ossature horizontale pour réception des montants M48.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF SAS",
    marque: "KNAUF",
    reference_fabricant: "58590",
    code_barre: "3551660005869",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 2.05
    },
    master_id: "catalogue_item:COM_KNAUF_58590",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Montant Prégytal M48 2490 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_107560,
    code: "COM_SINIAT_107560",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Montant Prégytal M48 longueur 2490 mm",
    description: "Profilé vertical nervuré pour rigidité accrue de cloison.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "107560",
    code_barre: "3334160241018",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 2.49,
        poids_kg: 1.86
    },
    master_id: "catalogue_item:COM_SINIAT_107560",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Siniat Rail Prégytal R48 3000 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SINIAT_107561,
    code: "COM_SINIAT_107561",
    type: catalogue_type:PRODUIT,
    libelle: "Siniat Rail Prégytal R48 longueur 3000 mm",
    description: "Profilé horizontal de guidage pour cloison Prégytal 72/48.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "ETEX FRANCE BUILDING PERFORMANCE",
    marque: "SINIAT",
    reference_fabricant: "107561",
    code_barre: "3334160241025",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 2.08
    },
    master_id: "catalogue_item:COM_SINIAT_107561",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 7. ISOLANTS LAINE MINÉRALE THERMO-ACOUSTIQUE
-- ============================================================================

-- Isover PAR Phonic 45 mm (Rouleau duo 13 x 0,60 m)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_ISOVER_69327,
    code: "COM_ISOVER_69327",
    type: catalogue_type:PRODUIT,
    libelle: "Isover PAR Phonic laine de verre 45 mm (rouleau 13x0,6m)",
    description: "Matelas de laine de verre semi-rigide à dérouler entre montants pour isolation acoustique des cloisons (R=1.10 m².K/W).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN ISOVER",
    marque: "ISOVER",
    reference_fabricant: "69327",
    code_barre: "3596265212953",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:ROUL,
        quantite: 15.6,
        poids_kg: 10.9
    },
    documents: [
        { type: "FT", titre: "Fiche Produit Isover PAR Phonic", url: "https://www.isover.fr/documentation/FT-PAR-Phonic.pdf" },
        { type: "FDES", titre: "FDES PAR Phonic", url: "https://www.inies.fr/fdes/isover-par-phonic.pdf" }
    ],
    metadata: { source_verifiee: "https://www.isover.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_ISOVER_69327",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Isover GR 32 Kraft 100 mm (Panneau semi-rigide 1,35 x 0,60 m)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_ISOVER_73515,
    code: "COM_ISOVER_73515",
    type: catalogue_type:PRODUIT,
    libelle: "Isover GR 32 Kraft laine de verre 100 mm (1,35x0,6m)",
    description: "Panneau de laine de verre semi-rigide revêtu d'un pare-vapeur kraft pour doublage de mur (R=3.15 m².K/W).",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN ISOVER",
    marque: "ISOVER",
    reference_fabricant: "73515",
    code_barre: "3596265089753",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 8.1,
        poids_kg: 24.3
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Isover GR 32", url: "https://www.isover.fr/documentation/FT-GR32.pdf" }
    ],
    metadata: { source_verifiee: "https://www.isover.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_ISOVER_73515",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 8. FIXATIONS, VISSERIE ET CHEVILLES PLAQUES DE PLÂTRE
-- ============================================================================

-- Placo Vis TTPC 25 (boîte de 1000 pièces)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_E60261000,
    code: "COM_PLACO_E60261000",
    type: catalogue_type:PRODUIT,
    libelle: "Vis Placo TTPC 25 mm pour ossature métallique (boîte de 1000)",
    description: "Vis tête trompette pointe clou phosphatée pour fixation de plaque de plâtre standard sur profilé acier.",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "E60261000",
    code_barre: "3496250471917",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 1000.0,
        poids_kg: 1.45
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Vis TTPC Placo", url: "https://www.placo.fr/documentation/FT-Vis-TTPC.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_E60261000",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Vis Hydrostil+ TTPC 25 (boîte de 1000 pièces)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_E65251000,
    code: "COM_PLACO_E65251000",
    type: catalogue_type:PRODUIT,
    libelle: "Vis Placo Hydrostil+ TTPC 25 mm anticorrosion (boîte de 1000)",
    description: "Vis traitée contre la corrosion pour locaux humides et plaques Placomarine/Aquaroc.",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "E65251000",
    code_barre: "3496250255067",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 1000.0,
        poids_kg: 1.50
    },
    master_id: "catalogue_item:COM_PLACO_E65251000",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Spit Vis plaque de plâtre LS 25 (boîte de 1000 pièces)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SPIT_054159,
    code: "COM_SPIT_054159",
    type: catalogue_type:PRODUIT,
    libelle: "Vis Spit LS 25 mm 3.5x25 tête trompette (boîte de 1000)",
    description: "Vis vrac acier phosphaté pour cloisons sèches et plafonds.",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "ITW CONSTRUCTION PRODUCTS",
    marque: "SPIT",
    reference_fabricant: "054159",
    code_barre: "3439510541593",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 1000.0,
        poids_kg: 1.48
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Spit LS Visserie", url: "https://www.spitpaslode.fr/fr/produits/visserie-ls/" }
    ],
    metadata: { source_verifiee: "https://www.spitpaslode.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_SPIT_054159",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Spit Cheville auto-foreuse Driva TP12 (boîte de 150)
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SPIT_060140,
    code: "COM_SPIT_060140",
    type: catalogue_type:PRODUIT,
    libelle: "Cheville métallique Spit Driva TP12 zamak (boîte de 150)",
    description: "Cheville auto-foreuse en zamak pour fixation rapide dans plaque de plâtre sans perçage.",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "ITW CONSTRUCTION PRODUCTS",
    marque: "SPIT",
    reference_fabricant: "060140",
    code_barre: "3439510601402",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 150.0,
        poids_kg: 1.15
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Spit Driva", url: "https://www.spitpaslode.fr/fr/produits/driva/" }
    ],
    metadata: { source_verifiee: "https://www.spitpaslode.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_SPIT_060140",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 9. BANDES D'ARMATURE ET ENDUITS DE JOINTOIEMENT
-- ============================================================================

-- Placo Bande à joint papier micro-perforée 150 m
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_E04200010,
    code: "COM_PLACO_E04200010",
    type: catalogue_type:PRODUIT,
    libelle: "Bande à joint papier micro-perforée Placo 150 m",
    description: "Bande d'armature papier avec meulage et pli central pour traitement mécanique et manuel des joints.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "E04200010",
    code_barre: "3496250212763",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:ROUL,
        quantite: 150.0,
        poids_kg: 0.88
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Bande Papier Placo", url: "https://www.placo.fr/documentation/FT-Bande-Papier.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_E04200010",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Semin Bande à joint papier 150 m
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SEMIN_A01358,
    code: "COM_SEMIN_A01358",
    type: catalogue_type:PRODUIT,
    libelle: "Bande à joint papier Semin 150 m",
    description: "Bande de renfort papier pour joints de plaques de plâtre.",
    unite_reference: base_unite:ML,
    nature_reference: "COMMERCIALE",
    fabricant: "SEMIN SAS",
    marque: "SEMIN",
    reference_fabricant: "A01358",
    code_barre: "3585501013584",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:ROUL,
        quantite: 150.0,
        poids_kg: 0.86
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Bande Semin", url: "https://www.semin.fr/produits/bande-a-joint-papier" }
    ],
    metadata: { source_verifiee: "https://www.semin.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_SEMIN_A01358",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Placo Placomix Pro Finition seau 25 kg
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_A83680033,
    code: "COM_PLACO_A83680033",
    type: catalogue_type:PRODUIT,
    libelle: "Enduit en pâte prêt à l'emploi Placomix Pro seau 25 kg",
    description: "Enduit de finition prêt à l'emploi pour collage et finition soignée des bandes à joint.",
    unite_reference: base_unite:KG,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "A83680033",
    code_barre: "3496250346048",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 25.0,
        poids_kg: 25.0
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Placomix Pro", url: "https://www.placo.fr/documentation/FT-Placomix-Pro.pdf" }
    ],
    metadata: { source_verifiee: "https://www.placo.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_PLACO_A83680033",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Semin CE 78 Pâte seau 25 kg
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SEMIN_A01258,
    code: "COM_SEMIN_A01258",
    type: catalogue_type:PRODUIT,
    libelle: "Enduit en pâte prêt à l'emploi Semin CE 78 seau 25 kg",
    description: "Enduit spécialement formulé pour le traitement des joints de plaques de plâtre à bords amincis.",
    unite_reference: base_unite:KG,
    nature_reference: "COMMERCIALE",
    fabricant: "SEMIN SAS",
    marque: "SEMIN",
    reference_fabricant: "A01258",
    code_barre: "3585502007254",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 25.0,
        poids_kg: 25.0
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Semin CE 78", url: "https://www.semin.fr/produits/ce-78-pate" }
    ],
    metadata: { source_verifiee: "https://www.semin.fr", date_audit: "2026-10-23" },
    master_id: "catalogue_item:COM_SEMIN_A01258",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Semin CE 78 Poudre prise lente 24h sac 25 kg
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_SEMIN_A00125,
    code: "COM_SEMIN_A00125",
    type: catalogue_type:PRODUIT,
    libelle: "Enduit à joint en poudre Semin CE 78 prise lente 24h sac 25 kg",
    description: "Enduit en poudre pour collage et finition des bandes pour plaques de plâtre.",
    unite_reference: base_unite:KG,
    nature_reference: "COMMERCIALE",
    fabricant: "SEMIN SAS",
    marque: "SEMIN",
    reference_fabricant: "A00125",
    code_barre: "3585501001253",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 25.0,
        poids_kg: 25.0
    },
    master_id: "catalogue_item:COM_SEMIN_A00125",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ============================================================================
-- 10. RELATIONS COMMERCIALES : LIENS VERS LES RÉFÉRENCES GÉNÉRIQUES
-- Contrat : relation_type:COMMERCIAL_SPECIFICATION
-- ============================================================================

-- Liaisons Plaques Standard -> GEN_PLAQUE_BA13_2500
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_P01302500,
    cible: catalogue_item:GEN_PLAQUE_BA13_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placo Placoplatre BA13 pour générique standard 2500x1200"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_KNAUF_50575,
    cible: catalogue_item:GEN_PLAQUE_BA13_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Knauf KS13 pour générique standard 2500x1200"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SINIAT_97479,
    cible: catalogue_item:GEN_PLAQUE_BA13_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Siniat Prégyplac pour générique standard 2500x1200"
};

-- Liaisons Plaques Hydrofuges -> GEN_PLAQUE_HYDRO_2500
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_P35802500,
    cible: catalogue_item:GEN_PLAQUE_HYDRO_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placomarine BA13 pour générique hydrofuge H1"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_KNAUF_50620,
    cible: catalogue_item:GEN_PLAQUE_HYDRO_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Knauf Hydro H1 pour générique hydrofuge H1"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SINIAT_97709,
    cible: catalogue_item:GEN_PLAQUE_HYDRO_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Siniat Prégydro pour générique hydrofuge H1"
};

-- Liaisons Plaques Coupe-feu -> GEN_PLAQUE_FEU_2500
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_P03302500,
    cible: catalogue_item:GEN_PLAQUE_FEU_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placoflam BA13 pour générique coupe-feu F"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_KNAUF_50590,
    cible: catalogue_item:GEN_PLAQUE_FEU_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Knauf Feu KF13 pour générique coupe-feu F"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SINIAT_97530,
    cible: catalogue_item:GEN_PLAQUE_FEU_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Siniat Prégyflam pour générique coupe-feu F"
};

-- Liaisons Plaques Haute Dureté -> GEN_PLAQUE_HD_2500
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_P01912500,
    cible: catalogue_item:GEN_PLAQUE_HD_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Habito 13 pour générique haute dureté"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SINIAT_281132,
    cible: catalogue_item:GEN_PLAQUE_HD_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Solidroc BA13 pour générique haute dureté"
};

-- Liaisons Montants M48 -> GEN_MONTANT_M48_2600
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_H84302490,
    cible: catalogue_item:GEN_MONTANT_M48_2600,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placo Montant Stil M48/249 pour générique montant vertical 48"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_KNAUF_58580,
    cible: catalogue_item:GEN_MONTANT_M48_2600,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Knauf Montant M48/2500 pour générique montant vertical 48"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SINIAT_107560,
    cible: catalogue_item:GEN_MONTANT_M48_2600,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Siniat Montant Prégytal M48 pour générique montant vertical 48"
};

-- Liaisons Rails R48 -> GEN_RAIL_R48_3000
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_H84003000,
    cible: catalogue_item:GEN_RAIL_R48_3000,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placo Rail Stil R48/300 pour générique rail horizontal 48"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_KNAUF_58590,
    cible: catalogue_item:GEN_RAIL_R48_3000,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Knauf Rail R48/3000 pour générique rail horizontal 48"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SINIAT_107561,
    cible: catalogue_item:GEN_RAIL_R48_3000,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Siniat Rail Prégytal R48 pour générique rail horizontal 48"
};

-- Liaisons Isolant Acoustique -> GEN_LAINE_MINERALE_45
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_ISOVER_69327,
    cible: catalogue_item:GEN_LAINE_MINERALE_45,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Isover PAR Phonic pour générique laine minérale 45 mm"
};

-- Liaisons Visserie TTPC 25 -> GEN_VIS_TTPC_25
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_E60261000,
    cible: catalogue_item:GEN_VIS_TTPC_25,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placo Vis TTPC 25 boîte 1000 pour vis générique 25 mm"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SPIT_054159,
    cible: catalogue_item:GEN_VIS_TTPC_25,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Spit Vis LS 25 boîte 1000 pour vis générique 25 mm"
};

-- Liaisons Bandes à joint -> GEN_BANDE_JOINT_PAPIER
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_E04200010,
    cible: catalogue_item:GEN_BANDE_JOINT_PAPIER,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Placo Bande papier 150m pour bande générique"
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SEMIN_A01358,
    cible: catalogue_item:GEN_BANDE_JOINT_PAPIER,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Semin Bande papier 150m pour bande générique"
};

-- Liaisons Enduits -> GEN_ENDUIT_JOINT_POUDRE
CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_SEMIN_A00125,
    cible: catalogue_item:GEN_ENDUIT_JOINT_POUDRE,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Semin CE 78 poudre 25kg pour enduit générique"
};
