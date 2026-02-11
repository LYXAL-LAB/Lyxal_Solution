# 🌍 Bunny.net API - Countries

Fonctions pour gérer la liste des pays disponibles sur Bunny.net.

---

## 📁 Fichiers

- **`fn_bunny_get_country_list.surql`** - Récupère la liste complète
- **`fn_bunny_sync_countries.surql`** - Synchronise dans la table locale
- **`fn_bunny_get_country_by_code.surql`** - Récupère un pays spécifique

---

## ⚠️ Note Importante sur la Syntaxe

**Seule `fn::bunny_get_country_list()`** utilise la syntaxe JavaScript avec `RETURN function() { ... }` car elle fait un appel API via `fetch()`.

Les 2 autres fonctions (`fn::bunny_sync_countries()` et `fn::bunny_get_country_by_code()`) sont en **SurrealQL pur** car elles ne font pas d'appel HTTP.

**Référence** : [SurrealDB Built-in Functions](https://surrealdb.com/docs/surrealql/functions/script/built-in-functions)

```sql
-- Fonction avec fetch() : nécessite JavaScript
DEFINE FUNCTION IF NOT EXISTS fn::my_api_call() {
  RETURN function() {
    const response = await fetch('https://api.example.com');
    return response.json();
  };
};

-- Fonction sans fetch() : SurrealQL pur
DEFINE FUNCTION IF NOT EXISTS fn::my_query() {
  LET $data = SELECT * FROM table;
  RETURN $data;
};
```

---

## 📋 Fonctions Disponibles

### 1. `fn::bunny_get_country_list()`

Récupère la liste complète des pays depuis l'API Bunny.net.

**Endpoint** : `GET https://api.bunny.net/country`  
**Auth** : Header `Accesskey` avec API key

#### Utilisation

```sql
-- Récupérer tous les pays
LET $result = fn::bunny_get_country_list();

-- Afficher les pays
RETURN $result.countries;
```

#### Réponse Success (200)

```json
{
  "success": true,
  "countries": [
    {
      "IsoCode": "FR",
      "Name": "France",
      "IsEU": true,
      "ContinentCode": "EU",
      "ContinentName": "Europe",
      "TaxRate": 20.0,
      "TaxPrefix": "VAT",
      "PriceOverride": null,
      "FlagUrl": "https://bunny.net/flags/fr.svg",
      "PopList": ["PAR", "MRS"]
    },
    {
      "IsoCode": "US",
      "Name": "United States",
      "IsEU": false,
      "ContinentCode": "NA",
      "ContinentName": "North America",
      "TaxRate": 0.0,
      "TaxPrefix": null,
      "PriceOverride": null,
      "FlagUrl": "https://bunny.net/flags/us.svg",
      "PopList": ["NY", "LA", "MIA"]
    }
  ],
  "count": 195,
  "fetched_at": "2025-01-24T12:00:00Z"
}
```

#### Réponse Error (400/401/500/503)

```json
{
  "success": false,
  "error": "unauthorized",
  "message": "The request authorization failed - check API key",
  "status_code": 401
}
```

---

### 2. `fn::bunny_sync_countries()`

Synchronise la liste des pays dans la table locale `bunny_country`.

**Utilité** : 
- Cache local pour requêtes rapides
- Pas besoin d'appeler l'API à chaque fois
- Permet des recherches et filtres complexes

#### Utilisation

```sql
-- Synchroniser les pays
LET $result = fn::bunny_sync_countries();

-- Vérifier le résultat
RETURN $result;
```

#### Réponse

```json
{
  "success": true,
  "synced_count": 195,
  "synced_at": "2025-01-24T12:00:00Z"
}
```

#### Après Synchronisation

```sql
-- Lister tous les pays
SELECT * FROM bunny_country;

-- Pays de l'Union Européenne
SELECT * FROM bunny_country WHERE is_eu = true;

-- Pays d'Europe
SELECT * FROM bunny_country WHERE continent_code = 'EU';

-- Pays avec taxe > 15%
SELECT * FROM bunny_country WHERE tax_rate > 15 ORDER BY tax_rate DESC;
```

---

### 3. `fn::bunny_get_country_by_code($iso_code)`

Récupère un pays spécifique par son code ISO (2 lettres).

**Paramètres** :
- `$iso_code` : Code ISO pays (ex: 'FR', 'US', 'DE')

#### Utilisation

```sql
-- Récupérer la France
LET $france = fn::bunny_get_country_by_code('FR');
RETURN $france;

-- Récupérer les États-Unis
LET $usa = fn::bunny_get_country_by_code('US');
RETURN $usa;
```

#### Réponse

```json
{
  "success": true,
  "country": {
    "iso_code": "FR",
    "name": "France",
    "is_eu": true,
    "continent_code": "EU",
    "continent_name": "Europe",
    "tax_rate": 20.0,
    "tax_prefix": "VAT",
    "price_override": null,
    "flag_url": "https://bunny.net/flags/fr.svg",
    "pop_list": ["PAR", "MRS"]
  }
}
```

---

## 🎯 Use Cases

### 1. Afficher la Liste des Pays dans un Formulaire

```sql
-- Frontend récupère la liste pour un <select>
LET $countries = fn::bunny_get_country_list();

RETURN $countries.countries.map(|c| {
  value: c.IsoCode,
  label: c.Name,
  flag: c.FlagUrl
});
```

### 2. Calculer le Prix avec Taxe

```sql
-- Calculer le prix TTC pour un client français
LET $country = fn::bunny_get_country_by_code('FR');
LET $price_ht = 100;
LET $tax_amount = $price_ht * ($country.country.tax_rate / 100);
LET $price_ttc = $price_ht + $tax_amount;

RETURN {
  price_ht: $price_ht,
  tax_rate: $country.country.tax_rate,
  tax_amount: $tax_amount,
  price_ttc: $price_ttc
};
```

### 3. Filtrer les Pays EU pour Réglementation RGPD

```sql
-- Après synchronisation
SELECT * FROM bunny_country 
WHERE is_eu = true 
ORDER BY name;
```

### 4. Grouper les Pays par Continent

```sql
-- Après synchronisation
SELECT 
  continent_name,
  count() AS countries_count,
  math::mean(tax_rate) AS avg_tax_rate
FROM bunny_country
GROUP BY continent_name;
```

---

## 📊 Structure de la Table `bunny_country`

| Champ | Type | Description |
|-------|------|-------------|
| `iso_code` | string | Code ISO (2 lettres, unique) |
| `name` | string | Nom du pays |
| `continent_code` | string | Code continent (EU, NA, AS, etc.) |
| `continent_name` | string | Nom du continent |
| `is_eu` | bool | Membre UE ? |
| `tax_rate` | float | Taux de taxe (%) |
| `tax_prefix` | string | Préfixe taxe (VAT, etc.) |
| `price_override` | float? | Override de prix |
| `flag_url` | string | URL du drapeau |
| `pop_list` | array? | Liste des PoP (Points of Presence) |
| `metadata.synced_at` | datetime | Date de sync |

**Note** : `PopList` contient les codes des Points of Presence (serveurs edge) Bunny disponibles dans ce pays (ex: ["PAR", "MRS"] pour Paris et Marseille).

---

## 🔄 Stratégie de Synchronisation

### Option 1 : Sync Manuelle

```sql
-- Exécuter manuellement quand nécessaire
CALL fn::bunny_sync_countries();
```

### Option 2 : Sync Automatique (Cron)

Créer un worker ou utiliser un scheduler SurrealDB pour synchroniser quotidiennement :

```sql
-- À exécuter 1x par jour
DEFINE EVENT IF NOT EXISTS sync_countries_daily ON DATABASE
WHEN time::hour(time::now()) == 2 -- 2h du matin
THEN {
  fn::bunny_sync_countries();
};
```

### Option 3 : Lazy Loading

```sql
-- Synchroniser si la table est vide
LET $count = (SELECT count() FROM bunny_country GROUP ALL)[0].count;

IF $count == 0 THEN
  fn::bunny_sync_countries();
END;

-- Puis utiliser les données locales
SELECT * FROM bunny_country;
```

---

## 🚀 Démarrage Rapide

### 1. Importer les Schémas

```bash
# Importer la table
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/database/bunny_country.surql

# Importer les fonctions (3 fichiers)
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/resources/bunny/bunny_net_api/country/fn_bunny_get_country_list.surql

surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/resources/bunny/bunny_net_api/country/fn_bunny_sync_countries.surql

surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/resources/bunny/bunny_net_api/country/fn_bunny_get_country_by_code.surql
```

### 2. Synchroniser les Pays

```sql
-- Dans SurrealDB
CALL fn::bunny_sync_countries();
```

### 3. Utiliser

```sql
-- Lister tous les pays
SELECT * FROM bunny_country ORDER BY name;

-- Rechercher un pays
SELECT * FROM bunny_country WHERE iso_code = 'FR';
```

---

## 📖 Documentation Officielle

- **API Bunny.net** : https://docs.bunny.net/reference/countriespublic_getcountrylist
- **Endpoint** : `GET https://api.bunny.net/country`
- **Auth** : Header `Accesskey`
- **SurrealDB Built-in Functions** : https://surrealdb.com/docs/surrealql/functions/script/built-in-functions

---

## ✅ Résumé

| Fonction | Description | Use Case |
|----------|-------------|----------|
| `fn::bunny_get_country_list()` | Fetch API direct | Données en temps réel |
| `fn::bunny_sync_countries()` | Sync table locale | Cache + performance |
| `fn::bunny_get_country_by_code()` | Get 1 pays | Lookup rapide |

**Recommandation** : Synchroniser 1x par jour avec `fn::bunny_sync_countries()` puis utiliser la table locale `bunny_country` pour toutes les requêtes. 🚀
