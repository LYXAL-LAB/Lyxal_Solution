# STATUS_CTO_LYXAL_IMAGE.md

> **Date** : 2025-12-16
> **Objet** : Audit strict et Plan de récupération (Suite incident machine)

## 1. Inventaire Repo (Vérité Terrain)

### Pipeline Steps (`pipeline.rs`)
| Action (JSON) | Paramètres | Validation | Implémentation |
| :--- | :--- | :--- | :--- |
| `resize` | `w`, `h` (u32) | Aucune borne explicite par step (mais quota global) | `ops.rs` (Lanczos3 via `fast_image_resize`) |
| `crop` | `x`, `y`, `w`, `h` (u32) | - | `ops.rs` (`image::crop_imm`) |
| `blur` | `sigma` (f32) | - | `filters.rs` |
| `grayscale` | - | - | `filters.rs` |
| `text` | `text`, `x`, `y`, `size`, `color` | Check alpha > 0 | `text.rs` (`cosmic-text` + blending manuel) |
| `watermark_svg`| `svg`, `x`, `y`, `scale` | - | `vector.rs` (`resvg` / `tiny-skia`) |
| `embed_secret` | `secret` (String) | LSB 1-bit | `secure.rs` (**Extraction manquante**) |

### Fonctions Disponibles
*   **Core** : Chargement/Sauvegarde (`lib.rs`, `core.rs`) avec détection format.
*   **Ops** : `resize`, `crop`.
*   **Filters** : `blur`, `grayscale`, `apply_lut` (Stub: vide).
*   **Text** : Moteur `cosmic-text` avec cache de font global (`lazy_static`).
*   **Vector** : Rendu SVG via `resvg` sur `tiny-skia` pixmap.
*   **Secure** :
    *   `phash` (Perceptual Hash) : OK (double gradient).
    *   `embed_secret` : OK.
    *   **Extact Secret** : ❌ Inexistant.
*   **ML** :
    *   `detect_primary_face` : ⚠️ **STUB** (renvoie `(100,100,200,200)` en dur).
    *   Modèle ONNX : Le code de chargement est là (`tract-onnx`), mais l'inférence est bouchonnée.

### Sandbox & Sécurité
| Contrôle | État | Localisation |
| :--- | :--- | :--- |
| **Input Size** | ✅ Hard limit 100 MB | `core.rs:16` |
| **Dimensions** | ✅ Configurable (Def: 8192x8192) | `core.rs:29` |
| **Pixel Bomb** | ✅ Configurable (Def: 50MP) | `core.rs:36` |
| **Max Steps** | ✅ Configurable (Def: 20) | `pipeline.rs:27` |
| **FS Sandbox** | ⚠️ Partiel/Inexistant | Pas de whitelist explicite vue pour charger des assets (fontes, luts). `apply_lut` prend un path mais est vide. |
| **Panic** | ⚠️ Risque | Utilisation de `unwrap()` dans `ops.rs` (resize buffer), `text.rs` (hex parsing), `vector.rs`. |

### Tests & Documentation
*   **Tests** : build réparé (dépendances corrigées). *Résultats en attente*.
*   **README** : ❌ Absent. Aucune documentation d'utilisation à la racine.

---

## 2. Gap Analysis vs Spec Validée

| Bloc | Fonctionnalité | État | Détails / Manques |
| :--- | :--- | :--- | :--- |
| **Stabilisation** | **Build & Deps** | ⚠️ Partiel | `Cargo.lock` corrompu (réparé), Conflits de versions. |
| | **Validations** | ⚠️ Partiel | Panics possibles (`unwrap`). Pas de validation fine par step. |
| | **Tests/Docs** | ❌ CRITIQUE | Pas de tests unitaires métier visibles. Pas de doc. |
| **Bloc 1** | **Ajustements** | ⚠️ Partiel | Resize/Crop OK. Manque Brightness/Contrast/Saturation. |
| **Bloc 3** | **Effets Artistiques**| ❌ Manquant | `blur` ok, `grayscale` ok. Manque tout le reste (LUT, filters créatifs). |
| **Bloc 4** | **Shapes** | ❌ Manquant | Rien. Uniquement SVG overlay (pas de primitives natives). |
| **Bloc 2** | **Blend Modes** | ❌ Manquant | Rien. |
| **Bloc 5** | **Layers** | ❌ Manquant | Pipeline linéaire simple, pas de composition multi-calques complexe. |
| **ML** | **Face Detect** | ⚠️ STUB | Code présent mais mocké. |

---

## 3. Plan de Récupération

**Priorité Absolue : Stabilisation (Socle)**
1.  **Tests** : Créer une suite de tests unitaires couvrant chaque Step existant.
2.  **Safety** : Remplacer tous les `unwrap()` par des `Result`.
3.  **Docs** : Rédiger `README.md` (installation, exemple JSON).

** Roadmap Features (Ordre Strict)**
1.  **ML (Fix)** : Brancher le modèle ONNX réel pour `detect_primary_face`.
2.  **Secure (Fix)** : Implémenter `extract_secret` pour valider la stéganographie.
3.  **Bloc 1 (Finish)** : Ajouter Brightness/Contrast/Saturation.
4.  **Bloc 3 (Art)** : Implémenter LUT (réel) et filtres basiques.
5.  **Bloc 4, 2, 5** : À planifier ultérieurement.

> **Instruction** : Code gelé tant que ce rapport n'est pas validé.
