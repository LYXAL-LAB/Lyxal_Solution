# 📝 AUDIT CLASSES - FORMULAIRES

## 📊 CLASSES FORMULAIRES DAISYUI UTILISÉES

---

## 🎯 CLASSES IDENTIFIÉES

### Inputs
- **`input`** : Classe de base pour tous les inputs
- **`input-bordered`** : Style avec bordure (défaut)
- **`input-ghost`** : Style fantôme (transparent)
- **`input-primary`** : Style couleur primaire
- **`input-secondary`** : Style couleur secondaire
- **`input-success`** : Style succès (vert)
- **`input-warning`** : Style avertissement (jaune)
- **`input-error`** : Style erreur (rouge)

### Textareas
- **`textarea`** : Classe de base pour les textareas
- **`textarea-bordered`** : Style avec bordure (défaut)
- **`textarea-ghost`** : Style fantôme (transparent)

### Labels
- **`label`** : Classe de base pour les labels
- **`label-text`** : Texte du label (couleur par défaut)

### Form Controls
- **`form-control`** : Conteneur pour champ + label
- **`input-group`** : Groupe d'inputs (préfixes/suffixes)

### États
- **`input-disabled`** : État désactivé
- **`input-focus`** : État focus (automatique)

---

## 📈 ANALYSE D'USAGE

### Fréquence d'Usage (Estimée)
- **`input`** + **`input-bordered`** : 90% (champs standards)
- **`textarea`** + **`textarea-bordered`** : 30% (zones de texte)
- **`label`** : 95% (tous les champs)
- **`form-control`** : 85% (structure formulaire)
- **`input-success`** / **`input-error`** : 15% chacun (validation)

### Contextes d'Usage
- **Champs requis** : `input input-bordered`
- **Validation** : `input input-bordered input-success` / `input-error`
- **Labels** : `label` + `label-text`
- **Structure** : `form-control` (label + input)

---

## 🎨 VARIABLES CSS ASSOCIÉES

### Dimensions
- `--input-height` : Hauteur des inputs
- `--input-padding-x` : Padding horizontal
- `--input-padding-y` : Padding vertical
- `--input-border-radius` : Arrondis des bordures

### Couleurs
- `--input-bg` : Couleur de fond
- `--input-text` : Couleur du texte
- `--input-border` : Couleur de bordure
- `--input-focus-border` : Couleur bordure focus
- `--input-placeholder` : Couleur placeholder

### États
- `--input-disabled-bg` : Fond état désactivé
- `--input-disabled-text` : Texte état désactivé
- `--input-success-border` : Bordure état succès
- `--input-error-border` : Bordure état erreur

---

## 🔄 ÉQUIVALENTS DANS NOUVEAU SYSTÈME

### Mapping Proposé
```css
/* Ancien DaisyUI */
.input.input-bordered { border: 1px solid var(--base-content); }

/* Nouveau système */
.input { border: 1px solid var(--color-outline); }
.input:focus { border-color: var(--color-primary); }
.input.error { border-color: var(--color-error); }
```

### Variables à Créer
```css
--input-height: 2.5rem;
--input-padding: var(--spacing-3);
--input-border-radius: var(--border-radius);
--input-border-color: var(--color-outline);
--input-bg: var(--color-surface);
--input-text: var(--color-on-surface);
--input-focus-border: var(--color-primary);
--input-error-border: var(--color-error);
--input-success-border: var(--color-success);
```

---

## 📋 OBSERVATIONS

### Points Forts
- **Validation visuelle** : États success/error clairs
- **Focus accessible** : Indicateurs visuels automatiques
- **Cohérence** : Apparence uniforme

### Points d'Amélioration
- **Personnalisation limitée** : Couleurs fixes par thème
- **Taille fixe** : Une seule hauteur standard
- **États limités** : Seulement success/error/warning

---

## 🎯 RECOMMANDATIONS

### Priorité de Migration
1. **`input`** + **`input-bordered`** + **`label`** (usage principal)
2. **`textarea`** + **`textarea-bordered`** (usage fréquent)
3. **`form-control`** (structure essentielle)
4. États (`success`, `error`) (UX important)

### Évolutions Possibles
- **Tailles multiples** : sm, lg, xl
- **Nouveaux états** : info, neutral
- **Variants** : rounded, square
- **Animations** : transitions smooth

---

*Date d'audit : [DATE]*
*Responsable : [VOTRE NOM]*
