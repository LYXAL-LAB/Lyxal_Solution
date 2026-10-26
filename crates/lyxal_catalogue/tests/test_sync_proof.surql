-- ============================================================================
-- TESTS DE SYNCHRONISATION ATOMIQUE ET DE PROTECTION DE L'EMPREINTE
-- ============================================================================

-- 0. Nettoyage préventif des variantes et attributs
DELETE catalogue_variante_attribut;
DELETE catalogue_variante;

-- 1. Initialisation des entités de test
CREATE catalogue_item:ITEM_POLO CONTENT {
    code: "POLO_DET_01",
    type: catalogue_type:PRODUIT,
    libelle: "Polo Test",
    unite_reference: base_unite:U,
    has_variants: true,
    enabled: true
};

CREATE catalogue_attribut:ATTR_TAILLE CONTENT {
    code: "ATTR_TAILLE_DET",
    libelle: "Taille",
    type_donnee: "STRING",
    is_variant_driver: true,
    enabled: true
};

CREATE catalogue_attribut:ATTR_COULEUR CONTENT {
    code: "ATTR_COULEUR_DET",
    libelle: "Couleur",
    type_donnee: "COLOR",
    is_variant_driver: true,
    enabled: true
};

CREATE catalogue_attribut_valeur:VAL_M CONTENT {
    attribut: catalogue_attribut:ATTR_TAILLE,
    code: "TM",
    valeur_texte: "M",
    libelle_affichage: "Medium",
    enabled: true
};

CREATE catalogue_attribut_valeur:VAL_L CONTENT {
    attribut: catalogue_attribut:ATTR_TAILLE,
    code: "TL",
    valeur_texte: "L",
    libelle_affichage: "Large",
    enabled: true
};

CREATE catalogue_attribut_valeur:VAL_BLEU CONTENT {
    attribut: catalogue_attribut:ATTR_COULEUR,
    code: "CBLEU",
    valeur_texte: "#0000FF",
    libelle_affichage: "Bleu",
    enabled: true
};

CREATE catalogue_variante:VAR_TEST CONTENT {
    item: catalogue_item:ITEM_POLO,
    code: "VAR_POLO_01",
    libelle: "Polo Test V1",
    empreinte_attributs: crypto::sha256(""),
    enabled: true
};

-- 2. Affectation officielle initiale : TAILLE = M via fn::catalogue_variante_set_attributs
RETURN fn::catalogue_variante_set_attributs({
    variante_id: "catalogue_variante:VAR_TEST",
    item_id: "catalogue_item:ITEM_POLO",
    attributs: [
        { attribut: "catalogue_attribut:ATTR_TAILLE", valeur: "catalogue_attribut_valeur:VAL_M" }
    ]
});

-- 3. TEST 3 : Modification directe de TAILLE=M vers TAILLE=L
-- Le moteur recalcule immédiatement l'empreinte pour refléter TAILLE=L
UPDATE catalogue_variante_attribut 
    SET attribut_valeur = catalogue_attribut_valeur:VAL_L 
    WHERE variante = catalogue_variante:VAR_TEST AND attribut = catalogue_attribut:ATTR_TAILLE;

SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_TEST;

-- 4. TEST 4 : Ajout direct d'un nouvel attribut COULEUR=BLEU
-- Le moteur recalcule immédiatement l'empreinte pour refléter (TAILLE=L + COULEUR=BLEU)
CREATE catalogue_variante_attribut CONTENT {
    item: catalogue_item:ITEM_POLO,
    variante: catalogue_variante:VAR_TEST,
    attribut: catalogue_attribut:ATTR_COULEUR,
    attribut_valeur: catalogue_attribut_valeur:VAL_BLEU
};

SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_TEST;

-- 5. TEST 5 : Suppression directe d'un attribut (suppression de COULEUR)
-- Le moteur recalcule immédiatement l'empreinte pour refléter uniquement TAILLE=L
DELETE catalogue_variante_attribut WHERE variante = catalogue_variante:VAR_TEST AND attribut = catalogue_attribut:ATTR_COULEUR;

SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_TEST;

-- 6. TEST 6 : Tentative de modification directe frauduleuse de l'empreinte
-- Rejetée par evt_variante_protect_fingerprint
UPDATE catalogue_variante:VAR_TEST SET empreinte_attributs = "HASH_FRAUDULEUX_INVENTE";

-- 7. TEST 7 : Vérification post-rejet : l'empreinte et les associations restent intactes
SELECT id, item, attribut, attribut_valeur FROM catalogue_variante_attribut WHERE variante = catalogue_variante:VAR_TEST;
SELECT empreinte_attributs FROM ONLY catalogue_variante:VAR_TEST;
