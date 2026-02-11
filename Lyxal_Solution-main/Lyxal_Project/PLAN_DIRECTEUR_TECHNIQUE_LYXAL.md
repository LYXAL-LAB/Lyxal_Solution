# PLAN DIRECTEUR TECHNIQUE (Masterplan) - LYXAL V1.1 (Greenfield Strategy)

**Rôle :** CTO / Lead Architect  
**Date :** 08 Décembre 2025  
**Vision :** Création du premier "Document Database Engine" natif au monde (Souverain & Complet).

---

## 1. Vue d'Ensemble & Gouvernance

### 1.1 Architecture du Repository (Monorepo)
Nous allons restructurer le projet pour tout centraliser. Cela garantit que la version du moteur utilisée par le serveur est *exactement* la même que celle utilisée par l'interface UI (via WASM).

```text
Lyxal_Solution/
├── Cargo.toml                  (Workspace Root)
├── crates/
│   ├── surrealdb-core/         (Code source de SurrealDB existant + API Native)
│   ├── pdf/                    (NOUVEAU : Le moteur PDF pur Rust)
│   │   ├── src/engine/         (Legacy : API DOM bas niveau)
│   │   ├── src/model.rs        (The Brain : Modèle Unifié)
│   │   ├── src/manage.rs       (The Editor : Parsing/Merge/Split)
│   │   ├── src/typography.rs   (The Typer : HarfBuzz Shaping)
│   │   ├── src/layout.rs       (The Composer : Flexbox Layout)
│   │   └── src/lib.rs          (Point d'entrée)
│   └── lyxal-surreal/          (Obsolète : Intégré directement dans core/src/fnc/pdf.rs)
├── apps/
│   ├── surrealist/             (Fork de l'interface UI)
│   └── desktop/                (App Tauri enveloppant Surrealist)
└── docs/                       (Documentation Architecture)
```

### 1.2 Stack Technologique Arrêtée
*   **Langage Core :** Rust (Edition 2021/2024).
*   **Stratégie Moteur :** **"Greenfield" (Pas de portage de dette TS).**
*   **Libs Bas Niveau :** `pdf-writer`, `lopdf`.
*   **Libs Pro :** `rustybuzz` (Typographie), `taffy` (Layout).
*   **Parsing :** `serde_json`.
*   **Async Runtime :** `tokio`.
*   **Frontend :** React + Rust (WASM) + WebGPU (Futur).

---

## 2. Phase A : Fondation Core & Brain (Terminé)
**Objectif :** Construire un moteur capable de Lire, Écrire et Comprendre.

*   **Jalon A.1 : Moteur de Génération (Writer) [OK]**
    *   Utilisation de `pdf-writer`.
    *   Exposition de `pdf::generate(json)`.

*   **Jalon A.2 : Moteur de Manipulation (Editor/Brain) [OK]**
    *   Intégration de `lopdf`.
    *   Structure unifiée `PdfDocument` (The Brain).
    *   Fonctions : `pdf::info`, `pdf::extract_text`, `pdf::merge`, `pdf::page_count`, `pdf::to_model`.

---

## 3. Phase B : Excellence Graphique (En cours)
**Objectif :** Remplacer le positionnement absolu par un moteur de rendu professionnel.

*   **Jalon B.1 : Typographie & Layout (Terminé)**
    *   **Shaping :** Intégration de `rustybuzz` pour le rendu de texte complexe (Arabe, Ligatures).
    *   **Layout :** Intégration de `taffy` pour le support Flexbox.
    *   **API :** `pdf::generate_flex(json_layout)`.

*   **Jalon B.2 : Conformité & Standards (Prochain Sprint)**
    *   Validation PDF/A-4 (Archivage).
    *   Validation PDF/UA (Accessibilité).
    *   Gestion des polices (Embedding complet).

---

## 4. Phase C : Rendu Souverain (Futur)
**Objectif :** Se passer de PDF.js.

*   **Jalon C.1 : WebGPU Pipeline**
    *   Portage des primitives graphiques vers `wgpu`.
    *   Compilation WASM du renderer.

---

## 5. Phase D : L'Interface "Single Pane of Glass" (Lyxal Studio)
**Objectif :** Transformer Surrealist en IDE métier.

*   **Jalon D.1 : Hybridation WASM**
    *   Intégrer le fichier `.wasm` généré en Phase 1 dans le build React de Surrealist.
    *   Créer un composant React `<LyxalPreview />` qui utilise le WASM pour le rendu.

*   **Jalon D.2 : Les Modules Métiers**
    *   Développer l'onglet "Documents" dans Surrealist.
    *   Connecter l'éditeur de code (Monaco Editor déjà présent dans Surrealist) au moteur de template.
    *   Implémenter le "Live Preview" (Split view).

---

## 6. Risques & Mitigations

| Risque | Impact | Mitigation |
| :--- | :--- | :--- |
| **Courbe d'apprentissage Rust** | Retard dév | S'appuyer massivement sur `pdf-writer` qui gère la spec PDF complexe pour nous. |
| **Blocage BDD** | Crash prod | Utilisation stricte de `spawn_blocking` + Timeouts + Circuit Breakers. |
| **Taille WASM** | UX lente | Optimisation du binaire (`wasm-opt`), Lazy loading dans Surrealist. |

---

## 7. Prochaines Étapes Immédiates (Action Plan)

1.  **Phase B.2 :** Implémenter le chargement réel des polices (Font Loading) pour que `generate_flex` produise des fichiers visuellement parfaits (actuellement placeholder).
2.  **Tests End-to-End :** Écrire un test Rust qui génère un PDF Flexbox complet et valide le fichier de sortie.
