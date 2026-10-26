-- ============================================================================
-- TESTS DES DERNIERS CONTRÔLES CTO — LYXAL CATALOGUE
-- 1. Anti-cycle indirect A -> B -> C -> A
-- 2. Synchronisation de l'empreinte et protection contre écritures directes
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PARTIE 1 : TEST ANTI-CYCLE INDIRECT A -> B -> C -> A
-- ----------------------------------------------------------------------------
-- Création de 3 ouvrages/ensembles distincts
LET $item_a = fn::catalogue_item_create({
    code: "CYCLE_ITEM_A",
    type: catalogue_type:OUVRAGE,
    libelle: "Ouvrage Alpha (A)",
    unite_reference: base_unite:U
}).data;

LET $item_b = fn::catalogue_item_create({
    code: "CYCLE_ITEM_B",
    type: catalogue_type:OUVRAGE,
    libelle: "Ouvrage Bêta (B)",
    unite_reference: base_unite:U
}).data;

LET $item_c = fn::catalogue_item_create({
    code: "CYCLE_ITEM_C",
    type: catalogue_type:OUVRAGE,
    libelle: "Ouvrage Gamma (C)",
    unite_reference: base_unite:U
}).data;

-- Création des compositions
LET $comp_a = fn::catalogue_composition_create({ parent_item: $item_a.id, libelle: "Comp A" }).data;
LET $comp_b = fn::catalogue_composition_create({ parent_item: $item_b.id, libelle: "Comp B" }).data;
LET $comp_c = fn::catalogue_composition_create({ parent_item: $item_c.id, libelle: "Comp C" }).data;

-- Étape 1 : A consomme B (A -> B)
RETURN fn::catalogue_composition_add_line({
    composition_id: $comp_a.id,
    composant_item: $item_b.id,
    quantite: 1.0,
    unite: base_unite:U
});

-- Étape 2 : B consomme C (B -> C)
RETURN fn::catalogue_composition_add_line({
    composition_id: $comp_b.id,
    composant_item: $item_c.id,
    quantite: 1.0,
    unite: base_unite:U
});

-- Étape 3 : Tentative de faire consommer A par C (C -> A)
-- Créerait la boucle A -> B -> C -> A ! DOIT ÊTRE BLOQUÉ AVEC CATALOGUE_COMPOSITION_CYCLE_DETECTED
RETURN fn::catalogue_composition_add_line({
    composition_id: $comp_c.id,
    composant_item: $item_a.id,
    quantite: 1.0,
    unite: base_unite:U
});

-- ----------------------------------------------------------------------------
-- PARTIE 2 : TEST DE DÉSYNCHRONISATION ET CONTOURMENT DES VARIANTES
-- ----------------------------------------------------------------------------
LET $item_tshirt = fn::catalogue_item_create({
    code: "ITEM_TSHIRT",
    type: catalogue_type:PRODUIT,
    libelle: "T-Shirt Coton Bio",
    unite_reference: base_unite:U,
    has_variants: true
}).data;

LET $attr_taille = fn::catalogue_attribut_create({
    code: "ATTR_TAILLE",
    libelle: "Taille Textile",
    type_donnee: "STRING",
    is_variant_driver: true
}).data;

LET $val_m = fn::catalogue_attribut_valeur_create({
    attribut: $attr_taille.id,
    code: "SIZE_M",
    valeur_texte: "M",
    libelle_affichage: "Taille Medium"
}).data;

LET $val_l = fn::catalogue_attribut_valeur_create({
    attribut: $attr_taille.id,
    code: "SIZE_L",
    valeur_texte: "L",
    libelle_affichage: "Taille Large"
}).data;

LET $var_1 = fn::catalogue_variante_create({
    item_id: $item_tshirt.id,
    code: "TSHIRT-M",
    libelle: "T-Shirt Taille M"
}).data;

-- Synchronisation officielle conforme
LET $sync_res = fn::catalogue_variante_set_attributs({
    variante_id: $var_1.id,
    item_id: $item_tshirt.id,
    attributs: [
        { attribut: $attr_taille.id, valeur: $val_m.id }
    ]
});
RETURN $sync_res;

-- TEST DE CONTOURNEMENT : Tentative d'écriture directe pour doubler un attribut sur la même variante
-- Le champ target_scope est forcé par VALUE (non falsifiable) et l'index UNIQUE doit bloquer immédiatement
CREATE catalogue_variante_attribut CONTENT {
    item: $item_tshirt.id,
    variante: $var_1.id,
    attribut: $attr_taille.id,
    attribut_valeur: $val_l.id
};
