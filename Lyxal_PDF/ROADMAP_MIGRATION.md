# 🗺️ Lyxal PDF Suite : Master Plan (Migration & Innovation)

**Objectif Final :** Créer une suite PDF souveraine, moderne (100% TS/React), capable de rivaliser avec Adobe, pilotable par IA.

---

## 📅 Phase 1 : Le Viewer "Native React" (UI Modernization)
**Objectif :** Supprimer l'iframe et l'interface legacy de Mozilla. Avoir une UI React fluide connectée au moteur existant.

### Étape 1.1 : Infrastructure React
- [ ] Créer l'architecture des composants (`<Document>`, `<Page>`, `<Toolbar>`).
- [ ] Configurer le chargement du moteur `pdf.js` (le binaire existant) dans React.

### Étape 1.2 : Composant `<PDFPage>` (Le Rendu)
- [ ] Implémenter le rendu Canvas via `page.render()`.
- [ ] Gérer le scaling (Zoom) et la haute résolution (Retina).
- [ ] Gérer le Text Layer (pour la sélection de texte).

### Étape 1.3 : Navigation & UX
- [ ] Implémenter le scroll virtuel (pour afficher 500 pages sans lag).
- [ ] Créer la Toolbar (Zoom, Pagination).
- [ ] Créer la Sidebar (Thumbnails).

### 🎯 Validation Phase 1
- Une app React capable d'ouvrir, afficher et naviguer dans un gros PDF sans iframe.

---

## 📅 Phase 2 : Le Renderer "Lyxal Engine" (Migration TS)
**Objectif :** Remplacer le moteur JS "boîte noire" par notre propre moteur TypeScript maîtrisé.

### Étape 2.1 : Bootstrapping `@lyxal-pdf/renderer`
- [ ] Initialiser le package TS.
- [ ] Migrer les utils de base (`util.js`, `shared/*.js`) en TS strict.

### Étape 2.2 : Core Parsing (Le Cerveau)
- [ ] Migrer le parser d'objets et de streams.
- [ ] Migrer le système de Fonts (`fonts.js` -> TS).
- [ ] Valider par des tests unitaires massifs (comparaison pixel-perfect avec l'ancien moteur).

### Étape 2.3 : Display Layer (Le Peintre)
- [ ] Migrer `canvas.js` en TS.
- [ ] Optimiser pour Bun/WASM si possible.

### 🎯 Validation Phase 2
- Le Viewer React (Phase 1) utilise `@lyxal-pdf/renderer` (TS) au lieu de `pdf.js` (JS). Rendu identique à l'octet près.

---

## 📅 Phase 3 : Innovation & IA (Features)
**Objectif :** Dépasser Adobe en fonctionnalités.

### Étape 3.1 : Édition Native (WYSIWYG)
- [ ] Connecter le clic utilisateur sur le Canvas au `@lyxal-pdf/core` (Modification).
- [ ] Ajouter du texte, des images, des formes en temps réel.

### Étape 3.2 : IA & Sémantique
- [ ] Intégrer Tesseract (OCR) directement dans le flux de rendu (pour rendre le texte scanné sélectionnable).
- [ ] Intégrer un assistant IA ("Résume cette page", "Trouve le total").

### Étape 3.3 : Layout Engine
- [ ] Créer un moteur de génération PDF depuis JSON/HTML (Auto-layout).

---

**Estimatif :** 4 Jours pour un MVP solide des Phases 1 & 2 (si focus total).

