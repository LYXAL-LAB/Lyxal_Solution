# Système de documentation pour LyxalKitUI

Ce document présente le système de documentation mis en place pour les composants de thème LyxalKitUI, y compris la structure de la documentation, les exemples interactifs et le playground pour tester les thèmes.

## Objectifs du système de documentation

1. **Fournir une documentation complète** pour chaque composant du système de thème
2. **Faciliter l'apprentissage** grâce à des exemples concrets et interactifs
3. **Permettre aux utilisateurs de tester** les thèmes en temps réel
4. **Documenter les meilleures pratiques** d'utilisation du système de thème
5. **Maintenir la documentation à jour** avec les évolutions du système

## Structure de la documentation

La documentation du système de thème LyxalKitUI est organisée selon la structure suivante:

```
docs/
├── introduction/
│   ├── getting-started.md
│   ├── core-concepts.md
│   └── architecture.md
├── components/
│   ├── theme-creator.md
│   ├── theme-preview.md
│   ├── theme-palette.md
│   ├── theme-manager.md
│   └── theme-switcher.md
├── hooks/
│   ├── use-theme.md
│   ├── use-theme-color.md
│   ├── use-theme-radius.md
│   └── use-theme-mode.md
├── guides/
│   ├── integration-complete.md
│   ├── optimisation-performances.md
│   ├── accessibilite.md
│   └── customisation-avancee.md
├── api/
│   ├── theme-definition.md
│   ├── theme-registry.md
│   └── theme-applier.md
└── playground/
    ├── theme-creator-playground.md
    └── theme-tester-playground.md
```

## Modèle de documentation des composants

Chaque composant suit un modèle de documentation standardisé:

```markdown
# Composant ThemeXYZ

## Description

Description détaillée du composant, son objectif et ses cas d'utilisation.

## API

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| prop1 | string | 'default' | Description de la prop1 |
| prop2 | number | 0 | Description de la prop2 |
| ... | ... | ... | ... |

## Exemples d'utilisation

### Exemple de base

```tsx
import { ThemeXYZ } from 'lyxalkitui';

const Example = () => (
  <ThemeXYZ prop1="value" prop2={42} />
);
```

### Exemple avancé

```tsx
// Code plus complexe avec explication
```

## Bonnes pratiques

Liste des bonnes pratiques pour l'utilisation du composant.

## Considérations d'accessibilité

Informations spécifiques sur l'accessibilité du composant.

## Voir aussi

Liens vers d'autres composants ou hooks associés.
```

## Exemples interactifs

Chaque composant de la documentation inclut des exemples interactifs permettant aux utilisateurs de manipuler les propriétés et de voir les résultats en temps réel.

### Implémentation des exemples interactifs

Les exemples interactifs sont implémentés à l'aide de composants React dédiés:

```tsx
import React, { useState } from 'react';
import { ThemePreview, ThemeDefinition } from 'lyxalkitui';
import { CodeBlock, PropsEditor } from '../doc-components';

const ThemePreviewExample = () => {
  const [props, setProps] = useState({
    showComponents: ['buttons', 'cards'],
    size: 'medium',
    mode: 'full',
  });
  
  const [theme, setTheme] = useState<ThemeDefinition>({
    id: 'example-theme',
    name: 'Example Theme',
    isDark: false,
    colors: {
      'primary': '#3b82f6',
      'primary-content': '#ffffff',
      'base-100': '#ffffff',
      'base-content': '#1f2937',
      // Autres couleurs...
    },
    radius: {
      'box': '0.5rem',
      'field': '0.25rem',
      'selector': '1.5rem',
    },
    // Autres propriétés...
  });
  
  const handlePropChange = (key, value) => {
    setProps(prev => ({
      ...prev,
      [key]: value
    }));
  };
  
  const generateCode = () => {
    return `
import { ThemePreview } from 'lyxalkitui';

const theme = ${JSON.stringify(theme, null, 2)};

const MyComponent = () => (
  <ThemePreview
    theme={theme}
    showComponents={${JSON.stringify(props.showComponents)}}
    size="${props.size}"
    mode="${props.mode}"
  />
);
    `;
  };
  
  return (
    <div className="interactive-example">
      <div className="preview-container">
        <ThemePreview
          theme={theme}
          showComponents={props.showComponents}
          size={props.size}
          mode={props.mode}
        />
      </div>
      
      <PropsEditor
        props={props}
        onChange={handlePropChange}
        options={{
          showComponents: {
            type: 'multiselect',
            options: ['buttons', 'cards', 'forms', 'alerts', 'navigation'],
          },
          size: {
            type: 'select',
            options: ['small', 'medium', 'large'],
          },
          mode: {
            type: 'select',
            options: ['full', 'compact'],
          },
        }}
      />
      
      <CodeBlock code={generateCode()} language="tsx" />
    </div>
  );
};

export default ThemePreviewExample;
```

## Playground interactif

Le playground interactif permet aux utilisateurs de tester et d'expérimenter avec le système de thème en temps réel.

### Fonctionnalités du playground

1. **Créateur de thème interactif** - Interface complète pour créer et modifier des thèmes
2. **Prévisualisation en temps réel** - Voir immédiatement les résultats des modifications
3. **Export/Import de thèmes** - Partager et réutiliser les thèmes créés
4. **Test sur différents composants** - Visualiser l'apparence du thème sur divers composants d'UI
5. **Validation d'accessibilité** - Vérifier que le thème respecte les standards d'accessibilité

### Implémentation du playground

Le playground est implémenté comme une application React standalone intégrée à la documentation:

```tsx
import React, { useState } from 'react';
import {
  ThemeCreator,
  ThemePreview,
  ThemePalette,
  ThemeDefinition,
  validateThemeContrast
} from 'lyxalkitui';

const ThemePlayground = () => {
  const [activeTheme, setActiveTheme] = useState<ThemeDefinition | null>(null);
  const [previewMode, setPreviewMode] = useState<'components' | 'accessibility'>('components');
  
  const handleSaveTheme = (theme: ThemeDefinition) => {
    setActiveTheme(theme);
  };
  
  return (
    <div className="theme-playground">
      <div className="playground-header">
        <h1>LyxalKitUI Theme Playground</h1>
        <div className="mode-selector">
          <button 
            className={previewMode === 'components' ? 'active' : ''}
            onClick={() => setPreviewMode('components')}
          >
            Prévisualisation des composants
          </button>
          <button 
            className={previewMode === 'accessibility' ? 'active' : ''}
            onClick={() => setPreviewMode('accessibility')}
          >
            Validation d'accessibilité
          </button>
        </div>
      </div>
      
      <div className="playground-content">
        <div className="theme-creator-panel">
          <h2>Créer un thème</h2>
          <ThemeCreator onSave={handleSaveTheme} />
        </div>
        
        <div className="theme-preview-panel">
          <h2>Prévisualisation</h2>
          {activeTheme ? (
            <>
              {previewMode === 'components' && (
                <ThemePreview 
                  theme={activeTheme}
                  showComponents={['buttons', 'cards', 'forms', 'alerts', 'navigation']}
                  size="large"
                />
              )}
              
              {previewMode === 'accessibility' && (
                <div className="accessibility-validator">
                  <h3>Validation des contrastes WCAG</h3>
                  <AccessibilityValidator theme={activeTheme} />
                </div>
              )}
            </>
          ) : (
            <div className="empty-state">
              Créez un thème pour le prévisualiser
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// Composant de validation d'accessibilité
const AccessibilityValidator = ({ theme }) => {
  const contrastResults = validateThemeContrast(theme);
  
  return (
    <div className="contrast-results">
      {contrastResults.map(result => (
        <div key={result.key} className={`contrast-item ${result.valid ? 'valid' : 'invalid'}`}>
          <div className="contrast-pair">
            <span>{result.key}</span>
          </div>
          <div className="contrast-ratio">
            Ratio: {result.ratio}
          </div>
          <div className="contrast-status">
            {result.valid ? '✓ Conforme' : '✗ Non conforme'}
          </div>
        </div>
      ))}
    </div>
  );
};

export default ThemePlayground;
```

## Génération de la documentation

La documentation est générée automatiquement à partir du code source et des fichiers markdown en utilisant les outils suivants:

1. **TypeDoc** - Pour générer la documentation d'API à partir des annotations TypeScript
2. **MDX** - Pour les pages de documentation avec des exemples interactifs
3. **Docusaurus** - Pour la génération du site de documentation

### Processus de génération

```bash
# Installation des dépendances
npm install

# Génération de la documentation d'API avec TypeDoc
npm run docs:api

# Construction du site de documentation avec Docusaurus
npm run docs:build

# Démarrer le serveur de documentation en local
npm run docs:start
```

## Intégration continue pour la documentation

La documentation est maintenue à jour grâce à un processus d'intégration continue:

1. Les tests automatisés vérifient que les exemples de code sont valides
2. La documentation est régénérée à chaque modification du code source
3. Les liens cassés sont détectés automatiquement
4. Les captures d'écran des exemples sont mises à jour automatiquement

## Contribution à la documentation

### Guide pour les contributeurs

```markdown
# Guide de contribution à la documentation

Pour contribuer à la documentation du système de thème LyxalKitUI, suivez ces étapes:

1. **Créez une branche** pour vos modifications
2. **Suivez le modèle** de documentation pour les nouveaux composants
3. **Ajoutez des exemples** interactifs si possible
4. **Testez localement** en exécutant `npm run docs:start`
5. **Soumettez une pull request** avec une description de vos modifications
```

## Résumé

Le système de documentation de LyxalKitUI fournit:

1. Une documentation complète et structurée pour tous les composants et hooks
2. Des exemples interactifs pour faciliter l'apprentissage
3. Un playground pour expérimenter avec les thèmes
4. Des guides détaillés pour l'intégration et l'optimisation
5. Une documentation d'API générée automatiquement
6. Un processus d'intégration continue pour maintenir la documentation à jour

Ces ressources permettent aux développeurs d'adopter rapidement le système de thème LyxalKitUI et de l'utiliser efficacement dans leurs projets. 