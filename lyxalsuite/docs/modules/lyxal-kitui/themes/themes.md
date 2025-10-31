# 🎨 Système de thèmes DaisyUI 5

LyxalKitUI utilise maintenant **DaisyUI 5** avec ses **35 thèmes natifs** pour offrir une expérience de personnalisation optimale et performante.

## 🌈 Migration vers DaisyUI 5

### Pourquoi DaisyUI ?
- **Performance native** : CSS pur, pas de JavaScript pour les thèmes
- **35 thèmes prêts** : Plus besoin de créer/maintenir des thèmes personnalisés
- **Compatibilité Tailwind v4** : Dernière version du framework
- **Simplicité d'usage** : Changement de thème en une ligne
- **Maintenance zéro** : Thèmes maintenus par l'équipe DaisyUI

## 🎯 35 Thèmes disponibles

### Thèmes clairs
| Thème | Style | Description |
|-------|-------|-------------|
| `light` | 🌕 Défaut | Thème clair classique et épuré |
| `cupcake` | 🧁 Pastel | Couleurs douces et féminines |
| `bumblebee` | 🐝 Vibrant | Jaune et noir énergique |
| `emerald` | 💚 Nature | Vert émeraude sophistiqué |
| `corporate` | 🏢 Business | Professionnel et moderne |
| `retro` | 📺 Vintage | Style rétro années 70-80 |
| `valentine` | 💕 Romance | Rose tendre romantique |
| `garden` | 🌿 Naturel | Verts naturels apaisants |
| `aqua` | 🌊 Frais | Bleus aquatiques rafraîchissants |
| `lofi` | 🎵 Doux | Tons neutres relaxants |
| `pastel` | 🎨 Tendre | Couleurs pastel harmonieuses |
| `fantasy` | 🦄 Magique | Violets et roses fantastiques |
| `wireframe` | 📐 Minimal | Noir et blanc épuré |
| `luxury` | ✨ Premium | Or et couleurs riches |
| `cmyk` | 🖨️ Print | Couleurs d'impression vives |
| `autumn` | 🍂 Saison | Oranges et rouges d'automne |
| `business` | 💼 Entreprise | Bleu corporate classique |
| `acid` | ⚡ Électrique | Couleurs néon acidulées |
| `lemonade` | 🍋 Citron | Jaune citron pétillant |
| `coffee` | ☕ Café | Bruns chaleureux |
| `winter` | ❄️ Hiver | Bleus glacés |
| `nord` | 🏔️ Nordique | Palette nordique apaisante |

### Thèmes sombres
| Thème | Style | Description |
|-------|-------|-------------|
| `dark` | 🌑 Défaut | Thème sombre classique |
| `synthwave` | 🌆 Rétro | Néons années 80 futuristes |
| `halloween` | 🎃 Saison | Orange et violet mystérieux |
| `forest` | 🌲 Nature | Verts sombres naturels |
| `black` | ⚫ Minimal | Noir pur minimaliste |
| `dracula` | 🧛 Gothique | Violet sombre élégant |
| `night` | 🌙 Nuit | Bleu nuit professionnel |
| `dim` | 🔅 Tamisé | Gris doux pour les yeux |
| `sunset` | 🌅 Crépuscule | Oranges et roses couchant |
| `cyberpunk` | 🤖 Futur | Néons cyberpunk |

## 🚀 Utilisation simple

### Changer de thème instantanément
```html
<!-- Via attribut HTML -->
<html data-theme="dracula">
```

```tsx
// Via JavaScript
document.documentElement.setAttribute('data-theme', 'cyberpunk');
```

```tsx
// Avec React et state
function ThemeToggle() {
  const [theme, setTheme] = useState('light');
  
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  return (
    <select 
      className="select select-bordered w-full max-w-xs"
      value={theme}
      onChange={(e) => setTheme(e.target.value)}
    >
      <option value="light">Light</option>
      <option value="dark">Dark</option>
      <option value="cyberpunk">Cyberpunk</option>
      <option value="dracula">Dracula</option>
      {/* ... tous les autres thèmes */}
    </select>
  );
}
```

### Configuration dans globals.css
```css
/* src/theme/globals.css */
@import "tailwindcss";
@plugin "daisyui";

/* Configuration DaisyUI 5 avec tous les thèmes */
:root {
  --animation-btn: 0.25s;
  --animation-input: 0.2s;
  --btn-focus-scale: 0.95;
  --border-btn: 1px;
  --tab-border: 1px;
  --tab-radius: 0.5rem;
}
```

## 🎨 Sélecteur de thème avancé

### Composant ThemeSelector complet
```tsx
import { useState, useEffect } from 'react';

const DAISYUI_THEMES = [
  // Thèmes clairs
  { name: 'light', type: 'light', emoji: '🌕', category: 'Défaut' },
  { name: 'cupcake', type: 'light', emoji: '🧁', category: 'Pastel' },
  { name: 'bumblebee', type: 'light', emoji: '🐝', category: 'Vibrant' },
  { name: 'emerald', type: 'light', emoji: '💚', category: 'Nature' },
  { name: 'corporate', type: 'light', emoji: '🏢', category: 'Business' },
  { name: 'retro', type: 'light', emoji: '📺', category: 'Vintage' },
  { name: 'valentine', type: 'light', emoji: '💕', category: 'Romance' },
  { name: 'garden', type: 'light', emoji: '🌿', category: 'Naturel' },
  { name: 'aqua', type: 'light', emoji: '🌊', category: 'Frais' },
  { name: 'lofi', type: 'light', emoji: '🎵', category: 'Doux' },
  { name: 'pastel', type: 'light', emoji: '🎨', category: 'Tendre' },
  { name: 'fantasy', type: 'light', emoji: '🦄', category: 'Magique' },
  { name: 'wireframe', type: 'light', emoji: '📐', category: 'Minimal' },
  { name: 'luxury', type: 'light', emoji: '✨', category: 'Premium' },
  { name: 'cmyk', type: 'light', emoji: '🖨️', category: 'Print' },
  { name: 'autumn', type: 'light', emoji: '🍂', category: 'Saison' },
  { name: 'business', type: 'light', emoji: '💼', category: 'Entreprise' },
  { name: 'acid', type: 'light', emoji: '⚡', category: 'Électrique' },
  { name: 'lemonade', type: 'light', emoji: '🍋', category: 'Citron' },
  { name: 'coffee', type: 'light', emoji: '☕', category: 'Café' },
  { name: 'winter', type: 'light', emoji: '❄️', category: 'Hiver' },
  { name: 'nord', type: 'light', emoji: '🏔️', category: 'Nordique' },
  
  // Thèmes sombres
  { name: 'dark', type: 'dark', emoji: '🌑', category: 'Défaut' },
  { name: 'synthwave', type: 'dark', emoji: '🌆', category: 'Rétro' },
  { name: 'halloween', type: 'dark', emoji: '🎃', category: 'Saison' },
  { name: 'forest', type: 'dark', emoji: '🌲', category: 'Nature' },
  { name: 'black', type: 'dark', emoji: '⚫', category: 'Minimal' },
  { name: 'dracula', type: 'dark', emoji: '🧛', category: 'Gothique' },
  { name: 'night', type: 'dark', emoji: '🌙', category: 'Nuit' },
  { name: 'dim', type: 'dark', emoji: '🔅', category: 'Tamisé' },
  { name: 'sunset', type: 'dark', emoji: '🌅', category: 'Crépuscule' },
  { name: 'cyberpunk', type: 'dark', emoji: '🤖', category: 'Futur' }
];

function ThemeSelector() {
  const [currentTheme, setCurrentTheme] = useState('light');
  const [filterType, setFilterType] = useState('all'); // 'all', 'light', 'dark'

  useEffect(() => {
    // Récupérer le thème actuel depuis localStorage ou par défaut
    const savedTheme = localStorage.getItem('theme') || 'light';
    setCurrentTheme(savedTheme);
    document.documentElement.setAttribute('data-theme', savedTheme);
  }, []);

  const handleThemeChange = (themeName: string) => {
    setCurrentTheme(themeName);
    document.documentElement.setAttribute('data-theme', themeName);
    localStorage.setItem('theme', themeName);
  };

  const filteredThemes = DAISYUI_THEMES.filter(theme => 
    filterType === 'all' || theme.type === filterType
  );

  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">
          🎨 Choisir un thème
          <div className="badge badge-secondary">{DAISYUI_THEMES.length} thèmes</div>
        </h2>
        
        {/* Filtres */}
        <div className="flex gap-2 mb-4">
          <button 
            className={`btn btn-sm ${filterType === 'all' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterType('all')}
          >
            Tous ({DAISYUI_THEMES.length})
          </button>
          <button 
            className={`btn btn-sm ${filterType === 'light' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterType('light')}
          >
            🌕 Clairs ({DAISYUI_THEMES.filter(t => t.type === 'light').length})
          </button>
          <button 
            className={`btn btn-sm ${filterType === 'dark' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilterType('dark')}
          >
            🌑 Sombres ({DAISYUI_THEMES.filter(t => t.type === 'dark').length})
          </button>
        </div>

        {/* Grille de thèmes */}
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
          {filteredThemes.map(theme => (
            <button
              key={theme.name}
              className={`btn btn-outline h-auto p-3 flex-col ${
                currentTheme === theme.name ? 'btn-primary' : ''
              }`}
              onClick={() => handleThemeChange(theme.name)}
            >
              <span className="text-2xl">{theme.emoji}</span>
              <span className="text-sm font-medium capitalize">{theme.name}</span>
              <span className="text-xs opacity-70">{theme.category}</span>
            </button>
          ))}
        </div>

        {/* Thème actuel */}
        <div className="alert alert-info mt-4">
          <div className="flex items-center gap-2">
            <span>🎯 Thème actuel :</span>
            <div className="badge badge-primary">
              {DAISYUI_THEMES.find(t => t.name === currentTheme)?.emoji} {currentTheme}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default ThemeSelector;
```

## 🎯 Intégration SaaS Builder

### Mapping intelligent Industry → Thème
```tsx
// SaasThemeGenerator.ts
export const INDUSTRY_THEME_MAPPING = {
  finance: ['business', 'corporate', 'luxury'],
  healthcare: ['emerald', 'garden', 'light'],
  technology: ['cyberpunk', 'synthwave', 'dark'],
  ecommerce: ['cupcake', 'valentine', 'luxury'],
  education: ['academic', 'light', 'forest'],
  restaurant: ['coffee', 'autumn', 'warm'],
  fitness: ['emerald', 'forest', 'night'],
  creative: ['fantasy', 'synthwave', 'pastel'],
  legal: ['business', 'corporate', 'dark'],
  real_estate: ['luxury', 'business', 'light']
};

export function getOptimalTheme(industry: string, style?: 'professional' | 'modern' | 'creative'): string {
  const themes = INDUSTRY_THEME_MAPPING[industry] || ['light', 'dark'];
  
  // Logique de sélection selon le style
  if (style === 'professional') {
    return themes.find(t => ['business', 'corporate', 'luxury'].includes(t)) || themes[0];
  }
  if (style === 'creative') {
    return themes.find(t => ['fantasy', 'synthwave', 'cyberpunk'].includes(t)) || themes[0];
  }
  
  return themes[0]; // Thème par défaut
}
```

### Utilisation dans le SaaS Builder
```tsx
import { getOptimalTheme } from './SaasThemeGenerator';

function SaasBuilder() {
  const [industry, setIndustry] = useState('');
  const [style, setStyle] = useState('modern');
  const [selectedTheme, setSelectedTheme] = useState('light');

  // Auto-sélection du thème optimal
  useEffect(() => {
    if (industry) {
      const optimalTheme = getOptimalTheme(industry, style);
      setSelectedTheme(optimalTheme);
      // Prévisualiser le thème
      document.documentElement.setAttribute('data-theme', optimalTheme);
    }
  }, [industry, style]);

  return (
    <div className="space-y-6">
      <div className="form-control">
        <label className="label">
          <span className="label-text">Secteur d'activité</span>
        </label>
        <select 
          className="select select-bordered"
          value={industry}
          onChange={(e) => setIndustry(e.target.value)}
        >
          <option value="">Choisir un secteur</option>
          <option value="finance">💰 Finance</option>
          <option value="healthcare">🏥 Santé</option>
          <option value="technology">💻 Technologie</option>
          <option value="ecommerce">🛒 E-commerce</option>
          <option value="education">📚 Éducation</option>
          <option value="restaurant">🍽️ Restauration</option>
        </select>
      </div>

      <div className="alert alert-success">
        <div>
          <h3 className="font-bold">Thème recommandé</h3>
          <div className="text-xs">
            🎨 <span className="badge badge-primary">{selectedTheme}</span>
            - Optimal pour {industry}
          </div>
        </div>
      </div>
    </div>
  );
}
```

## 🔧 Configuration avancée

### Personnaliser un thème DaisyUI
```css
/* Surcharger des variables spécifiques */
[data-theme="custom-corporate"] {
  --primary: #1e40af;          /* Bleu corporate personnalisé */
  --primary-focus: #1d4ed8;
  --primary-content: #ffffff;
  
  --secondary: #64748b;
  --secondary-focus: #475569;
  --secondary-content: #ffffff;
  
  --accent: #f59e0b;
  --accent-focus: #d97706;
  --accent-content: #ffffff;
  
  --base-100: #ffffff;         /* Fond principal */
  --base-200: #f8fafc;         /* Fond secondaire */
  --base-300: #e2e8f0;         /* Fond tertiaire */
  --base-content: #1f2937;     /* Texte principal */
}
```

### Thème adaptatif système
```tsx
function useSystemTheme() {
  const [theme, setTheme] = useState('light');

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e: MediaQueryListEvent) => {
      const newTheme = e.matches ? 'dark' : 'light';
      setTheme(newTheme);
      document.documentElement.setAttribute('data-theme', newTheme);
    };

    // Initial
    setTheme(mediaQuery.matches ? 'dark' : 'light');
    
    // Écouter les changements
    mediaQuery.addEventListener('change', handleChange);
    
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

  return theme;
}
```

## 🎨 Exemples d'usage par secteur

### Finance / Corporate
```tsx
// Thèmes recommandés: business, corporate, luxury
<div data-theme="business" className="min-h-screen bg-base-100">
  <div className="navbar bg-base-300">
    <div className="navbar-brand">
      <h1 className="text-xl font-bold">FinanceApp</h1>
    </div>
  </div>
  
  <div className="container mx-auto p-6">
    <div className="stats shadow">
      <div className="stat">
        <div className="stat-title">Revenue</div>
        <div className="stat-value text-primary">$125K</div>
      </div>
    </div>
  </div>
</div>
```

### Technologie / Startups
```tsx
// Thèmes recommandés: cyberpunk, synthwave, dark
<div data-theme="cyberpunk" className="min-h-screen bg-base-100">
  <div className="hero min-h-screen">
    <div className="hero-content text-center">
      <div className="max-w-md">
        <h1 className="text-5xl font-bold gradient-text">TechSaaS</h1>
        <p className="py-6">L'avenir de la technologie commence ici</p>
        <button className="btn btn-primary btn-lg">
          Commencer maintenant
        </button>
      </div>
    </div>
  </div>
</div>
```

### E-commerce / Retail
```tsx
// Thèmes recommandés: cupcake, valentine, luxury
<div data-theme="cupcake" className="min-h-screen bg-base-100">
  <div className="grid grid-cols-1 md:grid-cols-3 gap-6 p-6">
    <div className="card bg-base-200 shadow-xl">
      <figure>
        <img src="/product.jpg" alt="Product" />
      </figure>
      <div className="card-body">
        <h2 className="card-title">Produit Premium</h2>
        <p className="text-primary font-bold">€99.99</p>
        <div className="card-actions">
          <button className="btn btn-primary">Acheter</button>
        </div>
      </div>
    </div>
  </div>
</div>
```

## 💡 Conseils d'optimisation

### Performance
- **CSS pur** : Les thèmes DaisyUI n'utilisent pas de JavaScript
- **Lazy loading** : Seul le thème actuel est chargé
- **Cache navigateur** : Les thèmes sont mis en cache automatiquement

### SEO et accessibilité
- **Contraste** : Tous les thèmes DaisyUI respectent WCAG 2.1
- **Focus** : Navigation clavier native
- **Screen readers** : Sémantique HTML préservée

### Migration depuis thèmes personnalisés
```tsx
// ❌ Ancien système
import { applyTheme } from '@lyxal/ui-kit';
applyTheme('dracula-custom');

// ✅ Nouveau système DaisyUI
document.documentElement.setAttribute('data-theme', 'dracula');
```

---

**🎨 35 thèmes DaisyUI natifs - Performance et simplicité maximales**