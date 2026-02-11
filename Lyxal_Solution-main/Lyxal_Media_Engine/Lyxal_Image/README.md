# Lyxal Image - Module de Traitement d'Image Sécurisé

Ce module Rust fournit un pipeline de traitement d'image haute performance, conçu pour être sûr (no panic), stable et respectueux des quotas.

> 📘 **Architecture & Vision** : Pour comprendre la place de ce module dans l'écosystème Lyxal Media Engine (Layout, Vidéo, ML), voir [ARCHITECTURE.md](ARCHITECTURE.md).

## 🚀 Installation

Ajouter à `Cargo.toml` (dépendances gérées) :
```toml
[dependencies]
lyxal_image = { path = "." }
```

## 🛡️ Sécurité & Quotas

Le module applique des règles strictes pour protéger l'infrastructure :

*   **Zéro Panic** : Toutes les erreurs sont capturées et retournées proprement via `LyxalResult`.
*   **Pipeline Validé** : Chaque étape vérifie ses paramètres avant exécution.
*   **Quotas** :
    *   Taille entrée : Max 100 MB.
    *   Pixels : Max 50 MPixels (anti zip-bomb).
    *   Dimensions : Max 8192x8192 (configurable).
    *   Secret Stéganographie : Max 1KB.
*   **Sandbox** : Le chargement de ressources externes (fichiers dans SVG) est désactivé.

## 🛠️ Utilisation

Le principal point d'entrée est la fonction `pipeline::process`.

### Exemple Rust

```rust
use lyxal_image::{process, ImageContext};

let input_bytes = std::fs::read("input.jpg")?;
let context = ImageContext::default(); // Utilise les quotas par défaut

let pipeline_json = r#"{
    "steps": [
        { "action": "resize", "w": 800, "h": 600 },
        { "action": "grayscale" },
        { "action": "text", "text": "Copyright", "x": 10, "y": 50, "size": 48.0, "color": "#FFFFFF" }
    ]
}"#;

let result_bytes = process(&input_bytes, pipeline_json, context)?;
std::fs::write("output.png", result_bytes)?;
```

## 📋 Actions Pipeline Disponibles

| Action | Paramètres | Description | Contraintes |
| :--- | :--- | :--- | :--- |
| `resize` | `w`, `h` (int) | Redimensionne l'image (Lanczos3). | `> 0` et `<= MaxDims`. |
| `crop` | `x`, `y`, `w`, `h` (int) | Recadre l'image. | `w,h > 0`. |
| `blur` | `sigma` (float) | Flou Gaussien. | `0.1` à `100.0`. |
| `grayscale` | - | Convertit en N&B. | - |
| `text` | `text`, `x`, `y`, `size`, `color` | Ajoute du texte. | `text` non vide, `size > 0`. |
| `watermark_svg` | `svg` (string), `x`, `y`, `scale` | Superpose un SVG. | `scale > 0`. Backend `resvg` 0.36 + `usvg` (SVG 1.1). |
| `embed_secret` | `secret` (string) | Cache un texte dans l'image (LSB). | Max 1KB. |

### Bloc 1 : Ajustements Photo
| Action | Paramètres | Description | Bornes Validées |
| :--- | :--- | :--- | :--- |
| `brightness` | `value` (f32) | Ajuste la luminosité. | `[-1.0, 1.0]` |
| `contrast` | `value` (f32) | Ajuste le contraste. | `[-1.0, 1.0]` |
| `saturation` | `value` (f32) | Ajuste la saturation (N&B <-> Vif). | `[-1.0, 3.0]` |
| `temperature` | `value` (f32) | Ajuste la température (Froid <-> Chaud). | `[-1.0, 1.0]` |
| `tint` | `value` (f32) | Ajuste la teinte (Vert <-> Magenta). | `[-1.0, 1.0]` |
| `shadows` | `value` (f32) | Eclaircit les tons foncés. | `[0.0, 1.0]` |
| `highlights` | `value` (f32) | Assombrit les tons clairs. | `[0.0, 1.0]` |
| `sharpness` | `value` (f32) | Améliore la netteté (Unsharp Mask). | `[0.0, 5.0]` |
| `vignette` | `value` (f32) | Ajoute un vignettage sombre aux coins. | `[0.0, 1.0]` |
| `sepia` | `value` (f32) | Applique un effet sépia progressif. | `[0.0, 1.0]` |

### Bloc 3 : Effets Artistiques
| Action | Paramètres | Description | Bornes Validées |
| :--- | :--- | :--- | :--- |
| `pixelate` | `size` (u32) | Pixelise l'image par blocs. | `size > 1` |
| `posterize` | `levels` (u8) | Réduit le nombre de couleurs (posterisation). | `[2, 16]` |
| `noise` | `intensity` (f32) | Ajoute du bruit RGB déterministe. | `[0.0, 1.0]` |
| `duotone` | `color1`, `color2` (Hex) | Mappe la luminance sur un dégradé bi-colore. | Hex valide (`#RRGGBB`). |
| `glitch_horizontal` | - | Décale les canaux RGB horizontalement. | - |
| `glitch_vertical` | - | Décale les canaux RGB verticalement. | - |

### Bloc 4 : Formes Géométriques (Shapes)
Toutes les formes supportent `fill` et `stroke` (Hex #RRGGBB) et `stroke_width` (f32).

| Action | Paramètres Spécifiques | Description |
| :--- | :--- | :--- |
| `shape_rect` | `x`, `y`, `width`, `height` | Rectangle. |
| `shape_circle` | `cx`, `cy`, `radius` | Cercle. |
| `shape_line` | `x1`, `y1`, `x2`, `y2` | Ligne simple. |
| `shape_arrow` | `x1`, `y1`, `x2`, `y2`, `head_size` | Flèche vectorielle. |
| `shape_polygon` | `points` (`[[x,y], ...]`) | Polygone (min 3 pts). |

### Bloc 2 : Modes de Fusion (Blend Modes)
Applique une couleur de fusion sur l'image courante.
Action : `blend`.
Paramètres :
- `mode` (string) : `multiply`, `screen`, `overlay`, `darken`, `lighten`, `difference`, `color_burn`, `color_dodge`, `soft_light`.
- `color` (string) : Couleur hexadécimale `#RRGGBB` (simule un calque uni temporaire).

### Bloc 5 : Layers (Composition Multi-Calques)
Système de composition avancé. Remplace `steps`.
Clé JSON : `layers` (liste).
Structure d'un Layer :
```json
{
  "type": "image | shape_rect | shape_circle | shape_line | shape_arrow",
  "params": { /* Paramètres spécifiques à la shape */ },
  "opacity": 0.8, // 0.0 à 1.0 (Défaut 1.0)
  "blend": "overlay", // Mode de fusion (Défaut "normal")
  "visible": true // (Défaut true)
}
```
*Note sur Layer 0* : Utilisez `{ "type": "image" }` comme premier layer pour base.

## ⚠️ Limitations Connues
*   **ML** : La détection faciale (`detect_primary_face`) retourne `FeatureUnavailable` (Bloc futur).
*   **LUT** : Support LUT désactivé pour maintenance.
*   **SVG** :
    *   Le rendu est effectué via `resvg` (backend haute qualité).
    *   Pour des raisons de sécurité (Sandbox), le chargement de ressources externes (images liées, polices systèmes) est **strictement désactivé**. Le SVG doit être autonome (paths, shapes, styles inline).
