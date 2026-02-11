# Architecture des Composants LYXAL Master Console

## 🏗️ Structure Organisée

```
src/components/
├── app/                    # 🔐 Composants de l'application (utilisateurs authentifiés)
│   ├── header/            # 📱 Composants du header applicatif
│   │   ├── menusysteme/   # ⚙️ Menu système et configuration
│   │   │   ├── ConfigModal.tsx      # Modal de configuration système
│   │   │   ├── SystemMenuItem.tsx   # Élément générique de menu
│   │   │   └── index.ts            # Exports du menu système
│   │   ├── Header.tsx             # Header principal avec navigation
│   │   ├── ThemeColorPreview.tsx  # Aperçu visuel des thèmes
│   │   └── index.ts               # Exports du header
│   ├── Layout.tsx         # 🎨 Layout principal avec thème utilisateur
│   ├── Sidebar.tsx        # 📋 Menu latéral de navigation
│   ├── Footer.tsx         # 🏢 Footer de l'application
│   └── index.ts           # Exports des composants app
├── website/               # 🌐 Composants du site marketing (publics)
│   ├── Header.tsx         # Header du site marketing
│   ├── Footer.tsx         # Footer du site marketing
│   ├── Layout.tsx         # 🎨 Layout website avec thème fixe
│   └── index.ts           # Exports des composants website
└── __tests__/             # 🧪 Tests unitaires
    ├── Header.test.tsx
    ├── Layout.test.tsx
    └── ...
```

## 🎨 Gestion des Thèmes

### Architecture à Deux Niveaux

#### 1. **App Layout** (`/app/Layout.tsx`)
- **Thème personnalisable** par chaque utilisateur authentifié
- **Préférence sauvegardée** dans localStorage + profil utilisateur
- **Thème par défaut** configuré dans `systemConfig.identity.themeParDefaut`
- **Sélecteur de thème** disponible dans le header
- **Persistance** des préférences utilisateur

```typescript
// Utilisation du thème par défaut système
const defaultTheme = config.identity.themeParDefaut.value; // 'corporate'

// Hiérarchie de priorité :
// 1. localStorage (préférence utilisateur)
// 2. initialTheme (prop)
// 3. defaultTheme (configuration système)
const theme = localStorage.getItem('lyxal-theme') || initialTheme || defaultTheme;
```

#### 2. **Website Layout** (`/website/Layout.tsx`)
- **Thème fixe** défini par l'administration
- **Non modifiable** par les visiteurs
- **Cohérence de marque** garantie
- **Configuration** via `systemConfig.identity.themeWebsite`

```typescript
// Thème fixe pour le site marketing
const websiteTheme = config.identity.themeWebsite.value; // 'corporate'

// Application automatique sans sélecteur utilisateur
document.documentElement.setAttribute('data-theme', websiteTheme);
```

### Configuration Système

Dans `src/types/systemConfig.ts` :

```typescript
// Thème par défaut pour les nouveaux utilisateurs de l'app
themeParDefaut: {
  value: 'corporate',
  type: 'string',
  namespace: 'identity',
  description: 'Thème par défaut de l\'application (pour les nouveaux utilisateurs)',
  editable: true,
  validation: { 
    enum: ['light', 'dark', 'corporate', 'synthwave', ...] 
  }
}

// Thème fixe pour le site marketing
themeWebsite: {
  value: 'corporate',
  type: 'string', 
  namespace: 'identity',
  description: 'Thème fixe du site marketing (non modifiable par les utilisateurs)',
  editable: true,
  validation: { 
    enum: ['light', 'dark', 'corporate', 'synthwave', ...] 
  }
}
```

## 🔄 Flux de Données

### App (Utilisateurs Authentifiés)
1. **Chargement** : Configuration système → Thème par défaut
2. **Personnalisation** : Utilisateur → Sélecteur → localStorage
3. **Persistance** : localStorage → Rechargement de page
4. **Synchronisation** : Profil utilisateur (futur)

### Website (Visiteurs)
1. **Application** : Configuration système → Thème fixe
2. **Cohérence** : Pas de personnalisation possible
3. **Branding** : Contrôle total par l'administration

## 🎯 Avantages de cette Architecture

### ✅ Expérience Utilisateur
- **App** : Liberté de personnalisation pour le confort de travail
- **Website** : Expérience cohérente et professionnelle

### ✅ Administration
- **Contrôle** : Thème website géré centralement
- **Flexibilité** : Thème par défaut app configurable
- **Maintenance** : Séparation claire des responsabilités

### ✅ Technique
- **Performance** : Thèmes optimisés par contexte
- **Maintenabilité** : Logique séparée et claire
- **Évolutivité** : Architecture extensible

## 🚀 Utilisation

### Pour l'Application
```tsx
import { Layout } from './components/app';

function App() {
  return (
    <Layout>
      <YourAppContent />
    </Layout>
  );
}
```

### Pour le Site Marketing
```tsx
import { Layout } from './components/website';

function Website() {
  return (
    <Layout>
      <YourWebsiteContent />
    </Layout>
  );
}
```

## 📊 Composants Principaux

### Layout App
- **Responsabilité** : Orchestration complète de l'interface utilisateur
- **Fonctionnalités** : Header, Sidebar, Footer, Modals, Thèmes
- **État** : Thème, sidebar, modals, performance

### Layout Website  
- **Responsabilité** : Structure simple pour le site marketing
- **Fonctionnalités** : Header, Footer, Thème fixe
- **État** : Minimal, axé sur les performances

### ThemeColorPreview
- **Responsabilité** : Aperçu visuel des couleurs d'un thème
- **Optimisation** : React.memo, useMemo pour les performances
- **Accessibilité** : Labels ARIA, support clavier

### ConfigModal
- **Responsabilité** : Configuration des paramètres système
- **Sécurité** : Validation des entrées, permissions
- **UX** : Interface intuitive avec sections organisées 