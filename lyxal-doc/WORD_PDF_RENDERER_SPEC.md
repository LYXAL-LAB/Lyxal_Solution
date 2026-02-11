# Spécification du Renderer PDF Lyxal (Focus Word) - v1.0

## 1. Vision
Le Renderer PDF est un moteur de projection "aveugle". Il reçoit un **WordPageLayout** (boîtes positionnées, textes stylés) et produit un flux binaire conforme à la norme PDF. Il ne prend aucune décision de mise en page ; il exécute des instructions de dessin.

## 2. Flux Architectural
1.  **Entrée** : `WordPageLayout` (Coordonnées X,Y finales, styles résolus).
2.  **Ressources** : `FontProvider` (Accès aux fichiers de police pour l'incorporation).
3.  **Processus** : Sérialisation des commandes PDF (Text showing, Graphics state, Page tree).
4.  **Sortie** : `Vec<u8>` (Document PDF 1.7+).

## 3. Responsabilités du Renderer (Les Lois du Dessin)

### 3.1 Gestion des Textes
- **Glyph Mapping** : Transformation des chaînes de caractères en glyphes de police.
- **Positionnement Précis** : Placement de chaque ligne (ou segment de texte) selon les coordonnées calculées par le Layout Engine.
- **Incorporation (Embedding)** : Inclusion des sous-ensembles de polices nécessaires pour garantir la portabilité.
- **Normalisation Unicode** : Support UTF-8 intégral et encodage via ToUnicode CMap pour garantir la sélection et la copie correcte du texte.

### 3.2 Gestion Graphique
- **Tracé de Boîtes** : Dessin des bordures et des fonds de cellules/paragraphes basés sur le Box Model.
- **Images** : Incorporation et compression des flux raster (JPEG/PNG).
- **Espaces de Couleur** : Conversion des tokens de couleur (Thème) en opérateurs PDF (RVB ou CMJN).
- **Z-Order Strict** : L'ordre de dessin suit strictement l'ordre des `PhysicalElements` fournis, sans optimisation ni regroupement.

### 3.3 Structure du Document PDF
- **Arborescence des Pages** : Création du dictionnaire `/Pages` et des objets `/Page` correspondants.
- **Métadonnées** : Injection du titre, auteur et dates dans le dictionnaire `/Info`.
- **Système de Coordonnées** : Inversion obligatoire de l'axe Y (Origine PDF bas-gauche vs Origine Layout haut-gauche).

## 4. Invariants & Garanties
- **Pixel-Perfect** : Le rendu correspond au point près (1/72 inch) au Layout Physique.
- **Stateless** : Le renderer est une fonction pure : `(PageLayout, Resources) -> PDF`.
- **Zéro Logique** : Aucune correction de mise en page ou de style n'est effectuée ici.

## 5. Ce qui est HORS RENDERER
- **Interaction** : Pas de formulaires PDF dynamiques.
- **Optimisation** : Le renderer ne simplifie pas le document.

