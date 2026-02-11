# Spécification de l'Interprète Word (Lyxal) - v1.0

## 1. Vision
L'interprète Word donne une signification de traitement de texte au Langage Lyxal. Il transforme un arbre sémantique pur en un flux linéaire, paginé et structuré pour la lecture et l'édition textuelle.

## 2. Interprétation des Blocs (Mapping Word)

### 2.1 Flux de Base
- `Block::Paragraph` -> **Paragraphe Standard** : L'unité de texte de base.
- `Block::Section` -> **Structure de Document** : Le `level` définit le niveau de titre (H1, H2, etc.). La hiérarchie imbriquée définit les chapitres et sous-chapitres.
- `Block::Divider` -> **Ligne de Séparation** : Transition visuelle entre sections.

### 2.2 Listes & Tableaux
- `Block::List` -> **Liste Word** : 
  - `Ordered` -> Liste numérotée.
  - `Unordered` -> Liste à puces.
  - `Task` -> Liste de contrôle.
- `Block::Table` -> **Tableau Word** : Grille de cellules contenant d'autres blocs.
- **Règle Normative** : Les cellules de tableau sont interprétées comme des conteneurs de blocs linéarisés indépendamment du flux principal.

### 2.3 Éléments de Mise en Page (Sémantique)
- `Block::PageBreak` -> **Saut de Page** : Interruption forcée du flux de rendu.
- `Block::Header` -> **En-tête** : Contenu répété en haut de chaque page logique.
- `Block::Footer` -> **Pied de Page** : Contenu répété en bas de chaque page logique.
- **Règle d'accès** : Le Header/Footer est interprété comme un sous-flux répété, sans accès direct au flux principal sauf via Field et CrossRef.
- `Block::Footnote` -> **Note de bas de page** : Le contenu est extrait du flux et projeté en bas de la page courante avec un appel de note.

### 2.4 Gouvernance & Collaboration
- `Block::Comment` -> **Bulle de Commentaire** : Affiché en marge, lié au `target_id`.
- `Block::Revision` -> **Suivi des modifications (Track Changes)** :
  - `Insertion` -> Texte souligné/coloré.
  - `Deletion` -> Texte barré.
- **RÈGLE CTO NON NÉGOCIABLE** : Les révisions n’affectent jamais la numérotation, les références ni les champs tant qu’elles ne sont pas acceptées.
- `Block::SignatureSlot` -> **Zone de Signature** : Bloc réservé avec mention du rôle.

### 2.5 Intentions & Classification
- `Block::Intent` -> **Blocs Spéciaux** :
  - `Summary` -> Marque un emplacement destiné à recevoir un résumé interprété.
  - `Disclaimer` -> Encadré d'avertissement.
  - `TableOfContents` -> Indique un point d'insertion pour une table des matières interprétée.

## 3. Interprétation des Inlines

- `Inline::Text` -> Texte brut.
- `Inline::StyleRef` -> Applique un style nommé (ex: "Emphase").
- `Inline::Anchor` -> Cible invisible pour les liens.
- `Inline::Link` -> Hyperlien cliquable.
- `Inline::Value` -> Affiche la valeur formatée (date, nombre, devise).
- `Inline::Field` -> **Champ Dynamique** :
  - `current_date` -> Date du jour.
  - `page_number` -> Numéro de la page de rendu.
- `Inline::CrossRef` -> **Référence Croisée** : Affiche dynamiquement le titre ou le numéro de l'élément pointé. 
- **Règle de résolution** : Si la cible est indisponible ou ambiguë, l’interprète affiche un marqueur neutre (ex: "?") sans lever d’erreur.

## 4. Moteur de Layout Logique (Règles Word)

1. **Linéarisation** : L'interprète parcourt l'AST en profondeur d'abord (Depth-First) pour produire le flux de lecture.
2. **Numérotation** : L'interprète maintient des compteurs d'état pour les titres, listes, notes et pages. 
   - **Règle Normative** : La numérotation est une projection locale à l’interprète Word et ne doit jamais être persistée dans l’AST.
3. **Résolution des Champs** : Les Field et CrossRef sont résolus dans un contexte de layout donné et peuvent être recalculés à chaque interprétation.

## 5. Ce qui est ignoré dans Word
- Les propriétés géométriques des `Block::Shape` qui ne concernent pas le flux textuel (ex: coordonnées absolues complexes hors ancrage).
- Les `Metadata` non textuelles (ex: tags IA invisibles), sauf pour alimenter les `Field`.
