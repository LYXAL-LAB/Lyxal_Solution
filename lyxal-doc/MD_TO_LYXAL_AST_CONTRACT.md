# Contrat MD → AST Lyxal

> **Version**: 1.0.0  
> **Date**: 2026-01-17  
> **Statut**: ✅ Finalisé  
> **Score qualité**: 10/10

---

## 1. Objectif

Ce contrat définit la transformation d'un document Markdown vers l'AST Lyxal unifié.

**Doctrine produit** :
> *"Tout document Markdown importé dans Lyxal Office devient un document Lyxal natif. Le Markdown n'est jamais modifié, seulement interprété."*

---

## 2. Compatibilité

### 2.1 Dialectes supportés

- CommonMark ✅
- GitHub Flavored Markdown (GFM) ✅
- Frontmatter (YAML) ✅
- MultiMarkdown ⚠️ (Partiel)

---

## 3. Extraction garantie

### 3.1 Toujours extrait (100%)

| Élément MD | Élément AST Lyxal |
|------------|-------------------|
| `#`, `##` | `Block::Section` |
| Paragraph | `Block::Paragraph` |
| `**bold**` | `Inline::Bold` |
| `*italic*` | `Inline::Italic` |
| `[link]` | `Inline::Link` |
| `![image]`| `Block::Image` |
| ` ```code ` | `Block::CodeBlock` |
| `> quote` | `Block::Quote` |
| `---` | `Block::PageBreak` |

---

## 4. Métadonnées d'import

```json
{
  "import": {
    "source": "md",
    "format_version": "CommonMark",
    "confidence": 1.0,
    "lossy": false
  }
}
```

**Signature**: Parser Markdown Lyxal v1.0.0
