# NIVEAU 5 : CUSTOMERS

## 📋 Informations Générales

- **Numéro de niveau :** 5
- **Nom officiel :** CUSTOMERS
- **Position hiérarchique :** CONTRACTOR → **CUSTOMERS** (niveau final)
- **Date de création template :** Décembre 2024
- **Version :** 1.1
- **Document de référence :** GLOBAL-OVERVIEW.md

---

## 🎯 Définition et Rôle

### Définition Précise
- **Statut :** Clients finaux utilisant les SaaS créés par les CONTRACTORS
- **Accès :** Utilisation des applications et services selon le plan souscrit
- **Infrastructure :** Accès via l'instance unique MASTER
- **Paiement :** Vers le CONTRACTOR qui les a créés
- **Limitations :** Utilisation uniquement (pas de création de niveaux inférieurs)

### Fonctionnement Utilisateur Final
- Les CUSTOMERS utilisent les SaaS développés par les CONTRACTORS
- Ils bénéficient de l'infrastructure optimisée de LyxalSuite
- Ils n'ont pas accès aux fonctions de création d'autres utilisateurs
- Leur expérience dépend de la configuration de leur CONTRACTOR

---

## 💰 Modèle Économique

### Structure Financière
```typescript
interface CustomerConfig {
  // Identification
  customer_id: string;
  contractor_id: string;        // CONTRACTOR qui les gère
  subscription_plan: string;    // Plan souscrit
  
  // Modèle économique - Utilisation (selon CONTRACTOR)
  economics: {
    subscription_fee: number;    // Montant payé au CONTRACTOR
    payment_to: 'CONTRACTOR';
    plan_features: string[];     // Fonctionnalités incluses
    usage_limits?: object;       // Limites d'utilisation
  };
}
```

### Flux Financiers
- **Paiement sortant :** Abonnement vers CONTRACTOR
- **Services reçus :** Accès aux fonctionnalités selon plan souscrit

---

## 🔐 Droits et Permissions

### Permissions Utilisateur Final
```typescript
permissions: {
  can_use_saas_features: true;      // ✅ Utilisation des fonctionnalités
  can_manage_own_data: true;        // ✅ Gestion de ses propres données
  can_customize_profile: true;      // ✅ Personnalisation de profil
  can_create_lower_levels: false;   // ❌ Niveau final
}
```

### Restrictions
- ❌ **Ne peut PAS** : Créer d'autres utilisateurs
- ❌ **Ne peut PAS** : Accéder aux fonctions administratives
- ✅ **Peut** : Utiliser toutes les fonctionnalités de son plan
- ✅ **Peut** : Gérer ses données et son profil

---

## 🏗️ Infrastructure Technique

### Configuration d'Accès
```typescript
// Accès via l'instance unique MASTER
access_config: {
  surrealdb: {
    master_instance: 'lyxal-master.surrealdb.cloud';  // Instance unique MASTER
    contractor_namespace: string;  // NS contractor_{id}
    user_scope: 'customer';        // Scope utilisateur final
  };
  logto: {
    master_tenant: 'lyxal_platform';  // Tenant MASTER partagé
    app_access: LogtoUserCredentials;
  };
  apis_access: {
    base_url: 'https://api.lyxal.com/app/{contractor_id}';
    authentication: 'customer_scope';
  };
}
```

---

## 📈 Métriques et Limites

### Limites d'Utilisation
```typescript
limits: {
  features_available: 'according_to_plan';     // Selon plan souscrit
  data_storage: 'according_to_plan';           // Selon plan souscrit
  api_calls: 'according_to_plan';              // Selon plan souscrit
  customization_level: 'user_profile_only';    // Profil uniquement
}
```

### KPIs Utilisateur
- **Satisfaction utilisateur :** À définir
- **Utilisation des fonctionnalités :** À définir
- **Temps de réponse :** Optimisé par l'architecture unique
- **Disponibilité :** Haute disponibilité grâce à l'infrastructure partagée

---

## 🔄 Workflows Utilisateur

### Processus d'Onboarding
1. **Invitation CONTRACTOR** - Réception accès
2. **Création compte** - Configuration profil
3. **Formation/Tutorial** - Découverte fonctionnalités
4. **Utilisation régulière** - Activité selon besoins
5. **Support** - Assistance via CONTRACTOR

---

## 🔍 Cas d'Usage Concrets

### Cas d'Usage 1 : Utilisation SaaS
**Contexte :** CUSTOMER utilise quotidiennement le SaaS
**Acteur :** CUSTOMER
**Action :** Accès aux fonctionnalités selon son plan
**Résultat :** Productivité optimisée

### Cas d'Usage 2 : Personnalisation Profil
**Contexte :** CUSTOMER veut adapter son espace de travail
**Acteur :** CUSTOMER
**Action :** Configuration profil et préférences
**Résultat :** Expérience personnalisée

### Cas d'Usage 3 : Support
**Contexte :** CUSTOMER a besoin d'aide
**Acteur :** CUSTOMER
**Action :** Contact du support via CONTRACTOR
**Résultat :** Résolution rapide grâce à l'architecture centralisée

---

## 🚀 Avantages pour CUSTOMERS

1. **Performance optimisée :** Bénéficie de l'infrastructure unique
2. **Coût réduit :** Économies répercutées par les CONTRACTORS
3. **Stabilité :** Architecture centralisée et maintenue
4. **Évolutions continues :** Mises à jour automatiques
5. **Support efficace :** Maintenance centralisée

---

## 📚 Références et Liens

### Documentation Associée
- `00-GLOBAL-OVERVIEW.md` - Vue d'ensemble de l'architecture
- `04-NIVEAU-CONTRACTOR.md` - Niveau parent
- `99-GLOSSAIRE-TERMINOLOGIE.md` - Terminologie standardisée

### Historique des Modifications
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création depuis document source | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives et références inexistantes | Assistant |

---

## 🎉 Conclusion

Les CUSTOMERS représentent les bénéficiaires finaux de l'architecture LyxalSuite, profitant d'une infrastructure optimisée et d'une expérience utilisateur de qualité grâce à la centralisation et aux économies d'échelle. 