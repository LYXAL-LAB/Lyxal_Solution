-- =====================================================
-- TABLE: sale_order_line_type
-- Description: Types de lignes de commande de vente avec gestion intelligente
-- Version: 1.0
-- =====================================================

-- Définition de la table
DEFINE TABLE sale_order_line_type SCHEMAFULL 
    COMMENT "Types de lignes de commande de vente avec gestion intelligente des workflows et impacts métier";

-- =====================================================
-- CHAMPS PRINCIPAUX
-- =====================================================

-- Code unique du type (obligatoire)
DEFINE FIELD code ON sale_order_line_type TYPE string 
    COMMENT "Code unique du type de ligne (ex: NORMAL, TITLE, PACK, OPTION)";

-- Nom affiché du type (obligatoire)
DEFINE FIELD name ON sale_order_line_type TYPE string 
    COMMENT "Nom affiché du type de ligne (ex: 'Normale', 'Titre', 'Pack', 'Option')";

-- Description détaillée (optionnel)
DEFINE FIELD description ON sale_order_line_type TYPE string 
    COMMENT "Description détaillée du type de ligne et de son utilisation";

-- =====================================================
-- COMPORTEMENT MÉTIER
-- =====================================================

-- Impact sur le stock (par défaut true)
DEFINE FIELD affects_stock ON sale_order_line_type TYPE bool DEFAULT true 
    COMMENT "Indique si ce type de ligne affecte la gestion des stocks";

-- Impact sur la tarification (par défaut true)
DEFINE FIELD affects_pricing ON sale_order_line_type TYPE bool DEFAULT true 
    COMMENT "Indique si ce type de ligne affecte le calcul des prix";

-- Imprimable sur les documents (par défaut true)
DEFINE FIELD is_printable ON sale_order_line_type TYPE bool DEFAULT true 
    COMMENT "Indique si ce type de ligne apparaît sur les documents imprimés";

-- Peut être modifié (par défaut true)
DEFINE FIELD allows_modification ON sale_order_line_type TYPE bool DEFAULT true 
    COMMENT "Indique si les lignes de ce type peuvent être modifiées";

-- Peut être supprimé (par défaut true)
DEFINE FIELD allows_deletion ON sale_order_line_type TYPE bool DEFAULT true 
    COMMENT "Indique si les lignes de ce type peuvent être supprimées";

-- =====================================================
-- INTERFACE UTILISATEUR
-- =====================================================

-- Séquence d'affichage (obligatoire)
DEFINE FIELD sequence ON sale_order_line_type TYPE int 
    COMMENT "Ordre d'affichage et de priorité dans les listes";

-- Couleur d'affichage (optionnel, défaut gris)
DEFINE FIELD color ON sale_order_line_type TYPE string DEFAULT "#6c757d" 
    COMMENT "Couleur hexadécimale pour l'affichage dans l'interface";

-- Icône Lucide React (optionnel, défaut Box)
DEFINE FIELD icon ON sale_order_line_type TYPE string DEFAULT "Box" 
    COMMENT "Nom de l'icône Lucide React pour l'affichage";

-- =====================================================
-- RÈGLES DE VALIDATION
-- =====================================================

-- Nécessite une validation (par défaut false)
DEFINE FIELD requires_validation ON sale_order_line_type TYPE bool DEFAULT false 
    COMMENT "Indique si les lignes de ce type nécessitent une validation";

-- Quantité minimale (optionnel)
DEFINE FIELD min_quantity ON sale_order_line_type TYPE decimal DEFAULT 0 
    COMMENT "Quantité minimale autorisée pour ce type de ligne";

-- Quantité maximale (optionnel)
DEFINE FIELD max_quantity ON sale_order_line_type TYPE decimal 
    COMMENT "Quantité maximale autorisée pour ce type de ligne";

-- =====================================================
-- GESTION DES ÉTATS
-- =====================================================

-- Statut actif/inactif (par défaut true)
DEFINE FIELD is_active ON sale_order_line_type TYPE bool DEFAULT true 
    COMMENT "Indique si ce type de ligne est actif et utilisable";

-- Système (protégé contre suppression)
DEFINE FIELD is_system ON sale_order_line_type TYPE bool DEFAULT false 
    COMMENT "Indique si ce type est système et protégé contre la suppression";

-- =====================================================
-- MÉTADONNÉES
-- =====================================================

-- Date de création (automatique)
DEFINE FIELD created_on ON sale_order_line_type TYPE datetime DEFAULT time::now() 
    COMMENT "Date et heure de création de l'enregistrement";

-- Date de dernière modification (automatique)
DEFINE FIELD updated_on ON sale_order_line_type TYPE datetime DEFAULT time::now() 
    COMMENT "Date et heure de dernière modification";

-- =====================================================
-- CONTRAINTES ET VALIDATIONS
-- =====================================================

-- Le code ne peut pas être vide
DEFINE FIELD code ON sale_order_line_type ASSERT $value != "" AND $value != NONE 
    COMMENT "Le code est obligatoire et ne peut pas être vide";

-- Le nom ne peut pas être vide
DEFINE FIELD name ON sale_order_line_type ASSERT $value != "" AND $value != NONE 
    COMMENT "Le nom est obligatoire et ne peut pas être vide";

-- La séquence doit être positive
DEFINE FIELD sequence ON sale_order_line_type ASSERT $value > 0 
    COMMENT "La séquence doit être un nombre positif";

-- La couleur doit être un code hexadécimal valide
DEFINE FIELD color ON sale_order_line_type ASSERT $value == NONE OR string::starts_with($value, "#") 
    COMMENT "La couleur doit être un code hexadécimal valide";

-- Les quantités min/max doivent être cohérentes
DEFINE FIELD max_quantity ON sale_order_line_type ASSERT $value == NONE OR $value >= $parent.min_quantity 
    COMMENT "La quantité maximale doit être supérieure ou égale à la quantité minimale";

-- =====================================================
-- INDEX D'OPTIMISATION
-- =====================================================

-- Index unique sur le code
DEFINE INDEX idx_sale_order_line_type_code ON sale_order_line_type COLUMNS code UNIQUE 
    COMMENT "Index unique sur le code pour assurer l'unicité";

-- Index sur la séquence pour l'affichage ordonné
DEFINE INDEX idx_sale_order_line_type_sequence ON sale_order_line_type COLUMNS sequence 
    COMMENT "Index sur la séquence pour optimiser l'affichage ordonné";

-- Index sur le statut actif pour les requêtes fréquentes
DEFINE INDEX idx_sale_order_line_type_active ON sale_order_line_type COLUMNS is_active 
    COMMENT "Index sur le statut actif pour optimiser les requêtes";

-- Index composite pour les requêtes d'affichage
DEFINE INDEX idx_sale_order_line_type_display ON sale_order_line_type COLUMNS is_active, sequence 
    COMMENT "Index composite pour optimiser l'affichage des types actifs";


-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION:
Cette table définit les différents types de lignes de commande de vente :
- NORMAL: Ligne de produit standard
- TITLE: Ligne de titre/section (sans impact stock/prix)
- PACK: Ligne de pack/bundle
- OPTION: Ligne d'option/accessoire

RÈGLES MÉTIER:
- Les types système (is_system=true) ne peuvent pas être supprimés
- Les types inactifs ne peuvent pas être utilisés pour de nouvelles lignes
- La séquence détermine l'ordre d'affichage et de priorité
- L'impact sur stock/prix détermine le comportement dans les calculs

RELATIONS:
- Utilisé par sale_order_line.type_id
- Peut être étendu pour pack_line.type_id

EXEMPLES:
- NORMAL: Ligne produit classique (stock=oui, prix=oui, imprimable=oui)
- TITLE: Ligne de titre (stock=non, prix=non, imprimable=oui)
- PACK: Ligne de pack (stock=oui, prix=oui, validation=oui)
- OPTION: Ligne d'option (stock=selon, prix=oui, supprimable=oui)
*/ 