# ⚙️ AUDIT CLASSES - UTILITAIRES

## 📊 CLASSES UTILITAIRES DAISYUI UTILISÉES

---

## 🎯 CLASSES IDENTIFIÉES

### Couleurs de Fond
- **`bg-base-100`** : Fond principal (blanc en light, sombre en dark)
- **`bg-base-200`** : Fond secondaire (gris clair en light)
- **`bg-base-300`** : Fond tertiaire
- **`bg-primary`** : Fond couleur primaire
- **`bg-secondary`** : Fond couleur secondaire
- **`bg-accent`** : Fond couleur accent
- **`bg-neutral`** : Fond neutre

### États et Feedback
- **`loading`** : Spinner de chargement
- **`skeleton`** : Placeholder de chargement
- **`placeholder`** : Texte placeholder stylisé
- **`badge`** : Badge/pastille d'information

### Animations
- **`animate-pulse`** : Pulsation (skeleton loading)
- **`animate-bounce`** : Rebond (notifications)
- **`animate-spin`** : Rotation (loading)

### Espacement et Layout
- **`space-y-4`** : Espacement vertical 1rem
- **`space-x-4`** : Espacement horizontal 1rem
- **`gap-4`** : Écart dans grids/flex
- **`p-4`** : Padding 1rem
- **`m-4`** : Margin 1rem

### Bordures et Arrondis
- **`rounded-box`** : Bordures arrondies standard
- **`rounded-btn`** : Arrondis boutons
- **`border`** : Bordure simple
- **`border-base-300`** : Bordure couleur thème

### Ombres
- **`shadow`** : Ombre légère
- **`shadow-xl`** : Ombre forte
- **`shadow-2xl`** : Ombre très forte

### Tailles
- **`w-56`** : Largeur 14rem (224px)
- **`h-8`** : Hauteur 2rem (32px)
- **`min-h-[200px]`** : Hauteur minimale 200px

---

## 📈 ANALYSE D'USAGE

### Fréquence d'Usage (Estimée)
- **`bg-base-100`** / **`bg-base-200`** : 80% (fonds principaux)
- **`loading`** : 25% (états de chargement)
- **`space-y-4`** / **`p-4`** : 70% (espacement)
- **`rounded-box`** : 60% (arrondis)
- **`shadow`** / **`shadow-xl`** : 40% (ombres)
- **`w-56`** / **`h-8`** : 30% (dimensions fixes)

### Contextes d'Usage
- **Fonds** : `bg-base-100` (cartes, modals)
- **Chargement** : `loading` (boutons, pages)
- **Espacement** : `space-y-4 p-4` (layout)
- **Dimensions** : `w-56 h-8` (menus, icones)
- **Effets** : `shadow-xl rounded-box` (élévation)

---

## 🎨 VARIABLES CSS ASSOCIÉES

### Couleurs
- `--base-100` : Fond principal
- `--base-200` : Fond secondaire
- `--base-300` : Fond tertiaire
- `--base-content` : Texte sur base

### Espacement
- `--spacing` : Unité de base (0.25rem)
- `--padding` : Padding standard
- `--margin` : Margin standard

### Dimensions
- `--border-radius` : Arrondis standard
- `--shadow` : Ombre standard
- `--blur` : Flou pour effets

---

## 🔄 ÉQUIVALENTS DANS NOUVEAU SYSTÈME

### Mapping Proposé
```css
/* Ancien DaisyUI */
.space-y-4 > * + * { margin-top: 1rem; }
.bg-base-100 { background: var(--base-100); }
.rounded-box { border-radius: var(--rounded-box); }

/* Nouveau système */
.spacing-y-medium > * + * { margin-top: var(--spacing-4); }
.surface { background: var(--color-surface); }
.rounded { border-radius: var(--border-radius); }
```

### Variables à Créer
```css
/* Espacement */
--spacing-1: 0.25rem;   /* 4px */
--spacing-2: 0.5rem;    /* 8px */
--spacing-3: 0.75rem;   /* 12px */
--spacing-4: 1rem;      /* 16px */
--spacing-6: 1.5rem;    /* 24px */
--spacing-8: 2rem;      /* 32px */

/* Couleurs */
--color-surface: #FFFFFF;           /* light theme */
--color-surface-variant: #F8FAFC;   /* light theme */
--color-on-surface: #0F172A;        /* light theme */

/* Formes */
--border-radius: 0.375rem;          /* 6px */
--border-radius-large: 0.5rem;      /* 8px */

/* Élévation */
--elevation-1: 0 1px 3px rgba(0,0,0,0.1);
--elevation-2: 0 4px 6px rgba(0,0,0,0.1);
--elevation-3: 0 10px 15px rgba(0,0,0,0.1);
```

---

## 📋 OBSERVATIONS

### Points Forts
- **Utilitaires complets** : Couleurs, espacement, effets
- **Cohérence** : Système unifié
- **Performance** : Classes CSS optimisées
- **Flexibilité** : Combinaisons possibles

### Points d'Amélioration
- **Nommage arbitraire** : `base-100`, `w-56` pas sémantique
- **Dépendance thème** : Couleurs liées au thème actif
- **Limites responsive** : Peu de variantes mobile/desktop

---

## 🎯 RECOMMANDATIONS

### Priorité de Migration
1. **Couleurs** (`bg-base-100`, `bg-primary`) : Usage omniprésent
2. **Espacement** (`space-y-4`, `p-4`) : Layout essentiel
3. **Formes** (`rounded-box`, `shadow`) : Apparence visuelle
4. **Dimensions** (`w-56`, `h-8`) : Tailles spécifiques
5. **États** (`loading`, `skeleton`) : UX important

### Évolutions Possibles
- **Nommage sémantique** : `surface`, `on-surface`, `primary`
- **Responsive** : `spacing-y-medium@mobile`
- **Thèmes spécialisés** : `surface-success`, `surface-warning`
- **Animations étendues** : fade, slide, scale

---

*Date d'audit : [DATE]*
*Responsable : [VOTRE NOM]*
