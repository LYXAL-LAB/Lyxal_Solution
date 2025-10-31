 # 🎯 NIVEAU 0 - MASTER CONFIGURATION

## 📋 Vue d'ensemble

Le **niveau MASTER** est le **cœur de contrôle** de l'écosystème LYXAL. Il gère l'identité de la plateforme, l'infrastructure technique et le registry de toutes les plateformes subordonnées.

## 🏗️ Architecture MASTER

```
MASTER (Niveau 0)
├── Identité Plateforme (system_identity)
├── Infrastructure Technique (system_infrastructure) 
├── Registry Plateformes (master_registry)
└── Historique & Audit (system_config_metadata)
```

## 📁 Fichiers du niveau MASTER

### **Configuration système**
- `master_system_structure.surql` - Tables système (identity, infrastructure, metadata)
- `master_system_data.surql` - Données initiales système
- `master_system_functions.surql` - Fonctions CRUD avec validation

### **Registry des plateformes**
- `master_registry_structure.surql` - Tables registry multi-niveaux
- `master_registry_indexes.surql` - Index optimisés registry
- `master_registry_relations.surql` - Relations hiérarchiques

## 🔧 Tables principales

### **system_identity**
Configuration de l'identité plateforme MASTER
```sql
- platform_name: "LYXAL"
- platform_id: "lyxal-master-001"
- environment: "production"
- platform_version: "1.0.0"
- niveau_architectural: 0
- theme_par_defaut: "corporate"
```

### **system_infrastructure**
Configuration infrastructure technique
```sql
- surreal_db_url: "wss://..."
- surreal_namespace: "lyxal_platform"
- surreal_database: "platform"
- logto_master_endpoint: "https://..."
- api_base_url: "https://..."
```

### **system_config_metadata**
Historique et audit des modifications
```sql
- table_name: "system_identity"
- field_name: "platform_name"
- old_value / new_value
- changed_by / changed_at
- change_reason
```

## 🚀 Fonctions disponibles

### **fn::create_master_platform($data)**
Création complète d'une plateforme MASTER
- ✅ Validation des données
- ✅ Vérification unicité
- ✅ Transaction atomique
- ✅ Historique automatique

### **fn::update_master_config($table, $field, $value, ...)**
Mise à jour configuration avec traçabilité
- ✅ Validation avant modification
- ✅ Sauvegarde ancienne valeur
- ✅ Enregistrement historique

### **fn::get_master_platform($platform_id)**
Récupération configuration complète
- ✅ Identité + Infrastructure
- ✅ Métadonnées enrichies

### **fn::delete_master_platform($platform_id, $confirmation, ...)**
Suppression sécurisée avec confirmation
- ✅ Confirmation obligatoire
- ✅ Historique de suppression

## 💡 Utilisation

### **1. Installation**
```bash
# Exécuter dans l'ordre :
1. master_system_structure.surql
2. master_system_data.surql
3. master_registry_structure.surql
4. master_registry_indexes.surql
```

### **2. Création via formulaire**
```typescript
const result = await db.query(`
    RETURN fn::create_master_platform($data);
`, {
    data: {
        platform_name: "LYXAL_CLIENT_001",
        platform_id: "client-001-master",
        environment: "production",
        surreal_db_url: "wss://client-001.surreal.cloud/rpc",
        // ... autres champs
        created_by: "admin_user"
    }
});
```

### **3. Mise à jour configuration**
```typescript
const result = await db.query(`
    RETURN fn::update_master_config($table, $field, $value, $id, $user, $reason);
`, {
    table: "system_identity",
    field: "platform_name", 
    value: "NOUVEAU_NOM",
    id: "client-001-master",
    user: "admin_user",
    reason: "Changement commercial"
});
```

## 🔒 Sécurité

### **Permissions**
```sql
PERMISSIONS
    FOR select WHERE true
    FOR create, update WHERE $auth.role CONTAINS 'admin'
    FOR delete WHERE $auth.role CONTAINS 'admin'
```

### **Validation**
- ✅ Champs requis obligatoires
- ✅ Formats validés (URLs, longueurs)
- ✅ Énumérations contrôlées
- ✅ Unicité garantie

## 💰 Solution commerciale

### **Personnalisation client**
- ✅ Nom de plateforme personnalisable
- ✅ Thèmes adaptables
- ✅ Infrastructure configurable
- ✅ Endpoints personnalisés

### **Modification à chaud**
- ✅ Aucun redéploiement nécessaire
- ✅ Changements instantanés
- ✅ Historique complet
- ✅ Rollback possible

### **Audit & Compliance**
- ✅ Traçabilité complète
- ✅ Qui a changé quoi et quand
- ✅ Raisons des modifications
- ✅ Conformité réglementaire

## 🎯 Prochaines étapes

1. **Finaliser les fonctions MASTER**
2. **Créer interface d'administration**
3. **Développer niveau INVESTOR**
4. **Scripts de migration**
5. **Documentation commerciale**

---

**Niveau MASTER - Fondation de l'empire LYXAL** 🚀