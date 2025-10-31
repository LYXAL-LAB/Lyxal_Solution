# Module TRANSLATE - LYXAL Suite

## 📖 **Vue d'ensemble**

Module centralisé de traduction pour toute la LYXAL Suite. Remplace les colonnes `translations` dispersées dans chaque table par un système unifié et évolutif.

## 🏗️ **Architecture proposée**

### **Tables principales**

```sql
-- Table principale des traductions
DEFINE TABLE translation SCHEMAFULL;
DEFINE FIELD key ON translation TYPE string ASSERT $value != NONE;
DEFINE FIELD language ON translation TYPE string ASSERT $value != NONE;
DEFINE FIELD value ON translation TYPE string ASSERT $value != NONE;
DEFINE FIELD module ON translation TYPE string ASSERT $value != NONE;
DEFINE FIELD context ON translation TYPE option<string>;
DEFINE FIELD created_on ON translation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON translation TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_translation_key_lang ON translation COLUMNS key, language UNIQUE;
DEFINE INDEX idx_translation_module ON translation COLUMNS module;
DEFINE INDEX idx_translation_language ON translation COLUMNS language;

-- Table des langues supportées
DEFINE TABLE language SCHEMAFULL;
DEFINE FIELD code ON language TYPE string ASSERT $value != NONE; -- fr, en, de, etc.
DEFINE FIELD name ON language TYPE string ASSERT $value != NONE; -- Français, English, etc.
DEFINE FIELD native_name ON language TYPE string; -- Français, English, Deutsch
DEFINE FIELD is_default ON language TYPE bool DEFAULT false;
DEFINE FIELD is_active ON language TYPE bool DEFAULT true;
DEFINE FIELD direction ON language TYPE string DEFAULT 'ltr'; -- ltr, rtl

-- Cache des traductions (pour performance)
DEFINE TABLE translation_cache SCHEMAFULL;
DEFINE FIELD key ON translation_cache TYPE string;
DEFINE FIELD language ON translation_cache TYPE string;
DEFINE FIELD value ON translation_cache TYPE string;
DEFINE FIELD expires_at ON translation_cache TYPE datetime;
```

## 🔧 **Convention de nommage des clés**

### **Format standard :**
```
{module}.{entity}.{item}.{field?}
```

### **Exemples concrets :**

```sql
-- Entités légales
legal.category.societe                 → "Société"
legal.category.entreprise_individuelle → "Entreprise Individuelle"
legal.form.sarl                        → "Société à Responsabilité Limitée"
legal.form.sas                         → "Société par Actions Simplifiée"

-- Fiscalité
tax.regime.normal                      → "Régime Normal"
tax.regime.micro                       → "Régime Micro-entreprise"
tax.type.vat                          → "Taxe sur la Valeur Ajoutée"

-- Conformité
compliance.rule.gdpr                   → "Règlement Général sur la Protection des Données"
compliance.rule.sox                    → "Loi Sarbanes-Oxley"

-- Contrats
contract.type.employment               → "Contrat de Travail"
contract.clause.confidentiality       → "Clause de Confidentialité"

-- Messages système
system.error.validation_failed        → "Échec de validation"
system.message.save_success           → "Enregistrement réussi"

-- Interface utilisateur
ui.button.save                        → "Enregistrer"
ui.button.cancel                      → "Annuler"
ui.form.required_field                → "Champ obligatoire"
```

## 🌍 **Langues supportées (Phase 1)**

| Code | Langue | Nom natif | Direction | Priorité |
|------|--------|-----------|-----------|----------|
| `fr` | Français | Français | ltr | 🔴 **P1** |
| `en` | English | English | ltr | 🔴 **P1** |
| `de` | Deutsch | Deutsch | ltr | 🟡 **P2** |
| `es` | Español | Español | ltr | 🟡 **P2** |
| `it` | Italiano | Italiano | ltr | 🟡 **P2** |
| `nl` | Nederlands | Nederlands | ltr | 🟡 **P2** |

## 🚀 **API de traduction**

### **Fonctions SurrealDB :**

```sql
-- Récupérer une traduction
DEFINE FUNCTION fn::translate($key: string, $language: string) -> string {
    LET $translation = (SELECT value FROM translation 
                       WHERE key = $key AND language = $language LIMIT 1)[0];
    
    RETURN $translation.value ?? $key;
};

-- Récupérer plusieurs traductions
DEFINE FUNCTION fn::translate_batch($keys: array<string>, $language: string) -> object {
    LET $translations = SELECT key, value FROM translation 
                       WHERE key IN $keys AND language = $language;
    
    RETURN object::from_entries($translations);
};

-- Récupérer avec fallback
DEFINE FUNCTION fn::translate_with_fallback($key: string, $language: string, $fallback_language: string) -> string {
    LET $translation = fn::translate($key, $language);
    
    IF $translation == $key THEN {
        RETURN fn::translate($key, $fallback_language);
    };
    
    RETURN $translation;
};
```

### **SDK JavaScript/TypeScript :**

```typescript
// API proposée pour le SDK
interface TranslateAPI {
  translate(key: string, language?: string): Promise<string>;
  translateBatch(keys: string[], language?: string): Promise<Record<string, string>>;
  setLanguage(language: string): void;
  getLanguage(): string;
  getSupportedLanguages(): Promise<Language[]>;
}

// Utilisation
const t = new TranslateAPI();
await t.setLanguage('fr');
const label = await t.translate('legal.form.sarl'); // → "Société à Responsabilité Limitée"
```

## 📦 **Migration depuis les colonnes translations**

### **Étapes de migration :**

1. **Phase 1 - Extraction :**
   ```sql
   -- Extraire toutes les traductions existantes
   INSERT INTO translation 
   SELECT 
       'legal.category.' + LOWER(code) as key,
       'fr' as language,
       translations.fr as value,
       'legal' as module,
       null as context
   FROM legal_category WHERE translations.fr IS NOT NULL;
   ```

2. **Phase 2 - Validation :**
   - Vérifier l'intégrité des données extraites
   - Contrôler les doublons de clés
   - Valider les traductions manquantes

3. **Phase 3 - Suppression :**
   ```sql
   -- Supprimer les anciennes colonnes
   ALTER TABLE legal_category DROP COLUMN translations;
   ALTER TABLE legal_form DROP COLUMN translations;
   ```

## 🎯 **Intégration avec LYXAL Suite**

### **Modules consommateurs :**

- ✅ **lyxal-legal** : Entités, formes juridiques, conformité
- 🔄 **lyxal-base** : Pays, devises, unités de mesure
- 🔄 **lyxal-crm** : Types de contacts, secteurs d'activité
- 🔄 **lyxal-hr** : Types de contrats, postes
- 🔄 **lyxal-kitui** : Interface utilisateur complète

### **Points d'intégration :**

1. **ORM/SDK** : Traduction automatique des entités
2. **API REST** : Header `Accept-Language` 
3. **Interface** : Changement de langue en temps réel
4. **Rapports** : Génération multilingue

## 🔧 **Configuration et cache**

### **Variables d'environnement :**

```env
# Configuration traduction
LYXAL_DEFAULT_LANGUAGE=fr
LYXAL_FALLBACK_LANGUAGE=en
LYXAL_TRANSLATION_CACHE_TTL=3600
LYXAL_TRANSLATION_PRELOAD=legal,base,ui

# Base de données
LYXAL_SURREAL_TRANSLATION_NS=lyxal
LYXAL_SURREAL_TRANSLATION_DB=translate
```

### **Stratégie de cache :**

1. **Redis/In-Memory** : Traductions fréquentes (TTL: 1h)
2. **Preloading** : Chargement des modules critiques au démarrage
3. **Lazy Loading** : Chargement à la demande pour modules spécialisés
4. **Cache invalidation** : Invalidation sélective par module/clé

## 📊 **Métriques et monitoring**

### **KPIs proposés :**

- Temps de réponse des traductions
- Taux de cache hit/miss
- Traductions manquantes par langue
- Utilisation par module/langue

### **Tableaux de bord :**

- Dashboard administrateur (gestion des traductions)
- Métriques de performance
- Rapport de couverture par langue

## 🔄 **Roadmap de développement**

### **Phase 1 : Foundation (Sprint 1)**
- ✅ Architecture des tables
- ✅ Fonctions SurrealDB de base
- ✅ Migration du module legal

### **Phase 2 : SDK & API (Sprint 2)**
- 🔄 SDK TypeScript/JavaScript
- 🔄 API REST pour traductions
- 🔄 Cache Redis

### **Phase 3 : UI & UX (Sprint 3)**
- 🔄 Interface d'administration
- 🔄 Édition en ligne des traductions
- 🔄 Import/Export de traductions

### **Phase 4 : Scale & Performance (Sprint 4)**
- 🔄 Optimisations de performance
- 🔄 Monitoring avancé
- 🔄 Migration complète des autres modules

## 📋 **Standards de qualité**

### **Conventions de traduction :**

1. **Cohérence terminologique** : Glossaire centralisé
2. **Contexte** : Chaque clé doit avoir un contexte clair
3. **Longueur** : Limites par type d'élément UI
4. **Pluralisation** : Gestion des formes plurielles
5. **Variables** : Support des interpolations `{variable}`

### **Processus de validation :**

1. **Review linguistique** : Validation par des natifs
2. **Tests automatisés** : Clés manquantes, format
3. **Intégration continue** : Validation à chaque commit

---

## 🎯 **Objectifs business**

- **🌍 Internationalisation** : Support natif de 6 langues
- **⚡ Performance** : < 50ms pour récupération traductions
- **🔧 Maintenabilité** : Architecture centralisée et évolutive
- **👥 UX** : Changement de langue instantané
- **📈 Évolutivité** : Ajout facile de nouvelles langues

---

**Status** : 🔄 **EN ATTENTE** - À développer après finalisation du module legal  
**Priorité** : 🔴 **HAUTE** - Critique pour l'internationalisation  
**Équipe** : Backend + Frontend + UX/UI 