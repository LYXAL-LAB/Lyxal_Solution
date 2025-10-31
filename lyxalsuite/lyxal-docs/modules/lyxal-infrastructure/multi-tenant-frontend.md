# ⚛️ MULTI-TENANT FRONTEND - Module Infrastructure

## 📋 **Vue d'ensemble**

Module technique pour l'interface React adaptative qui se configure dynamiquement selon le domaine visiteur dans l'architecture LyxalSuite.

**Référence architecturale :** `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md`

---

## 🌐 **Détection Domaine et Configuration**

### **Processus de Détection**

```javascript
// 1. DNS résolution automatique
restaurant-bistro.com → CNAME → app.lyxal.com → IP LWS

// 2. Frontend détecte le domaine
const domain = window.location.hostname; // "restaurant-bistro.com"

// 3. SurrealDB récupère la configuration
const siteConfig = await surrealClient.query(`
  SELECT * FROM site_configurations 
  WHERE domain = $domain
`, { domain });

// 4. Interface s'adapte automatiquement
renderSaaSInterface(siteConfig);
```

---

## 🗃️ **Configuration SurrealDB par Domaine**

### **Structure de Configuration**

```json
{
  "domain": "restaurant-bistro.com",
  "namespace": "restaurant_bistro",
  "theme": "restaurant",
  "branding": {
    "logo": "https://cdn.exemple.com/restaurant-bistro/logo.png",
    "colors": { "primary": "#8B4513", "secondary": "#F4A460" },
    "fonts": { "primary": "Playfair Display", "secondary": "Source Sans Pro" }
  },
  "modules": ["menu", "orders", "reservations", "reviews", "analytics"],
  "features": {
    "online_ordering": true,
    "table_reservations": true,
    "loyalty_program": false
  },
  "integrations": {
    "payment": "stripe",
    "delivery": "uber_eats",
    "pos": "square"
  }
}
```

---

## ⚛️ **Interface React Adaptative**

### **Point d'Entrée Principal**

```typescript
// App.tsx - Point d'entrée unique
import React, { useState, useEffect } from 'react';
import { LoadingScreen } from './components/LoadingScreen';
import { SaaSProvider } from './providers/SaaSProvider';
import { ThemeProvider } from './providers/ThemeProvider';
import { Router } from 'react-router-dom';
import { DynamicInterface } from './components/DynamicInterface';

function LyxalApp() {
  const domain = window.location.hostname;
  const [siteConfig, setSiteConfig] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    loadSiteConfiguration(domain);
  }, [domain]);
  
  const loadSiteConfiguration = async (domain: string) => {
    try {
      const config = await fetchSiteConfig(domain);
      setSiteConfig(config);
    } catch (error) {
      console.error('Erreur chargement configuration:', error);
      // Configuration par défaut en cas d'erreur
      setSiteConfig(getDefaultConfig(domain));
    } finally {
      setLoading(false);
    }
  };
  
  if (loading) return <LoadingScreen />;
  
  if (!siteConfig) {
    return <div>Erreur de configuration</div>;
  }
  
  return (
    <SaaSProvider config={siteConfig}>
      <ThemeProvider theme={siteConfig.theme}>
        <Router>
          <DynamicInterface />
        </Router>
      </ThemeProvider>
    </SaaSProvider>
  );
}

export default LyxalApp;
```

### **Interface Dynamique**

```typescript
// DynamicInterface.tsx - Interface qui s'adapte
import React from 'react';
import { useSaaSConfig } from '../hooks/useSaaSConfig';
import { Navigation } from './Navigation';
import { Routes, Route } from 'react-router-dom';
import { RestaurantRoutes } from '../themes/restaurant/Routes';
import { EcommerceRoutes } from '../themes/ecommerce/Routes';
import { BeautyRoutes } from '../themes/beauty/Routes';
import { ConsultingRoutes } from '../themes/consulting/Routes';
import { AdminRoutes } from '../themes/admin/Routes';

function DynamicInterface() {
  const { config } = useSaaSConfig();
  
  return (
    <div className={`theme-${config.theme} saas-interface`}>
      <Navigation modules={config.modules} branding={config.branding} />
      
      <main className="main-content">
        <Routes>
          {config.theme === 'restaurant' && <RestaurantRoutes />}
          {config.theme === 'ecommerce' && <EcommerceRoutes />}
          {config.theme === 'beauty' && <BeautyRoutes />}
          {config.theme === 'consulting' && <ConsultingRoutes />}
          {config.theme === 'admin' && <AdminRoutes />}
          
          {/* Route par défaut */}
          <Route path="*" element={<DefaultDashboard />} />
        </Routes>
      </main>
    </div>
  );
}

export { DynamicInterface };
```

---

## 🎨 **Système de Thèmes Dynamiques**

### **Provider de Thème**

```typescript
// providers/ThemeProvider.tsx
import React, { createContext, useContext, ReactNode } from 'react';

interface ThemeConfig {
  name: string;
  colors: {
    primary: string;
    secondary: string;
    accent?: string;
  };
  fonts: {
    primary: string;
    secondary: string;
  };
  layout: {
    header: string;
    sidebar: boolean;
    footer: string;
  };
}

interface ThemeContextType {
  theme: ThemeConfig;
  applyTheme: (theme: ThemeConfig) => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export const ThemeProvider: React.FC<{ 
  theme: ThemeConfig; 
  children: ReactNode;
}> = ({ theme, children }) => {
  
  React.useEffect(() => {
    // Application dynamique des styles CSS
    const root = document.documentElement;
    root.style.setProperty('--color-primary', theme.colors.primary);
    root.style.setProperty('--color-secondary', theme.colors.secondary);
    root.style.setProperty('--font-primary', theme.fonts.primary);
    root.style.setProperty('--font-secondary', theme.fonts.secondary);
    
    // Application classe thème
    document.body.className = `theme-${theme.name}`;
  }, [theme]);
  
  const applyTheme = (newTheme: ThemeConfig) => {
    // Logique de changement de thème en temps réel
  };
  
  return (
    <ThemeContext.Provider value={{ theme, applyTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme doit être utilisé dans un ThemeProvider');
  }
  return context;
};
```

---

## 🔌 **Provider SaaS Configuration**

### **Gestion Globale Configuration**

```typescript
// providers/SaaSProvider.tsx
import React, { createContext, useContext, ReactNode } from 'react';

interface SaaSConfig {
  domain: string;
  namespace: string;
  theme: string;
  modules: string[];
  features: Record<string, boolean>;
  branding: {
    logo: string;
    colors: Record<string, string>;
    fonts: Record<string, string>;
  };
  integrations: Record<string, string>;
}

interface SaaSContextType {
  config: SaaSConfig;
  updateConfig: (updates: Partial<SaaSConfig>) => void;
  isModuleEnabled: (module: string) => boolean;
  isFeatureEnabled: (feature: string) => boolean;
}

const SaaSContext = createContext<SaaSContextType | null>(null);

export const SaaSProvider: React.FC<{ 
  config: SaaSConfig; 
  children: ReactNode;
}> = ({ config, children }) => {
  
  const [currentConfig, setCurrentConfig] = React.useState(config);
  
  const updateConfig = (updates: Partial<SaaSConfig>) => {
    setCurrentConfig(prev => ({ ...prev, ...updates }));
  };
  
  const isModuleEnabled = (module: string): boolean => {
    return currentConfig.modules.includes(module);
  };
  
  const isFeatureEnabled = (feature: string): boolean => {
    return currentConfig.features[feature] === true;
  };
  
  return (
    <SaaSContext.Provider value={{ 
      config: currentConfig, 
      updateConfig, 
      isModuleEnabled, 
      isFeatureEnabled 
    }}>
      {children}
    </SaaSContext.Provider>
  );
};

export const useSaaSConfig = () => {
  const context = useContext(SaaSContext);
  if (!context) {
    throw new Error('useSaaSConfig doit être utilisé dans un SaaSProvider');
  }
  return context;
};
```

---

## 🎭 **Modules Adaptatifs**

### **Navigation Dynamique**

```typescript
// components/Navigation.tsx
import React from 'react';
import { useSaaSConfig } from '../hooks/useSaaSConfig';
import { Link } from 'react-router-dom';

interface NavigationProps {
  modules: string[];
  branding: {
    logo: string;
    colors: Record<string, string>;
  };
}

export const Navigation: React.FC<NavigationProps> = ({ modules, branding }) => {
  const { config } = useSaaSConfig();
  
  const getModuleRoutes = () => {
    const routes: Record<string, { label: string; path: string; icon: string }> = {
      'menu': { label: 'Menu', path: '/menu', icon: '🍽️' },
      'orders': { label: 'Commandes', path: '/orders', icon: '📋' },
      'reservations': { label: 'Réservations', path: '/reservations', icon: '📅' },
      'reviews': { label: 'Avis', path: '/reviews', icon: '⭐' },
      'analytics': { label: 'Analytics', path: '/analytics', icon: '📊' },
      'products': { label: 'Produits', path: '/products', icon: '📦' },
      'customers': { label: 'Clients', path: '/customers', icon: '👥' },
      'billing': { label: 'Facturation', path: '/billing', icon: '💰' },
    };
    
    return modules.map(module => routes[module]).filter(Boolean);
  };
  
  return (
    <nav className="saas-navigation" style={{ 
      backgroundColor: branding.colors.primary 
    }}>
      <div className="nav-brand">
        <img src={branding.logo} alt="Logo" className="nav-logo" />
        <span className="nav-title">{config.domain}</span>
      </div>
      
      <ul className="nav-menu">
        {getModuleRoutes().map(route => (
          <li key={route.path} className="nav-item">
            <Link to={route.path} className="nav-link">
              <span className="nav-icon">{route.icon}</span>
              <span className="nav-label">{route.label}</span>
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
};
```

---

## 🔧 **Utilitaires Configuration**

### **Chargement Configuration**

```typescript
// utils/configLoader.ts
import { surrealClient } from '../database/surrealdb';

export const fetchSiteConfig = async (domain: string) => {
  try {
    const result = await surrealClient.query(`
      SELECT * FROM site_configurations 
      WHERE domain = $domain
      LIMIT 1
    `, { domain });
    
    if (result[0]?.result?.length > 0) {
      return result[0].result[0];
    }
    
    throw new Error('Configuration non trouvée');
  } catch (error) {
    console.error('Erreur lors du chargement de la configuration:', error);
    throw error;
  }
};

export const getDefaultConfig = (domain: string) => {
  return {
    domain,
    namespace: domain.replace(/\./g, '_'),
    theme: 'default',
    modules: ['dashboard'],
    features: {},
    branding: {
      logo: '/default-logo.png',
      colors: {
        primary: '#3B82F6',
        secondary: '#64748B'
      },
      fonts: {
        primary: 'Inter',
        secondary: 'Inter'
      }
    },
    integrations: {}
  };
};
```

---

## 📚 **Références**

### **Documentation Liée**
- `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md` - Vue architecturale
- `lyxal-infrastructure/domain-management.md` - Gestion domaines
- `lyxal-infrastructure/ssl-automation.md` - Gestion SSL
- `lyxal-infrastructure/monitoring-system.md` - Surveillance système

---

**Date de création :** Décembre 2024  
**Statut :** Module technique - Frontend multi-tenant  
**Version :** 1.0
