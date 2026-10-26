-- 0. Préparation : création d'un article, attributs et d'une variante
LET $item_res = fn::catalogue_item_create({
    code: "ITEM_POLO_SECURITE_2",
    type: catalogue_type:PRODUIT,
    libelle: "Polo Haute Visibilité",
    unite_reference: base_unite:U,
    has_variants: true
});
LET $item = $item_res.data;

LET $attr_t_res = fn::catalogue_attribut_create({
    code: "ATTR_POLO_TAILLE_2",
    libelle: "Taille",
    type_donnee: "STRING",
    is_variant_driver: true
});
LET $attr_taille = $attr_t_res.data;

LET $attr_c_res = fn::catalogue_attribut_create({
    code: "ATTR_POLO_COULEUR_2",
    libelle: "Couleur",
    type_donnee: "COLOR",
    is_variant_driver: true
});
LET $attr_couleur = $attr_c_res.data;

LET $val_m_res = fn::catalogue_attribut_valeur_create({
    attribut: $attr_taille.id,
    code: "TAILLE_M2",
    valeur_texte: "M",
    libelle_affichage: "Medium"
});
LET $val_m = $val_m_res.data;

LET $val_l_res = fn::catalogue_attribut_valeur_create({
    attribut: $attr_taille.id,
    code: "TAILLE_L2",
    valeur_texte: "L",
    libelle_affichage: "Large"
});
LET $val_l = $val_l_res.data;

LET $val_bleu_res = fn::catalogue_attribut_valeur_create({
    attribut: $attr_couleur.id,
    code: "COL_BLEU2",
    valeur_texte: "#0000FF",
    libelle_affichage: "Bleu Nuit"
});
LET $val_bleu = $val_bleu_res.data;

LET $var_res = fn::catalogue_variante_create({
    item_id: $item.id,
    code: "POLO-SEC-M2",
    libelle: "Polo Haute Visibilité - Taille M"
});
LET $var = $var_res.data;

-- Étape initiale légitime : affectation de TAILLE = M via la fonction métier autorisée
LET $init_sync = fn::catalogue_variante_set_attributs({
    variante_id: $var.id,
    item_id: $item.id,
    attributs: [
        { attribut: $attr_taille.id, valeur: $val_m.id }
    ]
});
LET $initial_fingerprint = $init_sync.data.empreinte;

-- ----------------------------------------------------------------------------
-- TEST 3 : Modification directe de TAILLE=M vers TAILLE=L -> DOIT ÉCHOUER
-- ----------------------------------------------------------------------------
UPDATE catalogue_variante_attribut 
    SET attribut_valeur = $val_l.id 
    WHERE variante = $var.id AND attribut = $attr_taille.id;

-- ----------------------------------------------------------------------------
-- TEST 4 : Ajout direct d'un nouvel attribut COULEUR=BLEU -> DOIT ÉCHOUER
-- ----------------------------------------------------------------------------
CREATE catalogue_variante_attribut CONTENT {
    item: $item.id,
    variante: $var.id,
    attribut: $attr_couleur.id,
    attribut_valeur: $val_bleu.id
};

-- ----------------------------------------------------------------------------
-- TEST 5 : Suppression directe d'un attribut de la variante -> DOIT ÉCHOUER
-- ----------------------------------------------------------------------------
DELETE catalogue_variante_attribut WHERE variante = $var.id;

-- ----------------------------------------------------------------------------
-- TEST 6 : Modification directe de catalogue_variante.empreinte_attributs -> DOIT ÉCHOUER
-- ----------------------------------------------------------------------------
UPDATE ONLY $var.id SET empreinte_attributs = "FAUSSE_EMPREINTE_PIRATEE_123456";

-- ----------------------------------------------------------------------------
-- TEST 7 : Vérification que les associations et l'empreinte sont STRICTEMENT INCHANGÉES
-- ----------------------------------------------------------------------------
LET $current_var = (SELECT empreinte_attributs FROM ONLY $var.id);
LET $current_attrs = (SELECT attribut, attribut_valeur FROM catalogue_variante_attribut WHERE variante = $var.id);

RETURN {
    initial_fingerprint: $initial_fingerprint,
    current_fingerprint: $current_var.empreinte_attributs,
    fingerprint_intact: ($initial_fingerprint == $current_var.empreinte_attributs),
    attributs_count: array::len($current_attrs),
    attribut_valeur_intact: ($current_attrs[0].attribut_valeur == $val_m.id)
};
