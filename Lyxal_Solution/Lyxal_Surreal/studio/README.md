# 🎨 Lyxal Studio - Database-Driven UI

## 🎯 Vision

**Lyxal Studio** est le moteur d'interface dynamique de Lyxal qui permet de **piloter 100% de l'UI depuis SurrealDB**. Créez des menus, pages, formulaires, dashboards et widgets sans écrire une ligne de code frontend.

**Tagline** : *"Build Your Perfect Interface, Database-Driven"*

---

## ✨ Pourquoi Lyxal Studio ?

### Problèmes Résolus

**Sans Lyxal Studio** ❌ :
- Chaque modification d'UI = Redéploiement frontend
- White-Label = Dupliquer le code pour chaque client
- Activation/désactivation de modules = Rebuild complet
- Personnalisation client = Branches Git multiples
- Multi-tenant = Code conditionnel partout

**Avec Lyxal Studio** ✅ :
- Modification d'UI = Simple UPDATE SurrealDB
- White-Label = 1 row dans `studio_config`
- Activation module = `enabled_modules += "crm"`
- Personnalisation = Configuration par tenant
- Multi-tenant = Natif dans la DB

---

## 🏗️ Architecture Globale

```
┌──────────────────────────────────────────────────────────┐
│         REACT FRONTEND (Lyxal Central)                    │
│              Moteur de Rendu Générique                    │
│  • <StudioEngine /> (point d'entrée)                     │
│  • <StudioMenu /> (menus dynamiques)                     │
│  • <StudioPage /> (pages dynamiques)                     │
│  • <StudioForm /> (formulaires dynamiques)               │
│  • <StudioTable /> (listes dynamiques)                   │
│  • <StudioDashboard /> (dashboards dynamiques)           │
└────────────────────────┬─────────────────────────────────┘
                         │ WebSocket Sécurisé (WSS)
                         ↓
┌──────────────────────────────────────────────────────────┐
│              SURREALDB CLOUD (95%)                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │ TABLES STUDIO                                      │  │
│  │  • studio_config      → Configuration globale      │  │
│  │  • studio_menu        → Menus dynamiques           │  │
│  │  • studio_page        → Pages dynamiques           │  │
│  │  • studio_form        → Formulaires dynamiques     │  │
│  │  • studio_table       → Tables/listes dynamiques   │  │
│  │  • studio_dashboard   → Dashboards dynamiques      │  │
│  │  • studio_widget      → Widgets réutilisables      │  │
│  │  • studio_theme       → Thèmes White-Label         │  │
│  │  • studio_permission  → Permissions granulaires    │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │ FONCTIONS STUDIO                                   │  │
│  │  • fn::studio_render_page()                        │  │
│  │  • fn::studio_validate_form()                      │  │
│  │  • fn::studio_check_permission()                   │  │
│  │  • fn::studio_get_menu()                           │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

---

## 🚀 Cas d'Usage

### 1. **White-Label Multi-Tenant**

```surql
-- Configuration Lyxal (par défaut)
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  app_name = "Lyxal Suite",
  logo = "https://cdn.lyxal.com/logo.svg",
  primary_color = "#3B82F6",
  secondary_color = "#10B981",
  enabled_modules = ["crm", "sales", "marketing", "treasury"],
  theme = studio_theme:lyxal_default;

-- Configuration BatiPro (partenaire White-Label)
CREATE studio_config:batipro SET
  tenant_id = "batipro",
  app_name = "BatiPro",
  logo = "https://cdn.batipro.com/logo.svg",
  primary_color = "#FF6B35",
  secondary_color = "#004E89",
  enabled_modules = ["crm", "project"],  -- Seulement 2 modules
  theme = studio_theme:batipro_custom;
```

**Résultat** : 2 SaaS complètement différents avec le même code frontend ! 🎨

### 2. **Activation/Désactivation de Modules**

```surql
-- Activer le module Marketing pour BatiPro
UPDATE studio_config:batipro SET
  enabled_modules += "marketing";

-- Désactiver le module Sales
UPDATE studio_config:batipro SET
  enabled_modules -= "sales";
```

**Résultat** : Interface mise à jour en temps réel (LIVE QUERY) ! ⚡

### 3. **Menus Dynamiques par Rôle**

```surql
-- Menu CRM visible seulement pour users et admins
CREATE studio_menu:crm SET
  code = "crm",
  label = { fr: "CRM", en: "CRM" },
  icon = "Users",
  url = "/crm",
  order = 1,
  permissions = ["user", "admin"];

-- Menu Admin visible seulement pour admins
CREATE studio_menu:admin SET
  code = "admin",
  label = { fr: "Administration", en: "Admin" },
  icon = "Settings",
  url = "/admin",
  order = 99,
  permissions = ["admin"];
```

**Résultat** : Chaque utilisateur voit uniquement ses menus autorisés ! 🔒

### 4. **Pages Configurables**

```surql
-- Dashboard CRM avec widgets configurables
CREATE studio_page:crm_dashboard SET
  code = "crm_dashboard",
  title = { fr: "Tableau de Bord CRM", en: "CRM Dashboard" },
  url = "/crm/dashboard",
  layout = "grid",
  widgets = [
    studio_widget:contacts_count,
    studio_widget:deals_chart,
    studio_widget:recent_activities
  ];
```

**Résultat** : Pages personnalisables sans coder ! 📊

### 5. **Formulaires Sans Code**

```surql
-- Formulaire de création de contact
CREATE studio_form:contact_create SET
  code = "contact_create",
  title = { fr: "Nouveau Contact", en: "New Contact" },
  table = "contact",
  fields = [
    {
      name: "first_name",
      label: { fr: "Prénom", en: "First Name" },
      type: "text",
      required: true
    },
    {
      name: "email",
      label: { fr: "Email", en: "Email" },
      type: "email",
      required: true,
      validation: "email"
    }
  ];
```

**Résultat** : Créer des formulaires en quelques lignes SQL ! 📝

---

## 💡 Niveaux de Pilotage

### Niveau 1 : Configuration Globale ⭐ (Simple)

```
✅ Logo, couleurs, nom d'application
✅ Modules actifs/inactifs
✅ Langue par défaut
✅ Thème (light/dark)

Durée dev : 1 semaine
```

### Niveau 2 : Menus Dynamiques ⭐⭐ (Moyen)

```
✅ Structure de navigation
✅ Permissions par rôle
✅ Icônes et labels multilingues
✅ Menus hiérarchiques

Durée dev : 2 semaines
```

### Niveau 3 : Pages Dynamiques ⭐⭐⭐ (Avancé)

```
✅ Layout personnalisable (grid, flex)
✅ Widgets réutilisables
✅ Queries dynamiques
✅ Dashboards configurables

Durée dev : 3-4 semaines
```

### Niveau 4 : Formulaires Dynamiques ⭐⭐⭐⭐ (Expert)

```
✅ Champs de tous types
✅ Validations dynamiques
✅ Relations entre tables
✅ Conditional logic

Durée dev : 4-6 semaines
```

---

## 🎯 Avantages de Lyxal Studio

### 1. **Multi-Tenant Natif**

```
1 Frontend React
  ↓
N Configurations SurrealDB
  ↓
N SaaS complètement différents
```

### 2. **Déploiement Instantané**

```
Modification DB → Mise à jour UI instantanée
(pas de rebuild, pas de redéploiement)
```

### 3. **White-Label en 5 Minutes**

```surql
-- Créer un nouveau partenaire
CREATE studio_config:new_partner SET
  tenant_id = "new_partner",
  app_name = "New Partner SaaS",
  logo = "...",
  primary_color = "#...",
  enabled_modules = ["crm", "sales"];

-- C'est tout ! Le SaaS est prêt. 🎉
```

### 4. **A/B Testing Facile**

```surql
-- Tester 2 versions d'une page
CREATE studio_page:dashboard_v1 SET ...;
CREATE studio_page:dashboard_v2 SET ...;

-- Changer pour un utilisateur
UPDATE user_preferences SET
  dashboard_version = studio_page:dashboard_v2;
```

### 5. **Cohérence avec Lyxal**

```
Même philosophie : Full SurrealDB
Même stack : SurrealDB Cloud
Même approche : Database-Driven
```

---

## 📚 Documentation

### Fichiers de Documentation

1. **[ARCHITECTURE.md](./ARCHITECTURE.md)**
   - Architecture détaillée
   - Flux de données
   - Composants techniques

2. **[DATABASE.md](./DATABASE.md)**
   - Structure de toutes les tables
   - Schémas complets
   - Index et relations

3. **[FUNCTIONS.md](./FUNCTIONS.md)**
   - Toutes les fonctions SurrealDB
   - Code complet et commenté
   - Cas d'usage

4. **[GUIDE.md](./GUIDE.md)**
   - Guide d'utilisation pas à pas
   - Exemples concrets
   - Bonnes pratiques

5. **[INTEGRATION.md](./INTEGRATION.md)**
   - Intégration avec Lyxal Central (Web)
   - Intégration DaisyUI
   - Intégration React Native (Mobile)
   - API et composants

6. **[MOBILE.md](./MOBILE.md)**
   - Architecture React Native
   - Composants natifs
   - Partage configuration Web/Mobile

7. **[DAISYUI.md](./DAISYUI.md)**
   - Intégration DaisyUI + Lyxal Studio
   - Thèmes dynamiques
   - Composants pré-faits

---

## 🛠️ Stack Technologique

### Backend (SurrealDB)

```yaml
Tables: 9 tables principales
Functions: ~15 fonctions
Events: LIVE QUERY pour réactivité
Permissions: Granulaires par rôle
```

### Frontend Web (React)

```yaml
Framework: React 18+
State: Context API + SurrealDB LIVE QUERY
Styling: Tailwind CSS + DaisyUI
Icons: Lucide React
Package: @lyxal/studio
```

### Frontend Mobile (React Native)

```yaml
Framework: React Native
Navigation: React Navigation (Drawer + Tabs)
UI Library: React Native Paper / NativeBase
Icons: React Native Vector Icons
State: Partagé avec Web (même DB)
```

### Infrastructure

```yaml
Database: SurrealDB Cloud (WSS)
CDN: Bunny CDN
Storage: Bunny Storage (assets, logos)
DNS: Cloudflare
Mobile: Expo / React Native CLI
```

---

## 📊 Comparaison Approches

| Aspect | Code en Dur | Lyxal Studio |
|--------|-------------|--------------|
| **Modification UI** | Rebuild frontend | UPDATE DB |
| **White-Label** | Dupliquer code | 1 row DB |
| **Déploiement** | 10-30 min | Instantané |
| **A/B Testing** | Branches Git | Config DB |
| **Personnalisation** | Code conditionnel | Native |
| **Maintenance** | ⚠️ Complexe | ✅ Simple |

---

## 🎯 Roadmap Lyxal Studio

### Version 1.0 (MVP) - **3-4 semaines**

```
✅ Configuration globale (logo, couleurs)
✅ Menus dynamiques
✅ Permissions par rôle
✅ Pages basiques
✅ Widgets simples (stat cards)
```

### Version 1.1 - **+2 semaines**

```
✅ Formulaires dynamiques
✅ Tables avec colonnes configurables
✅ Dashboards avec layout grid
✅ Thèmes personnalisés
```

### Version 1.2 - **+3 semaines**

```
✅ Conditional logic (if/then)
✅ Relations entre formulaires
✅ Validations avancées
✅ Widgets personnalisés
```

### Version 2.0 - **+4 semaines**

```
✅ Visual page builder (drag & drop)
✅ Workflow automation
✅ Custom CSS par tenant
✅ Export/Import configurations
```

---

## 💰 ROI de Lyxal Studio

### Sans Lyxal Studio

```
Temps dev nouvelle fonctionnalité UI : 5-10 jours
Temps deploy : 30 minutes
Temps création White-Label : 3-5 jours
Maintenance : Complexe (code dupliqué)
```

### Avec Lyxal Studio

```
Temps config nouvelle fonctionnalité UI : 30 minutes
Temps deploy : Instantané (UPDATE DB)
Temps création White-Label : 5 minutes
Maintenance : Simple (centralisée)

Gain : ~90% du temps de dev UI ! 🚀
```

---

## 🚀 Démarrage Rapide

### 1. Installation des Tables

```bash
# Connexion à SurrealDB Cloud
surreal sql \
  --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution \
  --database main

# Import du schéma
surreal import database/studio_schema.surql
```

### 2. Seeds Initiaux

```bash
# Import des configurations par défaut
surreal import seeds/studio_default_config.surql
surreal import seeds/studio_default_menus.surql
```

### 3. Intégration Frontend

```typescript
// App.tsx
import { StudioEngine } from '@lyxal/studio';

const App = () => {
  return (
    <StudioEngine tenant="lyxal">
      {/* L'interface est générée automatiquement */}
    </StudioEngine>
  );
};
```

### 4. Premier Test

```surql
-- Créer une page de test
CREATE studio_page:test_page SET
  code = "test",
  title = { fr: "Page de Test", en: "Test Page" },
  url = "/test",
  layout = "flex",
  widgets = [
    {
      type: "text",
      content: { fr: "Bienvenue dans Lyxal Studio !", en: "Welcome to Lyxal Studio!" }
    }
  ];
```

**Résultat** : Aller sur `/test` et voir la page apparaître ! ✨

---

## 🤝 Intégration avec Autres Modules

### Lyxal Studio + Lyxal Identity

```surql
-- Menus basés sur le rôle Identity
SELECT * FROM studio_menu
WHERE permissions CONTAINS $auth.role;

-- Config différente selon profil (Personal/Pro)
SELECT * FROM studio_config
WHERE profile = $auth.current_profile;
```

### Lyxal Studio + Lyxal Mail

```surql
-- Formulaire pour créer une campagne email
CREATE studio_form:email_campaign SET
  table = "email_campaign",  -- Table de Lyxal Mail
  fields = [
    { name: "name", type: "text" },
    { name: "subject", type: "text" },
    { name: "template", type: "relation", relation_table: "email_template" }
  ];
```

### Lyxal Studio + Modules Business (CRM, Sales, etc.)

```surql
-- Dashboard CRM avec données temps réel
CREATE studio_dashboard:crm SET
  widgets = [
    {
      type: "stat",
      query: "SELECT count() FROM contact WHERE status = 'active'"
    },
    {
      type: "chart",
      query: "SELECT time::month(created_at) AS month, count() FROM deal GROUP BY month"
    }
  ];
```

---

## 📈 Métriques de Succès

**KPIs Lyxal Studio** :

```surql
-- Temps moyen de création d'une page
SELECT AVG(time::diff(updated_at, created_at)) FROM studio_page;

-- Nombre de configurations White-Label
SELECT count() FROM studio_config WHERE tenant_id != 'lyxal';

-- Pages les plus utilisées
SELECT page, count() FROM page_views GROUP BY page ORDER BY count DESC;

-- Taux d'adoption par module
SELECT module, count(DISTINCT tenant_id) FROM studio_config GROUP BY module;
```

---

## 🎨 Vision Long Terme

**Lyxal Studio** deviendra :

1. **Le cœur de Lyxal** : Tous les modules l'utilisent
2. **Un produit standalone** : Vendable séparément
3. **Un standard du marché** : Référence du Database-Driven UI
4. **Une communauté** : Templates partagés entre partenaires

---

## 📝 Licence

Propriétaire - Lyxal © 2025

---

## 📱 Multi-Plateforme (Web + Mobile)

### ✅ Configuration Partagée

**1 configuration SurrealDB → 2 plateformes !**

```surql
-- Configuration unique pour web ET mobile
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  app_name = { fr: "Lyxal Suite", en: "Lyxal Suite" },
  logo = "https://cdn.lyxal.com/logo.svg",
  primary_color = "#3B82F6",
  
  -- Thème Web (DaisyUI)
  web_theme = "corporate",  -- ou custom
  daisy_custom = {
    "primary": "#3B82F6",
    "secondary": "#10B981",
    "accent": "#F59E0B"
  },
  
  -- Thème Mobile (React Native)
  mobile_theme = {
    primary: "#3B82F6",
    secondary: "#10B981",
    background: "#FFFFFF"
  },
  
  enabled_modules = ["crm", "sales"];
```

### Architecture Multi-Plateforme

```
┌──────────────────────────────────────────────┐
│         SURREALDB CLOUD (Config Unique)       │
│  • studio_config (partagé web + mobile)      │
│  • studio_menu (partagé)                     │
│  • studio_page (partagé)                     │
└────────────────┬─────────────────────────────┘
                 │
         ┌───────┴────────┐
         ↓                ↓
┌─────────────────┐  ┌─────────────────┐
│   WEB (React)   │  │ MOBILE (RN)     │
│  + DaisyUI      │  │ + RN Paper      │
│  + Tailwind     │  │ + Navigation    │
└─────────────────┘  └─────────────────┘
```

**Avantages** :
- ✅ 1 seule configuration pour tout
- ✅ Même backend (SurrealDB)
- ✅ Thèmes synchronisés
- ✅ Menus/Pages partagés
- ✅ Moins de maintenance

---

## 🎨 Intégration DaisyUI

### Pourquoi DaisyUI ?

**DaisyUI** est parfait pour Lyxal Studio car :

1. **Thèmes CSS Variables** → Pilotables par DB
2. **Multi-thèmes natif** → White-Label instantané
3. **Dark mode intégré** → 1 attribut HTML
4. **50+ composants** → Moins de code
5. **Tailwind-based** → Performance optimale

### Changement de Thème Instantané

```surql
-- Web : Passer au dark mode pour BatiPro
UPDATE studio_config:batipro SET
  web_theme = "dark";

-- Ou thème personnalisé
UPDATE studio_config:batipro SET
  daisy_custom = {
    "primary": "#FF6B35",
    "secondary": "#004E89"
  };
```

**Résultat** : Tous les utilisateurs basculent instantanément (LIVE QUERY) ! 🌙

### Exemple React avec DaisyUI

```tsx
// Application du thème DaisyUI depuis SurrealDB
const App = () => {
  const { config } = useStudioConfig('lyxal');
  
  return (
    <div data-theme={config.web_theme}>
      <StudioEngine tenant="lyxal">
        <Routes>
          <Route path="/crm" element={<StudioPage pageCode="crm_dashboard" />} />
        </Routes>
      </StudioEngine>
    </div>
  );
};
```

---

## 🔗 Ressources

- [Documentation SurrealDB](https://surrealdb.com/docs)
- [React Documentation](https://react.dev)
- [React Native Documentation](https://reactnative.dev)
- [DaisyUI Documentation](https://daisyui.com)
- [Tailwind CSS](https://tailwindcss.com)
- [Lucide Icons](https://lucide.dev)
- [React Navigation](https://reactnavigation.org)

---

**Lyxal Studio : Build Without Limits, Anywhere** 🎨🚀📱


