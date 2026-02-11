# Spécification du Moteur de Mise en Page Slides (Layout Engine) - v1.0

## 1. Vision
Le Moteur de Mise en Page Slides transforme un **SlidesVisualLayout** (objets stylés avec intentions spatiales) en un **SlidesPhysicalLayout** (composition physique par diapositive). Il gère le confinement dans le viewport, la résolution des coordonnées et la structure séquentielle des états de visibilité.

## 2. Flux Architectural
1.  **Entrée** : `SlidesVisualLayout` (Produit par l'Interprète Slides + Style Engine).
2.  **Configuration** : `ViewportSettings` (Ratio d'aspect ex: 16:9, dimensions de référence en pt).
3.  **Processus** : Projection spatiale et résolution de la timeline logique.
4.  **Sortie** : `SlidesPhysicalLayout` (Collection de diapositives contenant des objets positionnés et des étapes de visibilité).

## 3. Responsabilités du Moteur (Les Lois de la Projection)

### 3.1 Gestion du Viewport (Canevas)
- Définition de la zone physique de la diapositive (ex: 720pt x 405pt pour du 16:9).
- **Confinement** : Calcul des boîtes englobantes (`bounding boxes`) finales pour chaque objet.
- **Mise à l'échelle** : Adaptation des coordonnées logiques si le format de sortie diffère du format de conception.

### 3.2 Résolution Spatiale (X, Y, Z)
- **Coordonnées Physiques** : Transformation des positions relatives ou par défaut en coordonnées absolues par rapport au coin supérieur gauche du viewport.
- **Z-Order Final** : Résolution des superpositions pour garantir que les éléments s'empilent correctement.
- **Alignement & Distribution** : Application des contraintes de centrage ou de distribution si spécifiées dans les tags.

### 3.3 Résolution de la Timeline (Étapes de visibilité)
- **Fragmentation Temporelle** : Le moteur ne gère pas l'animation, mais il définit les **Étapes (Steps)**.
- **Calcul des État** : Pour chaque diapositive, le moteur produit une liste d'états :
  - *Step 0* : Éléments visibles au chargement.
  - *Step 1* : Éléments ajoutés/modifiés après le premier événement (clic).
  - *Step N* : État final de la diapositive.

### 3.4 Composition des Objets Complexes
- **Groupes** : Résolution récursive des positions des éléments enfants par rapport à leur parent.
- **Zones de Texte** : Calcul de l'encombrement physique du texte stylé (sans réaliser le dessin) pour ajuster la taille des blocs de texte.

## 4. Invariants & Garanties
- **Stateless** : Chaque diapositive est composée indépendamment.
- **Déterminisme** : Le résultat est strictement reproductible.
- **Pureté** : Aucun rendu graphique (GPU/SVG/Canvas) n'est effectué ici. Le moteur produit des chiffres et des structures.

## 5. Ce qui est HORS MOTEUR (Interdictions)
- **Interpolation d'animation** : Le moteur ignore comment on passe de l'étape 0 à l'étape 1.
- **Interaction** : Pas de gestion de navigation ou de boutons ici.
- **Sémantique** : Le moteur ignore si une slide est un "Titre" ou un "Sommaire".

