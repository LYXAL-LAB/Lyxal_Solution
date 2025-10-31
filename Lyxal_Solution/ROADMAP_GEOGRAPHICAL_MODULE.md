# Roadmap - Module Geographical (Enrichissement OSM)

## 🎯 Vision
Créer un module `geographical` complet et autonome qui enrichit le module `base` avec toutes les données géographiques d'OpenStreetMap, permettant une autonomie totale sans dépendance à des APIs externes.

---

## 📦 Phase 0 : Préparation (2-3 jours)

### ✅ Tâches

- [ ] **Créer la structure du module geographical**
  ```
  Lyxal_Surreal/geographical/
  ├── database/          # Schémas des tables
  ├── reference/         # Seeds des données
  ├── osm_source/        # Données OSM brutes
  └── scripts/           # Scripts d'extraction et conversion
  ```

- [ ] **Préparer l'espace disque**
  - Minimum 200 GB libre recommandé
  - Structure :
    - OSM Planet : 75 GB
    - Extraits temporaires : 50 GB
    - Données converties : 30 GB
    - Marge : 45 GB

- [ ] **Installer les outils nécessaires**
  ```bash
  # osmium-tool (extraction et conversion)
  pip install osmium
  
  # pyosmium (traitement Python)
  pip install osmium
  
  # shapely (géométries)
  pip install shapely
  
  # optionnel: PostgreSQL + PostGIS (pour requêtes complexes)
  ```

- [ ] **Décider de la stratégie de téléchargement**
  - [ ] Option A : Planet complet (75 GB, données complètes)
  - [ ] Option B : Extraits régionaux (Europe + Amérique + Asie = 28 GB)
  - [ ] Option C : Test avec France (3.5 GB) puis expansion

**Durée estimée : 1 jour**

---

## 📥 Phase 1 : Acquisition des Données OSM (1-2 jours)

### Étape 1.1 : Téléchargement

- [ ] **Télécharger OSM Planet (ou extraits)**
  ```bash
  # Option Planet complet
  wget https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
  
  # OU Option Extraits (recommandé pour commencer)
  wget https://download.geofabrik.de/europe-latest.osm.pbf
  wget https://download.geofabrik.de/north-america-latest.osm.pbf
  wget https://download.geofabrik.de/asia-latest.osm.pbf
  ```

- [ ] **Vérifier l'intégrité des fichiers**
  ```bash
  md5sum planet-latest.osm.pbf
  # Comparer avec le MD5 publié sur le site
  ```

**Durée : 2-6 heures (selon connexion)**

### Étape 1.2 : Extraction initiale

- [ ] **Extraire les boundaries administratives**
  ```bash
  osmium tags-filter planet-latest.osm.pbf \
    w/boundary=administrative \
    r/boundary=administrative \
    -o boundaries.osm.pbf
  ```

- [ ] **Extraire le réseau routier**
  ```bash
  osmium tags-filter planet-latest.osm.pbf \
    w/highway \
    -o roads.osm.pbf
  ```

- [ ] **Extraire les POI**
  ```bash
  osmium tags-filter planet-latest.osm.pbf \
    n/amenity n/shop n/tourism \
    -o poi.osm.pbf
  ```

**Durée : 2-4 heures**

---

## 🗺️ Phase 2 : Boundaries (Priorité 1) (3-5 jours)

### Étape 2.1 : Conversion boundaries en GeoJSON

- [ ] **Convertir OSM → GeoJSON**
  ```bash
  osmium export boundaries.osm.pbf \
    -o boundaries.geojson \
    -f geojson
  ```

- [ ] **Filtrer par admin_level**
  - admin_level 8-10 : Villes/communes
  - admin_level 6-7 : États/provinces
  - admin_level 4 : Pays

**Durée : 1-2 heures**

### Étape 2.2 : Matching avec base existante

- [ ] **Script de matching intelligent**
  ```python
  # Matcher OSM boundaries avec base_city par :
  # 1. Nom + pays (exact)
  # 2. Nom + proximité coordonnées (<5km)
  # 3. Fuzzy matching sur noms alternatifs
  ```

- [ ] **Validation manuelle des ambiguïtés**
  - Cas où plusieurs boundaries matchent
  - Villes homonymes

**Durée : 1 jour**

### Étape 2.3 : Création des schémas

- [ ] **Créer `geo_boundary.surql`**
  ```surql
  DEFINE TABLE geo_boundary SCHEMAFULL;
  
  DEFINE FIELD osm_id ON TABLE geo_boundary TYPE int;
  DEFINE FIELD entity_type ON TABLE geo_boundary TYPE string;
  DEFINE FIELD entity_id ON TABLE geo_boundary TYPE record;
  DEFINE FIELD admin_level ON TABLE geo_boundary TYPE int;
  DEFINE FIELD geometry ON TABLE geo_boundary TYPE geometry<polygon>;
  DEFINE FIELD area_km2 ON TABLE geo_boundary TYPE float;
  DEFINE FIELD source ON TABLE geo_boundary TYPE string DEFAULT "OSM";
  DEFINE FIELD updated_at ON TABLE geo_boundary TYPE datetime;
  ```

**Durée : 4 heures**

### Étape 2.4 : Génération des seeds

- [ ] **Générer seeds pour toutes les boundaries**
  ```surql
  CREATE geo_boundary:city_paris SET
      osm_id = 7444,
      entity_type = "city",
      entity_id = base_city:fr_paris_1,
      admin_level = 8,
      geometry = { type: "MultiPolygon", coordinates: [...] },
      area_km2 = 105.4,
      source = "OSM",
      updated_at = time::now();
  
  RELATE geo_boundary:city_paris->defines->base_city:fr_paris_1;
  ```

**Durée : 1 jour**

### Étape 2.5 : Mise à jour base_city

- [ ] **Option A : Garder séparé (Recommandé)**
  - Boundaries dans `geo_boundary` table séparée
  - Relations vers `base_city`
  - Flexibilité : multiples sources de boundaries

- [ ] **Option B : Intégrer directement**
  - Ajouter `boundary` field dans `base_city`
  - Plus simple mais moins flexible

**Durée : 4 heures**

**Total Phase 2 : 3-5 jours**

---

## 🚗 Phase 3 : Réseau Routier (Priorité 2) (5-7 jours)

### Étape 3.1 : Conversion roads

- [ ] **Convertir en GeoJSON**
  ```bash
  osmium export roads.osm.pbf -o roads.geojson -f geojson
  ```

### Étape 3.2 : Schéma geo_road

- [ ] **Créer table geo_road**
  ```surql
  DEFINE TABLE geo_road SCHEMAFULL;
  
  DEFINE FIELD osm_id ON TABLE geo_road TYPE int;
  DEFINE FIELD name ON TABLE geo_road TYPE option<string>;
  DEFINE FIELD highway_type ON TABLE geo_road TYPE string;
  DEFINE FIELD geometry ON TABLE geo_road TYPE geometry<linestring>;
  DEFINE FIELD max_speed ON TABLE geo_road TYPE option<int>;
  DEFINE FIELD oneway ON TABLE geo_road TYPE bool DEFAULT false;
  DEFINE FIELD surface ON TABLE geo_road TYPE option<string>;
  DEFINE FIELD lanes ON TABLE geo_road TYPE option<int>;
  ```

### Étape 3.3 : Indexation spatiale

- [ ] **Créer index géographique pour recherche rapide**
  ```surql
  DEFINE INDEX road_geo_idx ON TABLE geo_road FIELDS geometry SEARCH;
  ```

### Étape 3.4 : Relations road ↔ city

- [ ] **Relier routes aux villes traversées**
  ```surql
  RELATE geo_road:a1->crosses->base_city:fr_paris_1;
  ```

**Total Phase 3 : 5-7 jours**

---

## 📍 Phase 4 : Points d'Intérêt (Priorité 3) (3-5 jours)

### Étape 4.1 : Classification des POI

- [ ] **Définir taxonomie**
  - Restaurants (cuisine types)
  - Hôtels (étoiles)
  - Stations-service (carburants)
  - Santé (hôpitaux, pharmacies)
  - Éducation (écoles, universités)
  - Shopping (types de magasins)
  - Loisirs (cinémas, musées)

### Étape 4.2 : Schéma geo_poi

- [ ] **Créer table geo_poi**
  ```surql
  DEFINE TABLE geo_poi SCHEMAFULL;
  
  DEFINE FIELD osm_id ON TABLE geo_poi TYPE int;
  DEFINE FIELD name ON TABLE geo_poi TYPE string;
  DEFINE FIELD category ON TABLE geo_poi TYPE string;
  DEFINE FIELD subcategory ON TABLE geo_poi TYPE option<string>;
  DEFINE FIELD location ON TABLE geo_poi TYPE point;
  DEFINE FIELD address ON TABLE geo_poi TYPE option<object>;
  DEFINE FIELD phone ON TABLE geo_poi TYPE option<string>;
  DEFINE FIELD website ON TABLE geo_poi TYPE option<string>;
  DEFINE FIELD opening_hours ON TABLE geo_poi TYPE option<string>;
  DEFINE FIELD rating ON TABLE geo_poi TYPE option<float>;
  ```

### Étape 4.3 : Extraction et conversion

- [ ] **Convertir POI avec catégorisation**

### Étape 4.4 : Relations POI ↔ city

- [ ] **Relier POI aux villes**
  ```surql
  RELATE geo_poi:restaurant_123->located_in->base_city:fr_paris_1;
  ```

**Total Phase 4 : 3-5 jours**

---

## 🏢 Phase 5 : Bâtiments (Priorité 4) (2-3 jours)

### Étape 5.1 : Schéma geo_building

- [ ] **Créer table geo_building**
  ```surql
  DEFINE TABLE geo_building SCHEMAFULL;
  
  DEFINE FIELD osm_id ON TABLE geo_building TYPE int;
  DEFINE FIELD building_type ON TABLE geo_building TYPE string;
  DEFINE FIELD geometry ON TABLE geo_building TYPE geometry<polygon>;
  DEFINE FIELD height ON TABLE geo_building TYPE option<float>;
  DEFINE FIELD levels ON TABLE geo_building TYPE option<int>;
  DEFINE FIELD address ON TABLE geo_building TYPE option<object>;
  ```

### Étape 5.2 : Filtrage intelligent

- [ ] **Ne pas tout importer (800M bâtiments!)**
  - Focus : Bâtiments importants (monuments, gratte-ciels)
  - Ou : Par ville importante uniquement
  - Ou : Sur demande/région

**Total Phase 5 : 2-3 jours**

---

## 🚇 Phase 6 : Transports Publics (Priorité 5) (3-4 jours)

### Étape 6.1 : Schémas transport

- [ ] **geo_transport_line** (lignes de bus/métro)
- [ ] **geo_transport_stop** (arrêts)
- [ ] **geo_transport_route** (itinéraires)

**Total Phase 6 : 3-4 jours**

---

## 🔄 Phase 7 : Maintenance et Mise à Jour (Ongoing)

### Stratégie de mise à jour

- [ ] **Définir fréquence de mise à jour**
  - OSM Planet : Nouvelles versions chaque semaine
  - Option : Mise à jour mensuelle ou trimestrielle

- [ ] **Script de mise à jour différentielle**
  - Télécharger changeset OSM
  - Appliquer uniquement les modifications
  - Éviter de tout retélécharger

- [ ] **Monitoring qualité des données**
  - Vérifier cohérence boundaries
  - Détecter données obsolètes

---

## 📊 Estimation Globale

| Phase | Durée | Priorité |
|-------|-------|----------|
| 0. Préparation | 1 jour | Critique |
| 1. Acquisition OSM | 1-2 jours | Critique |
| 2. Boundaries | 3-5 jours | Haute |
| 3. Réseau routier | 5-7 jours | Haute |
| 4. POI | 3-5 jours | Moyenne |
| 5. Bâtiments | 2-3 jours | Basse |
| 6. Transports | 3-4 jours | Moyenne |
| **TOTAL** | **18-27 jours** | |

---

## 🎯 Jalons (Milestones)

### Milestone 1 : Boundaries complètes ✅
- Module `geographical` créé
- Boundaries pour toutes les villes
- Relations avec `base` fonctionnelles

### Milestone 2 : Navigation GPS possible ✅
- Réseau routier complet
- Algorithme de routing implémenté
- API de navigation fonctionnelle

### Milestone 3 : Système complet ✅
- POI intégrés
- Bâtiments importants
- Transports publics
- **AUTONOMIE TOTALE ATTEINTE** 🎉

---

## 🚀 Recommandation pour Commencer

**Approche Progressive :**

1. **Semaine 1 : Test France** 🇫🇷
   - Télécharger `france-latest.osm.pbf` (3.5 GB)
   - Implémenter toute la chaîne sur la France
   - Valider le workflow

2. **Semaine 2-3 : Expansion Europe**
   - Appliquer à toute l'Europe
   - ~10,000 villes françaises avec boundaries

3. **Semaine 4+ : Mondial**
   - Télécharger Planet complet
   - Appliquer à toutes les 150,874 villes

---

**Voulez-vous que je commence par la Phase 0 (création de la structure du module geographical) ?** 🚀

