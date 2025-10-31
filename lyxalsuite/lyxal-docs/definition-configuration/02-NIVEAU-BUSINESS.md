# NIVEAU 2 : BUSINESS

## 📋 Informations Générales

- **Numéro de niveau :** 2
- **Nom officiel :** BUSINESS
- **Position hiérarchique :** INVESTOR → **BUSINESS** → DEVELOPER
- **Date de création template :** Décembre 2024
- **Version :** 1.1
- **Document de référence :** GLOBAL-OVERVIEW.md

---

## 🎯 Définition et Rôle

### Définition Précise
- **Licence :** Achetée à un INVESTOR
- **Droits :** Créer et gérer des DEVELOPERS uniquement
- **Infrastructure :** Namespace dédié `NS business_{name}` dans l'instance unique MASTER
- **Revenus :** Vente licences DEVELOPER + via auto-affiliation peut se créer des comptes DEVELOPER et CONTRACTOR
- **Provisioning :** 6 secondes (selon GLOBAL-OVERVIEW)
- **Restriction :** Ne peut pas créer directement des CONTRACTORS (doit passer par DEVELOPERS)

### Fonctionnement Hiérarchique
- Un business ne peut contenir que des clients developer et aucun d'un niveau inférieur
- si un business voudrait développer des clients contractor alors il devra se créer son propre compte client developer rattaché à son niveau business
- si un business voudrait développer des clients finaux alors il devra se créer son propre compte client contractor rattaché à son niveau developer

### Auto-Affiliation (Modèle Filiale)
- **BUSINESS** → compte DEVELOPER, compte CONTRACTOR (selon GLOBAL-OVERVIEW)
- **Processus :** Respecter la hiérarchie comme société mère avec filiales
- **Infrastructure :** table registry_auto_affiliate dans `DB main_{name}` parent
- **Provisioning :** 4 secondes pour DEVELOPER, 4 secondes pour CONTRACTOR

---

## 💰 Modèle Économique

### Structure Financière
```typescript
interface BusinessConfig {
  // Identification
  business_id: string;
  license_type: 'BUSINESS';
  
  // Modèle économique - Achat/Vente + Auto-affiliation
  economics: {
    payment_to: 'INVESTOR';
    sells_to: 'DEVELOPER';
    revenue_sources: {
      direct: 'developer_licenses';          // Vente directe licences DEVELOPER
      auto_affiliate: {                      // Via auto-affiliation (modèle filiale)
        own_developer_accounts: true;        // Peut se créer des comptes DEVELOPER
        own_contractor_accounts: true;       // Peut se créer des comptes CONTRACTOR
      };
    };
  };
  
  // Revenus DIRECTS uniquement des DEVELOPERS
  revenue_sharing?: {
    from_developer: {
      percentage: number;
      cascade_enabled: boolean;  // ✅ Peut inclure cascade CONTRACTOR
    };
  };
}
```

### Flux Financiers
- **Paiement sortant :** Licence vers INVESTOR
- **Revenus entrants :** 
  - Licences DEVELOPER vendues à des tiers
  - Via auto-affiliation : revenus de ses propres comptes DEVELOPER et CONTRACTOR créés

---

## 🔐 Droits et Permissions

### Permissions Hiérarchiques
```typescript
permissions: {
  can_create_developer: true;       // ✅ Seul droit direct
  can_create_contractor: false;     // ❌ Via DEVELOPER seulement
  can_access_developer_data: true;  // ✅ Accès aux DEVELOPERS créés
  can_view_contractor_cascade: true; // ✅ Vue lecture seule CONTRACTORS indirects
}
```

### Restrictions
- ❌ **Ne peut PAS** : Créer directement des CONTRACTORS
- ❌ **Ne peut PAS** : Modifier les données des CONTRACTORS indirects
- ✅ **Peut** : Voir les métriques cascade de tous les CONTRACTORS créés par ses DEVELOPERS

---

## 🏗️ Infrastructure Technique

### Configuration SurrealDB
```typescript
// Infrastructure dans instance unique MASTER
infrastructure: {
  surrealdb: {
    master_instance: 'lyxal-master.surrealdb.cloud';  // Instance unique MASTER
    namespace: string;         // NS business_{id} dans instance MASTER
    database: 'main';          // DB main dans son namespace
  };
  logto: {
    master_tenant: 'lyxal_platform';  // Tenant MASTER partagé
    app_credentials: LogtoCredentials;
  };
  apis_natives: {
    enabled: true;
    base_url: 'https://api.lyxal.com/business/{id}';
    authentication: 'surrealdb_native_scope';
  };
}
```

---

## 📈 Métriques et Limites

### Limites
```typescript
limits: {
  max_developers_created: 'unlimited';      // Scaling infini selon GLOBAL-OVERVIEW
  max_contractors_indirect: 'unlimited';    // Via DEVELOPERS uniquement
  provisioning_time: '6 seconds';          // Provisioning BUSINESS
  developer_provisioning: '4 seconds';     // Provisioning DEVELOPER
}
```

### KPIs Principaux
- **Provisioning BUSINESS :** 6 secondes (selon GLOBAL-OVERVIEW)
- **Provisioning DEVELOPER :** 4 secondes (selon GLOBAL-OVERVIEW)
- **Nombre de DEVELOPERS créés :** À définir
- **Revenus générés :** À définir

---

## 🔄 Workflows Métier

### Processus de Création DEVELOPER
1. **Demande création** - Interface BUSINESS
2. **Validation permissions** - Vérification hiérarchique
3. **Provisioning** - Création namespace en 4 secondes
4. **Configuration automatique** - Setup DB main et APIs
5. **Notification** - Accès immédiat

---

## 🔍 Cas d'Usage Concrets

### Cas d'Usage 1 : Création DEVELOPERS
**Contexte :** BUSINESS veut créer plusieurs DEVELOPERS
**Acteur :** BUSINESS Admin
**Action :** Provisioning de namespaces
**Résultat :** Création rapide sans coût additionnel

### Cas d'Usage 2 : Auto-Affiliation
**Contexte :** BUSINESS veut devenir CONTRACTOR pour tester
**Acteur :** BUSINESS
**Action :** Auto-affiliation DEVELOPER→CONTRACTOR
**Résultat :** Compte opérationnel en respectant la hiérarchie

### Cas d'Usage 3 : Vue Cascade
**Contexte :** BUSINESS veut voir tous les CONTRACTORS indirects
**Acteur :** BUSINESS
**Action :** Consultation dashboard cascade
**Résultat :** Vue temps réel de tous les CONTRACTORS créés par ses DEVELOPERS

---

## 🚀 Avantages Compétitifs BUSINESS

1. **Provisioning rapide :** 6 secondes selon GLOBAL-OVERVIEW
2. **Scaling gratuit :** Croissance illimitée selon GLOBAL-OVERVIEW
3. **Infrastructure partagée :** Bénéficie de l'instance unique
4. **Vue cascade :** Visibilité complète sur niveaux inférieurs
5. **Time to market :** Déploiement rapide

---

## 📚 Références et Liens

### Documentation Associée
- `00-GLOBAL-OVERVIEW.md` - Vue d'ensemble et métriques
- `01-NIVEAU-INVESTOR.md` - Niveau parent
- `03-NIVEAU-DEVELOPER.md` - Niveau enfant direct
- `99-GLOSSAIRE-TERMINOLOGIE.md` - Terminologie standardisée

### Historique des Modifications
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création depuis document source | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives, références inexistantes et ajout auto-affiliation | Assistant |

---

## 🎉 Conclusion

Le niveau BUSINESS bénéficie de l'architecture LyxalSuite avec un provisioning rapide et permet de développer efficacement un réseau de DEVELOPERS.