# NIVEAU 1 : INVESTOR

## 📋 Informations Générales

- **Numéro de niveau :** 1
- **Nom officiel :** INVESTOR
- **Position hiérarchique :** MASTER → **INVESTOR** → BUSINESS
- **Date de création template :** Décembre 2024
- **Version :** 1.1
- **Document de référence :** GLOBAL-OVERVIEW.md

---

## 🎯 Définition et Rôle

### Définition Précise
- **Licence complète** : Achetée au MASTER
- **Droits** : Développer un réseau de business directement, et indirectement développer un réseau de developer, un réseau de contractor, et utiliser en tant que contractor les différentes activités du saas
- **Infrastructure** : Namespace dédié `NS investor_{name}` dans l'instance unique MASTER
- **Maintenance/MJ** : Maintenance et mise à jour incluse dans le forfait
- **Provisioning** : 8 secondes (selon GLOBAL-OVERVIEW)

### Fonctionnement Hiérarchique
- Un investor ne peut contenir que des clients business et aucun d'un niveau inférieur
- si un investor voudrait développer des clients developer alors il devra se créer son propre compte client business rattaché à son niveau investor
- si un investor voudrait développer des clients contractor alors il devra se créer son propre compte client developer rattaché à son niveau business
- si un investor voudrait développer des clients finaux alors il devra se créer son propre compte client contractor rattaché à son niveau developer

### Infrastructure SurrealDB
- Lors de la création d'un investor, un namespace dédié est créé dans l'instance unique MASTER (NS investor_{id}), avec database main pour la configuration
- **Architecture unique** : Une seule instance SurrealDB pour TOUS les niveaux
- **Provisioning** : 8 secondes selon GLOBAL-OVERVIEW

### Interface Utilisateur
- L'investor dispose de son propre saas de fonctionnement avec une interface utilisateur de type interne(admin, personnel etc) géré via route et rôle
- une interface client de type business
- un système d'authentification utilisant logto et sa puissance
- et il doit également avoir un site qui permet de promouvoir vendre ses services

---

## 💰 Modèle Économique

### Structure Financière
```typescript
interface InvestorConfig {
  // Identification
  investor_id: string;
  license_type: 'FULL_INVESTOR';
  
  // Modèle économique - Achat/Vente + Auto-affiliation
  economics: {
    payment_to: 'MASTER';
    sells_to: 'BUSINESS';
    revenue_sources: {
      direct: 'business_licenses';           // Vente directe licences BUSINESS
      auto_affiliate: {                      // Via auto-affiliation (modèle filiale)
        own_business_accounts: true;         // Peut se créer des comptes BUSINESS
        own_developer_accounts: true;        // Peut se créer des comptes DEVELOPER  
        own_contractor_accounts: true;       // Peut se créer des comptes CONTRACTOR
      };
    };
  };
  
  // Revenus DIRECTS uniquement
  revenue_sharing?: {
    from_business: {
      percentage: number;        // ✅ Revenue direct des BUSINESS créés
      cascade_enabled: boolean;  // ✅ Peut inclure cascade indirecte
    };
  };
}
```

### Flux Financiers
- **Paiement sortant :** Licence vers MASTER
- **Revenus entrants :** 
  - Licences BUSINESS vendues à des tiers
  - Via auto-affiliation : revenus de ses propres comptes BUSINESS, DEVELOPER, CONTRACTOR créés

---

## 🔐 Droits et Permissions

### Droits et permissions STRICTEMENT HIÉRARCHIQUES
```typescript
permissions: {
  can_create_business: true;        // ✅ Seul droit direct
  can_create_developer: false;      // ❌ Via BUSINESS seulement
  can_create_contractor: false;     // ❌ Via DEVELOPER seulement
  can_access_all_levels: true;      // ✅ Lecture seule cascade
}
```

### Auto-Affiliation (Modèle Filiale)
- **Peut se créer un compte :** BUSINESS (comme filiale)
- **Processus :** Respecter la hiérarchie
- **Hiérarchie maintenue :** Oui
- **Provisioning filiale :** 6 secondes pour BUSINESS (selon GLOBAL-OVERVIEW)
- **Avantage revenus :** L'INVESTOR peut se créer ses propres comptes BUSINESS, DEVELOPER, CONTRACTOR pour développer directement

---

## 🏗️ Infrastructure Technique

### Configuration SurrealDB
```typescript
// Infrastructure dans instance unique MASTER
infrastructure: {
  surrealdb: {
    master_instance: 'lyxal-master.surrealdb.cloud';  // Instance unique MASTER
    namespace: string;         // NS investor_{id} dans instance MASTER
    database: 'main';          // DB main dans son namespace
  };
  logto: {
    master_tenant: 'lyxal_platform';  // Tenant MASTER partagé
    app_credentials: LogtoCredentials;
  };
  apis_natives: {
    enabled: true;
    base_url: 'https://api.lyxal.com/investor/{id}';
    authentication: 'surrealdb_native_scope';
  };
}
```

---

## 📈 Métriques et Limites

### Limites avec scaling infini
```typescript
limits: {
  max_business_created: 'unlimited';    // Scaling infini selon GLOBAL-OVERVIEW
  max_developer_indirect: 'unlimited';  // Via BUSINESS uniquement  
  max_contractor_indirect: 'unlimited'; // Via DEVELOPER uniquement
  provisioning_time: '8 seconds';      // Provisioning INVESTOR
  business_provisioning: '6 seconds';  // Provisioning BUSINESS
}
```

### KPIs Principaux
- **Provisioning INVESTOR :** 8 secondes (selon GLOBAL-OVERVIEW)
- **Provisioning BUSINESS :** 6 secondes (selon GLOBAL-OVERVIEW)
- **Nombre de BUSINESS créés :** À définir
- **Revenus générés :** À définir

---

## 🔄 Workflows Métier

### Processus de Création BUSINESS
1. **Demande création** - Interface INVESTOR
2. **Validation hiérarchique** - Vérification permissions
3. **Provisioning** - Création namespace en 6 secondes
4. **Configuration automatique** - Setup DB main et APIs
5. **Notification** - Accès immédiat

---

## 🔍 Cas d'Usage Concrets

### Cas d'Usage 1 : Scaling
**Contexte :** INVESTOR veut créer plusieurs BUSINESS
**Acteur :** INVESTOR Admin  
**Action :** Provisioning de namespaces
**Résultat :** Création rapide sans coût additionnel

### Cas d'Usage 2 : Auto-Affiliation
**Contexte :** INVESTOR veut devenir CONTRACTOR pour tester
**Acteur :** INVESTOR
**Action :** Auto-affiliation BUSINESS→DEVELOPER→CONTRACTOR
**Résultat :** Compte opérationnel en respectant la hiérarchie

### Cas d'Usage 3 : Vue Hiérarchique
**Contexte :** INVESTOR veut voir tous ses niveaux indirects
**Acteur :** INVESTOR
**Action :** Consultation dashboard hiérarchique
**Résultat :** Vue temps réel de tous les DEVELOPER/CONTRACTOR créés indirectement

---

## 🚀 Avantages Compétitifs INVESTOR

1. **Provisioning rapide :** 8 secondes selon GLOBAL-OVERVIEW
2. **Scaling gratuit :** Croissance illimitée selon GLOBAL-OVERVIEW
3. **Infrastructure partagée :** Bénéficie de l'instance unique
4. **Vue hiérarchique complète :** Visibilité tous niveaux
5. **Time to market :** Déploiement rapide

---

## 📚 Références et Liens

### Documentation Associée
- `00-GLOBAL-OVERVIEW.md` - Vue d'ensemble et métriques
- `02-NIVEAU-BUSINESS.md` - Niveau enfant direct
- `99-GLOSSAIRE-TERMINOLOGIE.md` - Terminologie standardisée

### Historique des Modifications
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création depuis document source | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives, références inexistantes et ajout auto-affiliation | Assistant |

---

## 🎉 Conclusion

Le niveau INVESTOR bénéficie de l'architecture LyxalSuite avec un provisioning rapide et un scaling optimisé, permettant de développer leur réseau efficacement.