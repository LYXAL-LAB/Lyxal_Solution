-- ============================================================================
-- SEED / PILOTE BTP : Master Catalogue V1 — Pilote BTP Habitat & Cloisons
-- MODULE : lyxal_catalogue
-- RÔLE   : Démonstration et validation complète des extensions Master Catalogue :
--          - Références génériques et commerciales
--          - Unités physiques et conditionnements intrinsèques (découplés des règles de vente)
--          - Relations commerciales (COMMERCIAL_SPECIFICATION)
--          - Nomenclature d'ouvrage BTP (Cloison 72/48 selon DTU 25.41)
--          - Règle stricte d'évitement du double comptage des pertes
--          - Personnalisation locale tenant et article privé
-- STANDARD : Méthode CREATE conforme à la charte Lyxal OS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. RÉFÉRENCES GÉNÉRIQUES (Normatives / Métier DTU 25.41)
-- ----------------------------------------------------------------------------

-- Plaque de plâtre standard type A 13 mm (BA13 2500x1200)
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_PLAQUE_BA13_2500,
    code: "GEN_PLAQUE_BA13_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque de plâtre standard BA13 2500x1200 mm",
    description: "Plaque de plâtre à bords amincis pour cloisons, plafonds et doublages intérieurs (NF EN 520 type A).",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 27.5,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    documents: [
        { type: "FT", titre: "Fiche Technique Générique Plaque BA13", url: "https://docs.lyxal.org/btp/ft-ba13.pdf" },
        { type: "FDES", titre: "FDES Collective Plaque de plâtre standard", url: "https://inies.fr/fdes-ba13-standard.pdf" }
    ],
    master_id: "catalogue_item:GEN_PLAQUE_BA13_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Rail métallique horizontal 48 mm (R48 longueur 3000 mm)
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_RAIL_R48_3000,
    code: "GEN_RAIL_R48_3000",
    type: catalogue_type:PRODUIT,
    libelle: "Rail métallique horizontal R48 longueur 3000 mm",
    description: "Profilé métallique horizontal en acier galvanisé Z140 pour ossature de cloison 72/48 (NF EN 14195).",
    unite_reference: base_unite:ML,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 2.1
    },
    master_id: "catalogue_item:GEN_RAIL_R48_3000",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Montant métallique vertical 48 mm (M48 longueur 2600 mm)
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_MONTANT_M48_2600,
    code: "GEN_MONTANT_M48_2600",
    type: catalogue_type:PRODUIT,
    libelle: "Montant métallique vertical M48 longueur 2600 mm",
    description: "Profilé métallique vertical en acier galvanisé avec perforations passe-câbles pour cloison 72/48.",
    unite_reference: base_unite:ML,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 2.6,
        poids_kg: 2.2
    },
    master_id: "catalogue_item:GEN_MONTANT_M48_2600",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Laine minérale thermo-acoustique 45 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_LAINE_MINERALE_45,
    code: "GEN_LAINE_MINERALE_45",
    type: catalogue_type:PRODUIT,
    libelle: "Laine minérale acoustique épaisseur 45 mm",
    description: "Matelas isolant thermo-acoustique pour incorporation dans ossature métallique 48 mm (R=1.10 m².K/W).",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 15.6,
        poids_kg: 12.0
    },
    master_id: "catalogue_item:GEN_LAINE_MINERALE_45",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Vis autoforeuse TTPC 25 mm
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_VIS_TTPC_25,
    code: "GEN_VIS_TTPC_25",
    type: catalogue_type:PRODUIT,
    libelle: "Vis autoforeuse TTPC 25 mm pour plaque de plâtre",
    description: "Vis tête trompette pointe clou phosphatée pour fixation sur ossature métallique jusqu'à 0.7 mm.",
    unite_reference: base_unite:U,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 1000.0,
        poids_kg: 1.5
    },
    master_id: "catalogue_item:GEN_VIS_TTPC_25",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Enduit à joint en poudre 24h
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_ENDUIT_JOINT_POUDRE,
    code: "GEN_ENDUIT_JOINT_POUDRE",
    type: catalogue_type:PRODUIT,
    libelle: "Enduit à joint pour plaque de plâtre en poudre 24h",
    description: "Enduit de prise pour collage et finition des bandes à joint papier (sac de 25 kg).",
    unite_reference: base_unite:KG,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 25.0,
        poids_kg: 25.0
    },
    master_id: "catalogue_item:GEN_ENDUIT_JOINT_POUDRE",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Bande à joint papier micro-perforée 150 m
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_BANDE_JOINT_PAPIER,
    code: "GEN_BANDE_JOINT_PAPIER",
    type: catalogue_type:PRODUIT,
    libelle: "Bande à joint papier micro-perforée 150 m",
    description: "Bande d'armature avec pli central pour traitement des joints droits et d'angles.",
    unite_reference: base_unite:ML,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 150.0,
        poids_kg: 0.9
    },
    master_id: "catalogue_item:GEN_BANDE_JOINT_PAPIER",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Main d'œuvre / Poseur plaquiste pose cloison 72/48
CREATE catalogue_item CONTENT {
    id: catalogue_item:GEN_MO_POSE_CLOISON_72_48,
    code: "GEN_MO_POSE_CLOISON_72_48",
    type: catalogue_type:RESSOURCE,
    libelle: "Poseur plaquiste — Pose cloison 72/48",
    description: "Temps d'exécution moyen pour traçage, ossature, isolant, placage 2 faces et jointoiement.",
    unite_reference: base_unite:H,
    nature_reference: "GENERIQUE",
    is_composite: false,
    has_variants: false,
    master_id: "catalogue_item:GEN_MO_POSE_CLOISON_72_48",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ----------------------------------------------------------------------------
-- 2. RÉFÉRENCES COMMERCIALES (Spécifications fabricants)
-- Note : les références commerciales et GTIN non vérifiés sur les bases officielles
-- sont marqués explicitement comme données d'illustration/fictives (metadata.is_fictif = true).
-- ----------------------------------------------------------------------------

-- Placo Saint-Gobain : Placoplatre BA13 2500x1200
-- GTIN-13 validé par algorithme GS1 Modulo 10 : 3456789012340
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_PLACO_BA13_2500,
    code: "COM_PLACO_BA13_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Placoplatre BA13 standard 2500x1200 mm",
    description: "Plaque Placo BA13 originale certifiée NF Bâtiment, bords amincis.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACOPLATRE",
    reference_fabricant: "01000101",
    code_barre: "3456789012340",
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
        { type: "FT", titre: "Fiche Technique Placoplatre BA13", url: "https://placo.fr/ft/ba13-std.pdf" },
        { type: "DoP", titre: "Déclaration de Performances CE Placoplatre", url: "https://placo.fr/dop/dop-001.pdf" }
    ],
    metadata: {
        is_fictif: true,
        notice: "Donnée de démonstration pilote BTP — non publiée comme référence officielle"
    },
    master_id: "catalogue_item:COM_PLACO_BA13_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Knauf : Plaque standard KS 13 2500x1200
-- GTIN-13 validé par algorithme GS1 Modulo 10 : 4006381333931
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_KNAUF_BA13_2500,
    code: "COM_KNAUF_BA13_2500",
    type: catalogue_type:PRODUIT,
    libelle: "Knauf Standard KS 13 2500x1200 mm",
    description: "Plaque de plâtre cartonnée Knauf pour doublages et cloisons intérieures.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "KNAUF",
    marque: "KNAUF",
    reference_fabricant: "KN-2500-13",
    code_barre: "4006381333931",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 27.3,
        dimensions: { longueur: 2500, largeur: 1200, epaisseur: 12.5 }
    },
    metadata: {
        is_fictif: true,
        notice: "Donnée de démonstration pilote BTP — non publiée comme référence officielle"
    },
    master_id: "catalogue_item:COM_KNAUF_BA13_2500",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- Isover : Laine minérale PAR Phonic 45 mm
-- GTIN-13 validé par algorithme GS1 Modulo 10 : 3567890123457
CREATE catalogue_item CONTENT {
    id: catalogue_item:COM_ISOVER_PAR_PHONIC_45,
    code: "COM_ISOVER_PAR_PHONIC_45",
    type: catalogue_type:PRODUIT,
    libelle: "Isover PAR Phonic épaisseur 45 mm",
    description: "Panneau roulé de laine de verre acoustique avec voile de confort pour cloisons 72/48.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN ISOVER",
    marque: "ISOVER",
    reference_fabricant: "PAR-45-1200",
    code_barre: "3567890123457",
    statut_commercial: "ACTIF",
    is_composite: false,
    has_variants: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 15.6,
        poids_kg: 12.0
    },
    metadata: {
        is_fictif: true,
        notice: "Donnée de démonstration pilote BTP — non publiée comme référence officielle"
    },
    master_id: "catalogue_item:COM_ISOVER_PAR_PHONIC_45",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- ----------------------------------------------------------------------------
-- 3. RELATIONS COMMERCIALES (COMMERCIAL_SPECIFICATION)
-- Liaison univoque : Référence commerciale -> Référence générique correspondante
-- ----------------------------------------------------------------------------

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_PLACO_BA13_2500,
    cible: catalogue_item:GEN_PLAQUE_BA13_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    ordre: 1,
    commentaire: "Spécification commerciale officielle Saint-Gobain Placo pour Plaque BA13 générique",
    enabled: true,
    created_at: time::now()
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_KNAUF_BA13_2500,
    cible: catalogue_item:GEN_PLAQUE_BA13_2500,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    ordre: 2,
    commentaire: "Spécification commerciale officielle Knauf pour Plaque BA13 générique",
    enabled: true,
    created_at: time::now()
};

CREATE catalogue_relation CONTENT {
    source: catalogue_item:COM_ISOVER_PAR_PHONIC_45,
    cible: catalogue_item:GEN_LAINE_MINERALE_45,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    ordre: 1,
    commentaire: "Spécification commerciale officielle Isover pour isolant acoustique 45 mm",
    enabled: true,
    created_at: time::now()
};

-- ----------------------------------------------------------------------------
-- 4. OUVRAGE COMPOSÉ : Cloison de distribution 72/48 standard (DTU 25.41)
-- ----------------------------------------------------------------------------

CREATE catalogue_item CONTENT {
    id: catalogue_item:OUV_CLOISON_72_48_STD,
    code: "OUV_CLOISON_72_48_STD",
    type: catalogue_type:OUVRAGE,
    libelle: "Cloison de distribution 72/48 standard (1 BA13 / face + ossature 48 + laine 45)",
    description: "Cloison distributrice d'épaisseur totale 72 mm constituée d'une ossature métallique de 48 mm, isolant laine minérale de 45 mm et 1 plaque BA13 par face (Rw = 42 dB selon DTU 25.41).",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: true,
    has_variants: false,
    master_id: "catalogue_item:OUV_CLOISON_72_48_STD",
    is_custom: false,
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};

-- En-tête de composition (créé en DRAFT avec is_locked: false pour permettre l'ajout des lignes)
CREATE catalogue_composition CONTENT {
    id: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    parent_item: catalogue_item:OUV_CLOISON_72_48_STD,
    version: 1,
    statut: "DRAFT",
    libelle: "Nomenclature standard DTU 25.41 au m²",
    is_locked: false,
    date_effet: time::now(),
    created_at: time::now(),
    updated_at: time::now()
};

-- Lignes de composants détaillées avec application rigoureuse du correctif CTO n°1 :
-- ÉVITEMENT DU DOUBLE COMPTAGE DES PERTES.
-- La quantité est STRICTEMENT la quantité géométrique/physique NETTE au m² d'ouvrage.
-- Le coefficient de perte isole la marge technique de coupe et de chantier.
-- 1 m² de cloison à 2 parements comporte exactement 2.00 m² de plaque BA13.
-- Avec coefficient_perte = 1.025 (2.5% de chute), la consommation effective est 2.00 * 1.025 = 2.05 m².

-- Ligne 1 : Plaque de plâtre BA13 (2 m² nets pour 1 m² de cloison, 2.5% de perte)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_PLAQUE_BA13_2500,
    quantite: 2.00,
    unite: base_unite:M2,
    coefficient_perte: 1.025,
    ordre: 1,
    commentaire: "Parements recto-verso (2 m² nets + 2.5% de chutes de coupe)"
};

-- Ligne 2 : Montant M48 (2.0 ml nets d'ossature verticale avec entraxe 60 cm et renforts, 5% de chute)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_MONTANT_M48_2600,
    quantite: 2.00,
    unite: base_unite:ML,
    coefficient_perte: 1.050,
    ordre: 2,
    commentaire: "Ossature verticale entraxe standard 600 mm + renforts de rives"
};

-- Ligne 3 : Rail R48 (0.80 ml net pour lisses haute et basse, 5% de chute)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_RAIL_R48_3000,
    quantite: 0.80,
    unite: base_unite:ML,
    coefficient_perte: 1.050,
    ordre: 3,
    commentaire: "Lisses haute au plafond et basse au sol"
};

-- Ligne 4 : Isolant laine minérale 45 mm (1.00 m² net incorporé dans le plénum, 5% de chute)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_LAINE_MINERALE_45,
    quantite: 1.00,
    unite: base_unite:M2,
    coefficient_perte: 1.050,
    ordre: 4,
    commentaire: "Matelas isolant thermo-acoustique incorporé dans le plénum"
};

-- Ligne 5 : Vis TTPC 25 (24 vis nettes = 12 vis par face au m² avec pas de 30 cm, 8% de perte)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_VIS_TTPC_25,
    quantite: 24.00,
    unite: base_unite:U,
    coefficient_perte: 1.080,
    ordre: 5,
    commentaire: "Fixation des parements tous les 300 mm sur montants"
};

-- Ligne 6 : Enduit à joint en poudre (0.66 kg net pour traitement des bandes, 10% de gâchage)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_ENDUIT_JOINT_POUDRE,
    quantite: 0.66,
    unite: base_unite:KG,
    coefficient_perte: 1.100,
    ordre: 6,
    commentaire: "Collage et passes de finition des joints selon DTU"
};

-- Ligne 7 : Bande à joint papier (2.80 ml nets au m², 5% de chute)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_BANDE_JOINT_PAPIER,
    quantite: 2.80,
    unite: base_unite:ML,
    coefficient_perte: 1.050,
    ordre: 7,
    commentaire: "Armature papier pour joints droits et raccords de plafond"
};

-- Ligne 8 : Poseur plaquiste (0.75 heure nette de main d'œuvre au m², 0% de perte)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_OUV_CLOISON_72_48_V1,
    composant_item: catalogue_item:GEN_MO_POSE_CLOISON_72_48,
    quantite: 0.75,
    unite: base_unite:H,
    coefficient_perte: 1.000,
    ordre: 8,
    commentaire: "Temps unitaire d'exécution plaquiste (pose complète et jointoiement)"
};

-- Verrouillage et scellement d'immuabilité de la composition
UPDATE catalogue_composition:COMP_OUV_CLOISON_72_48_V1 SET
    statut = "PUBLISHED",
    is_locked = true,
    published_at = time::now();

-- ----------------------------------------------------------------------------
-- 5. SIMULATION DE PERSONNALISATION LOCALE TENANT & ARTICLE PRIVÉ
-- ----------------------------------------------------------------------------

-- Cas A : Personnalisation locale autorisée sur un article synchronisé du Master
-- L'organisation cliente surcharge son code interne et son libellé commercial devis,
-- sans altérer le master_id ni les attributs physiques d'origine.
UPDATE catalogue_item:COM_PLACO_BA13_2500 SET
    code_interne_client = "STOCK-PLACO-NORD",
    libelle_personnalise = "Plaque Placo BA13 2.50m (Stock Chantier Nord)";

-- Cas B : Création d'une référence 100% privée locale
-- master_id = NONE, is_custom = true : n'appartient pas au Master, exclusivité client.
CREATE catalogue_item CONTENT {
    id: catalogue_item:PRIV_PANNEAU_DECO_SUR_MESURE,
    code: "PRIV_PANNEAU_DECO_SUR_MESURE",
    type: catalogue_type:PRODUIT,
    libelle: "Panneau mural acoustique rainuré plaqué chêne sur mesure",
    description: "Panneau décoratif haut de gamme fabriqué sur plan par l'atelier interne de menuiserie.",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE INTERNE CLIENT",
    marque: "SUR-MESURE",
    reference_fabricant: "DECO-CHENE-001",
    statut_commercial: "ACTIF",
    master_id: NONE,
    is_custom: true,
    code_interne_client: "ATELIER-DECO-01",
    libelle_personnalise: "Habillage mural Chêne sur mesure",
    enabled: true,
    is_system: false,
    created_at: time::now(),
    updated_at: time::now()
};
