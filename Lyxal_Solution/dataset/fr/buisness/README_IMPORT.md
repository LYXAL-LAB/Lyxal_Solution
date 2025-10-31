# 📥 Import SIRENE vers SurrealDB

Guide complet pour importer les **28 millions d'entreprises** du fichier SIRENE vers SurrealDB.

---

## 🎯 Prérequis

### 1. SurrealDB installé et lancé
```bash
# Télécharger SurrealDB
# https://surrealdb.com/install

# Lancer SurrealDB
surreal start --log trace --user root --pass root file:database.db
```

### 2. Python avec dépendances
```bash
pip install surrealdb asyncio
```

### 3. Fichier SIRENE
- ✅ `StockUniteLegale_utf8.jsonl` (28 760 238 lignes)
- 📍 Emplacement: `Lyxal_Solution/dataset/StockUniteLegale_utf8.jsonl`

---

## 🚀 Étapes d'import

### Étape 1 : Créer les tables de référence

**Ordre d'exécution des fichiers `.surql` :**

```bash
# 1. Tables i18n (si pas déjà créées)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/Lyxal_Surreal/base/i18n/*.surql

# 2. Nomenclatures
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_nomenclature_type.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_nomenclature_type_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_nomenclature_type_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_nomenclature_type_i18n_translations.surql

# 3. Niveaux hiérarchiques
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_hierarchical_level.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_hierarchical_level_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_hierarchical_level_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_hierarchical_level_i18n_translations.surql

# 4. Codes activité (4 602 codes)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_activity_code.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_activity_code_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_activity_code_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_activity_code_i18n_translations.surql

# 5. Formes juridiques (307 formes)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_level.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_level_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_level_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_level_i18n_translations.surql

surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_legal_form_i18n_translations.surql

# 6. Tranches d'effectifs (14 tranches)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_workforce_range.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_workforce_range_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_workforce_range_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_workforce_range_i18n_translations.surql

# 7. Catégories d'entreprises (4 catégories)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_company_category.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_company_category_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_company_category_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_company_category_i18n_translations.surql

# 8. Statuts administratifs (2 statuts)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_administrative_status.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_administrative_status_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_administrative_status_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_administrative_status_i18n_translations.surql

# 9. Genres (3 genres)
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_gender.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_gender_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_gender_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_gender_i18n_translations.surql

# 10. Table principale business_company
surreal import --conn http://localhost:8000 --user root --pass root --ns production --db lyxal Lyxal_Solution/dataset/fr/buisness/datatable/business_company.surql
```

---

### Étape 2 : Lancer l'import des entreprises

```bash
python import_sirene_to_surrealdb.py
```

**Caractéristiques :**
- ✅ Import par **batch** (1000 enregistrements à la fois)
- ✅ **Checkpoint** tous les 10 000 enregistrements (reprise possible)
- ✅ Affichage de la **progression** en temps réel
- ✅ Estimation du **temps restant**
- ✅ Gestion des **erreurs** sans interruption
- ✅ **Reprise automatique** en cas d'interruption

---

## 📊 Performance estimée

### Temps d'import (estimation)

| Vitesse | Temps total | Note |
|---------|-------------|------|
| 100 /s | 80 heures | Ordinateur standard |
| 500 /s | 16 heures | Serveur performant |
| 1000 /s | 8 heures | Serveur dédié optimisé |

### Espace disque requis

- **Fichier source JSONL** : ~15 GB
- **Base SurrealDB** : ~25-30 GB (estimé)
- **Total recommandé** : 50 GB d'espace libre

---

## 🔄 Reprise après interruption

Le script sauvegarde automatiquement la progression dans `import_checkpoint.json`.

En cas d'interruption (Ctrl+C, plantage, coupure réseau) :
1. Relancer simplement le script : `python import_sirene_to_surrealdb.py`
2. Il reprendra automatiquement à partir du dernier checkpoint

**Fichier checkpoint :**
```json
{
  "last_processed": 150000,
  "total_imported": 149823,
  "errors": 177,
  "timestamp": "2025-10-20T15:30:45.123456"
}
```

---

## ⚙️ Configuration

Modifier les paramètres dans `import_sirene_to_surrealdb.py` :

```python
# Connexion SurrealDB
SURREALDB_URL = "ws://localhost:8000/rpc"
SURREALDB_NAMESPACE = "production"
SURREALDB_DATABASE = "lyxal"
SURREALDB_USER = "root"
SURREALDB_PASSWORD = "root"

# Performance
BATCH_SIZE = 1000          # Augmenter si serveur performant
CHECKPOINT_EVERY = 10000   # Fréquence de sauvegarde
```

---

## 🔍 Vérification post-import

### 1. Compter les entreprises importées
```sql
SELECT count() FROM business_company;
-- Résultat attendu: 28 760 238
```

### 2. Vérifier les entreprises actives
```sql
SELECT count() FROM business_company 
WHERE legal.administrative_status = business_administrative_status:status_a;
-- Résultat attendu: ~21 millions (74%)
```

### 3. Répartition par catégorie
```sql
SELECT classification.category, count() AS total
FROM business_company
GROUP BY classification.category
ORDER BY total DESC;
```

### 4. Top 10 des formes juridiques
```sql
SELECT legal.form, count() AS total
FROM business_company
WHERE legal.form != NONE
GROUP BY legal.form
ORDER BY total DESC
LIMIT 10;
```

### 5. Vérifier les index
```sql
INFO FOR TABLE business_company;
```

---

## ❌ Dépannage

### Erreur : "Connection refused"
**Solution :** Vérifier que SurrealDB est lancé
```bash
surreal start --log trace --user root --pass root file:database.db
```

### Erreur : "Table not found"
**Solution :** Importer les schémas des tables de référence (Étape 1)

### Import trop lent
**Solutions :**
1. Augmenter `BATCH_SIZE` (ex: 5000)
2. Vérifier les ressources système (CPU, RAM, disque)
3. Utiliser un SSD plutôt qu'un HDD
4. Désactiver temporairement les index (réactiver après)

### Erreurs JSON
**Solution :** Le script ignore automatiquement les lignes mal formatées et continue

---

## 📈 Monitoring pendant l'import

Le script affiche en temps réel :
```
   📊 1,000,000 lignes | ✅ 998,543 importées | ❌ 1,457 erreurs | ⚡ 850 /s | ⏳ ETA: 8.5h
```

Légende :
- 📊 **Lignes traitées** : Nombre de lignes lues
- ✅ **Importées** : Nombre d'entreprises dans SurrealDB
- ❌ **Erreurs** : Lignes non importées (format invalide, etc.)
- ⚡ **Vitesse** : Enregistrements par seconde
- ⏳ **ETA** : Temps estimé restant

---

## 🎯 Après l'import

### Optimiser les performances
```sql
-- Reconstruire les index
REBUILD INDEX siren_idx ON business_company;
REBUILD INDEX legal_form_idx ON business_company;
REBUILD INDEX activity_code_idx ON business_company;
REBUILD INDEX admin_status_idx ON business_company;

-- Analyser les statistiques
ANALYZE TABLE business_company;
```

### Créer des vues utiles
```sql
-- Vue des entreprises actives
DEFINE TABLE IF NOT EXISTS business_company_active AS
    SELECT * FROM business_company
    WHERE legal.administrative_status = business_administrative_status:status_a;

-- Vue des PME actives
DEFINE TABLE IF NOT EXISTS business_pme_active AS
    SELECT * FROM business_company
    WHERE classification.category = business_company_category:cat_pme
    AND legal.administrative_status = business_administrative_status:status_a;
```

---

## 📞 Support

Pour toute question sur l'import :
1. Vérifier les logs SurrealDB
2. Consulter le fichier `import_checkpoint.json`
3. Vérifier l'espace disque disponible
4. Consulter la documentation SurrealDB : https://surrealdb.com/docs

---

## ✅ Checklist finale

- [ ] SurrealDB lancé et accessible
- [ ] Python 3.8+ avec `surrealdb` et `asyncio`
- [ ] 50 GB d'espace disque disponible
- [ ] Toutes les tables de référence créées (Étape 1)
- [ ] Table `business_company` créée
- [ ] Fichier JSONL accessible
- [ ] Script `import_sirene_to_surrealdb.py` configuré
- [ ] Lancement de l'import
- [ ] Vérification post-import effectuée
- [ ] Index reconstruits et optimisés

---

**Bon import ! 🚀**

