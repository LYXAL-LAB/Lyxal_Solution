# Spécification de l'Interprète Excel (Lyxal) - v1.0

## 1. Vision
L'interprète Excel donne une signification de calcul et de gestion de données au Langage Lyxal. Il transforme un arbre sémantique pur en une grille de calcul logique et un graphe de dépendances évalué à la demande.

## 2. Interprétation des Blocs (Mapping Excel)

### 2.1 La Grille Logique
- `Block::Table` -> **Grille de Calcul** : C'est le conteneur principal.
- **Règle Normative** : La position logique (A1, B2...) est une projection locale à l'interprète Excel et ne doit jamais être persistée ni référencée dans l'AST.
- `Block::Section` -> **Classeur / Feuille** : Utilisé pour segmenter les grilles de calcul en domaines logiques.

### 2.2 Unité de Donnée (Cellule)
- `TableCell` -> **Cellule Excel** :
  - Interprétée comme un conteneur de valeurs ou d'expressions.
  - **Règle de Contenu** : Une cellule peut contenir simultanément `Inline::Value` + `Inline::Expression` (ex: valeur affichée + formule source). L'AST ne distingue pas "cellule de formule" et "cellule de valeur" ; c'est l'interprète qui décide de la priorité d'affichage ou de calcul.

### 2.3 Logique & Structure
- `Block::Condition` -> **Calcul Conditionnel** : Définit quelle branche de blocs/valeurs doit être incluse dans le graphe de calcul.
- **Règle d'Exclusion** : Les branches non sélectionnées par une condition n'entrent pas dans le graphe de dépendances.
- `Block::Iteration` -> **Expansion Symbolique** : Interprété comme une expansion structurelle symbolique, sans notion de boucle d'exécution ni de source de données externe. Toute donnée traitée provient exclusivement de l'AST ou du Layout.

### 2.4 Gouvernance & Collaboration
- `Block::Comment` -> **Commentaire de Cellule** : Rattaché à l'adresse logique de la cellule.
- `Block::Revision` -> **Audit de Calcul** : Historisation des changements de valeurs ou de formules.
- `NodePolicy` -> **Protection de Zone** : Définit les droits d'accès ou de modification projetés sur la grille.

## 3. Interprétation des Inlines (Le Cœur du Calcul)

- `Inline::Value` -> **Valeur Typée** : Base de calcul pour les types `Number`, `Date`, `Currency`, `Percent`, `Boolean`.
- `Inline::Expression` -> **Formule Symbolique** : 
  - **Règle d'Analyse** : L'analyse syntaxique de la chaîne `formula` est locale à l'interprète Excel et n'a aucune existence hors de celui-ci. Aucune structure d'expression ne doit être réinjectée dans l'AST.
- `Inline::CrossRef` -> **Référence de Cellule** : Cible un `NodeId`. 
  - **Règle de Robustesse** : Si la cible référencée existe mais n'est pas une cellule calculable, l'interprète produit la valeur d'erreur `#VALUE!`.

## 4. Moteur de Dépendances (Règles Excel)

1. **Graphe de Dépendances (DAG)** : L'interprète construit un graphe à partir des expressions et références.
   - **Règle Anti-Cycle** : Toute détection de cycle produit l'erreur standard `#CYCLE!` sans évaluation partielle.
2. **Ordre de Calcul** : L'ordre est recalculé intégralement à chaque interprétation. Aucun cache d'ordre n'est conservé. **L'interprète est garanti stateless.**
3. **Résolution Symbolique** : Les expressions sont évaluées pour produire une projection de résultat. En cas d'erreur (référence brisée, syntaxe), l'interprète produit les marqueurs standard (`#REF!`, `#NAME?`, etc.).

## 5. Ce qui est ignoré dans Excel
- Les styles de mise en page Word (`Header`, `Footer`, `PageBreak`).
- Les propriétés géométriques complexes des `Block::Shape` non liées à des contrôles de données.

## 6. Règle d'Or de l'Interprète
L'interprète Excel **ne modifie jamais l'AST**. Le Layout Excel est une **projection éphémère**, non persistable et non sérialisable dans le langage Lyxal.
