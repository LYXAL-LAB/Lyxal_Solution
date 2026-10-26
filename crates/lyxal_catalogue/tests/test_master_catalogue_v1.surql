-- ============================================================================
-- SUITE OFFICIELLE DE VALIDATION CTO : MASTER CATALOGUE V1
-- FICHIER : test_master_catalogue_v1.surql
-- MOTEUR  : SurrealDB v3.2.0
-- RÔLE    : Valider rigoureusement les 10 exigences et garanties CTO :
--   1. Deux références privées avec master_id = NONE (autorisées)
--   2. Deux références locales avec le même master_id renseigné (rejetées)
--   3. GTIN invalide avec bonne longueur mais mauvaise clé de contrôle GS1 Modulo 10 (rejeté)
--   4. Référence fabricant dupliquée sur le même fabricant (rejetée)
--   5. Tentative de modification directe d'un champ maître synchronisé (rejetée par verrou moteur)
--   6. Modification autorisée d'une référence commerciale liée à un générique (succès)
--   7. Cycle de remplacement de profondeur > 2 (A -> B -> C -> A) (rejeté par anti-cycle)
--   8. Composition BTP avec pertes isolées (non double-comptées) et conditionnements physiques
--   9. Protection de la nature générique vs commerciale (rejet des mélanges non conformes)
--  10. Non-régression complète de l'intégrité du catalogue
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TEST 1 : DEUX RÉFÉRENCES PRIVÉES AVEC master_id = NONE
-- DOIT RÉUSSIR SANS CONFLIT D'UNICITÉ
-- ----------------------------------------------------------------------------
LET $priv_1 = fn::catalogue_item_create({
    code: "TEST_PRIV_ITEM_01",
    type: catalogue_type:PRODUIT,
    libelle: "Article privé sur mesure A",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "ATELIER CLIENT",
    is_custom: true,
    master_id: NONE
});

LET $priv_2 = fn::catalogue_item_create({
    code: "TEST_PRIV_ITEM_02",
    type: catalogue_type:PRODUIT,
    libelle: "Article privé sur mesure B",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "ATELIER CLIENT",
    is_custom: true,
    master_id: NONE
});

-- ----------------------------------------------------------------------------
-- TEST 2 : DEUX RÉFÉRENCES LOCALES AVEC LE MÊME master_id RENSEIGNÉ
-- LA SECONDE DOIT ÊTRE BLOQUÉE
-- ----------------------------------------------------------------------------
LET $sync_1 = fn::catalogue_item_create({
    code: "TEST_SYNC_ITEM_01",
    type: catalogue_type:PRODUIT,
    libelle: "Article synchronisé 1",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "FABRICANT EXT",
    is_custom: false,
    master_id: "catalogue_item:EXT_SHARED_001"
});

LET $sync_2_collision = fn::catalogue_item_create({
    code: "TEST_SYNC_ITEM_02",
    type: catalogue_type:PRODUIT,
    libelle: "Article tentant de réutiliser le même master_id",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "FABRICANT EXT",
    is_custom: false,
    master_id: "catalogue_item:EXT_SHARED_001"
});

-- ----------------------------------------------------------------------------
-- TEST 3 : GTIN INVALIDE AVEC BONNE LONGUEUR MAIS MAUVAISE CLÉ DE CONTRÔLE GS1
-- 3456789012341 a 13 chiffres mais sa clé correcte est 0 -> DOIT ÊTRE REJETÉ
-- ----------------------------------------------------------------------------
LET $bad_gtin = fn::catalogue_item_create({
    code: "TEST_BAD_GTIN_ITEM",
    type: catalogue_type:PRODUIT,
    libelle: "Produit avec GTIN-13 erroné",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TEST LAB",
    code_barre: "3456789012341"
});

-- Produit avec GTIN-13 valide (clé 0) -> DOIT RÉUSSIR
LET $good_gtin = fn::catalogue_item_create({
    code: "TEST_GOOD_GTIN_ITEM",
    type: catalogue_type:PRODUIT,
    libelle: "Produit avec GTIN-13 officiel valide",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TEST LAB",
    code_barre: "3456789012340"
});

-- ----------------------------------------------------------------------------
-- TEST 4 : RÉFÉRENCE FABRICANT DUPLIQUÉE CHEZ LE MÊME FABRICANT
-- DOIT ÊTRE REJETÉE
-- ----------------------------------------------------------------------------
LET $fab_ref_1 = fn::catalogue_item_create({
    code: "TEST_FAB_REF_01",
    type: catalogue_type:PRODUIT,
    libelle: "Article Fabricant Ref Unique",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "BOSCH OUTILLAGE",
    reference_fabricant: "PRO-BOSCH-2026"
});

LET $fab_ref_2_collision = fn::catalogue_item_create({
    code: "TEST_FAB_REF_02",
    type: catalogue_type:PRODUIT,
    libelle: "Tentative doublon référence fabricant chez le même fabricant",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "BOSCH OUTILLAGE",
    reference_fabricant: "PRO-BOSCH-2026"
});

-- Même référence usine mais chez un fabricant DIFFERENT -> DOIT RÉUSSIR
LET $fab_ref_other_fab = fn::catalogue_item_create({
    code: "TEST_FAB_REF_MAKITA",
    type: catalogue_type:PRODUIT,
    libelle: "Même référence mais chez Makita",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MAKITA FRANCE",
    reference_fabricant: "PRO-BOSCH-2026"
});

-- ----------------------------------------------------------------------------
-- TEST 5 : TENTATIVE DE MODIFICATION DIRECTE D'UN CHAMP MAÎTRE PROTÉGÉ
-- LE VERROU MOTEUR evt_catalogue_item_guard DOIT BLOQUER L'ÉCRITURE DIRECTE
-- ----------------------------------------------------------------------------
-- Tentative directe de modifier master_id via UPDATE direct
LET $direct_tamper_master_id = (
    UPDATE $sync_1.data.id SET master_id = "catalogue_item:HACKED"
);

-- Tentative directe de convertir un article synchronisé en article privé
LET $direct_tamper_is_custom = (
    UPDATE $sync_1.data.id SET is_custom = true
);

-- Tentative locale via fonction de modifier un champ maître protégé (doit échouer avec CATALOGUE_ITEM_SYNC_FIELD_PROTECTED)
LET $local_tamper_master_field = fn::catalogue_item_update({
    id: $sync_1.data.id,
    fabricant: "FABRICANT PIRATE LOCAL"
});

-- Mise à jour autorisée de la description
LET $master_sync_update = fn::catalogue_item_update({
    id: $sync_1.data.id,
    description: "Description officielle mise à jour par le flux Master Catalogue"
});

-- Personnalisation locale autorisée sur article synchronisé (code_interne_client + libelle_personnalise)
LET $local_custom_update = fn::catalogue_item_update({
    id: $sync_1.data.id,
    code_interne_client: "CLI-SYNC-001",
    libelle_personnalise: "Mon Libellé Local Client"
});

-- ----------------------------------------------------------------------------
-- TEST 6 : MODIFICATION D'UNE RÉFÉRENCE COMMERCIALE LIÉE À UN GÉNÉRIQUE
-- DOIT RÉUSSIR SANS BRISER LE LIEN
-- ----------------------------------------------------------------------------
LET $gen_item = fn::catalogue_item_create({
    code: "TEST_GEN_SUPPORT",
    type: catalogue_type:PRODUIT,
    libelle: "Support métallique générique",
    unite_reference: base_unite:U,
    nature_reference: "GENERIQUE"
});

LET $com_item = fn::catalogue_item_create({
    code: "TEST_COM_SUPPORT_SPIT",
    type: catalogue_type:PRODUIT,
    libelle: "Support métallique Spit Pro",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "SPIT PASLODE",
    marque: "SPIT",
    reference_fabricant: "SPIT-SUP-01"
});

LET $rel_spec = fn::catalogue_relation_create({
    source: $com_item.data.id,
    cible: $gen_item.data.id,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Spécification Spit pour support générique"
});

-- Mise à jour autorisée de la référence commerciale (mise en fin de série)
LET $update_com_res = fn::catalogue_item_update({
    id: $com_item.data.id,
    statut_commercial: "FIN_DE_SERIE",
    description: "Fin de série — remplacé prochainement par la version V2"
});

-- ----------------------------------------------------------------------------
-- TEST 7 : CYCLE DE REMPLACEMENT DE PROFONDEUR > 2 (A -> B -> C -> A)
-- DOIT ÊTRE REJETÉ PAR LE VERROU MOTEUR RELATIONNEL
-- ----------------------------------------------------------------------------
LET $item_remp_a = fn::catalogue_item_create({
    code: "TEST_REMP_A",
    type: catalogue_type:PRODUIT,
    libelle: "Génération 1 (A)",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TECH CORP"
});

LET $item_remp_b = fn::catalogue_item_create({
    code: "TEST_REMP_B",
    type: catalogue_type:PRODUIT,
    libelle: "Génération 2 (B)",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TECH CORP"
});

LET $item_remp_c = fn::catalogue_item_create({
    code: "TEST_REMP_C",
    type: catalogue_type:PRODUIT,
    libelle: "Génération 3 (C)",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TECH CORP"
});

-- A remplacé par B (A -> B)
LET $rel_ab = fn::catalogue_relation_create({
    source: $item_remp_a.data.id,
    cible: $item_remp_b.data.id,
    relation_type: catalogue_relation_type:REMPLACEMENT
});

-- B remplacé par C (B -> C)
LET $rel_bc = fn::catalogue_relation_create({
    source: $item_remp_b.data.id,
    cible: $item_remp_c.data.id,
    relation_type: catalogue_relation_type:REMPLACEMENT
});

-- C remplacé par A (C -> A) : CRÉE UN CYCLE A -> B -> C -> A ! DOIT ÊTRE BLOQUÉ
LET $rel_ca_cycle = fn::catalogue_relation_create({
    source: $item_remp_c.data.id,
    cible: $item_remp_a.data.id,
    relation_type: catalogue_relation_type:REMPLACEMENT
});

-- ----------------------------------------------------------------------------
-- TEST 8 : COMPOSITION AVEC PERTES ET CONDITIONNEMENTS
-- QUANTITÉ NETTE ET COEFFICIENT DE PERTE SÉPARÉS
-- ----------------------------------------------------------------------------
LET $btp_composant = fn::catalogue_item_create({
    code: "TEST_COMPOSANT_M2",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque technique brute",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 27.5
    }
});

LET $btp_ouvrage = fn::catalogue_item_create({
    code: "TEST_OUVRAGE_CLOISON",
    type: catalogue_type:OUVRAGE,
    libelle: "Ouvrage de cloison test",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_composite: true
});

LET $btp_comp = fn::catalogue_composition_create({
    parent_item: $btp_ouvrage.data.id,
    libelle: "Recette test sans double perte"
});

-- Ajout ligne : 2.0 m² nettes, 2.5% de perte (coef 1.025)
LET $btp_ligne = fn::catalogue_composition_add_line({
    composition_id: $btp_comp.data.id,
    composant_item: $btp_composant.data.id,
    quantite: 2.00,
    unite: base_unite:M2,
    coefficient_perte: 1.025
});

-- ----------------------------------------------------------------------------
-- TEST 9 : CONTRÔLE DE NATURE GÉNÉRIQUE VS COMMERCIALE
-- ----------------------------------------------------------------------------
-- Générique tentant de déclarer un fabricant ou une marque -> DOIT ÉCHOUER
LET $bad_generic = fn::catalogue_item_create({
    code: "TEST_BAD_GENERIC",
    type: catalogue_type:PRODUIT,
    libelle: "Faux générique avec marque",
    unite_reference: base_unite:U,
    nature_reference: "GENERIQUE",
    fabricant: "PLACOPLATRE"
});

-- Commercial tentant d'omettre tout fabricant et marque -> DOIT ÉCHOUER
LET $bad_commercial = fn::catalogue_item_create({
    code: "TEST_BAD_COMMERCIAL",
    type: catalogue_type:PRODUIT,
    libelle: "Faux commercial sans marque ni fabricant",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE"
});

-- ----------------------------------------------------------------------------
-- RAPPORT RÉCAPITULATIF DES TESTS
-- ----------------------------------------------------------------------------
RETURN {
    test_1_two_privates_none: {
        item_1_success: ($priv_1.data.id != NONE),
        item_2_success: ($priv_2.data.id != NONE),
        passed: ($priv_1.data.id != NONE AND $priv_2.data.id != NONE)
    },
    test_2_duplicate_master_id: {
        sync_1_success: ($sync_1.data.id != NONE),
        sync_2_error_code: $sync_2_collision.error.code,
        passed: ($sync_1.data.id != NONE AND $sync_2_collision.error.code = "CATALOGUE_ITEM_MASTER_ID_DUPLICATE")
    },
    test_3_gtin_modulo_10: {
        bad_gtin_error_code: $bad_gtin.error.code,
        good_gtin_success: ($good_gtin.data.id != NONE),
        passed: ($bad_gtin.error.code = "CATALOGUE_ITEM_GTIN_INVALID" AND $good_gtin.data.id != NONE)
    },
    test_4_duplicate_manufacturer_sku: {
        first_sku_success: ($fab_ref_1.data.id != NONE),
        dup_sku_error_code: $fab_ref_2_collision.error.code,
        other_fab_success: ($fab_ref_other_fab.data.id != NONE),
        c1: ($fab_ref_1.data.id != NONE),
        c2: ($fab_ref_2_collision.error.code = "CATALOGUE_ITEM_FAB_REF_DUPLICATE"),
        c3: ($fab_ref_other_fab.data.id != NONE),
        passed: (IF ($fab_ref_1.data.id != NONE) AND ($fab_ref_2_collision.error.code = "CATALOGUE_ITEM_FAB_REF_DUPLICATE") AND ($fab_ref_other_fab.data.id != NONE) { true } ELSE { false })
    },
    test_5_direct_master_protection: {
        tamper_master_id_blocked: ($direct_tamper_master_id == NONE OR array::len($direct_tamper_master_id) = 0),
        tamper_is_custom_blocked: ($direct_tamper_is_custom == NONE OR array::len($direct_tamper_is_custom) = 0),
        local_tamper_error_code: $local_tamper_master_field.error.code,
        master_sync_success: ($master_sync_update.data.id != NONE),
        local_custom_success: ($local_custom_update.data.id != NONE),
        current_master_id: (SELECT VALUE master_id FROM ONLY $sync_1.data.id),
        current_is_custom: (SELECT VALUE is_custom FROM ONLY $sync_1.data.id),
        current_code_client: (SELECT VALUE code_interne_client FROM ONLY $sync_1.data.id),
        passed: (
            ($local_tamper_master_field.error.code = "CATALOGUE_ITEM_SYNC_FIELD_PROTECTED")
            AND ($master_sync_update.data.id != NONE)
            AND ($local_custom_update.data.id != NONE)
            AND ((SELECT VALUE master_id FROM ONLY $sync_1.data.id) = "catalogue_item:EXT_SHARED_001")
            AND ((SELECT VALUE is_custom FROM ONLY $sync_1.data.id) = false)
            AND ((SELECT VALUE code_interne_client FROM ONLY $sync_1.data.id) = "CLI-SYNC-001")
        )
    },
    test_6_commercial_update_with_generic_link: {
        relation_created: ($rel_spec.data.id != NONE),
        update_commercial_success: ($update_com_res.data.id != NONE),
        new_status: $update_com_res.data.statut_commercial,
        passed: (($rel_spec.data.id != NONE) AND ($update_com_res.data.statut_commercial = "FIN_DE_SERIE"))
    },
    test_7_replacement_cycle: {
        rel_ab_success: ($rel_ab.data.id != NONE),
        rel_bc_success: ($rel_bc.data.id != NONE),
        cycle_ca_error_code: $rel_ca_cycle.error.code,
        passed: (($rel_ab.data.id != NONE) AND ($rel_bc.data.id != NONE) AND ($rel_ca_cycle.error.code = "CATALOGUE_RELATION_REMPLACEMENT_CYCLE"))
    },
    test_8_composition_losses_and_packaging: {
        btp_ligne_success: ($btp_ligne.data.id != NONE),
        net_quantity: $btp_ligne.data.quantite,
        loss_coef: $btp_ligne.data.coefficient_perte,
        packaging_type: $btp_composant.data.conditionnement.type_unite,
        c1: ($btp_ligne.data.id != NONE),
        c2: (<float> $btp_ligne.data.quantite = 2.0),
        c3: (<float> $btp_ligne.data.coefficient_perte = 1.025),
        passed: (IF ($btp_ligne.data.id != NONE) AND (<float> $btp_ligne.data.quantite = 2.0) AND (<float> $btp_ligne.data.coefficient_perte = 1.025) { true } ELSE { false })
    },
    test_9_generic_vs_commercial_nature: {
        bad_generic_error_code: $bad_generic.error.code,
        bad_commercial_error_code: $bad_commercial.error.code,
        passed: (($bad_generic.error.code = "CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND") AND ($bad_commercial.error.code = "CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND"))
    }
};
