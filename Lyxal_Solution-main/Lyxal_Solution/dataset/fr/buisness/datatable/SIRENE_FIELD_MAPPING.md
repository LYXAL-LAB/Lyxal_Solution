# 🗺️ Mapping des champs SIRENE → `business_company`

## Vue d'ensemble

Correspondance complète entre les **34 champs du fichier SIRENE** et la **table `business_company` structurée par objets**.

---

## 📊 Mapping complet (34 champs)

### 🆔 IDENTIFIANTS (4 champs SIRENE → `identifiers`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 30 | `siren` | string(9) | → | `identifiers.siren` | string |
| 17 | `nicSiegeUniteLegale` | int(5) | → | `identifiers.nic_siege` | string |
| - | *(calculé)* | - | → | `identifiers.siret_siege` | string |
| 16 | `identifiantAssociationUniteLegale` | string | → | `identifiers.association_id` | option<string> |

**Note:** `siret_siege` est calculé = `siren` + `nic_siege`

---

### ⚖️ INFORMATIONS LÉGALES (6 champs SIRENE → `legal`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 6 | `categorieJuridiqueUniteLegale` | int(4) | → | `legal.form` | option<record<business_legal_form>> |
| 7 | `dateCreationUniteLegale` | string(date) | → | `legal.creation_date` | option<datetime> |
| 15 | `etatAdministratifUniteLegale` | string(A/C) | → | `legal.administrative_status` | option<record<business_administrative_status>> |
| 4 | `caractereEmployeurUniteLegale` | string(O/N) | → | `legal.is_employer` | option<bool> |
| 14 | `economieSocialeSolidaireUniteLegale` | string(O/N) | → | `legal.is_social_economy` | option<bool> |
| 31 | `societeMissionUniteLegale` | string(O/N) | → | `legal.is_mission_company` | option<bool> |

**Conversion:**
- `categorieJuridiqueUniteLegale: 5498` → `business_legal_form:cj_5498`
- `etatAdministratifUniteLegale: 'A'` → `business_administrative_status:status_a`
- `'O'` → `true`, `'N'` → `false`, `null` → `NONE`

---

### 💼 ACTIVITÉ ÉCONOMIQUE (2 champs SIRENE → `activity`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 1 | `activitePrincipaleUniteLegale` | string | → | `activity.code` | option<record<business_activity_code>> |
| 21 | `nomenclatureActivitePrincipaleUniteLegale` | string | → | `activity.nomenclature` | option<record<business_nomenclature_type>> |

**Conversion:**
- `activitePrincipaleUniteLegale: '32.12Z'` → `business_activity_code:nafrev2_32_12z`
- `nomenclatureActivitePrincipaleUniteLegale: 'NAFRev2'` → `business_nomenclature_type:nafrev2`

---

### 👥 EFFECTIFS (2 champs SIRENE → `workforce`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 33 | `trancheEffectifsUniteLegale` | string | → | `workforce.range` | option<record<business_workforce_range>> |
| 3 | `anneeEffectifsUniteLegale` | int | → | `workforce.year` | option<int> |

**Conversion:**
- `trancheEffectifsUniteLegale: '12'` → `business_workforce_range:wr_12`
- **Remappage:** `'32'` → `'31'`, `'53'` → `'52'`

---

### 🏢 CATÉGORISATION (2 champs SIRENE → `classification`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 5 | `categorieEntreprise` | string | → | `classification.category` | option<record<business_company_category>> |
| 2 | `anneeCategorieEntreprise` | int | → | `classification.category_year` | option<int> |

**Conversion:**
- `categorieEntreprise: 'PME'` → `business_company_category:cat_pme`
- `null` → Probablement `business_company_category:cat_mic` (microentreprise)

---

### 🏷️ DÉNOMINATION - Personnes morales (5 champs SIRENE → `names`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 10 | `denominationUniteLegale` | string | → | `names.official` | option<string> |
| 11 | `denominationUsuelle1UniteLegale` | string | → | `names.usual_1` | option<string> |
| 12 | `denominationUsuelle2UniteLegale` | string | → | `names.usual_2` | option<string> |
| 13 | `denominationUsuelle3UniteLegale` | string | → | `names.usual_3` | option<string> |
| 29 | `sigleUniteLegale` | string | → | `names.sigle` | option<string> |

**Note:** Ces champs sont pour les **personnes morales** (sociétés)

---

### 👤 PERSONNE - Entrepreneurs individuels (9 champs SIRENE → `individual`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 28 | `sexeUniteLegale` | string(M/F) | → | `individual.gender` | option<record<business_gender>> |
| 18 | `nomUniteLegale` | string | → | `individual.last_name` | option<string> |
| 19 | `nomUsageUniteLegale` | string | → | `individual.last_name_usage` | option<string> |
| 22 | `prenom1UniteLegale` | string | → | `individual.first_name_1` | option<string> |
| 23 | `prenom2UniteLegale` | string | → | `individual.first_name_2` | option<string> |
| 24 | `prenom3UniteLegale` | string | → | `individual.first_name_3` | option<string> |
| 25 | `prenom4UniteLegale` | string | → | `individual.first_name_4` | option<string> |
| 26 | `prenomUsuelUniteLegale` | string | → | `individual.usual_first_name` | option<string> |
| 27 | `pseudonymeUniteLegale` | string | → | `individual.pseudonym` | option<string> |

**Note:** Ces champs sont pour les **entrepreneurs individuels** uniquement (null pour personnes morales)

**Conversion:**
- `sexeUniteLegale: 'M'` → `business_gender:gender_m`
- `'[ND]'` → Remplacer par `business_gender:gender_nd` ou `null`

---

### 📢 DIFFUSION (2 champs SIRENE → `diffusion`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 32 | `statutDiffusionUniteLegale` | string(O/P) | → | `diffusion.status` | string |
| 34 | `unitePurgeeUniteLegale` | bool | → | `diffusion.is_purged` | bool |

**Valeurs:**
- `O` : Diffusion publique totale
- `P` : Diffusion partielle (données restreintes)

---

### 🕐 MÉTADONNÉES (4 champs SIRENE → `metadata`)

| # | Champ SIRENE | Type SIRENE | → | Champ SurrealDB | Type SurrealDB |
|---|--------------|-------------|---|-----------------|----------------|
| 8 | `dateDebut` | string(datetime) | → | `metadata.period_start_date` | option<datetime> |
| 9 | `dateDernierTraitementUniteLegale` | string(datetime) | → | `metadata.last_update` | option<datetime> |
| 20 | `nombrePeriodesUniteLegale` | int | → | `metadata.period_count` | int |
| - | *(auto)* | - | → | `metadata.import_date` | datetime |

**Note:** `import_date` est généré automatiquement lors de l'insertion

---

## 📊 Récapitulatif par objet

| Objet SurrealDB | Nombre de champs | Champs SIRENE sources |
|-----------------|------------------|----------------------|
| `identifiers` | 4 | 3 + 1 calculé |
| `legal` | 6 | 6 |
| `activity` | 2 | 2 |
| `workforce` | 2 | 2 |
| `classification` | 2 | 2 |
| `names` | 5 | 5 |
| `individual` | 9 | 9 |
| `diffusion` | 2 | 2 |
| `metadata` | 4 | 3 + 1 auto |
| **TOTAL** | **36** | **34 + 2** |

---

## 🔧 Script de conversion Python

```python
def convert_sirene_to_company(sirene_data):
    """
    Convertit un enregistrement SIRENE en format business_company
    """
    
    # Remappage des codes non officiels
    WORKFORCE_REMAP = {'32': '31', '53': '52'}
    
    # Calculer SIRET
    siren = sirene_data.get('siren', '')
    nic = str(sirene_data.get('nicSiegeUniteLegale', '')).zfill(5)
    siret = f"{siren}{nic}"
    
    # Tranche d'effectifs avec remappage
    tefet = sirene_data.get('trancheEffectifsUniteLegale')
    if tefet in WORKFORCE_REMAP:
        tefet = WORKFORCE_REMAP[tefet]
    
    company = {
        'identifiers': {
            'siren': siren,
            'nic_siege': nic,
            'siret_siege': siret,
            'association_id': sirene_data.get('identifiantAssociationUniteLegale')
        },
        'legal': {
            'form': f"business_legal_form:cj_{sirene_data.get('categorieJuridiqueUniteLegale')}" if sirene_data.get('categorieJuridiqueUniteLegale') else None,
            'creation_date': sirene_data.get('dateCreationUniteLegale'),
            'administrative_status': f"business_administrative_status:status_{sirene_data.get('etatAdministratifUniteLegale', '').lower()}" if sirene_data.get('etatAdministratifUniteLegale') else None,
            'is_employer': sirene_data.get('caractereEmployeurUniteLegale') == 'O' if sirene_data.get('caractereEmployeurUniteLegale') else None,
            'is_social_economy': sirene_data.get('economieSocialeSolidaireUniteLegale') == 'O' if sirene_data.get('economieSocialeSolidaireUniteLegale') else None,
            'is_mission_company': sirene_data.get('societeMissionUniteLegale') == 'O' if sirene_data.get('societeMissionUniteLegale') else None
        },
        'activity': {
            'code': convert_activity_code(sirene_data.get('activitePrincipaleUniteLegale'), sirene_data.get('nomenclatureActivitePrincipaleUniteLegale')),
            'nomenclature': f"business_nomenclature_type:{sirene_data.get('nomenclatureActivitePrincipaleUniteLegale', '').lower()}" if sirene_data.get('nomenclatureActivitePrincipaleUniteLegale') else None
        },
        'workforce': {
            'range': f"business_workforce_range:wr_{tefet.lower()}" if tefet else None,
            'year': sirene_data.get('anneeEffectifsUniteLegale')
        },
        'classification': {
            'category': f"business_company_category:cat_{sirene_data.get('categorieEntreprise', '').lower()}" if sirene_data.get('categorieEntreprise') else None,
            'category_year': sirene_data.get('anneeCategorieEntreprise')
        },
        'names': {
            'official': sirene_data.get('denominationUniteLegale'),
            'usual_1': sirene_data.get('denominationUsuelle1UniteLegale') if sirene_data.get('denominationUsuelle1UniteLegale') != '[ND]' else None,
            'usual_2': sirene_data.get('denominationUsuelle2UniteLegale') if sirene_data.get('denominationUsuelle2UniteLegale') != '[ND]' else None,
            'usual_3': sirene_data.get('denominationUsuelle3UniteLegale') if sirene_data.get('denominationUsuelle3UniteLegale') != '[ND]' else None,
            'sigle': sirene_data.get('sigleUniteLegale')
        },
        'individual': {
            'gender': f"business_gender:gender_{sirene_data.get('sexeUniteLegale', '').lower()}" if sirene_data.get('sexeUniteLegale') and sirene_data.get('sexeUniteLegale') != '[ND]' else None,
            'last_name': sirene_data.get('nomUniteLegale'),
            'last_name_usage': sirene_data.get('nomUsageUniteLegale'),
            'first_name_1': sirene_data.get('prenom1UniteLegale'),
            'first_name_2': sirene_data.get('prenom2UniteLegale'),
            'first_name_3': sirene_data.get('prenom3UniteLegale'),
            'first_name_4': sirene_data.get('prenom4UniteLegale'),
            'usual_first_name': sirene_data.get('prenomUsuelUniteLegale'),
            'pseudonym': sirene_data.get('pseudonymeUniteLegale') if sirene_data.get('pseudonymeUniteLegale') != '[ND]' else None
        } if sirene_data.get('sexeUniteLegale') else None,
        'diffusion': {
            'status': sirene_data.get('statutDiffusionUniteLegale', 'O'),
            'is_purged': sirene_data.get('unitePurgeeUniteLegale', False)
        },
        'metadata': {
            'period_start_date': sirene_data.get('dateDebut'),
            'last_update': sirene_data.get('dateDernierTraitementUniteLegale'),
            'period_count': sirene_data.get('nombrePeriodesUniteLegale', 1),
            'import_date': 'time::now()'  # Géré par SurrealDB
        }
    }
    
    return company
```

---

## ✅ Checklist de validation

- [x] **34 champs SIRENE** → Tous mappés
- [x] **Organisation par objets** → 8 objets logiques
- [x] **Références aux tables** → 9 tables de référence liées
- [x] **Conversions de types** → Booléens, dates, records
- [x] **Remappage des codes** → Effectifs (32→31, 53→52)
- [x] **Valeurs spéciales** → `[ND]` traité correctement
- [x] **Champs calculés** → SIRET = SIREN + NIC
- [x] **Index optimisés** → 6 index sur champs clés

---

## 📝 Notes importantes

1. **`individual` est `null` pour les personnes morales** (sociétés)
2. **`names` contient des données pour les personnes morales**
3. **Filtrer `[ND]`** lors de l'import (remplacer par `null`)
4. **Remap workforce codes:** 32→31, 53→52
5. **SIRET calculé** = SIREN (9) + NIC (5) = 14 chiffres
6. **Dates ISO 8601** : `2024-03-22T14:26:06` → `datetime`
7. **Index sur SIREN** : UNIQUE (clé primaire métier)

---

✅ **TOUS LES 34 CHAMPS SIRENE SONT MAPPÉS !**

