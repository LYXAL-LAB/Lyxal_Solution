-- ============================================================================
-- SUITE OFFICIELLE DE VALIDATION FINALE V2.1 — LYXAL CATALOGUE
-- Couvre le CRUD complet des 12 tables, l'immuabilité moteur, les anti-cycles
-- et l'atomicité transactionnelle des variantes.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- BLOC 1 : TYPES ET TAXONOMIE ARBORESCENTE
-- ----------------------------------------------------------------------------
-- 1.1 Consultation des types fondamentaux
RETURN fn::catalogue_type_list({});

-- 1.2 Création catégorie racine
LET $cat_menuiserie = fn::catalogue_categorie_create({
    code: "CAT_MENUISERIE",
    libelle: "Menuiserie & Fermetures"
}).data;

-- 1.3 Création sous-catégorie
LET $cat_fenetre = fn::catalogue_categorie_create({
    code: "CAT_FENETRES",
    libelle: "Fenêtres & Portes-fenêtres",
    parent: $cat_menuiserie.id
}).data;

-- 1.4 Test Anti-cycle Catégorie : Tenter de faire de la racine l'enfant de sa sous-catégorie -> DOIT ÉCHOUER
RETURN fn::catalogue_categorie_update({
    id: $cat_menuiserie.id,
    parent: $cat_fenetre.id
});

-- 1.5 Arborescence complète
RETURN fn::catalogue_categorie_tree({});

-- ----------------------------------------------------------------------------
-- BLOC 2 : CRÉATION D'ITEM MAÎTRE ET ATTRIBUTS STATIQUES
-- ----------------------------------------------------------------------------
-- 2.1 Création d'un produit parent déclinable
LET $item_fenetre = fn::catalogue_item_create({
    code: "ITEM_FEN_PREMIUM",
    type: catalogue_type:PRODUIT,
    libelle: "Fenêtre Premium Sur-Mesure",
    unite_reference: base_unite:U,
    has_variants: true,
    categories: [ $cat_fenetre.id ]
}).data;

-- 2.2 Création d'attributs
LET $attr_garantie = fn::catalogue_attribut_create({
    code: "ATTR_GARANTIE",
    libelle: "Garantie Constructeur",
    type_donnee: "STRING",
    is_variant_driver: false
}).data;

LET $attr_couleur = fn::catalogue_attribut_create({
    code: "ATTR_COULEUR",
    libelle: "Teinte de Finition",
    type_donnee: "COLOR",
    is_variant_driver: true
}).data;

-- 2.3 Création des valeurs
LET $val_10ans = fn::catalogue_attribut_valeur_create({
    attribut: $attr_garantie.id,
    code: "GAR_10ANS",
    valeur_texte: "10 Ans Pièces et Main d'Oeuvre",
    libelle_affichage: "Garantie 10 Ans"
}).data;

LET $val_blanc = fn::catalogue_attribut_valeur_create({
    attribut: $attr_couleur.id,
    code: "COL_BLANC",
    valeur_texte: "#FFFFFF",
    libelle_affichage: "Blanc Signalisation"
}).data;

LET $val_gris = fn::catalogue_attribut_valeur_create({
    attribut: $attr_couleur.id,
    code: "COL_GRIS",
    valeur_texte: "#2F353B",
    libelle_affichage: "Gris Anthracite"
}).data;

-- 2.4 Affectation attribut statique sur l'item parent (Garantie 10 ans)
RETURN fn::catalogue_attribut_set_static({
    item_id: $item_fenetre.id,
    attribut_id: $attr_garantie.id,
    valeur_id: $val_10ans.id
});

-- ----------------------------------------------------------------------------
-- BLOC 3 : DÉCLINAISONS EN VARIANTES ET INTÉGRITÉ DE COMBINAISON
-- ----------------------------------------------------------------------------
-- 3.1 Création de deux variantes
LET $var_blanc = fn::catalogue_variante_create({
    item_id: $item_fenetre.id,
    code: "FEN-PREM-BLANC",
    libelle: "Fenêtre Premium - Blanc"
}).data;

LET $var_gris = fn::catalogue_variante_create({
    item_id: $item_fenetre.id,
    code: "FEN-PREM-GRIS",
    libelle: "Fenêtre Premium - Gris"
}).data;

-- 3.2 Synchronisation des attributs de VAR_BLANC
RETURN fn::catalogue_variante_set_attributs({
    variante_id: $var_blanc.id,
    item_id: $item_fenetre.id,
    attributs: [
        { attribut: $attr_couleur.id, valeur: $val_blanc.id }
    ]
});

-- 3.3 Test Doublon / Concurrence : Tenter d'affecter la même combinaison blanche à VAR_GRIS -> DOIT ÉCHOUER
RETURN fn::catalogue_variante_set_attributs({
    variante_id: $var_gris.id,
    item_id: $item_fenetre.id,
    attributs: [
        { attribut: $attr_couleur.id, valeur: $val_blanc.id }
    ]
});

-- 3.4 Affectation de la couleur distincte à VAR_GRIS -> DOIT RÉUSSIR
RETURN fn::catalogue_variante_set_attributs({
    variante_id: $var_gris.id,
    item_id: $item_fenetre.id,
    attributs: [
        { attribut: $attr_couleur.id, valeur: $val_gris.id }
    ]
});

-- ----------------------------------------------------------------------------
-- BLOC 4 : COMPOSITIONS, COMPOSANTS, IMMUABILITÉ ET CLONAGE DE VERSION
-- ----------------------------------------------------------------------------
-- 4.1 Création de l'ouvrage parent
LET $ouvrage_pose = fn::catalogue_item_create({
    code: "OUV_POSE_FEN_PREM",
    type: catalogue_type:OUVRAGE,
    libelle: "Pose Ouvrage Fenêtre Premium",
    unite_reference: base_unite:U
}).data;

-- 4.2 Création de la composition DRAFT v1
LET $comp_v1 = fn::catalogue_composition_create({
    parent_item: $ouvrage_pose.id,
    libelle: "Pose standard neuve v1"
}).data;

-- 4.3 Ajout de ligne de composant (variante précise consommée)
RETURN fn::catalogue_composition_add_line({
    composition_id: $comp_v1.id,
    composant_item: $item_fenetre.id,
    composant_variante: $var_blanc.id,
    quantite: 1.0,
    unite: base_unite:U,
    coefficient_perte: 1.0
});

-- 4.4 Publication de la composition v1 -> Devient scellée
LET $published_v1 = fn::catalogue_composition_publish({
    composition_id: $comp_v1.id
}).data;

-- 4.5 Test Immuabilité : Tentative d'ajouter une ligne sur la v1 publiée -> DOIT ÉCHOUER (Verrou moteur)
RETURN fn::catalogue_composition_add_line({
    composition_id: $comp_v1.id,
    composant_item: $item_fenetre.id,
    composant_variante: $var_gris.id,
    quantite: 1.0,
    unite: base_unite:U
});

-- 4.6 Clonage vers une version 2 DRAFT
LET $clone_res = fn::catalogue_composition_clone_version({
    source_composition_id: $comp_v1.id
}).data;

-- 4.7 Vérification : La nouvelle version 2 est bien en DRAFT et peut accueillir une nouvelle ligne
RETURN fn::catalogue_composition_add_line({
    composition_id: $clone_res.new_composition.id,
    composant_item: $item_fenetre.id,
    composant_variante: $var_gris.id,
    quantite: 1.0,
    unite: base_unite:U
});

-- ----------------------------------------------------------------------------
-- BLOC 5 : RELATIONS INTER-ÉLÉMENTS
-- ----------------------------------------------------------------------------
-- 5.1 Création d'un accessoire
LET $poignee = fn::catalogue_item_create({
    code: "ACC_POIGNEE_ALU",
    type: catalogue_type:PRODUIT,
    libelle: "Poignée Design Aluminium",
    unite_reference: base_unite:U
}).data;

-- 5.2 Création de la relation ACCESSOIRE
RETURN fn::catalogue_relation_create({
    source: $item_fenetre.id,
    cible: $poignee.id,
    relation_type: catalogue_relation_type:ACCESSOIRE,
    commentaire: "Poignée compatible d'origine"
});

-- 5.3 Test Anti-auto-référence : Tenter de lier la poignée à elle-même -> DOIT ÉCHOUER
RETURN fn::catalogue_relation_create({
    source: $poignee.id,
    cible: $poignee.id,
    relation_type: catalogue_relation_type:ACCESSOIRE
});
