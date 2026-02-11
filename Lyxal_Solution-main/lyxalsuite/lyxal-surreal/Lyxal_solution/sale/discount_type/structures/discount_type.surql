-- =====================================================
-- TABLE: discount_type
-- Description: Types de remises avec méthodes de calcul dynamiques
-- Version: 2.0 - Refactorisation avec calculation_method_id
-- =====================================================

-- Définition de la table
DEFINE TABLE discount_type SCHEMAFULL 
    COMMENT "Types de remises avec méthodes de calcul configurables et gestion des devises";

-- =====================================================
-- CHAMPS PRINCIPAUX
-- =====================================================

-- Code unique du type de remise (obligatoire)
DEFINE FIELD code ON discount_type TYPE string 
    COMMENT "Code unique du type de remise (ex: EARLY_BIRD, VOLUME_DISCOUNT, LOYALTY_BONUS)";

-- Nom affiché du type de remise (obligatoire)
DEFINE FIELD name ON discount_type TYPE string 
    COMMENT "Nom affiché du type de remise (ex: 'Remise anticipée', 'Remise volume', 'Bonus fidélité')";

-- Description détaillée (optionnel)
DEFINE FIELD description ON discount_type TYPE string 
    COMMENT "Description détaillée du type de remise et de ses conditions d'application";

-- =====================================================
-- MÉTHODE DE CALCUL ET DEVISE
-- =====================================================

-- Méthode de calcul (obligatoire - référence vers discount_calculation_method)
DEFINE FIELD calculation_method_id ON discount_type TYPE record<discount_calculation_method> 
    COMMENT "Référence vers la méthode de calcul de la remise";

-- Devise pour les montants fixes (optionnel - référence vers currency)
DEFINE FIELD currency_id ON discount_type TYPE record<currency> 
    COMMENT "Devise utilisée pour les montants fixes (requis si méthode supporte les devises)";

-- Paramètres de calcul spécifiques (optionnel)
DEFINE FIELD calculation_params ON discount_type TYPE object 
    COMMENT "Paramètres spécifiques à la méthode de calcul (formules, paliers, conditions)";

-- =====================================================
-- VALEURS DE REMISE
-- =====================================================

-- Valeur par défaut de la remise (optionnel)
DEFINE FIELD default_value ON discount_type TYPE decimal 
    COMMENT "Valeur par défaut de la remise (montant ou pourcentage selon la méthode)";

-- Valeur minimale autorisée (optionnel)
DEFINE FIELD min_value ON discount_type TYPE decimal 
    COMMENT "Valeur minimale autorisée pour cette remise";

-- Valeur maximale autorisée (optionnel)
DEFINE FIELD max_value ON discount_type TYPE decimal 
    COMMENT "Valeur maximale autorisée pour cette remise";

-- =====================================================
-- CONDITIONS D'APPLICATION
-- =====================================================

-- Montant minimum de commande (optionnel)
DEFINE FIELD min_order_amount ON discount_type TYPE decimal 
    COMMENT "Montant minimum de commande pour appliquer cette remise";

-- Quantité minimale (optionnel)
DEFINE FIELD min_quantity ON discount_type TYPE decimal 
    COMMENT "Quantité minimale pour appliquer cette remise";

-- Date de début de validité (optionnel)
DEFINE FIELD valid_from ON discount_type TYPE date 
    COMMENT "Date de début de validité de la remise";

-- Date de fin de validité (optionnel)
DEFINE FIELD valid_to ON discount_type TYPE date 
    COMMENT "Date de fin de validité de la remise";

-- =====================================================
-- CONFIGURATION D'APPLICATION
-- =====================================================

-- S'applique aux lignes de commande (par défaut true)
DEFINE FIELD applies_to_lines ON discount_type TYPE bool DEFAULT true 
    COMMENT "Indique si cette remise s'applique aux lignes de commande";

-- S'applique au total de commande (par défaut false)
DEFINE FIELD applies_to_total ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si cette remise s'applique au total de la commande";

-- S'applique aux frais de port (par défaut false)
DEFINE FIELD applies_to_shipping ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si cette remise s'applique aux frais de port";

-- Peut être cumulée avec d'autres remises (par défaut false)
DEFINE FIELD can_be_combined ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si cette remise peut être cumulée avec d'autres";

-- =====================================================
-- RESTRICTIONS ET AUTORISATIONS
-- =====================================================

-- Nécessite une approbation (par défaut false)
DEFINE FIELD requires_approval ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si cette remise nécessite une approbation";

-- Niveau d'approbation requis (optionnel)
DEFINE FIELD approval_level ON discount_type TYPE string 
    COMMENT "Niveau d'approbation requis (MANAGER, DIRECTOR, ADMIN)";

-- Utilisation limitée (par défaut false)
DEFINE FIELD limited_usage ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si l'utilisation est limitée";

-- Nombre maximum d'utilisations (optionnel)
DEFINE FIELD max_usage_count ON discount_type TYPE int 
    COMMENT "Nombre maximum d'utilisations autorisées";

-- Rôles autorisés (optionnel)
DEFINE FIELD allowed_roles ON discount_type TYPE array<string> 
    COMMENT "Liste des rôles autorisés à appliquer cette remise";

-- =====================================================
-- INTERFACE UTILISATEUR
-- =====================================================

-- Séquence d'affichage (obligatoire)
DEFINE FIELD sequence ON discount_type TYPE int 
    COMMENT "Ordre d'affichage dans les listes et interfaces";

-- Couleur d'affichage (optionnel, défaut rouge)
DEFINE FIELD color ON discount_type TYPE string DEFAULT "#dc3545" 
    COMMENT "Couleur hexadécimale pour l'affichage dans l'interface";

-- Icône Lucide React (optionnel, défaut Tag)
DEFINE FIELD icon ON discount_type TYPE string DEFAULT "Tag" 
    COMMENT "Nom de l'icône Lucide React pour l'affichage";

-- Catégorie d'affichage (optionnel)
DEFINE FIELD display_category ON discount_type TYPE string 
    COMMENT "Catégorie pour regrouper les remises dans l'interface";

-- =====================================================
-- GESTION DES ÉTATS
-- =====================================================

-- Statut actif/inactif (par défaut true)
DEFINE FIELD is_active ON discount_type TYPE bool DEFAULT true 
    COMMENT "Indique si ce type de remise est actif et utilisable";

-- Système (protégé contre suppression)
DEFINE FIELD is_system ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si ce type de remise est système et protégé";

-- Automatique (appliqué automatiquement)
DEFINE FIELD is_automatic ON discount_type TYPE bool DEFAULT false 
    COMMENT "Indique si cette remise est appliquée automatiquement";

-- =====================================================
-- MÉTADONNÉES
-- =====================================================

-- Date de création (automatique)
DEFINE FIELD created_on ON discount_type TYPE datetime DEFAULT time::now() 
    COMMENT "Date et heure de création de l'enregistrement";

-- Date de dernière modification (automatique)
DEFINE FIELD updated_on ON discount_type TYPE datetime DEFAULT time::now() 
    COMMENT "Date et heure de dernière modification";

-- Créé par (optionnel)
DEFINE FIELD created_by ON discount_type TYPE string 
    COMMENT "Utilisateur ayant créé ce type de remise";

-- Modifié par (optionnel)
DEFINE FIELD updated_by ON discount_type TYPE string 
    COMMENT "Utilisateur ayant modifié ce type de remise en dernier";

-- =====================================================
-- CONTRAINTES ET VALIDATIONS
-- =====================================================

-- Le code ne peut pas être vide
DEFINE FIELD code ON discount_type ASSERT $value != "" AND $value != NONE 
    COMMENT "Le code est obligatoire et ne peut pas être vide";

-- Le nom ne peut pas être vide
DEFINE FIELD name ON discount_type ASSERT $value != "" AND $value != NONE 
    COMMENT "Le nom est obligatoire et ne peut pas être vide";

-- La séquence doit être positive
DEFINE FIELD sequence ON discount_type ASSERT $value > 0 
    COMMENT "La séquence doit être un nombre positif";

-- La méthode de calcul doit être valide et active
DEFINE FIELD calculation_method_id ON discount_type ASSERT $value != NONE AND 
    (SELECT VALUE is_active FROM $value LIMIT 1)[0] = true 
    COMMENT "La méthode de calcul doit être définie et active";

-- La devise est requise si la méthode supporte les devises
DEFINE FIELD currency_id ON discount_type ASSERT 
    $value != NONE OR 
    (SELECT VALUE supports_currency FROM $parent.calculation_method_id LIMIT 1)[0] = false 
    COMMENT "La devise est requise si la méthode de calcul supporte les devises";

-- La couleur doit être un code hexadécimal valide
DEFINE FIELD color ON discount_type ASSERT $value == NONE OR string::starts_with($value, "#") 
    COMMENT "La couleur doit être un code hexadécimal valide";

-- Les valeurs min/max doivent être cohérentes
DEFINE FIELD max_value ON discount_type ASSERT $value == NONE OR $value >= $parent.min_value 
    COMMENT "La valeur maximale doit être supérieure ou égale à la valeur minimale";

-- Les dates de validité doivent être cohérentes
DEFINE FIELD valid_to ON discount_type ASSERT $value == NONE OR $value >= $parent.valid_from 
    COMMENT "La date de fin doit être postérieure à la date de début";

-- Le nombre maximum d'utilisations doit être positif
DEFINE FIELD max_usage_count ON discount_type ASSERT $value == NONE OR $value > 0 
    COMMENT "Le nombre maximum d'utilisations doit être positif";

-- Au moins un type d'application doit être sélectionné
DEFINE FIELD applies_to_lines ON discount_type ASSERT 
    $parent.applies_to_lines = true OR 
    $parent.applies_to_total = true OR 
    $parent.applies_to_shipping = true 
    COMMENT "Au moins un type d'application doit être sélectionné";

-- =====================================================
-- INDEX D'OPTIMISATION
-- =====================================================

-- Index unique sur le code
DEFINE INDEX idx_discount_type_code ON discount_type COLUMNS code UNIQUE 
    COMMENT "Index unique sur le code pour assurer l'unicité";

-- Index sur la séquence pour l'affichage ordonné
DEFINE INDEX idx_discount_type_sequence ON discount_type COLUMNS sequence 
    COMMENT "Index sur la séquence pour optimiser l'affichage ordonné";

-- Index sur le statut actif pour les requêtes fréquentes
DEFINE INDEX idx_discount_type_active ON discount_type COLUMNS is_active 
    COMMENT "Index sur le statut actif pour optimiser les requêtes";

-- Index composite pour les requêtes d'affichage
DEFINE INDEX idx_discount_type_display ON discount_type COLUMNS is_active, sequence 
    COMMENT "Index composite pour optimiser l'affichage des types actifs";

-- Index sur la méthode de calcul pour les jointures
DEFINE INDEX idx_discount_type_calculation_method ON discount_type COLUMNS calculation_method_id 
    COMMENT "Index sur la méthode de calcul pour optimiser les jointures";

-- Index sur la devise pour les jointures
DEFINE INDEX idx_discount_type_currency ON discount_type COLUMNS currency_id 
    COMMENT "Index sur la devise pour optimiser les jointures";

-- Index sur les dates de validité
DEFINE INDEX idx_discount_type_validity ON discount_type COLUMNS valid_from, valid_to 
    COMMENT "Index sur les dates de validité pour optimiser les requêtes temporelles";

-- Index sur la catégorie d'affichage
DEFINE INDEX idx_discount_type_category ON discount_type COLUMNS display_category 
    COMMENT "Index sur la catégorie d'affichage pour optimiser le regroupement";

-- Index composite pour les applications
DEFINE INDEX idx_discount_type_applications ON discount_type COLUMNS applies_to_lines, applies_to_total, applies_to_shipping 
    COMMENT "Index composite pour optimiser les requêtes d'application";

-- =====================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- =====================================================

-- Mise à jour automatique du timestamp
DEFINE EVENT update_timestamp ON discount_type 
    WHEN $event = "UPDATE" 
    THEN (UPDATE $this SET updated_on = time::now());

-- Validation de la cohérence avec la méthode de calcul
DEFINE EVENT validate_calculation_method ON discount_type 
    WHEN $event = "CREATE" OR $event = "UPDATE" 
    THEN (
        -- Vérifier que la méthode de calcul est compatible
        LET $method = SELECT * FROM $this.calculation_method_id LIMIT 1;
        IF $method[0].requires_approval = true AND $this.requires_approval = false THEN
            THROW "Cette méthode de calcul nécessite une approbation";
        END;
        
        -- Vérifier la devise si nécessaire
        IF $method[0].supports_currency = true AND $this.currency_id = NONE THEN
            THROW "Cette méthode de calcul nécessite une devise";
        END;
        
        -- Vérifier les valeurs selon la méthode
        IF $method[0].supports_percentage = true AND $this.default_value > 100 THEN
            THROW "Le pourcentage ne peut pas dépasser 100%";
        END;
    );

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
REFACTORISATION VERSION 2.0:

CHANGEMENTS MAJEURS:
1. Remplacement de calculation_method (string) par calculation_method_id (record)
2. Ajout de currency_id pour la gestion des devises
3. Ajout de calculation_params pour les paramètres spécifiques
4. Amélioration des validations avec les nouvelles relations
5. Ajout d'événements pour la validation de cohérence

NOUVELLES FONCTIONNALITÉS:
- Méthodes de calcul configurables et extensibles
- Gestion des devises pour les montants fixes
- Paramètres de calcul personnalisables
- Validation automatique de la cohérence
- Intégration avec les systèmes d'approbation

MIGRATION DEPUIS VERSION 1.0:
1. Migrer calculation_method vers calculation_method_id
2. Configurer currency_id pour les types utilisant des montants fixes
3. Transférer les formules vers calculation_params
4. Mettre à jour les fonctions CRUD
5. Adapter les données de référence

RELATIONS:
- discount_type.calculation_method_id -> discount_calculation_method.id
- discount_type.currency_id -> currency.id
- Utilisé par sale_order.discount_type_id
- Utilisé par sale_order_line.discount_type_id

EXEMPLES D'UTILISATION:
- Remise fixe en euros: calculation_method_id = FIXED_AMOUNT, currency_id = EUR
- Remise pourcentage: calculation_method_id = PERCENTAGE, currency_id = null
- Remise par paliers: calculation_method_id = TIERED, calculation_params = {tiers: [...]}
- Remise conditionnelle: calculation_method_id = CONDITIONAL, calculation_params = {rules: [...]}

AVANTAGES:
1. Flexibilité maximale pour les méthodes de calcul
2. Extensibilité sans modification de structure
3. Réutilisabilité des méthodes de calcul
4. Gestion centralisée des devises
5. Validation automatique de la cohérence
6. Intégration native avec les systèmes d'approbation
*/ 