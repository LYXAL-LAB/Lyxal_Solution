# Spécification du Moteur de Mise en Page Draw (Layout Engine) - v1.0

## 1. Vision
Le Moteur de Mise en Page Draw transforme un **DrawVisualLayout** (objets stylés avec matrices de transformation résolues) en un **DrawPhysicalLayout** (composition physique finale sur un canevas vectoriel). Il gère la délimitation de la scène, la résolution finale des tracés et le Z-order physique.

## 2. Flux Architectural
1.  **Entrée** : `DrawVisualLayout` (Produit par l'Interprète Draw + Style Engine).
2.  **Configuration** : `CanvasSettings` (Unités de sortie, Viewport initial, mise à l'échelle globale).
3.  **Processus** : Projection géométrique et calcul des boîtes englobantes réelles.
4.  **Sortie** : `DrawPhysicalLayout` (Canevas contenant des objets géométriques résolus).

## 3. Responsabilités du Moteur (Les Lois de la Géométrie)

### 3.1 Délimitation de la Scène (Bounding Boxes)
- **Calcul récursif** : Le moteur calcule la boîte englobante (`Bounding Box`) de chaque objet, groupe et calque.
- **Auto-cadrage** : Capacité à définir la zone physique de sortie basée sur l'encombrement total des objets (uniquement si demandé).

### 3.2 Résolution Géométrique Finale
- **Matrice de Transformation** : Application finale des matrices de transformation résolues pour obtenir les coordonnées absolues de chaque point.
- **Normalisation des Tracés** : Transformation des `paths` complexes en une suite de segments et de courbes résolues selon l'unité de sortie.

### 3.3 Gestion de l'Empilement (Z-Order)
- **Résolution des Superpositions** : Le moteur fige l'ordre d'empilement final, tenant compte des calques (`Section`) et de l'ordre interne des groupes.
- **Clipping** : Calcul des zones de masquage si définies dans les groupes.

### 3.4 Composition des Primitives
- **Formes** : Résolution des primitives (rectangle, cercle) en tracés physiques.
- **Images & Texte** : Positionnement final des boîtes raster et textuelles sur le canevas.

## 4. Invariants & Garanties
- **Stateless** : Le canevas est reconstruit intégralement à chaque appel.
- **Déterminisme** : Résultat strictement reproductible.
- **Pureté** : Aucun rendu graphique réel (GPU/SVG) ; le moteur produit uniquement des structures géométriques de sortie.

## 5. Ce qui est HORS MOTEUR (Interdictions)
- **Interaction utilisateur** : Pas de gestion de clic, de drag & drop ou de sélection.
- **Rendu visuel** : Le moteur ne connaît pas les pixels, il ne connaît que les coordonnées réelles.
- **Logique métier** : Le moteur ignore la fonction des objets dessinés.

