# NIVEAU 0 : MASTER

## 📋 Informations Générales

- **Numéro de niveau :** 0
- **Nom officiel :** MASTER
- **Position hiérarchique :** - → **MASTER** → INVESTOR
- **Date de création template :** Décembre 2024
- **Version :** 1.1
- **Document de référence :** GLOBAL-OVERVIEW.md

---

## 🎯 Définition et Rôle

### Définition Précise
- **Créateur plateforme** : Propriétaire de LyxalSuite (équivalent GoHighLevel Corp)
- **Droits** : Créer et gérer des INVESTORS, contrôle total de la plateforme
- **Infrastructure** : Instance SurrealDB unique hébergeant TOUS les niveaux
- **Revenus** : Vente de licences INVESTOR + via auto-affiliation toutes les sources de revenus de chaque niveau
- **Responsabilités** : Maintenance, mises à jour, support, évolution technologique
- **Architecture révolutionnaire** : Une seule instance pour TOUS les niveaux 

### Responsabilités Principales
- [ ] Créer et gérer des INVESTORS
- [ ] Maintenir l'instance SurrealDB unique pour tous les niveaux
- [ ] Gérer les namespaces NS master_{name}, NS investor_{name}, etc.
- [ ] Contrôle total de la plateforme et authentification Logto
- [ ] Maintenance, mises à jour, support, évolution technologique

### Limitations et Interdictions
- ❌ **Ne peut PAS** : Modifier l'architecture fondamentale sans impact sur tous les niveaux

---

## 💰 Modèle Économique

### Structure Financière
```typescript
interface MasterConfig {
  // Identification plateforme
  platform_id: 'lyxal_master';
  version: string;
  
  // Modèle économique - Création/Vente + Auto-affiliation
  economics: {
    creates: 'INVESTOR';
    revenue_model: 'license_sales_and_auto_affiliate_cascade';
    revenue_sources: {
      direct: 'investor_licenses';           // Vente directe licences INVESTOR
      auto_affiliate: {                      // Via auto-affiliation
        from_investor: 'cascade_revenues';   // Tous revenus INVESTOR
        from_business: 'cascade_revenues';   // Tous revenus BUSINESS
        from_developer: 'cascade_revenues';  // Tous revenus DEVELOPER
        from_contractor: 'cascade_revenues'; // Tous revenus CONTRACTOR
      };
    };
  };
}
```

### Flux Financiers
- **Revenus entrants :** 
  - Licences INVESTOR vendues directement
  - Via auto-affiliation : cascade de tous les revenus de chaque niveau (INVESTOR, BUSINESS, DEVELOPER, CONTRACTOR)
- **Coût infrastructure :** À déterminer selon usage réel

---

## 🔐 Droits et Permissions

### Droits Accordés
- ✅ **Peut créer :** INVESTOR
- ✅ **Peut gérer :** Contrôle total de la plateforme
- ✅ **Peut consulter :** Tous les niveaux et tous les namespaces
- ✅ **Peut modifier :** Tous les éléments, configuration globale
- ✅ **Accès root :** Instance SurrealDB unique

### Restrictions Hiérarchiques
- ❌ **Ne peut PAS créer directement :** BUSINESS, DEVELOPER, CONTRACTOR (doit passer par auto-affiliation)
- ❌ **Ne peut PAS modifier :** Données client sans autorisation explicite

### Auto-Affiliation (Modèle Filiale)
- **MASTER peut créer :** compte INVESTOR, BUSINESS, DEVELOPER, CONTRACTOR
- **Infrastructure :** table registry_auto_affiliate dans `DB main_{name}`
- **Principe :** Société mère avec ses filiales
- **Respect hiérarchie :** Obligatoire même en auto-affiliation
- **Avantage revenus :** Le MASTER récupère tous les revenus des niveaux auto-affiliés (cascade complète)

### **🔒 Paramètre `ultimate` (Critique)**

```typescript
interface MasterConfig {
  level: 'MASTER';
  ultimate: boolean; // PARAMÈTRE CRITIQUE
  permissions: {
    // Permissions normales MASTER
    create_investor: boolean;
    create_business: boolean;
    create_developer: boolean;
    create_contractor: boolean;
    
    // PERMISSIONS EXCLUSIVES si ultimate=true
    domain_management?: boolean;     // 🚨 CRITIQUE
    infrastructure_access?: boolean; // 🚨 CRITIQUE
    cname_configuration?: boolean;   // 🚨 CRITIQUE
    ssl_administration?: boolean;    // 🚨 CRITIQUE
  };
}
```

### **⚡ Impact `ultimate=true`**

```
🚨 ACCÈS EXCLUSIF INFRASTRUCTURE
├── Gestion domaines et CNAME
├── Configuration SSL automatique
├── Accès module infrastructure
├── Contrôle hébergement complet
└── Audit système global

⛔ SI ultimate=false
├── Aucun accès domaines
├── Aucune configuration CNAME
├── Aucun contrôle infrastructure
├── Fonctions MASTER normales uniquement
└── Dépendant d'un MASTER ultimate
```

### **🛡️ Sécurité Renforcée**

Le paramètre `ultimate` est **LA** protection ultime de l'infrastructure :

```typescript
// Vérification avant TOUTE opération domaine
const checkUltimatePermissions = async (masterId: string) => {
  const master = await getMasterConfig(masterId);
  
  if (master.level !== 'MASTER') {
    throw new Error('ACCÈS REFUSÉ: Niveau MASTER requis');
  }
  
  if (master.ultimate !== true) {
    throw new Error('ACCÈS REFUSÉ: Paramètre ultimate=true requis');
  }
  
  return true; // Autorisé
};
```

---

## 🏗️ Infrastructure Technique

### Configuration SurrealDB Révolutionnaire
- **Instance unique :** Une seule instance SurrealDB pour tous les niveaux (URL à définir)
- **Namespaces séparés :** Chaque niveau dispose de son propre namespace
- **Databases standardisées :** `DB main_{name}` et `DB workspace_{id}` par namespace
- **Coût :** À déterminer selon usage réel
- **Scaling :** Gratuit et infini

### Authentification Logto
- **Tenant unique :** `lyxal_platform` pour TOUS les niveaux
- **Apps dédiées :** Une app par entité dans le tenant MASTER
- **Scopes :** Permissions selon niveau hiérarchique

### APIs Natives
- **Base URL :** `https://api.lyxal.com` (exemple)
- **Authentification :** surrealdb_native_root
- **Architecture :** Une seule instance pour tous les endpoints

---

## 📈 Métriques et Limites

### Quotas et Limitations
- **max_investors :** À définir selon plan
- **max_total_users :** À définir selon capacité
- **storage_limit :** À définir selon besoins
- **provisioning_time :** 4-15 secondes (selon GLOBAL-OVERVIEW)

### KPIs Principaux
- **Nombre d'INVESTORS créés :** À définir
- **Revenus générés :** À définir
- **Taux de croissance :** À définir
- **Satisfaction client :** À définir

---

## 🔄 Workflows Métier

### Processus de Création INVESTOR
1. **Réception commande** - Validation paiement
2. **Provisioning** - Création namespace 
3. **Configuration automatique** - Setup DB main_{name} et APIs
4. **Notification client** - Accès à l'interface
5. **Monitoring** - Surveillance performance et utilisation

### Processus de Support
1. **Support niveau 1** - Instance unique = maintenance simplifiée
2. **Maintenance** - Automatisée
3. **Mises à jour** - Déploiement sur tous les niveaux

---

## 🔍 Cas d'Usage Concrets

### Cas d'Usage 1 : Création INVESTOR
**Contexte :** Nouveau client INVESTOR veut démarrer
**Acteur :** MASTER Admin
**Action :** Provisioning namespace
**Résultat :** Client opérationnel avec namespace dédié

### Cas d'Usage 2 : Scaling 
**Contexte :** INVESTOR veut créer des BUSINESS
**Acteur :** INVESTOR
**Action :** Création dans la même instance SurrealDB
**Résultat :** Scaling sans coût additionnel

### Cas d'Usage 3 : Maintenance Centralisée
**Contexte :** Mise à jour nécessaire
**Acteur :** MASTER
**Action :** Update sur l'instance unique
**Résultat :** Tous les niveaux mis à jour

---

## 🚀 Avantages Compétitifs

1. **Simplicité :** Une seule instance à maintenir
2. **Scalabilité :** Croissance sans coût additionnel
3. **Innovation :** Architecture révolutionnaire unique au marché
4. **Flexibilité :** Modèles économiques adaptés par industrie
5. **Maintenance centralisée :** Mises à jour simultanées

---

## 📚 Références et Liens

### Documentation Associée
- `00-GLOBAL-OVERVIEW.md` - Vue d'ensemble complète
- `01-NIVEAU-INVESTOR.md` - Niveau 1 détaillé
- `99-GLOSSAIRE-TERMINOLOGIE.md` - Terminologie standardisée

### Historique des Modifications
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création template | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives et références inexistantes | Assistant |

---

## 🎉 Conclusion

Le niveau MASTER représente le cœur de l'architecture LyxalSuite. L'instance SurrealDB unique permet une gestion centralisée et un scaling optimisé pour tous les niveaux de la plateforme.