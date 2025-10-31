# 📊 DOCUMENTATION COMPLÈTE - SALE ORDER STATUS

## 🎯 **Vue d'ensemble**

La table `sale_order_status` est une **table de référence intelligente** qui gère les statuts des commandes de vente dans Lyxal Suite. Elle remplace les valeurs magiques `int` par des relations typées pour une architecture moderne et "IA-ready".

---

## 📋 **Structure de la table**

### **🔧 Définition technique**
```sql
DEFINE TABLE sale_order_status SCHEMAFULL;
    COMMENT "Statuts des commandes de vente avec gestion intelligente";
```

### **📊 Champs de la table**

| Champ | Type | Obligatoire | Défaut | Description |
|-------|------|-------------|---------|-------------|
| `code` | `string` | ✅ | - | Code unique du statut (ex: DRAFT, CONFIRMED) |
| `name` | `string` | ✅ | - | Nom affiché du statut (ex: "Brouillon", "Confirmée") |
| `sequence` | `int` | ✅ | - | Ordre d'affichage et logique workflow |
| `color` | `string` | ❌ | `#6c757d` | Couleur hexadécimale pour l'interface |
| `icon` | `string` | ❌ | `FileEdit` | Icône Lucide React |
| `is_final` | `bool` | ❌ | `false` | Statut final (pas de transition possible) |
| `allows_modification` | `bool` | ❌ | `true` | Permet la modification de la commande |
| `description` | `string` | ❌ | - | Description détaillée du statut |
| `is_active` | `bool` | ❌ | `true` | Statut actif/inactif (soft delete) |
| `created_on` | `datetime` | ❌ | `time::now()` | Date de création |
| `updated_on` | `datetime` | ❌ | `time::now()` | Date de dernière modification |

### **🔍 Index d'optimisation**
```sql
DEFINE INDEX idx_sale_order_status_code ON sale_order_status COLUMNS code UNIQUE;
DEFINE INDEX idx_sale_order_status_sequence ON sale_order_status COLUMNS sequence;
DEFINE INDEX idx_sale_order_status_active ON sale_order_status COLUMNS is_active;
```

---

## 🚀 **Fonctions disponibles**

### **📁 Organisation des fonctions**
```
sale_order_status/functions/
├── create_sale_order_status.surql      # Création
├── read_sale_order_status.surql        # Lecture
├── update_sale_order_status.surql      # Modification
├── deactivate_sale_order_status.surql  # Désactivation (soft delete)
├── activate_sale_order_status.surql    # Réactivation
├── list_sale_order_status.surql        # Listage et recherche
├── delete_sale_order_status.surql      # Suppression définitive
└── utility_sale_order_status.surql     # Fonctions utilitaires
```

### **🔧 Fonctions CRUD**

#### **1. Création**
```sql
fn::create_sale_order_status(
    $code: string,           -- Code unique (obligatoire)
    $name: string,           -- Nom affiché (obligatoire)
    $sequence: int,          -- Ordre (obligatoire)
    $color: string,          -- Couleur hex (optionnel)
    $icon: string,           -- Icône Lucide (optionnel)
    $is_final: bool,         -- Statut final (optionnel)
    $allows_modification: bool, -- Permet modification (optionnel)
    $description: string     -- Description (optionnel)
)
```

**Exemple** :
```sql
SELECT fn::create_sale_order_status(
    "PENDING_APPROVAL", 
    "En attente d'approbation", 
    15, 
    "#ffc107", 
    "UserCheck", 
    false, 
    false, 
    "Commande nécessitant une validation hiérarchique"
);
```

#### **2. Lecture**
```sql
-- Lecture par ID
fn::read_sale_order_status($id: record<sale_order_status>)

-- Lecture par code
fn::read_sale_order_status_by_code($code: string)

-- Lecture avec statistiques d'utilisation
fn::read_sale_order_status_with_usage($id: record<sale_order_status>)
```

#### **3. Modification**
```sql
fn::update_sale_order_status(
    $id: record<sale_order_status>,
    $code: string,           -- Nouveau code (optionnel)
    $name: string,           -- Nouveau nom (optionnel)
    $sequence: int,          -- Nouvelle séquence (optionnel)
    $color: string,          -- Nouvelle couleur (optionnel)
    $icon: string,           -- Nouvelle icône (optionnel)
    $is_final: bool,         -- Nouveau statut final (optionnel)
    $allows_modification: bool, -- Nouvelle permission (optionnel)
    $description: string     -- Nouvelle description (optionnel)
)
```

#### **4. Désactivation (Soft Delete)**
```sql
-- Désactivation par ID
fn::deactivate_sale_order_status($id: record<sale_order_status>)

-- Désactivation par code
fn::deactivate_sale_order_status_by_code($code: string)
```

#### **5. Réactivation**
```sql
-- Réactivation par ID
fn::activate_sale_order_status($id: record<sale_order_status>)

-- Réactivation par code
fn::activate_sale_order_status_by_code($code: string)
```

### **📋 Fonctions de listage**

#### **1. Listes simples**
```sql
-- Statuts actifs seulement
fn::list_sale_order_status()

-- Tous les statuts (actifs + inactifs)
fn::list_all_sale_order_status()

-- Avec statistiques d'utilisation
fn::list_sale_order_status_with_stats()
```

#### **2. Pagination**
```sql
fn::list_sale_order_status_paginated(
    $page: int,              -- Numéro de page
    $limit: int,             -- Nombre d'éléments par page
    $include_inactive: bool  -- Inclure les inactifs
)
```

#### **3. Recherche**
```sql
fn::search_sale_order_status(
    $search: string,         -- Terme de recherche
    $include_inactive: bool  -- Inclure les inactifs
)
```

#### **4. Workflow**
```sql
-- Obtenir les statuts suivants possibles
fn::get_next_possible_statuses($current_status_id: record<sale_order_status>)
```

### **🗑️ Suppression définitive**
```sql
-- Suppression avec protection
fn::delete_sale_order_status($id: record<sale_order_status>, $force: bool)

-- Suppression par code
fn::delete_sale_order_status_by_code($code: string, $force: bool)

-- Nettoyage des statuts inutilisés
fn::cleanup_unused_sale_order_status()
```

### **🔧 Fonctions utilitaires**

#### **1. Gestion des données de référence**
```sql
-- Réinitialiser les données de référence (4 statuts de base)
fn::reset_sale_order_status_data()

-- Créer un statut de test
fn::create_test_sale_order_status()
```

#### **2. Validation et contrôle**
```sql
-- Valider l'intégrité des données
fn::validate_sale_order_status_data()
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
- ✅ Présence des statuts obligatoires (DRAFT, CONFIRMED, COMPLETED, CANCELLED)
- ✅ Absence de doublons de séquence
- ✅ Absence de doublons de code
- ✅ Cohérence des données

#### **3. Statistiques et analytics**
```sql
-- Obtenir les statistiques globales
fn::get_sale_order_status_statistics()
```

**Retourne** :
```json
{
    "total_statuses": 12,
    "active_statuses": 10,
    "inactive_statuses": 2,
    "final_statuses": 2,
    "most_used_status": {"code": "CONFIRMED", "name": "Confirmée", "usage_count": 1500},
    "least_used_status": {"code": "ON_HOLD", "name": "En attente", "usage_count": 5}
}
```

#### **4. Interface utilisateur**
```sql
-- Obtenir la liste des icônes Lucide disponibles
fn::get_available_lucide_icons()
```

**Retourne** : Array de 50+ icônes Lucide React utilisables

---

## 📊 **Données de référence**

### **🎨 Statuts standards créés**

| Code | Nom | Séquence | Couleur | Icône | Final | Modifiable |
|------|-----|----------|---------|-------|-------|------------|
| `DRAFT` | Brouillon | 1 | `#6c757d` | `FileEdit` | ❌ | ✅ |
| `CONFIRMED` | Confirmée | 2 | `#28a745` | `CheckCircle` | ❌ | ❌ |
| `IN_PROGRESS` | En cours | 3 | `#17a2b8` | `Clock` | ❌ | ❌ |
| `SHIPPED` | Expédiée | 4 | `#fd7e14` | `Truck` | ❌ | ❌ |
| `DELIVERED` | Livrée | 5 | `#20c997` | `PackageCheck` | ❌ | ❌ |
| `COMPLETED` | Terminée | 6 | `#007bff` | `CheckCircle2` | ✅ | ❌ |
| `CANCELLED` | Annulée | 99 | `#dc3545` | `XCircle` | ✅ | ❌ |
| `ON_HOLD` | En attente | 10 | `#ffc107` | `Pause` | ❌ | ✅ |
| `PENDING_APPROVAL` | Approbation | 15 | `#6f42c1` | `UserCheck` | ❌ | ❌ |
| `PARTIALLY_SHIPPED` | Partiel | 35 | `#e83e8c` | `PackageMinus` | ❌ | ❌ |
| `INVOICED` | Facturée | 50 | `#198754` | `Receipt` | ❌ | ❌ |
| `PAID` | Payée | 55 | `#0d6efd` | `CreditCard` | ❌ | ❌ |

### **🔄 Workflow logique**
```
DRAFT → CONFIRMED → IN_PROGRESS → SHIPPED → DELIVERED → COMPLETED
  ↓         ↓            ↓           ↓          ↓
CANCELLED ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
  ↑
ON_HOLD → PENDING_APPROVAL
```

---

## 🎯 **Règles métier**

### **✅ Validations automatiques**

1. **Unicité** : `code` et `sequence` doivent être uniques
2. **Codes obligatoires** : `code` et `name` ne peuvent pas être vides
3. **Statuts système** : `DRAFT`, `CONFIRMED`, `COMPLETED`, `CANCELLED` sont protégés
4. **Utilisation** : Impossible de désactiver un statut utilisé dans des commandes
5. **Transitions** : Seules les transitions logiques sont autorisées

### **🔒 Protections de sécurité**

1. **Soft delete** : Désactivation par défaut (pas de suppression)
2. **Force delete** : Suppression définitive seulement avec `$force = true`
3. **Migration automatique** : Remplacement par `DRAFT` en cas de suppression forcée
4. **Vérification des conflits** : Contrôle des codes/séquences lors de la réactivation

### **📈 Logique de workflow**

1. **Séquence croissante** : Transitions généralement vers des séquences supérieures
2. **Retour au brouillon** : Toujours possible (sauf statuts finaux)
3. **Statuts finaux** : `is_final = true` empêche les transitions sortantes
4. **Modification** : `allows_modification = false` verrouille la commande

---

## 🎨 **Interface utilisateur**

### **🎭 Icônes Lucide React**

```jsx
import { 
  FileEdit, CheckCircle, Clock, Truck, 
  PackageCheck, XCircle, Pause, UserCheck,
  PackageMinus, Receipt, CreditCard, CheckCircle2
} from 'lucide-react';

const StatusIcon = ({ iconName, color, size = 16 }) => {
  const icons = {
    FileEdit, CheckCircle, Clock, Truck,
    PackageCheck, XCircle, Pause, UserCheck,
    PackageMinus, Receipt, CreditCard, CheckCircle2
  };
  
  const Icon = icons[iconName];
  return <Icon color={color} size={size} />;
};
```

### **🎨 Palette de couleurs**

```css
/* Couleurs des statuts */
.status-draft { color: #6c757d; }      /* Gris */
.status-confirmed { color: #28a745; }  /* Vert */
.status-progress { color: #17a2b8; }   /* Bleu clair */
.status-shipped { color: #fd7e14; }    /* Orange */
.status-delivered { color: #20c997; }  /* Vert clair */
.status-completed { color: #007bff; }  /* Bleu */
.status-cancelled { color: #dc3545; }  /* Rouge */
.status-hold { color: #ffc107; }       /* Jaune */
.status-approval { color: #6f42c1; }   /* Violet */
.status-partial { color: #e83e8c; }    /* Rose */
.status-invoiced { color: #198754; }   /* Vert foncé */
.status-paid { color: #0d6efd; }       /* Bleu roi */
```

### **📊 Composants React suggérés**

```jsx
// Badge de statut
const StatusBadge = ({ status }) => (
  <span 
    className="badge" 
    style={{ backgroundColor: status.color }}
  >
    <StatusIcon iconName={status.icon} color="white" />
    {status.name}
  </span>
);

// Stepper de workflow
const OrderWorkflow = ({ currentStatus, allStatuses }) => (
  <div className="workflow-stepper">
    {allStatuses.map(status => (
      <div 
        key={status.code}
        className={`step ${status.sequence <= currentStatus.sequence ? 'completed' : 'pending'}`}
      >
        <StatusIcon iconName={status.icon} color={status.color} />
        <span>{status.name}</span>
      </div>
    ))}
  </div>
);
```

---

## 🔗 **Relations avec d'autres tables**

### **📊 Utilisation dans sale_order**
```sql
-- Ancienne structure (à transformer)
DEFINE FIELD status_select ON sale_order TYPE int DEFAULT 1;

-- Nouvelle structure (avec relation)
DEFINE FIELD status_id ON sale_order TYPE record<sale_order_status>;
```

### **📈 Requêtes avec jointures**
```sql
-- Commandes avec détails du statut
SELECT 
    so.*,
    so.status_id.name as status_name,
    so.status_id.color as status_color,
    so.status_id.icon as status_icon
FROM sale_order so
WHERE so.status_id.is_active = true;

-- Statistiques par statut
SELECT 
    status.name,
    status.color,
    COUNT(*) as order_count,
    SUM(so.in_tax_total) as total_amount
FROM sale_order so
JOIN sale_order_status status ON so.status_id = status.id
WHERE status.is_active = true
GROUP BY status.id, status.name, status.color
ORDER BY status.sequence;
```

---

## 🧠 **Intelligence artificielle**

### **📊 Données structurées pour IA**
```sql
-- Modèle de prédiction des transitions
DEFINE ML MODEL status_transition_predictor<CLASSIFICATION>
INPUTS client_partner_id, team_id, in_tax_total, current_status_sequence
OUTPUTS next_status_probability, estimated_days_to_completion;

-- Utilisation
SELECT 
    so.*,
    ml::predict(status_transition_predictor, {
        client_partner_id: so.client_partner_id,
        team_id: so.team_id,
        in_tax_total: so.in_tax_total,
        current_status_sequence: so.status_id.sequence
    }) as prediction
FROM sale_order so
WHERE so.status_id.code = 'CONFIRMED';
```

### **📈 Analytics avancées**
```sql
-- Analyse des temps de transition
SELECT 
    from_status.name as from_status,
    to_status.name as to_status,
    AVG(DURATION(so1.updated_on, so2.updated_on)) as avg_transition_time,
    COUNT(*) as transition_count
FROM sale_order so1
JOIN sale_order so2 ON so1.id = so2.id
JOIN sale_order_status from_status ON so1.status_id = from_status.id
JOIN sale_order_status to_status ON so2.status_id = to_status.id
WHERE so2.updated_on > so1.updated_on
GROUP BY from_status.id, to_status.id
ORDER BY from_status.sequence, to_status.sequence;
```

---

## 🚀 **Utilisation pratique**

### **📝 Exemples d'utilisation**

#### **1. Créer un nouveau statut**
```sql
SELECT fn::create_sale_order_status(
    "QUALITY_CHECK",
    "Contrôle qualité",
    25,
    "#9c27b0",
    "Shield",
    false,
    false,
    "Commande en cours de contrôle qualité"
);
```

#### **2. Lister les statuts actifs**
```sql
SELECT fn::list_sale_order_status();
```

#### **3. Rechercher un statut**
```sql
SELECT fn::search_sale_order_status("appro", false);
```

#### **4. Obtenir les transitions possibles**
```sql
SELECT fn::get_next_possible_statuses(sale_order_status:CONFIRMED);
```

#### **5. Désactiver un statut**
```sql
SELECT fn::deactivate_sale_order_status(sale_order_status:QUALITY_CHECK);
```

#### **6. Valider les données**
```sql
SELECT fn::validate_sale_order_status_data();
```

#### **7. Obtenir les statistiques**
```sql
SELECT fn::get_sale_order_status_statistics();
```

#### **8. Réinitialiser les données**
```sql
SELECT fn::reset_sale_order_status_data();
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
-- Nettoyer les statuts inactifs non utilisés
SELECT fn::cleanup_unused_sale_order_status();
```

#### **Validation périodique**
```sql
-- Vérifier l'intégrité des données
SELECT fn::validate_sale_order_status_data();
```

#### **Monitoring des performances**
```sql
-- Surveiller l'utilisation des statuts
SELECT fn::get_sale_order_status_statistics();
```

---

## 📚 **Ressources**

### **🔗 Liens utiles**
- [Icônes Lucide React](https://lucide.dev/icons/)
- [Documentation SurrealDB](https://surrealdb.com/docs)
- [Guide des couleurs UI](https://tailwindcss.com/docs/customizing-colors)

### **📖 Fichiers associés**
- `structures/sale_order_status.surql` - Définition de la table
- `functions/create_sale_order_status.surql` - Fonction de création
- `functions/read_sale_order_status.surql` - Fonctions de lecture
- `functions/update_sale_order_status.surql` - Fonction de modification
- `functions/deactivate_sale_order_status.surql` - Fonction de désactivation
- `functions/activate_sale_order_status.surql` - Fonction d'activation
- `functions/list_sale_order_status.surql` - Fonctions de listage
- `functions/delete_sale_order_status.surql` - Fonction de suppression
- `functions/utility_sale_order_status.surql` - Fonctions utilitaires ✨
- `data_references/sale_order_status_data_references.surql` - Données initiales

---

**📅 Dernière mise à jour** : 2025  
**👤 Auteur** : Équipe Architecture Lyxal  
**🎯 Version** : 1.1 - Architecture optimisée  
**📋 Statut** : Production Ready ✅ 