# 📊 Module Business - Nomenclatures d'Activités

Structure modulaire et évolutive pour les codes d'activités économiques français.

---

## 🗂️ STRUCTURE DES TABLES

### **1. `business_nomenclature_type`** - Types de nomenclatures
Table de référence des **types de nomenclatures** (évite le hardcoding).

#### Champs:
- `code` - Code unique (ex: `NAFRev2`, `NAP`)
- `name` - Nom complet
- `description` - Description détaillée
- `period_start` - Année de début
- `period_end` - Année de fin (null si actif)
- `is_active` - Nomenclature en vigueur ?
- `sort_order` - Ordre d'affichage

#### Records:
- `business_nomenclature_type:nafrev2` - NAF Révision 2 (2008-Actuel) ✅ ACTIVE
- `business_nomenclature_type:nafrev1` - NAF Révision 1 (2003-2008)
- `business_nomenclature_type:naf1993` - NAF 1993 (1993-2003)
- `business_nomenclature_type:nap` - NAP (1973-1993)

---

### **2. `business_hierarchical_level`** - Niveaux hiérarchiques
Table de référence des **niveaux hiérarchiques** (évite le hardcoding).

#### Champs:
- `code` - Code unique (ex: `section`, `division`)
- `name` - Nom du niveau
- `description` - Description
- `level_number` - Numéro du niveau (1-5)
- `is_terminal` - Niveau terminal (assigné aux entreprises) ?
- `sort_order` - Ordre d'affichage

#### Records:
- `business_hierarchical_level:section` - Niveau 1 (Grandes familles)
- `business_hierarchical_level:division` - Niveau 2 (Secteurs)
- `business_hierarchical_level:groupe` - Niveau 3 (Sous-secteurs)
- `business_hierarchical_level:classe` - Niveau 4 (Catégories)
- `business_hierarchical_level:sous_classe` - Niveau 5 (Codes terminaux) ✅ TERMINAL

---

### **3. `business_activity_code`** - Codes d'activités
Table principale contenant **tous les codes** (4 602 codes, tous niveaux, toutes nomenclatures).

#### Champs:
- `code` - Code d'activité (ex: `01.11Z`, `SECTION A`)
- `nomenclature_type` - Référence vers `business_nomenclature_type`
- `hierarchical_level` - Référence vers `business_hierarchical_level`
- `parent_code` - Référence vers le code parent (hiérarchie)
- `libelle_long` - Libellé officiel complet
- `libelle_moyen` - Libellé moyen (65 caractères)
- `libelle_court` - Libellé court (40 caractères)

#### Index:
- `code_nomenclature_idx` - Index unique sur (code + nomenclature)
- `nomenclature_idx` - Filtrage par nomenclature
- `level_idx` - Filtrage par niveau
- `parent_idx` - Navigation hiérarchique
- `libelle_search_idx` - Recherche full-text sur les libellés

---

## 📊 STATISTIQUES

### Par nomenclature:
```
NAF Rev 2 :  1 728 codes (sections → sous-classes)
NAF Rev 1 :  1 045 codes (sections → sous-classes)
NAF 1993  :  1 026 codes (sections → sous-classes)
NAP       :    803 codes (divisions → sous-classes)
────────────────────────────────────────────────
TOTAL     :  4 602 codes
```

### Par niveau:
```
Sections     :    55 codes (niveau 1)
Divisions    :   164 codes (niveau 2)
Groupes      :   433 codes (niveau 3)
Classes      : 1 160 codes (niveau 4)
Sous-classes : 2 790 codes (niveau 5 - terminaux)
────────────────────────────────────────────────
TOTAL        : 4 602 codes
```

---

## 🎯 EXEMPLES D'UTILISATION

### 1. Récupérer toutes les nomenclatures actives
```sql
SELECT * FROM business_nomenclature_type WHERE is_active = true;
```

### 2. Récupérer tous les niveaux terminaux
```sql
SELECT * FROM business_hierarchical_level WHERE is_terminal = true;
```

### 3. Récupérer tous les codes NAF Rev 2
```sql
SELECT * FROM business_activity_code 
WHERE nomenclature_type = business_nomenclature_type:nafrev2;
```

### 4. Récupérer toutes les sections
```sql
SELECT * FROM business_activity_code 
WHERE hierarchical_level = business_hierarchical_level:section;
```

### 5. Récupérer tous les codes terminaux (sous-classes)
```sql
SELECT * FROM business_activity_code 
WHERE hierarchical_level = business_hierarchical_level:sous_classe;
```

### 6. Navigation hiérarchique - Trouver les enfants d'une section
```sql
SELECT * FROM business_activity_code 
WHERE parent_code = business_activity_code:nafrev2_section_a;
```

### 7. Remonter la hiérarchie - Trouver le parent
```sql
SELECT parent_code.* FROM business_activity_code 
WHERE code = '01.11Z' AND nomenclature_type = business_nomenclature_type:nafrev2;
```

### 8. Recherche full-text sur les libellés
```sql
SELECT * FROM business_activity_code 
WHERE libelle_long @@ 'agriculture céréales';
```

### 9. Filtrage en cascade (pour UI)
```sql
-- Étape 1: Sélectionner une section
SELECT * FROM business_activity_code 
WHERE hierarchical_level = business_hierarchical_level:section
  AND nomenclature_type = business_nomenclature_type:nafrev2;

-- Étape 2: Sélectionner une division (enfants de la section choisie)
SELECT * FROM business_activity_code 
WHERE parent_code = business_activity_code:nafrev2_section_a
  AND hierarchical_level = business_hierarchical_level:division;

-- Étape 3: Sélectionner un groupe (enfants de la division)
SELECT * FROM business_activity_code 
WHERE parent_code = business_activity_code:nafrev2_01
  AND hierarchical_level = business_hierarchical_level:groupe;

-- etc.
```

### 10. Statistiques par section
```sql
-- Nombre d'entreprises par section (à adapter selon votre table d'entreprises)
SELECT 
    section.code,
    section.libelle_court,
    COUNT(*) as nb_entreprises
FROM business_unite_legale ul
JOIN business_activity_code activity ON ul.activity_code = activity.id
JOIN business_activity_code section ON activity.parent_code.parent_code.parent_code = section.id
WHERE section.hierarchical_level = business_hierarchical_level:section
GROUP BY section.code, section.libelle_court
ORDER BY nb_entreprises DESC;
```

---

## 🚀 ORDRE D'IMPORT

Pour importer ces données dans SurrealDB, suivre cet ordre :

```bash
# 1. Tables de référence (pas de dépendances)
surreal import business_nomenclature_type.surql
surreal import business_nomenclature_type_seeds.surql

surreal import business_hierarchical_level.surql
surreal import business_hierarchical_level_seeds.surql

# 2. Table principale (dépend des deux précédentes)
surreal import business_activity_code.surql

# 3. Seeds (attention: gros fichier - 4 602 INSERT)
surreal import business_activity_code_seeds.surql
```

---

## ✅ AVANTAGES DE CETTE STRUCTURE

### 🔧 **Modulaire**
- Aucun hardcoding de nomenclatures ou de niveaux
- Facile d'ajouter de nouvelles nomenclatures futures

### 📈 **Évolutif**
- Nouvelles nomenclatures : simple INSERT dans `business_nomenclature_type`
- Nouveaux niveaux : simple INSERT dans `business_hierarchical_level`

### 🔍 **Performant**
- Index optimisés pour tous les types de recherches
- Full-text search sur les libellés
- Navigation hiérarchique rapide

### 🎨 **Flexible**
- Filtrage multi-critères facile
- Support de toutes les nomenclatures historiques
- Hiérarchie complète disponible

---

## 🔮 AJOUT D'UNE FUTURE NOMENCLATURE

Si une nouvelle nomenclature apparaît (ex: NAF Rev 3 en 2030):

```sql
-- 1. Ajouter le type de nomenclature
CREATE business_nomenclature_type:nafrev3 SET
    code = 'NAFRev3',
    name = 'NAF Révision 3',
    description = 'Nomenclature d\'Activités Française Révision 3',
    period_start = 2030,
    period_end = NONE,
    is_active = true,
    sort_order = 5;

-- 2. Désactiver l'ancienne (si nécessaire)
UPDATE business_nomenclature_type:nafrev2 SET
    period_end = 2030,
    is_active = false;

-- 3. Importer les nouveaux codes
CREATE business_activity_code:nafrev3_01_11z SET
    code = '01.11Z',
    nomenclature_type = business_nomenclature_type:nafrev3,
    hierarchical_level = business_hierarchical_level:sous_classe,
    parent_code = business_activity_code:nafrev3_01_11,
    libelle_long = '...',
    libelle_moyen = '...',
    libelle_court = '...';
```

**Aucune modification de schéma nécessaire !** ✅

---

## 📁 FICHIERS

- `business_nomenclature_type.surql` - Schéma de la table
- `business_nomenclature_type_seeds.surql` - 4 nomenclatures
- `business_hierarchical_level.surql` - Schéma de la table
- `business_hierarchical_level_seeds.surql` - 5 niveaux
- `business_activity_code.surql` - Schéma de la table
- `business_activity_code_seeds.surql` - 4 602 codes (⚠️ gros fichier)
- `README.md` - Cette documentation

---

## 🎯 COUVERTURE

✅ **100% des entreprises SIRENE** couvertes  
✅ **Toutes les nomenclatures** depuis 1973  
✅ **Toute la hiérarchie** (5 niveaux)  
✅ **Structure évolutive** pour le futur  

---

**Développé pour le module Business - Dataset FR** 🇫🇷

