# Environnement de test pour la migration des composants

Ce document détaille la configuration de l'environnement de test pour vérifier les changements visuels lors de la migration des composants au nouveau système de thème LyxalKitUI.

## 1. Structure de l'environnement de test

L'environnement de test est une application React autonome qui permet de visualiser les composants avant et après la migration vers le nouveau système de thème.

### 1.1 Structure des répertoires

```
lyxalsuite/
└── lyxalkitui/
    └── test-environment/
        ├── public/                # Fichiers statiques
        ├── src/
        │   ├── components/        # Composants de l'environnement de test
        │   │   ├── ThemePreview/  # Visualisation des thèmes
        │   │   ├── ComparisonView/# Vue comparaison avant/après
        │   │   └── TestCase/      # Cas de test individuels
        │   ├── tests/             # Cas de test pour chaque composant
        │   │   ├── Badge.test.tsx # Test pour Badge
        │   │   ├── Alert.test.tsx # Test pour Alert
        │   │   └── ...
        │   ├── themes/            # Définitions des thèmes
        │   │   ├── old/           # Ancien système de thème
        │   │   └── new/           # Nouveau système de thème
        │   ├── App.tsx            # Application principale
        │   └── index.tsx          # Point d'entrée
        ├── package.json
        └── tsconfig.json
```

### 1.2 Installation et configuration

```bash
# Créer le répertoire de l'environnement de test
mkdir -p lyxalsuite/lyxalkitui/test-environment

# Initialiser l'application React
cd lyxalsuite/lyxalkitui/test-environment
npm init -y
npm install react react-dom @types/react @types/react-dom typescript
npm install --save-dev vite @vitejs/plugin-react

# Installer les dépendances nécessaires
npm install @lyxalkitui/core # Version actuelle
npm install @lyxalkitui/theme # Nouveau système de thème
```

## 2. Composants de l'environnement de test

### 2.1 Visualisation comparative (ComparisonView)

Ce composant affiche deux versions du même composant côte à côte, permettant une comparaison visuelle directe.

```tsx
// src/components/ComparisonView/ComparisonView.tsx
import React from 'react';
import './ComparisonView.css';

type ComparisonViewProps = {
  title: string;
  description?: string;
  beforeComponent: React.ReactNode;
  afterComponent: React.ReactNode;
};

export const ComparisonView: React.FC<ComparisonViewProps> = ({
  title,
  description,
  beforeComponent,
  afterComponent
}) => {
  return (
    <div className="comparison-view">
      <h2 className="comparison-title">{title}</h2>
      {description && <p className="comparison-description">{description}</p>}
      
      <div className="comparison-container">
        <div className="comparison-side">
          <h3 className="comparison-label">Avant</h3>
          <div className="comparison-content">
            {beforeComponent}
          </div>
        </div>
        
        <div className="comparison-divider" />
        
        <div className="comparison-side">
          <h3 className="comparison-label">Après</h3>
          <div className="comparison-content">
            {afterComponent}
          </div>
        </div>
      </div>
    </div>
  );
};
```

### 2.2 Cas de test (TestCase)

Ce composant encapsule un cas de test spécifique pour un composant, avec des contrôles pour modifier les propriétés et visualiser différents états.

```tsx
// src/components/TestCase/TestCase.tsx
import React, { useState } from 'react';
import './TestCase.css';

type TestCaseProps = {
  title: string;
  component: React.FC<any>;
  props: Record<string, any>;
  controls?: React.ReactNode;
  states?: {
    label: string;
    props: Record<string, any>;
  }[];
};

export const TestCase: React.FC<TestCaseProps> = ({
  title,
  component: Component,
  props: initialProps,
  controls,
  states = []
}) => {
  const [currentProps, setCurrentProps] = useState(initialProps);
  const [selectedState, setSelectedState] = useState<number | null>(null);
  
  const handleStateChange = (index: number) => {
    setSelectedState(index);
    setCurrentProps({ ...initialProps, ...states[index].props });
  };
  
  return (
    <div className="test-case">
      <h3 className="test-case-title">{title}</h3>
      
      {states.length > 0 && (
        <div className="test-case-states">
          <span>États: </span>
          {states.map((state, index) => (
            <button
              key={index}
              className={`test-case-state-btn ${selectedState === index ? 'active' : ''}`}
              onClick={() => handleStateChange(index)}
            >
              {state.label}
            </button>
          ))}
          {selectedState !== null && (
            <button
              className="test-case-reset-btn"
              onClick={() => {
                setSelectedState(null);
                setCurrentProps(initialProps);
              }}
            >
              Réinitialiser
            </button>
          )}
        </div>
      )}
      
      {controls && <div className="test-case-controls">{controls}</div>}
      
      <div className="test-case-component">
        <Component {...currentProps} />
      </div>
    </div>
  );
};
```

## 3. Cas de test pour les composants prioritaires

### 3.1 Badge

```tsx
// src/tests/Badge.test.tsx
import React from 'react';
import { ComparisonView } from '../components/ComparisonView/ComparisonView';
import { TestCase } from '../components/TestCase/TestCase';

// Importer l'ancienne version du Badge
import { Badge as OldBadge } from '@lyxalkitui/core';

// Importer la nouvelle version du Badge (à implémenter)
import { Badge as NewBadge } from '@lyxalkitui/theme';

export const BadgeTest: React.FC = () => {
  const badgeStates = [
    { label: 'Default', props: {} },
    { label: 'Primary', props: { variant: 'primary' } },
    { label: 'Success', props: { variant: 'success' } },
    { label: 'Warning', props: { variant: 'warning' } },
    { label: 'Error', props: { variant: 'error' } },
  ];
  
  return (
    <div className="component-test">
      <h1>Test du composant Badge</h1>
      
      <ComparisonView
        title="Badge basique"
        description="Comparaison du badge standard avec différentes variantes"
        beforeComponent={
          <TestCase
            title="Badge (ancien)"
            component={OldBadge}
            props={{ children: 'Badge' }}
            states={badgeStates}
          />
        }
        afterComponent={
          <TestCase
            title="Badge (nouveau)"
            component={NewBadge}
            props={{ children: 'Badge' }}
            states={badgeStates}
          />
        }
      />
      
      <ComparisonView
        title="Badge avec icône"
        description="Comparaison du badge avec une icône"
        beforeComponent={
          <TestCase
            title="Badge avec icône (ancien)"
            component={OldBadge}
            props={{ 
              children: (
                <>
                  <span className="icon">✓</span>
                  <span>Validé</span>
                </>
              )
            }}
            states={badgeStates}
          />
        }
        afterComponent={
          <TestCase
            title="Badge avec icône (nouveau)"
            component={NewBadge}
            props={{ 
              children: (
                <>
                  <span className="icon">✓</span>
                  <span>Validé</span>
                </>
              )
            }}
            states={badgeStates}
          />
        }
      />
    </div>
  );
};
```

### 3.2 Alert

```tsx
// src/tests/Alert.test.tsx
import React from 'react';
import { ComparisonView } from '../components/ComparisonView/ComparisonView';
import { TestCase } from '../components/TestCase/TestCase';

// Importer l'ancienne version de l'Alert
import { Alert as OldAlert } from '@lyxalkitui/core';

// Importer la nouvelle version de l'Alert (à implémenter)
import { Alert as NewAlert } from '@lyxalkitui/theme';

export const AlertTest: React.FC = () => {
  const alertStates = [
    { label: 'Default', props: {} },
    { label: 'Info', props: { variant: 'info' } },
    { label: 'Success', props: { variant: 'success' } },
    { label: 'Warning', props: { variant: 'warning' } },
    { label: 'Error', props: { variant: 'error' } },
  ];
  
  return (
    <div className="component-test">
      <h1>Test du composant Alert</h1>
      
      <ComparisonView
        title="Alert basique"
        description="Comparaison de l'alerte standard avec différentes variantes"
        beforeComponent={
          <TestCase
            title="Alert (ancien)"
            component={OldAlert}
            props={{ 
              children: 'Ceci est une alerte informative.'
            }}
            states={alertStates}
          />
        }
        afterComponent={
          <TestCase
            title="Alert (nouveau)"
            component={NewAlert}
            props={{ 
              children: 'Ceci est une alerte informative.'
            }}
            states={alertStates}
          />
        }
      />
      
      <ComparisonView
        title="Alert avec titre et action"
        description="Comparaison de l'alerte avec titre et bouton d'action"
        beforeComponent={
          <TestCase
            title="Alert avec titre (ancien)"
            component={OldAlert}
            props={{ 
              title: "Attention requise",
              children: 'Une action est nécessaire de votre part.',
              action: <button>Agir</button>
            }}
            states={alertStates}
          />
        }
        afterComponent={
          <TestCase
            title="Alert avec titre (nouveau)"
            component={NewAlert}
            props={{ 
              title: "Attention requise",
              children: 'Une action est nécessaire de votre part.',
              action: <button>Agir</button>
            }}
            states={alertStates}
          />
        }
      />
    </div>
  );
};
```

## 4. Application principale

```tsx
// src/App.tsx
import React, { useState } from 'react';
import './App.css';
import { BadgeTest } from './tests/Badge.test';
import { AlertTest } from './tests/Alert.test';
import { CardTest } from './tests/Card.test';
import { ButtonTest } from './tests/Button.test';
import { ToggleTest } from './tests/Toggle.test';

// Composants de test supplémentaires à ajouter

const components = [
  { name: 'Badge', component: BadgeTest },
  { name: 'Alert', component: AlertTest },
  { name: 'Card', component: CardTest },
  { name: 'Button', component: ButtonTest },
  { name: 'Toggle', component: ToggleTest },
  // Ajouter d'autres composants ici
];

const App: React.FC = () => {
  const [activeTheme, setActiveTheme] = useState<'light' | 'dark'>('light');
  const [activeComponent, setActiveComponent] = useState<string | null>('Badge');
  
  const toggleTheme = () => {
    setActiveTheme(activeTheme === 'light' ? 'dark' : 'light');
  };
  
  const ActiveComponent = activeComponent 
    ? components.find(c => c.name === activeComponent)?.component 
    : null;
  
  return (
    <div className="app" data-theme={activeTheme}>
      <header className="app-header">
        <h1>LyxalKitUI - Environnement de test</h1>
        <div className="app-controls">
          <button onClick={toggleTheme}>
            {activeTheme === 'light' ? '🌙 Mode sombre' : '☀️ Mode clair'}
          </button>
        </div>
      </header>
      
      <div className="app-container">
        <aside className="app-sidebar">
          <h2>Composants</h2>
          <ul className="component-list">
            {components.map(({ name }) => (
              <li 
                key={name}
                className={activeComponent === name ? 'active' : ''}
                onClick={() => setActiveComponent(name)}
              >
                {name}
              </li>
            ))}
          </ul>
        </aside>
        
        <main className="app-content">
          {ActiveComponent ? <ActiveComponent /> : (
            <div className="app-empty-state">
              <p>Sélectionnez un composant pour commencer les tests</p>
            </div>
          )}
        </main>
      </div>
    </div>
  );
};

export default App;
```

## 5. Scénarios de test

Pour chaque composant, les scénarios de test suivants seront vérifiés:

### 5.1 Scénarios de base
- Rendu par défaut
- Toutes les variantes (primary, success, warning, error, etc.)
- Différentes tailles (sm, md, lg, etc.)
- États interactifs (hover, focus, active, disabled)

### 5.2 Scénarios de thème
- Mode clair vs mode sombre
- Transition entre thèmes
- Thèmes personnalisés

### 5.3 Scénarios d'accessibilité
- Contraste des couleurs
- Navigation au clavier
- Compatibilité avec les lecteurs d'écran

### 5.4 Scénarios de performance
- Temps de chargement initial
- Temps de transition entre thèmes
- Re-rendus lors des changements d'état

## 6. Capture d'écrans avant/après

Pour chaque composant, des captures d'écran seront prises avant et après la migration pour documenter les changements visuels:

```
lyxalsuite/
└── lyxalkitui/
    └── docs/
        └── screenshots/
            ├── before/
            │   ├── badge-default-light.png
            │   ├── badge-default-dark.png
            │   └── ...
            └── after/
                ├── badge-default-light.png
                ├── badge-default-dark.png
                └── ...
```

## 7. Instructions d'utilisation

1. Lancer l'environnement de test:
   ```bash
   cd lyxalsuite/lyxalkitui/test-environment
   npm run dev
   ```

2. Accéder à l'interface via le navigateur à l'adresse http://localhost:5173/

3. Sélectionner un composant dans la barre latérale

4. Comparer les versions avant/après pour différentes variantes et états

5. Basculer entre les thèmes pour vérifier la compatibilité

6. Prendre des captures d'écran pour la documentation

## 8. Automatisation des tests

Des tests automatisés seront également mis en place pour vérifier:

1. **Tests visuels**: Comparaison automatique des rendus avant/après
2. **Tests de contraste**: Vérification des ratios de contraste WCAG
3. **Tests de compatibilité**: Vérification sur différents navigateurs

Ces tests seront intégrés dans le pipeline CI/CD pour assurer la qualité continue du système de thème. 