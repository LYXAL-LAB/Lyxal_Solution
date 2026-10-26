# 📝 Changelog — Lyxal Catalogue (`lyxal_catalogue`)

Toutes les modifications notables apportées à ce module sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/), et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [1.0.0] - 2026-10-21

### Ajouté
- **12 Tables déclaratives SurrealQL (`schema/`)** :
  - `catalogue_type` : Types fondamentaux (PRODUIT, SERVICE, OUVRAGE, RESSOURCE, ENSEMBLE).
  - `catalogue_item` : Entité article maître avec unité de mesure référencée.
  - `catalogue_categorie` : Taxonomie arborescente avec verrou anti-cycle hiérarchique.
  - `catalogue_item_categorie` : Relation n:m article ↔ catégories.
  - `catalogue_attribut` : Attributs typés (STRING, NUMBER, BOOLEAN, DATE, COLOR).
  - `catalogue_attribut_valeur` : Valeurs autorisées discrètes.
  - `catalogue_variante` : Déclinaisons physiques avec empreinte SHA-256 canonique.
  - `catalogue_variante_attribut` : Matrice universelle des attributs avec `target_scope`.
  - `catalogue_composition` : Nomenclatures avec scellement immuable `is_locked`.
  - `catalogue_composition_ligne` : Composants consommés avec ratios et perte.
  - `catalogue_relation_type` : Typologie des liaisons transversales.
  - `catalogue_relation` : Relations dirigées inter-éléments.
- **22 Fonctions métier publiques (`functions/`)** :
  - `fn::catalogue_type_list`
  - `fn::catalogue_categorie_create`, `_tree`, `_update`, `_delete`
  - `fn::catalogue_item_create`, `_get`, `_list`, `_update`, `_delete`
  - `fn::catalogue_attribut_create`, `_valeur_create`, `_set_static`
  - `fn::catalogue_variante_create`, `_set_attributs`
  - `fn::catalogue_composition_check_cycle`, `_create`, `_add_line`, `_publish`, `_clone_version`
  - `fn::catalogue_relation_create`, `_delete`
- **45 Définitions d'erreurs canoniques (`error/` & `seeds/`)** :
  - Méthode officielle `CREATE error_definition CONTENT { ... };` selon la charte Lyxal OS.
  - Répartition par domaines : `items` (9), `categories` (8), `attributs` (11), `variantes` (7), `compositions` (7), `relations` (3).
- **Contrôle anti-cycle robuste par BFS** :
  - Parcours en largeur jusqu'à 200 niveaux de nomenclature dans `fn::catalogue_composition_check_cycle`.
  - Levée d'exception explicite `CATALOGUE_COMPOSITION_CYCLE_DEPTH_EXCEEDED` en cas de limite atteinte sans épuisement du graphe.
- **Recalcul bi-directionnel des empreintes SHA-256** :
  - Événement `evt_cva_recalc_fingerprint` recalculant automatiquement les empreintes des variantes source et cible lors d'un déplacement d'attribut ou d'un passage à `NONE`.
  - Index unique `idx_var_item_fingerprint` empêchant tout doublon d'empreinte pour un même article.
- **Suites de tests de validation (`tests/`)** :
  - `test_deep_cycle.surql` : Test de cycle sur 8 niveaux.
  - `test_variant_transfer.surql` : Test de déplacement d'attribut, passage à NONE, collision et rollback.
  - `test_catalogue_integrity.surql` : Intégrité des verrous moteur et immuabilité.
  - `test_variant_security.surql` : Protection absolue contre la modification manuelle d'empreinte.
  - `test_final_validation.surql` : Validation complète de bout en bout.
