# Script d'Upload SVG vers Bunny Storage

Ce script permet de télécharger des fichiers SVG depuis des URLs et de les uploader automatiquement vers votre stockage Bunny.

## Prérequis

1. **Installer les dépendances Python :**
   ```bash
   pip install -r requirements_svg_uploader.txt
   ```

2. **Configuration Bunny Storage :**
   - Votre clé API est déjà configurée dans le script
   - Vous devez configurer :
     - Le nom de votre Storage Zone
     - L'endpoint de votre région (si différent de `storage.bunnycdn.com`)

## Configuration

✅ **Le script est déjà configuré** avec vos paramètres Bunny Storage :
- **Storage Zone** : `lyxalsolution`
- **Endpoint** : `storage.bunnycdn.com` (Région Allemagne)
- **API Key** : Configurée automatiquement

### Configuration personnalisée (optionnel)

Si vous voulez utiliser une autre configuration, vous pouvez :
1. Modifier les variables dans le script
2. Ou utiliser les paramètres en ligne de commande :
```bash
python upload_svgs_to_bunny.py urls.txt --storage-zone autre-zone --endpoint la.storage.bunnycdn.com
```

### 2. Créer un fichier d'URLs

Créez un fichier `urls.txt` avec une URL par ligne :

```
https://example.com/icon1.svg
https://example.com/icon2.svg
https://cdn.example.com/logo.svg
```

Les lignes commençant par `#` sont ignorées.

## 🚀 Premiers pas

### Pour les fichiers JSON avec logos locaux :

1. **Téléchargez d'abord les SVGs localement** (si vous utilisez un repo comme SVG Logos Collection) :
   ```bash
   # Depuis le répertoire du repository GitHub
   php bin/mirror_worldvectorlogo.php
   ```

2. **Testez le script** :
   ```bash
   python upload_svgs_to_bunny.py --dry-run svgs.json
   ```

3. **Lancez l'upload réel** :
   ```bash
   python upload_svgs_to_bunny.py svgs.json
   ```

### Pour les fichiers texte simples :

1. **Testez le script** :
   ```bash
   python upload_svgs_to_bunny.py --dry-run urls.txt
   ```

2. **Lancez l'upload réel** :
   ```bash
   python upload_svgs_to_bunny.py urls.txt
   ```

3. **Vérifiez les logs** dans `upload_svgs.log`

## Utilisation

### Commande de base :
```bash
python upload_svgs_to_bunny.py urls.txt
```

### Avec paramètres personnalisés :
```bash
python upload_svgs_to_bunny.py urls.txt --storage-zone ma-zone-svg --endpoint la.storage.bunnycdn.com
```

### Mode test (recommandé avant le premier usage) :
```bash
python upload_svgs_to_bunny.py --dry-run urls.txt
```

## Fonctionnalités

- ✅ **Support multi-sources** : fichiers locaux (svg/*.svg) OU URLs distantes
- ✅ **Priorité locale** : utilise les fichiers locaux si disponibles, sinon télécharge depuis les URLs
- ✅ Téléchargement automatique des SVGs depuis les URLs
- ✅ Vérification du type de contenu (SVG)
- ✅ Upload vers Bunny Storage avec la structure `assets/logos/nom.svg`
- ✅ Gestion des erreurs et logging détaillé
- ✅ Nommage automatique des fichiers (préserve le nom original ou génère un hash)
- ✅ Mode test (`--dry-run`) pour simulation sans upload
- ✅ Logs dans `upload_svgs.log`

## Logs

Le script génère un fichier `upload_svgs.log` avec :
- Le statut de chaque téléchargement/upload
- Les erreurs rencontrées
- Un résumé final

## Exemple de sortie

```
2025-11-06 10:30:00 - INFO - Démarrage du processus d'upload des SVGs
2025-11-06 10:30:01 - INFO - Traitement de l'URL: https://example.com/icon.svg
2025-11-06 10:30:02 - INFO - Fichier icon.svg uploadé avec succès
2025-11-06 10:30:05 - INFO - Traitement terminé: 5 succès, 0 erreurs
```

## Dépannage

### Erreur "Storage zone not configured"
- Modifiez la variable `BUNNY_STORAGE_ZONE` dans le script

### Erreur d'authentification
- Vérifiez que votre clé API est correcte
- Vérifiez que votre storage zone existe

### Erreur de réseau
- Vérifiez votre connexion internet
- Les timeouts sont configurés à 30 secondes par défaut

## Support des régions Bunny

Endpoints disponibles selon votre région :
- `storage.bunnycdn.com` (Global)
- `la.storage.bunnycdn.com` (Los Angeles)
- `ny.storage.bunnycdn.com` (New York)
- `de.storage.bunnycdn.com` (Germany)
- `sg.storage.bunnycdn.com` (Singapore)
