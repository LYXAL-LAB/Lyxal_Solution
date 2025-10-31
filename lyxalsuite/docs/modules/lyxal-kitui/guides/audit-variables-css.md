# Audit des variables CSS

Ce document recense toutes les variables CSS personnalisées utilisées dans les composants LyxalKitUI et propose une correspondance avec le nouveau système de thème.

## Variables globales identifiées

### Couleurs de base

| Variable actuelle      | Description                 | Variable du système de thème  |
|------------------------|-----------------------------|------------------------------|
| `--color-bg`           | Couleur de fond principale  | `--color-base-100`           |
| `--color-bg-subtle`    | Couleur de fond secondaire  | `--color-base-200`           |
| `--color-bg-hover`     | Couleur de fond au survol   | `--color-base-300`           |
| `--color-text`         | Couleur de texte principale | `--color-base-content`       |
| `--color-text-muted`   | Couleur de texte secondaire | `--color-base-content-muted` |
| `--color-border`       | Couleur de bordure standard | `--color-base-300`           |
| `--color-border-hover` | Couleur de bordure au survol| `--color-base-400`           |

### Couleurs thématiques

| Variable actuelle       | Description               | Variable du système de thème   |
|-------------------------|---------------------------|-------------------------------|
| `--color-primary`       | Couleur principale        | `--color-primary`             |
| `--color-primary-hover` | Couleur principale survol | `--color-primary-focus`       |
| `--color-primary-dark`  | Couleur principale foncée | `--color-primary-dark`        |
| `--color-success`       | Couleur de succès         | `--color-success`             |
| `--color-success-hover` | Couleur succès au survol  | `--color-success-focus`       |
| `--color-warning`       | Couleur d'avertissement   | `--color-warning`             |
| `--color-warning-hover` | Couleur avert. au survol  | `--color-warning-focus`       |
| `--color-error`         | Couleur d'erreur          | `--color-error`               |
| `--color-error-hover`   | Couleur erreur au survol  | `--color-error-focus`         |
| `--color-info`          | Couleur d'information     | `--color-info`                |
| `--color-info-hover`    | Couleur info au survol    | `--color-info-focus`          |

### Typographie

| Variable actuelle        | Description               | Variable du système de thème   |
|--------------------------|---------------------------|-------------------------------|
| `--font-family`          | Police principale         | `--font-family`               |
| `--font-family-heading`  | Police pour titres        | `--font-family-heading`       |
| `--font-family-mono`     | Police monospace          | `--font-family-mono`          |
| `--font-size-xs`         | Taille de texte très petit| `--font-size-xs`              |
| `--font-size-sm`         | Taille de texte petit     | `--font-size-sm`              |
| `--font-size-md`         | Taille de texte moyenne   | `--font-size-base`            |
| `--font-size-lg`         | Taille de texte grande    | `--font-size-lg`              |
| `--font-size-xl`         | Taille de texte très grand| `--font-size-xl`              |
| `--font-weight-normal`   | Graisse normale           | `--font-weight-normal`        |
| `--font-weight-medium`   | Graisse moyenne           | `--font-weight-medium`        |
| `--font-weight-bold`     | Graisse forte             | `--font-weight-bold`          |

### Espacements et tailles

| Variable actuelle     | Description                | Variable du système de thème |
|-----------------------|----------------------------|-----------------------------|
| `--spacing-xs`        | Espacement très petit      | `--spacing-1`               |
| `--spacing-sm`        | Espacement petit           | `--spacing-2`               |
| `--spacing-md`        | Espacement moyen           | `--spacing-4`               |
| `--spacing-lg`        | Espacement grand           | `--spacing-6`               |
| `--spacing-xl`        | Espacement très grand      | `--spacing-8`               |
| `--border-radius-sm`  | Rayon de bordure petit     | `--radius-sm`               |
| `--border-radius`     | Rayon de bordure standard  | `--radius-box`              |
| `--border-radius-lg`  | Rayon de bordure grand     | `--radius-lg`               |
| `--border-radius-full`| Rayon de bordure circulaire| `--radius-full`             |

### Effets

| Variable actuelle    | Description          | Variable du système de thème |
|----------------------|----------------------|-----------------------------|
| `--shadow-sm`        | Ombre légère         | `--shadow-sm`               |
| `--shadow-md`        | Ombre moyenne        | `--shadow-md`               |
| `--shadow-lg`        | Ombre prononcée      | `--shadow-lg`               |
| `--transition-fast`  | Transition rapide    | `--transition-fast`         |
| `--transition-normal`| Transition normale   | `--transition-normal`       |
| `--transition-slow`  | Transition lente     | `--transition-slow`         |

## Variables spécifiques aux composants

### Badge

| Variable actuelle                  | Description                    | Variable du système de thème      |
|------------------------------------|--------------------------------|----------------------------------|
| `--badge-bg`                       | Fond du badge                  | `--color-base-200`                |
| `--badge-text`                     | Texte du badge                 | `--color-base-content`            |
| `--badge-primary-bg`               | Fond du badge primaire         | `--color-primary`                 |
| `--badge-primary-text`             | Texte du badge primaire        | `--color-primary-content`         |
| `--badge-success-bg`               | Fond du badge succès           | `--color-success`                 |
| `--badge-success-text`             | Texte du badge succès          | `--color-success-content`         |

### Alert

| Variable actuelle                  | Description                    | Variable du système de thème      |
|------------------------------------|--------------------------------|----------------------------------|
| `--alert-bg`                       | Fond de l'alerte standard      | `--color-base-200`                |
| `--alert-text`                     | Texte de l'alerte standard     | `--color-base-content`            |
| `--alert-border`                   | Bordure de l'alerte standard   | `--color-base-300`                |
| `--alert-info-bg`                  | Fond de l'alerte info          | `--color-info-light`              |
| `--alert-info-text`                | Texte de l'alerte info         | `--color-info`                    |
| `--alert-info-border`              | Bordure de l'alerte info       | `--color-info`                    |
| `--alert-success-bg`               | Fond de l'alerte succès        | `--color-success-light`           |
| `--alert-success-text`             | Texte de l'alerte succès       | `--color-success`                 |
| `--alert-success-border`           | Bordure de l'alerte succès     | `--color-success`                 |
| `--alert-warning-bg`               | Fond de l'alerte avertissement | `--color-warning-light`           |
| `--alert-warning-text`             | Texte de l'alerte avertissement| `--color-warning`                 |
| `--alert-warning-border`           | Bordure de l'alerte avert.     | `--color-warning`                 |
| `--alert-error-bg`                 | Fond de l'alerte erreur        | `--color-error-light`             |
| `--alert-error-text`               | Texte de l'alerte erreur       | `--color-error`                   |
| `--alert-error-border`             | Bordure de l'alerte erreur     | `--color-error`                   |

### Card

| Variable actuelle                  | Description                    | Variable du système de thème      |
|------------------------------------|--------------------------------|----------------------------------|
| `--card-bg`                        | Fond de la carte               | `--color-base-100`                |
| `--card-text`                      | Texte de la carte              | `--color-base-content`            |
| `--card-border`                    | Bordure de la carte            | `--color-base-300`                |
| `--card-shadow`                    | Ombre de la carte              | `--shadow-md`                     |
| `--card-radius`                    | Rayon de la carte              | `--radius-box`                    |
| `--card-header-bg`                 | Fond de l'en-tête de carte     | `--color-base-200`                |
| `--card-header-text`               | Texte de l'en-tête de carte    | `--color-base-content`            |
| `--card-footer-bg`                 | Fond du pied de carte          | `--color-base-200`                |
| `--card-footer-text`               | Texte du pied de carte         | `--color-base-content`            |

### Button

| Variable actuelle                  | Description                    | Variable du système de thème      |
|------------------------------------|--------------------------------|----------------------------------|
| `--button-bg`                      | Fond du bouton standard        | `--color-base-300`                |
| `--button-text`                    | Texte du bouton standard       | `--color-base-content`            |
| `--button-border`                  | Bordure du bouton standard     | `--color-base-400`                |
| `--button-hover-bg`                | Fond du bouton au survol       | `--color-base-400`                |
| `--button-hover-text`              | Texte du bouton au survol      | `--color-base-content`            |
| `--button-hover-border`            | Bordure du bouton au survol    | `--color-base-500`                |
| `--button-primary-bg`              | Fond du bouton primaire        | `--color-primary`                 |
| `--button-primary-text`            | Texte du bouton primaire       | `--color-primary-content`         |
| `--button-primary-border`          | Bordure du bouton primaire     | `--color-primary`                 |
| `--button-primary-hover-bg`        | Fond du bouton primaire survol | `--color-primary-focus`           |
| `--button-primary-hover-text`      | Texte du bouton primaire survol| `--color-primary-content`         |
| `--button-primary-hover-border`    | Bordure bouton primaire survol | `--color-primary-focus`           |

## Cas particuliers et exceptions

### Mode sombre

De nombreux composants utilisent actuellement des règles spécifiques pour le mode sombre avec le sélecteur `[data-theme="dark"]`. Ces règles doivent être remplacées par des variables adaptatives.

Exemple actuel:
```css
.badge {
  background-color: var(--badge-bg);
  color: var(--badge-text);
}

[data-theme="dark"] .badge {
  background-color: #333;
  color: #fff;
}
```

Solution avec le nouveau système:
```css
.badge {
  background-color: var(--color-base-200);
  color: var(--color-base-content);
}
```

### Variables dépendantes

Certaines variables sont définies à partir d'autres variables, créant une dépendance:

```css
:root {
  --color-primary: #3b82f6;
  --color-primary-dark: color-mix(in srgb, var(--color-primary), #000 20%);
  --color-primary-hover: var(--color-primary-dark);
}
```

Dans le nouveau système, ces dépendances sont gérées automatiquement par le système de thème.

### Opacités et variations

Plusieurs composants utilisent des variations de couleurs avec opacité:

```css
.tooltip {
  background-color: rgba(var(--color-text-rgb), 0.9);
}
```

Dans le nouveau système, on utilisera les variations prédéfinies ou la fonction `color-mix`:

```css
.tooltip {
  background-color: var(--color-base-content);
}
```

## Recommandations pour la migration

1. **Approche progressive**: Remplacer d'abord les variables globales dans les fichiers de thème
2. **Composants prioritaires**: Commencer par les composants de priorité haute
3. **Tests continus**: Vérifier visuellement chaque composant après modification
4. **Documentation**: Documenter chaque changement pour faciliter la maintenance
5. **Compatibilité**: Prévoir une période de transition avec support des anciennes variables 