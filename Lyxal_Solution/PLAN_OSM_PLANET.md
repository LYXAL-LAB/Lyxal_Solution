# Plan d'Extraction OSM Planet pour Autonomie Totale

## 🎯 Objectif
Extraire TOUTES les données géographiques d'OpenStreetMap pour ne dépendre d'aucune API externe.

## 📥 Étape 1 : Téléchargement

### Option A : Fichier complet (Recommandé)
```bash
# Télécharger le dernier snapshot (~75 GB)
wget https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf

# Ou via torrent (plus rapide et moins de charge serveur)
# https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf.torrent
```

### Option B : Extraits régionaux (Plus rapide pour commencer)
```bash
# Extraits par continent/pays disponibles sur:
# https://download.geofabrik.de/

# Exemple: Europe
wget https://download.geofabrik.de/europe-latest.osm.pbf

# Exemple: Amérique du Nord
wget https://download.geofabrik.de/north-america-latest.osm.pbf
```

## 🔧 Étape 2 : Outils d'Extraction

### Outil 1 : osmium (Recommandé)
```bash
# Installation
pip install osmium

# Extraire les boundaries administratives
osmium tags-filter planet-latest.osm.pbf \
  w/boundary=administrative \
  r/boundary=administrative \
  -o boundaries.osm.pbf

# Convertir en GeoJSON
osmium export boundaries.osm.pbf \
  -o boundaries.geojson \
  -f geojson
```

### Outil 2 : osm2pgsql (Pour base PostgreSQL/PostGIS)
```bash
# Importer dans PostgreSQL avec PostGIS
osm2pgsql -d osm_database planet-latest.osm.pbf

# Puis extraire via SQL
psql -d osm_database -c "SELECT * FROM planet_osm_polygon WHERE boundary='administrative'"
```

### Outil 3 : osmosis (Flexible)
```bash
# Filtrer par tags
osmosis --read-pbf planet-latest.osm.pbf \
  --tf accept-relations boundary=administrative \
  --tf accept-ways boundary=administrative \
  --write-pbf boundaries.osm.pbf
```

## 📊 Étape 3 : Extraction des Données Spécifiques

### A. Boundaries de villes (admin_level 8-10)
```python
# Script Python avec osmium
import osmium

class BoundaryHandler(osmium.SimpleHandler):
    def __init__(self):
        super().__init__()
        self.cities = []
    
    def relation(self, r):
        if 'boundary' in r.tags and r.tags['boundary'] == 'administrative':
            admin_level = r.tags.get('admin_level', '')
            if admin_level in ['8', '9', '10']:
                self.cities.append({
                    'id': r.id,
                    'name': r.tags.get('name', ''),
                    'admin_level': admin_level,
                    'country': r.tags.get('is_in:country_code', ''),
                })

handler = BoundaryHandler()
handler.apply_file('boundaries.osm.pbf')
```

### B. Réseau routier complet
```python
# Extraire routes pour GPS
osmium tags-filter planet-latest.osm.pbf \
  w/highway \
  -o roads.osm.pbf
```

### C. Points d'intérêt (POI)
```python
# Restaurants, hôtels, etc.
osmium tags-filter planet-latest.osm.pbf \
  n/amenity \
  n/shop \
  n/tourism \
  -o poi.osm.pbf
```

## 🎯 Étape 4 : Intégration dans SurrealDB

### Script de conversion OSM → SurrealDB
```python
# 1. Lire GeoJSON des boundaries
# 2. Matcher avec nos villes par nom + coordonnées
# 3. Générer UPDATE statements SurrealDB
# 4. Injecter dans base_city_seeds.surql
```

## 💾 Estimation des Ressources

### Téléchargement initial
- Fichier Planet: **~75 GB**
- Temps: **2-6 heures** (selon connexion)

### Extraction boundaries
- Fichier filtré: **~5-10 GB**
- Temps: **30-60 minutes**

### Conversion GeoJSON
- Taille finale: **~15-20 GB**
- Temps: **1-2 heures**

### Matching avec nos villes
- Temps: **2-4 heures**
- Résultat: **Boundaries pour ~80-90% de nos villes**

## ⚡ Alternative Rapide : Extraits Geofabrik

Si 75 GB est trop lourd, commencer par régions:

```bash
# Europe (7 GB)
wget https://download.geofabrik.de/europe-latest.osm.pbf

# Amérique du Nord (11 GB)
wget https://download.geofabrik.de/north-america-latest.osm.pbf

# Asie (10 GB)
wget https://download.geofabrik.de/asia-latest.osm.pbf

# Total: ~28 GB au lieu de 75 GB
# Couvre la majorité de vos 150k villes
```

## 🚀 Données Bonus OSM

En plus des boundaries, vous aurez accès à:

1. **Réseau routier complet**
   - Pour navigation GPS turn-by-turn
   - Vitesses, restrictions, sens uniques

2. **Points d'intérêt**
   - Restaurants: ~2M
   - Hôtels: ~500k
   - Stations-service: ~300k

3. **Bâtiments**
   - ~800M de bâtiments dans le monde
   - Avec formes exactes

4. **Transports publics**
   - Lignes de bus, métro, train
   - Horaires (selon disponibilité)

## 📝 Licence et Usage

**Licence ODbL (Open Database License)**
- ✅ Usage commercial autorisé
- ✅ Modification autorisée
- ✅ Redistribution autorisée
- ⚠️ Attribution requise: "© OpenStreetMap contributors"
- ⚠️ Share-alike: Si vous distribuez des modifications, même licence

## 🎯 Prochaines Étapes

1. **Décider de l'approche:**
   - [ ] Planet complet (75 GB, données complètes)
   - [ ] Extraits régionaux (28 GB, 80-90% couverture)
   - [ ] Test avec un pays (France: 3.5 GB)

2. **Préparer l'environnement:**
   - [ ] Espace disque: 200 GB minimum recommandé
   - [ ] Installer osmium-tool
   - [ ] Tester sur petit extrait

3. **Lancer l'extraction:**
   - [ ] Télécharger les données
   - [ ] Extraire boundaries
   - [ ] Matcher avec nos villes
   - [ ] Mettre à jour les seeds

---

**Question: Voulez-vous que je crée les scripts pour commencer avec un extrait régional (ex: Europe) pour tester le processus ?**

