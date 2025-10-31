# Guide d'intégration complète du système de thème LyxalKitUI

Ce guide présente comment intégrer et utiliser tous les composants du système de thème LyxalKitUI ensemble dans une application.

## Installation et configuration

Pour utiliser le système de thème LyxalKitUI, assurez-vous d'avoir correctement installé le package:

```bash
npm install lyxalkitui
```

## Architecture du système de thème

Le système de thème LyxalKitUI comprend plusieurs composants qui fonctionnent ensemble:

1. **ThemeProvider**: Fournit le contexte de thème à l'application
2. **ThemeCreator**: Interface pour créer et modifier des thèmes
3. **ThemePreview**: Composant de prévisualisation des thèmes
4. **ThemePalette**: Générateur de palettes de couleurs
5. **ThemeManager**: Interface pour gérer les thèmes (import/export, organisation)
6. **ThemeSwitcher**: Sélecteur de thème avec prévisualisation
7. **Hooks spécialisés**: Pour accéder facilement aux propriétés du thème

## Exemple d'application complète

Voici un exemple d'application qui intègre tous les composants du système de thème:

```tsx
import React, { useState } from 'react';
import { 
  ThemeProvider, 
  ThemeSwitcher, 
  ThemeCreator, 
  ThemeManager, 
  ThemePreview,
  ThemePalette,
  useTheme,
  ThemeDefinition
} from 'lyxalkitui';

const App = () => {
  // États pour contrôler l'affichage des différentes interfaces
  const [showCreator, setShowCreator] = useState(false);
  const [showManager, setShowManager] = useState(false);
  const [editingTheme, setEditingTheme] = useState<ThemeDefinition | null>(null);
  
  // Accéder au thème via le hook useTheme
  const { theme, allThemes, setTheme } = useTheme();
  
  // Gérer la sauvegarde d'un nouveau thème
  const handleSaveTheme = (newTheme: ThemeDefinition) => {
    setShowCreator(false);
    setEditingTheme(null);
    // Le thème est automatiquement enregistré par ThemeCreator
  };
  
  // Gérer l'édition d'un thème existant
  const handleEditTheme = (theme: ThemeDefinition) => {
    setEditingTheme(theme);
    setShowCreator(true);
    setShowManager(false);
  };
  
  // Gérer la suppression d'un thème
  const handleDeleteTheme = (themeId: string) => {
    // La suppression est gérée par ThemeManager
    // Vous pouvez ajouter une confirmation ici
  };
  
  return (
    <ThemeProvider>
      <div className="app-container">
        <header>
          <h1>Application avec LyxalKitUI</h1>
          
          {/* Bouton de basculement du mode clair/sombre */}
          <button onClick={() => {
            const { toggleDarkMode } = useTheme();
            toggleDarkMode();
          }}>
            {theme?.isDark ? '☀️ Mode clair' : '🌙 Mode sombre'}
          </button>
        </header>
        
        <main>
          {/* Interface principale */}
          <div className="theme-tools">
            <button onClick={() => {
              setShowCreator(true);
              setEditingTheme(null);
              setShowManager(false);
            }}>
              Créer un nouveau thème
            </button>
            
            <button onClick={() => {
              setShowManager(true);
              setShowCreator(false);
            }}>
              Gérer les thèmes
            </button>
          </div>
          
          {/* Affichage du sélecteur de thème */}
          <div className="theme-switcher-container">
            <h2>Sélectionnez un thème</h2>
            <ThemeSwitcher />
          </div>
          
          {/* Affichage du créateur de thème si nécessaire */}
          {showCreator && (
            <div className="modal">
              <div className="modal-content">
                <ThemeCreator 
                  initialTheme={editingTheme || undefined}
                  onSave={handleSaveTheme}
                  onCancel={() => {
                    setShowCreator(false);
                    setEditingTheme(null);
                  }}
                />
              </div>
            </div>
          )}
          
          {/* Affichage du gestionnaire de thème si nécessaire */}
          {showManager && (
            <div className="modal">
              <div className="modal-content">
                <ThemeManager 
                  onEdit={handleEditTheme}
                  onDelete={handleDeleteTheme}
                  onSelect={(theme) => setTheme(theme.id)}
                  onImport={() => {/* Géré automatiquement */}}
                  onExport={() => {/* Géré automatiquement */}}
                />
                <button onClick={() => setShowManager(false)}>
                  Fermer
                </button>
              </div>
            </div>
          )}
        </main>
      </div>
    </ThemeProvider>
  );
};

export default App;
```

## Scénarios d'utilisation courants

### 1. Changement de thème

```tsx
import { useTheme } from 'lyxalkitui';

const ThemeToggle = () => {
  const { theme, setTheme, toggleDarkMode } = useTheme();
  
  return (
    <div>
      <button onClick={() => toggleDarkMode()}>
        {theme?.isDark ? 'Mode clair' : 'Mode sombre'}
      </button>
      
      <button onClick={() => setTheme('blue-theme')}>
        Thème bleu
      </button>
    </div>
  );
};
```

### 2. Accès aux propriétés du thème

```tsx
import { useThemeColor, useThemeRadius } from 'lyxalkitui';

const StyledComponent = () => {
  const { getColor } = useThemeColor();
  const { getRadius } = useThemeRadius();
  
  const style = {
    backgroundColor: getColor('primary'),
    color: getColor('primary-content'),
    borderRadius: getRadius('box'),
    padding: '1rem',
  };
  
  return <div style={style}>Composant stylisé avec le thème</div>;
};
```

### 3. Création d'un nouveau thème à partir d'une couleur

```tsx
import React, { useState } from 'react';
import { ThemePalette, ThemeCreator, ThemeDefinition } from 'lyxalkitui';

const ThemeGenerator = () => {
  const [baseColor, setBaseColor] = useState('#3b82f6');
  const [generatedColors, setGeneratedColors] = useState({});
  const [showCreator, setShowCreator] = useState(false);
  
  const handleColorChange = (colors) => {
    setGeneratedColors(colors);
  };
  
  const createThemeFromPalette = () => {
    // Préparer un thème initial avec les couleurs générées
    const initialTheme = {
      id: `custom-${Date.now()}`,
      name: 'Thème généré',
      isDark: false,
      colors: generatedColors,
      // Autres propriétés par défaut
    };
    
    setShowCreator(true);
  };
  
  return (
    <div>
      <h2>Générer un thème à partir d'une couleur</h2>
      <ThemePalette 
        baseColor={baseColor}
        colorScheme="analogous"
        onChange={handleColorChange}
        variations={5}
      />
      
      <button onClick={createThemeFromPalette}>
        Créer un thème avec cette palette
      </button>
      
      {showCreator && (
        <ThemeCreator 
          initialTheme={initialTheme}
          onSave={() => setShowCreator(false)}
          onCancel={() => setShowCreator(false)}
        />
      )}
    </div>
  );
};
```

## Meilleures pratiques

1. **Utilisez ThemeProvider au plus haut niveau** de votre application pour que tous les composants aient accès au contexte de thème.

2. **Préférez les hooks spécialisés** (useThemeColor, useThemeRadius) plutôt que useTheme lorsque vous n'avez besoin que de certaines propriétés du thème.

3. **Mettez en cache les valeurs de thème** dans les composants qui les utilisent fréquemment pour éviter des re-rendus inutiles.

4. **Utilisez ThemePreview** pour tester vos thèmes avant de les appliquer à l'application complète.

5. **Organisez vos thèmes par catégories** pour faciliter leur gestion dans ThemeManager.

## Optimisation des performances

Pour optimiser les performances du système de thème:

1. Utilisez `React.memo` pour les composants qui dépendent des valeurs du thème mais ne changent pas souvent.

2. Évitez de recalculer les styles dérivés du thème à chaque rendu en utilisant `useMemo`.

3. N'appliquez pas de nouveaux thèmes trop fréquemment, car cela déclenche des mises à jour CSS globales.

```tsx
import React, { useMemo } from 'react';
import { useThemeColor } from 'lyxalkitui';

const OptimizedComponent = React.memo(() => {
  const { getColor } = useThemeColor();
  
  // Calculer les styles une seule fois par valeur de thème
  const style = useMemo(() => ({
    backgroundColor: getColor('primary'),
    color: getColor('primary-content'),
    padding: '1rem',
  }), [getColor]);
  
  return <div style={style}>Composant optimisé</div>;
});
```

Ce guide couvre les bases de l'intégration des composants du système de thème LyxalKitUI. Pour plus d'informations, consultez la documentation complète de chaque composant. 