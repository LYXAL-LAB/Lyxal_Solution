# URLs à créer pour icon_provider

Ce fichier liste tous les `record<url>` référencés dans `icon_provider_seeds.surql` qui doivent être créés dans la table `url`.

---

## 1. Lucide

### CDN Base URL
- **ID:** `url:icon_provider_lucide_base_cdn`
- **href:** `https://icons.lyxal.b-cdn.net/lucide/`
- **context.usage_type:** `asset`
- **context.module:** `builder_catalogue:studio_icon`

### Official URL
- **ID:** `url:icon_provider_lucide_official`
- **href:** `https://lucide.dev`
- **context.usage_type:** `documentation`
- **url.is_external:** `true`

### Docs URL
- **ID:** `url:icon_provider_lucide_docs`
- **href:** `https://lucide.dev/guide`
- **context.usage_type:** `documentation`
- **url.is_external:** `true`

### GitHub URL
- **ID:** `url:icon_provider_lucide_github`
- **href:** `https://github.com/lucide-icons/lucide`
- **context.usage_type:** `reference`
- **url.is_external:** `true`

---

## 2. Heroicons

- `url:icon_provider_heroicons_base_cdn` → `https://icons.lyxal.b-cdn.net/heroicons/`
- `url:icon_provider_heroicons_official` → `https://heroicons.com`
- `url:icon_provider_heroicons_docs` → `https://heroicons.com`
- `url:icon_provider_heroicons_github` → `https://github.com/tailwindlabs/heroicons`

---

## 3. Material Icons

- `url:icon_provider_material_icons_base_cdn` → `https://icons.lyxal.b-cdn.net/material-icons/`
- `url:icon_provider_material_icons_official` → `https://fonts.google.com/icons`
- `url:icon_provider_material_icons_docs` → `https://developers.google.com/fonts/docs/material_icons`
- `url:icon_provider_material_icons_github` → `https://github.com/google/material-design-icons`

---

## 4. Font Awesome

- `url:icon_provider_font_awesome_base_cdn` → `https://icons.lyxal.b-cdn.net/font-awesome/`
- `url:icon_provider_font_awesome_official` → `https://fontawesome.com`
- `url:icon_provider_font_awesome_docs` → `https://fontawesome.com/docs`
- `url:icon_provider_font_awesome_github` → `https://github.com/FortAwesome/Font-Awesome`

---

## 5. Feather Icons

- `url:icon_provider_feather_base_cdn` → `https://icons.lyxal.b-cdn.net/feather/`
- `url:icon_provider_feather_official` → `https://feathericons.com`
- `url:icon_provider_feather_docs` → `https://feathericons.com`
- `url:icon_provider_feather_github` → `https://github.com/feathericons/feather`

---

## 6. Bootstrap Icons

- `url:icon_provider_bootstrap_icons_base_cdn` → `https://icons.lyxal.b-cdn.net/bootstrap-icons/`
- `url:icon_provider_bootstrap_icons_official` → `https://icons.getbootstrap.com`
- `url:icon_provider_bootstrap_icons_docs` → `https://icons.getbootstrap.com`
- `url:icon_provider_bootstrap_icons_github` → `https://github.com/twbs/icons`

---

## 7. Phosphor Icons

- `url:icon_provider_phosphor_base_cdn` → `https://icons.lyxal.b-cdn.net/phosphor/`
- `url:icon_provider_phosphor_official` → `https://phosphoricons.com`
- `url:icon_provider_phosphor_docs` → `https://phosphoricons.com`
- `url:icon_provider_phosphor_github` → `https://github.com/phosphor-icons/core`

---

## 8. Tabler Icons

- `url:icon_provider_tabler_base_cdn` → `https://icons.lyxal.b-cdn.net/tabler/`
- `url:icon_provider_tabler_official` → `https://tabler-icons.io`
- `url:icon_provider_tabler_docs` → `https://tabler-icons.io`
- `url:icon_provider_tabler_github` → `https://github.com/tabler/tabler-icons`

---

## Total URLs à créer : 32

- **8 fournisseurs** × 4 URLs (base_cdn, official, docs, github) = **32 URLs**

---

## Logos (icon) à créer : 8

Les logos des fournisseurs doivent être créés en tant que `record<icon>` avec la catégorie `icon_category:brand` :

1. **`icon:lucide_logo`** - Logo Lucide
2. **`icon:heroicons_logo`** - Logo Heroicons
3. **`icon:material_icons_logo`** - Logo Material Icons (Google)
4. **`icon:font_awesome_logo`** - Logo Font Awesome
5. **`icon:feather_logo`** - Logo Feather Icons
6. **`icon:bootstrap_icons_logo`** - Logo Bootstrap Icons
7. **`icon:phosphor_logo`** - Logo Phosphor Icons
8. **`icon:tabler_logo`** - Logo Tabler Icons

### Structure des logos :

```surql
CREATE icon:lucide_logo CONTENT {
  identity: { value: 'lucide_logo', slug: 'lucide-logo' },
  presentation: {
    name_i18n: i18n_key:icon_lucide_logo_name,
    description_i18n: i18n_key:icon_lucide_logo_description
  },
  context: {
    category: icon_category:brand
  }
};

-- Puis créer la relation icon_variant pour pointer vers le SVG sur Bunny CDN
RELATE icon:lucide_logo->icon_variant->icon_provider:lucide CONTENT {
  asset: { svg_url: url:lucide_logo_svg }
};
```

---

## Notes

1. Toutes les URLs **CDN** (`base_cdn`) pointent vers Bunny CDN de Lyxal
2. Les URLs **official/docs/github** sont externes et doivent avoir `url.is_external = true`
3. Chaque URL doit avoir un `title_i18n` et `description_i18n` appropriés
4. Les URLs CDN doivent avoir l'extension `asset` activée
5. Les URLs externes doivent avoir l'extension `http_validation` pour vérification périodique
6. Les **logos** doivent être créés dans la table `icon` avec catégorie `brand`

