# Lyxal Media Engine - Architecture & Vision

## 🧠 Philosophie Système

Le projet **Lyxal** n'est pas une simple librairie, c'est une suite modulaire ("Engine of Engines") conçue pour égaler la puissance des géants de l'industrie (Canva, Photoshop) tout en restant pilotable par API (Headless).

La règle d'or est la **Séparation des Responsabilités**. Nous refusons de créer un monolithe.

### Architecture Modulaire

L'écosystème se découpe en moteurs spécialisés :

1.  🟢 **Lyxal Image** (Ce module) : **Moteur de Rendu Raster/Vectoriel 2D**.
    *   *Responsabilité* : Dessiner des pixels basés sur une scène absolue.
    *   *Statut* : **Production Ready**.
    *   *Input* : JSON décrivant une scène (Layers, X, Y, Effects).
    *   *Output* : Buffer d'image (PNG, JPEG, WebP, Raw).

2.  🟡 **Lyxal Layout** (Prochain Chantier) : **Moteur de Contraintes**.
    *   *Responsabilité* : Calculer les positions (Flexbox, Grilles, Auto-resize).
    *   *Statut* : *Planned*.
    *   *Input* : Données brutes + Règles de Layout.
    *   *Output* : JSON de scène absolue pour Lyxal Image.

3.  🔵 **Lyxal Video** : **Moteur Temporel**.
    *   *Responsabilité* : Orchestration Timeline, Transitions, Encodage.
    *   *Statut* : *Planned*.
    *   *Output* : MP4 / GIF.

4.  🟣 **Lyxal Text Advanced** : **Moteur Typographique**.
    *   *Responsabilité* : Rich Text, Text-on-path, Césure avancée.
    *   *Statut* : *Planned*.

5.  🔴 **Lyxal ML** : **Intelligence Artificielle**.
    *   *Responsabilité* : Détourage, Upscale, Restauration (Non-déterministe).
    *   *Statut* : *Planned*.

---

## 🎨 Lyxal Image : Le Coeur de Rendu 2D

**Lyxal Image** est le "GPU Logiciel" de la suite. Il est conçu pour être :
*   **Déterministe** : Même JSON + Mêmes Assets = Même Hash Binaire.
*   **Safe** : Zéro Panic, Quotas stricts (Memory, CPU).
*   **Portable** : Rust pur, compatible WASM/Lambda.

### Périmètre Fonctionnel (Validé)

*   **Primitives** : Images, Formes Vectorielles (Rect, Circle, Path...), Texte Simple.
*   **Composition** : Layers, Groupes, Masques (Alpha/Luma).
*   **Effets** : Ombres (Drop/Inner), Glow, Outline, Gradients (Linear/Radial).
*   **Manipulations** : Filtres (Blur, Contrast, HSL...), Blending Modes (Overlay, Screen...).
*   **Export** : PNG, JPEG (optimisé), WebP, Flattening.

### Ce que Lyxal Image NE FAIT PAS (Par Design)

*   ❌ **Layout Intelligent** : Pas de "bouton qui s'agrandit". C'est le rôle de *Lyxal Layout*.
*   ❌ **Vidéo** : Pas de timeline. C'est le rôle de *Lyxal Video*.
*   ❌ **Réseau** : Pas de téléchargement d'URL. Les assets doivent être fournis.
*   ❌ **Inférence ML** : Pas de modèle lourd chargé dans le process de rendu.

---

## 🗺️ Roadmap Prioritaire

La validation du CTO a fixé la priorité suivante pour transformer ce moteur de rendu en solution produit complète :

1.  **Lyxal Layout Engine** : Pour permettre les templates dynamiques.
2.  **Lyxal Video Engine** : Pour attaquer le marché TikTok/Reels.
3.  **Lyxal ML** : Pour les features "Magiques".

---

> *"Zéro manque fonctionnel, mais séparation stricte des responsabilités."*
