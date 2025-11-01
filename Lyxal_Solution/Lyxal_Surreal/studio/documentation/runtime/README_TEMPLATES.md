# 📐 Templates de Pages - Guide Rapide

**Résumé :** Les templates permettent de réutiliser et catégoriser des structures de pages complètes pour différents cas d'usage.

---

## 🎯 Concept en 30 secondes

**Template** = Un modèle réutilisable contenant plusieurs pages pré-configurées pour un cas d'usage spécifique.

**Exemple :**
- **Template "Ecommerce HiTech"** (catégorie: `ecommerce`, sous-catégorie: `hitech`)
  - Contient : page catalogue, page produit, panier, checkout
  - Réutilisable pour créer de nouvelles boutiques tech

---

## 📋 Structure

```
studio_template_category      → Catégories principales (ecommerce, saas, etc.) avec i18n
studio_template_subcategory   → Sous-catégories (hitech, mode, etc.) avec i18n
studio_template
    ├── identity.code          → "ecommerce_hitech"
    ├── categorization          → category: studio_template_category:ecommerce
    │                            subcategory: studio_template_subcategory:hitech
    ├── pages[]                → [studio_page:product_catalog, ...]
    ├── config                 → Prérequis, thème recommandé
    └── status                 → is_active, is_featured
```

---

## 🔗 Relation avec `studio_page`

**1 template** contient **N pages** (références vers `studio_page`)

```surql
studio_template:ecommerce_hitech {
    pages: [
        studio_page:product_catalog,
        studio_page:product_detail,
        studio_page:shopping_cart
    ]
}
```

---

## 📚 Catégories Suggérées

| Catégorie | Sous-catégories possibles |
|-----------|---------------------------|
| `ecommerce` | `hitech`, `mode`, `alimentaire`, `luxe` |
| `saas` | `crm`, `analytics`, `project_management` |
| `portfolio` | `designer`, `developer`, `photographer` |
| `blog` | `news`, `tutorial`, `lifestyle` |
| `landing` | `product_launch`, `event`, `webinar` |
| `corporate` | `business`, `agency`, `nonprofit` |

---

## 📖 Documentation Complète

- **📘 [TEMPLATES_PAGES.md](./TEMPLATES_PAGES.md)** - Documentation complète avec schéma, exemples, cas d'usage

---

**Créé le :** 2025-01-31

