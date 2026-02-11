# 📊 Dashboard Multi-Niveaux LyxalKitUI

Dashboard avec 3 niveaux d'accès : **Investor**, **Developer**, et **Contractor**. Chaque niveau offre une vue adaptée aux besoins spécifiques de l'utilisateur.

## 🎯 Vue d'ensemble

Le `LevelDashboard` est un composant React qui permet d'afficher différents tableaux de bord selon le niveau d'accès de l'utilisateur :

- **🏢 Investor** : Vue globale de la plateforme, métriques business, analytics
- **👨‍💻 Developer** : Gestion des SaaS, workspaces, modules, outils de développement
- **🔧 Contractor** : Projets assignés, tâches, planning, outils spécifiques

## 🚀 Utilisation rapide

```tsx
import { LevelDashboard } from '@lyxal/ui-kit';

function App() {
  return (
    <LevelDashboard
      defaultLevel="developer"
      onLevelChange={(level) => console.log('Niveau changé:', level)}
    />
  );
}
```

## 📋 API du composant

### LevelDashboard

```tsx
interface LevelDashboardProps {
  className?: string;
  defaultLevel?: DashboardLevel;
  onLevelChange?: (level: DashboardLevel) => void;
}

type DashboardLevel = 'investor' | 'developer' | 'contractor';
```

### Props

| Prop | Type | Défaut | Description |
|------|------|--------|-------------|
| `className` | `string` | `''` | Classes CSS personnalisées |
| `defaultLevel` | `DashboardLevel` | `'developer'` | Niveau affiché par défaut |
| `onLevelChange` | `(level) => void` | - | Callback lors du changement de niveau |

## 🏗️ Structure des composants

```
dashboard/
├── LevelDashboard.tsx          # Composant principal
├── LevelDashboard.css          # Styles personnalisés
├── DashboardExample.tsx        # Exemple d'utilisation
├── components/
│   ├── DashboardHeader.tsx     # En-tête avec titre et indicateur de niveau
│   └── LevelSelector.tsx       # Sélecteur de niveau
├── sections/
│   ├── InvestorDashboard.tsx   # Dashboard niveau investisseur
│   ├── DeveloperDashboard.tsx  # Dashboard niveau développeur
│   └── ContractorDashboard.tsx # Dashboard niveau contractant
└── utils/
    └── [futurs utilitaires]
```

## 🎨 Niveaux disponibles

### 💼 Niveau Investor

**Audience :** Investisseurs, Platform Admins, C-Level

**Fonctionnalités :**
- 📊 Métriques globales de la plateforme
- 💰 Revenus et analytics business
- 🏆 Top SaaS performants
- 📈 Graphiques d'évolution
- 🎯 Répartition par secteur

**Métriques affichées :**
- SaaS actifs
- Revenus mensuels
- Utilisateurs actifs totaux
- Taux de conversion global

### 👨‍💻 Niveau Developer

**Audience :** Développeurs, SaaS Owners, Tech Leads

**Fonctionnalités :**
- 🚧 Projets en développement
- 💻 Gestion des workspaces
- 📦 Modules disponibles
- 🛠️ Outils de développement
- 🔧 Infrastructure et monitoring

**Métriques affichées :**
- SaaS en développement
- Workspaces actifs
- Modules déployés
- Issues ouvertes

### 🔧 Niveau Contractor

**Audience :** Contractants, Freelancers, Consultants

**Fonctionnalités :**
- 📋 Projets assignés
- ✅ Tâches et planning
- ⏰ Suivi du temps
- 💰 Facturation
- 🛠️ Outils spécialisés
- 📅 Calendrier et notifications

**Métriques affichées :**
- Projets assignés
- Tâches complétées
- Heures facturées
- Revenus du mois

## 🎨 Personnalisation

### Styles CSS

Le dashboard utilise les variables CSS de DaisyUI et peut être personnalisé :

```css
.level-dashboard {
  --primary-accent: var(--color-primary);
}

.investor-dashboard {
  --primary-accent: var(--color-primary);
}

.developer-dashboard {
  --primary-accent: var(--color-secondary);
}

.contractor-dashboard {
  --primary-accent: var(--color-accent);
}
```

### Thèmes supportés

Le dashboard s'adapte automatiquement à tous les 35 thèmes DaisyUI disponibles dans LyxalKitUI.

## 📱 Responsive Design

Le dashboard est entièrement responsive avec :

- **Mobile** : Affichage en colonne, navigation simplifiée
- **Tablet** : Grille adaptative 2 colonnes
- **Desktop** : Grille complète 3-4 colonnes

## 🔧 Intégrations

### Avec d'autres composants LyxalKitUI

```tsx
import { LevelDashboard, ThemeProvider } from '@lyxal/ui-kit';

function App() {
  return (
    <ThemeProvider defaultTheme="dracula">
      <LevelDashboard defaultLevel="investor" />
    </ThemeProvider>
  );
}
```

### Avec des données réelles

```tsx
import { LevelDashboard } from '@lyxal/ui-kit';
import { useAuth, useMetrics } from './hooks';

function App() {
  const { user } = useAuth();
  const { metrics } = useMetrics();
  
  const getUserLevel = () => {
    if (user.role === 'admin') return 'investor';
    if (user.role === 'developer') return 'developer';
    return 'contractor';
  };

  return (
    <LevelDashboard
      defaultLevel={getUserLevel()}
      onLevelChange={(level) => {
        // Tracker le changement de niveau
        analytics.track('dashboard_level_changed', { level });
      }}
    />
  );
}
```

## 🔮 Évolutions futures

- [ ] **Widgets personnalisables** : Permettre à l'utilisateur de personnaliser les widgets affichés
- [ ] **Graphiques interactifs** : Intégration de Chart.js ou Recharts
- [ ] **Temps réel** : Mise à jour automatique des métriques
- [ ] **Exports** : Possibilité d'exporter les données en PDF/Excel
- [ ] **Notifications push** : Alertes en temps réel
- [ ] **Dashboard builder** : Interface pour créer des dashboards personnalisés

## 📚 Exemples complets

Voir `DashboardExample.tsx` pour un exemple complet avec gestion d'état et notifications.

## 🤝 Contribution

Pour ajouter un nouveau niveau ou modifier les composants existants :

1. Créer le composant dans `sections/`
2. Ajouter le type dans `LevelDashboard.tsx`
3. Mettre à jour le `LevelSelector`
4. Ajouter les styles CSS correspondants
5. Documenter les nouvelles fonctionnalités 