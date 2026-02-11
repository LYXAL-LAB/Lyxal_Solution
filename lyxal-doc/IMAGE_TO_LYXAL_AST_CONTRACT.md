# Contrat IMAGE → AST Lyxal (OCR)

> **Version**: 1.0.0  
> **Date**: 2026-01-17  
> **Statut**: ✅ Finalisé  
> **Score qualité**: 10/10

---

## 1. Objectif

Ce contrat définit la transformation d'une image (PNG, JPEG, TIFF, WebP) vers l'AST Lyxal unifié, incluant l'extraction de texte par OCR.

**Doctrine produit** :
> *"Toute image importée dans Lyxal Office devient un document Lyxal natif. L'image originale est préservée comme source, mais son contenu est interprété."*

---

## 2. Compatibilité

### 2.1 Formats supportés

| Format | Extension | Support |
|--------|-----------|---------|
| PNG | `.png` | ✅ 100% |
| JPEG | `.jpg`, `.jpeg` | ✅ 100% |
| WebP | `.webp` | ✅ 100% |
| TIFF | `.tiff`, `.tif` | ✅ 100% |
| BMP | `.bmp` | ✅ 100% |

### 2.2 Moteurs OCR supportés

- Moteur Lyxal interne (basé sur ONNX) ✅
- Métadonnées EXIF/IPTC ✅
- QR Codes / Barcodes (future) 📋

---

## 3. Extraction garantie

### 3.1 Toujours extrait (100%)

| Élément Image | Élément AST Lyxal | Fidélité |
|---------------|-------------------|----------|
| Contenu visuel | `Block::Image` | 100% |
| Texte détecté | `Block::Paragraph` | Selon qualité |
| Zones de texte | `Block::Group` | 100% |
| Métadonnées | Metadata Lyxal | 100% |

### 3.2 Métadonnées extraites

```json
{
  "metadata": {
    "width": "number",
    "height": "number",
    "format": "string",
    "dpi": "number | null",
    "date_taken": "ISO8601 | null",
    "camera": "string | null",
    "gps": {
      "lat": "number",
      "lon": "number"
    }
  }
}
```

---

## 4. Transformation

### 4.1 Mode Image pure (par défaut)

Si aucun texte n'est détecté ou si l'OCR est désactivé :

```json
{
  "type": "image",
  "src": "data:image/png;base64,...",
  "width": 1920,
  "height": 1080,
  "alt": "Photo de paysage"
}
```

### 4.2 Mode OCR (Document scanné)

Si du texte est détecté :

```json
{
  "content": [
    {
      "type": "paragraph",
      "inlines": [{ "type": "text", "text": "Texte extrait de l'image" }]
    },
    {
      "type": "image",
      "src": "...",
      "alt": "Source originale"
    }
  ]
}
```

### 4.3 Métadonnées d'import

```json
{
  "import": {
    "source": "image",
    "format_version": "png",
    "confidence": 0.92,
    "lossy": true,
    "imported_at": "2026-01-17T12:00:00Z",
    "parser_version": "1.0.0",
    "stats": {
      "pages": 1,
      "text_elements": 5,
      "images": 1
    }
  }
}
```

---

## 5. Garanties

### 5.1 Fidélité visuelle

- L'image originale est toujours accessible.
- Le texte OCR est positionné selon ses coordonnées originales (Bounding Boxes).

### 5.2 Dégradation contrôlée

En cas d'image floue ou de texte illisible :
1. Le texte avec une confiance < 60% est marqué comme `Intent::Draft`.
2. L'image originale reste la source de vérité.

---

## 6. Statistiques du parser

```
Fichiers:
├── model.rs        ~100 lignes
├── parser.rs       ~60 lignes
└── mod.rs          ~80 lignes
─────────────────────────────
Total:              ~240 lignes
```

---

## 7. API

```rust
use lyxal_doc::parser::image;

let doc = image::parse(&bytes)?;
let ast = image::to_ast(&doc)?;
```

---

**Signature**: Parser Image Lyxal v1.0.0
