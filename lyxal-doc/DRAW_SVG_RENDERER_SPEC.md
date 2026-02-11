# Spécification du Renderer SVG Lyxal (Focus Draw) - v1.0

## 1. Vision
Le Renderer SVG Draw transforme un **DrawPhysicalLayout** en un flux XML conforme à la norme SVG 1.1+. Il s'agit d'une projection 1:1 de la géométrie résolue, permettant une fidélité vectorielle absolue et une intégration native dans les navigateurs web et les outils de design.

## 2. Flux Architectural
1.  **Entrée** : `DrawPhysicalLayout` (Canevas, calques, géométrie absolue).
2.  **Processus** : Sérialisation XML des éléments géométriques et des styles.
3.  **Sortie** : `String` (Document SVG complet).

## 3. Responsabilités du Renderer (Lois du Vecteur)

### 3.1 Mapping des Éléments
- **Canevas** -> Balise `<svg>` avec attributs `viewBox` basés sur la Bounding Box globale.
- **Calques** -> Balises `<g>` (groupes) avec identifiant de calque.
- **Primitives** :
  - `Path` -> Balise `<path>` avec attribut `d` (commandes de tracé).
  - `Image` -> Balise `<image>` avec liens ou base64.
  - `Text` -> Balise `<text>` positionnée.
- **Groupes** -> Balises `<g>` imbriquées conservant la hiérarchie physique.

### 3.2 Gestion des Styles & Attributs
- **Styles en ligne** : Conversion des `StyleValue` résolues en attributs SVG (`fill`, `stroke`, `stroke-width`, `opacity`).
- **Transformations** : Bien que le Layout Engine ait déjà résolu la plupart des transformations, le renderer peut utiliser l'attribut `transform` pour les groupes si nécessaire.

### 3.3 Fidélité Géométrique
- **Z-Order** : L'ordre d'empilement SVG est déterminé par l'ordre d'écriture des balises XML, correspondant strictement au `z_order` du layout.
- **Précision** : Utilisation de coordonnées flottantes pour une précision sub-pixel.

## 4. Invariants & Garanties
- **Indépendance du Rendu** : Le renderer produit du code source (XML), il ne réalise pas la pixellisation.
- **Stateless** : Chaque canevas est sérialisé de façon isolée.
- **Lisibilité** : Le SVG produit doit être structuré pour être éditable ou inspectable.

## 5. Ce qui est HORS RENDERER
- **Interaction** : Pas de gestion d'événements JS dans le SVG produit.
- **Animations** : Pas de balises `<animate>` ou de CSS transitions.
- **Filtres complexes** : Limité aux primitives supportées par le modèle de style Lyxal.

## 6. Règle d'Or
Le Renderer SVG est une projection **textuelle** d'une vérité **géométrique**. Il ne modifie jamais les données source et garantit une portabilité totale vers les moteurs graphiques modernes.

