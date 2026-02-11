# 🎨 LyxalKitUI - Frontend Centralisé

## 🎯 Vue d'ensemble

**LyxalKitUI** est la bibliothèque frontend centralisée de LyxalSuite, construite avec **React + DaisyUI 5**. Elle contient TOUTES les pages, composants et templates nécessaires pour générer n'importe quel SaaS.

## 🏗️ Architecture frontend centralisée

### Structure complète
```
lyxalkitui/ (Hub frontend unique)
├── 📄 pages/
│   ├── auth/ (connexion, inscription, profil)
│   ├── crm/ (clients, prospects, pipeline)
│   ├── analytics/ (dashboards, KPIs, rapports)
│   ├── ai/ (agents, chat, automatisation)
│   ├── ecommerce/ (produits, commandes, inventaire)
│   └── admin/ (configuration, utilisateurs)
│
├── 🎨 templates/
│   ├── restaurant/ (menu, réservations, staff)
│   ├── finance/ (portefeuille, analyses, clients)
│   ├── ecommerce/ (boutique, panier, checkout)
│   ├── healthcare/ (patients, rendez-vous, dossiers)
│   └── generic/ (template par défaut)
│
├── 🧩 components/
│   ├── ui/ (DaisyUI natives + custom)
│   ├── forms/ (formulaires métier)
│   ├── charts/ (analytics & reporting)
│   ├── layouts/ (AdminLayout, DashboardLayout)
│   └── industry/ (composants spécifiques industrie)
│
├── 🎭 themes/
│   ├── 35 thèmes DaisyUI natifs
│   ├── Thèmes personnalisés par industrie
│   └── Configuration marque blanche
│
└── 🔧 utils/
    ├── api/ (clients API)
    ├── auth/ (gestion Logto)
    ├── store/ (Zustand state)
    └── build/ (configuration Vite)
```

## 📄 Pages par module

### Module Auth
```typescript
// pages/auth/LoginPage.tsx
export function LoginPage() {
  const { logtoConfig } = useSaaSConfig();
  const { signIn } = useLogto();
  
  return (
    <div className="hero min-h-screen bg-base-200">
      <div className="hero-content flex-col lg:flex-row-reverse">
        <div className="text-center lg:text-left">
          <h1 className="text-5xl font-bold">Connexion</h1>
          <p className="py-6">Accédez à votre espace de travail</p>
        </div>
        
        <div className="card flex-shrink-0 w-full max-w-sm shadow-2xl bg-base-100">
          <div className="card-body">
            <button 
              className="btn btn-primary"
              onClick={() => signIn(logtoConfig.redirectUri)}
            >
              Se connecter
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// pages/auth/ProfilePage.tsx
export function ProfilePage() {
  const { user } = useAuth();
  const { updateProfile } = useUserAPI();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <div className="card bg-base-100 shadow-xl">
          <div className="card-body">
            <h2 className="card-title">Profil utilisateur</h2>
            
            <div className="avatar">
              <div className="w-24 rounded-full">
                <img src={user.avatar} alt={user.name} />
              </div>
            </div>
            
            <div className="form-control">
              <label className="label">
                <span className="label-text">Nom</span>
              </label>
              <input 
                type="text" 
                className="input input-bordered" 
                defaultValue={user.name}
              />
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
```

### Module CRM
```typescript
// pages/crm/CustomersPage.tsx
export function CustomersPage() {
  const { customers, isLoading } = useCustomers();
  const { industry } = useSaaSConfig();
  
  // Colonnes adaptées selon industrie
  const columns = getIndustryColumns(industry);
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">
            {getIndustryLabel(industry, 'customers')}
          </h1>
          <button className="btn btn-primary">
            Ajouter {getIndustryLabel(industry, 'customer')}
          </button>
        </div>
        
        <div className="card bg-base-100 shadow-xl">
          <div className="card-body">
            {isLoading ? (
              <div className="flex justify-center">
                <span className="loading loading-spinner loading-lg"></span>
              </div>
            ) : (
              <DataTable 
                data={customers}
                columns={columns}
                industry={industry}
              />
            )}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

// pages/crm/PipelinePage.tsx
export function PipelinePage() {
  const { pipeline } = usePipeline();
  const { industry } = useSaaSConfig();
  
  const stages = getIndustryPipelineStages(industry);
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">Pipeline de vente</h1>
        
        <div className="flex gap-4 overflow-x-auto">
          {stages.map(stage => (
            <div key={stage.id} className="card bg-base-100 shadow-xl min-w-80">
              <div className="card-body">
                <h3 className="card-title">{stage.name}</h3>
                <div className="badge badge-neutral">{stage.count}</div>
                
                <PipelineColumn 
                  stage={stage}
                  customers={pipeline[stage.id]}
                  industry={industry}
                />
              </div>
            </div>
          ))}
        </div>
      </div>
    </DashboardLayout>
  );
}
```

### Module E-commerce
```typescript
// pages/ecommerce/ProductsPage.tsx
export function ProductsPage() {
  const { products } = useProducts();
  const { industry } = useSaaSConfig();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">
            {industry === 'restaurant' ? 'Menu' : 'Produits'}
          </h1>
          <button className="btn btn-primary">
            Ajouter {industry === 'restaurant' ? 'plat' : 'produit'}
          </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {products.map(product => (
            <ProductCard 
              key={product.id} 
              product={product}
              industry={industry}
            />
          ))}
        </div>
      </div>
    </DashboardLayout>
  );
}

// pages/ecommerce/OrdersPage.tsx
export function OrdersPage() {
  const { orders } = useOrders();
  const { industry } = useSaaSConfig();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">
          {industry === 'restaurant' ? 'Commandes' : 'Commandes'}
        </h1>
        
        <div className="stats shadow mb-6">
          <div className="stat">
            <div className="stat-title">Aujourd'hui</div>
            <div className="stat-value text-primary">12</div>
          </div>
          <div className="stat">
            <div className="stat-title">En cours</div>
            <div className="stat-value text-secondary">3</div>
          </div>
          <div className="stat">
            <div className="stat-title">CA du jour</div>
            <div className="stat-value">€450</div>
          </div>
        </div>
        
        <OrdersTable 
          orders={orders}
          industry={industry}
        />
      </div>
    </DashboardLayout>
  );
}
```

## 🎨 Templates par industrie

### Template Restaurant
```typescript
// templates/restaurant/MenuPage.tsx
export function RestaurantMenuPage() {
  const { menuItems, categories } = useMenu();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">Gestion du menu</h1>
        
        <div className="flex gap-6">
          {/* Sidebar catégories */}
          <div className="w-64">
            <div className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h3 className="card-title">Catégories</h3>
                <ul className="menu">
                  {categories.map(category => (
                    <li key={category.id}>
                      <a className={category.active ? 'active' : ''}>
                        {category.name}
                        <div className="badge">{category.count}</div>
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
          
          {/* Menu items */}
          <div className="flex-1">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {menuItems.map(item => (
                <MenuItemCard key={item.id} item={item} />
              ))}
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

// templates/restaurant/ReservationsPage.tsx
export function RestaurantReservationsPage() {
  const { reservations, tables } = useReservations();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">Réservations</h1>
        
        {/* Vue calendrier */}
        <div className="card bg-base-100 shadow-xl mb-6">
          <div className="card-body">
            <ReservationCalendar 
              reservations={reservations}
              tables={tables}
            />
          </div>
        </div>
        
        {/* Liste réservations du jour */}
        <div className="card bg-base-100 shadow-xl">
          <div className="card-body">
            <h3 className="card-title">Réservations d'aujourd'hui</h3>
            <ReservationsList 
              reservations={reservations.filter(r => isToday(r.date))}
            />
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
```

### Template Finance
```typescript
// templates/finance/PortfolioPage.tsx
export function FinancePortfolioPage() {
  const { portfolios, performance } = usePortfolios();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">Portefeuilles clients</h1>
        
        {/* Stats globales */}
        <div className="stats shadow mb-6">
          <div className="stat">
            <div className="stat-title">AUM Total</div>
            <div className="stat-value text-primary">€2.4M</div>
            <div className="stat-desc">+12% ce mois</div>
          </div>
          <div className="stat">
            <div className="stat-title">Performance</div>
            <div className="stat-value text-success">+8.3%</div>
            <div className="stat-desc">YTD</div>
          </div>
        </div>
        
        {/* Graphique performance */}
        <div className="card bg-base-100 shadow-xl mb-6">
          <div className="card-body">
            <h3 className="card-title">Performance globale</h3>
            <PerformanceChart data={performance} />
          </div>
        </div>
        
        {/* Liste portefeuilles */}
        <PortfoliosList portfolios={portfolios} />
      </div>
    </DashboardLayout>
  );
}

// templates/finance/ClientsPage.tsx
export function FinanceClientsPage() {
  const { clients, analytics } = useFinanceClients();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">Clients</h1>
        
        {/* Métriques clients */}
        <div className="stats shadow mb-6">
          <div className="stat">
            <div className="stat-title">Clients actifs</div>
            <div className="stat-value">{analytics.active_clients}</div>
          </div>
          <div className="stat">
            <div className="stat-title">Nouveaux ce mois</div>
            <div className="stat-value text-primary">{analytics.new_clients}</div>
          </div>
          <div className="stat">
            <div className="stat-title">Revenus moyens</div>
            <div className="stat-value">€{analytics.avg_revenue}</div>
          </div>
        </div>
        
        {/* Pipeline clients */}
        <FinancePipeline clients={clients} />
      </div>
    </DashboardLayout>
  );
}
```

## 🧩 Composants réutilisables

### Composants UI de base
```typescript
// components/ui/DataTable.tsx
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  industry?: string;
  onRowClick?: (row: T) => void;
}

export function DataTable<T>({ data, columns, industry, onRowClick }: DataTableProps<T>) {
  return (
    <div className="overflow-x-auto">
      <table className="table table-zebra">
        <thead>
          <tr>
            {columns.map(column => (
              <th key={column.key}>{column.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, index) => (
            <tr 
              key={index}
              className="hover cursor-pointer"
              onClick={() => onRowClick?.(row)}
            >
              {columns.map(column => (
                <td key={column.key}>
                  {column.render ? column.render(row) : row[column.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// components/ui/FormBuilder.tsx
export function FormBuilder({ schema, onSubmit, industry }: FormBuilderProps) {
  const { register, handleSubmit, formState } = useForm();
  
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {schema.fields.map(field => (
        <div key={field.name} className="form-control">
          <label className="label">
            <span className="label-text">{field.label}</span>
          </label>
          
          {field.type === 'text' && (
            <input 
              type="text"
              className="input input-bordered"
              {...register(field.name, field.validation)}
            />
          )}
          
          {field.type === 'select' && (
            <select 
              className="select select-bordered"
              {...register(field.name, field.validation)}
            >
              {field.options?.map(option => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          )}
          
          {formState.errors[field.name] && (
            <label className="label">
              <span className="label-text-alt text-error">
                {formState.errors[field.name]?.message}
              </span>
            </label>
          )}
        </div>
      ))}
      
      <button type="submit" className="btn btn-primary">
        Enregistrer
      </button>
    </form>
  );
}
```

### Composants analytics
```typescript
// components/charts/MetricsCard.tsx
export function MetricsCard({ title, value, change, icon, color = 'primary' }) {
  return (
    <div className="stat">
      <div className="stat-figure text-primary">
        <div className={`w-8 h-8 ${color}`}>
          {icon}
        </div>
      </div>
      <div className="stat-title">{title}</div>
      <div className={`stat-value text-${color}`}>{value}</div>
      {change && (
        <div className={`stat-desc ${change > 0 ? 'text-success' : 'text-error'}`}>
          {change > 0 ? '+' : ''}{change}% ce mois
        </div>
      )}
    </div>
  );
}

// components/charts/RevenueChart.tsx
export function RevenueChart({ data, industry }: RevenueChartProps) {
  const chartConfig = getIndustryChartConfig(industry);
  
  return (
    <div className="w-full h-80">
      <ResponsiveContainer>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis />
          <Tooltip 
            content={<CustomTooltip industry={industry} />}
          />
          <Line 
            type="monotone" 
            dataKey="revenue" 
            stroke={chartConfig.primaryColor}
            strokeWidth={2}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
```

## 🎭 Thèmes et personnalisation

### Configuration thèmes DaisyUI
```typescript
// themes/themeConfig.ts
export const INDUSTRY_THEMES = {
  restaurant: {
    primary: '#8B4513',
    secondary: '#CD853F', 
    accent: '#FF6B35',
    neutral: '#2A2E37',
    'base-100': '#FFFFFF',
    daisyui_theme: 'coffee'
  },
  
  finance: {
    primary: '#1E40AF',
    secondary: '#3B82F6',
    accent: '#10B981',
    neutral: '#374151',
    'base-100': '#FFFFFF',
    daisyui_theme: 'business'
  },
  
  ecommerce: {
    primary: '#7C3AED',
    secondary: '#A855F7',
    accent: '#F59E0B',
    neutral: '#1F2937',
    'base-100': '#FFFFFF',
    daisyui_theme: 'corporate'
  },
  
  healthcare: {
    primary: '#059669',
    secondary: '#10B981',
    accent: '#3B82F6',
    neutral: '#374151',
    'base-100': '#FFFFFF',
    daisyui_theme: 'emerald'
  }
};

// utils/themeProvider.tsx
export function ThemeProvider({ children, saasConfig }: ThemeProviderProps) {
  const theme = saasConfig?.branding?.theme || 
                INDUSTRY_THEMES[saasConfig?.industry] || 
                INDUSTRY_THEMES.ecommerce;
  
  useEffect(() => {
    // Application dynamique du thème
    document.documentElement.setAttribute('data-theme', theme.daisyui_theme);
    
    // Variables CSS custom
    const root = document.documentElement;
    Object.entries(theme).forEach(([key, value]) => {
      if (key !== 'daisyui_theme') {
        root.style.setProperty(`--${key}`, value);
      }
    });
  }, [theme]);
  
  return <>{children}</>;
}
```

### Personnalisation marque blanche
```typescript
// components/branding/BrandingProvider.tsx
export function BrandingProvider({ children, branding }: BrandingProviderProps) {
  useEffect(() => {
    // Logo
    if (branding.logo) {
      const favicon = document.querySelector('link[rel="icon"]');
      if (favicon) favicon.href = branding.favicon || branding.logo;
    }
    
    // Titre
    if (branding.name) {
      document.title = branding.name;
    }
    
    // Meta description
    if (branding.description) {
      const metaDesc = document.querySelector('meta[name="description"]');
      if (metaDesc) metaDesc.content = branding.description;
    }
    
    // Colors CSS
    if (branding.colors) {
      const root = document.documentElement;
      Object.entries(branding.colors).forEach(([key, value]) => {
        root.style.setProperty(`--color-${key}`, value);
      });
    }
  }, [branding]);
  
  return (
    <BrandingContext.Provider value={branding}>
      {children}
    </BrandingContext.Provider>
  );
}
```

## 🔧 Build et optimisation

### Configuration Vite
```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    react(),
    
    // Tree-shaking intelligent par SaaS
    {
      name: 'saas-tree-shaking',
      generateBundle(options, bundle) {
        // Suppression des modules non utilisés selon config SaaS
        const saasConfig = this.getSaasConfig();
        
        Object.keys(bundle).forEach(key => {
          const chunk = bundle[key];
          if (chunk.type === 'chunk') {
            // Supprime les modules non activés
            chunk.modules = this.filterModulesBySaasConfig(
              chunk.modules, 
              saasConfig
            );
          }
        });
      }
    }
  ],
  
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          // Chunks par module
          'vendor': ['react', 'react-dom'],
          'ui': ['daisyui', 'tailwindcss'],
          'crm': ['./src/pages/crm'],
          'ecommerce': ['./src/pages/ecommerce'],
          'analytics': ['./src/pages/analytics'],
          'ai': ['./src/pages/ai']
        }
      }
    },
    
    // Optimisation selon industrie
    define: {
      __INDUSTRY__: JSON.stringify(process.env.VITE_INDUSTRY),
      __MODULES__: JSON.stringify(process.env.VITE_MODULES?.split(','))
    }
  }
});
```

### Service de build
```typescript
// utils/buildService.ts
export class SaaSBuildService {
  async buildSaaS(saasConfig: SaaSConfig): Promise<BuildResult> {
    // 1. Génération variables d'environnement
    const envVars = this.generateEnvVars(saasConfig);
    
    // 2. Sélection modules
    const enabledModules = saasConfig.modules.enabled;
    
    // 3. Configuration Vite dynamique
    const viteConfig = {
      ...baseViteConfig,
      define: {
        __SAAS_ID__: JSON.stringify(saasConfig.saas_id),
        __INDUSTRY__: JSON.stringify(saasConfig.industry),
        __MODULES__: JSON.stringify(enabledModules),
        __BRANDING__: JSON.stringify(saasConfig.branding)
      }
    };
    
    // 4. Build optimisé
    const buildResult = await build(viteConfig);
    
    // 5. Génération manifest
    const manifest = this.generateManifest(saasConfig, buildResult);
    
    return {
      saas_id: saasConfig.saas_id,
      build_size: buildResult.size,
      chunks: buildResult.chunks,
      manifest: manifest,
      deploy_url: await this.deployToS3(buildResult, saasConfig.domain)
    };
  }
}
```

---

**🎨 LyxalKitUI : Un frontend unique qui génère tous les SaaS possibles** 