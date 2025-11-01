# 🔗 Intégration - Lyxal Studio

Ce document explique comment intégrer Lyxal Studio dans vos applications **React (Web)** et **React Native (Mobile)** avec **DaisyUI**.

---

## 📋 Table des Matières

1. [Installation Web (React + DaisyUI)](#-installation-web)
2. [Configuration SurrealDB](#-configuration-surrealdb)
3. [Composants React](#-composants-react)
4. [Intégration Mobile](#-intégration-mobile)
5. [Intégration DaisyUI](#-intégration-daisyui)

---

## 🌐 Installation Web

### Prérequis

```bash
# Dépendances requises
npm install surrealdb.js
npm install react-router-dom
npm install lucide-react  # Pour les icônes
npm install tailwindcss daisyui  # Pour le styling
```

### Structure du Projet

```
Lyxal_Central/
├── src/
│   ├── components/
│   │   └── studio/
│   │       ├── StudioEngine.tsx
│   │       ├── StudioMenu.tsx
│   │       ├── StudioPage.tsx
│   │       ├── StudioForm.tsx
│   │       ├── StudioTable.tsx
│   │       ├── StudioWidget.tsx
│   │       └── index.ts
│   ├── hooks/
│   │   ├── useStudioConfig.ts
│   │   ├── useStudioMenu.ts
│   │   ├── useStudioPage.ts
│   │   └── useStudioPermission.ts
│   ├── lib/
│   │   └── surrealdb.ts
│   └── App.tsx
```

---

## 🚀 Configuration Initiale

### 1. Connexion à SurrealDB Cloud

```typescript
// lib/surrealdb.ts
import Surreal from 'surrealdb.js';

class SurrealDBClient {
  private db: Surreal;
  private static instance: SurrealDBClient;

  private constructor() {
    this.db = new Surreal();
  }

  public static getInstance(): SurrealDBClient {
    if (!SurrealDBClient.instance) {
      SurrealDBClient.instance = new SurrealDBClient();
    }
    return SurrealDBClient.instance;
  }

  public async connect() {
    try {
      await this.db.connect('wss://cloud.surrealdb.com:443/rpc');
      await this.db.use('lyxal_solution', 'main');
      
      // Authentification
      await this.db.signin({
        username: process.env.REACT_APP_SURREAL_USERNAME,
        password: process.env.REACT_APP_SURREAL_PASSWORD,
      });

      console.log('✅ Connected to SurrealDB Cloud');
    } catch (error) {
      console.error('❌ Failed to connect to SurrealDB:', error);
      throw error;
    }
  }

  public getDB() {
    return this.db;
  }

  public async query(query: string) {
    return await this.db.query(query);
  }
}

export const db = SurrealDBClient.getInstance();
```

---

## 🎨 Composant Principal : StudioEngine

### StudioEngine.tsx

```typescript
import React, { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';
import { StudioMenu } from './StudioMenu';
import { useAuth } from '@/hooks/useAuth';

interface StudioEngineProps {
  tenant: string;
  children?: React.ReactNode;
}

interface StudioConfig {
  tenant_id: string;
  app_name: { [key: string]: string };
  logo: string;
  primary_color: string;
  secondary_color: string;
  accent_color?: string;
  theme: any;
  language_default: string;
  enabled_modules: string[];
}

export const StudioEngine: React.FC<StudioEngineProps> = ({ 
  tenant, 
  children 
}) => {
  const [config, setConfig] = useState<StudioConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const { user } = useAuth();

  useEffect(() => {
    const loadConfig = async () => {
      try {
        await db.connect();
        
        const result = await db.query(`
          SELECT fn::studio_get_config('${tenant}')
        `);
        
        if (result?.[0]?.config) {
          setConfig(result[0].config);
          applyTheme(result[0].config);
        }
      } catch (error) {
        console.error('Failed to load Studio config:', error);
      } finally {
        setLoading(false);
      }
    };

    loadConfig();
  }, [tenant]);

  const applyTheme = (config: StudioConfig) => {
    const root = document.documentElement;
    root.style.setProperty('--color-primary', config.primary_color);
    root.style.setProperty('--color-secondary', config.secondary_color);
    
    if (config.accent_color) {
      root.style.setProperty('--color-accent', config.accent_color);
    }
    
    // Appliquer le thème complet si disponible
    if (config.theme) {
      Object.entries(config.theme.colors || {}).forEach(([key, value]) => {
        root.style.setProperty(`--color-${key}`, value as string);
      });
    }
    
    // Mettre à jour le logo
    const favicon = document.querySelector('link[rel="icon"]') as HTMLLinkElement;
    if (favicon && config.logo) {
      favicon.href = config.logo;
    }
    
    // Mettre à jour le titre
    document.title = config.app_name[config.language_default] || 'Lyxal Suite';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!config) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600">Configuration Error</h1>
          <p className="text-gray-600">Failed to load Studio configuration for tenant: {tenant}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="studio-engine h-screen flex overflow-hidden">
      {/* Sidebar avec menu */}
      <aside className="w-64 bg-surface border-r border-border">
        <div className="p-4 border-b border-border">
          <img src={config.logo} alt={config.app_name.fr} className="h-8" />
        </div>
        <StudioMenu 
          tenant={tenant}
          role={user?.role || 'guest'}
          modules={config.enabled_modules}
        />
      </aside>

      {/* Contenu principal */}
      <main className="flex-1 overflow-auto bg-background">
        {children}
      </main>
    </div>
  );
};
```

---

## 📋 Hook : useStudioConfig

```typescript
// hooks/useStudioConfig.ts
import { useState, useEffect } from 'react';
import { db } from '@/lib/surrealdb';

export const useStudioConfig = (tenant: string) => {
  const [config, setConfig] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const loadConfig = async () => {
      try {
        const result = await db.query(`
          SELECT fn::studio_get_config('${tenant}')
        `);
        
        if (result?.[0]?.config) {
          setConfig(result[0].config);
        } else {
          throw new Error('Config not found');
        }
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    loadConfig();

    // LIVE QUERY pour réactivité
    const liveQuery = db.getDB().live(
      `SELECT * FROM studio_config WHERE tenant_id = '${tenant}'`,
      (update: any) => {
        if (update.action === 'UPDATE') {
          setConfig(update.result);
        }
      }
    );

    return () => {
      liveQuery.then(lq => lq.kill());
    };
  }, [tenant]);

  return { config, loading, error };
};
```

---

## 🧭 Composant : StudioMenu

```typescript
// components/studio/StudioMenu.tsx
import React, { useEffect, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import * as Icons from 'lucide-react';
import { db } from '@/lib/surrealdb';

interface StudioMenuProps {
  tenant: string;
  role: string;
  modules: string[];
}

interface MenuItem {
  id: string;
  code: string;
  label: { [key: string]: string };
  icon?: string;
  url: string;
  children?: MenuItem[];
}

export const StudioMenu: React.FC<StudioMenuProps> = ({ 
  tenant, 
  role, 
  modules 
}) => {
  const [menu, setMenu] = useState<MenuItem[]>([]);
  const location = useLocation();

  useEffect(() => {
    const loadMenu = async () => {
      try {
        const result = await db.query(`
          SELECT fn::studio_get_menu('${tenant}', '${role}', ${JSON.stringify(modules)})
        `);
        
        if (result?.[0]?.menu) {
          setMenu(result[0].menu);
        }
      } catch (error) {
        console.error('Failed to load menu:', error);
      }
    };

    loadMenu();
  }, [tenant, role, modules]);

  const renderMenuItem = (item: MenuItem, level: number = 0) => {
    const Icon = item.icon ? Icons[item.icon as keyof typeof Icons] : null;
    const isActive = location.pathname === item.url;

    return (
      <div key={item.id}>
        <Link
          to={item.url}
          className={`
            flex items-center gap-3 px-4 py-2.5 rounded-lg
            transition-colors
            ${isActive 
              ? 'bg-primary text-white' 
              : 'text-text hover:bg-surface-hover'
            }
            ${level > 0 ? 'ml-4' : ''}
          `}
        >
          {Icon && <Icon className="w-5 h-5" />}
          <span className="text-sm font-medium">
            {item.label.fr}
          </span>
        </Link>

        {/* Sous-menus */}
        {item.children && item.children.length > 0 && (
          <div className="mt-1">
            {item.children.map(child => renderMenuItem(child, level + 1))}
          </div>
        )}
      </div>
    );
  };

  return (
    <nav className="p-4 space-y-1">
      {menu.map(item => renderMenuItem(item))}
    </nav>
  );
};
```

---

## 📄 Composant : StudioPage

```typescript
// components/studio/StudioPage.tsx
import React, { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';
import { StudioWidget } from './StudioWidget';

interface StudioPageProps {
  pageCode: string;
  tenant: string;
}

interface PageData {
  page: any;
  widgets: Array<{
    widget: any;
    data: any;
  }>;
}

export const StudioPage: React.FC<StudioPageProps> = ({ 
  pageCode, 
  tenant 
}) => {
  const [pageData, setPageData] = useState<PageData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadPage = async () => {
      try {
        const result = await db.query(`
          SELECT fn::studio_render_page('${pageCode}', '${tenant}')
        `);
        
        if (result?.[0]) {
          setPageData(result[0]);
        }
      } catch (error) {
        console.error('Failed to load page:', error);
      } finally {
        setLoading(false);
      }
    };

    loadPage();
  }, [pageCode, tenant]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!pageData) {
    return <div>Page not found</div>;
  }

  const { page, widgets } = pageData;

  const layoutClass = {
    grid: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6',
    flex: 'flex flex-col gap-6',
    dashboard: 'grid grid-cols-12 gap-6',
    full: 'w-full'
  }[page.layout] || 'flex flex-col gap-6';

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-text">
          {page.title.fr}
        </h1>
        {page.description && (
          <p className="text-text-secondary mt-2">
            {page.description.fr}
          </p>
        )}
      </div>

      {/* Widgets */}
      <div className={layoutClass}>
        {widgets.map((w, index) => (
          <StudioWidget
            key={w.widget.code}
            widget={w.widget}
            initialData={w.data}
          />
        ))}
      </div>
    </div>
  );
};
```

---

## 📊 Composant : StudioWidget

```typescript
// components/studio/StudioWidget.tsx
import React, { useEffect, useState } from 'react';
import * as Icons from 'lucide-react';
import { db } from '@/lib/surrealdb';

interface StudioWidgetProps {
  widget: any;
  initialData?: any;
}

export const StudioWidget: React.FC<StudioWidgetProps> = ({ 
  widget, 
  initialData 
}) => {
  const [data, setData] = useState(initialData);

  useEffect(() => {
    if (widget.refresh_interval && widget.query) {
      const interval = setInterval(async () => {
        const result = await db.query(`
          SELECT fn::studio_execute_widget_query('${widget.code}')
        `);
        
        if (result?.[0]?.data) {
          setData(result[0].data);
        }
      }, widget.refresh_interval);

      return () => clearInterval(interval);
    }
  }, [widget]);

  const renderWidget = () => {
    switch (widget.type) {
      case 'stat':
        return <StatWidget widget={widget} data={data} />;
      case 'chart':
        return <ChartWidget widget={widget} data={data} />;
      case 'table':
        return <TableWidget widget={widget} data={data} />;
      case 'card':
        return <CardWidget widget={widget} data={data} />;
      default:
        return <div>Unknown widget type: {widget.type}</div>;
    }
  };

  return (
    <div className="bg-surface rounded-lg border border-border p-6">
      {widget.title && (
        <h3 className="text-lg font-semibold text-text mb-4">
          {widget.title.fr}
        </h3>
      )}
      {renderWidget()}
    </div>
  );
};

// Stat Widget
const StatWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  const Icon = widget.config.icon 
    ? Icons[widget.config.icon as keyof typeof Icons] 
    : null;

  const formatValue = (value: number) => {
    if (widget.config.format === 'currency') {
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: widget.config.currency || 'EUR'
      }).format(value);
    }
    return value.toLocaleString('fr-FR');
  };

  return (
    <div className="flex items-center gap-4">
      {Icon && (
        <div className={`p-3 rounded-lg bg-${widget.config.color}-100`}>
          <Icon className={`w-8 h-8 text-${widget.config.color}-600`} />
        </div>
      )}
      <div>
        <p className="text-3xl font-bold text-text">
          {formatValue(data?.count || data?.total || 0)}
        </p>
      </div>
    </div>
  );
};

// Chart Widget (simplifié)
const ChartWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  return (
    <div>
      <p className="text-text-secondary">Chart: {widget.config.chart_type}</p>
      <pre className="text-xs">{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};

// Table Widget
const TableWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  return (
    <table className="w-full">
      <thead>
        <tr className="border-b border-border">
          {widget.config.columns.map((col: any) => (
            <th key={col.field} className="text-left py-2 text-sm font-medium text-text">
              {col.label.fr}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data && Array.isArray(data) && data.map((row: any, i: number) => (
          <tr key={i} className="border-b border-border">
            {widget.config.columns.map((col: any) => (
              <td key={col.field} className="py-2 text-sm text-text-secondary">
                {row[col.field]}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
};

// Card Widget
const CardWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  return <div className="text-text">{data?.content || 'No content'}</div>;
};
```

---

## 📝 Composant : StudioForm

```typescript
// components/studio/StudioForm.tsx
import React, { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';

interface StudioFormProps {
  formCode: string;
  recordId?: string;
  onSubmit?: (result: any) => void;
  onCancel?: () => void;
}

export const StudioForm: React.FC<StudioFormProps> = ({ 
  formCode,
  recordId,
  onSubmit,
  onCancel
}) => {
  const [form, setForm] = useState<any>(null);
  const [formData, setFormData] = useState<any>({});
  const [errors, setErrors] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadForm = async () => {
      try {
        const result = await db.query(`
          SELECT * FROM studio_form WHERE code = '${formCode}'
        `);
        
        if (result?.[0]) {
          setForm(result[0]);
          
          // Si édition, charger les données
          if (recordId) {
            const record = await db.query(`SELECT * FROM ${recordId}`);
            setFormData(record[0] || {});
          }
        }
      } catch (error) {
        console.error('Failed to load form:', error);
      } finally {
        setLoading(false);
      }
    };

    loadForm();
  }, [formCode, recordId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      const result = await db.query(`
        SELECT fn::studio_submit_form(
          '${formCode}',
          ${JSON.stringify(formData)},
          ${recordId ? `type::record('${form.table}', '${recordId}')` : 'NONE'}
        )
      `);
      
      if (result?.[0]?.success) {
        onSubmit?.(result[0]);
      } else {
        setErrors(result?.[0]?.errors || []);
      }
    } catch (error) {
      console.error('Form submission error:', error);
    }
  };

  if (loading) return <div>Loading form...</div>;
  if (!form) return <div>Form not found</div>;

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <h2 className="text-2xl font-bold text-text">{form.title.fr}</h2>

      {errors.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded p-4">
          <ul>
            {errors.map((err, i) => (
              <li key={i} className="text-red-600 text-sm">{err.message}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="space-y-4">
        {form.fields
          .sort((a: any, b: any) => a.order - b.order)
          .map((field: any) => (
            <div key={field.name}>
              <label className="block text-sm font-medium text-text mb-1">
                {field.label.fr}
                {field.required && <span className="text-red-500 ml-1">*</span>}
              </label>
              
              {field.type === 'text' || field.type === 'email' || field.type === 'tel' ? (
                <input
                  type={field.type}
                  name={field.name}
                  value={formData[field.name] || ''}
                  onChange={(e) => setFormData({ ...formData, [field.name]: e.target.value })}
                  placeholder={field.placeholder?.fr}
                  required={field.required}
                  className="w-full px-3 py-2 border border-border rounded-lg focus:ring-2 focus:ring-primary"
                />
              ) : field.type === 'textarea' ? (
                <textarea
                  name={field.name}
                  value={formData[field.name] || ''}
                  onChange={(e) => setFormData({ ...formData, [field.name]: e.target.value })}
                  placeholder={field.placeholder?.fr}
                  required={field.required}
                  rows={field.rows || 4}
                  className="w-full px-3 py-2 border border-border rounded-lg focus:ring-2 focus:ring-primary"
                />
              ) : field.type === 'select' ? (
                <select
                  name={field.name}
                  value={formData[field.name] || field.default}
                  onChange={(e) => setFormData({ ...formData, [field.name]: e.target.value })}
                  required={field.required}
                  className="w-full px-3 py-2 border border-border rounded-lg focus:ring-2 focus:ring-primary"
                >
                  {field.options.map((opt: any) => (
                    <option key={opt.value} value={opt.value}>
                      {opt.label.fr}
                    </option>
                  ))}
                </select>
              ) : null}
            </div>
          ))}
      </div>

      <div className="flex gap-4">
        <button
          type="submit"
          className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark transition-colors"
        >
          {form.submit_button.label.fr}
        </button>
        
        {form.cancel_button && onCancel && (
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 border border-border rounded-lg hover:bg-surface transition-colors"
          >
            {form.cancel_button.label.fr}
          </button>
        )}
      </div>
    </form>
  );
};
```

---

## 🔌 Utilisation Complète dans App.tsx

```typescript
// App.tsx
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { StudioEngine } from '@/components/studio/StudioEngine';
import { StudioPage } from '@/components/studio/StudioPage';
import { useAuth } from '@/hooks/useAuth';

function App() {
  const { user } = useAuth();
  const tenant = user?.tenant_id || 'lyxal';

  return (
    <BrowserRouter>
      <StudioEngine tenant={tenant}>
        <Routes>
          {/* Routes dynamiques */}
          <Route path="/crm/dashboard" element={
            <StudioPage pageCode="crm_dashboard" tenant={tenant} />
          } />
          
          <Route path="/sales/dashboard" element={
            <StudioPage pageCode="sales_dashboard" tenant={tenant} />
          } />
          
          {/* Route générique pour toutes les pages Studio */}
          <Route path="/:module/:page" element={<DynamicStudioPage tenant={tenant} />} />
        </Routes>
      </StudioEngine>
    </BrowserRouter>
  );
}

// Composant pour charger dynamiquement n'importe quelle page
const DynamicStudioPage = ({ tenant }: { tenant: string }) => {
  const { module, page } = useParams();
  const pageCode = `${module}_${page}`;
  
  return <StudioPage pageCode={pageCode} tenant={tenant} />;
};

export default App;
```

---

---

## 📱 Intégration Mobile

### Installation React Native

```bash
# Projet React Native
npx react-native init LyxalMobile

# Dépendances
npm install surrealdb.js
npm install @react-navigation/native @react-navigation/drawer @react-navigation/bottom-tabs
npm install react-native-paper react-native-vector-icons
npm install react-native-chart-kit

# iOS
cd ios && pod install && cd ..
```

### StudioEngine Mobile

```typescript
// App.tsx
import React from 'react';
import { StudioEngine } from '@/components/studio/StudioEngine.native';

export default function App() {
  return <StudioEngine tenant="lyxal" />;
}
```

**Voir documentation complète** : [MOBILE.md](./MOBILE.md)

---

## 🎨 Intégration DaisyUI

### Installation

```bash
npm install -D tailwindcss daisyui
npx tailwindcss init
```

### Configuration

```javascript
// tailwind.config.js
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  plugins: [require('daisyui')],
  daisyui: {
    themes: ['light', 'dark', 'corporate', 'business', 'night'],
  },
}
```

### Application du Thème

```typescript
// Dans StudioEngine
import { useStudioTheme } from '@/hooks/useStudioTheme';

export const StudioEngine = ({ tenant }) => {
  const { config } = useStudioConfig(tenant);
  
  // Appliquer thème DaisyUI depuis DB
  useStudioTheme({
    web_theme: config?.web_theme,
    daisy_custom: config?.daisy_custom,
  });
  
  return (
    <div className="h-screen">
      {/* UI avec composants DaisyUI */}
    </div>
  );
};
```

**Voir documentation complète** : [DAISYUI.md](./DAISYUI.md)

---

## 📊 Architecture Multi-Plateforme

### Configuration Partagée

```surql
-- 1 config pour Web + Mobile
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  
  -- Web (DaisyUI)
  web_theme = "corporate",
  
  -- Mobile (React Native)
  mobile_theme = {
    primary: "#3B82F6",
    secondary: "#10B981"
  },
  
  -- Partagé
  enabled_modules = ["crm", "sales"];
```

### Flux Multi-Plateforme

```
┌──────────────────────────────────────────────┐
│         SURREALDB CLOUD (Config Unique)       │
└────────────────┬─────────────────────────────┘
                 │
         ┌───────┴────────┐
         ↓                ↓
┌─────────────────┐  ┌─────────────────┐
│   WEB (React)   │  │ MOBILE (RN)     │
│  + DaisyUI      │  │ + RN Paper      │
│  • Menus        │  │ • Drawer+Tabs   │
│  • Pages        │  │ • Screens       │
│  • Widgets      │  │ • Widgets       │
└─────────────────┘  └─────────────────┘
```

---

## ✅ Checklist d'Intégration

### Web (React + DaisyUI)

- [ ] SurrealDB Client configuré et connecté
- [ ] Tailwind CSS + DaisyUI installés
- [ ] StudioEngine implémenté et testé
- [ ] StudioMenu fonctionnel avec navigation
- [ ] StudioPage capable de rendre toutes les pages
- [ ] StudioWidget pour tous les types (stat, chart, table)
- [ ] StudioForm complet avec validation
- [ ] LIVE QUERY configuré pour réactivité
- [ ] Thèmes DaisyUI appliqués dynamiquement
- [ ] Dark mode fonctionnel
- [ ] Permissions vérifiées

### Mobile (React Native)

- [ ] React Native configuré (iOS + Android)
- [ ] SurrealDB Client mobile configuré
- [ ] React Navigation installé
- [ ] StudioEngine.native implémenté
- [ ] Navigation Drawer + Tabs fonctionnelle
- [ ] Screens dynamiques (StudioScreen)
- [ ] Widgets natifs (stat, chart, table)
- [ ] Thèmes mobile appliqués
- [ ] Build iOS testé
- [ ] Build Android testé

---

## 🚀 Résultat Final

### Web

```typescript
<StudioEngine tenant="batipro">
  {/* UI générée depuis DB avec DaisyUI ! */}
</StudioEngine>
```

### Mobile

```typescript
<StudioEngine tenant="batipro" />
{/* App native générée depuis la même DB ! */}
```

**1 Config DB = Web + iOS + Android** ! 🎉🌐📱

---

## 📚 Documentation Complémentaire

- **[MOBILE.md](./MOBILE.md)** → Guide complet React Native
- **[DAISYUI.md](./DAISYUI.md)** → Guide complet DaisyUI
- **[DATABASE.md](./DATABASE.md)** → Schémas avec champs web/mobile
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** → Architecture multi-plateforme

---

**Lyxal Studio : Build Once, Run Everywhere** 🎨🚀📱


