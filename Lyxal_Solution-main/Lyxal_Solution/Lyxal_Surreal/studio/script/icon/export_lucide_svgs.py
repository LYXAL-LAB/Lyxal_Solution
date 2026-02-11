#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour exporter tous les SVG Lucide dans un dossier pour Bunny CDN
"""

import shutil
from pathlib import Path

# Chemins
LUCIDE_ICONS_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\icons")
OUTPUT_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\studio\assets\bunny_upload\lucide")

def export_svgs():
    """Exporter tous les SVG Lucide"""
    print("📦 Export des SVG Lucide pour Bunny CDN...")
    print()
    
    # Créer le dossier de sortie
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Scanner tous les fichiers SVG
    svg_files = sorted(LUCIDE_ICONS_DIR.glob('*.svg'))
    total = len(svg_files)
    
    print(f"🔍 Trouvé {total} fichiers SVG à copier")
    print(f"📂 Dossier de sortie : {OUTPUT_DIR}")
    print()
    
    exported = 0
    errors = 0
    
    for idx, svg_file in enumerate(svg_files, 1):
        try:
            # Copier le fichier SVG
            destination = OUTPUT_DIR / svg_file.name
            shutil.copy2(svg_file, destination)
            
            exported += 1
            
            if idx % 100 == 0:
                print(f"   Progression: {idx}/{total} SVG copiés...")
                
        except Exception as e:
            errors += 1
            print(f"❌ Erreur : {svg_file.name} - {e}")
    
    print()
    print("=" * 80)
    print("📊 RÉSULTATS")
    print("=" * 80)
    print(f"✅ {exported} SVG exportés avec succès")
    print(f"❌ {errors} erreurs")
    print(f"📂 Dossier : {OUTPUT_DIR}")
    print()
    
    # Calculer la taille totale
    total_size = sum(f.stat().st_size for f in OUTPUT_DIR.glob('*.svg'))
    print(f"💾 Taille totale : {total_size / (1024 * 1024):.2f} MB")
    print()
    
    # Créer un fichier README pour Bunny
    create_bunny_readme()
    
    print("✅ Export terminé !")
    print()
    print("🚀 PROCHAINES ÉTAPES :")
    print("   1. Compresser le dossier en ZIP")
    print("   2. Uploader sur Bunny CDN")
    print("   3. Configurer l'URL de base : https://icons.lyxal.b-cdn.net/lucide/")
    print()

def create_bunny_readme():
    """Créer un README pour l'upload Bunny"""
    readme_content = """# Lucide Icons - SVG pour Bunny CDN

## 📦 Contenu

Ce dossier contient tous les fichiers SVG de Lucide Icons (v0.344.0).

- **Format** : SVG
- **Nombre de fichiers** : 1640
- **ViewBox** : 0 0 24 24
- **Stroke** : currentColor
- **Stroke-width** : 2

## 🚀 Upload sur Bunny CDN

### 1. Créer une Pull Zone

1. Aller sur https://panel.bunny.net
2. Créer une nouvelle Pull Zone : `lyxal-icons`
3. Créer un Storage Zone lié

### 2. Uploader les fichiers

**Option A : Via l'interface web**
1. Créer un dossier `lucide` dans le Storage Zone
2. Uploader tous les SVG dans ce dossier

**Option B : Via FTP**
```bash
# Configuration FTP
Host: storage.bunnycdn.com
Port: 21
Username: lyxal-icons
Password: [API Key]
```

### 3. Configuration

**URL de base** : `https://icons.lyxal.b-cdn.net/lucide/`

**Exemples d'URLs** :
- `https://icons.lyxal.b-cdn.net/lucide/user.svg`
- `https://icons.lyxal.b-cdn.net/lucide/home.svg`
- `https://icons.lyxal.b-cdn.net/lucide/search.svg`

### 4. Optimisation (optionnel)

**Cache Headers** :
- Cache-Control: public, max-age=31536000
- Content-Type: image/svg+xml

**CORS** :
```
Access-Control-Allow-Origin: *
```

## 📋 Structure des fichiers

Tous les fichiers SVG suivent la structure :

```xml
<svg xmlns="http://www.w3.org/2000/svg" 
     viewBox="0 0 24 24" 
     fill="none" 
     stroke="currentColor" 
     stroke-width="2" 
     stroke-linecap="round" 
     stroke-linejoin="round">
  <!-- Contenu SVG -->
</svg>
```

## 🔗 Intégration avec Lyxal

Après l'upload, créer les records `url` dans SurrealDB :

```surql
CREATE url:lucide_user_svg CONTENT {
  identity: { value: 'lucide_user_svg', slug: 'lucide-user-svg' },
  url: { 
    href: 'https://icons.lyxal.b-cdn.net/lucide/user.svg',
    is_external: true
  },
  context: {
    module: builder_catalogue:studio,
    usage_type: 'asset',
    tags: ['icon', 'svg', 'lucide']
  },
  extensions: {
    asset: {
      mime_type: 'image/svg+xml',
      size_bytes: 512
    }
  }
};
```

---

✅ **Prêt pour l'upload sur Bunny CDN !**
"""
    
    readme_file = OUTPUT_DIR / "README_BUNNY_UPLOAD.md"
    with open(readme_file, 'w', encoding='utf-8') as f:
        f.write(readme_content)
    
    print(f"📝 Créé : {readme_file.name}")

def main():
    """Fonction principale"""
    export_svgs()

if __name__ == '__main__':
    main()

