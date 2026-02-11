# 🎨 Guide d'Architecture UI - LyxalSuite
*Documentation complète pour la conception des interfaces avec DaisyUI*

## 📋 Vue d'ensemble

LyxalSuite utilise une architecture modulaire où chaque module contient ses propres interfaces UI, avec **DaisyUI 5** comme système de design unifié et **lyxalkitui** comme fondation partagée.

---

## 🏗️ Architecture des Modules

### **Structure standard d'un module :**

```
lyxal{module}/
├── gateway/              # 🔧 Backend API
│   ├── routes/          # Points d'entrée API
│   ├── services/        # Logique métier  
│   ├── middleware/      # Middlewares
│   └── logic/           # Contrôleurs
├── sdk/                 # 📦 SDKs clients
│   ├── core/           # Types partagés
│   ├── frontend/       # Client React + hooks
│   └── backend/        # Client serveur
├── frontend/           # 🎨 Interface UI (NOUVEAU)
│   ├── pages/          # Pages principales du module
│   ├── components/     # Composants spécifiques au module
│   ├── layouts/        # Layouts spécifiques (optionnel)
│   └── utils/          # Utilitaires UI du module
└── docs/              # Documentation du module
```

### **Exemple concret - lyxalauth :**

```
lyxalauth/
├── gateway/           # API Auth (✅ existant)
├── sdk/              # SDKs Auth (✅ existant)  
├── frontend/         # 🆕 UI Auth à créer
│   ├── pages/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── ProfilePage.tsx
│   │   ├── SettingsPage.tsx
│   │   └── ForgotPasswordPage.tsx
│   ├── components/
│   │   ├── LoginForm.tsx
│   │   ├── UserAvatar.tsx
│   │   ├── PasswordField.tsx
│   │   └── AuthCard.tsx
│   └── utils/
│       ├── authValidation.ts
│       └── authHelpers.ts
└── docs/
```

---

## 🎨 Rôle de lyxalkitui

### **Responsabilités de lyxalkitui :**

```
lyxalkitui/
├── src/
│   ├── layouts/         # 🏗️ Layouts génériques
│   │   ├── MainLayout.tsx      # Layout principal avec sidebar
│   │   ├── AuthLayout.tsx      # Layout pour auth (sans sidebar)
│   │   ├── DashboardLayout.tsx # Layout dashboard
│   │   └── PublicLayout.tsx    # Layout public
│   ├── navigation/      # 🧭 Navigation partagée
│   │   ├── Sidebar.tsx         # Sidebar adaptative
│   │   ├── Navbar.tsx          # Navbar générique
│   │   └── Breadcrumb.tsx      # Fil d'Ariane
│   ├── themes/          # 🎭 Système de thèmes
│   │   ├── globals.css         # Configuration DaisyUI
│   │   ├── ThemeProvider.tsx   # Provider de thème
│   │   └── presets/           # 35 thèmes configurés
│   ├── permissions/     # 🔐 Gestion des permissions
│   │   ├── PermissionProvider.tsx
│   │   ├── usePermissions.ts
│   │   └── PermissionGuard.tsx
│   ├── utils/           # 🛠️ Hooks communs
│   │   ├── useTheme.ts
│   │   ├── useModuleConfig.ts
│   │   └── useConditionalUI.ts
│   └── types/           # 📝 Types partagés
│       ├── permissions.ts
│       ├── themes.ts
│       └── modules.ts
```

### **Ce que lyxalkitui NE contient PAS :**
- ❌ Pages spécifiques aux modules
- ❌ Composants métier
- ❌ Logique fonctionnelle
- ❌ Formulaires métier

---

## 🌈 Configuration DaisyUI

### **globals.css (lyxalkitui) :**

```css
@import "tailwindcss";
@plugin "daisyui" {
  themes: light --default, dark --prefersdark, cupcake, bumblebee, emerald, 
          corporate, synthwave, retro, cyberpunk, valentine, halloween, 
          garden, forest, aqua, lofi, pastel, fantasy, wireframe, black, 
          luxury, dracula, cmyk, autumn, business, acid, lemonade, night, 
          coffee, winter, dim, nord, sunset;
  root: ":root";
  logs: false;
}
```

### **Utilisation dans les modules :**

```typescript
// lyxalcrm/frontend/pages/ContactsPage.tsx
import { MainLayout } from '@lyxalsuite/lyxalkitui';
import { useAuth } from '../sdk/frontend';

export function ContactsPage() {
  const { user } = useAuth();
  
  return (
    <MainLayout title="Contacts CRM">
      <div className="container mx-auto p-6">
        {/* Header avec DaisyUI */}
        <div className="navbar bg-base-200 rounded-lg mb-6">
          <div className="navbar-start">
            <h1 className="text-2xl font-bold">Contacts</h1>
          </div>
          <div className="navbar-end">
            <button className="btn btn-primary">
              Nouveau Contact
            </button>
          </div>
        </div>

        {/* Contenu avec DaisyUI */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <ContactList />
          </div>
          <div>
            <ContactFilters />
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
```

---

## 🔐 Gestion des Permissions UI

### **Configuration par SaaS :**

```typescript
// Configuration stockée en base/variable
interface SaasConfig {
  modules: {
    crm: {
      enabled: boolean;
      features: {
        contacts: boolean;
        leads: boolean;
        marketing: boolean;
        reports: boolean;
      };
    };
    analytics: {
      enabled: boolean;
      features: {
        dashboard: boolean;
        reports: boolean;
        exports: boolean;
      };
    };
  };
  theme: string;
  branding: {
    logo: string;
    name: string;
    colors: object;
  };
}
```

### **Hook usePermissions (lyxalkitui) :**

```typescript
// lyxalkitui/src/utils/usePermissions.ts
export function usePermissions() {
  const config = useModuleConfig();
  
  const hasModule = (module: string) => {
    return config.modules[module]?.enabled || false;
  };
  
  const hasFeature = (module: string, feature: string) => {
    return config.modules[module]?.features[feature] || false;
  };
  
  return { hasModule, hasFeature, config };
}
```

### **Utilisation conditionnelle :**

```typescript
// lyxalcrm/frontend/components/ContactCard.tsx
import { usePermissions } from '@lyxalsuite/lyxalkitui';

export function ContactCard({ contact }) {
  const { hasFeature } = usePermissions();
  
  return (
    <div className="card bg-base-100 shadow-lg">
      <div className="card-body">
        <h3 className="card-title">{contact.name}</h3>
        <p>{contact.email}</p>
        
        <div className="card-actions justify-end">
          <button className="btn btn-sm btn-ghost">Voir</button>
          <button className="btn btn-sm btn-ghost">Éditer</button>
          
          {/* Conditionnel selon permissions */}
          {hasFeature('crm', 'marketing') && (
            <button className="btn btn-sm btn-secondary">
              Campaign
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
```

---

## 🚀 Processus de Génération SaaS

### **1. Agent IA analyse la demande**
```
Input: "CRM pour agence immobilière, style professionnel"
→ Sélection: lyxalcrm + lyxalanalytics + thème "corporate"
```

### **2. Configuration générée**
```typescript
const generatedConfig: SaasConfig = {
  modules: {
    crm: {
      enabled: true,
      features: {
        contacts: true,
        leads: true,
        marketing: false,  // Pas nécessaire pour immobilier
        reports: true
      }
    },
    analytics: {
      enabled: true,
      features: {
        dashboard: true,
        reports: true,
        exports: false     // Version basique
      }
    }
  },
  theme: "corporate",
  branding: {
    name: "ImmoPro CRM",
    logo: "generated-logo.png"
  }
};
```

### **3. Assemblage automatique**
- Copie des modules activés
- Injection de la configuration
- Application du thème
- Déploiement sur sous-domaine

---

## 📱 Exemples d'Interfaces DaisyUI

### **Page Dashboard (lyxalanalytics) :**

```typescript
export function AnalyticsDashboard() {
  return (
    <MainLayout title="Analytics">
      <div className="container mx-auto p-6">
        {/* Hero section */}
        <div className="hero bg-base-200 rounded-lg mb-6">
          <div className="hero-content text-center">
            <div>
              <h1 className="text-4xl font-bold">Tableau de Bord</h1>
              <p className="py-6">Vos métriques en temps réel</p>
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="stat bg-base-100 shadow rounded-lg">
            <div className="stat-title">Ventes</div>
            <div className="stat-value text-primary">25.6K</div>
            <div className="stat-desc">+12% ce mois</div>
          </div>
          <div className="stat bg-base-100 shadow rounded-lg">
            <div className="stat-title">Utilisateurs</div>
            <div className="stat-value text-secondary">2.6K</div>
            <div className="stat-desc">+5% ce mois</div>
          </div>
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card bg-base-100 shadow-lg">
            <div className="card-body">
              <h2 className="card-title">Évolution des ventes</h2>
              {/* Chart component */}
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
```

### **Formulaire (lyxalcrm) :**

```typescript
export function ContactForm() {
  return (
    <div className="card bg-base-100 shadow-lg max-w-md mx-auto">
      <div className="card-body">
        <h2 className="card-title">Nouveau Contact</h2>
        
        <form className="space-y-4">
          <div className="form-control">
            <label className="label">
              <span className="label-text">Nom complet</span>
            </label>
            <input 
              type="text" 
              className="input input-bordered w-full" 
              placeholder="John Doe" 
            />
          </div>

          <div className="form-control">
            <label className="label">
              <span className="label-text">Email</span>
            </label>
            <input 
              type="email" 
              className="input input-bordered w-full" 
              placeholder="john@example.com" 
            />
          </div>

          <div className="form-control">
            <label className="label">
              <span className="label-text">Téléphone</span>
            </label>
            <input 
              type="tel" 
              className="input input-bordered w-full" 
              placeholder="+33 1 23 45 67 89" 
            />
          </div>

          <div className="card-actions justify-end">
            <button type="button" className="btn btn-ghost">
              Annuler
            </button>
            <button type="submit" className="btn btn-primary">
              Créer
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
```

---

## 📋 Standards et Bonnes Pratiques

### **1. Nomenclature des fichiers :**
```
- Pages : {Feature}Page.tsx (ContactsPage.tsx)
- Composants : {Feature}{Type}.tsx (ContactCard.tsx)
- Layouts : {Purpose}Layout.tsx (DashboardLayout.tsx)
- Hooks : use{Feature}.ts (useContacts.ts)
```

### **2. Classes DaisyUI recommandées :**
```typescript
// Layouts
"container mx-auto p-4"           // Container responsive
"grid grid-cols-1 lg:grid-cols-3" // Grid responsive

// Cards
"card bg-base-100 shadow-lg"      // Card standard
"card-body"                       // Corps de card
"card-title"                      // Titre de card
"card-actions justify-end"        // Actions alignées

// Buttons
"btn btn-primary"                 // Bouton principal
"btn btn-ghost"                   // Bouton transparent
"btn btn-sm"                      // Bouton petit

// Forms
"form-control"                    // Conteneur de champ
"input input-bordered"            // Input avec bordure
"label-text"                      // Label de champ

// Navigation
"navbar bg-base-200"              // Barre de navigation
"navbar-start/center/end"         // Sections navbar
"menu"                           // Menu vertical/horizontal
```

### **3. Structure d'export :**
```typescript
// lyxal{module}/frontend/index.ts
export * from './pages';
export * from './components';
export * from './utils';

// Dans les SaaS générés
import { ContactsPage, ContactCard } from '@lyxalsuite/lyxalcrm/frontend';
import { MainLayout } from '@lyxalsuite/lyxalkitui';
```

---

## 🔄 Workflow de Développement

### **1. Créer un nouveau module :**
```bash
# Structure de base
mkdir lyxal{module}/frontend
mkdir lyxal{module}/frontend/pages
mkdir lyxal{module}/frontend/components
mkdir lyxal{module}/frontend/utils

# Package.json avec dépendances
npm init -y
npm install @lyxalsuite/lyxalkitui react react-dom daisyui
```

### **2. Développer les pages :**
- Utiliser **DaisyUI directement** (pas de composants custom)
- Importer les layouts depuis **lyxalkitui**
- Utiliser les **hooks SDK** du module
- Appliquer les **permissions conditionnelles**

### **3. Tester l'intégration :**
- Vérifier que les thèmes s'appliquent
- Tester les permissions conditionnelles
- Valider la responsivité mobile
- Contrôler l'accessibilité

---

## 🎯 Points Clés à Retenir

### **✅ À FAIRE :**
- UI spécifique → dans le module concerné
- Layouts génériques → dans lyxalkitui
- Permissions UI → via configuration + hooks
- DaisyUI direct → pas de composants wrapper
- Thèmes → gérés automatiquement

### **❌ À ÉVITER :**
- Composants métier dans lyxalkitui
- CSS custom (utiliser DaisyUI + Tailwind)
- Logique permissions dans les modules
- Duplication de layouts
- Thèmes hardcodés

---

## 📊 Exemple de Timeline

### **Développement d'un module complet :**
1. **Backend + SDK** (existant) : 3 semaines
2. **Frontend/UI** : 1 semaine
   - Pages principales : 2 jours
   - Composants spécifiques : 2 jours  
   - Intégration permissions : 1 jour
   - Tests et responsive : 2 jours
3. **Génération SaaS** : Automatique via agent IA

---

*Ce document constitue la référence complète pour l'architecture UI de LyxalSuite. Toute modification de cette architecture doit être documentée ici.* 