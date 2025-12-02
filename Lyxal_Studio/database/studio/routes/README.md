# 🗄️ **PHASE 2 : SCHÉMAS BASE DE DONNÉES**

## 🎯 **Objectif**
Créer les schémas SurrealDB robustes pour persister les routes dynamiques avec sécurité intégrée.

## 📋 **Fichiers Créés**

### **Schémas Principaux**
- **`studio_route.surql`** - Schéma principal des routes dynamiques
- **`route_permissions.surql`** - Permissions disponibles
- **`route_guards.surql`** - Guards de sécurité

### **Index & Export**
- **`../index.surql`** - Export centralisé des schémas

### **Données de Référence**
- **`../../reference/studio/routes/route_seeds.surql`** - Routes d'exemple
- **`../../reference/studio/routes/route_permissions_seeds.surql`** - Permissions de base
- **`../../reference/studio/routes/route_guards_seeds.surql`** - Guards système

### **Scripts de Test**
- **`test_import.sh`** - Script Bash pour Linux/Mac
- **`test_import.ps1`** - Script PowerShell pour Windows

## 🏗️ **Architecture DB**

### **Tables Principales**

#### **studio_route**
```sql
- identity: {value, slug, code}  -- Identité unique de la route
- page: record<studio_page>      -- Page associée
- permissions: array<string>     -- Permissions requises
- guards: array<object>          -- Guards de sécurité
- metadata: object               -- Métadonnées optionnelles
- status: enum                    -- Statut de la route
- timestamps + etag               -- Audit et locking
```

#### **route_permissions**
```sql
- code: string                    -- Code unique
- name_i18n: string              -- Nom internationalisé
- category: string               -- Catégorie logique
- description_i18n: string       -- Description
- is_system: bool                -- Permission système
```

#### **route_guards**
```sql
- code: string                    -- Code unique
- name_i18n: string              -- Nom internationalisé
- type: enum                      -- Type de guard
- config_schema: object          -- Schéma de configuration
- is_system: bool                -- Guard système
```

## 🔐 **Sécurité Intégrée**

### **Contraintes DB**
- ✅ **Assertions** sur les formats (regex pour chemins, slugs)
- ✅ **Enums** pour permissions et statuts
- ✅ **Relations** avec studio_page
- ✅ **Timestamps** automatiques
- ✅ **ETags** pour optimistic locking

### **Permissions d'Accès**
- ✅ **RBAC** : Seuls les admins peuvent modifier
- ✅ **Lecture publique** pour les routes actives
- ✅ **Audit trail** avec timestamps

### **Indexes Performants**
- ✅ **UNIQUE** sur identity (value, slug, code)
- ✅ **INDEX** sur status, permissions, page
- ✅ **WHERE** clauses pour filtrage actif

## 📊 **Données de Référence**

### **Permissions Système**
```sql
guest           - Accès public
authenticated   - Utilisateur connecté
admin          - Administrateur
manager        - Manager
```

### **Guards Système**
```sql
auth           - Vérification authentification
role           - Vérification rôle utilisateur
subscription   - Vérification abonnement
feature        - Vérification fonctionnalité
```

### **Routes d'Exemple**
```sql
/              - Page d'accueil (guest)
/dashboard     - Tableau de bord (authenticated + auth guard)
/admin         - Administration (admin + auth + role guards)
/settings      - Paramètres (authenticated + auth guard)
/signin        - Connexion (guest)
```

## 🚀 **Utilisation**

### **Import des Schémas**
```bash
# Linux/Mac
./test_import.sh

# Windows
.\test_import.ps1

# Manuel
surreal import --conn http://localhost:8000 \
               --user root --pass root \
               --ns lyxal --db studio \
               studio_route.surql
```

### **Vérification**
```sql
-- Lister toutes les routes actives
SELECT identity.value, permissions, status
FROM studio_route
WHERE status = "active";

-- Compter les permissions
SELECT count() FROM route_permissions GROUP ALL;

-- Lister les guards disponibles
SELECT code, type FROM route_guards;
```

## 🧪 **Tests de Validation**

### **Contraintes Fonctionnelles**
- ✅ **Chemins** doivent commencer par `/`
- ✅ **Slugs** doivent être kebab-case
- ✅ **Codes** doivent être snake_case
- ✅ **Permissions** doivent être dans l'enum
- ✅ **Guards** doivent avoir un type valide

### **Performance**
- ✅ **Indexes** sur tous les champs de recherche
- ✅ **Relations** optimisées
- ✅ **Cache-friendly** avec status actif

## 📈 **Métriques de Succès**

- ✅ **3 schémas** créés et validés
- ✅ **4 permissions** système définies
- ✅ **4 guards** système configurés
- ✅ **5 routes** d'exemple créées
- ✅ **Scripts d'import** fonctionnels
- ✅ **Contraintes DB** respectées
- ✅ **Indexes** optimisés

## 🎯 **Prêt pour Phase 3**

**Les schémas DB sont solides et prêts !**

**Phase 3 : Services & Registry** pour l'accès aux données.

**On continue avec les services ?** 🤝
