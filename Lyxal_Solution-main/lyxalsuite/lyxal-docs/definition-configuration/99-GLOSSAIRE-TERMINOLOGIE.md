# 📚 GLOSSAIRE - Terminologie LyxalSuite

## 📋 Informations Générales

- **Document de référence :** GLOBAL-OVERVIEW.md
- **Date de création :** Décembre 2024
- **Version :** 1.1
- **Statut :** Terminologie standardisée basée sur document source

---

## 🏗️ ARCHITECTURE & INFRASTRUCTURE

### Architecture Instance Unique
- **Définition :** Une seule instance SurrealDB pour TOUS les niveaux hiérarchiques
- **Avantage :** Coût à déterminer selon usage réel
- **Innovation :** Architecture révolutionnaire unique au marché

### GoHighLevel révolutionnaire
- **Définition :** Modèle économique hiérarchique inspiré de GoHighLevel
- **Principe :** Chaque niveau revend au niveau inférieur avec marge
- **Particularité :** Instance unique vs instances multiples traditionnelles

### Instance SurrealDB unique
- **Localisation :** Une seule instance SurrealDB pour tous les niveaux (URL à définir)
- **Organisation :** Namespaces séparés → Databases standardisées
- **Coût :** À déterminer selon usage réel
- **Performance :** Provisioning 4-15 secondes (selon GLOBAL-OVERVIEW)

### Namespace (NS)
- **Définition :** Espace de nommage dédié dans instance SurrealDB
- **MASTER :** `NS master_{name}`
- **INVESTOR :** `NS investor_{name}`
- **BUSINESS :** `NS business_{name}`
- **DEVELOPER :** `NS developer_{name}`
- **CONTRACTOR :** `NS contractor_{name}`
- **Isolation :** Sécurité niveau namespace

### Database (DB)
- **Définition :** Base de données dans un namespace
- **Standardisées :** `DB main_{name}` pour configuration
- **Workspace :** `DB workspace_{id}` pour données métier
- **Organisation :** Chaque namespace dispose de ses databases

### Tables préfixées
- **Définition :** Tables avec préfixe d'identification si nécessaire
- **Usage :** Selon besoins d'organisation des données
- **Avantage :** Organisation claire sans collision

---

## 👥 HIÉRARCHIE & NIVEAUX

### Niveau 0 : MASTER
- **Définition :** Créateur plateforme (équivalent GoHighLevel Corp)
- **Droits :** Contrôle total, création INVESTORS
- **Revenue :** Vente licences INVESTOR exemple 40,000€/an + commissions
- **Infrastructure :** Propriétaire instance unique

### Niveau 1 : INVESTOR
- **Définition :** Licence complète achetée au MASTER
- **Droits :** Développer réseau business directement
- **Revenue :** Vente licences BUSINESS exemple 15,000€ (marge exemple 15,000€)
- **Infrastructure :** Namespace dédié `NS investor_{name}`

### Niveau 2 : BUSINESS
- **Définition :** Licence achetée à l'INVESTOR
- **Droits :** Revendre licences DEVELOPER
- **Revenue :** Vente licences DEVELOPER exemple 5,000€ (marge exemple 5,000€)
- **Infrastructure :** Namespace dédié `NS business_{name}`

### Niveau 3 : DEVELOPER
- **Définition :** Licence achetée au BUSINESS
- **Droits :** Vendre des SaaS prêt à l'emploi pour CONTRACTORS
- **Revenue :** Vente SaaS CONTRACTOR exemple 1,000€ (marge exemple 1,000€)
- **Infrastructure :** Namespace dédié `NS developer_{name}`

### Niveau 4 : CONTRACTOR
- **Définition :** SaaS acheté au DEVELOPER
- **Droits :** Développer réseau clients finaux directement
- **Revenue :** Selon industrie (project-based, subscription, etc.)
- **Infrastructure :** Namespace dédié `NS contractor_{name}`

### Niveau 5 : CUSTOMERS
- **Définition :** Clients du CONTRACTOR
- **Types :** Clients finaux selon industrie
- **Droits :** Utilisation selon rôle et permissions
- **Infrastructure :** Datatable dédié `DB workspace_{id}` dans NS parent

---

## 💰 MODÈLE ÉCONOMIQUE

### Licence
- **Définition :** Droit d'utilisation payé au niveau supérieur
- **INVESTOR :** exemple 40,000€/an au MASTER
- **BUSINESS :** exemple 15,000€ à l'INVESTOR
- **DEVELOPER :** exemple 5,000€ au BUSINESS

### SaaS
- **Définition :** Software as a Service vendu par DEVELOPER
- **Prix :** exemple 1,000€ payé par CONTRACTOR
- **Modalités :** Paiement unique ou annuel (à définir)
- **Maintenance :** Incluse si forfait annuel

### Marge
- **Définition :** Différence entre prix d'achat et prix de vente
- **INVESTOR :** exemple 15,000€ (prix exemple - coût exemple)
- **BUSINESS :** exemple 5,000€ (prix exemple - coût exemple)
- **DEVELOPER :** exemple 1,000€ (prix exemple - coût exemple)
- **Note :** Tous les chiffres sont des exemples à ajuster

### Commission optionnelle
- **Définition :** Pourcentage sur revenues des niveaux inférieurs
- **MASTER :** Peut prendre commission sur tous niveaux
- **INVESTOR :** Peut prendre commission sur BUSINESS créés
- **Principe :** Revenue sharing en cascade

---

## 🔐 DROITS & PERMISSIONS

### Hiérarchie stricte
- **Principe :** Chaque niveau ne peut créer QUE le niveau immédiatement inférieur
- **Exception :** Auto-affiliation (modèle filiale)
- **Interdiction :** Création directe de niveaux non-adjacents

### Auto-affiliation (Modèle Filiale)
- **Définition :** Capacité de se créer un compte au niveau inférieur
- **Principe :** Comme société mère avec ses filiales
- **MASTER :** compte INVESTOR, BUSINESS, DEVELOPER, CONTRACTOR
- **INVESTOR :** compte BUSINESS, DEVELOPER, CONTRACTOR
- **BUSINESS :** compte DEVELOPER, CONTRACTOR
- **DEVELOPER :** compte CONTRACTOR
- **Infrastructure :** table registry_auto_affiliate dans `DB main_{name}` parent

### Permissions STRICTEMENT HIÉRARCHIQUES
- **can_create_business :** Seulement INVESTOR
- **can_create_developer :** Seulement BUSINESS
- **can_create_contractor :** Seulement DEVELOPER
- **can_access_all_levels :** Selon niveau (lecture seule cascade)

---

## 🔧 AUTHENTIFICATION & SÉCURITÉ

### Logto
- **Définition :** Service d'authentification utilisé par LyxalSuite
- **Configuration :** Tenant unique `lyxal_platform` pour TOUS
- **Apps :** Une app par entité dans le tenant MASTER
- **Scopes :** Permissions selon niveau hiérarchique

### Tenant MASTER
- **Nom :** `lyxal_platform`
- **Usage :** Partagé par TOUS les niveaux
- **Avantage :** Gestion centralisée authentification
- **Sécurité :** Isolation par scopes et permissions

### SurrealDB native scope
- **Définition :** Système de permissions natif SurrealDB
- **Usage :** Authentification APIs natives
- **Niveaux :** Root (MASTER), namespace, database, table
- **Sécurité :** Isolation stricte par niveau

---

## 🏢 INTERFACE UTILISATEUR

### Interface interne
- **Définition :** Interface admin/personnel pour gestion interne
- **Gestion :** Via routes et rôles
- **Utilisateurs :** Employés du niveau concerné
- **Fonctionnalités :** Administration, configuration, monitoring

### Interface client
- **Définition :** Interface pour gérer les niveaux inférieurs
- **INVESTOR :** Interface pour gérer BUSINESS
- **BUSINESS :** Interface pour gérer DEVELOPER
- **DEVELOPER :** Interface pour gérer CONTRACTOR
- **Principe :** Interface du niveau supérieur = interface interne du niveau inférieur

### Site promotionnel
- **Définition :** Site web pour promouvoir et vendre services
- **Inspiration :** Comme SurrealDB et Logto proposent
- **Objectif :** Marketing et acquisition clients
- **Chaque niveau :** Dispose de son site promotionnel

---

## 📊 MÉTRIQUES & PERFORMANCE

### Provisioning
- **Définition :** Temps de création/déploiement d'un niveau
- **INVESTOR :** 8 secondes (selon GLOBAL-OVERVIEW)
- **BUSINESS :** 6 secondes (selon GLOBAL-OVERVIEW)
- **DEVELOPER :** 4 secondes (selon GLOBAL-OVERVIEW)
- **CONTRACTOR :** 4 secondes (selon GLOBAL-OVERVIEW)

### Scaling
- **Définition :** Capacité d'augmentation de capacité
- **Coût :** À déterminer selon usage réel
- **Performance :** Amélioration avec optimisation
- **Ressources :** Allocation selon besoins

### Limites
- **max_investors :** à définir selon plan (MASTER)
- **max_business_created :** à définir selon plan (INVESTOR)
- **max_developer_created :** selon plan (BUSINESS)
- **max_contractor_created :** selon plan (DEVELOPER)

---

## 🏭 MODÈLES INDUSTRIE

### BTP (Travaux)
- **Revenue model :** Project-based
- **End user model :** Client direct
- **Payment flow :** Contractor vers client
- **Spécificité :** Projets avec clients directs

### eBook
- **Revenue model :** Subscription ou pay-per-use
- **End user model :** Subscriber ou one-time buyer
- **Payment flow :** End user vers contractor
- **Spécificité :** Contenu numérique, abonnements

### eCommerce
- **Revenue model :** Commission ou subscription
- **End user model :** Customer
- **Payment flow :** Customer vers contractor
- **Spécificité :** Vente en ligne, commissions

### Consulting
- **Revenue model :** Hourly, project ou retainer
- **End user model :** Client
- **Payment flow :** Client vers contractor
- **Spécificité :** Services conseil, facturation flexible

---

## 🔄 WORKFLOW & PROCESSUS

### Maintenance/MJ (Mise à Jour)
- **Définition :** Maintenance et mise à jour du système
- **Inclusion :** Dans forfait si paiement annuel
- **Alternative :** Redevance annuelle si paiement unique
- **Responsabilité :** Niveau supérieur vers niveau inférieur

### Revenue sharing
- **Définition :** Partage des revenus en cascade
- **from_business :** Revenue direct des BUSINESS créés
- **cascade_enabled :** Inclut cascade indirecte
- **Optionnel :** Selon configuration niveau

### Billing model
- **included :** Inclus dans abonnement CONTRACTOR
- **per_seat :** Facturation par utilisateur
- **per_usage :** Facturation à l'usage
- **Flexible :** Selon industrie et besoins

---

## 📈 MÉTRIQUES ÉCONOMIQUES

### Coût fixe
- **Infrastructure :** À déterminer selon usage réel
- **Avantage :** Scaling optimisé selon GLOBAL-OVERVIEW

### Time to market
- **Provisioning :** 4-15 secondes (selon GLOBAL-OVERVIEW)
- **Déploiement :** Optimisé
- **Avantage concurrentiel :** À valider en production

### Operational overhead
- **Maintenance :** Instance unique vs multiples
- **Complexité :** Simplifiée
- **Resource utilization :** À optimiser selon usage

---

## 📚 RÉFÉRENCES

### Document source
- **GLOBAL-OVERVIEW.md :** Document fondamental définissant l'architecture
- **Statut :** Référence pour l'implémentation
- **Version :** 1.1 après nettoyage

### Historique
| Date | Version | Modifications | Auteur |
|------|---------|---------------|--------|
| Décembre 2024 | 1.0 | Création glossaire depuis document source | Assistant |
| Décembre 2024 | 1.1 | Nettoyage données fictives et références inexistantes | Assistant |

---

## ⚠️ NOTES IMPORTANTES

### Transparence sur les données
- **Données source :** Issues du document GLOBAL-OVERVIEW.md
- **Exemples :** Chiffres économiques sont illustratifs
- **À définir :** Nombreux éléments nécessitent spécification réelle

### Corrections apportées
- **Architecture :** Basée sur GLOBAL-OVERVIEW
- **Terminologie :** Standardisée et cohérente
- **Références :** Nettoyage des références inexistantes
- **Cohérence :** Alignement avec données réelles du GLOBAL-OVERVIEW

Ce glossaire reflète la terminologie nettoyée et cohérente basée sur GLOBAL-OVERVIEW. 