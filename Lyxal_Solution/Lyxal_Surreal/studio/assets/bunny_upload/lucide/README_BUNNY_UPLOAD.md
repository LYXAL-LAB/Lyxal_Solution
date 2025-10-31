# Lucide Icons - SVG pour Bunny CDN

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
