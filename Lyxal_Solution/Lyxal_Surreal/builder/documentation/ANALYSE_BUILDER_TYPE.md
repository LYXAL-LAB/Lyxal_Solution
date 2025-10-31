# 🔍 Analyse de la table builder_type

**Date** : 27 octobre 2025  
**Objectif** : Analyser la table `builder_type` et son intégration avec `builder_catalogue`  
**Statut** : ANALYSE + RECOMMANDATIONS

---

## 📋 Structure actuelle de builder_type

### Table présentée

```sql
DEFINE TABLE IF NOT EXISTS builder_type TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : types de ressources du Builder'
PERMISSIONS
  FOR SELECT,CREATE FULL
  FOR UPDATE,DELETE NONE;

DEFINE FIELD native_name ON builder_type
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 2 AND string::len($value) < 101
    READONLY
    COMMENT 'Nom du type de ressource';

DEFINE FIELD code ON builder_type
    TYPE string
    READONLY
    COMMENT 'Code unique du type de ressource';

DEFINE FIELD i18n_key ON builder_type
    TYPE object
    COMMENT 'Clés i18n du type de ressource';

DEFINE FIELD i18n_key.name ON builder_type
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Clé i18n du nom du type de ressource';

DEFINE FIELD i18n_key.description ON builder_type
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Clé i18n de la description du type de ressource';

DEFINE FIELD metadata ON builder_type
    FLEXIBLE
    TYPE object
    COMMENT 'Métadonnées du type de ressource';

DEFINE FIELD isactive ON builder_type
    TYPE bool
    DEFAULT true
    COMMENT 'Type actif';

DEFINE FIELD status ON builder_type
    TYPE record<builder_status>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Statut du type de ressource';
```

---

## ✅ Points POSITIFS de cette approche

### 1. **Table de référence normalisée** ✨

**Avantage majeur** : Au lieu d'un simple enum string, vous avez une vraie table.

**Bénéfices** :
- ✅ Évolutif : Ajouter un nouveau type = INSERT (pas de migration)
- ✅ i18n natif : Chaque type traduit dans toutes les langues
- ✅ Métadonnées par type : Configurer chaque type individuellement
- ✅ Désactivation possible : `isactive = false` sans supprimer
- ✅ Audit : Savoir quels types existent dans le système

**Comparaison** :

```sql
-- ❌ APPROCHE SIMPLE (enum string)
DEFINE FIELD type ON builder_catalogue
  TYPE string
  ASSERT $value IN ['table', 'function', 'module'];
-- Problème : Ajouter 'workflow' nécessite migration de la table

-- ✅ VOTRE APPROCHE (table de référence)
DEFINE FIELD type ON builder_catalogue
  TYPE record<builder_type>
  REFERENCE ON DELETE REJECT;
-- Avantage : Ajouter 'workflow' = INSERT dans builder_type
```

### 2. **Internationalisation (i18n)** 🌍

**Très intelligent** : Chaque type a des clés i18n pour name et description.

**Usage** :
```sql
-- Type en français
SELECT * FROM builder_type:function 
FETCH i18n_key.name->i18n_translation[WHERE language_id = 'fr'];
-- Retourne : "Fonction"

-- Type en anglais
SELECT * FROM builder_type:function 
FETCH i18n_key.name->i18n_translation[WHERE language_id = 'en'];
-- Retourne : "Function"
```

### 3. **Immutabilité des données clés** 🔒

**READONLY sur** :
- `native_name` : Ne peut pas changer après création
- `code` : Ne peut pas changer après création
- `i18n_key.name` et `i18n_key.description` : Ne peuvent pas changer
- `status` : Ne peut pas changer (sauf via fonction spécifique)

**Bonne pratique** : Garantit la stabilité des références.

### 4. **Permissions restrictives** 🛡️

```sql
FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE
```

**Excellent** : On peut créer des types, les consulter, mais pas les modifier/supprimer directement.
→ Données de référence protégées.

### 5. **Statut et activation séparés** 📊

```sql
DEFINE FIELD isactive ON builder_type TYPE bool DEFAULT true;
DEFINE FIELD status ON builder_type TYPE record<builder_status>;
```

**Distinction intelligente** :
- `isactive` : Toggle simple (actif/inactif)
- `status` : Statut complexe (draft, production, deprecated, etc.)

---

## ⚠️ Points à AMÉLIORER

### 1. ❌ Manque d'index UNIQUE sur code

**Problème** :
```sql
DEFINE FIELD code ON builder_type TYPE string READONLY;
```

**Manque** :
```sql
DEFINE INDEX idx_builder_type_code ON builder_type
  FIELDS code UNIQUE
  COMMENT 'Unicité du code type';
```

**Impact** : Sans index UNIQUE, on pourrait créer deux types avec le même code.

### 2. ⚠️ Référence à builder_status non définie

```sql
DEFINE FIELD status ON builder_type
    TYPE record<builder_status>
    REFERENCE ON DELETE REJECT
```

**Problème** : La table `builder_status` n'existe pas encore (ou n'est pas fournie).

**Solution** : Créer `builder_status` AVANT `builder_type`.

### 3. ⚠️ native_name vs code : Clarification

**Quelle différence ?**
```sql
DEFINE FIELD native_name ON builder_type TYPE string;  -- Ex: "Function" ?
DEFINE FIELD code ON builder_type TYPE string;         -- Ex: "function" ?
```

**Recommandation** :
- `code` : Identifiant technique (lowercase, snake_case) → `'function'`, `'api_endpoint'`
- `native_name` : Nom affiché par défaut (Title Case) → `'Function'`, `'API Endpoint'`

**Mais si i18n** : `native_name` est peut-être redondant avec `i18n_key.name` ?

**Suggestion** :
```sql
-- Option A : Garder native_name comme fallback (si i18n pas dispo)
native_name = 'Function'  -- Fallback anglais
i18n_key.name -> 'builder.type.function' -> traductions

-- Option B : Supprimer native_name, utiliser seulement i18n
code = 'function'
i18n_key.name -> 'builder.type.function' -> traductions
```

### 4. ⚠️ Metadata : Structure non définie

```sql
DEFINE FIELD metadata ON builder_type
    FLEXIBLE
    TYPE object
    COMMENT 'Métadonnées du type de ressource';
```

**Question** : Qu'est-ce qu'on met dans metadata pour un type ?

**Suggestions possibles** :
```json
{
  "metadata": {
    "icon": "📊",                    // Icône UI pour ce type
    "color": "#3B82F6",              // Couleur UI
    "required_fields": [             // Champs obligatoires dans builder_catalogue
      "fichier_surql",               // pour type='function'
      "module"
    ],
    "optional_fields": [
      "parameters",
      "return_type"
    ],
    "display_order": 1,              // Ordre d'affichage dans UI
    "category": "core",              // Catégorie (core, infrastructure, business)
    "description_en": "Executable function in SurrealDB",
    "examples": [
      "fn::bunny_create_dns_zone"
    ]
  }
}
```

### 5. ⚠️ Manque de timestamps

**Recommandation** : Ajouter audit trail
```sql
DEFINE FIELD created_at ON builder_type
  TYPE datetime
  READONLY
  DEFAULT time::now()
  COMMENT 'Date de création';

DEFINE FIELD updated_at ON builder_type
  TYPE datetime
  READONLY
  VALUE time::now()
  COMMENT 'Date de mise à jour';
```

### 6. ⚠️ Manque de champ description direct (si i18n fail)

Si l'i18n n'est pas disponible, avoir une description de secours :
```sql
DEFINE FIELD description ON builder_type
  TYPE option<string>
  COMMENT 'Description par défaut (si i18n indisponible)';
```

---

## 🏗️ Table builder_status (manquante)

### Structure recommandée

```sql
-- =============================================================================
-- TABLE: builder_status
-- =============================================================================
-- RÔLE
--   Statuts possibles pour les ressources du Builder
--   (draft, active, deprecated, disabled, archived)
--
-- =============================================================================

DEFINE TABLE IF NOT EXISTS builder_status TYPE NORMAL SCHEMAFULL
  COMMENT 'Catalogue : statuts des ressources Builder'
  PERMISSIONS
    FOR SELECT,CREATE FULL
    FOR UPDATE,DELETE NONE;

-- Champs
DEFINE FIELD IF NOT EXISTS code ON builder_status
  TYPE string
  READONLY
  COMMENT 'Code unique du statut (draft, active, deprecated, disabled, archived)';

DEFINE FIELD IF NOT EXISTS name ON builder_status
  TYPE string
  READONLY
  COMMENT 'Nom du statut (fallback)';

DEFINE FIELD IF NOT EXISTS i18n_key ON builder_status
  TYPE record<i18n_key>
  REFERENCE ON DELETE REJECT
  READONLY
  COMMENT 'Clé i18n du nom du statut';

DEFINE FIELD IF NOT EXISTS description ON builder_status
  TYPE option<string>
  COMMENT 'Description du statut';

DEFINE FIELD IF NOT EXISTS color ON builder_status
  TYPE option<string>
  DEFAULT '#6B7280'
  COMMENT 'Couleur UI pour ce statut (hex)';

DEFINE FIELD IF NOT EXISTS icon ON builder_status
  TYPE option<string>
  COMMENT 'Icône UI pour ce statut';

DEFINE FIELD IF NOT EXISTS display_order ON builder_status
  TYPE int
  DEFAULT 999
  COMMENT 'Ordre d\'affichage dans UI';

DEFINE FIELD IF NOT EXISTS is_terminal ON builder_status
  TYPE bool
  DEFAULT false
  COMMENT 'Statut terminal (ne peut plus changer)';

DEFINE FIELD IF NOT EXISTS created_at ON builder_status
  TYPE datetime
  READONLY
  DEFAULT time::now()
  COMMENT 'Date de création';

-- Index
DEFINE INDEX IF NOT EXISTS idx_builder_status_code ON builder_status
  FIELDS code UNIQUE
  COMMENT 'Unicité du code statut';

DEFINE INDEX IF NOT EXISTS idx_builder_status_display_order ON builder_status
  FIELDS display_order
  COMMENT 'Tri par ordre d\'affichage';
```

### Seeds pour builder_status

```sql
-- SEEDS builder_status

-- Draft (brouillon)
CREATE builder_status:draft CONTENT {
  code: 'draft',
  name: 'Draft',
  i18n_key: i18n_key:builder_status_draft,
  description: 'Ressource en cours de développement, non publiée',
  color: '#9CA3AF',
  icon: '📝',
  display_order: 1,
  is_terminal: false
};

-- Active (actif, en production)
CREATE builder_status:active CONTENT {
  code: 'active',
  name: 'Active',
  i18n_key: i18n_key:builder_status_active,
  description: 'Ressource active et utilisable en production',
  color: '#10B981',
  icon: '✅',
  display_order: 2,
  is_terminal: false
};

-- Deprecated (déprécié, à remplacer)
CREATE builder_status:deprecated CONTENT {
  code: 'deprecated',
  name: 'Deprecated',
  i18n_key: i18n_key:builder_status_deprecated,
  description: 'Ressource dépréciée, à ne plus utiliser',
  color: '#F59E0B',
  icon: '⚠️',
  display_order: 3,
  is_terminal: false
};

-- Disabled (désactivé temporairement)
CREATE builder_status:disabled CONTENT {
  code: 'disabled',
  name: 'Disabled',
  i18n_key: i18n_key:builder_status_disabled,
  description: 'Ressource temporairement désactivée',
  color: '#EF4444',
  icon: '🚫',
  display_order: 4,
  is_terminal: false
};

-- Archived (archivé, conservé pour historique)
CREATE builder_status:archived CONTENT {
  code: 'archived',
  name: 'Archived',
  i18n_key: i18n_key:builder_status_archived,
  description: 'Ressource archivée, conservée pour historique',
  color: '#6B7280',
  icon: '📦',
  display_order: 5,
  is_terminal: true
};
```

---

## 🎯 Types de ressources : Seeds pour builder_type

### Liste des types identifiés (de l'analyse précédente)

```sql
-- SEEDS builder_type

-- 1. TABLE (table SurrealDB)
CREATE builder_type:table CONTENT {
  code: 'table',
  native_name: 'Table',
  i18n_key: {
    name: i18n_key:builder_type_table_name,
    description: i18n_key:builder_type_table_description
  },
  metadata: {
    icon: '📊',
    color: '#3B82F6',
    category: 'core',
    required_fields: ['fichier_surql', 'module'],
    display_order: 1
  },
  isactive: true,
  status: builder_status:active
};

-- 2. FUNCTION (fonction SurrealDB fn::*)
CREATE builder_type:function CONTENT {
  code: 'function',
  native_name: 'Function',
  i18n_key: {
    name: i18n_key:builder_type_function_name,
    description: i18n_key:builder_type_function_description
  },
  metadata: {
    icon: '⚡',
    color: '#8B5CF6',
    category: 'core',
    required_fields: ['fichier_surql', 'module', 'parameters'],
    optional_fields: ['return_type', 'examples'],
    display_order: 2
  },
  isactive: true,
  status: builder_status:active
};

-- 3. MODULE (module Lyxal)
CREATE builder_type:module CONTENT {
  code: 'module',
  native_name: 'Module',
  i18n_key: {
    name: i18n_key:builder_type_module_name,
    description: i18n_key:builder_type_module_description
  },
  metadata: {
    icon: '📦',
    color: '#10B981',
    category: 'core',
    required_fields: ['description', 'category'],
    display_order: 3
  },
  isactive: true,
  status: builder_status:active
};

-- 4. TEMPLATE (template réutilisable)
CREATE builder_type:template CONTENT {
  code: 'template',
  native_name: 'Template',
  i18n_key: {
    name: i18n_key:builder_type_template_name,
    description: i18n_key:builder_type_template_description
  },
  metadata: {
    icon: '📄',
    color: '#F59E0B',
    category: 'builder',
    display_order: 4
  },
  isactive: true,
  status: builder_status:active
};

-- 5. CONFIG (configuration)
CREATE builder_type:config CONTENT {
  code: 'config',
  native_name: 'Configuration',
  i18n_key: {
    name: i18n_key:builder_type_config_name,
    description: i18n_key:builder_type_config_description
  },
  metadata: {
    icon: '⚙️',
    color: '#6B7280',
    category: 'builder',
    display_order: 5
  },
  isactive: true,
  status: builder_status:active
};

-- 6. EVENT (événement système)
CREATE builder_type:event CONTENT {
  code: 'event',
  native_name: 'Event',
  i18n_key: {
    name: i18n_key:builder_type_event_name,
    description: i18n_key:builder_type_event_description
  },
  metadata: {
    icon: '📡',
    color: '#EC4899',
    category: 'builder',
    display_order: 6
  },
  isactive: true,
  status: builder_status:active
};

-- 7. PARAM (paramètre global)
CREATE builder_type:param CONTENT {
  code: 'param',
  native_name: 'Parameter',
  i18n_key: {
    name: i18n_key:builder_type_param_name,
    description: i18n_key:builder_type_param_description
  },
  metadata: {
    icon: '🎚️',
    color: '#14B8A6',
    category: 'builder',
    display_order: 7
  },
  isactive: true,
  status: builder_status:active
};

-- 8. SEQUENCE (séquence de déploiement)
CREATE builder_type:sequence CONTENT {
  code: 'sequence',
  native_name: 'Sequence',
  i18n_key: {
    name: i18n_key:builder_type_sequence_name,
    description: i18n_key:builder_type_sequence_description
  },
  metadata: {
    icon: '🔢',
    color: '#06B6D4',
    category: 'builder',
    display_order: 8
  },
  isactive: true,
  status: builder_status:active
};

-- 9. ANALYZER (analyseur de données)
CREATE builder_type:analyzer CONTENT {
  code: 'analyzer',
  native_name: 'Analyzer',
  i18n_key: {
    name: i18n_key:builder_type_analyzer_name,
    description: i18n_key:builder_type_analyzer_description
  },
  metadata: {
    icon: '🔍',
    color: '#A855F7',
    category: 'builder',
    display_order: 9
  },
  isactive: true,
  status: builder_status:active
};

-- 10. PLUGIN (plugin/extension)
CREATE builder_type:plugin CONTENT {
  code: 'plugin',
  native_name: 'Plugin',
  i18n_key: {
    name: i18n_key:builder_type_plugin_name,
    description: i18n_key:builder_type_plugin_description
  },
  metadata: {
    icon: '🔌',
    color: '#F43F5E',
    category: 'extension',
    display_order: 10
  },
  isactive: true,
  status: builder_status:active
};

-- 11. ACTION (action CRUD, etc.)
CREATE builder_type:action CONTENT {
  code: 'action',
  native_name: 'Action',
  i18n_key: {
    name: i18n_key:builder_type_action_name,
    description: i18n_key:builder_type_action_description
  },
  metadata: {
    icon: '⚡',
    color: '#EAB308',
    category: 'builder',
    display_order: 11
  },
  isactive: true,
  status: builder_status:active
};

-- 12. API_ENDPOINT (endpoint API externe)
CREATE builder_type:api_endpoint CONTENT {
  code: 'api_endpoint',
  native_name: 'API Endpoint',
  i18n_key: {
    name: i18n_key:builder_type_api_endpoint_name,
    description: i18n_key:builder_type_api_endpoint_description
  },
  metadata: {
    icon: '🌐',
    color: '#0EA5E9',
    category: 'infrastructure',
    required_fields: ['http_method', 'endpoint_url'],
    optional_fields: ['authentication', 'rate_limit'],
    display_order: 12
  },
  isactive: true,
  status: builder_status:active
};

-- 13. WORKFLOW (workflow orchestré)
CREATE builder_type:workflow CONTENT {
  code: 'workflow',
  native_name: 'Workflow',
  i18n_key: {
    name: i18n_key:builder_type_workflow_name,
    description: i18n_key:builder_type_workflow_description
  },
  metadata: {
    icon: '🔄',
    color: '#7C3AED',
    category: 'orchestration',
    required_fields: ['steps', 'dependencies'],
    display_order: 13
  },
  isactive: true,
  status: builder_status:active
};

-- 14. EDGE (relation/edge entre ressources)
CREATE builder_type:edge CONTENT {
  code: 'edge',
  native_name: 'Edge',
  i18n_key: {
    name: i18n_key:builder_type_edge_name,
    description: i18n_key:builder_type_edge_description
  },
  metadata: {
    icon: '🔗',
    color: '#84CC16',
    category: 'core',
    display_order: 14
  },
  isactive: true,
  status: builder_status:active
};
```

---

## 🔗 Intégration avec builder_catalogue

### Modification de builder_catalogue

```sql
-- Dans builder_catalogue.surql

-- Ajouter le champ type (référence vers builder_type)
DEFINE FIELD IF NOT EXISTS type ON builder_catalogue
  TYPE record<builder_type>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('builder_type', $value)
  COMMENT 'Type de ressource (table, function, module, template, etc.)';

-- Ajouter index sur type pour performance
DEFINE INDEX IF NOT EXISTS idx_builder_catalogue_type ON builder_catalogue
  FIELDS type
  COMMENT 'Filtrage par type de ressource';

-- Modifier status pour référencer builder_status
DEFINE FIELD IF NOT EXISTS status ON builder_catalogue
  TYPE record<builder_status>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('builder_status', $value)
  DEFAULT builder_status:draft
  COMMENT 'Statut de la ressource';

-- Ajouter index sur status
DEFINE INDEX IF NOT EXISTS idx_builder_catalogue_status ON builder_catalogue
  FIELDS status
  COMMENT 'Filtrage par statut';
```

### Usage IA avec les références

```sql
-- L'IA peut maintenant filtrer précisément :

-- 1. Toutes les fonctions actives
SELECT * FROM builder_catalogue 
WHERE type = builder_type:function 
AND status = builder_status:active;

-- 2. Toutes les tables du module infrastructure
SELECT * FROM builder_catalogue 
WHERE type = builder_type:table 
AND module = 'infrastructure';

-- 3. Fetch avec détails du type
SELECT *, type.* FROM builder_catalogue 
WHERE type = builder_type:function 
FETCH type;

-- Résultat inclut les métadonnées du type :
{
  name: "fn_bunny_create_dns_zone",
  type: {
    code: "function",
    native_name: "Function",
    metadata: {
      icon: "⚡",
      color: "#8B5CF6",
      required_fields: ["fichier_surql", "module", "parameters"]
    }
  }
}

-- 4. Fetch avec i18n
SELECT * FROM builder_catalogue:fn_bunny_create_dns_zone
FETCH type.i18n_key.name->i18n_translation[WHERE language_id = 'fr'];
```

---

## 📊 Comparaison : Enum vs Table de référence

| Critère | Enum string | Table builder_type (votre approche) |
|---------|-------------|--------------------------------------|
| **Évolutivité** | ❌ Nécessite migration | ✅ Simple INSERT |
| **i18n** | ❌ Impossible | ✅ Natif |
| **Métadonnées par type** | ❌ Non | ✅ Oui (icon, color, etc.) |
| **Désactivation** | ❌ Doit supprimer valeur | ✅ isactive = false |
| **Performance** | ✅ Plus rapide (pas de JOIN) | ⚠️ Nécessite JOIN/FETCH |
| **Audit** | ❌ Non | ✅ Oui (timestamps) |
| **Complexité** | ✅ Simple | ⚠️ Plus complexe |
| **Flexibilité** | ❌ Limitée | ✅ Très flexible |

**Verdict** : Pour un catalogue universel comme le vôtre, **la table de référence est le bon choix** ✅

---

## 🎓 Recommandations finales

### ✅ À faire

1. **Créer `builder_status` AVANT `builder_type`**
   ```bash
   # Ordre de déploiement :
   1. builder_status.surql
   2. builder_type.surql
   3. builder_catalogue.surql (modifié)
   ```

2. **Ajouter index UNIQUE sur code dans builder_type**
   ```sql
   DEFINE INDEX idx_builder_type_code ON builder_type
     FIELDS code UNIQUE;
   ```

3. **Ajouter timestamps dans builder_type**
   ```sql
   DEFINE FIELD created_at ON builder_type TYPE datetime READONLY DEFAULT time::now();
   DEFINE FIELD updated_at ON builder_type TYPE datetime READONLY VALUE time::now();
   ```

4. **Clarifier native_name vs i18n**
   - Option A : Garder native_name comme fallback anglais
   - Option B : Supprimer native_name, utiliser seulement i18n

5. **Créer seeds pour les 14 types identifiés**
   - table, function, module, template, config
   - event, param, sequence, analyzer, plugin
   - action, api_endpoint, workflow, edge

6. **Modifier builder_catalogue pour référencer builder_type et builder_status**

### 🔄 Ordre de déploiement complet

```
1. builder_status.surql        ← Statuts (draft, active, etc.)
2. builder_type.surql           ← Types (table, function, etc.)
3. builder_catalogue.surql      ← Catalogue (avec références)
4. builder_status_seeds.surql   ← 5 statuts
5. builder_type_seeds.surql     ← 14 types
6. builder_catalogue_seeds.surql ← Cataloguer ressources existantes
```

---

## 🎯 Conclusion

### Votre approche builder_type

**✅ EXCELLENTE idée** :
- Table de référence normalisée
- i18n natif
- Évolutif sans migration
- Métadonnées riches par type
- Permissions restrictives

**⚠️ À compléter** :
- Créer `builder_status` (référencé mais manquant)
- Ajouter index UNIQUE sur `code`
- Ajouter timestamps
- Clarifier `native_name` vs i18n
- Créer les seeds

**🚀 Impact sur builder_catalogue** :
- Ajouter champ `type` → `record<builder_type>`
- Modifier champ `status` → `record<builder_status>`
- Ajouter index sur type et status
- L'IA peut maintenant filtrer précisément et découvrir les métadonnées

**C'est une approche professionnelle et bien pensée !** 🎉

---

**Cette analyse confirme que votre direction est la bonne.**  
**Prochaine étape : créer builder_status, compléter builder_type, et seeds.**

