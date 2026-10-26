# 📦 Module Lyxal Catalogue (`lyxal_catalogue`)

> **Référentiel universel des produits, services, ouvrages, ressources et ensembles de LYXAL OS.**  
> Module développé en **SurrealQL pur** pour **SurrealDB v3.2.0**.

---

## 🌟 1. Présentation & Rôle Métier

Le module `lyxal_catalogue` constitue le cœur de gestion des articles et nomenclatures de Lyxal OS. Il gère de manière unifiée et découplée :
- Les **articles fondamentaux** (Produits, Services, Ouvrages, Ressources, Ensembles).
- La **taxonomie arborescente** (Catégories et sous-catégories à niveaux arbitraires, protégées contre les boucles cycliques).
- Les **caractéristiques techniques et valeurs typées** (Attributs statiques au niveau de l'article ou différentiateurs de déclinaisons).
- La **matrice des variantes** avec calcul déterministe d'empreintes canoniques SHA-256 et protection contre toute falsification ou duplication.
- Le **moteur de nomenclature et composition récursive** (Ouvrages composés, calcul de perte, contrôle anti-cycles récursif en largeur BFS jusqu'à 200 niveaux).
- Les **relations transversales inter-éléments** (Accessoires, Substituts, Pièces de rechange, Produits compatibles).

---

## 🏛️ 2. Architecture des 12 Tables (`schema/`)

Toutes les tables sont déclarées en `TYPE NORMAL` ou `TYPE RELATION`, `SCHEMAFULL`, `PERMISSIONS NONE`, avec index d'unicité et événements de protection moteur.

| N° | Fichier de Schéma | Table | Type | Rôle Métier |
|:---:|---|---|---|---|
| **01** | `01_catalogue_type.surql` | `catalogue_type` | Normal | Types fondamentaux (PRODUIT, SERVICE, OUVRAGE, RESSOURCE, ENSEMBLE) |
| **02** | `02_catalogue_item.surql` | `catalogue_item` | Normal | Entité maître article / ouvrage / service avec unité de référence |
| **03** | `03_catalogue_categorie.surql` | `catalogue_categorie` | Normal | Taxonomie arborescente avec détection anti-cycle parent |
| **04** | `04_catalogue_item_categorie.surql` | `catalogue_item_categorie` | Relation | Table de liaison plusieurs-à-plusieurs Article ↔ Catégories |
| **05** | `05_catalogue_attribut.surql` | `catalogue_attribut` | Normal | Caractéristiques (STRING, NUMBER, BOOLEAN, DATE, COLOR, etc.) |
| **06** | `06_catalogue_attribut_valeur.surql` | `catalogue_attribut_valeur` | Normal | Valeurs discrètes autorisées rattachées aux attributs |
| **07** | `07_catalogue_variante.surql` | `catalogue_variante` | Normal | Déclinaisons avec empreinte SHA-256 unique et verrou anti-falsification |
| **08** | `08_catalogue_variante_attribut.surql` | `catalogue_variante_attribut` | Normal | Matrice d'affectation universelle (Scope Item statique ou Variante) |
| **09** | `09_catalogue_composition.surql` | `catalogue_composition` | Normal | En-têtes de nomenclatures versionnées avec immuabilité au scellement |
| **10** | `10_catalogue_composition_ligne.surql` | `catalogue_composition_ligne` | Normal | Lignes de composants consommés avec quantités et coefficients de perte |
| **11** | `11_catalogue_relation_type.surql` | `catalogue_relation_type` | Normal | Types de relations (ACCESSOIRE, SUBSTITUT, COMPATIBLE, etc.) |
| **12** | `12_catalogue_relation.surql` | `catalogue_relation` | Normal | Liaisons dirigées entre items avec contrôle anti-auto-liaison |

---

## ⚙️ 3. Les 22 Fonctions Métier (`functions/`)

Chaque fonction publique respecte la charte Lyxal OS :
- Signature unique : `DEFINE FUNCTION OVERWRITE fn::catalogue_<action>($params: object)`.
- Contrat universel de retour : `fn::result_ok($data)` ou `fn::error_result($code, $language, $details)`.

### 3.1. Types & Taxonomie
- `fn::catalogue_type_list($params)` : Liste des types fondamentaux actifs.
- `fn::catalogue_categorie_create($params)` : Création d'une catégorie avec validation de parent.
- `fn::catalogue_categorie_tree($params)` : Extraction de l'arbre taxonomique hiérarchique complet.
- `fn::catalogue_categorie_update($params)` : Mise à jour avec contrôle anti-cycle immédiat et récursif.
- `fn::catalogue_categorie_delete($params)` : Suppression contrôlée (refus si sous-catégories ou articles liés).

### 3.2. Articles & Items
- `fn::catalogue_item_create($params)` : Création d'un élément avec typage et unité du socle `lyxal_base`.
- `fn::catalogue_item_get($params)` : Lecture détaillée d'un item avec ses catégories et attributs.
- `fn::catalogue_item_list($params)` : Consultation paginée et filtrée (type, statut, catégories).
- `fn::catalogue_item_update($params)` : Mise à jour des informations administratives et de gestion.
- `fn::catalogue_item_delete($params)` : Suppression protégée (refus si référencé dans des compositions actives).

### 3.3. Attributs & Caractéristiques
- `fn::catalogue_attribut_create($params)` : Déclaration d'un attribut typé et drapeau `is_variant_driver`.
- `fn::catalogue_attribut_valeur_create($params)` : Ajout d'une valeur discrète avec validation de concordance de type.
- `fn::catalogue_attribut_set_static($params)` : Affectation d'un attribut commun directement à l'item maître (`variante: NONE`).

### 3.4. Variantes & Empreintes Canoniques
- `fn::catalogue_variante_create($params)` : Création d'une déclinaison avec calcul initial d'empreinte.
- `fn::catalogue_variante_set_attributs($params)` : Affectation transactionnelle et atomique d'attributs de déclinaison avec recalcul de l'empreinte SHA-256.

### 3.5. Nomenclatures & Compositions
- `fn::catalogue_composition_check_cycle($params)` : Parcours BFS complet jusqu'à 200 niveaux détectant les cycles directs et indirects (`A -> B -> ... -> A`).
- `fn::catalogue_composition_create($params)` : Initialisation d'une nomenclature en état `DRAFT`.
- `fn::catalogue_composition_add_line($params)` : Ajout d'un composant avec blocage automatique si cycle détecté.
- `fn::catalogue_composition_publish($params)` : Scellement immuable de la nomenclature (`PUBLISHED`), verrouillant lignes et en-tête.
- `fn::catalogue_composition_clone_version($params)` : Duplication d'une version scellée vers une nouvelle version brouillon incrémentée.

### 3.6. Relations Inter-Éléments
- `fn::catalogue_relation_create($params)` : Création d'un lien directionnel avec contrôle anti-boucle locale.
- `fn::catalogue_relation_delete($params)` : Suppression d'une relation existante.

---

## 🛡️ 4. Verrous Moteur & Garanties d'Intégrité

### 4.1. Détection Récursive des Cycles (`fn::catalogue_composition_check_cycle`)
L'algorithme de détection de cycles implémente un parcours en largeur (BFS) :
- Explore le graphe des dépendances jusqu'à **200 niveaux** de profondeur.
- **Règle absolue CTO** : si la limite technique est atteinte sans avoir épuisé le graphe, la fonction ne retourne jamais `false` silencieusement ; elle lève immédiatement l'exception explicite `CATALOGUE_COMPOSITION_CYCLE_DEPTH_EXCEEDED`.

### 4.2. Recalcul Bi-directionnel des Empreintes de Variantes
Sur la table `catalogue_variante_attribut`, l'événement `evt_cva_recalc_fingerprint` s'exécute sur `CREATE`, `UPDATE` et `DELETE` :
1. **Variante cible** : recalcule l'empreinte SHA-256 triée de l'ensemble des paires `attribut:valeur`.
2. **Variante source** : lors d'un déplacement d'attribut d'une variante A vers une variante B, ou d'une variante A vers `NONE` (attribut statique item), l'empreinte de la variante source est **automatiquement et immédiatement recalculée**.
3. **Protection contre la falsification** : l'événement `evt_variante_protect_fingerprint` sur `catalogue_variante` interdit toute modification directe arbitraire de `empreinte_attributs`.
4. **Anti-collision** : l'index unique `idx_var_item_fingerprint` garantit qu'un même article parent ne peut pas posséder deux variantes ayant la même combinaison d'attributs pilotes.

---

## 🚨 5. Référentiel des 45 Codes d'Erreurs

Toutes les erreurs sont strictement définies selon la charte Lyxal OS via la directive canonique `CREATE error_definition CONTENT { ... };` et organisées par sous-domaines dans [`error/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/error/) :

| Domaine | Fichier Source | Nombre | Codes Techniques |
|---|---|:---:|---|
| **item** | `error/items/error_item.surql` | 9 | `CATALOGUE_ITEM_NOT_FOUND`, `CATALOGUE_ITEM_ALREADY_EXISTS`, `CATALOGUE_ITEM_CODE_REQUIRED`, `CATALOGUE_ITEM_LIBELLE_REQUIRED`, `CATALOGUE_ITEM_TYPE_NOT_FOUND`, `CATALOGUE_ITEM_UNITE_INVALID`, `CATALOGUE_ITEM_IN_USE`, `CATALOGUE_ITEM_SYSTEM_IMMUTABLE`, `CATALOGUE_PAGINATION_INVALID` |
| **categorie** | `error/categories/error_categorie.surql` | 8 | `CATALOGUE_CATEGORIE_NOT_FOUND`, `CATALOGUE_CATEGORIE_CODE_REQUIRED`, `CATALOGUE_CATEGORIE_LIBELLE_REQUIRED`, `CATALOGUE_CATEGORIE_ALREADY_EXISTS`, `CATALOGUE_CATEGORIE_CYCLE_DETECTED`, `CATALOGUE_CATEGORIE_SYSTEM_IMMUTABLE`, `CATALOGUE_CATEGORIE_HAS_CHILDREN`, `CATALOGUE_CATEGORIE_IN_USE` |
| **attribut** | `error/attributs/error_attribut.surql` | 11 | `CATALOGUE_ATTRIBUT_NOT_FOUND`, `CATALOGUE_ATTRIBUT_CODE_REQUIRED`, `CATALOGUE_ATTRIBUT_LIBELLE_REQUIRED`, `CATALOGUE_ATTRIBUT_TYPE_INVALID`, `CATALOGUE_ATTRIBUT_ALREADY_EXISTS`, `CATALOGUE_ATTRIBUT_UNITE_INVALID`, `CATALOGUE_ATTRIBUT_VALEUR_NOT_FOUND`, `CATALOGUE_ATTRIBUT_VALEUR_CODE_REQUIRED`, `CATALOGUE_ATTRIBUT_TYPE_MISMATCH`, `CATALOGUE_ATTRIBUT_VALEUR_INVALID`, `CATALOGUE_ATTRIBUT_NOT_VARIANT_DRIVER` |
| **variante** | `error/variantes/error_variante.surql` | 7 | `CATALOGUE_VARIANTE_NOT_FOUND`, `CATALOGUE_VARIANTE_CODE_REQUIRED`, `CATALOGUE_VARIANTE_ALREADY_EXISTS`, `CATALOGUE_VARIANTE_ITEM_MISMATCH`, `CATALOGUE_VARIANTE_DUPLICATE_COMBINAISON`, `CATALOGUE_VARIANTE_REQUIRES_SPECIFIC`, `CATALOGUE_VARIANTE_FINGERPRINT_FORBIDDEN` |
| **composition** | `error/compositions/error_composition.surql` | 7 | `CATALOGUE_COMPOSITION_NOT_FOUND`, `CATALOGUE_COMPOSITION_NOT_DRAFT`, `CATALOGUE_COMPOSITION_EMPTY`, `CATALOGUE_COMPOSITION_IMMUTABLE`, `CATALOGUE_COMPOSITION_CYCLE_DETECTED`, `CATALOGUE_COMPOSITION_CYCLE_DEPTH_EXCEEDED`, `CATALOGUE_COMPOSITION_UNITE_INCOMPATIBLE` |
| **relation** | `error/relations/error_relation.surql` | 3 | `CATALOGUE_RELATION_SELF_REFERENCED`, `CATALOGUE_RELATION_TYPE_NOT_FOUND`, `CATALOGUE_RELATION_NOT_FOUND` |

---

## 🧪 6. Suites de Tests (`tests/`)

| Fichier de Test | Objectif de Validation | Statut |
|---|---|:---:|
| `tests/test_deep_cycle.surql` | Chaîne récursive sur 8 niveaux (> 5 niveaux), détection cycle profond, cycle intermédiaire, non-faux-positif | ✅ Conforme |
| `tests/test_variant_transfer.surql` | Déplacement d'attribut entre variantes, transition vers `NONE`, collision d'empreinte et rollback | ✅ Conforme |
| `tests/test_catalogue_integrity.surql` | Scellement immuable des nomenclatures et verrous de suppression | ✅ Conforme |
| `tests/test_variant_security.surql` | Protection absolue contre l'altération manuelle des empreintes de variantes | ✅ Conforme |
| `tests/test_final_validation.surql` | Validation fonctionnelle de bout en bout des 12 tables et 22 fonctions | ✅ Conforme |

---

## 📋 7. Contrat Manifeste (`manifest.toml`)

Le fichier `manifest.toml` respecte le schéma officiel de `lyxal_runtime` :
```toml
manifest_version = 1
id = "lyxal_catalogue"
name = "Lyxal Catalogue"
version = "1.0.0"
description = "Référentiel universel des produits, services, ouvrages, ressources et ensembles de LYXAL OS"
capabilities = ["database"]

[runtime]
min_version = ">=0.1.0"

[[dependencies]]
id = "lyxal_core"
version = ">=1.0.0"

[[dependencies]]
id = "lyxal_base"
version = ">=1.0.0"

[resources]
schemas = [ ... ]
functions = [ ... ]
seeds = [ ... ]
```

---

## 🗺️ 8. Feuille de Route & Évolutions Stratégiques

Pour le détail des versions, objectifs et critères d'acceptation de `lyxal_catalogue` (V1.1 terminée et gelée, V1.2 à V2.0 planifiées) :
* 📄 **Feuille de Route Officielle du Module :** [`ROADMAP.md`](./ROADMAP.md)
* 🌐 **Intégration Transversale LYXAL SPACE :** [`docs/14-roadmap/ROADMAP_LYXAL_SPACE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/14-roadmap/ROADMAP_LYXAL_SPACE.md)

