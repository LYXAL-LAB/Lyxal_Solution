# 🏗️ Architecture du Module Builder

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Qu'est-ce que le Builder ?](#quest-ce-que-le-builder)
3. [Le builder_catalogue](#le-builder_catalogue)
4. [Architecture du module](#architecture-du-module)
5. [Relations avec les autres modules](#relations-avec-les-autres-modules)
6. [Utilisation par l'IA](#utilisation-par-lia)
7. [Clarifications importantes](#clarifications-importantes)

---

## 🎯 Vue d'ensemble

### Définition

Le **Builder** est un **système de méta-programmation** qui permet de construire dynamiquement l'application Lyxal à partir de ressources cataloguées.

```
┌─────────────────────────────────────────────────────────┐
│                  MODULE BUILDER                         │
│                                                         │
│  Système low-code/no-code qui :                        │
│  • Catalogue TOUTES les ressources Lyxal              │
│  • Génère dynamiquement l'application                 │
│  • Gère les dépendances entre ressources              │
│  • Fournit des templates réutilisables                │
│  • Permet l'orchestration par l'IA                    │
└─────────────────────────────────────────────────────────┘
```

### Pourquoi "Builder" ?

Le nom **Builder** (constructeur en français) est parfait car ce module :
- ✅ **Construit** l'application dynamiquement
- ✅ **Assemble** les différentes ressources
- ✅ **Génère** les tables, fonctions, APIs
- ✅ **Orchestre** les dépendances
- ✅ **Déploie** les modules

**Ce n'est PAS** :
- ❌ Un simple catalogue statique
- ❌ Juste un stockage de métadonnées
- ❌ Limité aux ressources "builder"

**C'est** :
- ✅ Un système actif de construction
- ✅ Un orchestrateur d'application
- ✅ Un générateur dynamique

---

## 🏛️ Qu'est-ce que le Builder ?

### Concept

Le Builder est un **système de méta-programmation** qui permet de :

1. **Définir** des ressources (tables, fonctions, APIs, etc.)
2. **Cataloguer** ces ressources avec métadonnées enrichies
3. **Gérer** les dépendances entre ressources
4. **Générer** dynamiquement les composants
5. **Déployer** l'application automatiquement

### Analogie

```
┌────────────────────────────────────────────────┐
│   Le Builder = Chef d'orchestre               │
│                                                │
│   Le builder_catalogue = Partition complète   │
│   (liste de tous les instruments, notes)      │
│                                                │
│   Les modules (infra, CRM, etc.) = Musiciens  │
│                                                │
│   L'application Lyxal = Symphonie jouée       │
└────────────────────────────────────────────────┘
```

Le Builder **orchestre** tous les modules pour créer l'application finale.

---

## 📚 Le builder_catalogue

### Définition exacte

```sql
DEFINE TABLE builder_catalogue TYPE NORMAL SCHEMAFULL
  COMMENT 'Catalogue universel du système Builder - Référence TOUTES les ressources Lyxal';
```

### Ce que contient builder_catalogue

Le `builder_catalogue` est le **registre central** de **TOUTES** les ressources de l'application :

#### 1. Ressources du Builder lui-même

```
builder_catalogue contient les définitions de :
├── builder_analyzer    → Analyseurs de données
├── builder_api         → APIs dynamiques
├── builder_bucket      → Stockage
├── builder_config      → Configurations
├── builder_event       → Événements
├── builder_param       → Paramètres
├── builder_sequence    → Séquences
├── builder_template    → Templates
└── builder_action      → Actions (CRUD, etc.)
```

#### 2. Ressources Infrastructure (Bunny.net)

```
builder_catalogue contient les définitions de :
├── bunny_dns_zone           → Table DNS
├── bunny_dns_record         → Table records DNS
├── bunny_pull_zone          → Table CDN
├── fn::bunny_create_dns_zone() → Fonction création DNS
├── fn::bunny_add_dns_record()  → Fonction ajout record
└── ... (120+ ressources Bunny)
```

#### 3. Ressources Business (à venir)

```
builder_catalogue contiendra :
├── product              → Table produits
├── customer             → Table clients
├── order                → Table commandes
├── fn::create_product() → Fonction création produit
├── fn::create_order()   → Fonction création commande
└── ... (tous les modules métier)
```

#### 4. Ressources CRM, Marketing, etc.

```
builder_catalogue contiendra :
├── marketing_campaign         → Table campagnes
├── crm_lead                   → Table prospects
├── fn::create_campaign()      → Fonction campagne
├── fn::tiktok_create_ad()     → Fonction TikTok
└── ... (tous les futurs modules)
```

### Pourquoi dans le Builder ?

Le catalogue est dans le module `builder/` car :

1. **Le Builder l'utilise** pour générer l'application
2. **Le Builder maintient** ce catalogue
3. **Le Builder déploie** les ressources cataloguées
4. **Le Builder gère** les dépendances entre ressources

**C'est l'outil principal du Builder.**

### Qui utilise builder_catalogue ?

```
┌─────────────────────────────────────────────┐
│         builder_catalogue                   │
│    (Catalogue de TOUTES les ressources)     │
└──────────────┬──────────────────────────────┘
               │
       ┌───────┼───────┐
       │       │       │
   ┌───▼───┐ ┌▼────┐ ┌▼──────┐
   │Builder│ │ IA  │ │Devs   │
   │System │ │(MCP)│ │Humains│
   └───────┘ └─────┘ └───────┘
   
   • Builder : génère l'app
   • IA : découvre et orchestre
   • Devs : consultent et maintiennent
```

---

## 🏗️ Architecture du module

### Structure complète

```
builder/
│
├── builder_catalogue/                ← Définitions ressources Builder
│   ├── builder_analyzer/
│   │   ├── builder_analyzer_create_record.surql
│   │   ├── builder_analyzer_create_table.surql
│   │   └── builder_analyzer_deploy.surql
│   │
│   ├── builder_api/
│   │   ├── builder_api_create_record.surql
│   │   ├── builder_api_create_table.surql
│   │   └── builder_api_deploy.surql
│   │
│   ├── builder_bucket/
│   ├── builder_config/
│   ├── builder_documentation/
│   ├── builder_event/
│   ├── builder_param/
│   └── builder_sequence/
│
├── builder_dependency/               ← Gestion dépendances
│   ├── builder_dependency_actions.surql
│   ├── builder_dependency_create_record.surql
│   ├── builder_dependency_create_table.surql
│   ├── builder_dependency_deploy.surql
│   └── builder_dependency_edge_create_table.surql
│
├── builder_template/                 ← Templates réutilisables
│   ├── builder_template_create_record.surql
│   ├── builder_template_create_table.surql
│   ├── builder_template_deploy.surql
│   └── builder_template_materialize_plan.surql
│
├── database/                         ← Tables du Builder
│   ├── builder_action/
│   │   ├── builder_action_category.surql
│   │   └── builder_action.surql      → Dictionnaire actions
│   │
│   ├── builder_catalogue.surql       → LE CATALOGUE UNIVERSEL ⭐
│   │
│   ├── builder_tags_create_table_initialise.surql
│   │
│   └── builder_translate/
│       ├── builder_i18n_key.surql
│       └── builder_i18n_translation.surql
│
├── reference/                        ← Seeds et données ref
│   ├── builder_catalogue_reference_tags_initialise.surql
│   ├── builder_error_code_seeds.surql
│   ├── builder_error_severity_code_seeds.surql
│   └── builder_error_severity_seeds.surql
│
├── resources/                        ← Fonctions du Builder
│   ├── builder_action/
│   │   ├── builder_action_create.surql
│   │   ├── builder_action_delete.surql
│   │   ├── builder_action_get_by_code.surql
│   │   ├── builder_action_get.surql
│   │   └── builder_action_list.surql
│   │
│   ├── builder_action_category/
│   ├── builder_catalogue/
│   ├── builder_tags/
│   └── builder_translate/
│
└── documentation/                    ← Ce dossier
    └── ARCHITECTURE_MODULE_BUILDER.md
```

### Composants clés

#### 1. builder_catalogue (LA TABLE)

**Emplacement** : `builder/database/builder_catalogue.surql`

**Rôle** : Table centrale qui catalogue **TOUTES** les ressources Lyxal.

**Structure** :
```sql
DEFINE TABLE builder_catalogue TYPE NORMAL SCHEMAFULL;

-- Champs clés
DEFINE FIELD name ON builder_catalogue TYPE string;
DEFINE FIELD code ON builder_catalogue TYPE string READONLY;
DEFINE FIELD description ON builder_catalogue TYPE string;
DEFINE FIELD version ON builder_catalogue TYPE string;
DEFINE FIELD metadata ON builder_catalogue FLEXIBLE TYPE object;
DEFINE FIELD parent ON builder_catalogue TYPE option<record<builder_catalogue>>;
DEFINE FIELD fichier_surql ON builder_catalogue TYPE record<storage_file>;
```

**Contenu** :
- Toutes les tables (builder, infra, business, CRM, etc.)
- Toutes les fonctions (fn::*)
- Tous les modules
- Tous les templates
- Tous les plugins

#### 2. builder_action

**Emplacement** : `builder/database/builder_action/builder_action.surql`

**Rôle** : Dictionnaire des actions possibles dans le système.

**Exemples d'actions** :
- CREATE, UPDATE, DELETE (CRUD)
- GET, LIST (lecture)
- ATTACH, DETACH (relations)
- IMPORT, EXPORT (I/O)
- VALIDATE (validation)

**Usage** : Logs, stats, UI, catégorisation, i18n.

#### 3. builder_template

**Emplacement** : `builder/builder_template/`

**Rôle** : Templates réutilisables pour générer du code.

**Exemples** :
- Template CRUD complet
- Template API REST
- Template validation
- Template i18n

#### 4. builder_dependency

**Emplacement** : `builder/builder_dependency/`

**Rôle** : Gestion des dépendances entre ressources.

**Exemples** :
- `fn::create_order` dépend de `table:product`
- `fn::create_invoice` dépend de `fn::create_order`
- Ordre de déploiement automatique

---

## 🔗 Relations avec les autres modules

### Architecture globale Lyxal

```
Lyxal_Surreal/
│
├── builder/                    ← MODULE BUILDER (orchestrateur)
│   └── database/
│       └── builder_catalogue.surql  ← Catalogue de TOUT
│
├── infrastructure/            ← MODULE INFRASTRUCTURE
│   ├── database/
│   │   ├── dns/
│   │   │   ├── bunny_dns_zone.surql
│   │   │   └── bunny_dns_record.surql
│   │   ├── cdn/
│   │   └── storage/
│   └── resources/
│       └── bunny/
│           └── bunny_net_api/
│               ├── dns_zone/
│               │   ├── fn_bunny_create_dns_zone.surql
│               │   └── ... (13 fonctions)
│               ├── pull_zone/
│               └── ... (120+ fonctions)
│
├── authentification/          ← MODULE AUTH
│   ├── database/
│   └── resources/
│
├── business/                  ← MODULE BUSINESS (à venir)
│   ├── database/
│   │   ├── product.surql
│   │   ├── customer.surql
│   │   └── order.surql
│   └── resources/
│
├── crm/                       ← MODULE CRM (à venir)
├── marketing/                 ← MODULE MARKETING (à venir)
└── mcp_server/               ← Documentation MCP
    └── documentation/
```

### Flow de catalogage

```
1️⃣ CRÉATION D'UNE RESSOURCE
   Exemple : bunny_dns_zone.surql
   ↓
2️⃣ ENREGISTREMENT DANS builder_catalogue
   CREATE builder_catalogue:bunny_dns_zone CONTENT {
     name: "bunny_dns_zone",
     code: "bunny_dns_zone",
     metadata: {
       type: "table",
       module: "infrastructure",
       category: "bunny_dns"
     }
   };
   ↓
3️⃣ BUILDER PEUT L'UTILISER
   - Générer documentation
   - Créer dépendances
   - Déployer automatiquement
   ↓
4️⃣ IA PEUT LA DÉCOUVRIR
   SELECT * FROM builder_catalogue
   WHERE metadata.module = 'infrastructure'
   ↓
5️⃣ IA PEUT L'ORCHESTRER
   RETURN fn::bunny_create_dns_zone(...)
```

### Relations inter-modules

```
┌─────────────────────────────────────────────┐
│            BUILDER MODULE                   │
│         (Orchestrateur central)             │
│                                             │
│  builder_catalogue  ← Contient TOUT        │
└──────────────┬──────────────────────────────┘
               │ catalogue
       ┌───────┼───────┬────────┐
       │       │       │        │
┌──────▼────┐ │ ┌─────▼─────┐ │
│Infrastructure│ │  Business  │ │
│  • Bunny   │ │ │  • Product │ │
│  • DNS     │ │ │  • Order   │ │
│  • CDN     │ │ │  • Customer│ │
└────────────┘ │ └────────────┘ │
         ┌─────▼────┐     ┌─────▼────┐
         │   CRM    │     │Marketing │
         │ • Lead   │     │• Campaign│
         │ • Ticket │     │• TikTok  │
         └──────────┘     └──────────┘

Tous les modules sont CATALOGUÉS dans builder_catalogue
Le Builder orchestre leur déploiement et leurs dépendances
```

---

## 🤖 Utilisation par l'IA

### Découverte automatique

L'IA utilise `builder_catalogue` pour découvrir toutes les ressources :

```sql
-- L'IA découvre TOUT
SELECT * FROM builder_catalogue;

-- L'IA découvre un module spécifique
SELECT * FROM builder_catalogue 
WHERE metadata.module = 'infrastructure';

-- L'IA découvre les fonctions DNS
SELECT * FROM builder_catalogue 
WHERE metadata.module = 'infrastructure'
AND metadata.category = 'bunny_dns'
AND metadata.type = 'function';
```

### Orchestration intelligente

L'IA lit les relations dans le catalogue :

```sql
-- L'IA lit les métadonnées d'une fonction
SELECT * FROM builder_catalogue 
WHERE code = 'fn_create_order';

-- Résultat :
{
  metadata: {
    related_functions: [
      "fn::create_invoice",
      "fn::update_customer_status",
      "fn::reserve_stock"
    ],
    related_tables: [
      "order",
      "customer",
      "product"
    ]
  }
}

-- L'IA peut orchestrer automatiquement :
// 1. fn::create_order(...)
// 2. fn::create_invoice(...)  ← Découvert via related_functions
// 3. fn::update_customer_status(...) ← Découvert via related_functions
// 4. fn::reserve_stock(...) ← Découvert via related_functions
```

### Workflow IA + Builder

```
┌──────────────────────────────────────────────┐
│  1. Utilisateur : "Crée une zone DNS"       │
└────────────────┬─────────────────────────────┘
                 │
    ┌────────────▼────────────┐
    │  2. IA consulte         │
    │  builder_catalogue      │
    │  pour trouver fonction  │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │  3. IA trouve           │
    │  fn::bunny_create_dns_  │
    │  zone avec métadonnées  │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │  4. IA lit exemples     │
    │  et paramètres requis   │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │  5. IA exécute fonction │
    │  avec bons paramètres   │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │  6. IA voit related_    │
    │  functions et orchestre │
    └─────────────────────────┘
```

---

## ⚠️ Clarifications importantes

### 1. Nom "builder" ≠ Limité au module builder

**❌ FAUX** : "Le catalogue ne contient que les ressources du builder"

**✅ VRAI** : "Le catalogue contient **TOUTES** les ressources de Lyxal, il est juste **géré par** le module builder"

**Analogie** :
```
Une bibliothèque s'appelle "bibliothèque" 
mais elle ne contient pas QUE des livres sur les bibliothèques.
Elle contient TOUS les livres de tous les sujets.

Le builder s'appelle "builder"
mais builder_catalogue ne contient pas QUE des ressources builder.
Il contient TOUTES les ressources de tous les modules.
```

### 2. Pourquoi ne pas le mettre à la racine ?

**Question** : "Pourquoi `builder/database/builder_catalogue.surql` et pas `database/global_catalogue.surql` ?"

**Réponse** :
1. Le catalogue **appartient** au module Builder
2. Le Builder **maintient** le catalogue
3. Le Builder **utilise** le catalogue pour construire
4. C'est une **responsabilité** du Builder
5. Architecture modulaire claire

**Analogie** :
```
Le chef d'orchestre possède la partition complète.
Ce n'est pas parce que la partition contient la musique de tous les instruments
qu'elle devrait être "quelque part au milieu de l'orchestre".
Elle est entre les mains du chef qui orchestre.
```

### 3. builder_catalogue vs INFO FOR DB

**INFO FOR DB** : Métadonnées SurrealDB natives
```sql
INFO FOR DB;
-- Retourne : structure brute des tables, fonctions, types
-- Avantage : Toujours synchronisé
-- Limite : Pas de métadonnées enrichies
```

**builder_catalogue** : Métadonnées enrichies Lyxal
```sql
SELECT * FROM builder_catalogue;
-- Retourne : documentation complète, exemples, relations, métadonnées
-- Avantage : Richesse documentaire
-- Limite : Doit être maintenu
```

**Les deux sont complémentaires** :
```
L'IA utilise BOTH :
1. INFO FOR DB → Structure technique
2. builder_catalogue → Documentation et orchestration
```

### 4. Évolution future

Le nom restera `builder_catalogue` même quand on aura :
- ✅ 100+ tables business
- ✅ 500+ fonctions métier
- ✅ 20+ modules (CRM, Marketing, Finance, etc.)

**Pourquoi ?** Parce que c'est toujours le **Builder qui orchestre** tout.

---

## 📊 Comparaison noms envisagés

| Nom | Avantages | Inconvénients | Verdict |
|-----|-----------|---------------|---------|
| **builder_catalogue** (actuel) | Cohérent avec module<br>Clair sur propriété<br>Déjà établi | Peut sembler limité | ✅ **PARFAIT** |
| `resource_catalogue` | Descriptif<br>Universel | Perd lien avec Builder<br>Pas cohérent avec `builder/` | ⚠️ Acceptable |
| `global_catalogue` | Indique globalité | Trop générique<br>Perd responsabilité | ❌ À éviter |
| `mcp_catalogue` | Indique usage IA | Trompeur (pas que MCP)<br>Limite conceptuelle | ❌ À éviter |
| `app_catalogue` | Court | Vague<br>Pas précis | ❌ À éviter |

---

## 🎯 Recommandations

### Pour les développeurs

1. **Utiliser `builder_catalogue`** pour cataloguer **TOUTES** les ressources
2. **Ne pas** créer de catalogue parallèle
3. **Maintenir** les métadonnées à jour
4. **Documenter** richement (exemples, relations, etc.)

### Pour l'architecture

1. **Garder** le nom `builder/` pour le module
2. **Garder** le nom `builder_catalogue` pour la table
3. **Améliorer** la documentation (COMMENT)
4. **Clarifier** dans la doc que ça contient TOUT

### Pour la documentation

```sql
DEFINE TABLE IF NOT EXISTS builder_catalogue TYPE NORMAL SCHEMAFULL
  COMMENT 'CATALOGUE UNIVERSEL du système Builder Lyxal
  
  Contient TOUTES les ressources de l\'application Lyxal :
  • Ressources Builder (templates, actions, configs, analyseurs)
  • Tables métier (product, customer, order, invoice, etc.)
  • Tables infrastructure (bunny_dns_zone, bunny_pull_zone, etc.)
  • Fonctions (fn::bunny_*, fn::create_*, fn::builder_*, etc.)
  • Modules (infrastructure, business, CRM, marketing, etc.)
  • Plugins et extensions
  
  Utilisé par :
  - Le Builder : pour générer et déployer l\'application dynamiquement
  - L\'IA via MCP : pour découvrir et orchestrer toutes les ressources
  - Le système : pour gérer les dépendances et relations inter-ressources
  - Les développeurs : comme documentation technique centrale
  
  Le catalogue est dans le module Builder car le Builder est responsable
  de l\'orchestration et du déploiement de toutes ces ressources.
  
  Source unique de vérité pour la documentation enrichie et les métadonnées.';
```

---

## 📚 Documents associés

### Dans ce dossier
- Ce document : `ARCHITECTURE_MODULE_BUILDER.md`

### Documentation globale
- [VISION_LYXAL_ASSISTANT_UNIVERSEL.md](../../Definition/VISION_LYXAL_ASSISTANT_UNIVERSEL.md) - Vision globale
- [STRUCTURATION_DONNEES_FONDATION_IA.md](../../Definition/STRUCTURATION_DONNEES_FONDATION_IA.md) - Principes données
- [MCP_AUTO_DISCOVERY.md](../mcp_server/documentation/MCP_AUTO_DISCOVERY.md) - Documentation MCP
- [BUILDER_CATALOGUE_INTEGRATION.md](../mcp_server/documentation/BUILDER_CATALOGUE_INTEGRATION.md) - Intégration catalogue

---

## 🎓 En résumé

### Le Builder en 3 points

1. **Le Builder = Système de construction dynamique de l'application**
   - Génère, déploie, orchestre

2. **builder_catalogue = Registre central de TOUTES les ressources**
   - Tables, fonctions, modules, tout est catalogué

3. **Architecture cohérente = Builder possède son catalogue**
   - Comme le chef d'orchestre possède la partition complète

### Ne JAMAIS interpréter comme

- ❌ "builder_catalogue contient seulement les ressources du builder"
- ❌ "Le catalogue devrait être ailleurs car il contient plus que le builder"
- ❌ "On devrait le renommer en resource_catalogue ou global_catalogue"

### TOUJOURS interpréter comme

- ✅ "builder_catalogue contient TOUTES les ressources de Lyxal"
- ✅ "Le catalogue appartient au Builder car le Builder orchestre tout"
- ✅ "C'est le registre central utilisé par le Builder ET l'IA"

---

**Date de création** : 27 octobre 2025  
**Version** : 1.0.0  
**Module** : Builder  
**Auteur** : Équipe Lyxal

---

**Ce document fait autorité sur l'architecture du module Builder.**  
**En cas de doute, se référer à ce document.**

