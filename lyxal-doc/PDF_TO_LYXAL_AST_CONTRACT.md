# Contrat PDF → AST Lyxal

**Version**: 1.0.0  
**Date**: 2026-01-17  
**Auteur**: Lyxal Engineering  
**Statut**: ✅ OFFICIEL

---

## 1. Objectif

Ce document définit le **contrat formel** entre les fichiers PDF et l'AST (Abstract Syntax Tree) Lyxal Office.

**Lyxal Office n'est PAS un lecteur PDF générique.**  
**Lyxal Office EST un éditeur sémantique qui sait importer des PDF.**

### Doctrine produit

> **"Tout document PDF importé dans Lyxal Office devient un document Lyxal natif. Le PDF n'est jamais modifié, seulement interprété."**

Cette doctrine signifie :
- Le fichier PDF source reste **intact** (lecture seule)
- L'import produit un **nouvel** AST Lyxal indépendant
- Les modifications se font sur l'AST, jamais sur le PDF
- L'export peut produire un nouveau PDF si nécessaire

### Philosophie

```
PDF (présentation visuelle) → AST Lyxal (structure sémantique) → Édition → Export
```

L'objectif n'est pas de reproduire Acrobat, mais de **comprendre** le document pour le rendre éditable.

---

## 2. Compatibilité PDF

### Versions supportées

| Version PDF | Support | Notes |
|-------------|---------|-------|
| PDF 1.0 - 1.4 | ✅ Complet | Standard |
| PDF 1.5 - 1.7 | ✅ Complet | Compression objets, cross-ref streams |
| PDF 2.0 | ✅ Partiel | Fonctionnalités core uniquement |

### Chiffrement supporté

| Algorithme | Support |
|------------|---------|
| RC4 40-bit (V1) | ✅ |
| RC4 128-bit (V2) | ✅ |
| AES-128 (AESV2) | ✅ |
| AES-256 (AESV3) | ✅ |
| Certificats X.509 | ❌ Hors périmètre |

---

## 3. Extraction garantie (Socle industriel)

### 3.1 Métadonnées

| Donnée PDF | Extraction | Type Lyxal |
|------------|------------|------------|
| `/Title` | ✅ Garanti | `Document.metadata.title` |
| `/Author` | ✅ Garanti | `Document.metadata.author` |
| `/Creator` | ✅ Garanti | `Document.metadata.creator` |
| `/Producer` | ✅ Garanti | `Document.metadata.producer` |
| `/CreationDate` | ✅ Garanti | `Document.metadata.created_at` |
| `/ModDate` | ✅ Garanti | `Document.metadata.modified_at` |
| `/Keywords` | ✅ Garanti | `Document.metadata.keywords[]` |
| `/Subject` | ✅ Garanti | `Document.metadata.subject` |
| XMP Metadata | ⚠️ Partiel | Extraction brute si présent |

### 3.2 Structure du document

| Élément PDF | Extraction | Mapping AST |
|-------------|------------|-------------|
| Pages | ✅ Garanti | `Document.pages[]` |
| MediaBox | ✅ Garanti | `Page.dimensions` |
| CropBox | ✅ Garanti | `Page.crop_area` |
| Rotation | ✅ Garanti | `Page.rotation` |
| Bookmarks/Outlines | ✅ Garanti | `Document.toc[]` → `Block::TableOfContents` |
| Named Destinations | ✅ Garanti | `Document.destinations[]` |

### 3.3 Contenu textuel

| Élément PDF | Extraction | Détails |
|-------------|------------|---------|
| Texte (Tj, TJ, ', ") | ✅ Garanti | Position x,y, taille police |
| Police (Tf) | ✅ Garanti | Nom, taille |
| Couleur texte | ✅ Garanti | RGB/CMYK → RGBA |
| Mode rendu (Tr) | ✅ Garanti | Fill, Stroke, Invisible, Clip |
| Matrice texte (Tm) | ✅ Garanti | Position, échelle, rotation |
| Espacement (Tc, Tw) | ✅ Garanti | Character/word spacing |

**Encodages supportés**:
- WinAnsiEncoding ✅
- MacRomanEncoding ✅
- StandardEncoding ✅
- PDFDocEncoding ✅
- UTF-16BE (Unicode) ✅
- ToUnicode CMap ✅
- Identity-H/V ✅

### 3.4 Images

| Format/Filtre | Support | Notes |
|---------------|---------|-------|
| FlateDecode (PNG-like) | ✅ Complet | Avec predictors |
| DCTDecode (JPEG) | ✅ Complet | Décodage RGB |
| CCITTFaxDecode (G3/G4) | ✅ Complet | Documents scannés |
| JBIG2Decode | ✅ Complet | Compression avancée |
| LZWDecode | ✅ Complet | Avec predictors |
| ASCIIHexDecode | ✅ Complet | |
| ASCII85Decode | ✅ Complet | |
| RunLengthDecode | ✅ Complet | |
| JPXDecode (JPEG2000) | ⚠️ Données brutes | Rare, passthrough |

**Color spaces supportés**:
- DeviceGray ✅
- DeviceRGB ✅
- DeviceCMYK ✅ (conversion RGB)
- Indexed ✅
- ICCBased ✅ (fallback DeviceRGB)
- CalGray/CalRGB ✅

### 3.5 Graphiques vectoriels

| Opérateur PDF | Extraction | Mapping |
|---------------|------------|---------|
| m (moveto) | ✅ | `PathOp::MoveTo` |
| l (lineto) | ✅ | `PathOp::LineTo` |
| c (curveto) | ✅ | `PathOp::CurveTo` |
| v, y (curves) | ✅ | `PathOp::CurveTo` |
| h (closepath) | ✅ | `PathOp::ClosePath` |
| re (rectangle) | ✅ | `PathOp::Rectangle` |
| S, s (stroke) | ✅ | `Path.stroke` |
| f, F, f* (fill) | ✅ | `Path.fill` |
| B, B*, b, b* | ✅ | Fill + Stroke |
| W, W* (clip) | ✅ | `ClipPath` |

**Attributs graphiques**:
- Line width (w) ✅
- Line cap (J) ✅
- Line join (j) ✅
- Miter limit (M) ✅
- Dash pattern (d) ✅
- Couleurs stroke/fill ✅
- Transparency (ca, CA) ✅
- Blend modes ✅

### 3.6 Formulaires (AcroForm)

| Type de champ | Extraction | Mapping AST |
|---------------|------------|-------------|
| Text field | ✅ Complet | `Block::FormField::Text` |
| Checkbox | ✅ Complet | `Block::FormField::Checkbox` |
| Radio button | ✅ Complet | `Block::FormField::Radio` |
| Combo box | ✅ Complet | `Block::FormField::Select` |
| List box | ✅ Complet | `Block::FormField::MultiSelect` |
| Push button | ✅ Complet | `Block::FormField::Button` |
| Signature | ✅ Lecture | `Block::FormField::Signature` |

**Attributs extraits**:
- Nom du champ ✅
- Valeur courante ✅
- Valeur par défaut ✅
- Options (pour listes) ✅
- Flags (readonly, required, etc.) ✅
- Rectangle de position ✅
- Page associée ✅

### 3.7 Annotations

| Type | Extraction | Mapping AST |
|------|------------|-------------|
| Link | ✅ Complet | `Block::Link` |
| Text (note) | ✅ Complet | `Block::Comment` |
| Highlight | ✅ Complet | `Span::Highlight` |
| Underline | ✅ Complet | `Span::Underline` |
| StrikeOut | ✅ Complet | `Span::Strikethrough` |
| FreeText | ✅ Complet | `Block::Annotation` |
| Stamp | ✅ Complet | `Block::Stamp` |
| Popup | ✅ Complet | Attaché au parent |

### 3.8 Pièces jointes (Attachments)

| Donnée | Extraction |
|--------|------------|
| Filename | ✅ Garanti |
| Description | ✅ Garanti |
| MIME type | ✅ Garanti |
| Creation date | ✅ Garanti |
| Modification date | ✅ Garanti |
| File size | ✅ Garanti |
| Binary data | ✅ Garanti (décompressé) |
| Checksum | ✅ Si présent |

### 3.9 Structure Tree (PDF balisé)

| Élément | Extraction | Mapping AST |
|---------|------------|-------------|
| Document | ✅ | `Document` |
| Part | ✅ | `Section` |
| Sect | ✅ | `Section` |
| H1-H6 | ✅ | `Block::Heading{level}` |
| P | ✅ | `Block::Paragraph` |
| L (List) | ✅ | `Block::List` |
| LI | ✅ | `Block::ListItem` |
| Table | ✅ | `Block::Table` |
| TR | ✅ | `Block::TableRow` |
| TH | ✅ | `Block::TableCell{header:true}` |
| TD | ✅ | `Block::TableCell` |
| Figure | ✅ | `Block::Figure` |
| Formula | ✅ | `Block::Math` |
| Link | ✅ | `Span::Link` |
| Span | ✅ | `Span` |
| Quote | ✅ | `Block::Quote` |
| Code | ✅ | `Block::Code` |

---

## 4. Transformation PDF → AST Lyxal

### 4.1 Algorithme de conversion

```
┌─────────────────────────────────────────────────────────────┐
│                      PDF Source                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  1. Extraction brute (lopdf)                                │
│     - Objets PDF                                            │
│     - Streams décompressés                                  │
│     - Content streams parsés                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Modèle intermédiaire (PdfDocument)                      │
│     - PdfPage[]                                             │
│     - PdfElement[] (Text, Image, Path)                      │
│     - PdfFormField[]                                        │
│     - PdfAnnotation[]                                       │
│     - PdfBookmark[]                                         │
│     - PdfAttachment[]                                       │
│     - PdfStructureTree                                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Reconstruction sémantique                               │
│     - Groupement lignes/paragraphes                         │
│     - Détection colonnes                                    │
│     - Identification listes                                 │
│     - Détection tableaux                                    │
│     - Hiérarchie titres                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  4. AST Lyxal                                               │
│     - Document                                              │
│       - metadata                                            │
│       - sections[]                                          │
│         - blocks[]                                          │
│           - Paragraph, Heading, List, Table, Image...       │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Règles de mapping

#### Texte → Paragraphes

```
PDF TextElements avec:
  - même Y (± tolérance)
  - même police/taille
  - espacement normal
                    ↓
      Block::Paragraph {
        spans: [Span::Text { content, style }]
      }
```

#### Images → Block::Image

```
PdfImage {
  data, width, height, color_space
}
                    ↓
      Block::Image {
        source: ImageSource::Embedded(data),
        alt_text: from_structure_tree_or_empty,
        width, height
      }
```

#### Paths → Block::Shape

```
PdfPath {
  ops, stroke_color, fill_color, line_width
}
                    ↓
      Block::Shape {
        path: SvgPath::from(ops),
        stroke, fill
      }
```

#### Formulaires → Block::FormField

```
PdfFormField::Text { name, value, rect }
                    ↓
      Block::FormField {
        field_type: FieldType::Text,
        name, value,
        intent: Intent::UserInput
      }
```

#### Bookmarks → TableOfContents

```
PdfBookmark[] (hiérarchique)
                    ↓
      Block::TableOfContents {
        entries: [
          TocEntry { title, page, level, children }
        ]
      }
```

#### Structure Tree → AST direct

Si le PDF est balisé (tagged), la structure est **directement mappée** :

```
StructureElement::H1 { actual_text: "Titre" }
                    ↓
      Block::Heading { level: 1, content: "Titre" }

StructureElement::Table { children: [TR, TR, ...] }
                    ↓
      Block::Table { rows: [...] }
```

---

## 5. Hors périmètre (par design)

### 5.1 Fonctionnalités ignorées

| Fonctionnalité | Raison | Alternative |
|----------------|--------|-------------|
| **JavaScript** | Sécurité + hors scope bureautique | Ignoré silencieusement |
| **3D Content (U3D, PRC)** | Complexité, usage rare | Ignoré |
| **Multimédia (vidéo, audio)** | Hors scope document | Ignoré |
| **XFA Forms** | Obsolète (deprecated PDF 2.0) | AcroForm uniquement |
| **Pixel-perfect rendering** | Pas l'objectif | Export PDF/image si besoin |
| **Signatures création** | Nécessite HSM/certificats | Lecture seule |
| **Redaction** | Opération destructive | Non supporté |
| **Layers (OCG)** | Complexité | Aplati à l'import |
| **Transparency groups complexes** | Rendu uniquement | Simplifié |

### 5.2 Comportement en cas de contenu non supporté

| Situation | Comportement |
|-----------|--------------|
| JavaScript présent | Log warning, continue |
| 3D/Multimédia | Placeholder dans AST |
| XFA Form | Erreur explicite (pas de fallback) |
| Encryption inconnue | Erreur explicite |
| Filtre image inconnu | Données brutes préservées |

### 5.3 Dégradation contrôlée

Lorsque la reconstruction sémantique échoue partiellement :

| Situation | Stratégie |
|-----------|-----------|
| Structure non identifiée | `Block::Raw` avec contenu brut |
| Intent ambigu | `Intent::Unknown` préservé |
| Texte mal encodé | Préservé tel quel + flag `encoding_issue` |
| Image non décodable | `Block::Image` avec données brutes |
| Formulaire corrompu | Champs extraits individuellement |

**Principe fondamental** : 
> **Aucune donnée n'est supprimée.** En cas de doute, le contenu brut est préservé dans un bloc `Raw` ou `Unknown`, permettant une récupération manuelle ou une amélioration future de l'algorithme.

```json
{
  "type": "Block::Raw",
  "reason": "structure_unrecognized",
  "source": "pdf_content_stream",
  "raw_content": "...",
  "page_index": 3,
  "position": {"x": 72, "y": 500}
}
```

---

## 6. Exemples JSON → AST

### 6.1 Document simple

**PDF extrait (JSON):**
```json
{
  "metadata": {
    "title": "Rapport Annuel 2025",
    "author": "Jean Dupont"
  },
  "pages": [{
    "index": 0,
    "elements": [
      {"type": "text", "content": "Rapport Annuel", "x": 72, "y": 750, "font_size": 24},
      {"type": "text", "content": "Introduction", "x": 72, "y": 700, "font_size": 18},
      {"type": "text", "content": "Ce document présente...", "x": 72, "y": 670, "font_size": 12}
    ]
  }],
  "bookmarks": [
    {"title": "Introduction", "page_index": 0, "level": 0}
  ]
}
```

**AST Lyxal:**
```json
{
  "type": "Document",
  "metadata": {
    "title": "Rapport Annuel 2025",
    "author": "Jean Dupont"
  },
  "import": {
    "source": "pdf",
    "source_file": "rapport_2025.pdf",
    "pdf_version": "1.4",
    "confidence": 0.95,
    "lossy": false,
    "imported_at": "2026-01-17T14:30:00Z",
    "parser_version": "1.0.0"
  },
  "children": [
    {
      "type": "Heading",
      "level": 1,
      "content": "Rapport Annuel"
    },
    {
      "type": "Heading", 
      "level": 2,
      "content": "Introduction"
    },
    {
      "type": "Paragraph",
      "spans": [
        {"type": "Text", "content": "Ce document présente..."}
      ]
    }
  ],
  "toc": {
    "type": "TableOfContents",
    "entries": [
      {"title": "Introduction", "page": 1, "level": 1}
    ]
  }
}
```

### 6.2 Formulaire

**PDF extrait:**
```json
{
  "form_fields": [
    {
      "name": "nom_complet",
      "field_type": "Text",
      "value": "Marie Martin",
      "rect": {"x1": 100, "y1": 700, "x2": 300, "y2": 720}
    },
    {
      "name": "accepte_conditions",
      "field_type": "Button",
      "button_state": {"On": "Yes"}
    }
  ]
}
```

**AST Lyxal:**
```json
{
  "type": "Form",
  "fields": [
    {
      "type": "FormField",
      "field_type": "text",
      "name": "nom_complet",
      "label": "Nom complet",
      "value": "Marie Martin",
      "intent": "user_input"
    },
    {
      "type": "FormField",
      "field_type": "checkbox",
      "name": "accepte_conditions",
      "label": "J'accepte les conditions",
      "checked": true,
      "intent": "consent"
    }
  ]
}
```

### 6.3 PDF balisé (Tagged PDF)

**Structure Tree extraite:**
```json
{
  "structure_tree": {
    "children": [
      {
        "struct_type": "Document",
        "children": [
          {"struct_type": "H1", "actual_text": "Titre"},
          {"struct_type": "P", "actual_text": "Premier paragraphe."},
          {
            "struct_type": "L",
            "children": [
              {"struct_type": "LI", "children": [
                {"struct_type": "Lbl", "actual_text": "•"},
                {"struct_type": "LBody", "actual_text": "Item 1"}
              ]},
              {"struct_type": "LI", "children": [
                {"struct_type": "Lbl", "actual_text": "•"},
                {"struct_type": "LBody", "actual_text": "Item 2"}
              ]}
            ]
          }
        ]
      }
    ]
  }
}
```

**AST Lyxal (mapping direct):**
```json
{
  "type": "Document",
  "children": [
    {"type": "Heading", "level": 1, "content": "Titre"},
    {"type": "Paragraph", "content": "Premier paragraphe."},
    {
      "type": "List",
      "ordered": false,
      "items": [
        {"type": "ListItem", "content": "Item 1"},
        {"type": "ListItem", "content": "Item 2"}
      ]
    }
  ]
}
```

### 6.4 Métadonnées d'import (Traçabilité)

Chaque document importé contient un bloc `import` qui permet :
- **Debug** : identifier la source des problèmes
- **IA** : adapter le traitement selon l'origine
- **Audit** : tracer l'historique du document
- **UX** : différencier document natif vs importé

```json
{
  "import": {
    "source": "pdf",
    "source_file": "document.pdf",
    "pdf_version": "1.7",
    "confidence": 0.92,
    "lossy": false,
    "imported_at": "2026-01-17T14:30:00Z",
    "parser_version": "1.0.0",
    "warnings": [
      {"type": "font_substitution", "original": "CustomFont", "replacement": "Arial"},
      {"type": "unsupported_feature", "feature": "JavaScript", "action": "ignored"}
    ],
    "stats": {
      "pages": 12,
      "text_elements": 1547,
      "images": 8,
      "forms_fields": 23,
      "structure_tree_present": true
    }
  }
}
```

| Champ | Type | Description |
|-------|------|-------------|
| `source` | string | Type de source (`"pdf"`, `"docx"`, `"native"`) |
| `source_file` | string | Nom du fichier original |
| `pdf_version` | string | Version PDF détectée |
| `confidence` | float | Score de confiance global (0.0 - 1.0) |
| `lossy` | bool | `true` si des données ont été perdues |
| `imported_at` | datetime | Timestamp d'import |
| `parser_version` | string | Version du parser utilisé |
| `warnings` | array | Liste des avertissements |
| `stats` | object | Statistiques d'extraction |

**Usage du score de confiance** :

| Score | Interprétation |
|-------|----------------|
| 0.95+ | PDF parfaitement structuré (tagged PDF) |
| 0.80 - 0.95 | Import fiable, structure reconstruite |
| 0.60 - 0.80 | Reconstruction partielle, vérification recommandée |
| < 0.60 | PDF complexe/sale, édition manuelle probable |

---

## 7. Garanties et limitations

### 7.1 Ce que Lyxal Office garantit

✅ **Fidélité du contenu** : Tout le texte est extrait  
✅ **Préservation des images** : Décodées et intégrées  
✅ **Structure sémantique** : Reconstituée intelligemment  
✅ **Formulaires éditables** : Import/export fidèle  
✅ **Navigation préservée** : TOC, liens, destinations  
✅ **Accessibilité** : Structure tree exploitée si présente  
✅ **Pièces jointes** : Extraites et ré-attachables  

### 7.2 Ce que Lyxal Office NE garantit PAS

❌ **Rendu pixel-perfect** : L'objectif est l'édition, pas la reproduction  
❌ **Mise en page identique** : La structure prime sur la forme  
❌ **Polices exactes** : Substitution par polices système  
❌ **Effets visuels complexes** : Simplifiés ou ignorés  

---

## 8. Évolution du contrat

### Versioning

- **1.0.0** (2026-01-17) : Version initiale
- Les modifications breaking incrémentent MAJOR
- Les ajouts de features incrémentent MINOR
- Les corrections incrémentent PATCH

### Processus de modification

1. RFC interne avec justification
2. Review impact sur AST existant
3. Migration path documenté
4. Tests de non-régression
5. Mise à jour de ce document

---

## 9. Références

- [PDF Reference 1.7](https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf)
- [PDF 2.0 (ISO 32000-2:2020)](https://www.iso.org/standard/75839.html)
- [Tagged PDF (PDF/UA)](https://www.iso.org/standard/64599.html)
- [Lyxal AST Specification](./SPECIFICATION_LANGAGE_LYXAL.md)

---

**Ce contrat est la référence officielle pour toute intégration PDF dans Lyxal Office.**

```
╔═══════════════════════════════════════════════════════════════╗
║  Lyxal Office - PDF Native depuis 2026                        ║
║  "Comprendre le document, pas juste l'afficher"               ║
╚═══════════════════════════════════════════════════════════════╝
```
