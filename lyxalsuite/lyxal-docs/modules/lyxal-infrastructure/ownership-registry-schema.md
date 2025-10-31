# 📋 REGISTRE DE PROPRIÉTÉ - MODULE INFRASTRUCTURE

## 🎯 Objectif

Établir un **registre central** pour tracer la propriété des ressources infrastructure (domaines, hébergement, email, SMS, SSL) vers leurs vrais propriétaires dans la hiérarchie LyxalSuite, même si tout est techniquement géré par le Master Ultimate.

## 📊 **ARCHITECTURE DU REGISTRE**

### **Problématique**
- Les ressources infrastructure sont techniquement dans la DB du **Master Ultimate**
- Mais elles peuvent être **délléguées/assignées** à des comptes de niveaux inférieurs :
  - INVESTOR (qui dépend du Master)
  - BUSINESS (qui dépend d'un Investor)  
  - DEVELOPER (qui dépend d'un Business)
  - CONTRACTOR (qui dépend d'un Developer)

### **Solution : Table `ownership_registry`**
Un registre central qui mappe chaque ressource vers son **propriétaire réel** et sa **chaîne hiérarchique**.

---

## 🗄️ **SCHÉMA SURREALDB**

### Table `ownership_registry`
```sql
DEFINE TABLE ownership_registry SCHEMAFULL;

-- Master Ultimate responsable (UNIQUE dans tout LyxalSuite)
DEFINE FIELD master_ultimate_id ON ownership_registry TYPE string DEFAULT "master_ultimate_unique";

-- Master local responsable de cette instance SurrealDB
DEFINE FIELD master_account_id ON ownership_registry TYPE record<master_accounts> ASSERT $value != NONE;

-- Type de ressource infrastructure
DEFINE FIELD resource_type ON ownership_registry TYPE string ASSERT $value INSIDE ["domain", "hosting", "email", "sms", "ssl"];

-- ID unique de la ressource (ex: "domains:exemple.com")
DEFINE FIELD resource_id ON ownership_registry TYPE string ASSERT string::len($value) > 0;

-- Niveau hiérarchique du propriétaire réel (avec Master Ultimate)
DEFINE FIELD owner_level ON ownership_registry TYPE string ASSERT $value INSIDE ["MASTER_ULTIMATE", "MASTER", "INVESTOR", "BUSINESS", "DEVELOPER", "CONTRACTOR"];

-- ID du compte propriétaire réel
DEFINE FIELD owner_account_id ON ownership_registry TYPE string ASSERT string::len($value) > 0;

-- Namespace du propriétaire (où sont ses données)
DEFINE FIELD owner_namespace ON ownership_registry TYPE string ASSERT string::len($value) > 0;

-- Base de données du propriétaire
DEFINE FIELD owner_database ON ownership_registry TYPE string ASSERT string::len($value) > 0;

-- Parent dans la hiérarchie (optionnel si MASTER_ULTIMATE)
DEFINE FIELD parent_owner_id ON ownership_registry TYPE string;

-- Chaîne complète de délégation (MASTER_ULTIMATE → MASTER → INVESTOR → BUSINESS → DEVELOPER → CONTRACTOR)
DEFINE FIELD delegation_chain ON ownership_registry TYPE array;

-- Permissions spécifiques sur la ressource
DEFINE FIELD permissions ON ownership_registry TYPE object;

-- Qui paye la facture (owner/parent/master/master_ultimate)
DEFINE FIELD billing_responsibility ON ownership_registry TYPE string ASSERT $value INSIDE ["owner", "parent", "master", "master_ultimate"];

-- Timestamps
DEFINE FIELD created_at ON ownership_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ownership_registry TYPE datetime DEFAULT time::now();

-- Index pour performance
DEFINE INDEX idx_master_ultimate ON ownership_registry COLUMNS master_ultimate_id;
DEFINE INDEX idx_master_registry ON ownership_registry COLUMNS master_account_id;
DEFINE INDEX idx_resource_type ON ownership_registry COLUMNS resource_type;
DEFINE INDEX idx_resource_id ON ownership_registry COLUMNS resource_id UNIQUE;
DEFINE INDEX idx_owner_level ON ownership_registry COLUMNS owner_level;
DEFINE INDEX idx_owner_account ON ownership_registry COLUMNS owner_account_id;
DEFINE INDEX idx_owner_namespace ON ownership_registry COLUMNS owner_namespace;
```

---

## 📝 **EXEMPLES D'UTILISATION**

### **Cas 1 : Domaine du Master**
```sql
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "domain",
  resource_id: "domains:lyxal-john.com",
  owner_level: "MASTER",
  owner_account_id: "master_john",
  owner_namespace: "NS master_john",
  owner_database: "DB main_john",
  delegation_chain: ["MASTER_ULTIMATE", "MASTER"],
  permissions: {
    "full_control": true,
    "can_delegate": true,
    "can_transfer": true
  },
  billing_responsibility: "owner"
};
```

### **Cas 2 : Domaine délégué à un Investor**
```sql
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "domain",
  resource_id: "domains:startup-alice.com",
  owner_level: "INVESTOR",
  owner_account_id: "investor_alice",
  owner_namespace: "NS investor_alice", 
  owner_database: "DB main_alice",
  parent_owner_id: "master_john",
  delegation_chain: ["MASTER_ULTIMATE", "MASTER", "INVESTOR"],
  permissions: {
    "manage_dns": true,
    "manage_email": true,
    "can_delegate": true
  },
  billing_responsibility: "master"
};
```

### **Cas 3 : Hébergement délégué niveau Developer**
```sql
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "hosting",
  resource_id: "hosting_accounts:project_bob_hosting",
  owner_level: "DEVELOPER",
  owner_account_id: "developer_bob",
  owner_namespace: "NS developer_bob",
  owner_database: "DB main_bob",
  parent_owner_id: "business_carol",
  delegation_chain: ["MASTER_ULTIMATE", "MASTER", "INVESTOR", "BUSINESS", "DEVELOPER"],
  permissions: {
    "manage_files": true,
    "manage_databases": true,
    "view_stats": true
  },
  billing_responsibility: "master"
};
```

### **Cas 4 : Email délégué niveau Contractor (chaîne complète)**
```sql
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "email",
  resource_id: "email_accounts:support@client-project.com",
  owner_level: "CONTRACTOR",
  owner_account_id: "contractor_david",
  owner_namespace: "NS contractor_david",
  owner_database: "DB main_david",
  parent_owner_id: "developer_bob",
  delegation_chain: ["MASTER_ULTIMATE", "MASTER", "INVESTOR", "BUSINESS", "DEVELOPER", "CONTRACTOR"],
  permissions: {
    "manage_inbox": true,
    "create_aliases": false,
    "view_stats": true
  },
  billing_responsibility: "master"
};
```

---

## 🔍 **FONCTIONS DE RECHERCHE**

### 1. Trouver le propriétaire d'une ressource
```sql
DEFINE FUNCTION fn::get_resource_owner($resource_id: string) {
  RETURN SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
};

-- Utilisation
SELECT fn::get_resource_owner("domains:startup-alice.com");
```

### 2. Lister toutes les ressources d'un propriétaire
```sql
DEFINE FUNCTION fn::get_owner_resources($owner_account_id: string) {
  RETURN SELECT * FROM ownership_registry WHERE owner_account_id = $owner_account_id;
};

-- Utilisation
SELECT fn::get_owner_resources("investor_alice");
```

### 3. Vérifier les permissions d'accès
```sql
DEFINE FUNCTION fn::check_resource_access($resource_id: string, $user_account_id: string) {
  LET $ownership = SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
  RETURN $ownership.owner_account_id = $user_account_id OR $user_account_id IN $ownership.delegation_chain;
};

-- Utilisation
SELECT fn::check_resource_access("domains:startup-alice.com", "investor_alice");
```

### 4. Tracer la chaîne de propriété complète
```sql
DEFINE FUNCTION fn::get_ownership_chain($resource_id: string) {
  LET $ownership = SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
  RETURN {
    resource_id: $resource_id,
    resource_type: $ownership.resource_type,
    current_owner: $ownership.owner_account_id,
    owner_level: $ownership.owner_level,
    master_ultimate: $ownership.master_account_id,
    full_chain: $ownership.delegation_chain,
    billing_responsible: $ownership.billing_responsibility,
    permissions: $ownership.permissions
  };
};
```

### 5. Lister toutes les ressources d'un Master Ultimate
```sql
DEFINE FUNCTION fn::get_master_resources($master_account_id: string) {
  RETURN SELECT * FROM ownership_registry WHERE master_account_id = $master_account_id;
};
```

### 6. Rechercher par niveau hiérarchique
```sql
DEFINE FUNCTION fn::get_resources_by_level($master_account_id: string, $level: string) {
  RETURN SELECT * FROM ownership_registry 
         WHERE master_account_id = $master_account_id 
         AND owner_level = $level;
};

-- Exemple: Tous les domaines des Investors sous ce Master
SELECT fn::get_resources_by_level("master_john", "INVESTOR");
```

---

## 🎯 **FLUX D'UTILISATION**

### **1. Création d'une ressource**
```sql
-- 1. Créer la ressource (ex: domaine)
INSERT INTO domains { ... };

-- 2. Enregistrer la propriété
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "domain",
  resource_id: "domains:nouveau-domaine.com",
  owner_level: "BUSINESS",
  owner_account_id: "business_carol",
  owner_namespace: "NS business_carol",
  owner_database: "DB main_carol",
  parent_owner_id: "investor_alice",
  delegation_chain: ["MASTER_ULTIMATE", "MASTER", "INVESTOR", "BUSINESS"],
  billing_responsibility: "master"
};
```

### **2. Délégation d'une ressource**
```sql
-- Changer le propriétaire (ex: Master → Investor)
UPDATE ownership_registry 
SET owner_level = "INVESTOR",
    owner_account_id = "investor_alice",
    owner_namespace = "NS investor_alice",
    owner_database = "DB main_alice",
    delegation_chain = ["MASTER_ULTIMATE", "MASTER", "INVESTOR"],
    updated_at = time::now()
WHERE resource_id = "domains:exemple.com";
```

### **3. Vérification avant action**
```sql
-- Avant de modifier une ressource, vérifier les permissions
LET $access = fn::check_resource_access("domains:exemple.com", $current_user_id);
IF $access THEN {
  -- Autoriser l'action
} ELSE {
  -- Refuser l'accès
};
```

---

## 💼 **GESTION FACTURATION**

### **Responsabilité de paiement**
Le champ `billing_responsibility` détermine qui paye :

- **"owner"** : Le propriétaire direct paye
- **"parent"** : Le parent dans la hiérarchie paye  
- **"master"** : Le Master Ultimate paye (défaut)

### **Requête facturation**
```sql
-- Toutes les ressources facturées au Master
SELECT * FROM ownership_registry WHERE billing_responsibility = "master";

-- Ressources où l'Investor paye lui-même
SELECT * FROM ownership_registry 
WHERE owner_level = "INVESTOR" AND billing_responsibility = "owner";
```

---

## 🔐 **SÉCURITÉ ET PERMISSIONS**

### **Isolation des données**
- Les ressources restent dans la DB du **Master Ultimate**
- Le registre trace seulement la **propriété logique**
- Les **permissions** sont stockées dans l'objet `permissions`

### **Contrôle d'accès**
```sql
-- Fonction pour vérifier si un utilisateur peut accéder à une ressource
DEFINE FUNCTION fn::can_access_resource($resource_id: string, $user_id: string, $action: string) {
  LET $ownership = SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
  LET $user_permissions = $ownership.permissions;
  
  RETURN $ownership.owner_account_id = $user_id 
         OR ($user_id IN $ownership.delegation_chain AND $user_permissions[$action] = true);
};
```

---

## 📊 **STATISTIQUES ET REPORTING**

### **Dashboard Master Ultimate**
```sql
-- Résumé de toutes les ressources par type
SELECT resource_type, count() as total 
FROM ownership_registry 
WHERE master_account_id = "master_john"
GROUP BY resource_type;

-- Répartition par niveau de propriétaire
SELECT owner_level, count() as total
FROM ownership_registry 
WHERE master_account_id = "master_john"
GROUP BY owner_level;
```

### **Analytics de délégation**
```sql
-- Resources les plus déléguées
SELECT resource_type, owner_level, count() as delegated_count
FROM ownership_registry 
WHERE owner_level != "MASTER_ULTIMATE"
GROUP BY resource_type, owner_level
ORDER BY delegated_count DESC;
```

---

**Version :** 1.0  
**Intégration :** Module lyxal-infrastructure  
**Base de données :** `NS master_{name}` → `DB main_{name}`  
**Statut :** Prêt pour implémentation 