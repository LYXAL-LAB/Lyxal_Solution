-- ============================================================================
-- TESTS OFFICIELS D'INTÉGRITÉ V2.1 — MODULE LYXAL_CATALOGUE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PRÉ-REQUIS : Création d'unités de mesure de test (base_unite) si non présentes
-- ----------------------------------------------------------------------------
UPSERT base_unite:U SET code = "U", libelle = "UNITÉ", abreviation = "u", type = base_unite_type:QUANTITE, enabled = true, is_system = true;
UPSERT base_unite:M2 SET code = "M2", libelle = "MÈTRE CARRÉ", abreviation = "m²", type = base_unite_type:SURFACE, enabled = true, is_system = true;

-- ----------------------------------------------------------------------------
-- ÉTAPE 1 : Test Target Scope et Attributs Statiques vs Déclinaisons (Point 1)
-- ----------------------------------------------------------------------------
-- Création item parent
CREATE catalogue_item:FENETRE_ALU CONTENT {
    code: "FEN-ALU-01",
    type: catalogue_type:PRODUIT,
    libelle: "Fenêtre Aluminium Double Vitrage",
    unite_reference: base_unite:U,
    has_variants: true,
    enabled: true
};

-- Définition attributs
CREATE catalogue_attribut:MATERIAU CONTENT {
    code: "MATERIAU",
    libelle: "Matériau principal",
    type_donnee: "STRING",
    is_variant_driver: false,
    enabled: true
};

CREATE catalogue_attribut:COULEUR CONTENT {
    code: "COULEUR",
    libelle: "Couleur RAL",
    type_donnee: "COLOR",
    is_variant_driver: true,
    enabled: true
};

-- Valeurs d'attributs
CREATE catalogue_attribut_valeur:ALUMINIUM CONTENT {
    attribut: catalogue_attribut:MATERIAU,
    code: "ALU",
    valeur_texte: "ALUMINIUM",
    libelle_affichage: "Aluminium thermolaqué",
    enabled: true
};

CREATE catalogue_attribut_valeur:PVC CONTENT {
    attribut: catalogue_attribut:MATERIAU,
    code: "PVC",
    valeur_texte: "PVC",
    libelle_affichage: "PVC renforcé",
    enabled: true
};

CREATE catalogue_attribut_valeur:BLANC CONTENT {
    attribut: catalogue_attribut:COULEUR,
    code: "RAL9016",
    valeur_texte: "#FFFFFF",
    libelle_affichage: "Blanc pur",
    enabled: true
};

CREATE catalogue_attribut_valeur:GRIS CONTENT {
    attribut: catalogue_attribut:COULEUR,
    code: "RAL7016",
    valeur_texte: "#2F353B",
    libelle_affichage: "Gris Anthracite",
    enabled: true
};

-- TEST 1.1 : Affectation attribut statique (variante = NONE)
CREATE catalogue_variante_attribut CONTENT {
    item: catalogue_item:FENETRE_ALU,
    variante: NONE,
    attribut: catalogue_attribut:MATERIAU,
    attribut_valeur: catalogue_attribut_valeur:ALUMINIUM
};

-- TEST 1.2 : Tentative de doublon statique sur le même item -> DOIT ÉCHOUER (idx_scope_attr)
CREATE catalogue_variante_attribut CONTENT {
    item: catalogue_item:FENETRE_ALU,
    variante: NONE,
    attribut: catalogue_attribut:MATERIAU,
    attribut_valeur: catalogue_attribut_valeur:PVC
};

-- ----------------------------------------------------------------------------
-- ÉTAPE 2 : Intégrité des Variantes, Empreintes et Concurrence (Point 3)
-- ----------------------------------------------------------------------------
CREATE catalogue_variante:VAR_BLANC CONTENT {
    item: catalogue_item:FENETRE_ALU,
    code: "FEN-ALU-BLANC",
    libelle: "Fenêtre Aluminium - Blanc",
    empreinte_attributs: "INIT_1",
    enabled: true
};

CREATE catalogue_variante:VAR_GRIS CONTENT {
    item: catalogue_item:FENETRE_ALU,
    code: "FEN-ALU-GRIS",
    libelle: "Fenêtre Aluminium - Gris Anthracite",
    empreinte_attributs: "INIT_2",
    enabled: true
};

-- TEST 2.1 : Synchronisation canonique de VAR_BLANC
RETURN fn::catalogue_variante_set_attributs({
    variante_id: "catalogue_variante:VAR_BLANC",
    item_id: "catalogue_item:FENETRE_ALU",
    attributs: [
        { attribut: "catalogue_attribut:COULEUR", valeur: "catalogue_attribut_valeur:BLANC" }
    ]
});

-- TEST 2.2 : Tentative d'affecter la même combinaison à VAR_GRIS -> DOIT ÉCHOUER (idx_var_item_fingerprint)
RETURN fn::catalogue_variante_set_attributs({
    variante_id: "catalogue_variante:VAR_GRIS",
    item_id: "catalogue_item:FENETRE_ALU",
    attributs: [
        { attribut: "catalogue_attribut:COULEUR", valeur: "catalogue_attribut_valeur:BLANC" }
    ]
});

-- TEST 2.3 : Affectation de la vraie couleur Gris à VAR_GRIS -> DOIT RÉUSSIR
RETURN fn::catalogue_variante_set_attributs({
    variante_id: "catalogue_variante:VAR_GRIS",
    item_id: "catalogue_item:FENETRE_ALU",
    attributs: [
        { attribut: "catalogue_attribut:COULEUR", valeur: "catalogue_attribut_valeur:GRIS" }
    ]
});

-- ----------------------------------------------------------------------------
-- ÉTAPE 3 : Immuabilité Absolue des Compositions et Verrous Moteur (Point 2)
-- ----------------------------------------------------------------------------
CREATE catalogue_item:OUVRAGE_POSE CONTENT {
    code: "OUV-POSE-FEN",
    type: catalogue_type:OUVRAGE,
    libelle: "Fourniture et Pose Fenêtre Double Vitrage",
    unite_reference: base_unite:U,
    is_composite: false,
    enabled: true
};

-- Création de la composition DRAFT
CREATE catalogue_composition:COMP_V1 CONTENT {
    parent_item: catalogue_item:OUVRAGE_POSE,
    version: 1,
    statut: "DRAFT",
    libelle: "Recette standard pose tunnel",
    is_locked: false
};

-- Ajout des lignes composant
CREATE catalogue_composition_ligne:LIGNE_1 CONTENT {
    composition: catalogue_composition:COMP_V1,
    composant_item: catalogue_item:FENETRE_ALU,
    composant_variante: catalogue_variante:VAR_BLANC,
    quantite: 1.0,
    unite: base_unite:U,
    coefficient_perte: 1.0
};

-- TEST 3.1 : Publication de la composition
RETURN fn::catalogue_composition_publish({
    composition_id: "catalogue_composition:COMP_V1"
});

-- TEST 3.2 : Tentative d'altération du libellé sur la composition publiée -> DOIT ÉCHOUER (evt_composition_protect)
UPDATE catalogue_composition:COMP_V1 SET libelle = "Libellé piraté";

-- TEST 3.3 : Tentative de déverrouiller is_locked directement -> DOIT ÉCHOUER (evt_composition_protect)
UPDATE catalogue_composition:COMP_V1 SET is_locked = false;

-- TEST 3.4 : Tentative de supprimer la composition publiée -> DOIT ÉCHOUER (evt_composition_no_del)
DELETE catalogue_composition:COMP_V1;

-- TEST 3.5 : Tentative de modifier la quantité de la ligne LIGNE_1 -> DOIT ÉCHOUER (evt_comp_ligne_guard)
UPDATE catalogue_composition_ligne:LIGNE_1 SET quantite = 5.0;

-- TEST 3.6 : Tentative de supprimer la ligne LIGNE_1 -> DOIT ÉCHOUER (evt_comp_ligne_guard)
DELETE catalogue_composition_ligne:LIGNE_1;

-- TEST 3.7 : Tentative d'ajouter une nouvelle ligne sur COMP_V1 scellée -> DOIT ÉCHOUER (evt_comp_ligne_guard)
CREATE catalogue_composition_ligne CONTENT {
    composition: catalogue_composition:COMP_V1,
    composant_item: catalogue_item:FENETRE_ALU,
    composant_variante: catalogue_variante:VAR_GRIS,
    quantite: 1.0,
    unite: base_unite:U
};

-- TEST 3.8 : Archivage légitime (PUBLISHED -> ARCHIVED) sans modification de libellé ni de parent -> DOIT RÉUSSIR
UPDATE catalogue_composition:COMP_V1 SET statut = "ARCHIVED";
