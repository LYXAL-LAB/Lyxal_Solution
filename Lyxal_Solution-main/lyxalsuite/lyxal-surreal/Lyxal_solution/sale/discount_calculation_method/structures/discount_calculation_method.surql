-- =====================================================
-- TABLE: discount_calculation_method
-- Description: Méthodes de calcul des remises avec gestion dynamique
-- Version: 1.0
-- =====================================================

-- Définition de la table
DEFINE TABLE discount_calculation_method SCHEMAFULL 
    COMMENT "Méthodes de calcul des remises avec règles configurables et extensibles";

-- =====================================================
-- CHAMPS PRINCIPAUX
-- =====================================================

-- Code unique de la méthode (obligatoire)
DEFINE FIELD code ON discount_calculation_method TYPE string 
    COMMENT "Code unique de la méthode de calcul (ex: FIXED_AMOUNT, PERCENT_SUBTOTAL, FORMULA_COMPLEX)";

-- Nom affiché de la méthode (obligatoire)
DEFINE FIELD name ON discount_calculation_method TYPE string 
    COMMENT "Nom affiché de la méthode de calcul (ex: 'Montant fixe', 'Pourcentage', 'Formule personnalisée')";

-- Description détaillée (optionnel)
DEFINE FIELD description ON discount_calculation_method TYPE string 
    COMMENT "Description détaillée de la méthode et de son utilisation";

-- =====================================================
-- TYPE ET COMPORTEMENT DE CALCUL
-- =====================================================

-- Type de calcul principal (obligatoire)
DEFINE FIELD calculation_type ON discount_calculation_method TYPE string 
    COMMENT "Type de calcul principal (FIXED, PERCENT, FORMULA, TIERED, CONDITIONAL)";

-- Sous-type de calcul (optionnel)
DEFINE FIELD calculation_subtype ON discount_calculation_method TYPE string 
    COMMENT "Sous-type de calcul pour spécialisation (SIMPLE, COMPLEX, PROGRESSIVE, etc.)";

-- Formule de calcul (optionnel)
DEFINE FIELD calculation_formula ON discount_calculation_method TYPE string 
    COMMENT "Formule de calcul par défaut ou template de formule";

-- =====================================================
-- SUPPORT DES TYPES DE VALEURS
-- =====================================================

-- Support des montants fixes (par défaut false)
DEFINE FIELD supports_fixed_amount ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode supporte les montants fixes";

-- Support des pourcentages (par défaut false)
DEFINE FIELD supports_percentage ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode supporte les pourcentages";

-- Support des formules (par défaut false)
DEFINE FIELD supports_formula ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode supporte les formules personnalisées";

-- Support des devises (par défaut false)
DEFINE FIELD supports_currency ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode nécessite une devise";

-- =====================================================
-- CONFIGURATION DES SYMBOLES
-- =====================================================

-- Symbole par défaut (optionnel)
DEFINE FIELD default_symbol ON discount_calculation_method TYPE string 
    COMMENT "Symbole par défaut pour l'affichage (€, %, $, f(x), etc.)";

-- Utilise le symbole de devise (par défaut false)
DEFINE FIELD uses_currency_symbol ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si le symbole doit être pris depuis la devise";

-- Format d'affichage (optionnel)
DEFINE FIELD display_format ON discount_calculation_method TYPE string 
    COMMENT "Format d'affichage de la valeur (ex: '{value} {symbol}', '{symbol}{value}')";

-- =====================================================
-- RÈGLES DE VALIDATION
-- =====================================================

-- Valeur minimale autorisée (optionnel)
DEFINE FIELD min_value ON discount_calculation_method TYPE decimal 
    COMMENT "Valeur minimale autorisée pour cette méthode";

-- Valeur maximale autorisée (optionnel)
DEFINE FIELD max_value ON discount_calculation_method TYPE decimal 
    COMMENT "Valeur maximale autorisée pour cette méthode";

-- Précision décimale (par défaut 2)
DEFINE FIELD decimal_precision ON discount_calculation_method TYPE int DEFAULT 2 
    COMMENT "Nombre de décimales autorisées pour les valeurs";

-- Validation personnalisée (optionnel)
DEFINE FIELD validation_rules ON discount_calculation_method TYPE string 
    COMMENT "Règles de validation personnalisées en JSON ou expression";

-- =====================================================
-- CONFIGURATION D'APPLICATION
-- =====================================================

-- S'applique sur le sous-total (par défaut true)
DEFINE FIELD applies_to_subtotal ON discount_calculation_method TYPE bool DEFAULT true 
    COMMENT "Indique si cette méthode s'applique sur le sous-total";

-- S'applique sur les taxes (par défaut false)
DEFINE FIELD applies_to_taxes ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode s'applique sur les taxes";

-- S'applique sur les frais (par défaut false)
DEFINE FIELD applies_to_fees ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode s'applique sur les frais";

-- Peut être cumulée (par défaut false)
DEFINE FIELD can_be_cumulated ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode peut être cumulée avec d'autres";

-- =====================================================
-- INTERFACE UTILISATEUR
-- =====================================================

-- Séquence d'affichage (obligatoire)
DEFINE FIELD sequence ON discount_calculation_method TYPE int 
    COMMENT "Ordre d'affichage dans les listes et interfaces";

-- Couleur d'affichage (optionnel, défaut bleu)
DEFINE FIELD color ON discount_calculation_method TYPE string DEFAULT "#007bff" 
    COMMENT "Couleur hexadécimale pour l'affichage dans l'interface";

-- Icône Lucide React (optionnel, défaut Calculator)
DEFINE FIELD icon ON discount_calculation_method TYPE string DEFAULT "Calculator" 
    COMMENT "Nom de l'icône Lucide React pour l'affichage";

-- Catégorie d'affichage (optionnel)
DEFINE FIELD display_category ON discount_calculation_method TYPE string 
    COMMENT "Catégorie pour regrouper les méthodes dans l'interface";

-- =====================================================
-- CONFIGURATION AVANCÉE
-- =====================================================

-- Nécessite une approbation (par défaut false)
DEFINE FIELD requires_approval ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode nécessite une approbation";

-- Niveau d'approbation requis (optionnel)
DEFINE FIELD approval_level ON discount_calculation_method TYPE string 
    COMMENT "Niveau d'approbation requis (MANAGER, DIRECTOR, ADMIN)";

-- Utilisation restreinte (par défaut false)
DEFINE FIELD restricted_usage ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si l'utilisation est restreinte à certains utilisateurs";

-- Rôles autorisés (optionnel)
DEFINE FIELD allowed_roles ON discount_calculation_method TYPE array<string> 
    COMMENT "Liste des rôles autorisés à utiliser cette méthode";

-- =====================================================
-- PARAMÈTRES TECHNIQUES
-- =====================================================

-- Classe de calcul (optionnel)
DEFINE FIELD calculation_class ON discount_calculation_method TYPE string 
    COMMENT "Classe ou service responsable du calcul";

-- Paramètres de configuration (optionnel)
DEFINE FIELD configuration_params ON discount_calculation_method TYPE object 
    COMMENT "Paramètres de configuration spécifiques à la méthode";

-- Cache autorisé (par défaut true)
DEFINE FIELD cache_enabled ON discount_calculation_method TYPE bool DEFAULT true 
    COMMENT "Indique si les résultats de calcul peuvent être mis en cache";

-- Durée de cache (par défaut 300 secondes)
DEFINE FIELD cache_duration ON discount_calculation_method TYPE int DEFAULT 300 
    COMMENT "Durée de cache en secondes pour les résultats";

-- =====================================================
-- GESTION DES ÉTATS
-- =====================================================

-- Statut actif/inactif (par défaut true)
DEFINE FIELD is_active ON discount_calculation_method TYPE bool DEFAULT true 
    COMMENT "Indique si cette méthode est active et utilisable";

-- Système (protégé contre suppression)
DEFINE FIELD is_system ON discount_calculation_method TYPE bool DEFAULT false 
    COMMENT "Indique si cette méthode est système et protégée";

-- Version (pour gestion des évolutions)
DEFINE FIELD version ON discount_calculation_method TYPE string DEFAULT "1.0" 
    COMMENT "Version de la méthode de calcul";

-- =====================================================
-- MÉTADONNÉES
-- =====================================================

-- Date de création (automatique)
DEFINE FIELD created_on ON discount_calculation_method TYPE datetime DEFAULT time::now() 
    COMMENT "Date et heure de création de l'enregistrement";

-- Date de dernière modification (automatique)
DEFINE FIELD updated_on ON discount_calculation_method TYPE datetime DEFAULT time::now() 
    COMMENT "Date et heure de dernière modification";

-- Créé par (optionnel)
DEFINE FIELD created_by ON discount_calculation_method TYPE string 
    COMMENT "Utilisateur ayant créé cette méthode";

-- Modifié par (optionnel)
DEFINE FIELD updated_by ON discount_calculation_method TYPE string 
    COMMENT "Utilisateur ayant modifié cette méthode en dernier";

-- =====================================================
-- CONTRAINTES ET VALIDATIONS
-- =====================================================

-- Le code ne peut pas être vide
DEFINE FIELD code ON discount_calculation_method ASSERT $value != "" AND $value != NONE 
    COMMENT "Le code est obligatoire et ne peut pas être vide";

-- Le nom ne peut pas être vide
DEFINE FIELD name ON discount_calculation_method ASSERT $value != "" AND $value != NONE 
    COMMENT "Le nom est obligatoire et ne peut pas être vide";

-- La séquence doit être positive
DEFINE FIELD sequence ON discount_calculation_method ASSERT $value > 0 
    COMMENT "La séquence doit être un nombre positif";

-- Le type de calcul doit être valide
DEFINE FIELD calculation_type ON discount_calculation_method ASSERT $value IN ["FIXED", "PERCENT", "FORMULA", "TIERED", "CONDITIONAL"] 
    COMMENT "Le type de calcul doit être valide";

-- La couleur doit être un code hexadécimal valide
DEFINE FIELD color ON discount_calculation_method ASSERT $value == NONE OR string::starts_with($value, "#") 
    COMMENT "La couleur doit être un code hexadécimal valide";

-- Les valeurs min/max doivent être cohérentes
DEFINE FIELD max_value ON discount_calculation_method ASSERT $value == NONE OR $value >= $parent.min_value 
    COMMENT "La valeur maximale doit être supérieure ou égale à la valeur minimale";

-- La précision décimale doit être raisonnable
DEFINE FIELD decimal_precision ON discount_calculation_method ASSERT $value >= 0 AND $value <= 10 
    COMMENT "La précision décimale doit être entre 0 et 10";

-- La durée de cache doit être positive
DEFINE FIELD cache_duration ON discount_calculation_method ASSERT $value > 0 
    COMMENT "La durée de cache doit être positive";

-- Au moins un type de support doit être activé
DEFINE FIELD supports_fixed_amount ON discount_calculation_method ASSERT 
    $parent.supports_fixed_amount = true OR 
    $parent.supports_percentage = true OR 
    $parent.supports_formula = true 
    COMMENT "Au moins un type de support doit être activé";

-- =====================================================
-- INDEX D'OPTIMISATION
-- =====================================================

-- Index unique sur le code
DEFINE INDEX idx_discount_calculation_method_code ON discount_calculation_method COLUMNS code UNIQUE 
    COMMENT "Index unique sur le code pour assurer l'unicité";

-- Index sur la séquence pour l'affichage ordonné
DEFINE INDEX idx_discount_calculation_method_sequence ON discount_calculation_method COLUMNS sequence 
    COMMENT "Index sur la séquence pour optimiser l'affichage ordonné";

-- Index sur le statut actif pour les requêtes fréquentes
DEFINE INDEX idx_discount_calculation_method_active ON discount_calculation_method COLUMNS is_active 
    COMMENT "Index sur le statut actif pour optimiser les requêtes";

-- Index composite pour les requêtes d'affichage
DEFINE INDEX idx_discount_calculation_method_display ON discount_calculation_method COLUMNS is_active, sequence 
    COMMENT "Index composite pour optimiser l'affichage des méthodes actives";

-- Index sur le type de calcul
DEFINE INDEX idx_discount_calculation_method_type ON discount_calculation_method COLUMNS calculation_type 
    COMMENT "Index sur le type de calcul pour optimiser les requêtes de filtrage";

-- Index sur la catégorie d'affichage
DEFINE INDEX idx_discount_calculation_method_category ON discount_calculation_method COLUMNS display_category 
    COMMENT "Index sur la catégorie d'affichage pour optimiser le regroupement";

-- Index composite pour les supports
DEFINE INDEX idx_discount_calculation_method_supports ON discount_calculation_method COLUMNS supports_fixed_amount, supports_percentage, supports_formula 
    COMMENT "Index composite pour optimiser les requêtes de support";

-- =====================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- =====================================================

-- Mise à jour automatique du timestamp
DEFINE EVENT update_timestamp ON discount_calculation_method 
    WHEN $event = "UPDATE" 
    THEN (UPDATE $this SET updated_on = time::now());

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION:
Cette table définit les méthodes de calcul des remises de manière dynamique :
- FIXED: Calcul en montant fixe
- PERCENT: Calcul en pourcentage
- FORMULA: Calcul par formule personnalisée
- TIERED: Calcul par paliers
- CONDITIONAL: Calcul conditionnel

TYPES DE SUPPORT:
- supports_fixed_amount: Montants fixes en devise
- supports_percentage: Pourcentages
- supports_formula: Formules personnalisées
- supports_currency: Nécessite une devise

CONFIGURATION:
- Règles de validation personnalisées
- Paramètres de configuration flexibles
- Gestion des approbations
- Contrôle d'accès par rôles

RELATIONS:
- Utilisé par discount_type.calculation_method_id
- Référencé dans les calculs de remise
- Intégré aux workflows d'approbation

EXEMPLES:
- FIXED_AMOUNT: Remise fixe en euros (supports_fixed_amount=true, supports_currency=true)
- PERCENT_SUBTOTAL: Remise en pourcentage du sous-total (supports_percentage=true)
- FORMULA_COMPLEX: Formule personnalisée (supports_formula=true)
- TIERED_VOLUME: Remise par paliers de volume (calculation_type=TIERED)
*/ 