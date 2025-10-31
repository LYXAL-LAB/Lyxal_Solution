# Guide d'accessibilité pour le système de thème LyxalKitUI

Ce guide présente les meilleures pratiques et les implémentations recommandées pour assurer que le système de thème LyxalKitUI est accessible à tous les utilisateurs, conformément aux standards WCAG (Web Content Accessibility Guidelines).

## Importance de l'accessibilité

Un système de thème accessible garantit que les applications sont utilisables par tous, y compris les personnes ayant des handicaps visuels, moteurs ou cognitifs. L'accessibilité n'est pas seulement une bonne pratique, c'est également une obligation légale dans de nombreux contextes.

## Standards d'accessibilité à respecter

Le système de thème LyxalKitUI vise à se conformer aux standards WCAG 2.1 niveau AA, qui couvrent:

1. **Perceptibilité**: L'information et les composants de l'interface doivent être présentés de manière à ce que les utilisateurs puissent les percevoir.
2. **Utilisabilité**: Les composants de l'interface doivent être utilisables par tous.
3. **Compréhensibilité**: L'information et l'utilisation de l'interface doivent être compréhensibles.
4. **Robustesse**: Le contenu doit être suffisamment robuste pour être interprété par une large variété d'agents utilisateurs, y compris les technologies d'assistance.

## Contraste des couleurs

### Vérification automatique des contrastes

Le système de thème LyxalKitUI intègre une vérification automatique des contrastes de couleurs:

```typescript
// Fonction pour calculer le ratio de contraste entre deux couleurs
function calculateContrastRatio(foreground: string, background: string): number {
  const getLuminance = (color: string): number => {
    // Convertir la couleur hex en RGB
    const r = parseInt(color.substring(1, 3), 16) / 255;
    const g = parseInt(color.substring(3, 5), 16) / 255;
    const b = parseInt(color.substring(5, 7), 16) / 255;
    
    // Calculer la luminosité relative
    const luminance = 0.2126 * adjustGamma(r) + 0.7152 * adjustGamma(g) + 0.0722 * adjustGamma(b);
    return luminance;
  };
  
  const adjustGamma = (color: number): number => {
    return color <= 0.03928 ? color / 12.92 : Math.pow((color + 0.055) / 1.055, 2.4);
  };
  
  const luminance1 = getLuminance(foreground);
  const luminance2 = getLuminance(background);
  
  const ratio = (Math.max(luminance1, luminance2) + 0.05) / (Math.min(luminance1, luminance2) + 0.05);
  return parseFloat(ratio.toFixed(2));
}

// Vérifier si un thème respecte les contraintes WCAG
function validateThemeContrast(theme: ThemeDefinition): Array<{key: string, ratio: number, valid: boolean}> {
  const results = [];
  const colors = theme.colors || {};
  
  // Paires de couleurs à vérifier (premier plan / arrière-plan)
  const pairs = [
    { fg: 'primary-content', bg: 'primary' },
    { fg: 'secondary-content', bg: 'secondary' },
    { fg: 'accent-content', bg: 'accent' },
    { fg: 'base-content', bg: 'base-100' },
    { fg: 'neutral-content', bg: 'neutral' },
    { fg: 'info-content', bg: 'info' },
    { fg: 'success-content', bg: 'success' },
    { fg: 'warning-content', bg: 'warning' },
    { fg: 'error-content', bg: 'error' },
  ];
  
  // Vérifier chaque paire
  for (const pair of pairs) {
    if (colors[pair.fg] && colors[pair.bg]) {
      const ratio = calculateContrastRatio(colors[pair.fg], colors[pair.bg]);
      results.push({
        key: `${pair.fg} / ${pair.bg}`,
        ratio,
        valid: ratio >= 4.5 // WCAG AA pour le texte normal
      });
    }
  }
  
  return results;
}
```

### Interface utilisateur pour le contraste

Ajoutez une interface utilisateur pour visualiser et corriger les problèmes de contraste:

```tsx
import React from 'react';
import { ThemeDefinition } from 'lyxalkitui';

interface ContrastCheckerProps {
  theme: ThemeDefinition;
  onColorChange?: (key: string, value: string) => void;
}

const ContrastChecker: React.FC<ContrastCheckerProps> = ({ theme, onColorChange }) => {
  const contrastResults = validateThemeContrast(theme);
  
  return (
    <div className="contrast-checker">
      <h3>Vérification des contrastes WCAG</h3>
      
      <table>
        <thead>
          <tr>
            <th>Paire de couleurs</th>
            <th>Ratio</th>
            <th>Statut</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {contrastResults.map((result) => (
            <tr key={result.key}>
              <td>{result.key}</td>
              <td>{result.ratio}</td>
              <td>
                {result.valid ? (
                  <span className="valid">✓ Conforme</span>
                ) : (
                  <span className="invalid">✗ Non conforme</span>
                )}
              </td>
              <td>
                {!result.valid && onColorChange && (
                  <button onClick={() => suggestFixedColor(result.key, theme, onColorChange)}>
                    Suggérer une correction
                  </button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

// Fonction pour suggérer une correction de couleur
function suggestFixedColor(pairKey: string, theme: ThemeDefinition, onColorChange: (key: string, value: string) => void) {
  const [fg, bg] = pairKey.split(' / ');
  const fgColor = theme.colors?.[fg] || '';
  const bgColor = theme.colors?.[bg] || '';
  
  // Calculer une nouvelle couleur qui offre un meilleur contraste
  const adjustedColor = improveContrast(fgColor, bgColor);
  
  // Mettre à jour la couleur de premier plan
  onColorChange(fg, adjustedColor);
}

// Fonction pour améliorer le contraste entre deux couleurs
function improveContrast(foreground: string, background: string): string {
  // Logique pour ajuster la couleur pour un meilleur contraste
  // (voir l'implémentation complète dans le code source)
  
  return adjustedColor;
}
```

## Navigation au clavier

### Focus visible

Assurez-vous que les éléments interactifs ont un focus visible:

```css
/* Styles pour le focus visible */
:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Pour les éléments qui ont déjà une bordure */
button:focus, input:focus, select:focus, textarea:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
  border-color: var(--color-primary);
}
```

### Gestion du focus dans les interfaces de thème

Implémentez une gestion appropriée du focus dans les composants de thème:

```tsx
import React, { useRef, useEffect } from 'react';
import { ThemeDefinition } from 'lyxalkitui';

interface ThemeSwitcherProps {
  themes: ThemeDefinition[];
  onSelect: (themeId: string) => void;
  activeThemeId?: string;
}

const AccessibleThemeSwitcher: React.FC<ThemeSwitcherProps> = ({ 
  themes, 
  onSelect, 
  activeThemeId 
}) => {
  // Référence pour gérer le focus
  const themeButtonsRef = useRef<(HTMLButtonElement | null)[]>([]);
  
  // Gérer la navigation au clavier
  const handleKeyDown = (e: React.KeyboardEvent, index: number) => {
    switch (e.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        e.preventDefault();
        const nextIndex = (index + 1) % themes.length;
        themeButtonsRef.current[nextIndex]?.focus();
        break;
      case 'ArrowLeft':
      case 'ArrowUp':
        e.preventDefault();
        const prevIndex = (index - 1 + themes.length) % themes.length;
        themeButtonsRef.current[prevIndex]?.focus();
        break;
      default:
        break;
    }
  };
  
  return (
    <div 
      role="radiogroup" 
      aria-label="Sélectionnez un thème"
      className="theme-switcher"
    >
      {themes.map((theme, index) => (
        <button
          key={theme.id}
          ref={el => themeButtonsRef.current[index] = el}
          role="radio"
          aria-checked={theme.id === activeThemeId}
          onClick={() => onSelect(theme.id)}
          onKeyDown={(e) => handleKeyDown(e, index)}
          className={`theme-button ${theme.id === activeThemeId ? 'active' : ''}`}
        >
          <div className="theme-preview" 
            style={{ 
              backgroundColor: theme.colors?.['base-100'] || '#ffffff',
              color: theme.colors?.['base-content'] || '#000000',
            }}
          >
            <span className="visually-hidden">{theme.isDark ? 'Thème sombre' : 'Thème clair'}</span>
            {theme.name}
          </div>
        </button>
      ))}
    </div>
  );
};
```

## Support des lecteurs d'écran

### Attributs ARIA appropriés

Utilisez les attributs ARIA pour améliorer l'accessibilité:

```tsx
// Exemple pour ThemePreview
const ThemePreview: React.FC<ThemePreviewProps> = ({ theme, showComponents, size }) => {
  return (
    <div 
      className="theme-preview" 
      role="region" 
      aria-label={`Prévisualisation du thème ${theme.name}`}
    >
      {/* Contenus de la prévisualisation */}
      <div role="status" aria-live="polite" className="sr-only">
        Thème {theme.name} chargé pour prévisualisation
      </div>
    </div>
  );
};

// Exemple pour ThemeCreator
const ThemeCreator: React.FC<ThemeCreatorProps> = ({ onSave, onCancel, initialTheme }) => {
  return (
    <div 
      role="dialog" 
      aria-labelledby="theme-creator-title" 
      aria-describedby="theme-creator-description"
    >
      <h2 id="theme-creator-title">{initialTheme ? 'Modifier le thème' : 'Créer un nouveau thème'}</h2>
      <p id="theme-creator-description" className="sr-only">
        Formulaire pour {initialTheme ? 'modifier' : 'créer'} un thème. Utilisez les contrôles ci-dessous pour personnaliser les couleurs et autres propriétés.
      </p>
      
      {/* Reste du formulaire avec des labels appropriés */}
    </div>
  );
};
```

### Textes alternatifs pour les prévisualisations

Ajoutez des descriptions pour les prévisualisations de thème:

```tsx
const ThemePreview: React.FC<ThemePreviewProps> = ({ theme }) => {
  // Génération d'une description textuelle du thème
  const generateThemeDescription = (theme: ThemeDefinition): string => {
    const parts = [];
    
    parts.push(`Thème ${theme.name}, ${theme.isDark ? 'sombre' : 'clair'}.`);
    
    if (theme.colors) {
      parts.push(`Couleur primaire: ${theme.colors['primary'] || 'non définie'}.`);
      parts.push(`Couleur secondaire: ${theme.colors['secondary'] || 'non définie'}.`);
      // Autres couleurs importantes...
    }
    
    return parts.join(' ');
  };
  
  const themeDescription = generateThemeDescription(theme);
  
  return (
    <div className="theme-preview">
      {/* Rendu visuel */}
      <div className="theme-preview-visual">
        {/* Composants visuels */}
      </div>
      
      {/* Description accessible pour les lecteurs d'écran */}
      <div className="sr-only">{themeDescription}</div>
    </div>
  );
};
```

## Modes de contraste élevé

Supportez les modes de contraste élevé du système d'exploitation:

```css
/* Styles pour le mode de contraste élevé */
@media (forced-colors: active) {
  .theme-button {
    /* Utiliser les couleurs système */
    background-color: ButtonFace;
    color: ButtonText;
    border: 1px solid ButtonText;
  }
  
  .theme-button.active {
    background-color: Highlight;
    color: HighlightText;
  }
  
  /* Garantir que les éléments importants restent visibles */
  .preview-element {
    border: 1px solid;
  }
}
```

## Tests d'accessibilité

### Outils automatisés

Intégrez des tests d'accessibilité automatisés:

```typescript
// Exemple d'intégration avec axe-core pour les tests d'accessibilité
import { axe, toHaveNoViolations } from 'jest-axe';
import { render } from '@testing-library/react';
import { ThemeSwitcher } from './ThemeSwitcher';

// Étendre les matchers de Jest
expect.extend(toHaveNoViolations);

describe('ThemeSwitcher Accessibility', () => {
  it('should not have accessibility violations', async () => {
    const { container } = render(
      <ThemeSwitcher
        themes={[
          /* Thèmes de test */
        ]}
        onSelect={() => {}}
      />
    );
    
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

### Liste de vérification manuelle

Utilisez cette liste de vérification pour tester manuellement l'accessibilité:

1. **Navigation au clavier**:
   - Tous les contrôles peuvent-ils être atteints avec la touche Tab?
   - L'ordre de tabulation est-il logique?
   - Le focus est-il clairement visible?

2. **Lecteurs d'écran**:
   - Testez avec NVDA, JAWS ou VoiceOver
   - Les composants annoncent-ils correctement leur état et leur fonction?
   - Les changements de thème sont-ils annoncés?

3. **Contraste et lisibilité**:
   - Le texte est-il lisible sur tous les arrière-plans?
   - Les contrôles sont-ils suffisamment visibles?
   - Le thème fonctionne-t-il en mode zoom (200%+)?

4. **Modes de contraste élevé**:
   - Les composants restent-ils utilisables en mode de contraste élevé?

## Meilleures pratiques pour les développeurs

1. **Toujours fournir des labels explicites** pour les contrôles de thème.

2. **Tester avec différentes technologies d'assistance** pendant le développement.

3. **Intégrer les vérifications d'accessibilité** dans votre pipeline CI/CD.

4. **Documenter les considérations d'accessibilité** pour chaque composant.

5. **Consulter les utilisateurs ayant des besoins d'accessibilité** lors du développement.

## Ressources

- [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/)
- [WAI-ARIA Authoring Practices](https://www.w3.org/TR/wai-aria-practices-1.1/)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)
- [Web Accessibility Evaluation Tools](https://www.w3.org/WAI/ER/tools/) 