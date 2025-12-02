# 🏗️ Lyxal PDF Suite : Architecture Technique (Stratégie 100% TypeScript)

## 1. Vision et Philosophie
L'objectif est de construire une infrastructure de traitement de documents (PDF, Office, Images) **souveraine, autonome et intégrée**, capable de rivaliser fonctionnellement avec Adobe Acrobat Pro, mais conçue pour l'ère de l'IA.

### Le Choix Stratégique : "Pure TypeScript & WASM"
Contrairement aux architectures traditionnelles lourdes (Java, C++, binaires Linux disparates), Lyxal fait le choix de l'agilité et de l'universalité.
*   **0% Binaire Externe :** Pas de dépendance système (pas de `apt-get install ghostscript`, pas de LibreOffice Server).
*   **100% Portable :** Le code tourne partout (Node.js, Bun, Workers, et même Navigateur Client).
*   **Maintenance Simplifiée :** Une seule `package.json`, un seul langage.

---

## 2. La Stack Technique (The Lyxal Stack)

Nous remplaçons chaque brique historique lourde par son équivalent moderne dans l'écosystème JavaScript/WASM.

| Domaine | Fonctionnalité | Solution Traditionnelle (Lourde) | **Solution Lyxal (TypeScript/WASM)** |
| :--- | :--- | :--- | :--- |
| **Manipulation** | Fusion, Split, Rotate, Metadatas | `pdftk` / `qpdf` (C++) | **`pdf-lib`** (Native TS) <br> *Le standard moderne pour l'édition binaire de PDF.* |
| **Lecture** | Parsing, Extraction Texte, Rendu Image | `Poppler` / `Xpdf` (C) | **`pdf.js`** (Mozilla / JS) <br> *Utilisé côté serveur (Node/Bun) pour "comprendre" le PDF.* |
| **OCR** | Reconnaissance de caractères (Scan) | `Tesseract` (C++ natif) | **`tesseract.js`** (WASM) <br> *Portage WebAssembly de Tesseract. Performance quasi-native, zéro install.* |
| **Conversion** | Word/Excel → PDF | `LibreOffice Headless` | **`mammoth.js` + `Puppeteer`** <br> *Pipeline : DOCX → HTML propre → PDF (via Chrome Headless).* |
| **Compression** | Optimisation taille | `Ghostscript` | **`sharp` + `pdf-lib`** <br> *Extraction des images → Re-compression WebP/JPEG optimisée → Re-assemblage.* |
| **Signature** | Signatures Certifiées | `OpenSSL` / `Java DSS` | **`node-signpdf`** <br> *Signature cryptographique standard P12/PAdES en pur JS.* |
| **Polices** | Gestion Typographique | Adobe PostScript Fonts | **`Lyxal Font Engine`** (Dynamique) <br> *Chargement à la volée de polices TTF/OTF via CDN. Parsing via `fontkit`.* |

---

## 3. Architecture Modulaire : Le Serveur MCP

Toute cette puissance technique est exposée aux agents IA via le **Model Context Protocol (MCP)**.
Pour l'IA, Lyxal PDF n'est pas du code, c'est une boîte à outils native.

### Structure du Serveur MCP (`lyxal-pdf-mcp`)
Le serveur agit comme un chef d'orchestre. Il reçoit les ordres de l'IA et active les bibliothèques TS appropriées.

```typescript
// Exemple conceptuel de l'interface exposée à l'IA
interface LyxalPDFTools {
  // Manipulation basique
  merge_pdfs(files: string[]): Promise<string>;
  split_pdf(file: string, pages: string): Promise<string[]>;
  
  // Intelligence
  ocr_document(file: string, lang: 'fr' | 'en'): Promise<string>;
  extract_form_data(file: string): Promise<JSON>;
  
  // Conversion
  convert_office_to_pdf(file: string): Promise<string>;
  
  // Sécurité
  sign_document(file: string, certificateId: string): Promise<string>;
}
```

### Flux de Données (Workflow)
1.  **Agent IA :** "Analyse cette facture scan (scan.pdf) et extrais le montant."
2.  **MCP Server :** Reçoit la requête.
3.  **Logique Interne :**
    *   Détecte que c'est une image (via `pdf.js`).
    *   Active `tesseract.js` (WASM) pour l'OCR.
    *   Nettoie le texte brut.
4.  **Retour :** Renvoie le texte structuré à l'agent IA.

---

## 4. Zoom sur les "Pain Points" & Solutions

### A. La Conversion Microsoft Word (`.docx` vers `.pdf`)
C'est le défi majeur sans LibreOffice.
*   **Approche Lyxal :** Le pipeline "HTML Pivot".
*   *Process :* On utilise `mammoth.js` ou une librairie de parsing XML pour transformer le `.docx` en HTML/CSS fidèle. Ensuite, `Puppeteer` (Chrome Headless) "imprime" ce HTML en PDF.
*   *Avantage :* Rendu ultra-propre, support des CSS modernes, 100% scriptable.
*   *Limite :* Mise en page complexe (tableaux imbriqués bizarres) parfois légèrement décalée par rapport à Word natif.

### B. Performance OCR (WASM vs Natif)
*   **Constat :** `tesseract.js` est ~2x plus lent que le binaire C++.
*   **Solution :** Utiliser des **Workers**. Ne jamais bloquer le thread principal. Lancer l'OCR en tâche de fond (Background Job) et notifier l'agent quand c'est fini.

### C. Gestion des Polices ("Adobe-scale")
Pour supporter des milliers de polices sans alourdir le package :
*   **Stratégie :** Font-on-Demand.
*   Le module `core` ne contient que les 14 polices standard.
*   Un système de plugin télécharge dynamiquement les fichiers `.ttf` (Google Fonts ou Lyxal CDN) si demandés, les parse avec `fontkit`, et les incorpore au PDF.

---

## 5. Roadmap de Développement

### Phase 1 : Le Cœur (Core)
*   Initialiser le projet TypeScript (Bun ou Node).
*   Implémenter `pdf-lib` pour Merge/Split/Metadata.
*   Mettre en place le moteur de polices (statique + dynamique).
*   Créer le serveur MCP de base.

### Phase 2 : L'Intelligence (Reader)
*   Intégrer `pdf.js` pour l'extraction de texte propre.
*   Intégrer `tesseract.js` pour l'OCR des images.

### Phase 3 : Le Convertisseur (Converter)
*   Mettre en place le pipeline `Docx -> HTML -> PDF` avec Puppeteer.
*   Gérer la compression d'images via `sharp`.

### Phase 4 : La Souveraineté (Security)
*   Implémenter la signature électronique.
*   Chiffrage / Déchiffrage des documents.

---

## Conclusion
Cette architecture permet à **Lyxal** de posséder sa propre technologie documentaire. Elle est moderne, légère, facile à déployer dans le cloud ou sur site, et parfaitement adaptée pour servir d'OS aux agents IA.
