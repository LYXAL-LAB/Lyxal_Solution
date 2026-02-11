# Manifeste Technique : Lyxal PDF Engine (Souveraineté & Excellence)

## 1. Vision & Ambition
L'objectif est de créer la pile technologique PDF la plus performante, sécurisée et complète du marché, surpassant les solutions historiques (Adobe) et les standards web actuels (PDF.js).
Lyxal PDF ne dépend d'aucune brique externe critique. C'est une technologie souveraine, écrite en Rust, conçue pour l'ère de l'IA et du Cloud Edge.

## 2. Architecture du Noyau (The Core)
Le cœur du système doit être indestructible.

*   **Langage** : 100% Rust (Safe).
*   **Zero-Copy Parsing** : Les fichiers ne sont jamais copiés inutilement en mémoire. On travaille sur des vues (slices) du fichier brut. Permet d'ouvrir des fichiers de 10 Go instantanément.
*   **Streaming I/O** : Le traitement se fait au fil de l'eau. Le premier octet du PDF de sortie est envoyé au réseau avant même que la fin du fichier ne soit générée.

## 2 bis. PDF Parsing & Model Layer (The Brain)

Le Parsing Layer est la couche qui transforme un flux binaire PDF (`&[u8]` ou stream) en un modèle interne structuré, partagé par tous les moteurs (Writer, Editor, Viewer).

*   **Object Model Unifié** :
    *   Représentation interne des objets PDF : Catalog, Pages, Fonts, XRef, Streams, Annotations, Forms.
    *   API Rust typée : `PdfDocument`, `PdfPage`, `PdfTextRun`, `PdfImage`, `PdfTableCandidate`, etc.

*   **Zero-Copy Parsing** :
    *   Utilisation de slices sur le buffer mmap/stream sans recopier les données.
    *   Résolution lazy des objets (on ne charge que ce qui est nécessaire).

*   **Sémantique Avancée** :
    *   Reconstruction de la structure logique : titres, paragraphes, listes, tableaux.
    *   Base de travail pour l’IA (RAG, classification, extraction de champs).

Ce modèle est le langage commun entre :
*   le **Writer** (génération à partir de données),
*   l’**Editor** (modifications partielles),
*   le **Viewer** (rendu GPU),
*   et les **modules IA** (extraction, compréhension de documents).

## 3. Le Moteur de Génération (The Writer)
Pour remplacer les outils de PAO (InDesign) et les générateurs de rapports.

*   **Moteur Typographique "HarfBuzz-Rust"** :
    *   Support natif OpenType (Ligatures, Kerning optique).
    *   Support Bidirectionnel (BiDi) pour Arabe/Hébreu.
    *   Shaping de texte complexe (Indien, CJK).
*   **Layout Engine "Flex-Rust"** :
    *   Abandon du positionnement absolu (X, Y).
    *   Implémentation d'un algorithme de contraintes (Cassowary) et Flexbox.
    *   Pagination intelligente : gestion des veuves/orphelines, tableaux multipages avec report d'en-tête.
*   **Conformité ISO** :
    *   Validation native PDF/A-4 (Archivage).
    *   Validation native PDF/UA (Accessibilité universelle).

## 4. Le Moteur de Manipulation (The Editor)
Pour traiter l'existant (Legacy) avec une maîtrise totale.

*   **Chirurgie Binaire** : Capacité à modifier un objet (ex: changer un mot) sans réécrire tout le fichier (Incremental Update).
*   **Deep Inspection** : Analyse structurelle pour l'IA. Ne pas voir le PDF comme une image, mais comme un arbre sémantique (Titres, Paragraphes, Tableaux).
*   **Sécurité** :
    *   Caviardage (Redaction) réel : Suppression physique des données masquées (pas juste un rectangle noir par dessus).
    *   Signature Cryptographique Souveraine (Support HSM, Clés quantiques).

## 5. Le Moteur de Rendu (The Viewer - Lyxal View)
Le défi ultime : Afficher le PDF sans PDF.js.

*   **Approche** : "Rust to Pixels".
*   **Technologie** : WebAssembly (WASM) + WebGPU.
*   **Fonctionnement** :
    1.  Le binaire Rust (WASM) télécharge et parse le PDF dans le navigateur.
    2.  Il convertit les commandes PDF (Vecteurs, Courbes de Bézier) en commandes GPU primitives (Triangles).
    3.  Il utilise **WebGPU** (ou WebGL2 en fallback) pour dessiner la page à 60 FPS.
*   **Avantages** :
    *   **Fluidité** : Zoom/Scroll infini à 60fps même sur des plans d'architecte complexes.
    *   **Indépendance** : Aucun script JS tiers. Le rendu est identique sur Chrome, Firefox, Safari et Desktop (Tauri).
    *   **Sécurité** : Le parsing se fait dans la sandbox WASM isolée, protégeant contre les exploits PDF malveillants.

## 6. Stratégie d'Implémentation

### Phase A : Fondation Core & Brain (Actuel)
- [x] Intégration Rust/SurrealDB.
- [x] Génération basique (Texte/Image/Rect) via `pdf::generate`.
- [ ] **Parsing & Model Layer (The Brain)** : Création du modèle unifié.
- [ ] Parsing minimal des headers et extraction de texte (WIP).
- [ ] Manipulation avancée (Merge/Count/Redact) — dépend du Parsing Layer.

### Phase B : Typographie & Layout (Prochain Sprint)
- [ ] Intégration `rustybuzz` (Texte Pro).
- [ ] Implémentation `taffy` (Moteur Flexbox Rust) pour le layout PDF.

### Phase C : Rendu Souverain (Le Gros Morceau)
- [ ] Création du crate `pdf-render`.
- [ ] Portage des primitives graphiques vers `wgpu` (WebGPU en Rust).
- [ ] Compilation WASM du renderer.
- [ ] Intégration dans le Frontend (Canvas WebGPU).
