# Lyxal Investor Module

Module INVESTOR pour LyxalSuite - Interface principale de gestion des SaaS déployés.

## Vue d'ensemble

Le module `lyxal-investor` fournit l'interface principale pour les INVESTORS qui déploient et gèrent plusieurs instances SaaS de LyxalSuite. Il **réutilise intégralement** le système de monitoring existant de `lyxal-surreal` en mode `INVESTOR_LEVEL` pour offrir une vue consolidée de tous les SaaS.

## Architecture

### Niveau d'accès
- **Niveau**: `INVESTOR_LEVEL`
- **Namespace**: `catalog` (vue globale)
- **Portée**: Tous les SaaS déployés (pas de `saasNamespace` spécifique)

### Structure de l'application
```
lyxal-investor/
├── index.html              # Page HTML principale
├── vite.config.ts          # Configuration Vite
├── src/
│   ├── main.tsx           # Point d'entrée React
│   ├── App.tsx            # Composant App principal
│   └── pages/
│       └── InvestorDashboard.tsx  # Dashboard INVESTOR
└── module.config.json     # Configuration (réutilise lyxal-surreal)
```

## Lancement de l'application

### Installation des dépendances
```bash
cd lyxalsuite/lyxal-investor
npm install
```

### Lancement en mode développement
```bash
npm run dev
```
L'application sera accessible sur `http://localhost:3001`

### Build de production
```bash
npm run build
npm run preview
```

## Composants principaux

#### InvestorDashboard
Interface principale qui réutilise `SurrealMonitoringPage` avec :
- `userLevel="INVESTOR_LEVEL"`
- Vue consolidée de tous les SaaS
- Métriques globales et monitoring en temps réel

## Architecture de base de données

### ✅ Réutilisation des tables existantes (lyxal-surreal)

Le module **ne crée aucune nouvelle table** mais réutilise l'architecture bicéphale existante :

#### Tables INVESTOR_LEVEL (Namespace: `catalog`)
| Table | Description | Source |
|-------|-------------|---------|
| `global_system_metrics` | Métriques système globales de tous les SaaS | lyxal-surreal |
| `global_saas_health` | Santé individuelle de chaque SaaS | lyxal-surreal |
| `cross_saas_analytics` | Analytics comparatives entre SaaS | lyxal-surreal |
| `global_alerts` | Alertes système globales | lyxal-surreal |

#### Fonctions réutilisées
- `fn::get_platform_overview()` : Vue d'ensemble de la plateforme
- `fn::calculate_global_health_score()` : Score de santé global
- `fn::get_cross_saas_comparison()` : Comparaison entre SaaS

## Utilisation

L'application se lance avec un fichier HTML (`index.html`) qui charge l'application React :

1. **HTML** : `index.html` - Page principale avec styles DaisyUI
2. **React** : `src/main.tsx` → `src/App.tsx` → `src/pages/InvestorDashboard.tsx`
3. **Monitoring** : Réutilise `SurrealMonitoringPage` de `lyxalkitui`
4. **Données** : Utilise les tables existantes de `lyxal-surreal`

Le dashboard se connecte automatiquement au namespace `catalog` et affiche :
- Vue d'ensemble de tous les SaaS
- Métriques consolidées en temps réel
- Statut de santé global
- Analytics comparatives
- Actions de maintenance

## Dépendances

- `lyxal-surreal`: Module de base SurrealDB (**tables réutilisées**)
- `lyxalkitui`: Interface utilisateur (pour SurrealMonitoringPage)
- `react`: Framework UI
- `vite`: Build tool et serveur de développement

## Configuration

Le module utilise la configuration définie dans `module.config.json` :
- **Namespace**: `catalog`
- **Tables réutilisées**: `global_system_metrics`, `global_saas_health`, `cross_saas_analytics`, `global_alerts`
- **Fonctions réutilisées**: `get_platform_overview`
- **Source**: `lyxal-surreal`

## Avantages de la réutilisation

✅ **Pas de doublon** : Réutilise l'architecture existante  
✅ **Cohérence** : Même structure que le système de monitoring  
✅ **Maintenance** : Un seul système à maintenir  
✅ **Performance** : Données déjà optimisées  
✅ **Évolutivité** : Bénéficie des améliorations de lyxal-surreal 