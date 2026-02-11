# 🎨 AUDIT VARIABLES CSS - INVENTAIRE COMPLET

## 📊 VARIABLES DAISYUI UTILISÉES

---

## 🎯 VARIABLES IDENTIFIÉES

### Couleurs Principales
- **`--primary`** : Couleur principale (bleu par défaut)
- **`--primary-focus`** : Primary au focus (bleu plus foncé)
- **`--primary-content`** : Texte sur primary (blanc)
- **`--secondary`** : Couleur secondaire (gris/vert)
- **`--secondary-focus`** : Secondary au focus
- **`--secondary-content`** : Texte sur secondary
- **`--accent`** : Couleur accent (orange/violet)
- **`--accent-focus`** : Accent au focus
- **`--accent-content`** : Texte sur accent

### Couleurs d'État
- **`--success`** : Couleur succès (vert)
- **`--success-content`** : Texte sur success
- **`--warning`** : Couleur avertissement (jaune)
- **`--warning-content`** : Texte sur warning
- **`--error`** : Couleur erreur (rouge)
- **`--error-content`** : Texte sur error
- **`--info`** : Couleur info (bleu clair)
- **`--info-content`** : Texte sur info

### Couleurs Neutres/Base
- **`--base-100`** : Fond principal (blanc en light)
- **`--base-200`** : Fond secondaire (gris très clair)
- **`--base-300`** : Fond tertiaire (gris clair)
- **`--base-content`** : Texte sur base (noir/bleu foncé)
- **`--neutral`** : Couleur neutre (gris)
- **`--neutral-focus`** : Neutral au focus
- **`--neutral-content`** : Texte sur neutral

### Typographie
- **`--font-family`** : Police principale
- **`--font-size`** : Taille de base
- **`--line-height`** : Interligne de base
- **`--font-weight`** : Graisse normale
- **`--font-weight-semibold`** : Graisse semi-bold

### Dimensions et Espacement
- **`--spacing`** : Unité d'espacement de base (0.25rem)
- **`--border-radius`** : Arrondis par défaut
- **`--border-radius-sm`** : Arrondis petits
- **`--border-radius-lg`** : Arrondis grands

### Ombres et Effets
- **`--shadow`** : Ombre légère
- **`--shadow-lg`** : Ombre moyenne
- **`--shadow-xl`** : Ombre forte
- **`--blur`** : Flou pour effets

---

## 📈 ANALYSE D'USAGE

### Fréquence d'Usage (Estimée)
- **`--base-100`** / **`--base-200`** : 90% (fonds principaux)
- **`--primary`** : 70% (couleur principale)
- **`--base-content`** : 85% (texte principal)
- **`--success`** / **`--error`** : 30% chacun (états)
- **`--spacing`** : 60% (espacement)
- **`--border-radius`** : 50% (arrondis)

### Contextes d'Usage
- **Thèmes** : Toutes les variables changent par thème
- **Composants** : Utilisées dans les classes DaisyUI
- **Personnalisation** : Overrides possibles dans config

---

## 🔄 VALEURS PAR THÈME

### Thème Light (Exemple)
```css
--primary: #3B82F6;        /* Bleu */
--primary-focus: #2563EB;   /* Bleu foncé */
--primary-content: #FFFFFF; /* Blanc */

--base-100: #FFFFFF;       /* Blanc */
--base-200: #F8FAFC;       /* Gris très clair */
--base-content: #0F172A;   /* Bleu très foncé */

--success: #22C55E;        /* Vert */
--error: #EF4444;          /* Rouge */

--border-radius: 0.375rem; /* 6px */
--spacing: 0.25rem;        /* 4px */
```

### Thème Dark (Exemple)
```css
--primary: #60A5FA;        /* Bleu clair */
--primary-focus: #3B82F6;   /* Bleu */
--primary-content: #FFFFFF; /* Blanc */

--base-100: #0F172A;       /* Bleu très foncé */
--base-200: #1E293B;       /* Bleu foncé */
--base-content: #F8FAFC;   /* Blanc/gris clair */

--success: #34D399;        /* Vert clair */
--error: #F87171;          /* Rouge clair */
```

---

## 🎯 SYSTÈME DE VARIABLES RECOMMANDÉ

### Structure Organisée
```css
/* Nouveau système de variables */
:root {
  /* Palette de couleurs */
  --color-primary: #3B82F6;
  --color-primary-hover: #2563EB;
  --color-primary-light: #60A5FA;
  --color-on-primary: #FFFFFF;

  --color-surface: #FFFFFF;
  --color-surface-variant: #F8FAFC;
  --color-on-surface: #0F172A;
  --color-on-surface-variant: #64748B;

  --color-success: #22C55E;
  --color-on-success: #FFFFFF;
  --color-error: #EF4444;
  --color-on-error: #FFFFFF;

  /* Typographie */
  --font-family-primary: 'Inter', sans-serif;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --line-height: 1.5;

  /* Espacement */
  --spacing-1: 0.25rem;   /* 4px */
  --spacing-2: 0.5rem;    /* 8px */
  --spacing-3: 0.75rem;   /* 12px */
  --spacing-4: 1rem;      /* 16px */
  --spacing-6: 1.5rem;    /* 24px */
  --spacing-8: 2rem;      /* 32px */

  /* Formes */
  --border-radius: 0.375rem;        /* 6px */
  --border-radius-large: 0.5rem;    /* 8px */
  --border-radius-small: 0.25rem;   /* 4px */

  /* Élévation */
  --elevation-1: 0 1px 3px rgba(0,0,0,0.1);
  --elevation-2: 0 4px 6px rgba(0,0,0,0.1);
  --elevation-3: 0 10px 15px rgba(0,0,0,0.1);

  /* États */
  --state-hover-opacity: 0.08;
  --state-focus-opacity: 0.12;
  --state-pressed-opacity: 0.16;
}
```

### Avantages du Nouveau Système
- **Nommage sémantique** : `color-primary` vs `--primary`
- **Hiérarchie claire** : `color-`, `spacing-`, `border-radius-`
- **Complétude** : Toutes les valeurs nécessaires
- **Évolutivité** : Facilement extensible

---

## 📋 MAPPING ANCIEN → NOUVEAU

| Ancien DaisyUI | Nouveau Système | Description |
|----------------|-----------------|-------------|
| `--primary` | `--color-primary` | Couleur principale |
| `--base-100` | `--color-surface` | Fond principal |
| `--base-content` | `--color-on-surface` | Texte principal |
| `--success` | `--color-success` | Couleur succès |
| `--spacing` | `--spacing-1` | Unité d'espacement |
| `--border-radius` | `--border-radius` | Arrondis par défaut |
| `--shadow` | `--elevation-1` | Ombre légère |

---

## 🎯 RECOMMANDATIONS

### Migration Progressives
1. **Créer les nouvelles variables** en parallèle
2. **Mapper progressivement** les anciennes aux nouvelles
3. **Tester par composant** la compatibilité
4. **Supprimer les anciennes** une fois migration complète

### Variables Prioritaires
1. **Couleurs** (`color-primary`, `color-surface`, etc.)
2. **Espacement** (`spacing-1` à `spacing-8`)
3. **Formes** (`border-radius`, `elevation-1`)
4. **Typographie** (`font-size-base`, `font-weight-medium`)

---

## 📊 IMPACT ESTIMÉ

### Complexité : Moyenne
- **Variables à créer** : ~40 variables organisées
- **Mapping à faire** : Correspondance ancien/nouveau
- **Tests nécessaires** : Validation par thème et composant

### Bénéfices : Élevés
- **Maintenance** : Système cohérent et évolutif
- **Personnalisation** : Flexibilité maximale
- **Performance** : Optimisation des thèmes
- **Évolutivité** : Ajout facile de nouvelles variables

---

*Date d'audit : [DATE]*
*Responsable : [VOTRE NOM]*
