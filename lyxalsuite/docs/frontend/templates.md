# 🎨 Templates SaaS par Industrie

## 🎯 Vue d'ensemble

Les **templates LyxalKitUI** sont des configurations pré-construites de pages, composants et workflows adaptés à chaque industrie. Ils permettent de générer automatiquement des SaaS fonctionnels en quelques minutes.

## 🏗️ Architecture des templates

### Structure template
```
templates/{industry}/
├── 📄 pages/
│   ├── dashboard.tsx (accueil personnalisé)
│   ├── specific-page-1.tsx
│   └── specific-page-2.tsx
│
├── 🧩 components/
│   ├── IndustryCard.tsx
│   ├── IndustryForm.tsx
│   └── IndustryChart.tsx
│
├── 📊 workflows/
│   ├── onboarding.json
│   ├── automation.json
│   └── notifications.json
│
├── 🎨 styles/
│   ├── industry-colors.css
│   ├── custom-components.css
│   └── branding.json
│
└── ⚙️ config/
    ├── modules.json (modules activés)
    ├── permissions.json (rôles par défaut)
    └── navigation.json (menu structure)
```

## 🍽️ Template Restaurant

### Configuration
```json
{
  "name": "Restaurant & Food Service",
  "industry": "restaurant",
  "modules": ["auth", "crm", "ecommerce", "analytics"],
  "theme": {
    "primary": "#8B4513",
    "secondary": "#CD853F",
    "accent": "#FF6B35",
    "daisyui_theme": "coffee"
  },
  "roles": [
    { "name": "admin", "label": "Propriétaire/Gérant" },
    { "name": "manager", "label": "Manager" },
    { "name": "staff", "label": "Personnel" },
    { "name": "waiter", "label": "Serveur" }
  ]
}
```

### Pages spécifiques
```typescript
// templates/restaurant/pages/MenuManagementPage.tsx
export function MenuManagementPage() {
  const { menuItems, categories } = useMenu();
  const [selectedCategory, setSelectedCategory] = useState('all');
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold flex items-center gap-2">
            🍽️ Gestion du Menu
          </h1>
          <button className="btn btn-primary">
            ➕ Ajouter un plat
          </button>
        </div>
        
        {/* Filtres catégories */}
        <div className="tabs tabs-boxed mb-6">
          <a 
            className={`tab ${selectedCategory === 'all' ? 'tab-active' : ''}`}
            onClick={() => setSelectedCategory('all')}
          >
            Tous
          </a>
          {categories.map(category => (
            <a 
              key={category.id}
              className={`tab ${selectedCategory === category.id ? 'tab-active' : ''}`}
              onClick={() => setSelectedCategory(category.id)}
            >
              {category.name} ({category.count})
            </a>
          ))}
        </div>
        
        {/* Grille des plats */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {menuItems
            .filter(item => selectedCategory === 'all' || item.category_id === selectedCategory)
            .map(item => (
              <MenuItemCard key={item.id} item={item} />
            ))}
        </div>
      </div>
    </DashboardLayout>
  );
}

// templates/restaurant/pages/ReservationsPage.tsx
export function ReservationsPage() {
  const { reservations, tables } = useReservations();
  const [selectedDate, setSelectedDate] = useState(new Date());
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">📅 Réservations</h1>
        
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Calendrier */}
          <div className="lg:col-span-1">
            <div className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h3 className="card-title">Calendrier</h3>
                <Calendar 
                  value={selectedDate}
                  onChange={setSelectedDate}
                  tileContent={({ date }) => {
                    const dayReservations = getReservationsForDate(reservations, date);
                    return dayReservations.length > 0 ? (
                      <div className="badge badge-primary badge-xs">
                        {dayReservations.length}
                      </div>
                    ) : null;
                  }}
                />
              </div>
            </div>
          </div>
          
          {/* Planning du jour */}
          <div className="lg:col-span-2">
            <div className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h3 className="card-title">
                  Planning du {format(selectedDate, 'dd/MM/yyyy')}
                </h3>
                <RestaurantTimeSlots 
                  date={selectedDate}
                  reservations={getReservationsForDate(reservations, selectedDate)}
                  tables={tables}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

// templates/restaurant/pages/KitchenDisplayPage.tsx
export function KitchenDisplayPage() {
  const { activeOrders } = useKitchenOrders();
  
  return (
    <div className="min-h-screen bg-base-200 p-4">
      <div className="text-center mb-6">
        <h1 className="text-4xl font-bold">👨‍🍳 Écran Cuisine</h1>
        <div className="text-lg opacity-70">
          {format(new Date(), 'HH:mm:ss')} - {activeOrders.length} commandes actives
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {activeOrders.map(order => (
          <KitchenOrderCard key={order.id} order={order} />
        ))}
      </div>
    </div>
  );
}
```

### Composants restaurant
```typescript
// templates/restaurant/components/MenuItemCard.tsx
export function MenuItemCard({ item }: { item: MenuItem }) {
  const [isEditing, setIsEditing] = useState(false);
  
  return (
    <div className="card bg-base-100 shadow-xl">
      <figure className="h-48">
        <img 
          src={item.image || '/placeholder-dish.jpg'} 
          alt={item.name}
          className="w-full h-full object-cover"
        />
      </figure>
      
      <div className="card-body">
        <h3 className="card-title">
          {item.name}
          <div className="badge badge-secondary">{item.price}€</div>
        </h3>
        
        <p className="text-sm opacity-70">{item.description}</p>
        
        {/* Allergènes */}
        {item.allergens?.length > 0 && (
          <div className="flex flex-wrap gap-1">
            {item.allergens.map(allergen => (
              <div key={allergen} className="badge badge-warning badge-xs">
                {allergen}
              </div>
            ))}
          </div>
        )}
        
        {/* Actions */}
        <div className="card-actions justify-end">
          <div className="form-control">
            <label className="label cursor-pointer">
              <span className="label-text mr-2">Disponible</span>
              <input 
                type="checkbox" 
                className="toggle toggle-primary"
                checked={item.available}
                onChange={(e) => updateItemAvailability(item.id, e.target.checked)}
              />
            </label>
          </div>
          
          <button 
            className="btn btn-sm btn-primary"
            onClick={() => setIsEditing(true)}
          >
            ✏️ Modifier
          </button>
        </div>
      </div>
    </div>
  );
}

// templates/restaurant/components/ReservationCard.tsx
export function ReservationCard({ reservation }: { reservation: Reservation }) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed': return 'badge-success';
      case 'seated': return 'badge-info';
      case 'completed': return 'badge-neutral';
      case 'cancelled': return 'badge-error';
      default: return 'badge-warning';
    }
  };
  
  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <div className="flex justify-between items-start">
          <h3 className="card-title">{reservation.customer_name}</h3>
          <div className={`badge ${getStatusColor(reservation.status)}`}>
            {reservation.status}
          </div>
        </div>
        
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            🕒 {format(reservation.datetime, 'HH:mm')}
          </div>
          <div className="flex items-center gap-2">
            👥 {reservation.party_size} personnes
          </div>
          {reservation.table_number && (
            <div className="flex items-center gap-2">
              🪑 Table {reservation.table_number}
            </div>
          )}
        </div>
        
        {reservation.special_requests && (
          <div className="alert alert-info">
            💬 {reservation.special_requests}
          </div>
        )}
        
        <div className="card-actions justify-end">
          {reservation.status === 'confirmed' && (
            <>
              <button className="btn btn-sm btn-primary">
                ✅ Installer
              </button>
              <button className="btn btn-sm btn-error">
                ❌ Annuler
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
```

## 💰 Template Finance

### Configuration
```json
{
  "name": "Services Financiers",
  "industry": "finance",
  "modules": ["auth", "crm", "analytics", "ai"],
  "theme": {
    "primary": "#1E40AF",
    "secondary": "#3B82F6",
    "accent": "#10B981",
    "daisyui_theme": "business"
  },
  "roles": [
    { "name": "advisor", "label": "Conseiller Financier" },
    { "name": "analyst", "label": "Analyste" },
    { "name": "client", "label": "Client" }
  ]
}
```

### Pages spécifiques
```typescript
// templates/finance/pages/PortfolioManagementPage.tsx
export function PortfolioManagementPage() {
  const { portfolios, marketData } = usePortfolios();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">📊 Gestion Portefeuilles</h1>
        
        {/* Vue d'ensemble */}
        <div className="stats shadow mb-6">
          <div className="stat">
            <div className="stat-figure text-primary">
              💰
            </div>
            <div className="stat-title">AUM Total</div>
            <div className="stat-value text-primary">€2.4M</div>
            <div className="stat-desc">+12% ce mois</div>
          </div>
          
          <div className="stat">
            <div className="stat-figure text-success">
              📈
            </div>
            <div className="stat-title">Performance YTD</div>
            <div className="stat-value text-success">+8.3%</div>
            <div className="stat-desc">vs benchmark +6.1%</div>
          </div>
          
          <div className="stat">
            <div className="stat-figure text-info">
              👥
            </div>
            <div className="stat-title">Clients actifs</div>
            <div className="stat-value text-info">47</div>
            <div className="stat-desc">+3 ce mois</div>
          </div>
        </div>
        
        {/* Performance globale */}
        <div className="card bg-base-100 shadow-xl mb-6">
          <div className="card-body">
            <h3 className="card-title">Performance Globale</h3>
            <PortfolioPerformanceChart data={marketData} />
          </div>
        </div>
        
        {/* Liste portefeuilles */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {portfolios.map(portfolio => (
            <PortfolioCard key={portfolio.id} portfolio={portfolio} />
          ))}
        </div>
      </div>
    </DashboardLayout>
  );
}

// templates/finance/pages/ClientAnalysisPage.tsx
export function ClientAnalysisPage() {
  const { clients, analytics } = useClientAnalysis();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">🎯 Analyse Clientèle</h1>
        
        {/* Segmentation clients */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          {analytics.segments.map(segment => (
            <div key={segment.name} className="stat bg-base-100 shadow rounded-lg">
              <div className="stat-title">{segment.name}</div>
              <div className="stat-value text-primary">{segment.count}</div>
              <div className="stat-desc">{segment.percentage}% du total</div>
            </div>
          ))}
        </div>
        
        {/* Répartition par profil de risque */}
        <div className="card bg-base-100 shadow-xl mb-6">
          <div className="card-body">
            <h3 className="card-title">Répartition par Profil de Risque</h3>
            <RiskProfileChart data={analytics.riskDistribution} />
          </div>
        </div>
        
        {/* Pipeline clients */}
        <FinancePipelineView clients={clients} />
      </div>
    </DashboardLayout>
  );
}
```

## 🛒 Template E-commerce

### Configuration
```json
{
  "name": "E-commerce & Retail",
  "industry": "ecommerce",
  "modules": ["auth", "crm", "ecommerce", "analytics", "ai"],
  "theme": {
    "primary": "#7C3AED",
    "secondary": "#A855F7",
    "accent": "#F59E0B",
    "daisyui_theme": "corporate"
  },
  "roles": [
    { "name": "owner", "label": "Propriétaire" },
    { "name": "manager", "label": "Manager" },
    { "name": "support", "label": "Support Client" }
  ]
}
```

### Pages spécifiques
```typescript
// templates/ecommerce/pages/InventoryManagementPage.tsx
export function InventoryManagementPage() {
  const { products, lowStockAlerts } = useInventory();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">📦 Gestion Stock</h1>
        
        {/* Alertes stock faible */}
        {lowStockAlerts.length > 0 && (
          <div className="alert alert-warning mb-6">
            <div>
              ⚠️ {lowStockAlerts.length} produits en stock faible
              <button className="btn btn-sm btn-warning ml-4">
                Voir détails
              </button>
            </div>
          </div>
        )}
        
        {/* Métriques stock */}
        <div className="stats shadow mb-6">
          <div className="stat">
            <div className="stat-title">Produits actifs</div>
            <div className="stat-value">{products.filter(p => p.active).length}</div>
          </div>
          <div className="stat">
            <div className="stat-title">Valeur stock</div>
            <div className="stat-value text-primary">
              €{products.reduce((acc, p) => acc + (p.stock * p.cost_price), 0).toLocaleString()}
            </div>
          </div>
          <div className="stat">
            <div className="stat-title">Rotation moyenne</div>
            <div className="stat-value text-info">12.5</div>
          </div>
        </div>
        
        {/* Table produits */}
        <InventoryTable products={products} />
      </div>
    </DashboardLayout>
  );
}

// templates/ecommerce/pages/OrderFulfillmentPage.tsx
export function OrderFulfillmentPage() {
  const { orders, fulfillmentStats } = useOrderFulfillment();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">🚚 Traitement Commandes</h1>
        
        {/* Workflow commandes */}
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-4 mb-6">
          {fulfillmentStats.stages.map(stage => (
            <div key={stage.name} className="card bg-base-100 shadow-xl">
              <div className="card-body text-center">
                <h3 className="card-title justify-center">{stage.name}</h3>
                <div className="text-3xl font-bold text-primary">{stage.count}</div>
                <progress 
                  className="progress progress-primary" 
                  value={stage.percentage} 
                  max="100"
                />
              </div>
            </div>
          ))}
        </div>
        
        {/* Commandes en attente */}
        <OrderKanbanBoard orders={orders} />
      </div>
    </DashboardLayout>
  );
}
```

## 🏥 Template Healthcare

### Configuration
```json
{
  "name": "Santé & Bien-être",
  "industry": "healthcare",
  "modules": ["auth", "crm", "analytics"],
  "theme": {
    "primary": "#059669",
    "secondary": "#10B981",
    "accent": "#3B82F6",
    "daisyui_theme": "emerald"
  },
  "roles": [
    { "name": "doctor", "label": "Médecin" },
    { "name": "nurse", "label": "Infirmier" },
    { "name": "receptionist", "label": "Réceptionniste" },
    { "name": "patient", "label": "Patient" }
  ]
}
```

### Pages spécifiques
```typescript
// templates/healthcare/pages/PatientManagementPage.tsx
export function PatientManagementPage() {
  const { patients, appointments } = usePatients();
  
  return (
    <DashboardLayout>
      <div className="container mx-auto p-6">
        <h1 className="text-3xl font-bold mb-6">👥 Gestion Patients</h1>
        
        {/* Statistiques du jour */}
        <div className="stats shadow mb-6">
          <div className="stat">
            <div className="stat-title">RDV aujourd'hui</div>
            <div className="stat-value text-primary">{appointments.today}</div>
          </div>
          <div className="stat">
            <div className="stat-title">Patients vus</div>
            <div className="stat-value text-success">{appointments.completed}</div>
          </div>
          <div className="stat">
            <div className="stat-title">En attente</div>
            <div className="stat-value text-warning">{appointments.waiting}</div>
          </div>
        </div>
        
        {/* Planning du jour */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <div className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h3 className="card-title">Planning du jour</h3>
                <AppointmentSchedule appointments={appointments.today_list} />
              </div>
            </div>
          </div>
          
          <div>
            <div className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h3 className="card-title">Patients récents</h3>
                <RecentPatientsList patients={patients.recent} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
```

## 🔧 Système de génération

### Service de template
```typescript
// utils/templateService.ts
export class TemplateService {
  async generateSaaSFromTemplate(
    industry: string,
    saasConfig: SaaSConfig
  ): Promise<GeneratedSaaS> {
    
    // 1. Récupération template
    const template = await this.getTemplate(industry);
    
    // 2. Génération pages
    const pages = await this.generatePages(template, saasConfig);
    
    // 3. Configuration navigation
    const navigation = await this.generateNavigation(template, saasConfig.modules);
    
    // 4. Application branding
    const themedPages = await this.applyBranding(pages, saasConfig.branding);
    
    // 5. Optimisation bundle
    const optimizedBundle = await this.optimizeBundle(themedPages, saasConfig.modules);
    
    return {
      pages: themedPages,
      navigation: navigation,
      bundle: optimizedBundle,
      size: optimizedBundle.size
    };
  }
  
  private async generateNavigation(
    template: Template,
    enabledModules: string[]
  ): Promise<NavigationConfig> {
    const baseNavigation = template.navigation;
    
    // Filtrage selon modules activés
    return {
      ...baseNavigation,
      items: baseNavigation.items.filter(item => 
        enabledModules.includes(item.module)
      )
    };
  }
}
```

### Builder de composants
```typescript
// utils/componentBuilder.ts
export class ComponentBuilder {
  async buildIndustryComponent(
    baseComponent: string,
    industry: string,
    customizations: any
  ): Promise<string> {
    
    const template = `
      import { ${baseComponent} } from '@lyxal/ui-kit';
      import { ${industry}Theme } from '../themes/${industry}';
      
      export function Industry${baseComponent}(props) {
        return (
          <${industry}Theme>
            <${baseComponent} 
              {...props}
              industry="${industry}"
              customizations={${JSON.stringify(customizations)}}
            />
          </${industry}Theme>
        );
      }
    `;
    
    return template;
  }
}
```

---

**🎨 Templates LyxalKitUI : De l'industrie au SaaS fonctionnel en un clic** 