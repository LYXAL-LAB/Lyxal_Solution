# 🎨 Système de Thèmes Lyxal Kit UI

**Système de génération et gestion de thèmes dynamiques avec validation WCAG**

---

## 🚀 Démarrage Rapide

### Installation

Aucune dépendance externe requise ! Le système utilise uniquement :
- Variables CSS natives
- Tailwind CSS (déjà installé)
- TypeScript

### Utilisation Basique

```typescript
import { ThemeGenerator, themeManager } from '@/theme';

// Générer un thème depuis une couleur
const theme = ThemeGenerator.generateFromPrimary('#3b82f6');

// Appliquer un thème prédéfini
themeManager.applyTheme('dark');

// Créer un thème custom
themeManager.createCustomTheme('brand', {
  primary: '#8B5CF6',
  secondary: '#10B981',
  accent: '#F59E0B'
});
```

---

## 📚 Fonctionnalités

### 1. Génération Automatique

#### Depuis une Couleur Primaire

```typescript
const theme = ThemeGenerator.generateFromPrimary('#3b82f6');

// Génère automatiquement :
// ✅ 16 variables CSS complètes
// ✅ Couleurs complémentaires et triadiques
// ✅ Contraste optimal pour textes
// ✅ Neutrals harmonieux
```

#### Palettes de Couleurs

```typescript
// Palette analogique (couleurs adjacentes)
const palette = ThemeGenerator.generateAnalogousPalette('#3b82f6', 5);
// → ['#3b62f6', '#3b82f6', '#3ba2f6', '#3bb6f6', '#3bc2f6']

// Palette monochromatique (variations luminosité)
const monochrome = ThemeGenerator.generateMonochromaticPalette('#3b82f6', 9);
// → Du très clair au très foncé
```

#### Variant Sombre

```typescript
const lightTheme = ThemeGenerator.generateFromPrimary('#3b82f6');
const darkTheme = ThemeGenerator.generateDarkVariant(lightTheme);
// ✅ Couleurs ajustées automatiquement pour mode sombre
```

---

### 2. Validation Accessibilité (WCAG)

```typescript
const contrast = ThemeGenerator.checkContrast(
  [59, 130, 246],   // Texte bleu
  [255, 255, 255]   // Fond blanc
);

console.log(contrast);
// {
//   ratio: '4.51',
//   AA: true,      ✅ Texte normal (4.5:1 requis)
//   AAA: false,    ❌ Texte normal (7:1 requis)
//   AALarge: true, ✅ Texte large (3:1 requis)
//   AAALarge: true ✅ Texte large (4.5:1 requis)
// }
```

---

### 3. Gestion Runtime

```typescript
import { themeManager } from '@/theme';

// Appliquer un thème
themeManager.applyTheme('dark');

// Toggle dark/light
themeManager.toggleDarkMode();

// Obtenir le thème actuel
const current = themeManager.getCurrentTheme();

// Modifier une variable
themeManager.setVariable('--rounded-btn', '1rem');

// Écouter les changements
const unsubscribe = themeManager.onThemeChange((theme) => {
  console.log('Thème changé:', theme);
});
```

---

### 4. Thèmes Personnalisés

```typescript
// Créer un thème custom
themeManager.createCustomTheme('sunset', {
  primary: '#ff6b6b',
  secondary: '#ffa500',
  accent: '#ff1493',
  neutral: '#4a5568'
});

// Appliquer
themeManager.applyTheme('sunset');

// Exporter
const exported = themeManager.exportTheme();

// Importer
themeManager.importTheme('imported', themeData);

// Supprimer
themeManager.deleteCustomTheme('sunset');
```

---

### 5. Export Multi-Format

```typescript
// CSS
const css = ThemeGenerator.exportTheme(theme, 'css');
/*
  --color-primary: 59 130 246;
  --color-secondary: 163 211 92;
  ...
*/

// JSON
const json = ThemeGenerator.exportTheme(theme, 'json');
// { "--color-primary": "59 130 246", ... }

// Tailwind Config
const tailwind = ThemeGenerator.exportTheme(theme, 'tailwind');
// { "colors": { "primary": "rgb(59 130 246)", ... } }
```

---

## 🎨 Théorie des Couleurs

### Couleurs Complémentaires

```typescript
const complementary = ThemeGenerator.getComplementary([59, 130, 246]);
// Rotation de 180° sur le cercle chromatique
// Bleu → Jaune-Orange
```

### Couleurs Triadiques

```typescript
const [color1, color2] = ThemeGenerator.getTriadic([59, 130, 246]);
// Rotations de 120° et 240°
// Bleu → Rouge + Vert-Jaune
```

### Conversions

```typescript
// HEX → RGB
const rgb = ThemeGenerator.hexToRgb('#3b82f6');
// [59, 130, 246]

// RGB → HEX
const hex = ThemeGenerator.rgbToHex(59, 130, 246);
// '#3b82f6'

// RGB → HSL
const hsl = ThemeGenerator.rgbToHsl(59, 130, 246);
// [217, 91, 60] → Teinte: 217°, Saturation: 91%, Luminosité: 60%

// HSL → RGB
const rgb2 = ThemeGenerator.hslToRgb(217, 91, 60);
// [59, 130, 246]
```

---

## 🔧 API Référence

### ThemeGenerator (Statique)

| Méthode | Description | Retour |
|---------|-------------|--------|
| `generateFromPrimary(hex)` | Génère thème complet | `ThemeVariables` |
| `generateDarkVariant(theme)` | Crée variant sombre | `ThemeVariables` |
| `generateAnalogousPalette(hex, count)` | Palette analogique | `string[]` |
| `generateMonochromaticPalette(hex, count)` | Palette mono | `string[]` |
| `checkContrast(fg, bg)` | Validation WCAG | `ContrastResult` |
| `exportTheme(theme, format)` | Export thème | `string` |
| `hexToRgb(hex)` | Conversion HEX→RGB | `RGB` |
| `rgbToHex(r, g, b)` | Conversion RGB→HEX | `string` |
| `rgbToHsl(r, g, b)` | Conversion RGB→HSL | `HSL` |
| `hslToRgb(h, s, l)` | Conversion HSL→RGB | `RGB` |
| `validateHex(hex)` | Validation couleur | `boolean` |

### ThemeManager (Instance)

| Méthode | Description | Retour |
|---------|-------------|--------|
| `applyTheme(name)` | Applique thème | `void` |
| `createCustomTheme(name, colors)` | Crée thème custom | `void` |
| `applyCustomTheme(name)` | Applique custom | `void` |
| `setVariable(name, value)` | Modifie variable | `void` |
| `getVariable(name)` | Lit variable | `string` |
| `exportTheme()` | Export actuel | `Record<string, string>` |
| `importTheme(name, data)` | Import thème | `void` |
| `toggleDarkMode()` | Bascule clair/sombre | `void` |
| `getAvailableThemes()` | Liste thèmes | `string[]` |
| `getCurrentTheme()` | Thème actuel | `string` |
| `deleteCustomTheme(name)` | Supprime custom | `void` |
| `onThemeChange(callback)` | Écoute changements | `Function` |

---

## 💡 Exemples Avancés

### Exemple 1 : Thème de Marque Automatique

```typescript
// Votre couleur de marque
const brandColor = '#8B5CF6';

// Génération automatique
const brandTheme = ThemeGenerator.generateFromPrimary(brandColor);

// Validation accessibilité
const textContrast = ThemeGenerator.checkContrast(
  ThemeGenerator.hexToRgb(brandColor),
  [255, 255, 255]
);

if (textContrast.AA) {
  // ✅ Contraste OK, appliquer
  themeManager.importTheme('brand', brandTheme);
  themeManager.applyTheme('brand');
} else {
  // ❌ Ajuster la couleur
  console.warn('Contraste insuffisant, ajustement nécessaire');
}
```

### Exemple 2 : Thème Adaptatif (Heure du Jour)

```typescript
const hour = new Date().getHours();

let theme: string;
if (hour >= 6 && hour < 12) {
  theme = 'morning'; // Couleurs chaudes
} else if (hour >= 12 && hour < 18) {
  theme = 'day'; // Couleurs vives
} else if (hour >= 18 && hour < 22) {
  theme = 'evening'; // Couleurs douces
} else {
  theme = 'night'; // Mode sombre
}

themeManager.applyTheme(theme);
```

### Exemple 3 : Export pour Documentation

```typescript
// Générer plusieurs thèmes
const themes = ['light', 'dark', 'ocean'];

themes.forEach(themeName => {
  themeManager.applyTheme(themeName);
  const exported = themeManager.exportTheme();
  
  // Sauvegarder dans un fichier JSON
  const json = JSON.stringify(exported, null, 2);
  // Utiliser pour documentation, storybook, etc.
});
```

### Exemple 4 : Validation Batch

```typescript
// Valider tous les contrastes d'un thème
const theme = ThemeGenerator.generateFromPrimary('#your-color');
const primary = theme['--color-primary'].split(' ').map(Number) as RGB;
const base = theme['--color-base-100'].split(' ').map(Number) as RGB;

const validations = [
  { name: 'Primary on Base', fg: primary, bg: base },
  // ... autres combinaisons
];

validations.forEach(({ name, fg, bg }) => {
  const result = ThemeGenerator.checkContrast(fg, bg);
  console.log(`${name}: ${result.ratio} - AA: ${result.AA ? '✅' : '❌'}`);
});
```

---

## 🎯 Thèmes Prédéfinis

### Light (Défaut)
- Primary: Bleu (#3b82f6)
- Secondary: Vert (#10b981)
- Accent: Orange (#f59e0b)

### Dark
- Primary: Bleu clair (#60a5fa)
- Bases inversées (fonds sombres)

### Ocean
- Primary: Cyan (#06b6d4)
- Secondary: Teal (#0e7490)
- Accent: Cyan clair (#22d3ee)

---

## 🔗 Intégration

### Avec React Components

```typescript
import { themeManager } from '@/theme';
import { useEffect, useState } from 'react';

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(themeManager.getCurrentTheme());
  
  useEffect(() => {
    const unsubscribe = themeManager.onThemeChange(setTheme);
    return unsubscribe;
  }, []);
  
  return (
    <div data-theme={theme}>
      {children}
    </div>
  );
}
```

### Avec Tailwind

Les variables CSS sont automatiquement disponibles :

```tsx
<button className="bg-primary hover:bg-primary-focus text-primary-content">
  Bouton
</button>
```

---

## 🎨 Variables CSS Disponibles

### Couleurs Sémantiques
```css
--color-primary
--color-primary-focus
--color-primary-content
--color-secondary
--color-secondary-focus
--color-secondary-content
--color-accent
--color-accent-focus
--color-accent-content
```

### Couleurs de Base
```css
--color-base-100 (fond principal)
--color-base-200 (fond secondaire)
--color-base-300 (fond tertiaire)
--color-base-content (texte)
```

### Couleurs d'État
```css
--color-info
--color-success
--color-warning
--color-error
```

### Design Tokens
```css
--rounded-box (cartes)
--rounded-btn (boutons)
--rounded-badge (badges)
--animation-btn (timing boutons)
--animation-input (timing inputs)
--btn-focus-scale (scale au clic)
--border-btn (épaisseur bordure)
```

---

## 🧪 Tests & Validation

### Validation de Couleur

```typescript
// Vérifier format hex
if (ThemeGenerator.validateHex('#3b82f6')) {
  // ✅ Couleur valide
}

// Vérifier RGB dans range
const rgb: RGB = [59, 130, 246];
if (ThemeGenerator.validateRgb(rgb)) {
  // ✅ RGB valide
}
```

### Validation Accessibilité

```typescript
// WCAG AA requis pour texte normal : 4.5:1
// WCAG AAA requis pour texte normal : 7:1
// WCAG AA requis pour texte large : 3:1

const contrast = ThemeGenerator.checkContrast(foreground, background);

if (!contrast.AA) {
  console.error('⚠️ Contraste insuffisant pour WCAG AA');
  // Ajuster la couleur ou la luminosité
}
```

---

## 🎓 Concepts Avancés

### Cercle Chromatique

```
              0° Rouge
               │
               │
270° Violet ───┼─── 90° Vert-Jaune
               │
               │
             180° Cyan

Opérations :
- Complémentaire : +180° (contraste maximal)
- Triadique : +120°, +240° (harmonie équilibrée)
- Analogue : ±30° (harmonie douce)
- Monochrome : Même teinte, luminosité variable
```

### Luminance Relative (WCAG)

```
Luminance = 0.2126 × R + 0.7152 × G + 0.0722 × B

Contraste = (L1 + 0.05) / (L2 + 0.05)

Seuils WCAG :
- AA Texte normal : ≥ 4.5:1
- AAA Texte normal : ≥ 7:1
- AA Texte large : ≥ 3:1
- AAA Texte large : ≥ 4.5:1
```

---

## 📦 Structure des Fichiers

```
theme/
├── index.ts                      ← Exports centralisés
├── theme-generator.ts            ← Générateur (TypeScript ✅)
├── ThemeManager.ts               ← Gestionnaire (TypeScript ✅)
├── tailwind-theme-system.js      ← Plugin Tailwind
├── tailwind.config.js            ← Config Tailwind
├── README.md                     ← Ce fichier
└── docs/
    ├── INDEX_DOCUMENTATION.md
    ├── SYNTHESE_RAPIDE.md
    ├── SCHEMA_ARCHITECTURE.md
    └── PLAN_ANALYSE_THEME_SYSTEM.md
```

---

## 🚨 Notes Importantes

### Variables CSS Format RGB

Les variables utilisent le format RGB sans `rgb()` :

```css
/* ✅ Correct */
--color-primary: 59 130 246;

/* ❌ Incorrect */
--color-primary: rgb(59, 130, 246);
```

**Pourquoi ?** Permet d'utiliser avec `rgba()` facilement :

```css
/* Avec transparence */
background: rgba(var(--color-primary), 0.5);
```

### localStorage

Les thèmes sont sauvegardés automatiquement :
- `selectedTheme` : Thème actuel
- `customThemes` : Thèmes personnalisés

---

## 🔗 Ressources

### Documentation Complète
- `INDEX_DOCUMENTATION.md` - Index général
- `SYNTHESE_RAPIDE.md` - Vue d'ensemble (5 min)
- `SCHEMA_ARCHITECTURE.md` - Diagrammes et flux
- `PLAN_ANALYSE_THEME_SYSTEM.md` - Analyse technique

### Standards
- [WCAG 2.1 Contrast](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Color Theory](https://en.wikipedia.org/wiki/Color_theory)
- [Tailwind CSS Variables](https://tailwindcss.com/docs/customizing-colors)

---

## ✅ Checklist Migration TypeScript

- [x] theme-generator.js → theme-generator.ts
- [x] ThemeManager.js → ThemeManager.ts
- [x] Types complets ajoutés
- [x] Validation des entrées
- [x] Gestion d'erreurs
- [x] Index d'exports
- [x] Documentation README
- [ ] Tests unitaires (à faire)
- [ ] Implémentation generateFromImage()

---

## 🎉 Prochaines Étapes

1. ✅ **Migration TypeScript** - FAIT !
2. ⏳ **Connexion avec boutons** - À faire (8h)
3. ⏳ **Tests unitaires** - À faire
4. ⏳ **generateFromImage()** - À implémenter

---

**Version :** 2.0.0 (TypeScript)  
**Créé le :** 17 Novembre 2025  
**Dernière mise à jour :** 17 Novembre 2025  
**Auteur :** LyxalSuite Team

