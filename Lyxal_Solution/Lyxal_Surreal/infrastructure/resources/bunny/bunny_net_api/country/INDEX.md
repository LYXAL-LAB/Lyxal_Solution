# 📚 Index - Bunny Country API

Documentation complète pour la gestion des pays Bunny.net.

---

## 📁 Structure des Fichiers

```
country/
├── INDEX.md                           (ce fichier)
├── README.md                          (documentation principale)
├── fn_bunny_get_country_list.surql   (fonction: récupérer la liste)
├── fn_bunny_sync_countries.surql     (fonction: synchroniser)
├── fn_bunny_get_country_by_code.surql (fonction: get par code)
├── examples.surql                     (16 exemples pratiques)
└── tests.surql                        (11 tests unitaires)
```

---

## 🎯 Résumé Rapide

**Endpoint** : `GET https://api.bunny.net/country`  
**Auth** : Public (pas d'API key)  
**Objectif** : Récupérer la liste des pays disponibles sur Bunny.net avec infos fiscales

---

## 📋 Contenu par Fichier

### 1. **README.md** (Documentation Principale)

**Sections** :
- 3 fonctions disponibles
- Exemples d'utilisation
- Structure de la table `bunny_country`
- Stratégies de synchronisation
- Use cases principaux
- Démarrage rapide

**Pour qui** : Tous · Documentation de référence

---

### 2. **Fonctions SurrealDB** (3 fichiers)

**fn_bunny_get_country_list.surql** (180 lignes)
- Fonction : `fn::bunny_get_country_list()`
- Fetch API direct
- Gestion complète des erreurs (400/401/500/503)

**fn_bunny_sync_countries.surql** (55 lignes)
- Fonction : `fn::bunny_sync_countries()`
- Synchronise dans table locale

**fn_bunny_get_country_by_code.surql** (70 lignes)
- Fonction : `fn::bunny_get_country_by_code($iso_code)`
- Récupère un pays spécifique

**Pour qui** : Développeurs · Implémentation

---

### 3. **examples.surql** (Exemples Pratiques)

**15 exemples** :

1. Récupérer et afficher tous les pays
2. Synchroniser et utiliser la table locale
3. Calculer le prix TTC par pays
4. Grouper les pays par continent avec stats
5. Top 10 pays avec le plus de taxes
6. Créer un sélecteur de pays pour formulaire
7. Vérifier si un pays est dans l'UE (RGPD)
8. Filtrer les pays par fourchette de taxes
9. Créer une table de conversion de prix multi-pays
10. Recherche full-text sur les noms de pays
11. Créer un rapport d'audit fiscal par région
12. Intégration avec table customers
13. Dashboard de monitoring des pays
14. Valider un code pays avant insertion
15. Export CSV des pays pour analyse externe

**Pour qui** : Développeurs · Use cases réels

---

### 4. **tests.surql** (Tests Unitaires)

**10 tests** :

1. `fn::bunny_get_country_list()` - Success
2. `fn::bunny_sync_countries()` - Success
3. `fn::bunny_get_country_by_code()` - Success
4. `fn::bunny_get_country_by_code()` - Not Found
5. Vérifier l'intégrité des données France
6. Vérifier les pays de l'UE
7. Vérifier les index et performances
8. Vérifier la synchronisation multiple (idempotence)
9. Vérifier les logs d'audit
10. Vérifier les continents

**Pour qui** : QA · Tests automatisés

---

## 🚀 Démarrage Rapide (5 Minutes)

### Étape 1 : Importer les Schémas

```bash
# Table bunny_country
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/database/bunny_country.surql

# Fonctions
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/resources/bunny/bunny_net_api/country/fn_get_country_list.surql
```

### Étape 2 : Synchroniser

```sql
-- Dans SurrealDB
CALL fn::bunny_sync_countries();
```

### Étape 3 : Utiliser

```sql
-- Lister tous les pays
SELECT * FROM bunny_country ORDER BY name;

-- France
SELECT * FROM bunny_country WHERE iso_code = 'FR';
```

---

## 📊 Table `bunny_country`

**Structure** :

| Champ | Type | Description |
|-------|------|-------------|
| `iso_code` | string | Code ISO (2 lettres, unique) |
| `name` | string | Nom du pays |
| `continent_code` | string | Code continent |
| `continent_name` | string | Nom du continent |
| `is_eu` | bool | Membre UE ? |
| `tax_rate` | float | Taux de taxe (%) |
| `tax_prefix` | string | Préfixe taxe |
| `price_override` | float? | Override de prix |
| `flag_url` | string | URL du drapeau |
| `pop_list` | array? | PoP (Points of Presence) |
| `metadata.synced_at` | datetime | Date de sync |

**Index** :
- `iso_code` (unique)
- `name`
- `continent_code`
- `is_eu`

**Note** : `PopList` = codes des serveurs edge Bunny dans ce pays (ex: ["PAR", "MRS"]).

---

## 💡 Use Cases Principaux

### 1. Formulaire de Sélection Pays

```sql
SELECT {
  value: iso_code,
  label: name,
  flag: flag_url
} FROM bunny_country ORDER BY name;
```

### 2. Calcul Prix TTC

```sql
LET $country = fn::bunny_get_country_by_code('FR');
LET $price_ttc = 100 + (100 * $country.country.tax_rate / 100);
RETURN $price_ttc; -- 120.0
```

### 3. Vérification RGPD

```sql
SELECT * FROM bunny_country 
WHERE is_eu = true 
ORDER BY name;
```

---

## 🔄 Stratégie de Synchronisation

### Recommandée : Sync Quotidienne

```sql
-- Event scheduler (à implémenter)
DEFINE EVENT sync_countries_daily ON DATABASE
WHEN time::hour(time::now()) == 2
THEN {
  fn::bunny_sync_countries();
};
```

### Alternative : Lazy Loading

```sql
-- Sync si table vide
LET $count = (SELECT count() FROM bunny_country GROUP ALL)[0].count;
IF $count == 0 THEN fn::bunny_sync_countries(); END;
```

---

## 📖 Parcours d'Apprentissage

### 🚀 Débutant (15 min)

```
1. README.md - Sections principales (10 min)
2. Importer et synchroniser (5 min)
```

**Objectif** : Comprendre et utiliser les fonctions de base

---

### 🔧 Intermédiaire (45 min)

```
1. README.md - Complet (15 min)
2. examples.surql - 5 exemples (20 min)
3. Tester sur vos propres données (10 min)
```

**Objectif** : Intégrer avec vos tables existantes

---

### 🏆 Avancé (2h)

```
1. Tous les exemples (60 min)
2. Tous les tests (30 min)
3. Créer vos propres fonctions métier (30 min)
```

**Objectif** : Maîtrise complète et personnalisation

---

## 🔗 Liens

### Documentation

- **[README.md](./README.md)** - Documentation principale
- **[examples.surql](./examples.surql)** - 16 exemples pratiques
- **[tests.surql](./tests.surql)** - 11 tests unitaires
- **[fn_bunny_get_country_list.surql](./fn_bunny_get_country_list.surql)** - Fonction get list
- **[fn_bunny_sync_countries.surql](./fn_bunny_sync_countries.surql)** - Fonction sync
- **[fn_bunny_get_country_by_code.surql](./fn_bunny_get_country_by_code.surql)** - Fonction get by code

### API Bunny.net

- **Endpoint** : https://api.bunny.net/country
- **Docs** : https://docs.bunny.net/reference/countriespublic_getcountrylist

### Infrastructure Lyxal

- **[infrastructure/README.md](../../../README.md)** - Module infrastructure
- **[infrastructure/INDEX.md](../../../INDEX.md)** - Index général

---

## ✅ Checklist d'Implémentation

### Setup Initial

- [ ] Table `bunny_country` créée
- [ ] Fonctions importées
- [ ] Première synchronisation effectuée
- [ ] Données vérifiées (France, US, etc.)

### Intégration

- [ ] Utilisé dans formulaire frontend
- [ ] Calcul de prix TTC implémenté
- [ ] Vérification RGPD activée
- [ ] Validation de codes pays en place

### Production

- [ ] Synchronisation automatique (cron/event)
- [ ] Monitoring des logs
- [ ] Tests passants
- [ ] Documentation équipe à jour

---

## 📊 Statistiques

| Métrique | Valeur |
|----------|--------|
| **Fichiers créés** | 7 |
| **Lignes de code** | ~1,300 |
| **Fonctions** | 3 (1 par fichier) |
| **Exemples** | 16 |
| **Tests** | 11 |
| **Temps de setup** | ~5 min |

---

## 🎯 Résumé

**Module Country** : Gestion complète des pays Bunny.net

✅ **API Authentifiée** : Header `Accesskey` requis  
✅ **Cache Local** : Table `bunny_country` pour performance  
✅ **3 Fonctions** : 1 fichier par fonction  
✅ **16 Exemples** : Use cases réels  
✅ **11 Tests** : Couverture complète  

**Prêt à l'emploi en 5 minutes !** 🚀

---

**Navigation** : 
- [README](./README.md) · [Exemples](./examples.surql) · [Tests](./tests.surql)
- Fonctions : [Get List](./fn_bunny_get_country_list.surql) · [Sync](./fn_bunny_sync_countries.surql) · [Get By Code](./fn_bunny_get_country_by_code.surql)

