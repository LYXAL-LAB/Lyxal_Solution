# 📊 Rapport d'Analyse : Patterns et Conventions des Tables Knowledge

**Date** : 2025-01-27  
**Tables analysées** : 12 tables dans `knowledge/database/`

---

## 📋 Vue d'Ensemble

| Table | Type | Permissions SELECT | Permissions CRUD | Structure principale |
|-------|------|-------------------|------------------|---------------------|
| `knowledge_category` | NORMAL | `WHERE metadata.is_active = true` | NONE | identity + metadata |
| `knowledge_content` | NORMAL | `WHERE metadata.is_active = true` | NONE | topic + identity + content + metadata |
| `knowledge_content_type` | NORMAL | `WHERE metadata.is_active = true` | NONE | identity + metadata (avec metadata.ai) |
| `knowledge_domain` | NORMAL | `WHERE metadata.is_active = true` | NONE | identity + ui + tags + metadata |
| `knowledge_keyword` | NORMAL | FULL | NONE | identity + metadata |
| `knowledge_topic` | NORMAL | `WHERE metadata.is_active = true` | NONE | domain + category + identity + metadata |
| `knowledge_sub_category` | NORMAL | `WHERE metadata.is_active = true` | NONE | category + identity + metadata |
| `knowledge_domain_keyword` | RELATION | FULL | NONE | in + out |
| `knowledge_topic_keyword` | RELATION | FULL | NONE | in + out |
| `knowledge_feedback` | NORMAL | FULL | CREATE FULL, DELETE FULL | content + feedback_type + source + metadata |
| `knowledge_gap` | NORMAL | FULL | FULL | gap_type + detection + resolution + metadata |
| `knowledge_content_proposal` | NORMAL | FULL | FULL | gap + topic + identity + content + generation + review + metadata |

---

## ✅ PATTERNS COHÉRENTS

### 1. **Structure des Tables NORMAL**

Toutes les tables NORMAL suivent un pattern cohérent :
- ✅ `TYPE NORMAL SCHEMAFULL`
- ✅ Bloc `identity` avec structure standardisée
- ✅ Bloc `metadata` avec structure standardisée
- ✅ Section `-- INDEXES` à la fin

### 2. **Structure du Bloc IDENTITY**

Pattern standard pour les tables référentielles :
```sql
identity.code       -- string, UPPER_SNAKE_CASE, ASSERT uppercase
identity.slug       -- string, ASSERT not empty
identity.label_key  -- record<i18n_key>, REFERENCE ON DELETE REJECT
identity.description_key -- record<i18n_key> ou option<record<i18n_key>>
```

**Tables utilisant ce pattern** :
- ✅ `knowledge_category`
- ✅ `knowledge_domain`
- ✅ `knowledge_topic`
- ✅ `knowledge_sub_category`
- ✅ `knowledge_content_type`

**Variations** :
- `knowledge_keyword` : utilise `identity.value` au lieu de `identity.code` (✅ justifié, c'est un référentiel de valeurs)
- `knowledge_content` : n'a pas de `identity.code`, seulement `identity.slug` (✅ justifié, rattaché à un topic)
- `knowledge_content_proposal` : n'a pas de `identity.code`, seulement `identity.slug` (✅ justifié, proposition temporaire)

### 3. **Structure du Bloc METADATA**

Pattern standard :
```sql
metadata.version_label  -- string ou option<string>, DEFAULT "1.0.0" ou option
metadata.is_active      -- bool, DEFAULT true
metadata.display_order  -- int ou option<number>, DEFAULT 0 ou option
```

**Cohérence** :
- ✅ `metadata.is_active` : toujours présent, toujours `DEFAULT true`
- ✅ `metadata.version_label` : présent dans toutes les tables principales
- ✅ `metadata.display_order` : présent dans toutes les tables principales (sauf feedback, gap, proposal)

**Tables avec métadonnées enrichies** :
- `knowledge_content` : ajoute `metadata.priority`, `metadata.quality_score`, `metadata.analytics`
- `knowledge_content_type` : ajoute `metadata.ai` (bloc spécialisé IA)
- `knowledge_gap` : ajoute `metadata.priority`, `metadata.impact_score`, `metadata.recurrence_count`
- `knowledge_content_proposal` : ajoute `metadata.priority`, `metadata.quality_score`

### 4. **Permissions Standard**

Pattern principal pour tables référentielles :
```sql
PERMISSIONS 
    FOR SELECT WHERE metadata.is_active = true
    FOR CREATE, UPDATE, DELETE NONE;
```

**Tables utilisant ce pattern** :
- ✅ `knowledge_category`
- ✅ `knowledge_content`
- ✅ `knowledge_content_type`
- ✅ `knowledge_domain`
- ✅ `knowledge_topic`
- ✅ `knowledge_sub_category`

**Tables avec permissions différentes** :
- `knowledge_keyword` : `FOR SELECT FULL` (✅ justifié, pour recherche)
- `knowledge_domain_keyword` : `FOR SELECT FULL` (✅ justifié, table relationnelle)
- `knowledge_topic_keyword` : `FOR SELECT FULL` (✅ justifié, table relationnelle)
- `knowledge_feedback` : `FOR SELECT FULL, FOR CREATE FULL, FOR DELETE FULL` (✅ justifié, auto-généré)
- `knowledge_gap` : `FOR SELECT FULL, FOR CREATE FULL, FOR UPDATE FULL, FOR DELETE FULL` (✅ justifié, auto-généré)
- `knowledge_content_proposal` : `FOR SELECT FULL, FOR CREATE FULL, FOR UPDATE FULL, FOR DELETE FULL` (✅ justifié, auto-généré)

### 5. **Indexes - Pattern de Nommage**

Pattern cohérent :
```sql
idx_{table_short}_{field}        -- Index simple
idx_{table_short}_{field} UNIQUE -- Index unique
idx_{table_short}_{field1}_{field2} -- Index composite
```

**Exemples** :
- ✅ `idx_category_code`, `idx_category_slug`, `idx_category_active`
- ✅ `idx_content_topic`, `idx_content_type`, `idx_content_slug`, `idx_content_active`
- ✅ `idx_topic_code`, `idx_topic_slug`, `idx_topic_domain`, `idx_topic_category`, `idx_topic_active`

**Indexes obligatoires** :
- ✅ Index UNIQUE sur `identity.code` (quand présent)
- ✅ Index UNIQUE sur `identity.slug` (quand présent)
- ✅ Index sur `metadata.is_active` (toujours présent)

### 6. **REFERENCE ON DELETE - Patterns**

Pattern cohérent selon le type de relation :

**Pour référentiels (tables maîtres)** :
- ✅ `REFERENCE ON DELETE REJECT` : empêche la suppression si utilisé
  - Exemples : `knowledge_category`, `knowledge_domain`, `knowledge_content_type`, `i18n_key`

**Pour relations hiérarchiques** :
- ✅ `REFERENCE ON DELETE CASCADE` : supprime automatiquement les enfants
  - Exemples : `knowledge_content.topic`, `knowledge_sub_category.category`, `knowledge_topic_keyword`

**Pour relations optionnelles** :
- ✅ `REFERENCE ON DELETE UNSET` : met à NONE si supprimé
  - Exemples : `knowledge_domain.ui.icon`, `knowledge_gap.resolution.resolution_content`

---

## ⚠️ DIFFÉRENCES ET INCOHÉRENCES DÉTECTÉES

### 🔴 **CRITIQUE : Structure `content.code` différente entre tables**

**Problème** : `knowledge_content` et `knowledge_content_proposal` utilisent des structures différentes pour `content.code`

**Dans `knowledge_content`** :
```sql
content.code.*.language       -- ✅ Syntaxe wildcard correcte
content.code.*.value          -- ✅ Nom de champ cohérent
content.code.*.explanation_key -- ✅ Nom de champ cohérent
```

**Dans `knowledge_content_proposal`** :
```sql
content.code[*].language       -- ❌ Syntaxe incorrecte (devrait être .*)
content.code[*].code           -- ❌ Nom différent (devrait être .value)
content.code[*].description_key -- ❌ Nom différent (devrait être .explanation_key)
```

**Impact** : La fonction `fn_knowledge_enrich_approve_proposal` copie `content.code` de `knowledge_content_proposal` vers `knowledge_content`, mais la structure est incompatible.

**Recommandation** : Aligner `knowledge_content_proposal` sur `knowledge_content` :
- Utiliser `content.code.*.language` au lieu de `content.code[*].language`
- Utiliser `content.code.*.value` au lieu de `content.code[*].code`
- Utiliser `content.code.*.explanation_key` au lieu de `content.code[*].description_key`

---

### 🟡 **MOYEN : Structure `content.examples` différente entre tables**

**Problème** : Noms de champs différents dans `content.examples`

**Dans `knowledge_content`** :
```sql
content.examples.correct.*.text_key   -- ✅
content.examples.correct.*.code       -- ✅
content.examples.incorrect.*.text_key -- ✅
content.examples.incorrect.*.code     -- ✅
```

**Dans `knowledge_content_proposal`** :
```sql
content.examples.correct[*].code             -- ⚠️ Syntaxe différente (devrait être .*)
content.examples.correct[*].description_key  -- ❌ Nom différent (devrait être .text_key)
content.examples.incorrect[*].code           -- ⚠️ Syntaxe différente (devrait être .*)
content.examples.incorrect[*].description_key -- ❌ Nom différent (devrait être .text_key)
```

**Recommandation** : Aligner `knowledge_content_proposal` sur `knowledge_content`

---

### 🟡 **MOYEN : Type de `metadata.version_label` incohérent**

**Problème** : Certaines tables utilisent `option<string>` et d'autres `string` avec DEFAULT

**Tables avec `option<string>`** :
- `knowledge_category.metadata.version_label` : `option<string>`
- `knowledge_sub_category.metadata.version_label` : `option<string>`

**Tables avec `string DEFAULT "1.0.0"`** :
- `knowledge_content.metadata.version_label` : `string DEFAULT "1.0.0"`
- `knowledge_content_type.metadata.version_label` : `string DEFAULT "1.0.0"`
- `knowledge_domain.metadata.version_label` : `string DEFAULT "1.0.0"`
- `knowledge_topic.metadata.version_label` : `string DEFAULT "1.0.0"`

**Recommandation** : Standardiser sur `string DEFAULT "1.0.0"` pour toutes les tables (sauf justification métier)

---

### 🟡 **MOYEN : Type de `metadata.display_order` incohérent**

**Problème** : Certaines tables utilisent `option<number>` et d'autres `int` avec DEFAULT

**Tables avec `option<number>`** :
- `knowledge_category.metadata.display_order` : `option<number>`
- `knowledge_sub_category.metadata.display_order` : `option<number>`

**Tables avec `int DEFAULT 0`** :
- `knowledge_content_type.metadata.display_order` : `int DEFAULT 0`
- `knowledge_domain.metadata.display_order` : `int DEFAULT 0`
- `knowledge_topic.metadata.display_order` : `int DEFAULT 0`

**Recommandation** : Standardiser sur `int DEFAULT 0` pour toutes les tables

---

### 🟡 **MOYEN : Absence de `identity.code` dans certaines tables**

**Tables sans `identity.code`** :
- `knowledge_content` (a seulement `identity.slug`)
- `knowledge_content_proposal` (a seulement `identity.slug`)
- `knowledge_feedback` (n'a pas de bloc identity)
- `knowledge_gap` (n'a pas de bloc identity)

**Justification** :
- ✅ `knowledge_content` : rattaché à un topic, identifié par slug unique (justifié)
- ✅ `knowledge_content_proposal` : proposition temporaire (justifié)
- ❓ `knowledge_feedback` : pas de besoin d'identité (justifié mais différent)
- ❓ `knowledge_gap` : pas de besoin d'identité (justifié mais différent)

**Observation** : Les tables sans `identity.code` sont celles qui ne sont pas des référentiels mais des entités métier. C'est cohérent.

---

### 🟢 **MINEUR : Commentaires dans ASSERT**

**Observation** : Certaines tables ont des commentaires très détaillés dans les ASSERT, d'autres non.

**Exemple détaillé** (`knowledge_content.metadata.quality_score`) :
```sql
COMMENT 'Score de qualité du contenu (0 = faible qualité, 1 = excellente qualité). Utilisé par l\'IA pour filtrer et prioriser les contenus selon leur qualité. Valeur par défaut : 0.5 (qualité moyenne)';
```

**Exemple simple** (`knowledge_category.metadata.is_active`) :
```sql
COMMENT 'La catégorie est active et peut être utilisée';
```

**Recommandation** : Standardiser le niveau de détail selon l'importance du champ (plus de détails pour les champs critiques comme `quality_score`)

---

### 🟢 **MINEUR : Structure des champs de niveau racine**

**Observation** : Certaines tables ont des champs au niveau racine en dehors des blocs `identity` et `metadata` :

**Tables avec champs racine** :
- `knowledge_content` : `topic` (relation)
- `knowledge_topic` : `domain`, `category`, `sub_category`, `tags` (relations)
- `knowledge_sub_category` : `category` (relation)
- `knowledge_feedback` : `content`, `feedback_type`, `score`, `comment`, `source` (champs métier)
- `knowledge_gap` : `gap_type`, `severity`, `domain`, `topic`, `content`, `description`, `expected_content`, `suggested_keywords` (champs métier)
- `knowledge_content_proposal` : `gap`, `topic`, `content_type` (relations)

**Pattern** : Les champs de relation et les champs métier principaux sont au niveau racine, ce qui est cohérent.

---

### 🟢 **MINEUR : Blocs spéciaux**

**Observation** : Certaines tables ont des blocs spéciaux en plus de `identity` et `metadata` :

- `knowledge_domain` : `ui` (bloc UI avec icon)
- `knowledge_content` : `content` (bloc U3-FLEX avec texte, code, exemples, etc.)
- `knowledge_content_type` : `metadata.ai` (bloc spécialisé IA)
- `knowledge_content_proposal` : `content`, `generation`, `review` (blocs métier)
- `knowledge_feedback` : `source` (bloc métier)
- `knowledge_gap` : `detection`, `resolution` (blocs métier)

**Pattern** : Les blocs spéciaux sont justifiés par le besoin métier. C'est cohérent.

---

## 📊 Tableau Récapitulatif des Patterns

| Pattern | Tables Concernées | Cohérence | Action Requise |
|---------|------------------|-----------|----------------|
| Structure `identity.code` | Toutes sauf content, proposal, feedback, gap | ✅ Cohérent | Aucune |
| Structure `identity.slug` | Toutes avec identity | ✅ Cohérent | Aucune |
| Structure `metadata.is_active` | Toutes | ✅ Cohérent | Aucune |
| Structure `metadata.version_label` | Toutes sauf feedback, gap | ⚠️ Incohérent | Standardiser type |
| Structure `metadata.display_order` | Tables principales | ⚠️ Incohérent | Standardiser type |
| Structure `content.code` | content vs proposal | 🔴 Incohérent | **CORRIGER** |
| Structure `content.examples` | content vs proposal | 🟡 Incohérent | **CORRIGER** |
| Permissions SELECT | Tables référentielles vs auto-générées | ✅ Cohérent | Aucune |
| Permissions CRUD | Tables référentielles vs auto-générées | ✅ Cohérent | Aucune |
| Indexes nommage | Toutes | ✅ Cohérent | Aucune |
| REFERENCE ON DELETE | Selon type relation | ✅ Cohérent | Aucune |

---

## ✅ RECOMMANDATIONS PRIORITAIRES

### 🔴 **PRIORITÉ HAUTE**

1. **Corriger la structure `content.code` dans `knowledge_content_proposal`**
   - Remplacer `content.code[*]` par `content.code.*`
   - Remplacer `content.code[*].code` par `content.code.*.value`
   - Remplacer `content.code[*].description_key` par `content.code.*.explanation_key`

2. **Corriger la structure `content.examples` dans `knowledge_content_proposal`**
   - Remplacer `content.examples.correct[*]` par `content.examples.correct.*`
   - Remplacer `content.examples.correct[*].description_key` par `content.examples.correct.*.text_key`
   - Remplacer `content.examples.incorrect[*]` par `content.examples.incorrect.*`
   - Remplacer `content.examples.incorrect[*].description_key` par `content.examples.incorrect.*.text_key`

### 🟡 **PRIORITÉ MOYENNE**

3. **Standardiser `metadata.version_label`**
   - Utiliser `string DEFAULT "1.0.0"` partout (sauf justification métier)
   - Modifier `knowledge_category` et `knowledge_sub_category`

4. **Standardiser `metadata.display_order`**
   - Utiliser `int DEFAULT 0` partout
   - Modifier `knowledge_category` et `knowledge_sub_category`

### 🟢 **PRIORITÉ BASSE**

5. **Documenter les choix de design**
   - Pourquoi certaines tables n'ont pas `identity.code`
   - Pourquoi certaines tables ont des permissions différentes
   - Pourquoi certaines tables ont des blocs spéciaux

---

## 📝 NOTES FINALES

### Points Positifs ✅

- **Architecture cohérente** : Les tables suivent globalement des patterns bien définis
- **Séparation des responsabilités** : Tables référentielles vs entités métier bien différenciées
- **Documentation** : Commentaires présents et utiles
- **Indexes** : Patterns de nommage cohérents et appropriés
- **Permissions** : Logique métier respectée (référentiels protégés, auto-généré ouverts)

### Points à Améliorer ⚠️

- **Incohérences structurelles** : `knowledge_content_proposal` doit être aligné sur `knowledge_content`
- **Types optionnels** : Standardiser les types pour `version_label` et `display_order`
- **Documentation** : Certains choix de design pourraient être mieux documentés

---

**Fin du rapport**

