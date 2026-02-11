# NIVEAU 4 : CONTRACTOR

## 📋 Informations Générales

- **Numéro de niveau :** 4
- **Nom officiel :** CONTRACTOR
- **Position hiérarchique :** DEVELOPER → **CONTRACTOR** → CUSTOMERS
- **Date de création template :** Décembre 2024
- **Version :** 1.1
- **Document de référence :** GLOBAL-OVERVIEW.md

---

## 🎯 Définition et Rôle

### Définition Précise
- **Licence :** Achetée à un DEVELOPER
- **Droits :** Créer et gérer des clients finaux (CUSTOMERS) uniquement
- **Infrastructure :** Namespace dédié `NS contractor_{name}` dans l'instance unique MASTER
- **Revenus :** Revenus depuis clients finaux créés (niveau opérationnel final - pas d'auto-affiliation)
- **Provisioning :** 4 secondes (selon GLOBAL-OVERVIEW)
- **Niveau final :** Création de clients finaux uniquement

### Fonctionnement Opérationnel
- Un contractor créé des clients finaux (CUSTOMERS) selon GLOBAL-OVERVIEW
- Il dispose de tous les outils pour gérer ses clients
- C'est le niveau opérationnel direct avec les utilisateurs finaux

### Modèles Économiques par Industrie
Selon GLOBAL-OVERVIEW, les modèles économiques varient par industrie :
- **BTP :** Gestion projets et devis
- **eBook :** Création et vente de contenu
- **eCommerce :** Boutiques en ligne
- **Consulting :** Gestion clients et facturation

---

## 💰 Modèle Économique

### Structure Financière
```typescript
interface ContractorConfig {
  // Identification
  contractor_id: string;
  license_type: 'CONTRACTOR';
  industry_type: 'BTP' | 'eBook' | 'eCommerce' | 'Consulting' | 'Other';
  
  // Modèle économique - Achat/Utilisation (niveau opérationnel final)
  economics: {
    payment_to: 'DEVELOPER';
    serves: 'CUSTOMERS';
    revenue_model: 'customer_subscriptions' | 'project_based' | 'commission';
    revenue_sources: {
      direct: 'customer_revenues';           // Revenus directs des CUSTOMERS
      auto_affiliate: null;                  // ❌ Niveau final - pas d'auto-affiliation
    };
  };
  
  // Flux revenus selon industrie
  revenue_details: {
    customer_subscriptions?: 'recurring_model';
    project_fees?: 'project_based_model';
    commission_rates?: 'commission_model';
  };
}
```

### Flux Financiers
- **Paiement sortant :** Licence vers DEVELOPER
- **Revenus entrants :** Revenus directs des CUSTOMERS (selon modèle économique choisi par industrie)
- **Auto-affiliation :** ❌ Non applicable (niveau opérationnel final)

---

## 🔐 Droits et Permissions

### Permissions Finales
```typescript
permissions: {
  can_create_customers: true;        // ✅ Création clients finaux
  can_manage_customers: true;        // ✅ Gestion complète
  can_access_all_tools: true;        // ✅ Accès tous outils SaaS
  can_customize_interface: true;     // ✅ Personnalisation interface
}
```

### Avantages Complets
- ✅ **Peut** : Créer autant de clients finaux que nécessaire
- ✅ **Peut** : Personnaliser complètement son interface
- ✅ **Peut** : Utiliser tous les modules disponibles
- ✅ **Peut** : Gérer sa facturation et ses revenus

---

## 🏗️ Infrastructure Technique

### Configuration SurrealDB
```typescript
// Infrastructure dans instance unique MASTER
infrastructure: {
  surrealdb: {
    master_instance: 'lyxal-master.surrealdb.cloud';  // Instance unique MASTER
    namespace: string;         // NS contractor_{id} dans instance MASTER
    database: 'main';          // DB main dans son namespace
  };
  logto: {
    master_tenant: 'lyxal_platform';  // Tenant MASTER partagé
    app_credentials: LogtoCredentials;
  };
  apis_natives: {
    enabled: true;
    base_url: 'https://api.lyxal.com/contractor/{id}';
    authentication: 'surrealdb_native_scope';
  };
}
```

---

## 📈 Métriques et Limites

### Limites
```typescript
limits: {
  max_customers: 'unlimited';              // Scaling infini selon GLOBAL-OVERVIEW
  provisioning_time: '4 seconds';          // Provisioning CONTRACTOR
  modules_available: 'all';                 // Accès tous modules
  customization_level: 'full';             // Personnalisation complète
}
```

### KPIs Principaux
- **Provisioning CONTRACTOR :** 4 secondes (selon GLOBAL-OVERVIEW)
- **Nombre de clients finaux :** À définir
- **Revenus générés :** À définir
- **Taux de satisfaction :** À définir

---

## 🔄 Workflows Métier

### Processus de Création Client Final
1. **Demande création** - Interface CONTRACTOR
2. **Configuration client** - Paramétrage spécifique
3. **Provisioning** - Création accès immédiat
4. **Formation/Onboarding** - Accompagnement client
5. **Suivi performance** - Monitoring utilisation

---

## 🔍 Cas d'Usage Concrets

### Cas d'Usage 1 : Scaling Clients
**Contexte :** CONTRACTOR veut créer de nombreux clients finaux
**Acteur :** CONTRACTOR Admin
**Action :** Création en masse
**Résultat :** Scaling sans coût additionnel

### Cas d'Usage 2 : Personnalisation
**Contexte :** CONTRACTOR veut adapter l'interface à son industrie
**Acteur :** CONTRACTOR
**Action :** Customisation interface et workflows
**Résultat :** Solution sur-mesure pour ses clients

### Cas d'Usage 3 : Multi-Industrie
**Contexte :** CONTRACTOR gère plusieurs types de clients
**Acteur :** CONTRACTOR
**Action :** Configuration de modèles économiques différents
**Résultat :** Flexibilité maximale selon les besoins

---

## 🚀 Avantages Compétitifs CONTRACTOR

1. **Provisioning rapide :** 4 secondes selon GLOBAL-OVERVIEW
2. **Scaling illimité :** Croissance sans contraintes selon GLOBAL-OVERVIEW
3. **Infrastructure optimisée :** Bénéficie de l'instance unique
4. **Personnalisation complète :** Adaptation à tous les besoins
5. **Tous les modules :** Accès à l'ensemble des fonctionnalités

---

## 📚 Références et Liens

### Documentation Associée
- `00-GLOBAL-OVERVIEW.md` - Vue d'ensemble et métriques
- `03-NIVEAU-DEVELOPER.md` - Niveau parent
- `05-NIVEAU-CUSTOMERS.md` - Niveau enfant (clients finaux)
- `99-GLOSSAIRE-TERMINOLOGIE.md` - Terminologie standardisée

### Historique des Modifications
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création depuis document source | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives, références inexistantes et clarification niveau opérationnel | Assistant |

---

## 🎉 Conclusion

Le niveau CONTRACTOR représente le niveau opérationnel final avec accès à tous les outils et modules pour créer et gérer efficacement des clients finaux selon différents modèles économiques. 