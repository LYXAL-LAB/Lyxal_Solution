# 📚 Intégration du Builder Catalogue dans l'écosystème MCP

## 🎯 Vue d'ensemble

Le **Builder Catalogue** (`builder_catalogue`) est le catalogue universel de l'application Lyxal. Il centralise **TOUTES** les ressources de l'application dans une seule table avec des métadonnées enrichies.

### Pourquoi "Builder" ?

Le catalogue est dans le module `builder/` car le **Builder est le système de méta-programmation** responsable de :
- 🏗️ Construire dynamiquement l'application
- 📦 Cataloguer toutes les ressources (tables, fonctions, modules)
- 🔗 Gérer les dépendances entre ressources
- 🚀 Déployer automatiquement les composants
- 🎼 Orchestrer comme un chef d'orchestre avec sa partition complète

**Le catalogue contient TOUTES les ressources Lyxal** (infrastructure, business, CRM, marketing, etc.), pas seulement les ressources du Builder lui-même.

➡️ **Documentation complète** : `/builder/documentation/ARCHITECTURE_MODULE_BUILDER.md`

Cette intégration renforce considérablement les capacités d'auto-découverte de l'IA via MCP.

---

## 🏗️ Architecture à 3 niveaux

L'IA dispose maintenant de **3 sources d'information complémentaires** :

```
┌─────────────────────────────────────────────────────────────┐
│                      IA (Claude, GPT, etc.)                 │
└─────────────────────────┬───────────────────────────────────┘
                          │ MCP Protocol
                          │
┌─────────────────────────▼───────────────────────────────────┐
│               3 SOURCES D'INFORMATION                        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  NIVEAU 1: INFO FOR DB (natif SurrealDB)          │     │
│  │  ✅ Structure brute (tables, fonctions, champs)    │     │
│  │  ✅ Types et contraintes                           │     │
│  │  ✅ COMMENT basiques                               │     │
│  │  ⚡ Rapide, toujours synchronisé                   │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  NIVEAU 2: builder_catalogue (enrichi)            │     │
│  │  ✅ Documentation enrichie                         │     │
│  │  ✅ Exemples de code                               │     │
│  │  ✅ Relations explicites (related_*, parent)       │     │
│  │  ✅ Enums détaillés avec descriptions              │     │
│  │  ✅ Liens vers API docs                            │     │
│  │  ✅ Hiérarchie des modules                         │     │
│  │  📚 Complet, structuré, queryable                  │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  NIVEAU 3: Fichiers .surql (via MCP File System)  │     │
│  │  ✅ Header complet                                 │     │
│  │  ✅ Commentaires développeurs                      │     │
│  │  ✅ Notes et contexte                              │     │
│  │  📖 Contexte maximal (optionnel)                   │     │
│  └────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

---

## 📋 Contenu du Builder Catalogue

### Tables incluses

- ✅ **Tables Bunny.net** : `bunny_dns_zone`, `bunny_pull_zone`, `bunny_storage_zone`, etc.
- ✅ **Fonctions Bunny.net** : `fn::bunny_add_dns_zone`, `fn::bunny_create_pull_zone`, etc.
- ✅ **Modules Builder** : Modules personnalisés de l'application
- ✅ **Templates** : Templates réutilisables
- ✅ **Plugins** : Extensions et plugins
- ✅ **Utilitaires** : Fonctions helpers et outils

### Structure de base

```sql
DEFINE TABLE builder_catalogue TYPE NORMAL SCHEMAFULL;

-- Champs essentiels
DEFINE FIELD name ON builder_catalogue TYPE string;           -- Nom unique
DEFINE FIELD code ON builder_catalogue TYPE string READONLY;  -- Code unique
DEFINE FIELD description ON builder_catalogue TYPE string;    -- Description
DEFINE FIELD version ON builder_catalogue TYPE string;        -- Version
DEFINE FIELD metadata ON builder_catalogue FLEXIBLE TYPE object; -- Métadonnées enrichies
DEFINE FIELD parent ON builder_catalogue TYPE option<record<builder_catalogue>>; -- Hiérarchie
DEFINE FIELD fichier_surql ON builder_catalogue TYPE record<storage_file>; -- Fichier source

-- Index performants
DEFINE INDEX idx_builder_catalogue_code ON builder_catalogue FIELDS code UNIQUE;
DEFINE INDEX idx_builder_catalogue_name ON builder_catalogue FIELDS name UNIQUE;
DEFINE INDEX idx_builder_catalogue_parent ON builder_catalogue FIELDS parent;
```

---

## 🔍 Métadonnées enrichies (`metadata`)

Le champ `metadata` est **FLEXIBLE** et peut contenir n'importe quelle structure. Voici les standards pour Bunny.net :

### Pour une **table** :

```json
{
  "type": "table",
  "category": "bunny_infrastructure",
  "module": "dns",
  "api_docs": "https://docs.bunny.net/reference/dnszonepublic_index2",
  "api_endpoint": "/dnszone",
  "fields_count": 24,
  "has_dnssec": true,
  "enums": {
    "log_anonymization_type": [
      { "value": "OneDigit", "code": 0, "description": "..." },
      { "value": "Drop", "code": 1, "description": "..." }
    ]
  },
  "related_functions": ["fn::bunny_add_dns_zone", "fn::bunny_list_dns_zones"]
}
```

### Pour une **fonction** :

```json
{
  "type": "function",
  "category": "bunny_api",
  "module": "dns",
  "api_method": "POST",
  "api_endpoint": "/dnszone",
  "api_docs": "https://docs.bunny.net/reference/dnszonepublic_add",
  "parameters": [
    {
      "name": "$domain",
      "type": "string",
      "required": true,
      "description": "Le nom de domaine à créer",
      "example": "example.com"
    }
  ],
  "returns": {
    "success": { "type": "object", "fields": {...} },
    "error": { "type": "object", "fields": {...} }
  },
  "examples": [
    {
      "title": "Créer une zone DNS",
      "code": "RETURN fn::bunny_add_dns_zone('example.com');",
      "description": "Crée une zone DNS pour le domaine example.com"
    }
  ],
  "related_functions": ["fn::bunny_get_dns_zone", "fn::bunny_delete_dns_zone"],
  "related_tables": ["bunny_dns_zone", "bunny_dns_record"]
}
```

---

## 💡 Requêtes pour l'IA

### Découverte globale

```sql
-- Voir TOUT le catalogue
SELECT * FROM builder_catalogue;

-- Voir uniquement Bunny.net
SELECT * FROM builder_catalogue 
WHERE metadata.category IN ['bunny_infrastructure', 'bunny_api']
ORDER BY metadata.module, name;
```

### Recherche par module

```sql
-- Toutes les ressources DNS
SELECT * FROM builder_catalogue 
WHERE metadata.module = 'dns';

-- Uniquement les fonctions DNS
SELECT * FROM builder_catalogue 
WHERE metadata.module = 'dns' 
AND metadata.type = 'function';

-- Uniquement les tables DNS
SELECT * FROM builder_catalogue 
WHERE metadata.module = 'dns' 
AND metadata.type = 'table';
```

### Recherche par endpoint API

```sql
-- Trouver toutes les ressources liées à /dnszone
SELECT * FROM builder_catalogue 
WHERE metadata.api_endpoint CONTAINS '/dnszone';

-- Grouper par endpoint
SELECT 
  metadata.api_endpoint AS endpoint,
  array::group(name) AS resources
FROM builder_catalogue 
WHERE metadata.api_endpoint != NONE
GROUP BY metadata.api_endpoint;
```

### Documentation enrichie

```sql
-- Doc complète d'une fonction avec exemples
SELECT 
  name,
  description,
  version,
  metadata.parameters AS parametres,
  metadata.returns AS retours,
  metadata.examples AS exemples,
  metadata.api_docs AS documentation_api,
  metadata.related_functions AS fonctions_liees,
  metadata.related_tables AS tables_liees
FROM builder_catalogue 
WHERE code = 'fn_bunny_add_dns_zone';
```

### Relations entre ressources

```sql
-- Toutes les fonctions utilisant une table
SELECT 
  name,
  description,
  metadata.type
FROM builder_catalogue 
WHERE metadata.related_tables CONTAINS 'bunny_dns_zone';

-- Toutes les tables utilisées par une fonction
SELECT 
  name,
  description,
  metadata.type
FROM builder_catalogue 
WHERE id INSIDE (
  SELECT metadata.related_tables 
  FROM builder_catalogue 
  WHERE code = 'fn_bunny_add_dns_zone'
);
```

### Hiérarchie des modules

```sql
-- Modules racine
SELECT * FROM builder_catalogue 
WHERE parent = NONE 
AND metadata.type = 'module';

-- Sous-modules d'un module
SELECT * FROM builder_catalogue 
WHERE parent = builder_catalogue:bunny_infrastructure;

-- Toute la hiérarchie d'un module (récursif)
-- (nécessite une fonction récursive)
```

---

## 🎯 Workflow de l'IA

### Scénario : Créer une zone DNS

```
1. L'IA reçoit : "Crée une zone DNS pour example.com"
   ↓
2. Recherche dans le catalogue
   SELECT * FROM builder_catalogue 
   WHERE metadata.module = 'dns' 
   AND metadata.type = 'function'
   AND description CONTAINS 'créer';
   ↓
3. L'IA trouve : fn::bunny_add_dns_zone
   + description
   + paramètres détaillés ($domain: string)
   + exemples de code
   + doc API complète
   ↓
4. L'IA lit les exemples et comprend l'usage
   ↓
5. L'IA exécute
   RETURN fn::bunny_add_dns_zone('example.com');
   ↓
6. L'IA voit metadata.related_functions
   et propose d'activer DNSSEC
   ↓
7. L'IA exécute
   fn::bunny_enable_dnssec($zone_id);
```

---

## 📊 Comparaison avant/après

| Critère | Sans catalogue | Avec `builder_catalogue` |
|---------|----------------|--------------------------|
| **Documentation** | COMMENT limités | Métadonnées enrichies illimitées |
| **Exemples** | Aucun | Inclus dans metadata.examples |
| **Relations** | Implicites (à deviner) | Explicites (related_*) |
| **Hiérarchie** | Plate | Arbre (parent/enfant) |
| **Recherche** | Par nom uniquement | Par module, catégorie, endpoint, description |
| **Enums** | À parser depuis ASSERT | Liste structurée avec descriptions |
| **API Docs** | À chercher manuellement | URL directe dans metadata.api_docs |
| **Versions** | Aucune | Versionné par ressource |
| **Évolution** | Difficile à tracer | Historique via updated_at |

---

## 🚀 Mise en place

### Étape 1 : Créer la table (déjà fait)

La table `builder_catalogue` existe déjà dans votre projet.

### Étape 2 : Peupler le catalogue

**Option A : Manuelle** (pour commencer)

```sql
-- Exemple : Table bunny_dns_zone
CREATE builder_catalogue:bunny_dns_zone CONTENT {
  name: "bunny_dns_zone",
  code: "bunny_dns_zone",
  description: "Table miroir de l'API Bunny.net pour les zones DNS",
  version: "2.0.0",
  personnal_tag: system_tag:infrastructure,
  fichier_surql: storage_file:bunny_dns_zone_surql,
  metadata: {
    type: "table",
    category: "bunny_infrastructure",
    module: "dns",
    api_docs: "https://docs.bunny.net/reference/dnszonepublic_index2",
    api_endpoint: "/dnszone",
    // ... métadonnées enrichies
  }
};
```

**Option B : Script automatique** (recommandé)

Un script Python peut parser vos fichiers `.surql` et peupler automatiquement le catalogue :

```python
# populate_builder_catalogue.py
# Parser les fichiers .surql
# Extraire les métadonnées
# Créer les records dans builder_catalogue
```

### Étape 3 : Maintenir le catalogue

```sql
-- Mettre à jour une ressource
UPDATE builder_catalogue:fn_bunny_add_dns_zone
SET 
  version = '1.1.0',
  metadata.examples += {
    title: "Nouveau cas d'usage",
    code: "...",
    description: "..."
  };
```

---

## 📈 Bénéfices pour le projet

### Pour l'IA

- ✅ **Découverte rapide** : Trouve instantanément les ressources pertinentes
- ✅ **Documentation complète** : Exemples, paramètres, retours, relations
- ✅ **Navigation intelligente** : Suit les relations entre ressources
- ✅ **Contexte enrichi** : Comprend l'usage et les cas d'utilisation

### Pour les développeurs

- ✅ **Catalogue centralisé** : Vue d'ensemble de toute l'application
- ✅ **Documentation structurée** : Format standard et queryable
- ✅ **Maintenance facilitée** : Un seul endroit à mettre à jour
- ✅ **Versionning** : Suivi des évolutions de chaque ressource

### Pour le projet

- ✅ **Scalabilité** : Facile d'ajouter de nouvelles ressources
- ✅ **Découvrabilité** : Les ressources sont facilement trouvables
- ✅ **Cohérence** : Structure standardisée pour toutes les ressources
- ✅ **IA-ready** : Optimisé pour l'utilisation par des IA via MCP

---

## 🎓 Prochaines étapes

1. **Peupler le catalogue** avec les tables et fonctions Bunny.net existantes
2. **Créer un script** pour automatiser le peuplement
3. **Établir des conventions** pour les métadonnées par type de ressource
4. **Tester avec l'IA** via MCP Server
5. **Itérer** sur la structure des métadonnées selon les besoins

---

## 📚 Ressources

- [MCP_AUTO_DISCOVERY.md](./MCP_AUTO_DISCOVERY.md) : Documentation complète MCP
- [CONFIGURATION_GUIDE.md](./CONFIGURATION_GUIDE.md) : Guide de configuration
- [README.md](./README.md) : Vue d'ensemble

---

**Date de création** : 27 octobre 2025  
**Version** : 1.0.0  
**Projet** : Lyxal Infrastructure  
**Auteur** : Documentation Lyxal Team

