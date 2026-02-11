# 🔄 MAPPING VARIABLES CSS - ANCIEN → NOUVEAU

## 📊 CORRESPONDANCES DÉTAILLÉES

---

## 🎨 COULEURS PRINCIPALES

| DaisyUI | Nouveau Système | Valeur Light | Valeur Dark | Usage |
|---------|-----------------|--------------|-------------|-------|
| `--primary` | `--color-primary` | #3B82F6 | #60A5FA | Boutons principaux, liens |
| `--primary-focus` | `--color-primary-hover` | #2563EB | #3B82F6 | Hover/focus primary |
| `--primary-content` | `--color-on-primary` | #FFFFFF | #FFFFFF | Texte sur primary |
| `--secondary` | `--color-secondary` | #10B981 | #34D399 | Boutons secondaires |
| `--accent` | `--color-accent` | #F59E0B | #FBBF24 | Éléments spéciaux |

---

## 🎯 COULEURS D'ÉTAT

| DaisyUI | Nouveau Système | Usage |
|---------|-----------------|-------|
| `--success` | `--color-success` | Validations, succès |
| `--success-content` | `--color-on-success` | Texte sur success |
| `--warning` | `--color-warning` | Avertissements |
| `--warning-content` | `--color-on-warning` | Texte sur warning |
| `--error` | `--color-error` | Erreurs, validations |
| `--error-content` | `--color-on-error` | Texte sur error |
| `--info` | `--color-info` | Informations |

---

## 🏠 COULEURS DE SURFACE

| DaisyUI | Nouveau Système | Description |
|---------|-----------------|-------------|
| `--base-100` | `--color-surface` | Fond principal (cartes, modals) |
| `--base-200` | `--color-surface-variant` | Fond secondaire (menus, barres) |
| `--base-300` | `--color-outline` | Bordures, séparateurs |
| `--base-content` | `--color-on-surface` | Texte principal |
| `--neutral` | `--color-neutral` | Éléments neutres |
| `--neutral-content` | `--color-on-neutral` | Texte sur neutral |

---

## 📏 ESPACEMENT

| DaisyUI | Nouveau Système | Valeur (rem) | Valeur (px) |
|---------|-----------------|--------------|-------------|
| `--spacing * 1` | `--spacing-1` | 0.25 | 4 |
| `--spacing * 2` | `--spacing-2` | 0.5 | 8 |
| `--spacing * 3` | `--spacing-3` | 0.75 | 12 |
| `--spacing * 4` | `--spacing-4` | 1 | 16 |
| `--spacing * 6` | `--spacing-6` | 1.5 | 24 |
| `--spacing * 8` | `--spacing-8` | 2 | 32 |

---

## 🔲 FORMES ET BORDURES

| DaisyUI | Nouveau Système | Valeur |
|---------|-----------------|--------|
| `--border-radius` | `--border-radius` | 0.375rem (6px) |
| `--border-radius-sm` | `--border-radius-small` | 0.25rem (4px) |
| `--border-radius-lg` | `--border-radius-large` | 0.5rem (8px) |
| `--rounded-box` | `--border-radius` | Identique |
| `--rounded-btn` | `--border-radius` | Identique |

---

## 📖 TYPOGRAPHIE

| DaisyUI | Nouveau Système | Valeur |
|---------|-----------------|--------|
| `--font-family` | `--font-family-primary` | 'Inter', sans-serif |
| `--font-size` | `--font-size-base` | 1rem (16px) |
| `--line-height` | `--line-height` | 1.5 |
| `--font-weight` | `--font-weight-normal` | 400 |
| `--font-weight-semibold` | `--font-weight-medium` | 500 |

---

## 🎭 ÉTATS ET EFFETS

| DaisyUI | Nouveau Système | Description |
|---------|-----------------|-------------|
| `--shadow` | `--elevation-1` | Ombre légère |
| `--shadow-lg` | `--elevation-2` | Ombre moyenne |
| `--shadow-xl` | `--elevation-3` | Ombre forte |
| `hover:opacity-80` | `--state-hover-opacity` | 0.08 |
| `focus:opacity-100` | `--state-focus-opacity` | 0.12 |

---

## 🛠️ UTILISATION DANS LES COMPOSANTS

### Exemple : Bouton Primary
```css
/* Ancien (DaisyUI) */
.btn.btn-primary {
  background: var(--primary);
  color: var(--primary-content);
  border-radius: var(--border-radius);
  padding: calc(var(--spacing) * 3) calc(var(--spacing) * 4);
}

/* Nouveau système */
.btn-primary {
  background: var(--color-primary);
  color: var(--color-on-primary);
  border-radius: var(--border-radius);
  padding: var(--spacing-3) var(--spacing-4);
}
```

### Exemple : Surface (Carte)
```css
/* Ancien (DaisyUI) */
.card {
  background: var(--base-100);
  color: var(--base-content);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow);
}

/* Nouveau système */
.surface {
  background: var(--color-surface);
  color: var(--color-on-surface);
  border-radius: var(--border-radius);
  box-shadow: var(--elevation-1);
}
```

---

## 📋 PLAN DE MIGRATION

### Phase 1 : Variables de Base (1 semaine)
```css
/* Priorité 1 : Couleurs essentielles */
--color-primary: #3B82F6;
--color-on-primary: #FFFFFF;
--color-surface: #FFFFFF;
--color-on-surface: #0F172A;

/* Priorité 2 : Espacement */
--spacing-1: 0.25rem;
--spacing-2: 0.5rem;
--spacing-3: 0.75rem;
--spacing-4: 1rem;

/* Priorité 3 : Formes */
--border-radius: 0.375rem;
--elevation-1: 0 1px 3px rgba(0,0,0,0.1);
```

### Phase 2 : Variables Avancées (1 semaine)
```css
/* États et feedback */
--color-success: #22C55E;
--color-error: #EF4444;
--state-hover-opacity: 0.08;

/* Typographie étendue */
--font-size-sm: 0.875rem;
--font-size-lg: 1.125rem;
--font-weight-medium: 500;

/* Élévation complète */
--elevation-2: 0 4px 6px rgba(0,0,0,0.1);
--elevation-3: 0 10px 15px rgba(0,0,0,0.1);
```

### Phase 3 : Variables Spécialisées (1 semaine)
```css
/* Composants spécifiques */
--btn-padding-x: var(--spacing-4);
--btn-padding-y: var(--spacing-2);
--input-height: 2.5rem;
--card-padding: var(--spacing-6);

/* Thèmes spécialisés */
--color-surface-variant: #F8FAFC;
--color-outline: #E2E8F0;
```

---

## ✅ TESTS DE VALIDATION

### Test 1 : Compatibilité Visuelle
```css
/* Vérifier que ces mappings produisent le même résultat */
.btn-primary { /* DaisyUI vs Nouveau système */ }
.card { /* DaisyUI vs Nouveau système */ }
.input { /* DaisyUI vs Nouveau système */ }
```

### Test 2 : Performance
```css
/* Mesurer la taille du bundle CSS */
/* Mesurer le temps de chargement des thèmes */
/* Mesurer les performances de rendu */
```

### Test 3 : Thèmes
```css
/* Tester le changement de thème light ↔ dark */
/* Tester les overrides personnalisés */
/* Tester les thèmes spécialisés */
```

---

## 🎯 BÉNÉFICES ATTENDUS

### Maintenance
- ✅ **Nommage cohérent** : `color-*`, `spacing-*`, `border-*`
- ✅ **Hiérarchie claire** : Variables organisées par domaine
- ✅ **Évolutivité** : Ajout facile de nouvelles variables

### Performance
- ✅ **Bundle optimisé** : Variables utilisées uniquement
- ✅ **Cache efficace** : Variables statiques
- ✅ **Thèmes rapides** : Changement instantané

### Flexibilité
- ✅ **Personnalisation** : Overrides par tenant faciles
- ✅ **Évolution** : Nouveaux thèmes sans breaking changes
- ✅ **Consistency** : Variables centralisées

---

## 📊 MÉTRIQUES DE SUCCÈS

- **Couverture** : 100% des variables DaisyUI mappées
- **Performance** : Pas de régression vs DaisyUI
- **Maintenabilité** : Code plus lisible et organisé
- **Flexibilité** : Personnalisation White-Label facilitée

---

*Date de création : [DATE]*
*Responsable : [VOTRE NOM]*
