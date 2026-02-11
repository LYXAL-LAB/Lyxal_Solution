# 🏗️ Schéma d'Architecture - Identité Lyxal (Modèle Google)

## 📊 Vue d'Ensemble - Flux Utilisateur

```
┌──────────────────────────────────────────────────────────────────────┐
│                      EXPÉRIENCE UTILISATEUR                          │
└──────────────────────────────────────────────────────────────────────┘

1️⃣  CONNEXION UNIQUE
    jean@lyxal.id + password
         ↓
    🔐 auth.lyxal.com
         ↓
    ✅ Connecté partout
    
    
2️⃣  SÉLECTION DE CONTEXTE (Comme Google Apps)
    
    ┌─────────────────────────────────────────────────┐
    │  🆔 Jean Dupont (@jean_dupont_123)             │
    │  ┌───────────────────────────────────────────┐ │
    │  │  Mes Applications SaaS                    │ │
    │  │                                           │ │
    │  │  🏪 Restaurant Bistro (Manager)           │ │
    │  │  💼 Finance Conseil (Conseiller)          │ │
    │  │  ⏰ Scheduler Cron (Admin) ⭐            │ │
    │  │  📊 CRM Pro (User)                        │ │
    │  └───────────────────────────────────────────┘ │
    └─────────────────────────────────────────────────┘
    
    
3️⃣  CHANGEMENT DE CONTEXTE (Instantané)
    
    Clic sur "Scheduler Cron"
         ↓
    Interface change automatiquement
         ↓
    Accès aux monitors/cron jobs
    
    Clic sur "Restaurant Bistro"
         ↓
    Interface change automatiquement
         ↓
    Accès aux commandes/menus
```

---

## 🔄 Architecture Technique Détaillée

### Flux de Connexion

```
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 1 : AUTHENTIFICATION                                     │
└─────────────────────────────────────────────────────────────────┘

Frontend (React)
    │
    │ POST /auth/signup ou /auth/signin
    │ { email, password }
    ↓
SurrealDB (WebSocket RPC)
    │
    │ SCOPE: lyxal_user
    │ NAMESPACE: lyxal_identity
    │ DATABASE: main
    ↓
Authentification via crypto::argon2
    ↓
✅ JWT Token généré
    │
    │ { lyxal_id, email, namespaces: [...] }
    │
    ↓
Frontend stocke token
    │
    │ localStorage.setItem('lyxal_token', token)
    │
    ↓
✅ Utilisateur connecté
```

### Flux de Changement de Contexte

```
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 2 : CHANGEMENT DE CONTEXTE SAAS                          │
└─────────────────────────────────────────────────────────────────┘

Utilisateur clique "Scheduler"
    ↓
Frontend: switchContext('scheduler_cron')
    │
    │ QUERY: SELECT * FROM fn::switch_saas_context($lyxal_id, 'scheduler_cron')
    ↓
SurrealDB Function
    │
    ├─ Vérification permissions
    │  SELECT * FROM user_saas_contexts
    │  WHERE lyxal_id = $lyxal_id
    │    AND saas_id = 'scheduler_cron'
    │    AND status = 'active'
    │
    ├─ Mise à jour last_accessed
    │  UPDATE user_saas_contexts
    │  SET last_accessed = time::now()
    │
    └─ Retour contexte + permissions
       { saas_id, roles, permissions, workspace_ids }
    ↓
Frontend met à jour état local
    │
    │ setCurrentContext(newContext)
    │
    ↓
Event dispatché
    │
    │ window.dispatchEvent('saas-context-changed')
    │
    ↓
✅ Interface change automatiquement
   Modules Scheduler affichés
```

### Flux d'Accès aux Données

```
┌─────────────────────────────────────────────────────────────────┐
│  ÉTAPE 3 : ACCÈS AUX DONNÉES MÉTIER                             │
└─────────────────────────────────────────────────────────────────┘

Frontend demande monitors
    │
    │ QUERY: SELECT * FROM scheduler_user_monitors
    │        WHERE environmentid = $env_id
    ↓
SurrealDB vérifie permissions
    │
    ├─ PERMISSIONS ON scheduler_user_monitors
    │  WHERE lyxal_id = fn::get_lyxal_id($auth)
    │    AND fn::check_permission($auth, 'monitors:read')
    │
    ├─ NAMESPACE: saas_scheduler_cron
    │  DATABASE: main
    │
    └─ ISOLATION: Namespace isolé
    ↓
Données retournées
    │
    │ [{ monitor1 }, { monitor2 }, ...]
    │
    ↓
✅ Affichage dans l'interface
```

---

## 🗄️ Structure des Données - Vue Détaillée

### Base de Données - Organisation

```
SurrealDB Instance
│
├─ 🆔 NAMESPACE: lyxal_identity
│  │
│  ├─ DATABASE: main
│  │  │
│  │  ├─ TABLE: lyxal_users
│  │  │  ├─ jean_dupont_123abc
│  │  │  │  ├─ email: "jean@example.com"
│  │  │  │  ├─ password_hash: "..."
│  │  │  │  ├─ personal_namespace: "user_jean_dupont_123abc"
│  │  │  │  └─ status: "active"
│  │  │  │
│  │  │  └─ marie_martin_456def
│  │  │     ├─ email: "marie@example.com"
│  │  │     └─ ...
│  │  │
│  │  ├─ TABLE: user_saas_contexts
│  │  │  ├─ context_1
│  │  │  │  ├─ lyxal_id: "jean_dupont_123abc"
│  │  │  │  ├─ saas_id: "scheduler_cron"
│  │  │  │  ├─ roles: ["admin"]
│  │  │  │  ├─ permissions: ["monitors:*", "api:unlimited"]
│  │  │  │  └─ legacy_user_id: "12345"  ← Lien vers scheduler_user
│  │  │  │
│  │  │  └─ context_2
│  │  │     ├─ lyxal_id: "jean_dupont_123abc"
│  │  │     ├─ saas_id: "restaurant_bistro"
│  │  │     └─ roles: ["manager"]
│  │  │
│  │  └─ TABLE: user_sessions
│  │     └─ ...
│  │
│  └─ Autres tables (user_profiles, user_activity_log, ...)
│
│
├─ 👤 NAMESPACE: user_jean_dupont_123abc
│  │
│  ├─ DATABASE: main
│  │  │
│  │  ├─ TABLE: personal_data
│  │  │  ├─ theme: "dark"
│  │  │  ├─ language: "fr"
│  │  │  └─ timezone: "Europe/Paris"
│  │  │
│  │  ├─ TABLE: documents
│  │  │  ├─ doc_1: { name: "CV.pdf", url: "...", tags: ["personnel"] }
│  │  │  └─ doc_2: { name: "Facture.pdf", url: "...", tags: ["finance"] }
│  │  │
│  │  ├─ TABLE: notifications
│  │  │  ├─ notif_1: { title: "Monitor down", source_saas_id: "scheduler_cron" }
│  │  │  └─ notif_2: { title: "Nouvelle commande", source_saas_id: "restaurant_bistro" }
│  │  │
│  │  └─ TABLE: saas_contexts
│  │     ├─ scheduler_cron: { favorite: true, pinned: true }
│  │     └─ restaurant_bistro: { favorite: false, pinned: false }
│  │
│  └─ Autres tables personnelles
│
│
├─ ⏰ NAMESPACE: saas_scheduler_cron
│  │
│  ├─ DATABASE: main
│  │  │
│  │  ├─ TABLE: scheduler_user
│  │  │  ├─ 12345  ← Utilisateur existant
│  │  │  │  ├─ email: "jean@example.com"
│  │  │  │  ├─ password: "..." (legacy, optionnel)
│  │  │  │  ├─ usergroupid: record<scheduler_usergroup>:1
│  │  │  │  └─ lyxal_identity_id: record<lyxal_users>:'jean_dupont_123abc' ⬅️ PONT
│  │  │  │
│  │  │  └─ 67890
│  │  │     └─ ...
│  │  │
│  │  ├─ TABLE: scheduler_usergroup
│  │  │  ├─ 1: { title: "Free", max_monitors: 10, ... }
│  │  │  ├─ 2: { title: "Pro", max_monitors: 100, ... }
│  │  │  └─ 3: { title: "Enterprise", max_monitors: 999, ... }
│  │  │
│  │  ├─ TABLE: scheduler_user_monitors
│  │  │  ├─ monitor_1: { userid: 12345, name: "Website", url: "...", ... }
│  │  │  └─ monitor_2: { userid: 12345, name: "API", url: "...", ... }
│  │  │
│  │  └─ Autres tables scheduler (refreshtoken, mfadevice, ...)
│  │
│  └─ OU TABLE: scheduler_lyxal_mapping (si pont externe)
│     ├─ { scheduler_userid: 12345, lyxal_identity_id: 'jean_dupont_123abc' }
│     └─ ...
│
│
├─ 🏪 NAMESPACE: saas_restaurant_bistro
│  │
│  ├─ DATABASE: main
│  │  │
│  │  ├─ TABLE: restaurant_users
│  │  │  └─ user_1: { lyxal_identity_id: 'jean_dupont_123abc', role: 'manager' }
│  │  │
│  │  ├─ TABLE: orders
│  │  │  ├─ order_1: { table: 5, items: [...], total: 45.50 }
│  │  │  └─ order_2: { ... }
│  │  │
│  │  └─ TABLE: menu_items
│  │     ├─ item_1: { name: "Burger", price: 12.50 }
│  │     └─ ...
│  │
│  └─ Autres tables restaurant
│
│
└─ 💼 NAMESPACE: saas_finance_conseil
   │
   └─ DATABASE: main
      ├─ TABLE: clients
      ├─ TABLE: portfolios
      └─ TABLE: transactions
```

---

## 🔐 Isolation et Sécurité

### Modèle d'Isolation

```
┌─────────────────────────────────────────────────────────────────┐
│  COUCHE 1 : IDENTITÉ (Namespace lyxal_identity)                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  lyxal_users                                              │ │
│  │  ├─ jean_dupont_123abc                                    │ │
│  │  └─ marie_martin_456def                                   │ │
│  │                                                             │ │
│  │  user_saas_contexts                                        │ │
│  │  ├─ jean → scheduler_cron (admin)                         │ │
│  │  ├─ jean → restaurant_bistro (manager)                    │ │
│  │  └─ marie → scheduler_cron (user)                         │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                        ↓ ISOLATION TOTALE ↓
┌─────────────────────────────────────────────────────────────────┐
│  COUCHE 2 : NAMESPACES PERSONNELS (1 par utilisateur)           │
│  ┌───────────────────────┐    ┌───────────────────────┐        │
│  │  user_jean_dupont     │    │  user_marie_martin    │        │
│  │  ├─ personal_data     │    │  ├─ personal_data     │        │
│  │  ├─ documents         │    │  ├─ documents         │        │
│  │  └─ notifications     │    │  └─ notifications     │        │
│  └───────────────────────┘    └───────────────────────┘        │
│       ❌ Pas d'accès         ←→      ❌ Pas d'accès            │
└─────────────────────────────────────────────────────────────────┘
                        ↓ ISOLATION TOTALE ↓
┌─────────────────────────────────────────────────────────────────┐
│  COUCHE 3 : NAMESPACES SAAS (1 par SaaS)                        │
│  ┌───────────────────────┐    ┌───────────────────────┐        │
│  │  saas_scheduler_cron  │    │  saas_restaurant      │        │
│  │  ├─ scheduler_user    │    │  ├─ orders            │        │
│  │  ├─ monitors          │    │  ├─ customers         │        │
│  │  └─ jobs              │    │  └─ menu_items        │        │
│  └───────────────────────┘    └───────────────────────┘        │
│       ❌ Pas d'accès         ←→      ❌ Pas d'accès            │
└─────────────────────────────────────────────────────────────────┘

RÈGLE : Un namespace NE PEUT PAS accéder aux données d'un autre namespace
       Seules les functions cross-namespace autorisées le peuvent
```

### Contrôle d'Accès

```
QUAND : Jean accède aux monitors du Scheduler

1️⃣  Vérification identité
    → Token JWT valide ?
    → lyxal_id existe dans lyxal_identity ?
    → Statut = 'active' ?
    ✅ Identité confirmée
    
2️⃣  Vérification contexte SaaS
    → SELECT * FROM user_saas_contexts
      WHERE lyxal_id = 'jean_dupont_123abc'
        AND saas_id = 'scheduler_cron'
        AND status = 'active'
    ✅ Accès au SaaS confirmé
    
3️⃣  Vérification permission
    → 'monitors:read' IN permissions ?
    → OU 'admin' IN roles ?
    → OU '*' IN permissions ?
    ✅ Permission confirmée
    
4️⃣  Accès aux données
    → USE NAMESPACE saas_scheduler_cron
    → SELECT * FROM scheduler_user_monitors
      WHERE environmentid = (
        SELECT environmentid FROM scheduler_user
        WHERE lyxal_identity_id = record<lyxal_users>:'jean_dupont_123abc'
      )
    ✅ Données retournées
```

---

## 🎨 Interface Utilisateur - Exemples Concrets

### Dashboard Principal

```
┌────────────────────────────────────────────────────────────────┐
│  🆔 Jean Dupont (@jean_dupont_123)    [🔔 3]    [👤 Menu]     │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📱 Mes Applications SaaS                                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│  │ 🏪 Restaurant│ │ ⏰ Scheduler │ │ 💼 Finance  │              │
│  │  Bistro     │  │  Cron ⭐   │  │  Conseil    │              │
│  │             │  │             │  │             │              │
│  │  Manager    │  │  Admin      │  │  Conseiller │              │
│  │             │  │             │  │             │              │
│  │  [Ouvrir]   │  │  [Ouvrir]   │  │  [Ouvrir]   │              │
│  └────────────┘  └────────────┘  └────────────┘              │
│                                                                 │
│  📊 Activité Récente (Cross-SaaS)                              │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ ⏰ Scheduler: Monitor "Website" is down      Il y a 2h   │ │
│  │ 🏪 Restaurant: Nouvelle commande #1234       Il y a 3h   │ │
│  │ 💼 Finance: Nouveau client ajouté            Hier        │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│  📁 Mes Documents Personnels                                   │
│  ├─ CV.pdf                                                     │
│  ├─ Facture_janvier.pdf                                        │
│  └─ Contrat.pdf                                                │
└────────────────────────────────────────────────────────────────┘
```

### Interface Scheduler (Après Changement de Contexte)

```
┌────────────────────────────────────────────────────────────────┐
│  🆔 Jean Dupont    [⏰ Scheduler Cron ▼]   [🔔 1]   [👤 Menu] │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ⏰ Lyxal Scheduler - Tableau de Bord                          │
│                                                                 │
│  📊 Vue d'Ensemble                                             │
│  ┌──────────────┬──────────────┬──────────────┐              │
│  │ 12 Monitors  │ 5 Jobs Actifs│ 2 Alertes    │              │
│  │ ✅ 10 Up     │ ⏳ En cours  │ ⚠️ Attention │              │
│  │ ❌ 2 Down    │              │              │              │
│  └──────────────┴──────────────┴──────────────┘              │
│                                                                 │
│  🖥️ Mes Monitors                                              │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ ✅ Website         https://lyxal.com        Réponse: 45ms│ │
│  │ ✅ API             https://api.lyxal.com    Réponse: 23ms│ │
│  │ ❌ Database        db.lyxal.com             Timeout      │ │
│  │ ✅ CDN             cdn.lyxal.com            Réponse: 12ms│ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│  [+ Nouveau Monitor]  [Paramètres]  [Historique]              │
└────────────────────────────────────────────────────────────────┘
```

### Changement Rapide de Contexte (Dropdown)

```
┌────────────────────────────────────────────────────┐
│  [⏰ Scheduler Cron ▼]                            │
│  ┌────────────────────────────────────────────────┤
│  │ 🏪 Restaurant Bistro          Manager   ⭐    │
│  │ ⏰ Scheduler Cron              Admin    ⭐    │ ← Actuel
│  │ 💼 Finance Conseil             Conseiller     │
│  │ 📊 CRM Pro                     User           │
│  ├────────────────────────────────────────────────┤
│  │ ➕ Activer un nouveau SaaS                    │
│  └────────────────────────────────────────────────┘
```

---

## 📈 Comparaison : Modèle Lyxal vs Google

```
┌────────────────────────────────────────────────────────────────┐
│                    GOOGLE                  │    LYXAL          │
├────────────────────────────────────────────┼───────────────────┤
│  Identité Unique                           │                   │
│  → account.google.com                      │  → auth.lyxal.com │
│  → jean@gmail.com                          │  → jean@lyxal.id  │
│                                            │                   │
│  Applications                              │                   │
│  → Gmail (Email)                           │  → Restaurant     │
│  → YouTube (Vidéo)                         │  → Scheduler      │
│  → Drive (Stockage)                        │  → Finance        │
│  → Calendar (Agenda)                       │  → CRM            │
│  → Analytics (Stats)                       │  → Analytics      │
│                                            │                   │
│  Changement de Contexte                    │                   │
│  → Clic sur icon app                       │  → Sélecteur SaaS │
│  → Interface change                        │  → Interface change│
│  → Pas de re-connexion                     │  → Pas de reconnexion
│                                            │                   │
│  Données Personnelles                      │                   │
│  → Google Account                          │  → Namespace perso│
│  → Profil, préférences                     │  → Documents, notifs
│                                            │                   │
│  Permissions                               │                   │
│  → Par application                         │  → Par SaaS       │
│  → Granulaires                             │  → Granulaires    │
└────────────────────────────────────────────┴───────────────────┘

CONCLUSION : Architecture identique ✅
```

---

**Ce schéma illustre l'architecture complète validée dans INTEGRATION_LYXAL_IDENTITY_COMPLETE.md**

**Référence** : Voir `INTEGRATION_LYXAL_IDENTITY_COMPLETE.md` pour les détails d'implémentation

