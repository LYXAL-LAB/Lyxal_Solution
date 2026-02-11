# Spécification du Moteur de Mise en Page Excel (Layout Engine) - v1.0

## 1. Vision
Le Moteur de Mise en Page Excel transforme un **ExcelVisualLayout** (grille de cellules stylées avec expressions et valeurs résolues) en un **ExcelPhysicalLayout** (composition physique finale d'un classeur). Il gère le dimensionnement dynamique des colonnes/lignes, le gel des zones, le viewport scrollable et les zones de visibilité partielle.

## 2. Flux Architectural
1.  **Entrée** : `ExcelVisualLayout` (Produit par l'Interprète Excel + Style Engine).
2.  **Configuration** : `GridSettings` (Largeur par défaut des colonnes, hauteur par défaut des lignes, réglages de gel).
3.  **Processus** : Résolution géométrique de la grille et calcul du viewport.
4.  **Sortie** : `ExcelPhysicalLayout` (Collection de feuilles contenant des zones de cellules positionnées physiquement).

## 3. Responsabilités du Moteur (Les Lois de la Grille)

### 3.1 Résolution Géométrique de la Grille
- **Dimensionnement Dynamique** : Calcul de la largeur de chaque colonne et de la hauteur de chaque ligne.
- **Ajustement Automatique** : Capacité à ajuster les dimensions en fonction du contenu résolu par le Style Engine (sans effectuer de dessin).
- **Adressage Physique** : Conversion des adresses logiques (A1, B2) en coordonnées (X, Y) relatives au coin supérieur gauche de la feuille.

### 3.2 Gestion du Viewport & Scrolling
- **Zones de Gel (Freeze Panes)** : Définition des zones de cellules qui restent fixes lors du défilement (ex: ligne 1 gelée).
- **Fenêtre de Visibilité (Viewport)** : Calcul de la plage de cellules visibles (ex: de A1 à M50) en fonction de la taille de l'écran et de la position de scroll.
- **Sauts de Page de Calcul** : Gestion des ruptures de grille pour l'impression.

### 3.3 Composition des Cellules
- **Fusion de Cellules (Merged Cells)** : Calcul de la boîte englobante pour les cellules fusionnées (rowspan/colspan).
- **Alignement Interne** : Positionnement du contenu à l'intérieur de la cellule physique selon les styles résolus.

### 3.4 Bounding Boxes de Calcul
- Calcul de l'encombrement total de la grille pour définir les limites du scroll.

## 4. Invariants & Garanties
- **Stateless** : L'intégralité de la grille est recalculée à chaque changement de layout ou de settings.
- **Déterminisme** : Sortie strictement identique pour une entrée donnée.
- **Pureté** : Aucun rendu graphique (GPU/Pixels) ; production de structures géométriques uniquement.

## 5. Ce qui est HORS MOTEUR (Interdictions)
- **Logique de calcul** : Le moteur ignore comment une valeur a été calculée ; il ne voit que le résultat final et la structure.
- **Interaction de Scroll** : Le moteur définit la *fenêtre*, il ne gère pas les *événements* de scroll.
- **Édition** : Pas de gestion de focus ou de saisie clavier.

## 6. Règle d'Or de l'Interprète
L'interprète Excel **ne modifie jamais l'AST**. Le Layout Excel est une **projection physique éphémère** non persistable.

