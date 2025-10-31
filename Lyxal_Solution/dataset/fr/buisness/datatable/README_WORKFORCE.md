# 👥 Tranches d'Effectifs - Documentation

## Vue d'ensemble

Ce module gère les **tranches d'effectifs salariés officielles INSEE** avec l'internationalisation (i18n) dans 5 langues.

---

## 🗂️ Structure de la table

### `business_workforce_range`
**Tranches d'effectifs salariés des entreprises**

| Champ | Type | Description |
|-------|------|-------------|
| `code` | `string` | Code officiel INSEE (NN, 00, 01, 02, etc.) |
| `name_i18n_key` | `record<i18n_key>` | Clé i18n pour le libellé |
| `min_employees` | `option<int>` | Nombre minimum de salariés (null pour NN) |
| `max_employees` | `option<int>` | Nombre maximum de salariés (null pour illimité) |
| `sort_order` | `int` | Ordre de tri |

**Exemple de données :**
```surql
business_workforce_range:wr_12 {
    code: "12",
    min_employees: 20,
    max_employees: 49,
    sort_order: 6
}
```

---

## 📊 Nomenclature officielle INSEE (14 tranches)

| Code | Tranche | Min | Max |
|------|---------|-----|-----|
| **NN** | Non renseigné | - | - |
| **00** | 0 salarié | 0 | 0 |
| **01** | 1 ou 2 salariés | 1 | 2 |
| **02** | 3 à 5 salariés | 3 | 5 |
| **03** | 6 à 9 salariés | 6 | 9 |
| **11** | 10 à 19 salariés | 10 | 19 |
| **12** | 20 à 49 salariés | 20 | 49 |
| **21** | 50 à 99 salariés | 50 | 99 |
| **22** | 100 à 199 salariés | 100 | 199 |
| **31** | 200 à 499 salariés | 200 | 499 |
| **41** | 500 à 999 salariés | 500 | 999 |
| **42** | 1 000 à 1 999 salariés | 1 000 | 1 999 |
| **51** | 2 000 à 4 999 salariés | 2 000 | 4 999 |
| **52** | 5 000 salariés ou plus | 5 000 | ∞ |

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
| Tranches d'effectifs | 14 | 70 (14 × 5 langues) |

### Exemples de traductions

**1 ou 2 salariés (01)**
- 🇫🇷 1 ou 2 salariés
- 🇬🇧 1 or 2 employees
- 🇪🇸 1 o 2 empleados
- 🇩🇪 1 oder 2 Beschäftigte
- 🇮🇹 1 o 2 dipendenti

**200 à 499 salariés (31)**
- 🇫🇷 200 à 499 salariés
- 🇬🇧 200 to 499 employees
- 🇪🇸 200 a 499 empleados
- 🇩🇪 200 bis 499 Beschäftigte
- 🇮🇹 200 a 499 dipendenti

**5 000 salariés ou plus (52)**
- 🇫🇷 5 000 salariés ou plus
- 🇬🇧 5,000 employees or more
- 🇪🇸 5.000 empleados o más
- 🇩🇪 5.000 Beschäftigte oder mehr
- 🇮🇹 5.000 dipendenti o più

---

## 📁 Fichiers générés

```
business_workforce_range.surql                    ← Schéma de table
business_workforce_range_i18n_keys.surql         ← 14 clés i18n
business_workforce_range_i18n_translations.surql ← 70 traductions
business_workforce_range_seeds.surql             ← 14 seeds
```

---

## 🔍 Requêtes SurrealQL utiles

### Récupérer toutes les tranches triées
```surql
SELECT * FROM business_workforce_range
ORDER BY sort_order;
```

### Récupérer une tranche avec sa traduction
```surql
SELECT *,
    (SELECT text FROM i18n_translation WHERE in = name_i18n_key AND out = i18n_language:fr) AS name_fr
FROM business_workforce_range:wr_12;
```

### Trouver la tranche pour un nombre de salariés
```surql
SELECT * FROM business_workforce_range
WHERE min_employees <= 35 AND (max_employees >= 35 OR max_employees = NONE)
AND code != 'NN';
-- Résultat : 12 (20 à 49 salariés)
```

### Filtrer les PME (moins de 250 salariés)
```surql
SELECT * FROM business_workforce_range
WHERE max_employees < 250
ORDER BY sort_order;
```

### Filtrer les grandes entreprises (250+ salariés)
```surql
SELECT * FROM business_workforce_range
WHERE min_employees >= 250
ORDER BY sort_order;
```

---

## 📊 Statistiques d'utilisation (données SIRENE)

Sur 100 000 unités légales analysées :
- **75,5%** : Non renseigné (NN)
- **23,3%** : 1 ou 2 salariés (01)
- **0,5%** : 3 à 5 salariés (02)
- **0,3%** : 0 salarié (00)
- Autres tranches : < 0,2% chacune

> ⚠️ La majorité des entreprises françaises sont des micro-entreprises ou auto-entrepreneurs.

---

## 🔗 Intégration avec SIRENE

### 2 champs d'effectifs dans SIRENE

#### 1. **TEFET** - `trancheEffectifsUniteLegale` (Tranche d'effectif)
**Type:** `string` → Référence vers `business_workforce_range`  
**Valeurs:** 14 codes officiels (NN, 00, 01, 02, 03, 11, 12, 21, 22, 31, 41, 42, 51, 52)

```surql
DEFINE FIELD IF NOT EXISTS workforce_range ON TABLE business_unite_legale
    TYPE option<record<business_workforce_range>>
    COMMENT 'Tranche d\'effectifs salariés (TEFET)';
```

#### 2. **EFETCENT** - Effectif salarié approché
**Type:** `int` (simple champ numérique, pas de table de référence)  
**Valeurs:** 0, 1, 3, 6, 10, 20, 50, 100, 200, 300... (de 100 en 100 au-delà de 200)

```surql
DEFINE FIELD IF NOT EXISTS workforce_approximate ON TABLE business_unite_legale
    TYPE option<int>
    COMMENT 'Effectif salarié approché (EFETCENT) - valeur numérique';
```

#### 3. Année des effectifs
```surql
DEFINE FIELD IF NOT EXISTS workforce_year ON TABLE business_unite_legale
    TYPE option<int>
    COMMENT 'Année des effectifs (anneeEffectifsUniteLegale)';
```

### ⚠️ Gestion des codes non officiels lors de l'import

**Codes trouvés mais non officiels:**
- `32` (1,585 cas) → Doit être remappé vers `31`
- `53` (30 cas) → Doit être remappé vers `52`

**Script d'import Python:**
```python
# Remappage des codes non officiels
WORKFORCE_REMAP = {
    '32': '31',  # 250-499 → 200-499
    '53': '52'   # 10000+ → 5000+
}

# Lors de l'import
tefet_code = data.get('trancheEffectifsUniteLegale')
if tefet_code in WORKFORCE_REMAP:
    tefet_code = WORKFORCE_REMAP[tefet_code]

workforce_range = f"business_workforce_range:wr_{tefet_code.lower()}" if tefet_code else None
workforce_approximate = data.get('EFETCENT')  # Valeur numérique directe
workforce_year = data.get('anneeEffectifsUniteLegale')
```

---

## 📈 Catégorisation par taille d'entreprise

### Micro-entreprise
- **00** : 0 salarié
- **01** : 1 ou 2 salariés
- **02** : 3 à 5 salariés
- **03** : 6 à 9 salariés

### Petite entreprise (TPE/PME)
- **11** : 10 à 19 salariés
- **12** : 20 à 49 salariés

### Moyenne entreprise (PME)
- **21** : 50 à 99 salariés
- **22** : 100 à 199 salariés
- **31** : 200 à 499 salariés

### Grande entreprise (ETI/GE)
- **41** : 500 à 999 salariés
- **42** : 1 000 à 1 999 salariés
- **51** : 2 000 à 4 999 salariés
- **52** : 5 000 salariés ou plus

---

## ✅ Validation

### Vérifier l'intégrité des données
```surql
-- Toutes les tranches doivent avoir une clé i18n valide
SELECT * FROM business_workforce_range
WHERE name_i18n_key = NONE;

-- Toutes les clés i18n doivent avoir 5 traductions
SELECT in, count() AS nb_translations
FROM i18n_translation
WHERE in IN (SELECT name_i18n_key FROM business_workforce_range)
GROUP BY in
HAVING nb_translations != 5;

-- Vérifier la cohérence min/max (sauf NN et 53)
SELECT * FROM business_workforce_range
WHERE code NOT IN ['NN', '53']
AND (min_employees >= max_employees OR min_employees = NONE OR max_employees = NONE);
```

---

## 🎯 Prochaines étapes

1. ✅ **Formes juridiques** (terminé)
2. ✅ **Tranches d'effectifs** (terminé)
3. 🔄 **Catégories d'entreprises** (`business_company_category`)
4. 🔄 **Statuts administratifs** (`business_administrative_status`)
5. 🔄 **Genres** (`business_gender`)
6. 🔄 **Table principale** (`business_unite_legale`)

---

## 📞 Questions / Support

Pour toute question sur l'utilisation de cette table, référez-vous au `README.md` principal du module business.

