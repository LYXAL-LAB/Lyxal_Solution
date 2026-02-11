# 📦 DOCUMENTATION COMPLÈTE - SALE ORDER LINE TYPE

## 🎯 **Vue d'ensemble**

La table `sale_order_line_type` est une **table de référence intelligente** qui gère les types de lignes de commande de vente dans Lyxal Suite. Elle remplace les valeurs magiques `int` par des relations typées pour une architecture moderne et "IA-ready".

---

## 📋 **Structure de la table**

### **🔧 Définition technique**
```sql
DEFINE TABLE sale_order_line_type SCHEMAFULL;
    COMMENT "Types de lignes de commande de vente avec gestion intelligente des workflows et impacts métier";
```

### **📊 Champs de la table**

| Champ | Type | Obligatoire | Défaut | Description |
|-------|------|-------------|---------|-------------|
| `code` | `string` | ✅ | - | Code unique du type (ex: NORMAL, TITLE, PACK, OPTION) |
| `name` | `string` | ✅ | - | Nom affiché du type (ex: "Normale", "Titre", "Pack") |
| `description` | `string` | ❌ | - | Description détaillée du type et de son utilisation |
| `sequence` | `int` | ✅ | - | Ordre d'affichage et de priorité |
| `affects_stock` | `bool` | ❌ | `true` | Indique si ce type affecte la gestion des stocks |
| `affects_pricing` | `bool` | ❌ | `true` | Indique si ce type affecte le calcul des prix |
| `is_printable` | `bool` | ❌ | `true` | Indique si ce type apparaît sur les documents imprimés |
| `allows_modification` | `bool` | ❌ | `true` | Indique si les lignes de ce type peuvent être modifiées |
| `allows_deletion` | `bool` | ❌ | `true` | Indique si les lignes de ce type peuvent être supprimées |
| `color` | `string` | ❌ | `#6c757d` | Couleur hexadécimale pour l'affichage |
| `icon` | `string` | ❌ | `Box` | Icône Lucide React |
| `requires_validation` | `bool` | ❌ | `false` | Indique si les lignes nécessitent une validation |
| `min_quantity` | `decimal` | ❌ | `0` | Quantité minimale autorisée |
| `max_quantity` | `decimal` | ❌ | - | Quantité maximale autorisée |
| `is_active` | `bool` | ❌ | `true` | Statut actif/inactif (soft delete) |
| `is_system` | `bool` | ❌ | `false` | Indique si le type est système et protégé |
| `created_on` | `datetime` | ❌ | `time::now()` | Date de création |
| `updated_on` | `datetime` | ❌ | `time::now()` | Date de dernière modification |

### **🔍 Index d'optimisation**
```sql
DEFINE INDEX idx_sale_order_line_type_code ON sale_order_line_type COLUMNS code UNIQUE;
DEFINE INDEX idx_sale_order_line_type_sequence ON sale_order_line_type COLUMNS sequence;
DEFINE INDEX idx_sale_order_line_type_active ON sale_order_line_type COLUMNS is_active;
DEFINE INDEX idx_sale_order_line_type_display ON sale_order_line_type COLUMNS is_active, sequence;
```

---

## 🚀 **Fonctions disponibles**

### **📁 Organisation des fonctions**
```
sale_order_line_type/functions/
├── create_sale_order_line_type.surql      # Création
├── read_sale_order_line_type.surql        # Lecture
├── update_sale_order_line_type.surql      # Modification
├── deactivate_sale_order_line_type.surql  # Désactivation (soft delete)
├── activate_sale_order_line_type.surql    # Réactivation
├── list_sale_order_line_type.surql        # Listage et recherche
├── delete_sale_order_line_type.surql      # Suppression définitive
└── utility_sale_order_line_type.surql     # Fonctions utilitaires
```

### **🔧 Fonctions CRUD**

#### **1. Création**
```sql
fn::create_sale_order_line_type(
    $code: string,                    -- Code unique (obligatoire)
    $name: string,                    -- Nom affiché (obligatoire)
    $sequence: int,                   -- Ordre (obligatoire)
    $description: string,             -- Description (optionnel)
    $affects_stock: bool,             -- Impact stock (optionnel)
    $affects_pricing: bool,           -- Impact prix (optionnel)
    $is_printable: bool,              -- Imprimable (optionnel)
    $allows_modification: bool,       -- Permet modification (optionnel)
    $allows_deletion: bool,           -- Permet suppression (optionnel)
    $color: string,                   -- Couleur hex (optionnel)
    $icon: string,                    -- Icône Lucide (optionnel)
    $requires_validation: bool,       -- Nécessite validation (optionnel)
    $min_quantity: decimal,           -- Quantité min (optionnel)
    $max_quantity: decimal            -- Quantité max (optionnel)
)
```

**Exemple** :
```sql
SELECT fn::create_sale_order_line_type(
    "CUSTOM_SERVICE", 
    "Service personnalisé", 
    10, 
    "Service avec validation requise", 
    false, true, true, true, true, 
    "#6f42c1", "Settings", true, 1, 10
);
```

#### **2. Lecture**
```sql
-- Lecture par ID
fn::read_sale_order_line_type($id: record<sale_order_line_type>)

-- Lecture par code
fn::read_sale_order_line_type_by_code($code: string)

-- Lecture avec statistiques d'utilisation
fn::read_sale_order_line_type_with_usage($id: record<sale_order_line_type>)

-- Lecture multiple par IDs
fn::read_multiple_sale_order_line_types($ids: array<record<sale_order_line_type>>)

-- Lecture multiple par codes
fn::read_sale_order_line_types_by_codes($codes: array<string>)

-- Vérification d'existence
fn::check_sale_order_line_type_exists($code: string)

-- Détails complets avec métadonnées
fn::get_sale_order_line_type_details($id: record<sale_order_line_type>)
```

#### **3. Modification**
```sql
fn::update_sale_order_line_type(
    $id: record<sale_order_line_type>,
    $code: string,                    -- Nouveau code (optionnel)
    $name: string,                    -- Nouveau nom (optionnel)
    $sequence: int,                   -- Nouvelle séquence (optionnel)
    $description: string,             -- Nouvelle description (optionnel)
    $affects_stock: bool,             -- Nouveau impact stock (optionnel)
    $affects_pricing: bool,           -- Nouveau impact prix (optionnel)
    $is_printable: bool,              -- Nouveau statut impression (optionnel)
    $allows_modification: bool,       -- Nouvelle permission modification (optionnel)
    $allows_deletion: bool,           -- Nouvelle permission suppression (optionnel)
    $color: string,                   -- Nouvelle couleur (optionnel)
    $icon: string,                    -- Nouvelle icône (optionnel)
    $requires_validation: bool,       -- Nouvelle validation (optionnel)
    $min_quantity: decimal,           -- Nouvelle quantité min (optionnel)
    $max_quantity: decimal            -- Nouvelle quantité max (optionnel)
)

-- Fonctions spécialisées
fn::update_sale_order_line_type_partial($id, $updates: object)
fn::update_sale_order_line_type_sequence($id, $new_sequence: int)
fn::update_sale_order_line_type_display($id, $color: string, $icon: string)
fn::update_sale_order_line_type_behavior($id, $affects_stock, $affects_pricing, $is_printable, $requires_validation)
fn::update_sale_order_line_type_permissions($id, $allows_modification, $allows_deletion)
fn::update_sale_order_line_type_quantities($id, $min_quantity, $max_quantity)
```

#### **4. Désactivation (Soft Delete)**
```sql
-- Désactivation par ID
fn::deactivate_sale_order_line_type($id: record<sale_order_line_type>)

-- Désactivation par code
fn::deactivate_sale_order_line_type_by_code($code: string)

-- Désactivation forcée avec migration
fn::deactivate_sale_order_line_type_force($id, $replacement_id: record<sale_order_line_type>)

-- Désactivation en lot
fn::batch_deactivate_sale_order_line_types($ids: array<record<sale_order_line_type>>)

-- Vérification de possibilité
fn::check_sale_order_line_type_can_be_deactivated($id: record<sale_order_line_type>)
```

#### **5. Réactivation**
```sql
-- Réactivation par ID
fn::activate_sale_order_line_type($id: record<sale_order_line_type>)

-- Réactivation par code
fn::activate_sale_order_line_type_by_code($code: string)

-- Réactivation avec nouvelle séquence
fn::activate_sale_order_line_type_with_new_sequence($id, $new_sequence: int)

-- Réactivation en lot
fn::batch_activate_sale_order_line_types($ids: array<record<sale_order_line_type>>)

-- Vérification de possibilité
fn::check_sale_order_line_type_can_be_activated($id: record<sale_order_line_type>)

-- Prochaine séquence disponible
fn::get_next_available_sequence()
```

### **📋 Fonctions de listage**

#### **1. Listes simples**
```sql
-- Types actifs seulement
fn::list_sale_order_line_type()

-- Tous les types (actifs + inactifs)
fn::list_all_sale_order_line_type()

-- Avec statistiques d'utilisation
fn::list_sale_order_line_type_with_stats()

-- Optimisée pour sélection UI
fn::list_sale_order_line_type_for_selection()
```

#### **2. Pagination et recherche**
```sql
-- Pagination
fn::list_sale_order_line_type_paginated($page: int, $limit: int, $include_inactive: bool)

-- Recherche textuelle
fn::search_sale_order_line_type($search: string, $include_inactive: bool)
```

#### **3. Filtrage avancé**
```sql
-- Par comportement métier
fn::list_sale_order_line_type_by_behavior($affects_stock, $affects_pricing, $is_printable)

-- Par catégories
fn::list_sale_order_line_type_by_category()

-- Résumé statistique
fn::get_sale_order_line_type_summary()
```

### **🗑️ Suppression définitive**
```sql
-- Suppression avec protection
fn::delete_sale_order_line_type($id: record<sale_order_line_type>, $force: bool)

-- Suppression par code
fn::delete_sale_order_line_type_by_code($code: string, $force: bool)

-- Nettoyage des types inutilisés
fn::cleanup_unused_sale_order_line_type()

-- Suppression en lot
fn::batch_delete_sale_order_line_types($ids: array<record<sale_order_line_type>>, $force: bool)

-- Vérification de possibilité
fn::check_sale_order_line_type_can_be_deleted($id: record<sale_order_line_type>)

-- Analyse des dépendances
fn::get_sale_order_line_type_dependencies($id: record<sale_order_line_type>)
```

### **🔧 Fonctions utilitaires**

#### **1. Gestion des données de référence**
```sql
-- Réinitialiser les données de référence (8 types de base)
fn::reset_sale_order_line_type_data()

-- Créer un type de test
fn::create_test_sale_order_line_type()
```

#### **2. Validation et contrôle**
```sql
-- Valider l'intégrité des données
fn::validate_sale_order_line_type_data()
```

**Retourne** :
```json
{
    "success": true/false,
    "errors": ["Erreur 1", "Erreur 2"],
    "message": "Validation réussie / Erreurs détectées"
}
```

**Vérifications effectuées** :
- ✅ Présence des types obligatoires (NORMAL, TITLE, PACK)
- ✅ Absence de doublons de code
- ✅ Absence de doublons de séquence
- ✅ Codes et noms non vides
- ✅ Séquences positives
- ✅ Format de couleur hexadécimal
- ✅ Cohérence des quantités min/max

#### **3. Statistiques et analytics**
```sql
-- Obtenir les statistiques globales
fn::get_sale_order_line_type_statistics()
```

**Retourne** :
```json
{
    "basic_stats": {
        "total_types": 8,
        "active_types": 7,
        "inactive_types": 1,
        "system_types": 3
    },
    "usage_stats": {
        "total_lines": 5000,
        "lines_with_type": 4800,
        "lines_without_type": 200,
        "most_used_type": {"code": "NORMAL", "name": "Normale", "usage_count": 3500},
        "least_used_type": {"code": "COMMENT", "name": "Commentaire", "usage_count": 10}
    },
    "behavior_stats": {
        "affects_stock": 5,
        "affects_pricing": 6,
        "is_printable": 8,
        "requires_validation": 1
    }
}
```

#### **4. Interface utilisateur**
```sql
-- Obtenir la liste des icônes Lucide disponibles
fn::get_available_lucide_icons()
```

**Retourne** : Array de 80+ icônes Lucide React utilisables

---

## 📊 **Données de référence**

### **🎨 Types standards créés**

| Code | Nom | Séquence | Couleur | Icône | Stock | Prix | Impression | Validation | Système |
|------|-----|----------|---------|-------|-------|------|------------|------------|---------|
| `NORMAL` | Normale | 1 | `#28a745` | `Box` | ✅ | ✅ | ✅ | ❌ | ✅ |
| `TITLE` | Titre | 2 | `#6c757d` | `Heading` | ❌ | ❌ | ✅ | ❌ | ✅ |
| `PACK` | Pack | 3 | `#17a2b8` | `Package` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `OPTION` | Option | 4 | `#ffc107` | `Plus` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `SERVICE` | Service | 5 | `#6f42c1` | `Settings` | ❌ | ✅ | ✅ | ❌ | ❌ |
| `DISCOUNT` | Remise | 6 | `#dc3545` | `Minus` | ❌ | ✅ | ✅ | ❌ | ❌ |
| `COMMENT` | Commentaire | 7 | `#fd7e14` | `MessageCircle` | ❌ | ❌ | ✅ | ❌ | ❌ |
| `SUBTOTAL` | Sous-total | 8 | `#20c997` | `Calculator` | ❌ | ❌ | ✅ | ❌ | ❌ |

### **🔄 Logique d'utilisation**
```
NORMAL    → Produits standards (physiques)
TITLE     → Sections et titres de documents
PACK      → Bundles et packs de produits
OPTION    → Accessoires et options
SERVICE   → Prestations et services
DISCOUNT  → Remises et réductions
COMMENT   → Notes et commentaires
SUBTOTAL  → Récapitulatifs partiels
```

---

## 🎯 **Règles métier**

### **✅ Validations automatiques**

1. **Unicité** : `code` et `sequence` doivent être uniques
2. **Codes obligatoires** : `code` et `name` ne peuvent pas être vides
3. **Types système** : `NORMAL`, `TITLE`, `PACK` sont protégés
4. **Utilisation** : Impossible de désactiver un type utilisé dans des lignes
5. **Quantités** : `max_quantity` >= `min_quantity`

### **🔒 Protections de sécurité**

1. **Soft delete** : Désactivation par défaut (pas de suppression)
2. **Force delete** : Suppression définitive seulement avec `$force = true`
3. **Migration automatique** : Remplacement par `NORMAL` en cas de suppression forcée
4. **Vérification des conflits** : Contrôle des codes/séquences lors de la réactivation

### **📈 Logique comportementale**

1. **Impact stock** : `affects_stock = true` → gestion des stocks
2. **Impact prix** : `affects_pricing = true` → calcul des prix
3. **Impression** : `is_printable = true` → apparition sur documents
4. **Validation** : `requires_validation = true` → validation requise
5. **Permissions** : `allows_modification/deletion` → contrôle des actions

---

## 🎨 **Interface utilisateur**

### **🎭 Icônes Lucide React**

```jsx
import { 
  Box, Package, Heading, Plus, Settings, 
  Minus, MessageCircle, Calculator
} from 'lucide-react';

const TypeIcon = ({ iconName, color, size = 16 }) => {
  const icons = {
    Box, Package, Heading, Plus, Settings,
    Minus, MessageCircle, Calculator
  };
  
  const Icon = icons[iconName];
  return <Icon color={color} size={size} />;
};
```

### **🎨 Palette de couleurs**

```css
/* Couleurs des types */
.type-normal { color: #28a745; }      /* Vert */
.type-title { color: #6c757d; }       /* Gris */
.type-pack { color: #17a2b8; }        /* Bleu clair */
.type-option { color: #ffc107; }      /* Jaune */
.type-service { color: #6f42c1; }     /* Violet */
.type-discount { color: #dc3545; }    /* Rouge */
.type-comment { color: #fd7e14; }     /* Orange */
.type-subtotal { color: #20c997; }    /* Vert clair */
```

### **📊 Composants React suggérés**

```jsx
// Badge de type
const TypeBadge = ({ type }) => (
  <span 
    className="badge" 
    style={{ backgroundColor: type.color }}
  >
    <TypeIcon iconName={type.icon} color="white" />
    {type.name}
  </span>
);

// Sélecteur de type
const TypeSelector = ({ types, selectedType, onChange }) => (
  <div className="type-selector">
    {types.map(type => (
      <div 
        key={type.code}
        className={`type-option ${selectedType?.code === type.code ? 'selected' : ''}`}
        onClick={() => onChange(type)}
      >
        <TypeIcon iconName={type.icon} color={type.color} />
        <span>{type.name}</span>
        {type.requires_validation && <span className="validation-required">*</span>}
      </div>
    ))}
  </div>
);

// Indicateur de comportement
const TypeBehavior = ({ type }) => (
  <div className="type-behavior">
    <span className={`behavior-indicator ${type.affects_stock ? 'active' : 'inactive'}`}>
      Stock
    </span>
    <span className={`behavior-indicator ${type.affects_pricing ? 'active' : 'inactive'}`}>
      Prix
    </span>
    <span className={`behavior-indicator ${type.is_printable ? 'active' : 'inactive'}`}>
      Impression
    </span>
    {type.requires_validation && (
      <span className="behavior-indicator validation">Validation</span>
    )}
  </div>
);
```

---

## 🔗 **Relations avec d'autres tables**

### **📊 Utilisation dans sale_order_line**
```sql
-- Ancienne structure (à transformer)
DEFINE FIELD type_select ON sale_order_line TYPE int DEFAULT 0;

-- Nouvelle structure (avec relation)
DEFINE FIELD type_id ON sale_order_line TYPE record<sale_order_line_type>;
```

### **📈 Requêtes avec jointures**
```sql
-- Lignes avec détails du type
SELECT 
    sol.*,
    sol.type_id.name as type_name,
    sol.type_id.color as type_color,
    sol.type_id.icon as type_icon,
    sol.type_id.affects_stock as affects_stock,
    sol.type_id.affects_pricing as affects_pricing
FROM sale_order_line sol
WHERE sol.type_id.is_active = true;

-- Statistiques par type
SELECT 
    type.name,
    type.color,
    COUNT(*) as line_count,
    SUM(sol.qty) as total_quantity,
    SUM(sol.in_tax_total) as total_amount,
    AVG(sol.in_tax_total) as avg_amount
FROM sale_order_line sol
JOIN sale_order_line_type type ON sol.type_id = type.id
WHERE type.is_active = true
GROUP BY type.id, type.name, type.color
ORDER BY type.sequence;
```

---

## 🧠 **Intelligence artificielle**

### **📊 Données structurées pour IA**
```sql
-- Modèle de prédiction du type de ligne
DEFINE ML MODEL line_type_predictor<CLASSIFICATION>
INPUTS product_id, client_partner_id, quantity, unit_price, context
OUTPUTS recommended_type, confidence_score;

-- Utilisation
SELECT 
    sol.*,
    ml::predict(line_type_predictor, {
        product_id: sol.product_id,
        client_partner_id: sol.sale_order_id.client_partner_id,
        quantity: sol.qty,
        unit_price: sol.price,
        context: "new_order"
    }) as type_prediction
FROM sale_order_line sol
WHERE sol.type_id IS NONE;
```

### **📈 Analytics avancées**
```sql
-- Analyse des patterns d'utilisation
SELECT 
    type.name as type_name,
    COUNT(*) as usage_count,
    AVG(sol.qty) as avg_quantity,
    AVG(sol.in_tax_total) as avg_amount,
    COUNT(DISTINCT sol.sale_order_id) as order_count,
    COUNT(DISTINCT sol.product_id) as product_count,
    -- Analyse temporelle
    DATE_TRUNC('month', sol.creation_date) as month,
    -- Analyse comportementale
    CASE 
        WHEN type.affects_stock THEN 'Stock Impact'
        WHEN type.affects_pricing THEN 'Price Impact'
        ELSE 'Display Only'
    END as impact_category
FROM sale_order_line sol
JOIN sale_order_line_type type ON sol.type_id = type.id
WHERE sol.creation_date >= '2024-01-01'
GROUP BY type.id, type.name, DATE_TRUNC('month', sol.creation_date), impact_category
ORDER BY type.sequence, month;
```

---

## 🚀 **Utilisation pratique**

### **📝 Exemples d'utilisation**

#### **1. Créer un nouveau type**
```sql
SELECT fn::create_sale_order_line_type(
    "MAINTENANCE",
    "Maintenance",
    9,
    "Ligne de maintenance préventive",
    false,  -- affects_stock
    true,   -- affects_pricing
    true,   -- is_printable
    true,   -- allows_modification
    true,   -- allows_deletion
    "#e83e8c",  -- color
    "Wrench",   -- icon
    true,   -- requires_validation
    1,      -- min_quantity
    NONE    -- max_quantity
);
```

#### **2. Lister les types actifs**
```sql
SELECT fn::list_sale_order_line_type();
```

#### **3. Rechercher un type**
```sql
SELECT fn::search_sale_order_line_type("service", false);
```

#### **4. Filtrer par comportement**
```sql
SELECT fn::list_sale_order_line_type_by_behavior(true, true, true);
```

#### **5. Désactiver un type**
```sql
SELECT fn::deactivate_sale_order_line_type(sale_order_line_type:MAINTENANCE);
```

#### **6. Valider les données**
```sql
SELECT fn::validate_sale_order_line_type_data();
```

#### **7. Obtenir les statistiques**
```sql
SELECT fn::get_sale_order_line_type_statistics();
```

#### **8. Réinitialiser les données**
```sql
SELECT fn::reset_sale_order_line_type_data();
```

### **⚠️ Gestion des erreurs**

Toutes les fonctions retournent un format standardisé :
```sql
{
    success: bool,           -- true/false
    message: string,         -- Message descriptif
    data: object,           -- Données retournées (optionnel)
    error: string           -- Message d'erreur (optionnel)
}
```

### **🔧 Maintenance**

#### **Nettoyage périodique**
```sql
-- Nettoyer les types inactifs non utilisés
SELECT fn::cleanup_unused_sale_order_line_type();
```

#### **Validation périodique**
```sql
-- Vérifier l'intégrité des données
SELECT fn::validate_sale_order_line_type_data();
```

#### **Monitoring des performances**
```sql
-- Surveiller l'utilisation des types
SELECT fn::get_sale_order_line_type_statistics();
```

---

## 📚 **Ressources**

### **🔗 Liens utiles**
- [Icônes Lucide React](https://lucide.dev/icons/)
- [Documentation SurrealDB](https://surrealdb.com/docs)
- [Guide des couleurs UI](https://tailwindcss.com/docs/customizing-colors)

### **📖 Fichiers associés**
- `structures/sale_order_line_type.surql` - Définition de la table
- `functions/create_sale_order_line_type.surql` - Fonction de création
- `functions/read_sale_order_line_type.surql` - Fonctions de lecture
- `functions/update_sale_order_line_type.surql` - Fonction de modification
- `functions/deactivate_sale_order_line_type.surql` - Fonction de désactivation
- `functions/activate_sale_order_line_type.surql` - Fonction d'activation
- `functions/list_sale_order_line_type.surql` - Fonctions de listage
- `functions/delete_sale_order_line_type.surql` - Fonction de suppression
- `functions/utility_sale_order_line_type.surql` - Fonctions utilitaires ✨
- `data_references/sale_order_line_type_data_references.surql` - Données initiales

---

**📅 Dernière mise à jour** : 2025  
**👤 Auteur** : Équipe Architecture Lyxal  
**🎯 Version** : 1.0 - Architecture complète  
**📋 Statut** : Production Ready ✅ 