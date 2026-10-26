-- ============================================================================
-- TEST : test_variant_transfer.surql
-- MODULE : lyxal_catalogue
-- RÔLE : Validation du transfert d'attributs entre variantes, du passage à NONE,
--        du recalcul bi-directionnel source/cible et du rollback sur conflit.
-- ============================================================================

-- 0. Pré-requis
UPSERT base_unite:U SET code = "U", libelle = "UNITÉ", abreviation = "u", type = base_unite_type:QUANTITE, enabled = true, is_system = true;

-- 1. Création item déclinable et attributs
CREATE catalogue_item:TSHIRT CONTENT {
    code: "ITEM_TSHIRT_TRANSFER",
    type: catalogue_type:PRODUIT,
    libelle: "T-Shirt Col Rond Coton Bio",
    unite_reference: base_unite:U,
    has_variants: true,
    enabled: true
};

CREATE catalogue_attribut:COULEUR CONTENT {
    code: "ATTR_TSHIRT_COLOR",
    libelle: "Couleur",
    type_donnee: "COLOR",
    is_variant_driver: true,
    enabled: true
};

CREATE catalogue_attribut:TAILLE CONTENT {
    code: "ATTR_TSHIRT_SIZE",
    libelle: "Taille",
    type_donnee: "STRING",
    is_variant_driver: true,
    enabled: true
};

CREATE catalogue_attribut_valeur:ROUGE CONTENT {
    attribut: catalogue_attribut:COULEUR,
    code: "VAL_ROUGE",
    valeur_texte: "#FF0000",
    libelle_affichage: "Rouge Rubis",
    enabled: true
};

CREATE catalogue_attribut_valeur:BLEU CONTENT {
    attribut: catalogue_attribut:COULEUR,
    code: "VAL_BLEU",
    valeur_texte: "#0000FF",
    libelle_affichage: "Bleu Marine",
    enabled: true
};

CREATE catalogue_attribut_valeur:M CONTENT {
    attribut: catalogue_attribut:TAILLE,
    code: "VAL_M",
    valeur_texte: "M",
    libelle_affichage: "Taille M",
    enabled: true
};

CREATE catalogue_attribut_valeur:L CONTENT {
    attribut: catalogue_attribut:TAILLE,
    code: "VAL_L",
    valeur_texte: "L",
    libelle_affichage: "Taille L",
    enabled: true
};

-- 2. Création de 2 variantes
CREATE catalogue_variante:VAR_1 CONTENT {
    item: catalogue_item:TSHIRT,
    code: "TSHIRT-R-M",
    libelle: "T-Shirt Rouge Taille M",
    enabled: true
};

CREATE catalogue_variante:VAR_2 CONTENT {
    item: catalogue_item:TSHIRT,
    code: "TSHIRT-B-L",
    libelle: "T-Shirt Bleu Taille L",
    enabled: true
};

-- 3. Initialisation des attributs via fonction métier
LET $init_v1 = fn::catalogue_variante_set_attributs({
    variante_id: catalogue_variante:VAR_1,
    item_id: catalogue_item:TSHIRT,
    attributs: [
        { attribut: catalogue_attribut:COULEUR, valeur: catalogue_attribut_valeur:ROUGE },
        { attribut: catalogue_attribut:TAILLE, valeur: catalogue_attribut_valeur:M }
    ]
});
LET $fp_v1_initial = $init_v1.data.empreinte;

LET $init_v2 = fn::catalogue_variante_set_attributs({
    variante_id: catalogue_variante:VAR_2,
    item_id: catalogue_item:TSHIRT,
    attributs: [
        { attribut: catalogue_attribut:COULEUR, valeur: catalogue_attribut_valeur:BLEU }
    ]
});
LET $fp_v2_initial = $init_v2.data.empreinte;

-- ----------------------------------------------------------------------------
-- TEST 1 : Déplacement d'un attribut de VAR_1 (source) vers VAR_2 (cible)
--          L'événement evt_cva_recalc_fingerprint doit recalculer LES DEUX variantes.
-- ----------------------------------------------------------------------------
UPDATE catalogue_variante_attribut 
    SET variante = catalogue_variante:VAR_2 
    WHERE variante = catalogue_variante:VAR_1 AND attribut = catalogue_attribut:TAILLE;

LET $v1_after_move = (SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_1);
LET $v2_after_move = (SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_2);

-- L'empreinte attendue pour V1 est maintenant seulement ROUGE
LET $expected_fp_v1_moved = crypto::sha256(string::concat(<string> catalogue_attribut:COULEUR, ":", <string> catalogue_attribut_valeur:ROUGE));
-- L'empreinte attendue pour V2 est maintenant BLEU + TAILLE M
LET $p2_1 = string::concat(<string> catalogue_attribut:COULEUR, ":", <string> catalogue_attribut_valeur:BLEU);
LET $p2_2 = string::concat(<string> catalogue_attribut:TAILLE, ":", <string> catalogue_attribut_valeur:M);
LET $expected_fp_v2_moved = crypto::sha256(array::join(array::sort([$p2_1, $p2_2]), "|"));

LET $test1_src_recalc = ($v1_after_move.empreinte_attributs == $expected_fp_v1_moved);
LET $test1_tgt_recalc = ($v2_after_move.empreinte_attributs == $expected_fp_v2_moved);

-- ----------------------------------------------------------------------------
-- TEST 2 : Passage d'un attribut de variante vers NONE (attribut statique item)
--          L'événement doit recalculer la variante source ($before.variante) sans erreur.
-- ----------------------------------------------------------------------------
UPDATE catalogue_variante_attribut 
    SET variante = NONE 
    WHERE variante = catalogue_variante:VAR_2 AND attribut = catalogue_attribut:TAILLE;

LET $v2_after_none = (SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_2);
LET $expected_fp_v2_none = crypto::sha256(string::concat(<string> catalogue_attribut:COULEUR, ":", <string> catalogue_attribut_valeur:BLEU));
LET $test2_none_recalc = ($v2_after_none.empreinte_attributs == $expected_fp_v2_none);

-- ----------------------------------------------------------------------------
-- TEST 3 : Conflit d'empreinte (unicité idx_var_item_fingerprint) et Rollback
--          Tentative de donner à VAR_2 la même combinaison d'attributs que VAR_1
--          (c'est-à-dire remplacer BLEU par ROUGE sur VAR_2).
--          Doit échouer par collision d'index et laisser VAR_2 intacte.
-- ----------------------------------------------------------------------------
LET $conflict_attempt = (
    UPDATE catalogue_variante_attribut 
        SET attribut_valeur = catalogue_attribut_valeur:ROUGE 
        WHERE variante = catalogue_variante:VAR_2 AND attribut = catalogue_attribut:COULEUR
);

-- Vérifier si l'attribut de VAR_2 est resté BLEU (protection intégrité / unicité)
LET $v2_attr_current = (SELECT attribut_valeur FROM ONLY catalogue_variante_attribut WHERE variante = catalogue_variante:VAR_2 AND attribut = catalogue_attribut:COULEUR);
LET $v2_fp_current = (SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_2);

RETURN {
    fp_v1_initial_set: ($fp_v1_initial != ""),
    fp_v2_initial_set: ($fp_v2_initial != ""),
    test1_source_recalculated: $test1_src_recalc,
    test1_target_recalculated: $test1_tgt_recalc,
    test2_none_transition_recalculated: $test2_none_recalc,
    test3_conflict_prevented: ($v2_fp_current.empreinte_attributs != $v1_after_move.empreinte_attributs)
};
