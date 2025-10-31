# 🏗️ Architecture UI LyxalSuite

Guide de l'architecture UI recommandée pour les applications LyxalSuite avec DaisyUI 5 et génération SaaS automatique.

## 🎯 Principes architecturaux

### Séparation des responsabilités
- **lyxalkitui** : Layouts génériques, navigation, thèmes DaisyUI, composants partagés
- **Modules backend** : Logique métier, API, SDK (LyxalAuth, LyxalCRM, etc.)
- **Applications SaaS** : UI spécifique, pages dédiées, configuration thématique

### Architecture modulaire
```
LyxalSuite Ecosystem/
├── lyxalkitui/              # 🎨 Bibliothèque UI centrale
│   ├── src/
│   │   ├── layouts/         # Layouts génériques
│   │   ├── components/      # Composants DaisyUI partagés
│   │   ├── theme/           # Configuration thèmes
│   │   └── utils/           # Utilitaires UI
│   └── docs/                # Documentation (vous êtes ici)
│
├── lyxalauth/               # 🔐 Module authentification
│   ├── backend/             # API & logique métier
│   ├── sdk/                 # SDK client
│   └── frontend/            # Pages UI spécifiques (optionnel)
│
├── lyxalcrm/                # 👥 Module CRM
│   ├── backend/             # API & logique métier
│   ├── sdk/                 # SDK client
│   └── frontend/            # Pages UI spécifiques (optionnel)
│
└── Generated-SaaS/          # 🚀 Applications générées
    ├── saas-restaurant/     # SaaS spécifique restaurant
    ├── saas-finance/        # SaaS spécifique finance
    └── saas-ecommerce/      # SaaS spécifique e-commerce
```

## 📁 Structure d'une application SaaS générée

### Architecture recommandée
```
Generated-SaaS-App/
├── src/
│   ├── layouts/             # Layouts depuis lyxalkitui
│   │   ├── MainLayout.tsx   # Layout principal avec navigation
│   │   ├── AuthLayout.tsx   # Layout pour pages auth
│   │   └── DashboardLayout.tsx # Layout dashboard
│   │
│   ├── components/          # Composants DaisyUI spécifiques
│   │   ├── common/          # Composants génériques
│   │   ├── forms/           # Composants de formulaires
│   │   └── charts/          # Composants graphiques
│   │
│   ├── pages/               # Pages par module
│   │   ├── auth/            # Pages LyxalAuth
│   │   │   ├── LoginPage.tsx
│   │   │   ├── SignupPage.tsx
│   │   │   └── ForgotPasswordPage.tsx
│   │   │
│   │   ├── crm/             # Pages LyxalCRM (si activé)
│   │   │   ├── CRMDashboard.tsx
│   │   │   ├── CustomersPage.tsx
│   │   │   └── LeadsPage.tsx
│   │   │
│   │   ├── analytics/       # Pages LyxalAnalytics (si activé)
│   │   │   ├── AnalyticsDashboard.tsx
│   │   │   ├── ReportsPage.tsx
│   │   │   └── MetricsPage.tsx
│   │   │
│   │   └── dashboard/       # Dashboard principal
│   │       ├── HomePage.tsx
│   │       └── OverviewPage.tsx
│   │
│   ├── providers/           # Context providers
│   │   ├── AuthProvider.tsx
│   │   ├── CRMProvider.tsx
│   │   ├── AnalyticsProvider.tsx
│   │   └── ThemeProvider.tsx
│   │
│   ├── hooks/               # Hooks personnalisés
│   │   ├── useAuth.ts
│   │   ├── usePermissions.ts
│   │   ├── useTheme.ts
│   │   └── useApi.ts
│   │
│   ├── utils/               # Utilitaires
│   │   ├── api.ts
│   │   ├── constants.ts
│   │   └── helpers.ts
│   │
│   ├── theme/               # Configuration thème
│   │   ├── globals.css      # DaisyUI + thème sélectionné
│   │   └── custom.css       # Styles personnalisés
│   │
│   └── config/              # Configuration
│       ├── saas.config.ts   # Configuration SaaS
│       ├── routes.ts        # Configuration routes
│       └── permissions.ts   # Configuration permissions
│
├── public/                  # Assets statiques
├── package.json             # Dépendances spécifiques
├── vite.config.ts           # Configuration build
├── tailwind.config.js       # Configuration Tailwind + DaisyUI
└── README.md                # Documentation SaaS
```

## 🎨 Layouts génériques (lyxalkitui)

### MainLayout.tsx
```tsx
// src/layouts/MainLayout.tsx
import React from 'react';
import { Outlet } from 'react-router-dom';
import { Navigation } from '../components/Navigation';
import { Sidebar } from '../components/Sidebar';
import { Footer } from '../components/Footer';
import { useAuth } from '../providers/AuthProvider';

export function MainLayout() {
  const { user } = useAuth();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="min-h-screen bg-base-100">
      {/* Navigation principale */}
      <Navigation />
      
      <div className="flex">
        {/* Sidebar */}
        <Sidebar />
        
        {/* Contenu principal */}
        <main className="flex-1 p-6">
          <Outlet />
        </main>
      </div>
      
      {/* Footer */}
      <Footer />
    </div>
  );
}
```

### AuthLayout.tsx
```tsx
// src/layouts/AuthLayout.tsx
import React from 'react';
import { Outlet } from 'react-router-dom';

export function AuthLayout() {
  return (
    <div className="min-h-screen bg-base-200 flex items-center justify-center">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold">LyxalSuite</h1>
          <p className="text-base-content/70">Plateforme SaaS modulaire</p>
        </div>
        
        <Outlet />
      </div>
    </div>
  );
}
```

### DashboardLayout.tsx
```tsx
// src/layouts/DashboardLayout.tsx
import React from 'react';
import { Outlet } from 'react-router-dom';
import { DashboardSidebar } from '../components/DashboardSidebar';
import { DashboardHeader } from '../components/DashboardHeader';

export function DashboardLayout() {
  return (
    <div className="min-h-screen bg-base-100">
      <DashboardHeader />
      
      <div className="flex">
        <DashboardSidebar />
        
        <main className="flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
```

## 🧩 Composants partagés (lyxalkitui)

### Navigation.tsx
```tsx
// src/components/Navigation.tsx
import React from 'react';
import { useAuth } from '../providers/AuthProvider';
import { usePermissions } from '../hooks/usePermissions';
import { ThemeSelector } from './ThemeSelector';

export function Navigation() {
  const { user, logout } = useAuth();
  const { hasPermission } = usePermissions();

  return (
    <div className="navbar bg-base-300 shadow-lg">
      <div className="navbar-start">
        <div className="dropdown">
          <div tabIndex={0} role="button" className="btn btn-ghost lg:hidden">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h8m-8 6h16"></path>
            </svg>
          </div>
          <ul tabIndex={0} className="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
            <li><a href="/dashboard">📊 Dashboard</a></li>
            {hasPermission('crm:read') && (
              <li><a href="/crm">👥 CRM</a></li>
            )}
            {hasPermission('analytics:read') && (
              <li><a href="/analytics">📈 Analytics</a></li>
            )}
          </ul>
        </div>
        
        <a className="btn btn-ghost text-xl" href="/">
          <span className="font-bold">LyxalSuite</span>
        </a>
      </div>

      <div className="navbar-center hidden lg:flex">
        <ul className="menu menu-horizontal px-1">
          <li><a href="/dashboard">📊 Dashboard</a></li>
          {hasPermission('crm:read') && (
            <li><a href="/crm">👥 CRM</a></li>
          )}
          {hasPermission('analytics:read') && (
            <li><a href="/analytics">📈 Analytics</a></li>
          )}
          {hasPermission('ai:use') && (
            <li><a href="/ai">🤖 Assistant IA</a></li>
          )}
        </ul>
      </div>

      <div className="navbar-end gap-2">
        {/* Sélecteur de thème */}
        <ThemeSelector />
        
        {/* Notifications */}
        <div className="dropdown dropdown-end">
          <div tabIndex={0} role="button" className="btn btn-ghost btn-circle">
            <div className="indicator">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-5 5v-5zM10.5 3.5L6.5 7.5 10.5 11.5"></path>
              </svg>
              <span className="badge badge-xs badge-primary indicator-item"></span>
            </div>
          </div>
          <div tabIndex={0} className="mt-3 z-[1] card card-compact dropdown-content w-52 bg-base-100 shadow">
            <div className="card-body">
              <span className="font-bold text-lg">3 notifications</span>
              <span className="text-info">Nouveau lead CRM</span>
              <span className="text-success">Rapport analytics prêt</span>
            </div>
          </div>
        </div>

        {/* Menu utilisateur */}
        <div className="dropdown dropdown-end">
          <div tabIndex={0} role="button" className="btn btn-ghost btn-circle avatar">
            <div className="w-10 rounded-full">
              <img alt="Avatar" src={user?.avatar || '/default-avatar.png'} />
            </div>
          </div>
          <ul tabIndex={0} className="mt-3 z-[1] p-2 shadow menu menu-sm dropdown-content bg-base-100 rounded-box w-52">
            <li>
              <a className="justify-between">
                Profil
                <span className="badge">Nouveau</span>
              </a>
            </li>
            <li><a>Paramètres</a></li>
            <li><a>Aide</a></li>
            <li><button onClick={logout}>Déconnexion</button></li>
          </ul>
        </div>
      </div>
    </div>
  );
}
```

### Sidebar.tsx
```tsx
// src/components/Sidebar.tsx
import React from 'react';
import { useLocation } from 'react-router-dom';
import { usePermissions } from '../hooks/usePermissions';

export function Sidebar() {
  const location = useLocation();
  const { hasPermission } = usePermissions();

  const menuItems = [
    {
      label: 'Dashboard',
      icon: '📊',
      path: '/dashboard',
      permission: null
    },
    {
      label: 'CRM',
      icon: '👥',
      path: '/crm',
      permission: 'crm:read'
    },
    {
      label: 'Analytics',
      icon: '📈',
      path: '/analytics',
      permission: 'analytics:read'
    },
    {
      label: 'Assistant IA',
      icon: '🤖',
      path: '/ai',
      permission: 'ai:use'
    },
    {
      label: 'Paramètres',
      icon: '⚙️',
      path: '/settings',
      permission: 'settings:manage'
    }
  ];

  const filteredItems = menuItems.filter(item => 
    !item.permission || hasPermission(item.permission)
  );

  return (
    <div className="drawer-side">
      <label htmlFor="drawer-toggle" className="drawer-overlay"></label>
      <aside className="w-64 min-h-full bg-base-200">
        <ul className="menu p-4 space-y-2">
          {filteredItems.map(item => (
            <li key={item.path}>
              <a 
                href={item.path}
                className={`flex items-center gap-3 ${
                  location.pathname === item.path ? 'active' : ''
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span>{item.label}</span>
              </a>
            </li>
          ))}
        </ul>
      </aside>
    </div>
  );
}
```

## 🎨 Gestion des thèmes

### ThemeProvider.tsx
```tsx
// src/providers/ThemeProvider.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';

interface ThemeContextType {
  theme: string;
  setTheme: (theme: string) => void;
  availableThemes: string[];
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const DAISYUI_THEMES = [
  'light', 'dark', 'cupcake', 'bumblebee', 'emerald', 'corporate',
  'synthwave', 'retro', 'cyberpunk', 'valentine', 'halloween',
  'garden', 'forest', 'aqua', 'lofi', 'pastel', 'fantasy',
  'wireframe', 'black', 'luxury', 'dracula', 'cmyk', 'autumn',
  'business', 'acid', 'lemonade', 'night', 'coffee', 'winter',
  'dim', 'nord', 'sunset'
];

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setThemeState] = useState('light');

  useEffect(() => {
    // Récupérer le thème depuis localStorage ou configuration SaaS
    const savedTheme = localStorage.getItem('theme') || 
                      window.SAAS_CONFIG?.theme || 
                      'light';
    setThemeState(savedTheme);
    document.documentElement.setAttribute('data-theme', savedTheme);
  }, []);

  const setTheme = (newTheme: string) => {
    setThemeState(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
  };

  return (
    <ThemeContext.Provider value={{ theme, setTheme, availableThemes: DAISYUI_THEMES }}>
      {children}
    </ThemeContext.Provider>
  );
}

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
```

### ThemeSelector.tsx
```tsx
// src/components/ThemeSelector.tsx
import React from 'react';
import { useTheme } from '../providers/ThemeProvider';

export function ThemeSelector() {
  const { theme, setTheme, availableThemes } = useTheme();

  return (
    <div className="dropdown dropdown-end">
      <div tabIndex={0} role="button" className="btn btn-ghost btn-circle">
        🎨
      </div>
      <div tabIndex={0} className="dropdown-content z-[1] card card-compact w-64 p-2 shadow bg-base-100">
        <div className="card-body">
          <h3 className="card-title text-sm">Choisir un thème</h3>
          <div className="grid grid-cols-3 gap-2">
            {availableThemes.slice(0, 12).map(themeName => (
              <button
                key={themeName}
                className={`btn btn-xs ${theme === themeName ? 'btn-primary' : 'btn-outline'}`}
                onClick={() => setTheme(themeName)}
              >
                {themeName}
              </button>
            ))}
          </div>
          <div className="text-xs text-center mt-2">
            <a href="/themes" className="link">Voir tous les thèmes</a>
          </div>
        </div>
      </div>
    </div>
  );
}
```

## 🔧 Configuration SaaS

### saas.config.ts
```typescript
// src/config/saas.config.ts
export interface SaasConfig {
  name: string;
  version: string;
  description: string;
  
  branding: {
    companyName: string;
    logo?: string;
    favicon?: string;
    primaryColor: string;
    secondaryColor: string;
  };
  
  theme: string;
  
  modules: {
    auth: boolean;
    crm?: boolean;
    analytics?: boolean;
    dashboard?: boolean;
    ai?: boolean;
  };
  
  permissions: {
    roles: string[];
    features: Record<string, string[]>;
  };
  
  deployment: {
    domain?: string;
    environment: 'development' | 'staging' | 'production';
  };
}

// Configuration générée automatiquement par le SaaS Builder
export const saasConfig: SaasConfig = {
  name: "restaurant-manager",
  version: "1.0.0",
  description: "SaaS de gestion de restaurants",
  
  branding: {
    companyName: "RestaurantPro",
    primaryColor: "#8B4513",
    secondaryColor: "#D2691E"
  },
  
  theme: "coffee",
  
  modules: {
    auth: true,
    crm: true,
    analytics: true,
    dashboard: true
  },
  
  permissions: {
    roles: ["admin", "manager", "staff"],
    features: {
      "crm": ["admin", "manager"],
      "analytics": ["admin"],
      "orders": ["admin", "manager", "staff"]
    }
  },
  
  deployment: {
    domain: "restaurantpro.com",
    environment: "production"
  }
};

// Exposer la config globalement pour les composants
declare global {
  interface Window {
    SAAS_CONFIG: SaasConfig;
  }
}

window.SAAS_CONFIG = saasConfig;
```

## 🚀 Routing et navigation

### routes.ts
```typescript
// src/config/routes.ts
import { saasConfig } from './saas.config';

export interface Route {
  path: string;
  component: string;
  permission?: string;
  module: string;
}

export const generateRoutes = (): Route[] => {
  const routes: Route[] = [
    // Routes de base (toujours présentes)
    { path: '/', component: 'HomePage', module: 'core' },
    { path: '/dashboard', component: 'Dashboard', module: 'core' }
  ];

  // Routes conditionnelles selon les modules activés
  if (saasConfig.modules.auth) {
    routes.push(
      { path: '/login', component: 'LoginPage', module: 'auth' },
      { path: '/signup', component: 'SignupPage', module: 'auth' },
      { path: '/forgot-password', component: 'ForgotPasswordPage', module: 'auth' }
    );
  }

  if (saasConfig.modules.crm) {
    routes.push(
      { path: '/crm', component: 'CRMDashboard', permission: 'crm:read', module: 'crm' },
      { path: '/crm/customers', component: 'CustomersPage', permission: 'crm:read', module: 'crm' },
      { path: '/crm/leads', component: 'LeadsPage', permission: 'crm:read', module: 'crm' }
    );
  }

  if (saasConfig.modules.analytics) {
    routes.push(
      { path: '/analytics', component: 'AnalyticsDashboard', permission: 'analytics:read', module: 'analytics' },
      { path: '/analytics/reports', component: 'ReportsPage', permission: 'analytics:read', module: 'analytics' }
    );
  }

  if (saasConfig.modules.ai) {
    routes.push(
      { path: '/ai', component: 'AIAssistant', permission: 'ai:use', module: 'ai' },
      { path: '/ai/chat', component: 'AIChatPage', permission: 'ai:use', module: 'ai' }
    );
  }

  return routes;
};
```

## 📊 Métriques et monitoring

### Performance monitoring
```tsx
// src/utils/monitoring.ts
export class PerformanceMonitor {
  static trackPageLoad(pageName: string) {
    const startTime = performance.now();
    
    return () => {
      const endTime = performance.now();
      const loadTime = endTime - startTime;
      
      // Envoyer les métriques à LyxalAnalytics
      if (window.SAAS_CONFIG?.modules.analytics) {
        this.sendMetric('page_load_time', {
          page: pageName,
          duration: loadTime,
          timestamp: new Date().toISOString()
        });
      }
    };
  }
  
  static trackUserAction(action: string, metadata?: any) {
    this.sendMetric('user_action', {
      action,
      metadata,
      timestamp: new Date().toISOString()
    });
  }
  
  private static sendMetric(type: string, data: any) {
    // Implémentation envoi vers LyxalAnalytics
    fetch('/api/analytics/metrics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type, data })
    });
  }
}
```

## 🎯 Bonnes pratiques

### 1. Composants réutilisables
- Utiliser les composants DaisyUI comme base
- Créer des wrappers pour la logique métier
- Maintenir la cohérence visuelle

### 2. Gestion d'état
- Context API pour l'état global
- Hooks personnalisés pour la logique réutilisable
- State local pour l'état des composants

### 3. Performance
- Lazy loading des modules
- Code splitting par route
- Optimisation des bundles

### 4. Accessibilité
- Utiliser les composants DaisyUI (déjà accessibles)
- Tester avec les lecteurs d'écran
- Respecter les contrastes de couleurs

### 5. Tests
- Tests unitaires des composants
- Tests d'intégration des providers
- Tests E2E des workflows critiques

---

**🏗️ Architecture UI modulaire - Scalable, maintenable et performante**