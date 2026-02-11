# Stratégie Multi-Plateforme "Universal Lyxal" : Le Code Unique (Rust)

**Date :** 08 Décembre 2025  
**Sujet :** Déploiement Universel du Moteur Lyxal  
**Objectif :** Atteindre 100% des plateformes (Serveur, Web, Desktop, Mobile) avec une seule base de code Rust.

---

## 1. Le Concept : "Write Once, Run Everywhere (For Real)"

Contrairement aux approches hybrides classiques (Electron, Cordova) qui sont lentes, ou aux approches natives qui demandent 3 équipes de dev (Swift, Kotlin, JS), l'architecture **Rust** permet de compiler le **même code moteur** pour toutes les cibles, avec des performances natives partout.

---

## 2. Web & Navigateur (Client Léger)

### Technologie : WebAssembly (WASM)
Rust est le langage roi du WASM.
*   **Fonctionnement :** Le moteur Lyxal est compilé en un fichier `.wasm`.
*   **Usage :** Le navigateur télécharge ce fichier et l'exécute à une vitesse proche du natif.
*   **Scénarios Lyxal :**
    *   **Prévisualisation Instantanée :** Le PDF se génère dans l'onglet du navigateur en < 100ms, sans appel serveur.
    *   **Mode Déconnecté :** Un commercial peut générer un devis dans le train sans internet.
    *   **Sécurité :** Les données sensibles ne quittent jamais le poste client si nécessaire.

---

## 3. Desktop (Windows, macOS, Linux)

### Technologie : Tauri
Tauri est le successeur moderne d'Electron, construit en Rust.
*   **Architecture :**
    *   **Frontend :** Votre UI Web existante (React/Vue/Svelte...).
    *   **Backend :** Le moteur Lyxal compilé directement dans l'exécutable binaire.
*   **Avantages :**
    *   **Taille Minuscule :** L'installateur fera ~5 Mo (contre ~100 Mo pour Electron).
    *   **Performance :** Usage mémoire divisé par 10.
    *   **Sécurité :** Accès natif sécurisé au système de fichiers local.

---

## 4. Mobile (Android & iOS)

Il existe deux voies principales pour porter du Rust sur mobile, toutes deux excellentes :

### Option A : Tauri Mobile (Recommandé)
Tauri v2 supporte désormais iOS et Android.
*   **Principe :** C'est exactement comme pour le Desktop. Votre UI Web tourne dans une WebView native, et votre moteur Rust tourne en tâche de fond native.
*   **Avantage :** 100% de réutilisation du code Desktop et Web. Vous développez une seule app pour 5 plateformes.

### Option B : UniFFI (Pour une App Native existante)
Si vous avez déjà une app native (Swift ou Kotlin) et que vous voulez juste "injecter" le moteur PDF dedans.
*   **Technologie :** **UniFFI** (Mozilla) ou **Mozilla/uniffi-rs**.
*   **Principe :** Rust génère automatiquement des "bindings" (ponts) pour Swift (iOS) et Kotlin (Android).
*   **Usage :**
    *   Dans Xcode (iOS) : Vous appelez `Lyxal.generate()` comme une fonction Swift normale.
    *   Dans Android Studio : Vous appelez `Lyxal.generate()` comme une fonction Java/Kotlin normale.
*   **Résultat :** Performance native pure, sans passer par une WebView.

---

## 5. Matrice de Déploiement

| Plateforme | Technologie de Compilation | Format de Sortie | Performance |
| :--- | :--- | :--- | :--- |
| **SurrealDB (Serveur)** | `rustc` (Standard) | Binaire Serveur (`.so` / `.dll`) | 🚀🚀🚀 Native |
| **Navigateur Web** | `wasm-pack` | WebAssembly (`.wasm`) | 🚀🚀 Near-Native |
| **Desktop (Win/Mac)** | `tauri build` | Exécutable (`.exe` / `.app`) | 🚀🚀🚀 Native |
| **Mobile (iOS/Android)** | `cargo-mobile` / `tauri` | Librairie Native (`.dylib` / `.so`) | 🚀🚀🚀 Native |

## 6. Conclusion Stratégique

En réécrivant Lyxal en Rust, vous ne résolvez pas seulement le problème de l'intégration SurrealDB. **Vous résolvez le problème de la distribution multi-plateforme pour les 10 prochaines années.** Vous devenez "agnostique" de la plateforme d'exécution.

