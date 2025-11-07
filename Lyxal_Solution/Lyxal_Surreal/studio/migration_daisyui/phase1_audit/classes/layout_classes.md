# 🏗️ AUDIT CLASSES - LAYOUT

## 📊 CLASSES LAYOUT DAISYUI UTILISÉES

---

## 🎯 CLASSES IDENTIFIÉES

### Cards
- **`card`** : Conteneur principal de carte
- **`card-body`** : Corps de la carte (padding, contenu)
- **`card-title`** : Titre de la carte
- **`card-actions`** : Zone d'actions de la carte

### Heroes
- **`hero`** : Section hero (bannière principale)
- **`hero-content`** : Contenu centré du hero
- **`hero-overlay`** : Overlay pour images de fond

### Menus
- **`menu`** : Conteneur de menu
- **`menu-title`** : Titre de section menu
- **`menu-item`** : Élément de menu individuel

### Modals/Dialogs
- **`modal`** : Conteneur modal
- **`modal-box`** : Contenu du modal
- **`modal-action`** : Zone d'actions du modal
- **`modal-backdrop`** : Fond du modal

### Navigation
- **`navbar`** : Barre de navigation
- **`navbar-start`** : Partie gauche navbar
- **`navbar-center`** : Partie centrale navbar
- **`navbar-end`** : Partie droite navbar

### Layout Utilities
- **`container`** : Conteneur centré responsive
- **`divider`** : Séparateur horizontal
- **`join`** : Grouper des éléments (boutons, etc.)

---

## 📈 ANALYSE D'USAGE

### Fréquence d'Usage (Estimée)
- **`card`** + **`card-body`** : 60% (widgets, panneaux)
- **`menu`** : 40% (navigation principale)
- **`hero`** : 20% (pages d'accueil, sections importantes)
- **`modal`** : 15% (dialogs, confirmations)
- **`navbar`** : 25% (en-têtes d'application)
- **`container`** : 35% (mise en page principale)

### Contextes d'Usage
- **Widgets dashboard** : `card card-body`
- **Navigation** : `menu` avec items
- **Modals** : `modal modal-box modal-backdrop`
- **Layout principal** : `hero` + `container`
- **Actions groupées** : `join` (boutons)

---

## 🎨 VARIABLES CSS ASSOCIÉES

### Cards
- `--card-bg` : Couleur de fond
- `--card-border-radius` : Arrondis des cartes
- `--card-shadow` : Ombre des cartes
- `--card-padding` : Padding interne

### Heroes
- `--hero-height` : Hauteur des héros
- `--hero-overlay-bg` : Couleur overlay
- `--hero-overlay-opacity` : Opacité overlay

### Menus
- `--menu-bg` : Fond des menus
- `--menu-text` : Couleur texte menu
- `--menu-hover-bg` : Fond au survol

### Modals
- `--modal-bg` : Fond du modal
- `--modal-border-radius` : Arrondis modal
- `--modal-shadow` : Ombre du modal

---

## 🔄 ÉQUIVALENTS DANS NOUVEAU SYSTÈME

### Mapping Proposé
```css
/* Ancien DaisyUI */
.card { background: var(--base-100); border-radius: var(--rounded-box); }

/* Nouveau système */
.card { background: var(--color-surface); border-radius: var(--border-radius-large); }
.card.elevated { box-shadow: var(--elevation-2); }
```

### Variables à Créer
```css
--card-bg: var(--color-surface);
--card-border-radius: var(--border-radius-large);
--card-shadow: var(--elevation-1);
--card-padding: var(--spacing-4);

--hero-height: 400px;
--hero-bg-overlay: rgba(0, 0, 0, 0.5);

--menu-bg: var(--color-surface-variant);
--menu-hover-bg: var(--color-state-hover);

--modal-bg: var(--color-surface);
--modal-overlay: rgba(0, 0, 0, 0.5);
```

---

## 📋 OBSERVATIONS

### Points Forts
- **Composants complets** : Cards, menus, modals prêts à l'emploi
- **Responsive** : Adaptation automatique mobile/desktop
- **Cohérence visuelle** : Apparence uniforme

### Points d'Amélioration
- **Personnalisation limitée** : Styles fixes par thème
- **Taille fixe** : Dimensions prédéfinies
- **Flexibilité réduite** : Peu de variants

---

## 🎯 RECOMMANDATIONS

### Priorité de Migration
1. **`card`** + **`card-body`** (usage principal - widgets)
2. **`menu`** (navigation essentielle)
3. **`container`** + **`hero`** (layout principal)
4. **`modal`** (dialogs importants)
5. **`navbar`** (en-têtes d'application)

### Évolutions Possibles
- **Variants de cartes** : outlined, filled, elevated
- **Tailles multiples** : sm, lg, xl pour cards/heroes
- **Animations** : transitions d'entrée/sortie
- **Thèmes spécialisés** : success, warning, error pour cards

---

*Date d'audit : [DATE]*
*Responsable : [VOTRE NOM]*
