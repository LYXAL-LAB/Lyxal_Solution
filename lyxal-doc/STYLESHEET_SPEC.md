# Spécification du Modèle StyleSheet Lyxal - v1.0

## 1. Vision
Le `StyleSheet` Lyxal est la source de données unique définissant l'identité visuelle d'un document. Il s'agit d'une structure pure, indépendante de toute technologie de rendu, servant de référentiel au Style Engine.

## 2. Structure Fondamentale
Un `StyleSheet` est composé d'une collection de définitions de styles nommées et d'une gestion de variantes.

```rust
pub struct StyleSheet {
    pub name: String,
    pub version: String,
    pub base_styles: BTreeMap<String, StyleDefinition>,
    pub variants: BTreeMap<String, VariantOverlay>,
}
```

## 3. StyleDefinition (Le Token)
Chaque définition de style est un dictionnaire de propriétés typées.

### 3.1 Propriétés (Tokens)
Les propriétés sont regroupées par domaines sémantiques :

- **TYPOGRAPHY** :
  - `font_family`: Nom de la famille de police.
  - `font_size`: Valeur numérique abstraite.
  - `font_weight`: Graisse (100-900).
  - `line_height`: Multiplicateur ou valeur fixe.
  - `letter_spacing`: Espacement entre caractères.

- **COLORIMETRY** :
  - `text_color`: Hash hexadécimal ou nom de couleur système.
  - `bg_color`: Couleur de fond.
  - `border_color`: Couleur des bordures.
  - `opacity`: Valeur de 0.0 à 1.0.

- **BOX_MODEL** :
  - `padding`: Structure [Top, Right, Bottom, Left].
  - `margin`: Structure [Top, Right, Bottom, Left].
  - `border_width`: Épaisseur de bordure.
  - `corner_radius`: Rayon d'arrondi.

### 3.2 Héritage Logique
Un style peut hériter d'un autre style pour spécialiser ses propriétés.
```rust
pub struct StyleDefinition {
    pub parent: Option<String>, // Clé vers une autre définition
    pub properties: BTreeMap<String, StyleValue>,
}
```

## 4. Gestion des Variantes (Overlays)
Une variante ne définit pas un nouveau style, mais surcharge les propriétés d'un style existant pour un contexte donné (ex: `Dark`, `Print`).

```rust
pub struct VariantOverlay {
    pub context_key: String, // ex: "mode:dark"
    pub overrides: BTreeMap<String, BTreeMap<String, StyleValue>>, // StyleName -> Property -> Value
}
```

## 5. Résolution des Unités (Abstractions)
Le `StyleSheet` ne stocke pas d'unités physiques (pas de `px`, `cm`, `pt`). Il stocke des valeurs numériques pures. C'est le **Style Engine** qui convertit ces valeurs en unités physiques selon le `Context` (ex: 12 devient 12pt en Print et 16px en Screen).

## 6. Règles de Cohérence (Invariants)
- **Style racine** : Tout thème doit posséder un style nommé `root` ou `default` servant de base ultime.
- **Récursivité** : Les cycles d'héritage sont interdits (détection obligatoire par le Style Engine).
- **Immuabilité** : Une fois chargé dans le Style Engine, le `StyleSheet` est traité comme une donnée en lecture seule.

## 7. Règle d'Or
Le `StyleSheet` ne connaît aucun moteur de rendu. Il ne contient aucun code CSS, aucune commande SVG et aucune instruction PDF. Il exprime uniquement une **intention visuelle structurée**.

