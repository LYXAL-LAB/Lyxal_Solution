# Spécification de l'Interprète Slides (Lyxal) - v1.0

## 1. Vision
L'interprète Slides donne une signification spatiale et d’ordonnancement temporel déclaratif au Langage Lyxal. Il transforme un arbre sémantique pur en une séquence de diapositives composées d'éléments positionnés et ordonnancés logiquement.
**Note** : L'interprète ne gère aucune exécution ni aucun runtime d'animation.

## 2. Interprétation des Blocs (Mapping Slides)

### 2.1 La Séquence Temporelle
- `Block::Section` -> **Diapositive (Slide)** : 
  - **Règle d'Unité** : Seules les `Section` de premier niveau génèrent des diapositives.
  - **Groupement** : Les sections imbriquées sont interprétées comme des groupes logiques internes à une diapositive, sauf tag explicite contraire.
- **Règle d'Ordre** : L'ordre des blocs dans le document définit l'ordre logique de la présentation.

### 2.2 Éléments Spatiaux
- **Règle d'Ancrage** : Tout élément spatial (`Shape`, `Image`, `Paragraph`, `Table`) est interprété comme un "objet ancré" dans la diapositive, sans flux automatique ni reflow implicite.
- `Block::Shape` -> **Objet Graphique**.
- `Block::Image` -> **Média Visuel**.
- `Block::Paragraph` -> **Zone de Texte**.
- `Block::Table` -> **Tableau de Présentation**.

### 2.3 Structure & Organisation
- `Block::Group` -> **Calque / Groupe** : Regroupe des éléments spatiaux pour des transformations collectives.
- `Block::Iteration` -> **Expansion Spatiale Symbolique** : Interprété comme une expansion de structure sans boucle, sans source externe, et sans duplication dynamique à l'exécution.
- `Block::Condition` -> **Affichage Conditionnel** : Les éléments exclus par une condition ne participent ni à la projection spatiale ni à l'ordonnancement temporel.

### 2.4 Gouvernance & Collaboration
- `Block::Comment` -> **Annotation de Diapositive**.
- `Block::Revision` -> **Suivi de Composition**.
- `NodePolicy` -> **Verrouillage d'Objet**.

### 2.5 Intentions (Rôles)
- `Block::Intent` -> **Rôle Sémantique** : Qualifie la fonction de la diapositive (ex: Titre, Sommaire, Clause) sans imposer de template ni de contenu prédéfini.

## 3. Interprétation des Inlines
Les inlines sont rendus au sein de leurs zones de texte respectives avec leur richesse sémantique.

## 4. Moteur de Projection (Règles Slides)

1. **Projection Spatiale (X, Y, Z)** : 
   - L'interprète projette les éléments sur un plan 2D. 
   - **Règle Normative** : Les coordonnées sont locales au Layout Slides et ne sont jamais persistées dans l'AST.
   - **Projection par Défaut** : En l'absence d'information spatiale explicite, l'interprète applique une projection neutre (ex: empilement vertical logique).
   - **Z-Order** : Déduit de l'ordre des blocs ou de tags spécifiques.

2. **Ordonnancement Temporel Déclaratif** :
   - L'interprète construit une séquence d'apparition basée sur l'ordre des éléments.
   - **Intentions d'Apparition** : Les intentions (ex: "au clic", "après précédent") sont purement déclaratives. Le temps est logique, pas physique (aucune notion de durée).

3. **Stateless Garanti** :
   - L'interprète recalcule l'intégralité du plan de montage à chaque interprétation.

## 5. Ce qui est ignoré dans Slides
- Les éléments de flux linéaires continus (`Header`, `Footer`, `Footnote` en tant que flux de bas de page).
- La pagination automatique de Word.

## 6. Règle d'Or de l'Interprète
L'interprète Slides **ne modifie jamais l'AST**. Le Layout Slides est une **projection éphémère** non persistable et non sérialisable dans le langage Lyxal.
