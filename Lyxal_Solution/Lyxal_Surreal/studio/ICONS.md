# 🎨 Lyxal Studio - Gestion des Icônes (100% CDN)

Guide complet pour gérer les icônes SVG via Bunny CDN dans Lyxal Studio.

---

## 🎯 Vision

**Héberger 100% des icônes sur Bunny CDN** pour une **flexibilité maximale** :
- ✅ Changer de bibliothèque d'icônes sans rebuild
- ✅ Ajouter/modifier des icônes instantanément
- ✅ Mixer plusieurs bibliothèques (Lucide, Heroicons, Tabler, etc.)
- ✅ Créer des icônes custom Lyxal
- ✅ Performance optimale (CDN + Cache)

**Aucune dépendance frontend = Flexibilité totale** ! 🚀

---

## ✨ Avantages de l'Approche 100% CDN

| Aspect | Imports JS | 100% CDN Bunny |
|--------|-----------|----------------|
| **Changement de lib** | ⚠️ Rebuild complet | ✅ Changer URL en DB |
| **Ajout icône** | ⚠️ Rebuild app | ✅ Upload SVG |
| **Mix de libs** | ❌ Conflits | ✅ Illimité |
| **Custom icons** | ⚠️ Complexe | ✅ Simple upload |
| **Bundle size** | ⚠️ Toutes les icônes | ✅ 0 KB (chargement dynamique) |
| **Performance** | ✅ Bon | ✅✅ Excellent (CDN) |
| **Cache** | ✅ App bundle | ✅✅ Browser + Bunny Edge |
| **Maintenance** | ⚠️ npm update | ✅ Aucune |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────┐
│         BUNNY STORAGE (Icons Source)                  │
│  Storage Zone: lyxal-icons                           │
│  Pull Zone: icons.lyxal.b-cdn.net                    │
├──────────────────────────────────────────────────────┤
│  /lucide/           (7800+ icons)                    │
│    ├─ users.svg                                      │
│    ├─ home.svg                                       │
│    └─ ...                                            │
│  /heroicons/        (300+ icons)                     │
│  /tabler/           (5800+ icons)                    │
│  /feather/          (287 icons)                      │
│  /boxicons/         (1600+ icons)                    │
│  /phosphor/         (9000+ icons)                    │
│  /custom/           (Icônes Lyxal)                   │
│    ├─ lyxal-logo.svg                                 │
│    └─ lyxal-*.svg                                    │
│  /brands/           (Logos marques)                  │
│    ├─ google.svg                                     │
│    └─ ...                                            │
└──────────────────────────────────────────────────────┘
                     ↓ URL dans DB
┌──────────────────────────────────────────────────────┐
│         SURREALDB (studio_menu)                       │
│  icon: "https://icons.lyxal.b-cdn.net/lucide/       │
│         users.svg"                                   │
└──────────────────────────────────────────────────────┘
                     ↓ Rendu dynamique
┌──────────────────────────────────────────────────────┐
│         FRONTEND (React / React Native)               │
│  <Icon src={menu.icon} />                            │
└──────────────────────────────────────────────────────┘
```

---

## 📚 Bibliothèques SVG Disponibles sur GitHub

### 1. **Lucide Icons** (Recommandé) ⭐
- **URL** : https://github.com/lucide-icons/lucide
- **Nombre** : 7800+ icônes
- **Style** : Minimaliste, moderne, stroke-based
- **Licence** : MIT
- **Pourquoi** : Consistant, beau, open-source actif

### 2. **Tabler Icons**
- **URL** : https://github.com/tabler/tabler-icons
- **Nombre** : 5800+ icônes
- **Style** : Minimaliste, outline
- **Licence** : MIT

### 3. **Heroicons** (by Tailwind)
- **URL** : https://github.com/tailwindlabs/heroicons
- **Nombre** : 300+ icônes
- **Style** : Moderne, solid + outline
- **Licence** : MIT

### 4. **Phosphor Icons**
- **URL** : https://github.com/phosphor-icons/react
- **Nombre** : 9000+ icônes
- **Style** : Versatile, 6 variants
- **Licence** : MIT

### 5. **Feather Icons**
- **URL** : https://github.com/feathericons/feather
- **Nombre** : 287 icônes
- **Style** : Simple, minimaliste
- **Licence** : MIT

### 6. **Boxicons**
- **URL** : https://github.com/atisawd/boxicons
- **Nombre** : 1600+ icônes
- **Style** : Regular, Solid, Logos
- **Licence** : CC BY 4.0

### 7. **Simple Icons** (Brands)
- **URL** : https://github.com/simple-icons/simple-icons
- **Nombre** : 3000+ logos de marques
- **Style** : Logos officiels
- **Licence** : CC0 1.0

### 8. **Font Awesome** (Free)
- **URL** : https://github.com/FortAwesome/Font-Awesome
- **Nombre** : 2000+ icônes (version free)
- **Style** : Solid, Regular, Brands
- **Licence** : CC BY 4.0 / MIT / OFL

---

## 🛠️ Script d'Upload Automatique

### upload-icons.js - Script Complet

```javascript
// scripts/upload-icons.js
const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');
const { execSync } = require('child_process');

// Configuration Bunny Storage
const BUNNY_STORAGE_ZONE = 'lyxal-icons';
const BUNNY_API_KEY = process.env.BUNNY_STORAGE_API_KEY;
const BUNNY_STORAGE_URL = `https://storage.bunnycdn.com/${BUNNY_STORAGE_ZONE}`;
const BUNNY_CDN_URL = 'https://icons.lyxal.b-cdn.net';

// Bibliothèques d'icônes à uploader
const ICON_LIBRARIES = [
  {
    name: 'lucide',
    repo: 'https://github.com/lucide-icons/lucide',
    path: 'icons',
    description: '7800+ icônes minimalistes',
  },
  {
    name: 'heroicons',
    repo: 'https://github.com/tailwindlabs/heroicons',
    path: 'optimized',
    description: '300+ icônes Tailwind',
  },
  {
    name: 'tabler',
    repo: 'https://github.com/tabler/tabler-icons',
    path: 'icons',
    description: '5800+ icônes outline',
  },
  {
    name: 'feather',
    repo: 'https://github.com/feathericons/feather',
    path: 'icons',
    description: '287 icônes simples',
  },
  {
    name: 'boxicons',
    repo: 'https://github.com/atisawd/boxicons',
    path: 'svg/regular',
    description: '1600+ icônes',
  },
  {
    name: 'phosphor',
    repo: 'https://github.com/phosphor-icons/core',
    path: 'assets/regular',
    description: '9000+ icônes versatiles',
  },
  {
    name: 'simple-icons',
    repo: 'https://github.com/simple-icons/simple-icons',
    path: 'icons',
    description: '3000+ logos de marques',
  },
];

// 1. Cloner les repos
async function cloneRepos() {
  console.log('📦 Clonage des repositories...\n');
  
  for (const lib of ICON_LIBRARIES) {
    const tempDir = `./temp/${lib.name}`;
    
    if (fs.existsSync(tempDir)) {
      console.log(`⏭️  ${lib.name} déjà cloné`);
      continue;
    }
    
    console.log(`📥 Clonage de ${lib.name}...`);
    execSync(`git clone --depth 1 ${lib.repo} ${tempDir}`, { stdio: 'inherit' });
  }
  
  console.log('\n✅ Tous les repos sont clonés\n');
}

// 2. Optimiser les SVG (SVGO)
function optimizeSVG(svgContent) {
  // Nettoyer le SVG
  return svgContent
    // Supprimer les commentaires
    .replace(/<!--[\s\S]*?-->/g, '')
    // Supprimer les attributs inutiles
    .replace(/\s+(xmlns:.*?=".*?")/g, '')
    .replace(/\s+id=".*?"/g, '')
    .replace(/\s+data-.*?=".*?"/g, '')
    // Minifier
    .replace(/\s+/g, ' ')
    .replace(/> </g, '><')
    .trim();
}

// 3. Préparer le SVG pour Lyxal (currentColor)
function prepareSVG(svgContent) {
  // Remplacer les couleurs fixes par currentColor pour DaisyUI
  return svgContent
    .replace(/fill="#[0-9a-fA-F]{6}"/g, 'fill="currentColor"')
    .replace(/stroke="#[0-9a-fA-F]{6}"/g, 'stroke="currentColor"')
    .replace(/fill="black"/g, 'fill="currentColor"')
    .replace(/fill="white"/g, 'fill="currentColor"')
    .replace(/stroke="black"/g, 'stroke="currentColor"')
    // Ajouter des attributs par défaut si absents
    .replace(/<svg/, '<svg fill="currentColor" stroke="currentColor"');
}

// 4. Uploader sur Bunny Storage
async function uploadToBunny(remotePath, content) {
  try {
    const response = await fetch(`${BUNNY_STORAGE_URL}/${remotePath}`, {
      method: 'PUT',
      headers: {
        'AccessKey': BUNNY_API_KEY,
        'Content-Type': 'image/svg+xml',
      },
      body: content,
    });
    
    if (response.ok) {
      return true;
    } else {
      console.error(`❌ Échec: ${remotePath} (${response.status})`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Erreur: ${remotePath}`, error.message);
    return false;
  }
}

// 5. Traiter et uploader une bibliothèque
async function processLibrary(lib) {
  console.log(`\n📤 Upload de ${lib.name} (${lib.description})...`);
  
  const localPath = `./temp/${lib.name}/${lib.path}`;
  
  if (!fs.existsSync(localPath)) {
    console.log(`⚠️  Chemin introuvable: ${localPath}`);
    return;
  }
  
  const files = fs.readdirSync(localPath).filter(f => f.endsWith('.svg'));
  console.log(`   📁 ${files.length} icônes trouvées`);
  
  let uploaded = 0;
  let failed = 0;
  
  for (const file of files) {
    const svgPath = path.join(localPath, file);
    let svgContent = fs.readFileSync(svgPath, 'utf-8');
    
    // Optimiser et préparer le SVG
    svgContent = optimizeSVG(svgContent);
    svgContent = prepareSVG(svgContent);
    
    // Uploader sur Bunny
    const remotePath = `${lib.name}/${file}`;
    const success = await uploadToBunny(remotePath, svgContent);
    
    if (success) {
      uploaded++;
      if (uploaded % 100 === 0) {
        console.log(`   ✅ ${uploaded}/${files.length} uploadées...`);
      }
    } else {
      failed++;
    }
  }
  
  console.log(`\n   ✅ ${lib.name}: ${uploaded} réussies, ${failed} échouées`);
}

// 6. Générer l'index JSON
async function generateIndex() {
  console.log('\n📋 Génération de l\'index...');
  
  const index = {
    version: '1.0.0',
    updated: new Date().toISOString(),
    cdn_url: BUNNY_CDN_URL,
    libraries: [],
  };
  
  for (const lib of ICON_LIBRARIES) {
    const localPath = `./temp/${lib.name}/${lib.path}`;
    
    if (!fs.existsSync(localPath)) continue;
    
    const files = fs.readdirSync(localPath)
      .filter(f => f.endsWith('.svg'))
      .map(f => f.replace('.svg', ''));
    
    index.libraries.push({
      name: lib.name,
      description: lib.description,
      count: files.length,
      base_url: `${BUNNY_CDN_URL}/${lib.name}`,
      icons: files.sort(),
    });
  }
  
  // Uploader l'index
  const indexJSON = JSON.stringify(index, null, 2);
  await uploadToBunny('index.json', indexJSON);
  
  console.log('✅ Index généré et uploadé\n');
}

// 7. Fonction principale
async function main() {
  console.log('🚀 Lyxal Icons Uploader\n');
  console.log('═'.repeat(50) + '\n');
  
  // Vérifier la clé API
  if (!BUNNY_API_KEY) {
    console.error('❌ BUNNY_STORAGE_API_KEY non définie !');
    process.exit(1);
  }
  
  try {
    // Étape 1 : Cloner les repos
    await cloneRepos();
    
    // Étape 2 : Traiter et uploader chaque bibliothèque
    for (const lib of ICON_LIBRARIES) {
      await processLibrary(lib);
    }
    
    // Étape 3 : Générer l'index
    await generateIndex();
    
    console.log('\n' + '═'.repeat(50));
    console.log('✅ Upload terminé avec succès !');
    console.log(`\n📍 CDN URL: ${BUNNY_CDN_URL}`);
    console.log(`📋 Index: ${BUNNY_CDN_URL}/index.json\n`);
    
  } catch (error) {
    console.error('❌ Erreur:', error);
    process.exit(1);
  }
}

// Lancer le script
main();
```

### Utilisation

```bash
# Installer les dépendances
npm install node-fetch

# Définir la clé API Bunny
export BUNNY_STORAGE_API_KEY="votre-cle-api-bunny"

# Lancer l'upload
node scripts/upload-icons.js
```

---

## 🗄️ Structure SurrealDB

### Table studio_menu (avec URL icône)

```surql
-- Définition
DEFINE FIELD icon ON studio_menu
  TYPE string
  COMMENT 'URL complète du SVG (ex: https://icons.lyxal.b-cdn.net/lucide/users.svg)';

-- Exemples
CREATE studio_menu:crm SET
  code = "crm",
  label = { fr: "CRM", en: "CRM" },
  icon = "https://icons.lyxal.b-cdn.net/lucide/users.svg",
  url = "/crm",
  order = 1;

CREATE studio_menu:dashboard SET
  code = "dashboard",
  label = { fr: "Tableau de Bord", en: "Dashboard" },
  icon = "https://icons.lyxal.b-cdn.net/tabler/dashboard.svg",  -- Mix de libs !
  url = "/dashboard",
  order = 0;

CREATE studio_menu:custom SET
  code = "lyxal_module",
  label = { fr: "Module Lyxal", en: "Lyxal Module" },
  icon = "https://icons.lyxal.b-cdn.net/custom/lyxal-logo.svg",  -- Icône custom
  url = "/lyxal",
  order = 10;
```

### Configuration globale des icônes

```surql
-- Ajouter dans studio_config
DEFINE FIELD icon_cdn ON studio_config
  TYPE string
  DEFAULT "https://icons.lyxal.b-cdn.net"
  COMMENT 'URL du CDN d\'icônes';

DEFINE FIELD icon_default ON studio_config
  TYPE string
  DEFAULT "https://icons.lyxal.b-cdn.net/lucide/circle.svg"
  COMMENT 'Icône par défaut si erreur';

-- Exemple
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  icon_cdn = "https://icons.lyxal.b-cdn.net",
  icon_default = "https://icons.lyxal.b-cdn.net/lucide/circle.svg";
```

---

## 🎨 Composants Frontend

### React (Web) - Composant Icon Universel

```typescript
// components/Icon.tsx
import React, { useEffect, useState, useRef } from 'react';

interface IconProps {
  src: string;
  size?: number;
  className?: string;
  color?: string;
  fallback?: string;
}

// Cache global pour les SVG
const svgCache = new Map<string, string>();

export const Icon: React.FC<IconProps> = ({ 
  src, 
  size = 24, 
  className = '', 
  color = 'currentColor',
  fallback = 'https://icons.lyxal.b-cdn.net/lucide/circle.svg'
}) => {
  const [svg, setSvg] = useState<string>('');
  const [error, setError] = useState(false);
  const containerRef = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    // Vérifier le cache
    if (svgCache.has(src)) {
      setSvg(svgCache.get(src)!);
      return;
    }

    // Charger le SVG
    fetch(src)
      .then(res => {
        if (!res.ok) throw new Error('Failed to load icon');
        return res.text();
      })
      .then(svgContent => {
        // Parser le SVG
        const parser = new DOMParser();
        const doc = parser.parseFromString(svgContent, 'image/svg+xml');
        const svgElement = doc.querySelector('svg');
        
        if (svgElement) {
          // Appliquer les attributs
          svgElement.setAttribute('width', size.toString());
          svgElement.setAttribute('height', size.toString());
          svgElement.setAttribute('fill', color);
          svgElement.setAttribute('stroke', color);
          
          const processedSvg = svgElement.outerHTML;
          
          // Mettre en cache
          svgCache.set(src, processedSvg);
          setSvg(processedSvg);
        }
      })
      .catch(err => {
        console.error(`Failed to load icon: ${src}`, err);
        setError(true);
        
        // Charger le fallback
        if (fallback && fallback !== src) {
          fetch(fallback)
            .then(res => res.text())
            .then(setSvg);
        }
      });
  }, [src, size, color, fallback]);

  if (error && !svg) {
    return <span className={`inline-block ${className}`} style={{ width: size, height: size }} />;
  }

  return (
    <span 
      ref={containerRef}
      className={`inline-flex items-center justify-center ${className}`}
      style={{ width: size, height: size }}
      dangerouslySetInnerHTML={{ __html: svg }}
    />
  );
};

// Version avec préchargement (pour menus)
export const IconPreloaded: React.FC<{ icons: string[] }> = ({ icons }) => {
  useEffect(() => {
    icons.forEach(src => {
      if (!svgCache.has(src)) {
        fetch(src)
          .then(res => res.text())
          .then(svg => svgCache.set(src, svg));
      }
    });
  }, [icons]);
  
  return null;
};
```

### Utilisation dans StudioMenu

```typescript
// components/studio/StudioMenu.tsx
import { Icon, IconPreloaded } from '@/components/Icon';

export const StudioMenu: React.FC<{ menu: any[] }> = ({ menu }) => {
  // Précharger toutes les icônes du menu
  const iconUrls = menu.map(item => item.icon);

  return (
    <>
      <IconPreloaded icons={iconUrls} />
      
      <ul className="menu bg-base-200 w-56 rounded-box">
        {menu.map((item) => (
          <li key={item.code}>
            <Link to={item.url} className={item.active ? 'active' : ''}>
              <Icon 
                src={item.icon} 
                size={20}
                className="shrink-0"
              />
              <span>{item.label.fr}</span>
            </Link>
          </li>
        ))}
      </ul>
    </>
  );
};
```

### React Native (Mobile)

```typescript
// components/Icon.native.tsx
import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { SvgXml } from 'react-native-svg';

interface IconProps {
  src: string;
  size?: number;
  color?: string;
}

// Cache global
const svgCache = new Map<string, string>();

export const Icon: React.FC<IconProps> = ({ 
  src, 
  size = 24, 
  color = '#000000' 
}) => {
  const [svg, setSvg] = useState<string>(svgCache.get(src) || '');

  useEffect(() => {
    if (svgCache.has(src)) {
      setSvg(svgCache.get(src)!);
      return;
    }

    fetch(src)
      .then(res => res.text())
      .then(svgContent => {
        // Appliquer la couleur
        const coloredSvg = svgContent
          .replace(/fill="currentColor"/g, `fill="${color}"`)
          .replace(/stroke="currentColor"/g, `stroke="${color}"`)
          .replace(/fill="#[0-9a-fA-F]{6}"/g, `fill="${color}"`)
          .replace(/stroke="#[0-9a-fA-F]{6}"/g, `stroke="${color}"`);
        
        svgCache.set(src, coloredSvg);
        setSvg(coloredSvg);
      })
      .catch(err => console.error('Failed to load icon:', err));
  }, [src, color]);

  if (!svg) {
    return <View style={{ width: size, height: size }} />;
  }

  return <SvgXml xml={svg} width={size} height={size} />;
};
```

---

## 🔄 Changer de Bibliothèque d'Icônes

### Exemple : Passer de Lucide à Tabler

```surql
-- Avant (Lucide)
UPDATE studio_menu SET
  icon = "https://icons.lyxal.b-cdn.net/lucide/users.svg"
WHERE code = "crm";

-- Après (Tabler) - Changer juste l'URL !
UPDATE studio_menu SET
  icon = "https://icons.lyxal.b-cdn.net/tabler/users.svg"
WHERE code = "crm";
```

**Aucun rebuild, aucun changement de code !** ✨

### Migration Globale

```surql
-- Migrer tous les menus de Lucide vers Heroicons
UPDATE studio_menu SET
  icon = string::replace(icon, '/lucide/', '/heroicons/')
WHERE icon CONTAINS '/lucide/';
```

---

## 📊 Index des Icônes (API)

### Endpoint : `/index.json`

```json
{
  "version": "1.0.0",
  "updated": "2025-10-24T10:00:00Z",
  "cdn_url": "https://icons.lyxal.b-cdn.net",
  "libraries": [
    {
      "name": "lucide",
      "description": "7800+ icônes minimalistes",
      "count": 7856,
      "base_url": "https://icons.lyxal.b-cdn.net/lucide",
      "icons": [
        "activity",
        "airplay",
        "alert-circle",
        "...7850 more"
      ]
    },
    {
      "name": "heroicons",
      "description": "300+ icônes Tailwind",
      "count": 292,
      "base_url": "https://icons.lyxal.b-cdn.net/heroicons",
      "icons": ["academic-cap", "adjustments", "..."]
    }
  ]
}
```

### Utiliser l'index dans l'UI

```typescript
// Admin UI - Sélecteur d'icône
const IconPicker = () => {
  const [index, setIndex] = useState<any>(null);
  
  useEffect(() => {
    fetch('https://icons.lyxal.b-cdn.net/index.json')
      .then(res => res.json())
      .then(setIndex);
  }, []);
  
  return (
    <div>
      <h3>Choisir une icône</h3>
      {index?.libraries.map(lib => (
        <div key={lib.name}>
          <h4>{lib.name} ({lib.count} icônes)</h4>
          <div className="grid grid-cols-10 gap-2">
            {lib.icons.slice(0, 50).map(icon => (
              <Icon 
                key={icon}
                src={`${lib.base_url}/${icon}.svg`}
                size={32}
              />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
};
```

---

## 💰 Coûts Bunny Storage

### Estimation pour 20 000 icônes

| Ressource | Quantité | Prix Bunny | Total |
|-----------|----------|------------|-------|
| **Stockage** | 100 MB | 0.01$/GB/mois | 0.001$/mois |
| **Bande passante** | 10 GB/mois | 0.01$/GB | 0.10$/mois |
| **Requêtes** | 100K/mois | Inclus | 0$/mois |
| **Total** | | | **~0.10$/mois** |

**Quasi gratuit !** 💸

---

## 🚀 Déploiement

### Option 1 : Upload Local (Simple)

#### 1. Créer le Storage Zone sur Bunny

```bash
# Via Bunny Dashboard
1. Créer Storage Zone "lyxal-icons"
2. Créer Pull Zone "icons.lyxal.b-cdn.net"
3. Lier Storage → Pull Zone
4. Récupérer l'API Key
```

#### 2. Upload Initial

```bash
# Cloner ce repo
git clone https://github.com/lyxal/icons-setup
cd icons-setup

# Configurer
export BUNNY_STORAGE_API_KEY="votre-cle"

# Upload
npm install
node upload-icons.js
```

---

### Option 2 : Automation avec Bunny Magic Containers ⭐ (Recommandé)

**Déployer le script d'upload comme un service automatisé sur [Bunny Magic Containers](https://bunny.net/blog/introducing-magic-containers-what-edge-computing-was-meant-to-be/)** !

#### Avantages

- ✅ **Automation Complète** : Upload automatique quotidien
- ✅ **CI/CD Intégré** : Push GitHub → Deploy automatique
- ✅ **Monitoring** : Real-time logs et health checks
- ✅ **Coûts Minimaux** : ~$0.03/mois pour runs quotidiens
- ✅ **Global** : Deploy proche de Bunny Storage (latence minimale)

#### 1. Créer le Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copier package.json
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Copier le script
COPY upload-icons.js ./

# Variables d'environnement
ENV NODE_ENV=production

# Lancer le script (puis attendre)
CMD ["node", "upload-icons.js"]
```

#### 2. Créer le Script avec Cron

```javascript
// upload-icons-cron.js
const cron = require('node-cron');
const { uploadIcons } = require('./upload-icons');

console.log('🚀 Lyxal Icons Uploader - Cron Mode');
console.log('📅 Scheduled: Daily at 2:00 AM UTC\n');

// Lancer une fois au démarrage
uploadIcons().then(() => {
  console.log('✅ Initial upload completed\n');
});

// Puis chaque jour à 2h du matin UTC
cron.schedule('0 2 * * *', async () => {
  console.log('⏰ Cron triggered - Starting upload...');
  await uploadIcons();
  console.log('✅ Cron upload completed\n');
});

// Health check endpoint (pour Magic Containers)
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'lyxal-icons-uploader' });
});

app.listen(3000, () => {
  console.log('💚 Health check available on :3000/health');
});
```

#### 3. Mettre à Jour package.json

```json
{
  "name": "lyxal-icons-uploader",
  "version": "1.0.0",
  "scripts": {
    "start": "node upload-icons-cron.js"
  },
  "dependencies": {
    "node-fetch": "^3.3.2",
    "node-cron": "^3.0.3",
    "express": "^4.18.2"
  }
}
```

#### 4. Build et Push l'Image Docker

```bash
# Build l'image
docker build -t lyxal-icons-uploader:latest .

# Tag pour Docker Hub (ou autre registry)
docker tag lyxal-icons-uploader:latest your-dockerhub/lyxal-icons-uploader:latest

# Push
docker push your-dockerhub/lyxal-icons-uploader:latest
```

#### 5. Déployer sur Bunny Magic Containers

**Via Bunny Dashboard** :

1. Aller sur https://panel.bunny.net
2. Menu **Magic Containers**
3. Cliquer **Add Application**
4. Configurer :
   ```yaml
   Name: lyxal-icons-uploader
   Docker Image: your-dockerhub/lyxal-icons-uploader:latest
   Port: 3000 (health check)
   Environment Variables:
     BUNNY_STORAGE_API_KEY: "votre-cle-api"
   ```
5. Sélectionner **Regions** : Choisir la région la plus proche de ton Bunny Storage
6. Cliquer **Deploy**

**Via GitHub Actions** (CI/CD) :

```yaml
# .github/workflows/deploy-icons-uploader.yml
name: Deploy Icons Uploader

on:
  push:
    branches: [main]
    paths:
      - 'scripts/upload-icons/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker Image
        run: |
          cd scripts/upload-icons
          docker build -t lyxal-icons-uploader:${{ github.sha }} .
      
      - name: Push to Docker Hub
        run: |
          echo "${{ secrets.DOCKERHUB_TOKEN }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin
          docker tag lyxal-icons-uploader:${{ github.sha }} your-dockerhub/lyxal-icons-uploader:latest
          docker push your-dockerhub/lyxal-icons-uploader:latest
      
      - name: Deploy to Bunny Magic Containers
        run: |
          curl -X POST "https://api.bunny.net/containers/deploy" \
            -H "AccessKey: ${{ secrets.BUNNY_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{
              "name": "lyxal-icons-uploader",
              "image": "your-dockerhub/lyxal-icons-uploader:latest"
            }'
```

#### 6. Monitoring

**Real-Time Logs** (via Bunny Dashboard) :
- Console logs en temps réel
- Voir les uploads en direct
- Alertes en cas d'erreur

**Health Checks** :
```bash
# Tester le health check
curl https://lyxal-icons-uploader.b-cdn.net/health

# Réponse
{"status":"ok","service":"lyxal-icons-uploader"}
```

#### 7. Coûts Estimés

**Run quotidien (2 minutes)** :
- CPU : ~1 heure/mois = $0.02/mois
- RAM (512 MB) : 1 heure/mois = $0.005/mois
- Storage : 100 MB = $0.01/mois
- **Total : ~$0.035/mois** 💸

**Quasi gratuit pour une automation complète !** 🎉

### 3. Configuration CORS

```json
{
  "AllowedOrigins": ["*"],
  "AllowedMethods": ["GET"],
  "AllowedHeaders": ["*"],
  "MaxAge": 86400
}
```

### 4. Cache Headers

```
Cache-Control: public, max-age=31536000, immutable
Content-Type: image/svg+xml
```

---

## 🎯 Bonnes Pratiques

### 1. Nommer les Icônes

```
✅ Bon : users.svg, home.svg, settings.svg
❌ Mauvais : icon1.svg, temp.svg
```

### 2. Optimiser les SVG

- Utiliser SVGO
- Supprimer les métadonnées
- Minifier le SVG
- Utiliser `currentColor` pour la couleur

### 3. Précharger les Icônes Critiques

```typescript
// Précharger les icônes du menu principal
<IconPreloaded icons={[
  "https://icons.lyxal.b-cdn.net/lucide/home.svg",
  "https://icons.lyxal.b-cdn.net/lucide/users.svg",
  "https://icons.lyxal.b-cdn.net/lucide/settings.svg",
]} />
```

### 4. Fallback Toujours Disponible

```typescript
<Icon 
  src="https://icons.lyxal.b-cdn.net/lucide/custom-icon.svg"
  fallback="https://icons.lyxal.b-cdn.net/lucide/circle.svg"
/>
```

---

## 🔗 Ressources Externes

### Bibliothèques SVG sur GitHub

- [Lucide Icons](https://github.com/lucide-icons/lucide) - 7800+ icônes
- [Tabler Icons](https://github.com/tabler/tabler-icons) - 5800+ icônes
- [Heroicons](https://github.com/tailwindlabs/heroicons) - 300+ icônes
- [Phosphor Icons](https://github.com/phosphor-icons/react) - 9000+ icônes
- [Feather Icons](https://github.com/feathericons/feather) - 287 icônes
- [Boxicons](https://github.com/atisawd/boxicons) - 1600+ icônes
- [Simple Icons](https://github.com/simple-icons/simple-icons) - 3000+ logos
- [Font Awesome Free](https://github.com/FortAwesome/Font-Awesome) - 2000+ icônes

### Bunny.net

- [Bunny Storage](https://bunny.net/storage/) - CDN Storage
- [Bunny Magic Containers](https://bunny.net/blog/introducing-magic-containers-what-edge-computing-was-meant-to-be/) - Edge Computing
- [Bunny CDN](https://bunny.net/) - Global CDN

### Outils

- [SVGO](https://github.com/svg/svgo) - Optimiseur SVG
- [SVGR](https://react-svgr.com/) - SVG vers React
- [Docker](https://www.docker.com/) - Containerization

---

## ✅ Résumé

**Avantages de l'approche 100% CDN Bunny** :

1. ✅ **Flexibilité Maximale** : Changer de lib sans rebuild
2. ✅ **Performance** : CDN Edge + Cache navigateur
3. ✅ **Coûts Minimaux** : ~0.10$/mois pour 20K icônes
4. ✅ **Mix de Libs** : Lucide + Tabler + Custom dans le même projet
5. ✅ **Ajout Instantané** : Upload SVG = Disponible immédiatement
6. ✅ **Multi-Plateforme** : Web + Mobile avec les mêmes URLs
7. ✅ **Maintenance Zero** : Pas de dépendances npm à maintenir
8. ✅ **Automation** : Deploy sur Magic Containers pour ~$0.03/mois

---

## 🚀 Architecture Complète Recommandée

```
┌──────────────────────────────────────────────────────┐
│         GITHUB REPOSITORY (Source)                    │
│  • upload-icons.js                                   │
│  • Dockerfile                                        │
│  • GitHub Actions (CI/CD)                            │
└────────────────┬─────────────────────────────────────┘
                 │ Push → Build → Deploy
                 ↓
┌──────────────────────────────────────────────────────┐
│    BUNNY MAGIC CONTAINERS (Automation)                │
│  • Run quotidien (2 min)                             │
│  • Upload automatique des nouvelles icônes           │
│  • Monitoring et logs                                │
│  • Health checks                                     │
│  Coût : ~$0.03/mois                                  │
└────────────────┬─────────────────────────────────────┘
                 │ Upload SVG
                 ↓
┌──────────────────────────────────────────────────────┐
│         BUNNY STORAGE (Icons Storage)                 │
│  • 20,000+ icônes SVG optimisées                     │
│  • Organisé par bibliothèque                         │
│  • index.json pour l'API                             │
│  Coût : ~$0.10/mois                                  │
└────────────────┬─────────────────────────────────────┘
                 │ Serve via CDN
                 ↓
┌──────────────────────────────────────────────────────┐
│         BUNNY CDN (icons.lyxal.b-cdn.net)            │
│  • 41+ régions globales                              │
│  • Cache agressif                                    │
│  • SSL automatique                                   │
│  • Performance maximale                              │
└────────────────┬─────────────────────────────────────┘
                 │ Icônes accessibles
                 ↓
┌──────────────────────────────────────────────────────┐
│         LYXAL STUDIO (Web + Mobile)                   │
│  • <Icon src="https://icons.lyxal.b-cdn.net/..." /> │
│  • Rendu dynamique                                   │
│  • Cache navigateur                                  │
└──────────────────────────────────────────────────────┘
```

**Coût Total : ~$0.13/mois pour une solution complète automatisée !** 💸✨

---

**Lyxal Studio Icons : Maximum Flexibility, Zero Dependencies, Full Automation** 🎨🚀🤖

