# Thèmes Additionnels LyxalKitUI

LyxalKitUI inclut maintenant une variété de thèmes additionnels qui ont été convertis à partir des anciens thèmes CSS vers le nouveau format du système de thème amélioré.

## Thèmes Disponibles

Voici les thèmes additionnels actuellement disponibles :

### Thèmes Clairs
- **Acid** : Un thème acidulé avec des couleurs vives
- **Cyberpunk** : Un thème futuriste inspiré du style cyberpunk

### Thèmes Sombres
- **Dracula** : Un thème sombre inspiré du célèbre thème Dracula
- **Night** : Un thème nocturne aux teintes bleutées
- **Synthwave** : Un thème rétro inspiré des années 80

## Utilisation des Thèmes

### Initialisation avec tous les thèmes

Par défaut, le système de thème initialise tous les thèmes disponibles, y compris les thèmes additionnels :

```tsx
import { ThemeInitializer } from 'lyxalkitui';

function App() {
  return (
    <ThemeInitializer>
      <YourApp />
    </ThemeInitializer>
  );
}
```

### Changement de Thème

Vous pouvez changer de thème en utilisant l'ID du thème :

```tsx
import { useTheme, cyberpunkTheme } from 'lyxalkitui';

function ThemeSwitcher() {
  const { changeTheme } = useTheme();
  
  return (
    <button onClick={() => changeTheme(cyberpunkTheme.id)}>
      Activer le thème Cyberpunk
    </button>
  );
}
```

### Utilisation du Sélecteur de Thème

Le composant `ThemeSelector` affiche automatiquement tous les thèmes disponibles, y compris les thèmes additionnels :

```tsx
import { ThemeSelector } from 'lyxalkitui';

function Settings() {
  return (
    <div>
      <h2>Paramètres</h2>
      <ThemeSelector />
    </div>
  );
}
```

## Ajout de Nouveaux Thèmes

Si vous souhaitez ajouter de nouveaux thèmes, vous pouvez utiliser la fonction `cssToThemeDefinition` pour convertir les thèmes CSS existants, ou créer directement des thèmes au format `ThemeDefinition` :

```tsx
import { registerTheme, ThemeDefinition } from 'lyxalkitui';

const myCustomTheme: ThemeDefinition = {
  id: 'custom-theme',
  name: 'custom-theme',
  label: 'Mon Thème Personnalisé',
  category: 'custom',
  isDark: false,
  colors: {
    primary: '#ff0000',
    'primary-content': '#ffffff',
    // ... autres couleurs
  },
  // ... autres propriétés
};

// Enregistrer le thème
registerTheme(myCustomTheme);
```

## Structure des Fichiers

Les thèmes additionnels sont définis dans les fichiers suivants :

- `src/theme/enhanced/additionalThemes.ts` : Contient la définition et la conversion des thèmes additionnels
- `src/theme/enhanced/defaultThemes.ts` : Exporte les thèmes de base et additionnels
- `src/theme/enhanced/index.ts` : Point d'entrée pour l'export des thèmes

## Catégories de Thèmes

Les thèmes sont organisés en catégories pour faciliter leur utilisation :

- **base** : Thèmes fondamentaux (light, dark, corporate)
- **extended** : Thèmes additionnels convertis des anciens thèmes CSS
- **custom** : Vos thèmes personnalisés (si vous en ajoutez)

## Personnalisation Avancée

Vous pouvez créer des variantes de thèmes existants :

```tsx
import { darkTheme, registerTheme } from 'lyxalkitui';

// Créer une variante du thème sombre
const darkBlueTheme: ThemeDefinition = {
  ...darkTheme,
  id: 'dark-blue',
  name: 'dark-blue',
  label: 'Bleu Sombre',
  colors: {
    ...darkTheme.colors,
    primary: '#0055ff',
    'primary-content': '#ffffff',
  }
};

// Enregistrer la variante
registerTheme(darkBlueTheme);
```

## Prochaines Étapes

Pour des thèmes plus riches, vous pouvez envisager d'ajouter d'autres propriétés comme :

- Typographie spécifique au thème
- Effets d'animation personnalisés
- Variables d'espacement spécifiques au thème
- Styles d'ombre personnalisés 