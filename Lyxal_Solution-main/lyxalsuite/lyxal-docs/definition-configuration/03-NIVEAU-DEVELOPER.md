# NIVEAU 3 : DEVELOPER

## 📋 Informations Générales

- **Numéro de niveau :** 3
- **Nom officiel :** DEVELOPER
- **Position hiérarchique :** BUSINESS → **DEVELOPER** → CONTRACTOR
- **Date de création template :** Décembre 2024
- **Version :** 1.1
- **Document de référence :** GLOBAL-OVERVIEW.md

---

## 🎯 Définition et Rôle

### Définition Précise
- **Licence :** Achetée à un BUSINESS
- **Droits :** Créer et gérer des CONTRACTORS uniquement
- **Infrastructure :** Namespace dédié `NS developer_{name}` dans l'instance unique MASTER
- **Revenus :** Vente licences CONTRACTOR + via auto-affiliation peut se créer des comptes CONTRACTOR
- **Provisioning :** 4 secondes (selon GLOBAL-OVERVIEW)
- **Restriction :** Ne peut créer que des CONTRACTORS (niveau final)

### Fonctionnement Hiérarchique
- Un developer peut créer des contractors (niveau final)
- Il dispose d'outils pour créer des clients finaux
- C'est le niveau opérationnel pour les projets concrets

### Auto-Affiliation (Modèle Filiale)
- **DEVELOPER** → compte CONTRACTOR (selon GLOBAL-OVERVIEW)
- **Processus :** Respecter la hiérarchie comme société mère avec filiales
- **Infrastructure :** table registry_auto_affiliate dans `DB main_{name}` parent
- **Provisioning :** 4 secondes pour CONTRACTOR

---

## 💰 Modèle Économique

### Structure Financière
```typescript
interface DeveloperConfig {
  // Identification
  developer_id: string;
  license_type: 'DEVELOPER';
  
  // Modèle économique - Achat/Vente (niveau final)
  economics: {
    payment_to: 'BUSINESS';
    sells_to: 'CONTRACTOR';
    revenue_sources: {
      direct: 'contractor_licenses';         // Vente directe licences CONTRACTOR à des tiers
      auto_affiliate: {                      // Via auto-affiliation (modèle filiale)
        own_contractor_accounts: true;       // Peut se créer des comptes CONTRACTOR
      };
    };
  };
  
  // Revenus DIRECTS des CONTRACTORS uniquement
  revenue_sharing?: {
    from_contractor: {
      percentage: number;
      cascade_enabled: false;  // ❌ Niveau final
    };
  };
}
```

### Flux Financiers
- **Paiement sortant :** Licence vers BUSINESS
- **Revenus entrants :** 
  - Licences CONTRACTOR vendues à des tiers
  - Via auto-affiliation : revenus de ses propres comptes CONTRACTOR créés

---

## 🔐 Droits et Permissions

### Permissions Hiérarchiques
```typescript
permissions: {
  can_create_contractor: true;       // ✅ Seul droit
  can_access_contractor_data: true;  // ✅ Accès complet aux CONTRACTORS créés
  can_create_customers: true;        // ✅ Via CONTRACTORS créés
}
```

### Avantages
- ✅ **Peut** : Créer des CONTRACTORS
- ✅ **Peut** : Gérer complètement ses CONTRACTORS
- ✅ **Peut** : Voir toutes les métriques de ses CONTRACTORS

---

## 🏗️ Infrastructure Technique

### Configuration SurrealDB
```typescript
// Infrastructure dans instance unique MASTER
infrastructure: {
  surrealdb: {
    master_instance: 'lyxal-master.surrealdb.cloud';  // Instance unique MASTER
    namespace: string;         // NS developer_{id} dans instance MASTER
    database: 'main';          // DB main dans son namespace
  };
  logto: {
    master_tenant: 'lyxal_platform';  // Tenant MASTER partagé
    app_credentials: LogtoCredentials;
  };
  apis_natives: {
    enabled: true;
    base_url: 'https://api.lyxal.com/developer/{id}';
    authentication: 'surrealdb_native_scope';
  };
}
```

---

## 📈 Métriques et Limites

### Limites
```typescript
limits: {
  max_contractors_created: 'unlimited';     // Scaling infini selon GLOBAL-OVERVIEW
  provisioning_time: '4 seconds';          // Provisioning DEVELOPER
  contractor_provisioning: '4 seconds';    // Provisioning CONTRACTOR
}
```

### KPIs Principaux
- **Provisioning DEVELOPER :** 4 secondes (selon GLOBAL-OVERVIEW)
- **Provisioning CONTRACTOR :** 4 secondes (selon GLOBAL-OVERVIEW)
- **Nombre de CONTRACTORS créés :** À définir
- **Revenus générés :** À définir

---

## 🔄 Workflows Métier

### Processus de Création CONTRACTOR
1. **Demande création** - Interface DEVELOPER
2. **Validation permissions** - Vérification hiérarchique
3. **Provisioning** - Création namespace en 4 secondes
4. **Configuration automatique** - Setup DB main et APIs
5. **Notification** - Accès immédiat

---

## 🔍 Cas d'Usage Concrets

### Cas d'Usage 1 : Création CONTRACTORS
**Contexte :** DEVELOPER veut créer plusieurs CONTRACTORS
**Acteur :** DEVELOPER Admin
**Action :** Provisioning de namespaces
**Résultat :** Création rapide sans coût additionnel

### Cas d'Usage 2 : Auto-Affiliation
**Contexte :** DEVELOPER veut devenir CONTRACTOR pour tester
**Acteur :** DEVELOPER
**Action :** Auto-affiliation CONTRACTOR
**Résultat :** Compte opérationnel immédiat

### Cas d'Usage 3 : Gestion Complète
**Contexte :** DEVELOPER veut gérer tous ses CONTRACTORS
**Acteur :** DEVELOPER
**Action :** Dashboard de gestion
**Résultat :** Vue complète et contrôle total

---

## 🚀 Avantages Compétitifs DEVELOPER

1. **Provisioning rapide :** 4 secondes selon GLOBAL-OVERVIEW
2. **Scaling gratuit :** Croissance illimitée selon GLOBAL-OVERVIEW
3. **Infrastructure partagée :** Bénéficie de l'instance unique
4. **Contrôle total :** Gestion complète des CONTRACTORS
5. **Time to market :** Déploiement rapide

---

## 📚 Références et Liens

### Documentation Associée
- `00-GLOBAL-OVERVIEW.md` - Vue d'ensemble et métriques
- `02-NIVEAU-BUSINESS.md` - Niveau parent
- `04-NIVEAU-CONTRACTOR.md` - Niveau enfant direct
- `99-GLOSSAIRE-TERMINOLOGIE.md` - Terminologie standardisée

### Historique des Modifications
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création depuis document source | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives, références inexistantes et clarification niveau final | Assistant |

---

## 🎉 Conclusion

Le niveau DEVELOPER bénéficie de l'architecture LyxalSuite avec un provisioning rapide et permet de créer efficacement des CONTRACTORS pour les projets concrets.