-- ============================================================================
-- TEST : test_deep_cycle.surql
-- MODULE : lyxal_catalogue
-- RÔLE : Validation du contrôle récursif anti-cycles au-delà de 5 niveaux (8 niveaux)
--        Garantit que le parcours BFS ne coupe pas silencieusement et détecte
--        les cycles profonds et indirects sans faux positif.
-- ============================================================================

-- 0. Pré-requis : unité de mesure de test
CREATE base_unite:U SET code = "U", libelle = "UNITÉ", abreviation = "u", type = base_unite_type:QUANTITE, enabled = true, is_system = true;

-- 1. Création de la chaîne de 9 items (de niveau 0 à niveau 8)
CREATE catalogue_item:DEEP_0 CONTENT { code: "DEEP_ITEM_0", type: catalogue_type:OUVRAGE, libelle: "Niveau 0 - Système Complexe", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_1 CONTENT { code: "DEEP_ITEM_1", type: catalogue_type:OUVRAGE, libelle: "Niveau 1 - Sous-ensemble A", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_2 CONTENT { code: "DEEP_ITEM_2", type: catalogue_type:OUVRAGE, libelle: "Niveau 2 - Module B", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_3 CONTENT { code: "DEEP_ITEM_3", type: catalogue_type:OUVRAGE, libelle: "Niveau 3 - Composant C", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_4 CONTENT { code: "DEEP_ITEM_4", type: catalogue_type:OUVRAGE, libelle: "Niveau 4 - Bloc D", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_5 CONTENT { code: "DEEP_ITEM_5", type: catalogue_type:OUVRAGE, libelle: "Niveau 5 - Assemblage E", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_6 CONTENT { code: "DEEP_ITEM_6", type: catalogue_type:OUVRAGE, libelle: "Niveau 6 - Élément F", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_7 CONTENT { code: "DEEP_ITEM_7", type: catalogue_type:OUVRAGE, libelle: "Niveau 7 - Pièce G", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_8 CONTENT { code: "DEEP_ITEM_8", type: catalogue_type:PRODUIT, libelle: "Niveau 8 - Matière H", unite_reference: base_unite:U, enabled: true };
CREATE catalogue_item:DEEP_INDEP CONTENT { code: "DEEP_ITEM_INDEP", type: catalogue_type:PRODUIT, libelle: "Item Indépendant Non Cyclique", unite_reference: base_unite:U, enabled: true };

-- 2. Création et publication des 8 compositions reliant la chaîne : 0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8
-- Niveau 0 consomme 1
CREATE catalogue_composition:C_0 CONTENT { parent_item: catalogue_item:DEEP_0, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 0" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_0, composant_item: catalogue_item:DEEP_1, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_0 SET is_locked = true;

-- Niveau 1 consomme 2
CREATE catalogue_composition:C_1 CONTENT { parent_item: catalogue_item:DEEP_1, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 1" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_1, composant_item: catalogue_item:DEEP_2, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_1 SET is_locked = true;

-- Niveau 2 consomme 3
CREATE catalogue_composition:C_2 CONTENT { parent_item: catalogue_item:DEEP_2, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 2" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_2, composant_item: catalogue_item:DEEP_3, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_2 SET is_locked = true;

-- Niveau 3 consomme 4
CREATE catalogue_composition:C_3 CONTENT { parent_item: catalogue_item:DEEP_3, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 3" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_3, composant_item: catalogue_item:DEEP_4, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_3 SET is_locked = true;

-- Niveau 4 consomme 5
CREATE catalogue_composition:C_4 CONTENT { parent_item: catalogue_item:DEEP_4, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 4" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_4, composant_item: catalogue_item:DEEP_5, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_4 SET is_locked = true;

-- Niveau 5 consomme 6
CREATE catalogue_composition:C_5 CONTENT { parent_item: catalogue_item:DEEP_5, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 5" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_5, composant_item: catalogue_item:DEEP_6, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_5 SET is_locked = true;

-- Niveau 6 consomme 7
CREATE catalogue_composition:C_6 CONTENT { parent_item: catalogue_item:DEEP_6, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 6" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_6, composant_item: catalogue_item:DEEP_7, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_6 SET is_locked = true;

-- Niveau 7 consomme 8
CREATE catalogue_composition:C_7 CONTENT { parent_item: catalogue_item:DEEP_7, version: 1, statut: "PUBLISHED", is_locked: false, libelle: "Comp 7" };
CREATE catalogue_composition_ligne CONTENT { composition: catalogue_composition:C_7, composant_item: catalogue_item:DEEP_8, quantite: 1.0, unite: base_unite:U };
UPDATE catalogue_composition:C_7 SET is_locked = true;

-- ----------------------------------------------------------------------------
-- TEST 1 : Cycle direct immédiat A -> A
-- ----------------------------------------------------------------------------
LET $t1_direct = fn::catalogue_composition_check_cycle({
    parent_item: catalogue_item:DEEP_0,
    composant_item: catalogue_item:DEEP_0
});

-- ----------------------------------------------------------------------------
-- TEST 2 : Cycle profond de 8 niveaux (DEEP_8 tente de consommer DEEP_0) -> DOIT RETOURNER true
-- ----------------------------------------------------------------------------
LET $t2_deep_8 = fn::catalogue_composition_check_cycle({
    parent_item: catalogue_item:DEEP_8,
    composant_item: catalogue_item:DEEP_0
});

-- ----------------------------------------------------------------------------
-- TEST 3 : Cycle intermédiaire de 5 niveaux (DEEP_5 tente de consommer DEEP_0) -> DOIT RETOURNER true
-- ----------------------------------------------------------------------------
LET $t3_deep_5 = fn::catalogue_composition_check_cycle({
    parent_item: catalogue_item:DEEP_5,
    composant_item: catalogue_item:DEEP_0
});

-- ----------------------------------------------------------------------------
-- TEST 4 : Élément indépendant ne créant aucun cycle -> DOIT RETOURNER false (graphe épuisé)
-- ----------------------------------------------------------------------------
LET $t4_indep = fn::catalogue_composition_check_cycle({
    parent_item: catalogue_item:DEEP_INDEP,
    composant_item: catalogue_item:DEEP_0
});

-- ----------------------------------------------------------------------------
-- TEST 5 : Rejet fonctionnel via fn::catalogue_composition_add_line sur cycle profond
-- ----------------------------------------------------------------------------
CREATE catalogue_composition:C_8 CONTENT {
    parent_item: catalogue_item:DEEP_8,
    version: 1,
    statut: "DRAFT",
    is_locked: false,
    libelle: "Comp 8 Draft"
};

LET $t5_add_cycle = fn::catalogue_composition_add_line({
    composition_id: catalogue_composition:C_8,
    composant_item: catalogue_item:DEEP_0,
    quantite: 1.0,
    unite: base_unite:U
});

-- ----------------------------------------------------------------------------
-- TEST 6 : Succès fonctionnel via fn::catalogue_composition_add_line pour composant sans cycle
-- ----------------------------------------------------------------------------
LET $t6_add_valid = fn::catalogue_composition_add_line({
    composition_id: catalogue_composition:C_8,
    composant_item: catalogue_item:DEEP_INDEP,
    quantite: 2.5,
    unite: base_unite:U
});

RETURN {
    direct_cycle_detected: ($t1_direct == true),
    deep_8_levels_cycle_detected: ($t2_deep_8 == true),
    deep_5_levels_cycle_detected: ($t3_deep_5 == true),
    independent_no_cycle: ($t4_indep == false),
    add_line_cycle_rejected: ($t5_add_cycle.ok == false AND $t5_add_cycle.error.code == "CATALOGUE_COMPOSITION_CYCLE_DETECTED"),
    add_line_valid_accepted: ($t6_add_valid.ok == true)
};
