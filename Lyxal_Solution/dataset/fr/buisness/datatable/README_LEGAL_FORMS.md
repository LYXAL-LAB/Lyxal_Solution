# 📋 Formes Juridiques - Documentation

## Vue d'ensemble

Ce module gère les **formes juridiques officielles françaises** avec leur hiérarchie complète à 3 niveaux et l'internationalisation (i18n) dans 5 langues.

---

## 🗂️ Structure des tables

### 1. `business_legal_form_level`
**Niveaux hiérarchiques des formes juridiques**

| Champ | Type | Description |
|-------|------|-------------|
| `code` | `string` | Code unique du niveau (level_1, level_2, level_3) |
| `name_i18n_key` | `record<i18n_key>` | Clé i18n pour le nom du niveau |
| `description_i18n_key` | `record<i18n_key>` | Clé i18n pour la description |
| `level_number` | `int` | Numéro du niveau (1, 2 ou 3) |
| `code_length` | `int` | Longueur du code juridique (1, 2 ou 4 chiffres) |
| `is_terminal` | `bool` | Niveau terminal (utilisé dans SIRENE) |
| `sort_order` | `int` | Ordre de tri |

**Exemple de données :**
```surql
business_legal_form_level:level_3 {
    code: "level_3",
    level_number: 3,
    code_length: 4,
    is_terminal: true,
    sort_order: 3
}
```

---

### 2. `business_legal_form`
**Formes juridiques des entreprises**

| Champ | Type | Description |
|-------|------|-------------|
| `code` | `string` | Code officiel (1, 2 ou 4 chiffres) |
| `level` | `record<business_legal_form_level>` | Référence vers le niveau hiérarchique |
| `parent_code` | `option<record<business_legal_form>>` | Code parent (null pour niveau I) |
| `name_i18n_key` | `record<i18n_key>` | Clé i18n pour le libellé |

**Exemple de données :**
```surql
business_legal_form:cj_5498 {
    code: "5498",
    level: business_legal_form_level:level_3,
    parent_code: business_legal_form:cj_54,
    name_i18n_key: i18n_key:i18n_legal_form_5498_name
}
```

---

## 📊 Hiérarchie des 3 niveaux

### Niveau I - Grandes catégories (10 formes)
**Code : 1 chiffre**
- Personnes physiques
- Personnes morales de droit privé
- Personnes morales de droit public
- etc.

### Niveau II - Catégories moyennes (38 formes)
**Code : 2 chiffres**
- Société à responsabilité limitée (54)
- Société par actions simplifiée (57)
- Société anonyme (56)
- etc.

### Niveau III - Catégories détaillées (259 formes)
**Code : 4 chiffres**
- SARL unipersonnelle (5498)
- SAS unipersonnelle (5710)
- SA à conseil d'administration (5599)
- etc.

> ⚠️ **Seul le niveau III** est utilisé dans le jeu de données SIRENE.

---

## 🌍 Internationalisation (i18n)

### Langues actives
- 🇫🇷 **Français** (fr) - Langue source
- 🇬🇧 **Anglais** (en)
- 🇪🇸 **Espagnol** (es)
- 🇩🇪 **Allemand** (de)
- 🇮🇹 **Italien** (it)

### Traductions disponibles

| Type | Nombre | Total traductions |
|------|--------|-------------------|
| Niveaux hiérarchiques | 3 | 30 (3 × 2 × 5 langues) |
| Formes juridiques | 307 | 1 535 (307 × 5 langues) |
| **TOTAL** | **310** | **1 565 traductions** |

### Exemples de traductions

**SARL (Société à responsabilité limitée)**
- 🇫🇷 Société à responsabilité limitée
- 🇬🇧 Limited liability company
- 🇪🇸 Sociedad de responsabilidad limitada
- 🇩🇪 Gesellschaft mit beschränkter Haftung
- 🇮🇹 Società a responsabilità limitata

**SAS (Société par actions simplifiée)**
- 🇫🇷 Société par actions simplifiée
- 🇬🇧 Simplified joint-stock company
- 🇪🇸 Sociedad por acciones simplificada
- 🇩🇪 Vereinfachte Aktiengesellschaft
- 🇮🇹 Società per azioni semplificata

---

## 📁 Fichiers générés

### Niveaux hiérarchiques
```
business_legal_form_level.surql                  ← Schéma de table
business_legal_form_level_i18n_keys.surql       ← 6 clés i18n
business_legal_form_level_i18n_translations.surql ← 30 traductions
business_legal_form_level_seeds.surql           ← 3 seeds
```

### Formes juridiques
```
business_legal_form.surql                        ← Schéma de table
business_legal_form_i18n_keys.surql             ← 307 clés i18n
business_legal_form_i18n_translations.surql     ← 1 535 traductions
business_legal_form_seeds.surql                 ← 307 seeds
```

---

## 🔍 Requêtes SurrealQL utiles

### Récupérer toutes les formes juridiques de niveau III (terminales)
```surql
SELECT * FROM business_legal_form
WHERE level = business_legal_form_level:level_3;
```

### Récupérer une forme juridique avec sa traduction
```surql
SELECT *,
    (SELECT text FROM i18n_translation WHERE in = name_i18n_key AND out = i18n_language:fr) AS name_fr
FROM business_legal_form:cj_5498;
```

### Récupérer la hiérarchie complète d'une forme juridique
```surql
SELECT *,
    parent_code.*,
    parent_code.parent_code.*
FROM business_legal_form:cj_5498;
```

### Compter les formes par niveau
```surql
SELECT level.level_number, count() AS total
FROM business_legal_form
GROUP BY level.level_number
ORDER BY level.level_number;
```

---

## 📊 Statistiques

- **Total formes juridiques** : 307
- **Niveau I** : 10 formes (1 chiffre)
- **Niveau II** : 38 formes (2 chiffres)
- **Niveau III** : 259 formes (4 chiffres) ← **Utilisé dans SIRENE**

- **Clés i18n** : 313 (3 niveaux + 307 formes, avec 2 clés/entité pour certains)
- **Traductions** : 1 565 (313 entités × 5 langues)

---

## 🔗 Intégration avec SIRENE

Le champ `categorieJuridiqueUniteLegale` dans le jeu de données SIRENE utilise les codes du **niveau III uniquement**.

**Exemple de lien :**
```surql
DEFINE FIELD IF NOT EXISTS legal_form ON TABLE business_unite_legale
    TYPE option<record<business_legal_form>>
    COMMENT 'Forme juridique (niveau III uniquement)';
```

**Lors de l'import SIRENE :**
```python
# Si categorieJuridiqueUniteLegale = "5498"
legal_form = f"business_legal_form:cj_5498"
```

---

## 📝 Source officielle

Données extraites de : `cj_septembre_2022.xls`  
Source : INSEE - Nomenclature des catégories juridiques

---

## ✅ Validation

### Vérifier l'intégrité des données
```surql
-- Toutes les formes de niveau II et III doivent avoir un parent
SELECT * FROM business_legal_form
WHERE parent_code = NONE AND level != business_legal_form_level:level_1;

-- Toutes les formes doivent avoir une clé i18n valide
SELECT * FROM business_legal_form
WHERE name_i18n_key = NONE;

-- Toutes les clés i18n doivent avoir 5 traductions
SELECT in, count() AS nb_translations
FROM i18n_translation
WHERE in IN (SELECT name_i18n_key FROM business_legal_form)
GROUP BY in
HAVING nb_translations != 5;
```

---

## 🎯 Prochaines étapes

1. ✅ **Formes juridiques** (terminé)
2. 🔄 **Tranches d'effectifs** (`business_workforce_range`)
3. 🔄 **Catégories d'entreprises** (`business_company_category`)
4. 🔄 **Statuts administratifs** (`business_administrative_status`)
5. 🔄 **Statuts ESS** (`business_ess_status`)
6. 🔄 **Genres** (`business_gender`)
7. 🔄 **Table principale** (`business_unite_legale`)

---

## 📞 Questions / Support

Pour toute question sur l'utilisation de ces tables, référez-vous au `README.md` principal du module business.

