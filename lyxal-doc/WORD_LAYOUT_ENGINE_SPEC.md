# Spécification du Moteur de Mise en Page Word (Layout Engine) - v1.0

## 1. Vision
Le Moteur de Mise en Page Word transforme un **VisualLayout** (flux d'éléments stylés) en un **PageLayout** (composition physique paginée). Il gère les contraintes spatiales, la fragmentation du texte et l'organisation géométrique finale sur le support.

## 2. Flux Architectural
1.  **Entrée** : `WordVisualLayout` (Produit par l'Interprète Word + Style Engine).
2.  **Configuration** : `PageSettings` (Dimensions de page, marges, orientation).
3.  **Processus** : Composition géométrique (Line-breaking, Pagination).
4.  **Sortie** : `WordPageLayout` (Collection de pages contenant des boîtes positionnées avec coordonnées X,Y).

## 3. Responsabilités du Moteur (Les Lois de la Composition)

### 3.1 Calcul des Boîtes (Box Model)
- Résolution des dimensions finales en tenant compte des marges (`margin`), du remplissage (`padding`) et des bordures issues du style.
- Calcul de la largeur disponible pour le contenu (Largeur page - Marges gauche/droite).

### 3.2 Fragmentation du Texte (Line Breaking)
- Découpage des paragraphes en lignes physiques selon la largeur disponible.
- Gestion de l'alignement (Gauche, Droite, Centré, Justifié).
- Gestion de l'interlignage (`line_height`) résolu par le Style Engine.

### 3.3 Pagination (Page Breaking)
- Remplissage progressif des pages.
- Déclenchement automatique d'un saut de page lorsque la hauteur disponible est épuisée.
- Support des sauts de page forcés (`PageBreak` issus de l'AST).

### 3.4 Zones Spéciales
- **En-têtes & Pieds de page** : Placement des éléments répétés dans les marges haute et basse.
- **Notes de bas de page** : Calcul de l'espace nécessaire en bas de page pour inclure les notes appelées dans le corps de texte.

## 4. Règles de Composition Avancées
- **Veuves et Orphelines** : Empêcher qu'une ligne seule d'un paragraphe se retrouve isolée en haut ou en bas d'une page (minimum 2 lignes requis par bloc fragmenté).
- **Blocs Indisociables** : Support d'une option "Garder avec le suivant" (ex: titres rattachés à leur paragraphe).
- **Z-Order Physique** : Placement des éléments superposés (images flottantes, formes) selon leur plan de profondeur.

## 5. Invariants & Garanties
- **Stateless** : Le moteur ne stocke aucun état entre deux compositions. Chaque document est recalculé intégralement.
- **Déterminisme** : À flux visuel et paramètres de page identiques, la sortie doit être strictement identique.
- **Pureté** : Le moteur ne réalise aucune opération de rendu (pas de dessin de glyphes, pas de génération de binaire PDF).

## 6. Ce qui est HORS MOTEUR (Interdictions)
- **Logique sémantique** : Le moteur ignore si un texte est un titre ou un disclaimer, il ne voit que des boîtes et des contraintes.
- **Calcul de style** : Les couleurs et polices sont déjà résolues, le moteur ne fait que les transporter.
- **Interaction utilisateur** : Pas de gestion de curseur ou de sélection ici.

