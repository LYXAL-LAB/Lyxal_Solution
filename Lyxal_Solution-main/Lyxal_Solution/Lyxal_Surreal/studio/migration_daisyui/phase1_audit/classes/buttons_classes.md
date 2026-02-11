# 🔘 AUDIT CLASSES - BOUTONS

## 📊 CLASSES BOUTONS DAISYUI UTILISÉES

---

## 🎯 CLASSES IDENTIFIÉES

### Classes de Base
- **`btn`** : Classe de base pour tous les boutons
- **`btn-primary`** : Style primaire (bleu)
- **`btn-secondary`** : Style secondaire (gris)
- **`btn-accent`** : Style accent (orange/violet)
- **`btn-success`** : Style succès (vert)
- **`btn-warning`** : Style avertissement (jaune)
- **`btn-error`** : Style erreur (rouge)

### Modificateurs de Taille
- **`btn-lg`** : Bouton large
- **`btn-md`** : Bouton moyen (défaut)
- **`btn-sm`** : Bouton petit
- **`btn-xs`** : Bouton extra petit

### Modificateurs d'État
- **`btn-active`** : État actif/pressé
- **`btn-disabled`** : État désactivé
- **`loading`** : État de chargement (spinner)

### Modificateurs de Style
- **`btn-outline`** : Style outline (bordure seulement)
- **`btn-ghost`** : Style fantôme (transparent)
- **`btn-link`** : Style lien (minimal)

---

## 📈 ANALYSE D'USAGE

### Fréquence d'Usage (Estimée)
- **`btn`** : 100% (tous les boutons)
- **`btn-primary`** : 70% (actions principales)
- **`btn-secondary`** : 20% (actions secondaires)
- **`btn-success`** / **`btn-error`** : 5% chacun (états)
- **`btn-lg`** : 30% (CTA, actions importantes)
- **`btn-sm`** : 20% (actions secondaires)
- **`loading`** : 10% (actions asynchrones)

### Contextes d'Usage
- **Actions principales** : `btn btn-primary btn-lg`
- **Actions secondaires** : `btn btn-secondary`
- **Validations** : `btn btn-success`
- **Annulations** : `btn btn-error`
- **Chargements** : `btn loading`

---

## 🎨 VARIABLES CSS ASSOCIÉES

### Couleurs
- `--btn-bg` : Couleur de fond
- `--btn-text` : Couleur du texte
- `--btn-border` : Couleur de bordure

### Dimensions
- `--btn-height` : Hauteur des boutons
- `--btn-padding-x` : Padding horizontal
- `--btn-padding-y` : Padding vertical

### Autres
- `--btn-font-weight` : Graisse du texte
- `--btn-border-radius` : Arrondis des bordures

---

## 🔄 ÉQUIVALENTS DANS NOUVEAU SYSTÈME

### Mapping Proposé
```css
/* Ancien DaisyUI */
.btn.btn-primary { background: var(--primary); }

/* Nouveau système */
.btn-primary { background: var(--color-primary); }
.btn-primary:hover { background: var(--color-primary-hover); }
.btn-large { padding: var(--spacing-large); }
```

### Variables à Créer
```css
--btn-primary-bg: var(--color-primary);
--btn-primary-text: var(--color-on-primary);
--btn-primary-hover: var(--color-primary-hover);
--btn-padding: var(--spacing-3) var(--spacing-4);
--btn-border-radius: var(--border-radius);
```

---

## 📋 OBSERVATIONS

### Points Forts
- **Cohérence** : Système uniforme
- **Flexibilité** : Modificateurs combinables
- **Accessibilité** : États visuels clairs

### Points d'Amélioration
- **Personnalisation limitée** : Seulement 7 couleurs de base
- **Taille fixe** : Seulement 4 tailles
- **Dépendance thème** : Couleurs liées au thème actif

---

## 🎯 RECOMMANDATIONS

### Priorité de Migration
1. **`btn`** + **`btn-primary`** (usage principal)
2. **`btn-secondary`** + **`btn-lg`** (usage fréquent)
3. États (`success`, `error`, `loading`) (UX important)
4. Styles alternatifs (`outline`, `ghost`) (usage moindre)

### Évolutions Possibles
- **Plus de couleurs** : warning, info, neutral
- **Plus de tailles** : xl, 2xl pour mobile
- **Nouveaux états** : focus, pressed
- **Variants** : rounded, square, pill

---

*Date d'audit : [DATE]*
*Responsable : [VOTRE NOM]*
