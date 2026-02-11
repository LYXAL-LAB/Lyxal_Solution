# 🚀 LyxalSuite Base Module

**Module fondational IA-native avec SurrealDB révolutionnaire**

## 📋 Aperçu

Le module **lyxal-base** constitue la fondation technologique de LyxalSuite, implémentant une architecture SurrealDB révolutionnaire avec IA intégrée. Ce module fournit 24 entités métier intelligentes et 23 relations graphe optimisées pour l'entreprise moderne.

### ✨ Caractéristiques Principales

- 🧠 **IA-Native** : Intelligence artificielle intégrée à chaque entité
- 📊 **Analytics Temps Réel** : Scoring et métriques automatiques  
- 🎯 **Performance Maximale** : 200+ index optimisés
- 🔗 **Relations Intelligentes** : Graphe relationnel avec IA
- ⚡ **Production Ready** : Architecture scalable et robuste
- 🌐 **Multi-tenant** : Support entreprise intégré

## 📦 Installation

```bash
# Installation du module
npm install @lyxalsuite/lyxal-base

# Ou dans le monorepo LyxalSuite
cd lyxalsuite/lyxal-base
npm install
```

## 🚀 Démarrage Rapide

### 1. Configuration SurrealDB Cloud

**Variables d'environnement requises** (voir section Configuration):

```bash
export SURREAL_URL="wss://your-instance.surreal.cloud/rpc"
export SURREAL_USER="your-username"
export SURREAL_PASS="your-password"
export SURREAL_NS="your-namespace"
export SURREAL_DB="your-workspace-name"
```

### 2. Déployer la Base de Données

```bash
# Setup complet (reset + deploy + verify)
npm run db:setup

# Ou étape par étape
npm run db:deploy          # Déployer le schéma complet
npm run db:verify          # Vérifier l'installation
```

### 3. Vérification

```bash
# Vérification complète avec tous les tests
npm run db:verify:full

# Tests spécifiques
npm run db:verify:ai        # Tests IA uniquement
npm run db:verify:perf      # Tests performance uniquement
```

## 🗂️ Structure des Fichiers

```
lyxal-base/
├── database/                    # 📁 Schémas SurrealDB (.surql)
│   ├── base_structure.surql     # 🏗️ 24 entités IA-native (62KB)
│   ├── base_relations.surql     # 🔗 23 relations graphe (30KB)
│   ├── base_index.surql         # 📊 200+ index optimisés (33KB)
│   ├── base_triggers.surql      # ⚡ Triggers IA automatiques (22KB)
│   └── base_reference_data.surql # 📋 Données de référence (34KB)
├── scripts/                     # 🛠️ Scripts TypeScript
│   ├── deploy-database.ts       # 🚀 Déploiement automatique
│   ├── verify-database.ts       # 🔍 Vérification complète
│   └── reset-database.ts        # 🗑️ Réinitialisation
├── src/                         # 💻 Code TypeScript
└── tests/                       # 🧪 Tests automatisés
```

## 🛠️ Scripts de Gestion

### Déploiement

```bash
# Environnements
npm run db:deploy:dev         # Développement
npm run db:deploy:test        # Test
npm run db:deploy:prod        # Production

# Options avancées
npm run db:deploy -- --reset  # Réinitialiser avant déploiement
npm run db:deploy -- --verbose # Mode verbeux
npm run db:deploy -- --skip-non-critical # Structures critiques uniquement
```

### Vérification

```bash
# Vérifications standards
npm run db:verify:dev         # Environnement développement
npm run db:verify:prod        # Environnement production

# Tests approfondis
npm run db:verify -- --detailed      # Tests détaillés
npm run db:verify -- --performance   # Tests de performance
npm run db:verify -- --ai           # Tests spécifiques IA
npm run db:verify -- --all          # Tous les tests
```

### Réinitialisation

```bash
# ⚠️ ATTENTION: Opérations destructives !
npm run db:reset:dev          # Reset développement
npm run db:reset:test         # Reset test (auto-confirmé)
npm run db:reset:prod         # Reset production (avec backup)

# Options de réinitialisation
npm run db:reset -- --tables-only    # Tables uniquement
npm run db:reset -- --backup         # Avec backup automatique
npm run db:reset -- --force          # Mode forcé
```

## 🏗️ Architecture des Données

### 📊 Entités Principales (24)

| Entité | Description | IA Intégrée |
|--------|-------------|-------------|
| `country` | Pays avec IA géopolitique | ✅ Analytics géopolitiques |
| `currency` | Devises avec IA de change | ✅ Prédictions taux |
| `company` | Sociétés avec IA business | ✅ Scoring entreprise |
| `partner` | Partenaires avec IA CRM | ✅ Profils intelligents |
| `product` | Produits avec IA pricing | ✅ Tarification dynamique |
| `account` | Comptes avec IA financière | ✅ Analytics financières |
| ... | *et 18 autres entités* | ✅ IA spécialisée |

### 🔗 Relations Intelligentes (23)

| Relation | Type | IA Features |
|----------|------|-------------|
| `has_contact` | Partner → Contact | Scoring relationnel |
| `has_address` | Partner → Address | Géolocalisation IA |
| `supplies` | Supply Chain | **IA Révolutionnaire** |
| `product_price` | Product → Price | Tarification dynamique |
| ... | *et 19 autres relations* | Analytics avancées |

### 🎯 Fonctions IA Intégrées

```sql
-- Calcul de qualité des données
SELECT fn::calculate_data_quality(partner_data);

-- Score de confiance IA 
SELECT fn::calculate_ai_confidence(entity, score);

-- Évaluation des risques
SELECT fn::calculate_risk_score(partner, metadata);

-- Génération d'embeddings
SELECT fn::generate_embeddings("texte à analyser");
```

## ⚡ Performance et Optimisation

### 📊 Index Avancés (200+)

- **Index standards** : Recherche rapide sur champs clés
- **Index composites** : Requêtes multi-critères optimisées  
- **Index IA** : Recherche vectorielle et analytics
- **Index géospatiaux** : Géolocalisation haute performance

### 🚀 Métriques de Performance

| Opération | Temps Cible | Index Utilisés |
|-----------|-------------|----------------|
| Recherche simple | < 50ms | Index standards |
| Requête complexe | < 200ms | Index composites |
| Analytics IA | < 100ms | Index vectoriels |
| Relations graphe | < 150ms | Index relationels |

## 🌍 Configuration SurrealDB Cloud

### Variables d'Environnement Requises

⚠️ **IMPORTANT**: Ce module utilise **uniquement** des variables d'environnement pour la configuration SurrealDB Cloud.

```bash
# 🔗 Configuration SurrealDB Cloud (OBLIGATOIRE)
export SURREAL_URL="wss://your-instance.surreal.cloud/rpc"
export SURREAL_USER="your-username"
export SURREAL_PASS="your-password"
export SURREAL_NS="your-namespace"           # Namespace tenant/saas
export SURREAL_DB="your-workspace-name"      # Nom du workspace (pas 'base' !)

# 🧠 Configuration IA (optionnel)
export AI_CONFIDENCE_THRESHOLD=75
export AI_EMBEDDING_DIMENSIONS=1536
export AI_ANALYTICS_ENABLED=true
```

### Exemples de Configuration

```bash
# Configuration Développement
export SURREAL_URL="wss://dev-instance.surreal.cloud/rpc"
export SURREAL_USER="dev-user"
export SURREAL_PASS="dev-password"
export SURREAL_NS="tenant_dev_company"
export SURREAL_DB="workspace_crm"

# Configuration Production  
export SURREAL_URL="wss://prod-instance.surreal.cloud/rpc"
export SURREAL_USER="prod-admin"
export SURREAL_PASS="secure-password"
export SURREAL_NS="tenant_acme_corp"
export SURREAL_DB="workspace_erp"
```

### Architecture Workspace

Le module lyxal-base suit l'architecture LyxalSuite :
- **Namespace** = Tenant/SaaS isolé
- **Database** = Workspace métier spécifique  
- **Tables** = Entités du module lyxal-base

## 🧪 Tests et Validation

### Tests Automatisés

```bash
# Suite de tests complète
npm test

# Tests en mode watch
npm run test:watch

# Tests avec couverture
npm run test:coverage

# Interface UI des tests
npm run test:ui
```

### Validation de Schéma

```bash
# Validation complète du déploiement
npm run db:verify:full

# Tests de performance spécifiques
npm run db:verify -- --performance

# Validation des fonctions IA
npm run db:verify -- --ai
```

## 🔧 Développement et Contributions

### Installation Développement

```bash
# Clone du projet
git clone https://github.com/lyxalsuite/lyxalsuite.git
cd lyxalsuite/lyxal-base

# Installation des dépendances
npm install

# Setup base de données locale
npm run db:setup

# Mode développement avec watch
npm run dev
```

### Scripts de Développement

```bash
# Compilation TypeScript
npm run build

# Vérification de types
npm run type-check

# Linting et formatage
npm run lint
npm run format

# Génération documentation
npm run docs:generate
npm run docs:serve
```

### Structure de Contribution

```
Pull Request → Tests Automatiques → Review → Merge
     ↓              ↓                 ↓        ↓
  Linting     Tests Unitaires    Code Review  Deploy
  Format      Tests E2E          Security     Docs
  Type-Check  Performance        Quality      Release
```

## 📚 Documentation Avancée

### API Documentation

- **Entités** : [docs/entities.md](docs/entities.md)
- **Relations** : [docs/relations.md](docs/relations.md)  
- **Fonctions IA** : [docs/ai-functions.md](docs/ai-functions.md)
- **Performance** : [docs/performance.md](docs/performance.md)

### Guides d'Utilisation

- **Déploiement Production** : [docs/production-deployment.md](docs/production-deployment.md)
- **Optimisation Performance** : [docs/performance-tuning.md](docs/performance-tuning.md)
- **Intégration IA** : [docs/ai-integration.md](docs/ai-integration.md)
- **Troubleshooting** : [docs/troubleshooting.md](docs/troubleshooting.md)

## 🚨 Dépannage

### Problèmes Courants

#### Erreur de Connexion SurrealDB

```bash
# Vérifier que SurrealDB est démarré
npm run start:surreal

# Vérifier la configuration
npm run db:verify -- --detailed
```

#### Problèmes de Performance

```bash
# Vérifier les index
npm run db:verify -- --performance

# Redéployer les index
npm run db:deploy -- --reset
```

#### Erreurs de Déploiement

```bash
# Réinitialiser complètement
npm run db:reset:dev
npm run db:setup

# Vérification post-déploiement
npm run db:verify:full
```

### Support et Assistance

- 🐛 **Issues** : [GitHub Issues](https://github.com/lyxalsuite/lyxalsuite/issues)
- 💬 **Discussions** : [GitHub Discussions](https://github.com/lyxalsuite/lyxalsuite/discussions)
- 📧 **Contact** : support@lyxalsuite.com
- 📚 **Documentation** : [docs.lyxalsuite.com](https://docs.lyxalsuite.com)

## 📊 Statistiques du Module

| Métrique | Valeur |
|----------|--------|
| **Entités IA-Native** | 24 |
| **Relations Graphe** | 23 |
| **Index Optimisés** | 200+ |
| **Fonctions IA** | 15+ |
| **Triggers Automatiques** | 10+ |
| **Taille Schéma Total** | 181 KB |
| **Lignes de Code SQL** | 5,537 |
| **Données de Référence** | 50+ enregistrements |

## 🎯 Roadmap

### Version 1.1 (Q2 2024)

- [ ] **IA Avancée** : Modèles ML intégrés
- [ ] **Analytics Prédictifs** : Prévisions automatiques
- [ ] **API GraphQL** : Interface graphe native
- [ ] **Real-time Sync** : Synchronisation temps réel

### Version 1.2 (Q3 2024)

- [ ] **Multi-tenant Advanced** : Isolation renforcée
- [ ] **Backup Automatique** : Sauvegarde intelligente
- [ ] **Monitoring Intégré** : Observabilité complète
- [ ] **Scaling Horizontal** : Architecture distribuée

## 📄 Licence

Ce projet est sous licence **MIT**. Voir [LICENSE](LICENSE) pour plus de détails.

---

**🚀 LyxalSuite Base Module - La Fondation IA-Native de Votre Enterprise** 

*Développé avec ❤️ par l'équipe LyxalSuite* 