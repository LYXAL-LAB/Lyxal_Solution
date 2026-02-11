# Spécification de l'Interprète Draw (Lyxal) - v1.0

## 1. Vision
L'interprète Draw donne une signification de construction spatiale et géométrique au Langage Lyxal. Il transforme un arbre sémantique pur en un canevas vectoriel composé de primitives géométriques, de tracés complexes et de transformations affines.
**Note** : L'interprète ne gère aucun moteur de rendu graphique (GPU/SVG), il définit uniquement la structure géométrique résolue.

## 2. Interprétation des Blocs (Mapping Draw)

### 2.1 Le Canevas Logique
- `Block::Section` -> **Calque (Layer) / Zone Logique** : Contrairement à Word ou Slides, la section dans Draw n'implique aucune rupture de flux ou de page. Elle sert à organiser la visibilité et le verrouillage de groupes d'objets.
- **Règle d'Espace** : Tout le document est interprété comme un canevas unique infini.

### 2.2 Primitives Géométriques
- `Block::Shape` -> **Objet Vectoriel** :
  - `rectangle`, `ellipse` -> Primitives avec centre et dimensions.
  - `path` -> Série de points et de commandes de tracé (MoveTo, LineTo, Bezier).
- `Block::Image` -> **Objet Raster** : Image positionnée et transformée.

### 2.3 Organisation Spatiale
- `Block::Group` -> **Groupe de Transformation** : Définit un référentiel local. Les éléments enfants héritent des transformations (translation, rotation, mise à l'échelle) du groupe.
- `Block::Paragraph` -> **Étiquette / Bloc de Texte** : Texte traité comme un objet géométrique avec son propre ancrage.

### 2.4 Logique & Dynamisme
- `Block::Iteration` -> **Motif (Pattern)** : Expansion symbolique d'une forme ou d'un groupe selon un vecteur de répétition.
- `Block::Condition` -> **Visibilité Conditionnelle** : Inclusion ou exclusion d'un tracé dans la scène finale selon une règle logique.

### 2.5 Gouvernance
- `Block::Comment` -> **Annotation Technique** : Commentaire lié à un point ou un tracé spécifique.
- `Block::Revision` -> **Suivi de Tracé** : Historique des modifications géométriques (déplacement de points, changement de formes).

## 3. Interprétation des Inlines
Les inlines sont utilisés exclusivement au sein des zones de texte (`Paragraph`) ancrées aux formes ou isolées, conservant leur sémantique (ex: `StyleRef` pour les étiquettes).

## 4. Moteur de Projection Géométrique (Règles Draw)

1. **Résolution des Transformations** : 
   - L'interprète calcule la matrice de transformation finale pour chaque objet en combinant les `SemanticTags` (ex: `rotate`, `scale`, `translate`) du nœud et de ses parents (`Group`).
   - **Règle Normative** : Les transformations sont locales au Layout Draw et ne modifient jamais les données de base de l'AST.

2. **Géométrie des Tracés (Paths)** :
   - L'interprète résout les listes de points et les segments définis dans les propriétés de la `Shape`.
   - Si les données de points sont invalides ou incomplètes, l'objet est ignoré ou rendu comme un point neutre.

3. **Z-Order (Empilement)** :
   - L'ordre de superposition est strictement défini par l'ordre d'apparition dans l'AST au sein d'un même calque (`Section`).

4. **Stateless Garanti** :
   - L'interprète reconstruit l'intégralité de l'arbre géométrique à chaque interprétation.

## 5. Ce qui est ignoré dans Draw
- Toutes les notions de flux textuel continu (`Header`, `Footer`, `Footnote`, `PageBreak`).
- Les structures de données tabulaires (`Table`) sauf si elles sont interprétées comme des grilles de construction d'objets.

## 6. Règle d'Or de l'Interprète
L'interprète Draw **ne modifie jamais l'AST**. Le Layout Draw est une **projection géométrique éphémère** destinée à être consommée par un moteur de rendu (SVG, Canvas, etc.).

