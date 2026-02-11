# Migration des variables CSS globales

Ce document détaille la standardisation des variables CSS globales pour la migration vers le nouveau système de thème LyxalKitUI.

## Objectif

Remplacer toutes les variables CSS globales actuelles par les nouvelles variables du système de thème, en assurant une transition cohérente et sans rupture visuelle.

## Fichier de variables global

Le fichier principal de variables CSS sera mis à jour comme suit:

```css
/* theme-variables.css - AVANT */
:root {
  /* Couleurs de base */
  --color-bg: #ffffff;
  --color-bg-subtle: #f9fafb;
  --color-bg-hover: #f3f4f6;
  --color-text: #1f2937;
  --color-text-muted: #6b7280;
  --color-border: #e5e7eb;
  --color-border-hover: #d1d5db;
  
  /* Couleurs thématiques */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-primary-dark: #1d4ed8;
  --color-success: #10b981;
  --color-success-hover: #059669;
  --color-warning: #f59e0b;
  --color-warning-hover: #d97706;
  --color-error: #ef4444;
  --color-error-hover: #dc2626;
  --color-info: #3b82f6;
  --color-info-hover: #2563eb;
  
  /* Typographie */
  --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-family-heading: var(--font-family);
  --font-family-mono: 'Fira Code', 'Consolas', monospace;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-md: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-bold: 700;
  
  /* Espacements et tailles */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
  --border-radius-sm: 0.25rem;
  --border-radius: 0.375rem;
  --border-radius-lg: 0.5rem;
  --border-radius-full: 9999px;
  
  /* Effets */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  --transition-fast: 150ms;
  --transition-normal: 250ms;
  --transition-slow: 350ms;
}

/* Mode sombre */
[data-theme="dark"] {
  --color-bg: #111827;
  --color-bg-subtle: #1f2937;
  --color-bg-hover: #374151;
  --color-text: #f9fafb;
  --color-text-muted: #9ca3af;
  --color-border: #374151;
  --color-border-hover: #4b5563;
  
  /* Les couleurs thématiques peuvent rester identiques ou être ajustées pour le mode sombre */
}
```

```css
/* theme-variables.css - APRÈS */
:root {
  /* Couleurs de base */
  --color-base-50: #f9fafb;
  --color-base-100: #ffffff;
  --color-base-200: #f3f4f6;
  --color-base-300: #e5e7eb;
  --color-base-400: #d1d5db;
  --color-base-500: #9ca3af;
  --color-base-600: #6b7280;
  --color-base-700: #4b5563;
  --color-base-800: #374151;
  --color-base-900: #1f2937;
  --color-base-950: #111827;
  
  --color-base-content: var(--color-base-900);
  --color-base-content-muted: var(--color-base-600);
  
  /* Couleurs thématiques - Primary */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-200: #bfdbfe;
  --color-primary-300: #93c5fd;
  --color-primary-400: #60a5fa;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  --color-primary-800: #1e40af;
  --color-primary-900: #1e3a8a;
  --color-primary-950: #172554;
  
  --color-primary: var(--color-primary-500);
  --color-primary-focus: var(--color-primary-600);
  --color-primary-content: #ffffff;
  
  /* Couleurs thématiques - Success */
  --color-success-50: #ecfdf5;
  --color-success-100: #d1fae5;
  --color-success-200: #a7f3d0;
  --color-success-300: #6ee7b7;
  --color-success-400: #34d399;
  --color-success-500: #10b981;
  --color-success-600: #059669;
  --color-success-700: #047857;
  --color-success-800: #065f46;
  --color-success-900: #064e3b;
  --color-success-950: #022c22;
  
  --color-success: var(--color-success-500);
  --color-success-focus: var(--color-success-600);
  --color-success-content: #ffffff;
  
  /* Couleurs thématiques - Warning */
  --color-warning-50: #fffbeb;
  --color-warning-100: #fef3c7;
  --color-warning-200: #fde68a;
  --color-warning-300: #fcd34d;
  --color-warning-400: #fbbf24;
  --color-warning-500: #f59e0b;
  --color-warning-600: #d97706;
  --color-warning-700: #b45309;
  --color-warning-800: #92400e;
  --color-warning-900: #78350f;
  --color-warning-950: #451a03;
  
  --color-warning: var(--color-warning-500);
  --color-warning-focus: var(--color-warning-600);
  --color-warning-content: #ffffff;
  
  /* Couleurs thématiques - Error */
  --color-error-50: #fef2f2;
  --color-error-100: #fee2e2;
  --color-error-200: #fecaca;
  --color-error-300: #fca5a5;
  --color-error-400: #f87171;
  --color-error-500: #ef4444;
  --color-error-600: #dc2626;
  --color-error-700: #b91c1c;
  --color-error-800: #991b1b;
  --color-error-900: #7f1d1d;
  --color-error-950: #450a0a;
  
  --color-error: var(--color-error-500);
  --color-error-focus: var(--color-error-600);
  --color-error-content: #ffffff;
  
  /* Couleurs thématiques - Info */
  --color-info-50: #eff6ff;
  --color-info-100: #dbeafe;
  --color-info-200: #bfdbfe;
  --color-info-300: #93c5fd;
  --color-info-400: #60a5fa;
  --color-info-500: #3b82f6;
  --color-info-600: #2563eb;
  --color-info-700: #1d4ed8;
  --color-info-800: #1e40af;
  --color-info-900: #1e3a8a;
  --color-info-950: #172554;
  
  --color-info: var(--color-info-500);
  --color-info-focus: var(--color-info-600);
  --color-info-content: #ffffff;
  
  /* Typographie */
  --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-family-heading: var(--font-family);
  --font-family-mono: 'Fira Code', 'Consolas', monospace;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-bold: 700;
  
  /* Espacements et tailles */
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  --spacing-5: 1.25rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
  --spacing-10: 2.5rem;
  --spacing-12: 3rem;
  --spacing-16: 4rem;
  
  /* Rayons de bordure */
  --radius-sm: 0.25rem;
  --radius-box: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-full: 9999px;
  
  /* Effets */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  --transition-fast: 150ms;
  --transition-normal: 250ms;
  --transition-slow: 350ms;
}

/* Mode sombre - définit automatiquement les variations de couleur */
[data-theme="dark"] {
  /* Couleurs de base */
  --color-base-50: #111827;
  --color-base-100: #1f2937;
  --color-base-200: #374151;
  --color-base-300: #4b5563;
  --color-base-400: #6b7280;
  --color-base-500: #9ca3af;
  --color-base-600: #d1d5db;
  --color-base-700: #e5e7eb;
  --color-base-800: #f3f4f6;
  --color-base-900: #f9fafb;
  --color-base-950: #ffffff;
  
  --color-base-content: var(--color-base-900);
  --color-base-content-muted: var(--color-base-700);
  
  /* Ombres plus subtiles pour le mode sombre */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.2), 0 2px 4px -1px rgba(0, 0, 0, 0.12);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.2), 0 4px 6px -2px rgba(0, 0, 0, 0.1);
}
```

## Fichier de transition pour assurer la compatibilité

Pour éviter les ruptures dans les applications existantes, nous créerons un fichier de transition qui maintient les anciennes variables tout en utilisant les nouvelles:

```css
/* transition.css */
:root {
  /* Compatibilité pour les anciennes variables */
  --color-bg: var(--color-base-100);
  --color-bg-subtle: var(--color-base-50);
  --color-bg-hover: var(--color-base-200);
  --color-text: var(--color-base-content);
  --color-text-muted: var(--color-base-content-muted);
  --color-border: var(--color-base-300);
  --color-border-hover: var(--color-base-400);
  
  --color-primary-hover: var(--color-primary-focus);
  --color-primary-dark: var(--color-primary-700);
  --color-success-hover: var(--color-success-focus);
  --color-warning-hover: var(--color-warning-focus);
  --color-error-hover: var(--color-error-focus);
  --color-info-hover: var(--color-info-focus);
  
  /* Compatibilité pour les espacements */
  --spacing-xs: var(--spacing-1);
  --spacing-sm: var(--spacing-2);
  --spacing-md: var(--spacing-4);
  --spacing-lg: var(--spacing-6);
  --spacing-xl: var(--spacing-8);
  
  /* Compatibilité pour les rayons */
  --border-radius-sm: var(--radius-sm);
  --border-radius: var(--radius-box);
  --border-radius-lg: var(--radius-lg);
  --border-radius-full: var(--radius-full);
  
  /* Compatibilité pour la taille de police */
  --font-size-md: var(--font-size-base);
}
```

## Approche pour la migration

1. **Méthode progressive**:
   - Mettre à jour d'abord les fichiers globaux de variables
   - Ajouter le fichier de transition pour maintenir la compatibilité
   - Mettre à jour progressivement les composants pour utiliser les nouvelles variables

2. **Ordre de migration**:
   ```
   1. Fichier de variables principales
   2. Fichier de transition
   3. Variables spécifiques aux composants prioritaires
   4. Variables pour les autres composants
   ```

3. **Impact sur les applications existantes**:
   - Pas de changement visuel grâce au fichier de transition
   - Les anciennes variables continueront de fonctionner
   - Les nouvelles applications peuvent utiliser directement les nouvelles variables

## Validation

Pour valider la migration des variables globales, nous effectuerons les tests suivants:

1. **Test visuel**: Vérifier que l'apparence des composants reste identique après la migration
2. **Test de cohérence**: S'assurer que toutes les anciennes variables ont un équivalent dans le nouveau système
3. **Test de thème**: Vérifier le comportement avec différents thèmes, y compris les thèmes personnalisés

## Exemple de remplacement pour un composant

Voici comment les variables seront remplacées dans un composant typique:

```css
/* Button.css - AVANT */
.button {
  background-color: var(--color-bg);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: var(--spacing-sm) var(--spacing-md);
  font-size: var(--font-size-md);
  transition: all var(--transition-fast);
}

.button:hover {
  background-color: var(--color-bg-hover);
  border-color: var(--color-border-hover);
}

.button-primary {
  background-color: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.button-primary:hover {
  background-color: var(--color-primary-hover);
  border-color: var(--color-primary-hover);
}
```

```css
/* Button.css - APRÈS */
.button {
  background-color: var(--color-base-100);
  color: var(--color-base-content);
  border: 1px solid var(--color-base-300);
  border-radius: var(--radius-box);
  padding: var(--spacing-2) var(--spacing-4);
  font-size: var(--font-size-base);
  transition: all var(--transition-fast);
}

.button:hover {
  background-color: var(--color-base-200);
  border-color: var(--color-base-400);
}

.button-primary {
  background-color: var(--color-primary);
  color: var(--color-primary-content);
  border-color: var(--color-primary);
}

.button-primary:hover {
  background-color: var(--color-primary-focus);
  border-color: var(--color-primary-focus);
}
```

## Prochaines étapes

1. Implémenter les fichiers de variables globales et de transition
2. Mettre à jour les composants prioritaires (Badge, Alert, Card)
3. Valider visuellement les changements
4. Documenter les nouvelles variables pour les développeurs 