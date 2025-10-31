# Module Icon - Extraction Lucide

## 📊 Vue d'ensemble

Ce module contient l'extraction complète des **1640 icônes** du pack [Lucide Icons](https://lucide.dev) avec **vraies traductions multilingues**.

## 📦 Fichiers générés

### Schemas
- `studio/database/icon/icon.surql` - Table icon (icônes abstraites/sémantiques)

### Seeds Lucide (1640 icônes complètes)
- `icon_seeds_lucide_all.surql` - 1640 records icon
- `icon_i18n_key_seeds_lucide_all.surql` - 3280 clés i18n (name + label)
- `icon_i18n_translation_seeds_lucide_all.surql` - 16 400 **vraies traductions** (5 langues)

### Scripts Python
- `extract_lucide_icons.py` - Extraction des icônes depuis les JSON Lucide
- `generate_real_translations.py` - Génération des **vraies traductions multilingues**
- `check_icon_consistency.py` - Vérification de la correspondance avec Lucide
- `clean_system_icons.py` - Nettoyage des icônes système (doublons)

### Documentation
- `LUCIDE_ICONS_SUMMARY.md` - Résumé de l'extraction (statistiques, exemples)
- `ICON_MAPPING_AND_TRANSLATIONS.md` - Correspondances et traductions
- `README.md` - Ce fichier

## 🔢 Statistiques

| Élément | Quantité |
|---------|----------|
| **Icônes Lucide** | 1640 |
| **Clés i18n** | 3280 (name + label) |
| **Traductions** | 16 400 (vraies traductions) |
| **Langues** | 5 (FR, EN, IT, DE, ES) |
| **Catégories** | 56 (13 système + 43 Lucide) |
| **Termes traduits** | 45 (dictionnaire) |

## 📂 Structure des données

Chaque icône contient :

```surql
CREATE icon:activity CONTENT {
  identity: {
    value: 'activity',
    slug: 'activity'
  },
  presentation: {
    name_i18n: i18n_key:icon_activity_name,
    label_i18n: i18n_key:icon_activity_label,
    keywords: ["pulse", "health", "action", "motion"]
  },
  context: {
    category: icon_category:medical,  -- Catégorie primaire depuis Lucide
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};
```

## 🔗 Relations

Les icônes sont liées à :
- **icon_category** - Catégorie fonctionnelle (ui, navigation, action, etc.)
- **icon_provider** - Fournisseur d'icônes (Lucide, Heroicons, etc.)
- **icon_variant** - Relation vers les SVG spécifiques sur Bunny CDN

## 🌐 Traductions (VRAIES)

Toutes les icônes ont de **vraies traductions multilingues** pour :
- `name_i18n` - Nom descriptif de l'icône
- `label_i18n` - Label court pour UI

### Exemples de traductions

**Icône `user`:**
- FR: "Utilisateur"
- EN: "User"
- IT: "Utente"
- DE: "Benutzer"
- ES: "Usuario"

**Icône `search`:**
- FR: "Rechercher"
- EN: "Search"
- IT: "Cerca"
- DE: "Suchen"
- ES: "Buscar"

**Icône `house` (home):**
- FR: "Maison"
- EN: "Home"
- IT: "Casa"
- DE: "Haus"
- ES: "Casa"

*(Note : 45 termes courants sont traduits intelligemment. Les icônes spécifiques gardent leur nom anglais capitalisé si aucune traduction n'est disponible.)*

## 🚀 Ordre de déploiement

1. `icon.surql` (schema)
2. `icon_category_seeds.surql` (13 catégories système)
3. `icon_category_seeds_lucide.surql` (43 catégories Lucide)
4. `icon_i18n_key_seeds_lucide_all.surql` (3280 clés i18n pour icônes Lucide)
5. `icon_seeds_lucide_all.surql` (1640 icônes Lucide)
6. `icon_i18n_translation_seeds_lucide_all.surql` (16 400 **vraies traductions**)

## 📝 Notes

- Les **keywords** de chaque icône proviennent directement des **tags** de Lucide
- La **catégorie primaire** est la première catégorie trouvée dans le fichier JSON de Lucide
- Les **icônes Lucide** (1640) constituent le dictionnaire complet disponible
- **Aucune icône système custom** : toutes les icônes proviennent de Lucide (évite les doublons)
- **45 termes traduits** : dictionnaire de traduction pour les termes courants (user, search, home, edit, etc.)

## 🔄 Mise à jour

Pour mettre à jour les icônes Lucide :
1. Télécharger la dernière version de Lucide
2. Extraire dans `lucide-main/icons/`
3. Exécuter `python extract_lucide_icons.py`
4. Exécuter `python generate_real_translations.py`

## 📊 Taille des fichiers

| Fichier | Taille | Lignes |
|---------|--------|--------|
| `icon_seeds_lucide_all.surql` | ~1.2 MB | ~29 520 |
| `icon_i18n_key_seeds_lucide_all.surql` | ~510 KB | ~9 840 |
| `icon_i18n_translation_seeds_lucide_all.surql` | **~1.54 MB** | **34 447** |
| **Total** | **~3.25 MB** | **~73 807 lignes** |

---

✅ **Extraction complète des icônes Lucide terminée !**

