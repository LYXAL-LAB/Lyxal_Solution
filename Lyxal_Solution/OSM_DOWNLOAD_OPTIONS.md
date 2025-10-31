# Options de Téléchargement OSM

## 🎯 Trois Options Disponibles

### Option 1 : Planet Complet (Recommandé pour production)
```bash
python download_osm_planet_full.py
```
- **Taille**: 75 GB
- **Durée**: 3-6 heures
- **Couverture**: Monde entier
- **Avantage**: Données complètes pour toutes les 150,874 villes

### Option 2 : Extraits Régionaux (Recommandé pour démarrer)
```bash
python download_osm_regions.py
```
- **Europe**: 7 GB
- **Amérique du Nord**: 11 GB
- **Asie**: 10 GB
- **Total**: ~28 GB
- **Durée**: 1-2 heures
- **Couverture**: ~80-90% de vos villes

### Option 3 : Test France (Recommandé pour validation)
```bash
python download_osm_france.py
```
- **Taille**: 3.5 GB
- **Durée**: 10-20 minutes
- **Couverture**: ~10,000 villes françaises
- **Avantage**: Valider le workflow complet rapidement

## 💾 Espace Disque Requis

| Option | Téléchargement | Après extraction | Total recommandé |
|--------|----------------|------------------|------------------|
| Planet | 75 GB | 50 GB | 200 GB |
| Régions | 28 GB | 30 GB | 80 GB |
| France | 3.5 GB | 5 GB | 15 GB |

## 🚀 Recommandation

**Stratégie Progressive:**

1. **Aujourd'hui**: Télécharger France (3.5 GB, 15 min)
   - Valider le workflow complet
   - Tester l'extraction des boundaries
   - Vérifier l'intégration avec votre base

2. **Cette semaine**: Télécharger Régions (28 GB, 1-2h)
   - Couvrir 80-90% de vos villes
   - Production rapide

3. **Plus tard**: Planet complet (75 GB, 3-6h)
   - Couverture 100%
   - Quand le workflow est validé

## 📊 État Actuel

Vérifier l'espace disque disponible:
```bash
python check_disk_space.py
```

