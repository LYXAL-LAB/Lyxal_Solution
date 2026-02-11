# Spécification Officielle du Langage Lyxal (v1.0)

## 1. Introduction
Le Langage Lyxal est un formalisme sémantique universel pour la représentation de documents bureautiques complexes (texte, calcul, présentation, dessin). Il sépare strictement l'**intention sémantique** de l'**exécution** et du **rendu**.

## 2. Principes Fondamentaux (Les Tables de la Loi)
- **Sémantique Pure** : Tout nœud exprime "ce que c'est", jamais "comment l'afficher".
- **Déclaratif Uniquement** : L'AST ne contient aucune logique d'exécution (pas de calcul de formule, pas de pagination).
- **Gouvernance Intégrée** : L'identité, les droits et l'auditabilité sont des citoyens de premier rang.
- **Détachement du Runtime** : Le langage est indépendant de toute base de données, interface utilisateur ou protocole réseau.

## 3. Matrice Finie des Concepts

### 3.1 Unité de Gouvernance (Metadata)
Chaque nœud possède une structure de métadonnées incluant :
- **Identité** : `NodeId` unique et persistant.
- **Provenance** : `author`, `created_at`, `updated_at`.
- **Classification** : `SemanticTags` (clés/valeurs libres pour IA/Workflows).
- **Contrôle** : `NodePolicy` définissant les accès par `Scope`.

### 3.2 Famille : STRUCTURE
- **Section** : Hiérarchie logique imbriquée.
- **List** : Énumération (ordonnée, non-ordonnée, tâches).
- **Table** : Structure de grille bidimensionnelle.
- **Group** : Regroupement libre de blocs (calques, protection).
- **Iteration** : Intention de répétition d'un template.
- **Divider** : Séparateur structurel.

### 3.3 Famille : CONTENU
- **Text** : Contenu textuel riche (via Inlines).
- **Image** : Référence à un média externe.
- **CodeBlock** : Texte brut avec intention de langage.
- **Value** : Donnée typée sémantique (`Number`, `Date`, `Currency`, `Percent`, `Boolean`).
- **Shape** : Primitives vectorielles (Rectangle, Ellipse, Path).

### 3.4 Famille : RELATIONS
- **Anchor** : Point d'ancrage nommé (stable pour référence).
- **Link** : Référence externe (URL).
- **CrossRef** : Référence croisée symbolique vers un `NodeId`.
- **Citation** : Référence bibliographique ou juridique.

### 3.5 Famille : DYNAMIQUE
- **Expression** : Expression de calcul symbolique (ex: `SUM()`).
- **Condition** : Structure logique `If / Then / Else` symbolique.
- **Field** : Champ auto-résolu (date, numérotation).

### 3.6 Famille : GOUVERNANCE
- **Comment** : Fil de discussion rattaché à un nœud.
- **Revision** : Marquage sémantique des modifications (`Insertion`, `Deletion`, `Modification`).
- **SignatureSlot** : Intention formelle d'emplacement de signature.
- **Intent** : Classification fonctionnelle (`Summary`, `Disclaimer`, `TOC`, etc.).

## 4. Invariants & Validité
Le moteur de cohérence doit garantir :
- **Non-vacuité** : Les conteneurs critiques (Section, Footnote, Intent) ne peuvent être vides.
- **Intégrité de l'Historique** : Chaque transition d'état est chaînée par hachage SHA-256.
- **Identité Forte** : Un document est défini par son hash de structure (`document_hash`).

## 5. Ce qui est HORS LANGAGE (Interdictions)
- **Pixels & Coordonnées absolues** : (Sauf propriétés spécifiques de Shape, mais jamais pour la mise en page).
- **Moteur de Calcul** : L'AST stocke la formule, pas le résultat.
- **Moteur de Rendu** : Le langage ignore l'existence du PDF, du HTML ou de l'écran.
- **Gestion des Utilisateurs** : Le langage définit des `Scopes`, pas des annuaires.

## 6. État de Clôture
Version : **1.0.0**
Statut : **GELÉ** (Fichier `core/node.rs` verrouillé).
Toute modification doit être traitée comme une révision de la norme.

