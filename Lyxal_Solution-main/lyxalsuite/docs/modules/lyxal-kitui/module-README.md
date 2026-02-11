# LyxalKitUI

Une librairie de composants React moderne et élégante construite avec Tailwind CSS et TypeScript.

## 🚀 Fonctionnalités

- **Composants universels** : Button, Input, Textarea, Table, Badge, Modal, Loader
- **Pages composables** : LoginPage, Dashboard prêtes à l'emploi
- **Système de thème** : Support des thèmes personnalisés avec CSS variables
- **TypeScript** : Entièrement typé pour une meilleure expérience de développement
- **Tailwind CSS** : Styles utilitaires et personnalisables
- **Responsive** : Optimisé pour tous les écrans
- **Accessibilité** : Conforme aux standards WCAG
- **Thème sombre** : Support natif du mode sombre

## 📦 Installation

```bash
npm install lyxalkitui
# ou
yarn add lyxalkitui
# ou
pnpm add lyxalkitui
```

## 🛠️ Configuration

### 1. Importer les styles

Dans votre fichier principal (ex: `main.tsx` ou `App.tsx`) :

```tsx
import 'lyxalkitui/dist/style.css';
```

### 2. Configuration Tailwind (optionnel)

Si vous utilisez Tailwind CSS dans votre projet, ajoutez notre configuration :

```js
// tailwind.config.js
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
    './node_modules/lyxalkitui/dist/**/*.{js,ts,jsx,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: 'var(--primary-50)',
          100: 'var(--primary-100)',
          200: 'var(--primary-200)',
          300: 'var(--primary-300)',
          400: 'var(--primary-400)',
          500: 'var(--primary-500)',
          600: 'var(--primary-600)',
          700: 'var(--primary-700)',
          800: 'var(--primary-800)',
          900: 'var(--primary-900)',
        },
        // ... autres couleurs
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
```

## 🎨 Utilisation

### Composants de base

```tsx
import { Button, Input, Modal, Badge } from 'lyxalkitui';

function App() {
  return (
    <div>
      <Button variant="primary" size="lg">
        Cliquez-moi
      </Button>
      
      <Input
        label="Email"
        type="email"
        placeholder="votre@email.com"
      />
      
      <Badge variant="success">Actif</Badge>
    </div>
  );
}
```

### Pages composables

```tsx
import { LoginPage, Dashboard } from 'lyxalkitui';

// Page de connexion
function Login() {
  return (
    <LoginPage
      title="Connexion"
      onSubmit={async (credentials) => {
        // Logique de connexion
        console.log(credentials);
      }}
      signupLink="/signup"
      forgotPasswordLink="/forgot-password"
    />
  );
}

// Tableau de bord
function DashboardPage() {
  const stats = [
    {
      title: 'Utilisateurs',
      value: '1,234',
      change: { value: 12, type: 'increase' },
      icon: <UserIcon />
    }
  ];
  
  return (
    <Dashboard
      title="Mon Dashboard"
      stats={stats}
      user={{ name: 'John Doe', role: 'Admin' }}
    />
  );
}
```

### Système de thème

```tsx
import { injectTheme, applyPresetTheme } from 'lyxalkitui';

// Thème personnalisé
injectTheme({
  colors: {
    primary: {
      500: '#3b82f6',
      600: '#2563eb',
      // ...
    }
  }
});

// Thèmes prédéfinis
applyPresetTheme('dark');
applyPresetTheme('light');
```

## 📚 Composants disponibles

### Button
Bouton universel avec support des variantes, tailles, icônes et état de chargement.

**Props principales :**
- `variant`: 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive'
- `size`: 'sm' | 'md' | 'lg' | 'xl'
- `loading`: boolean
- `icon`: ReactNode
- `fullWidth`: boolean

### Input
Champ de saisie avec support des labels, erreurs, icônes et différentes variantes.

**Props principales :**
- `label`: string
- `error`: string
- `helperText`: string
- `icon`: ReactNode
- `variant`: 'default' | 'filled' | 'underlined'
- `size`: 'sm' | 'md' | 'lg'

### Table
Tableau dynamique avec tri, pagination et rendu personnalisé.

**Props principales :**
- `columns`: TableColumn[]
- `data`: any[]
- `loading`: boolean
- `bordered`: boolean
- `striped`: boolean

### Modal
Modal composable avec gestion du focus et des événements clavier.

**Props principales :**
- `open`: boolean
- `onClose`: () => void
- `title`: string
- `size`: 'sm' | 'md' | 'lg' | 'xl' | 'full'
- `closeOnOverlayClick`: boolean

### Badge
Badge avec support des variantes, tailles et icônes.

**Props principales :**
- `variant`: 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'error'
- `size`: 'sm' | 'md' | 'lg'
- `icon`: ReactNode
- `dot`: boolean

### Loader
Indicateur de chargement avec différents types d'animation.

**Props principales :**
- `variant`: 'spinner' | 'dots' | 'pulse' | 'bars'
- `size`: 'sm' | 'md' | 'lg' | 'xl'
- `color`: string
- `fullScreen`: boolean

## 🎯 Pages composables

### LoginPage
Page de connexion complète avec validation, gestion d'erreurs et personnalisation.

### Dashboard
Tableau de bord avec statistiques, actions rapides, tableau de données et contenu personnalisé.

## 🎨 Personnalisation

### Variables CSS

Tous les composants utilisent des variables CSS personnalisables :

```css
:root {
  --primary-500: #3b82f6;
  --secondary-500: #6b7280;
  --success-500: #10b981;
  --warning-500: #f59e0b;
  --error-500: #ef4444;
  --background: #ffffff;
  --foreground: #0f172a;
  --muted: #f8fafc;
  --border: #e2e8f0;
}
```

### Classes CSS personnalisées

Chaque composant accepte une prop `className` pour la personnalisation :

```tsx
<Button className="mon-style-personnalise">
  Bouton personnalisé
</Button>
```

## 🌙 Mode sombre

Le mode sombre est automatiquement activé avec l'attribut `data-theme="dark"` :

```tsx
// Activer le mode sombre
document.documentElement.setAttribute('data-theme', 'dark');

// Désactiver le mode sombre
document.documentElement.removeAttribute('data-theme');
```

## 📱 Responsive

Tous les composants sont optimisés pour les différentes tailles d'écran :

- **Mobile** : < 768px
- **Tablet** : 768px - 1024px
- **Desktop** : > 1024px

## ♿ Accessibilité

- Support complet du clavier
- Attributs ARIA appropriés
- Contrastes de couleurs conformes WCAG
- Focus visible et logique
- Support des lecteurs d'écran

## 🔧 Développement

```bash
# Installation des dépendances
npm install

# Développement
npm run dev

# Build
npm run build

# Tests
npm run test

# Linting
npm run lint
```

## 📄 Licence

MIT © LyxalKitUI

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez notre guide de contribution pour plus d'informations.

## 📞 Support

Pour toute question ou problème, n'hésitez pas à ouvrir une issue sur GitHub.

# LyxalKitUI - Système de thème avancé

LyxalKitUI est une bibliothèque de composants React qui offre un système de thème riche et personnalisable.

## Composants du système de thème

### ThemeSwitcher
Un sélecteur de thème qui permet aux utilisateurs de choisir parmi une liste de thèmes disponibles.

```jsx
import { ThemeSwitcher } from 'lyxalkitui';

<ThemeSwitcher onThemeChange={(theme) => console.log('Thème changé:', theme)} />
```

### ThemeCreator
Un éditeur visuel pour créer et personnaliser des thèmes.

```jsx
import { ThemeCreator } from 'lyxalkitui';

<ThemeCreator onSave={(theme) => console.log('Thème sauvegardé:', theme)} />
```

### ThemePreview
Un composant de prévisualisation qui montre l'apparence des composants courants avec un thème spécifique.

```jsx
import { ThemePreview } from 'lyxalkitui';

<ThemePreview 
  theme={myTheme} 
  showComponents={['buttons', 'cards', 'forms']} 
  size="large" 
/>
```

### ThemeManager
Un gestionnaire de thèmes qui permet d'organiser, filtrer, exporter et importer des thèmes.

```jsx
import { ThemeManager } from 'lyxalkitui';

<ThemeManager 
  onImport={(theme) => console.log('Thème importé:', theme)}
  onExport={(theme) => console.log('Thème exporté:', theme)}
  onDelete={(themeId) => console.log('Thème supprimé:', themeId)}
/>
```

### ThemePalette
Un générateur de palettes de couleurs harmonieuses à partir d'une couleur de base.

```jsx
import { ThemePalette } from 'lyxalkitui';

<ThemePalette 
  baseColor="#3b82f6" 
  colorScheme="analogous" 
  onChange={(colors) => console.log('Palette générée:', colors)} 
/>
```

### ThemeModal
Une boîte de dialogue modale qui intègre ThemeCreator pour une expérience d'édition de thème immersive.

```jsx
import { ThemeModal } from 'lyxalkitui';

<ThemeModal 
  isOpen={isModalOpen} 
  onClose={() => setIsModalOpen(false)}
  onSave={(theme) => console.log('Thème sauvegardé:', theme)}
/>
```

## Hooks

### useTheme
Hook principal pour accéder au thème actif et ses fonctions.

```jsx
import { useTheme } from 'lyxalkitui';

function MyComponent() {
  const { theme, setTheme, toggleDarkMode } = useTheme();
  
  return (
    <div>
      <h1>Thème actuel: {theme?.name}</h1>
      <button onClick={() => toggleDarkMode()}>
        Basculer en mode {theme?.isDark ? 'clair' : 'sombre'}
      </button>
    </div>
  );
}
```

### Hooks spécialisés
Des hooks pour accéder à des aspects spécifiques du thème.

```jsx
import { useThemeColor, useThemeRadius, useThemeMode } from 'lyxalkitui';

function MyComponent() {
  const { getColor } = useThemeColor();
  const { getRadius } = useThemeRadius();
  const { isDark, toggleDarkMode } = useThemeMode();
  
  return (
    <div style={{ 
      backgroundColor: getColor('base-100'),
      borderRadius: getRadius('box')
    }}>
      <h1>Mode {isDark ? 'sombre' : 'clair'}</h1>
      <button onClick={toggleDarkMode}>Basculer</button>
    </div>
  );
}
```

## Fonctions utilitaires

### Appliquer un thème
```jsx
import { applyTheme } from 'lyxalkitui';

// Appliquer un thème par son ID
applyTheme('theme-modern-light');
```

### Créer un thème
```jsx
import { createTheme } from 'lyxalkitui';

const myTheme = createTheme({
  name: 'mon-theme',
  label: 'Mon Thème',
  colors: {
    'primary': '#3b82f6',
    'primary-content': '#ffffff',
    'base-100': '#ffffff',
    'base-content': '#333333'
  },
  radius: {
    'box': '8px',
    'field': '4px'
  },
  isDark: false
});
```

### Enregistrer un thème
```jsx
import { registerTheme } from 'lyxalkitui';

// Enregistrer un thème personnalisé
registerTheme(myTheme);
```

### Obtenir tous les thèmes
```jsx
import { getAllThemes } from 'lyxalkitui';

// Récupérer tous les thèmes disponibles
const themes = getAllThemes();
```

## Initialisation du système de thème
```jsx
import { initThemeSystem } from 'lyxalkitui';

// Initialiser le système de thème (à appeler au démarrage de l'application)
initThemeSystem();
```

## Observer les changements de thème
```jsx
import { onThemeChange } from 'lyxalkitui';

// S'abonner aux changements de thème
const unsubscribe = onThemeChange((event) => {
  console.log('Thème changé:', event.detail.theme);
});

// Se désabonner quand c'est nécessaire
unsubscribe();
```