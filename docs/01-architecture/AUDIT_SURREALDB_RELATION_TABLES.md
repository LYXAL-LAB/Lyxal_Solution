# 🏛️ AUDIT ARCHITECTURAL DES TABLES RELATIONNELLES SURREALDB
## Modules `lyxal_catalogue` & `lyxal_pipeline_ingestion`

> **Destinataire :** CTO LYXAL OS  
> **Auteur :** Antigravity AI Architecture Assistant  
> **Date :** 26 Octobre 2026  
> **Statut de l'Audit :** LIVRABLE D'AUDIT ARCHITECTURAL — AUDIT EN LECTURE SEULE  
> **Versions auditées :**  
> - `crates/lyxal_catalogue` : **V1.1 (Clôturé et Gelé)**  
> - `crates/lyxal_pipeline_ingestion` : **V1.0.0 (Clôturé Staging et Gelé)**  
> - Référentiels transversaux : `lyxal_base` V1.0 / `lyxal_error` V1.0  
> **Environnement cible :** SurrealDB 3.2.0 persistant  

---

## 1. Objectif & Cadre de l'Audit

### 1.1. Contexte du Mandat CTO

À la suite de la clôture officielle des modules [`lyxal_catalogue`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue) (V1.1) et [`lyxal_pipeline_ingestion`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion) (V1.0.0), la Direction Technique (CTO) a mandaté un audit exhaustif de l'ensemble des modèles de données et schémas relationnels déployés dans le workspace.

L'objectif cardinal de cet audit est de :
1. **Évaluer l'opportunité d'utiliser le type natif SurrealDB `TYPE RELATION`** par rapport au modèle actuel fondé sur `TYPE NORMAL` et des pointeurs `record<...>` typés.
2. **Identifier les tables qui doivent impérativement demeurer en `TYPE NORMAL`**, celles qui constituent des arêtes de graphe naturelles, et celles pour lesquelles une conversion apporterait un réel gain expressif ou algorithmique.
3. **Mesurer avec une rigueur absolue les impacts techniques** (fonctions SurrealQL, code Rust, permissions RLS, événements gardiens, seeds, migrations) et les risques de déstabilisation des versions actuellement gelées.
4. **Fournir un tableau de décision exhaustif** et une recommandation formelle pour la stratégie d'évolution vers SurrealDB 3.2.0 et les versions futures (V1.2 / V2.0).

### 1.2. Règle d'Inviolabilité Absolue

Conformément à la directive stricte du CTO :
- **Aucune modification de schéma** n'a été effectuée.
- **Aucune migration** n'a été appliquée.
- **Aucune fonction SurrealQL, code Rust ou seed** n'a été altéré.
- **Aucun déploiement** n'a été exécuté.
- **Les statuts gelés (V1.1 et V1.0.0)** demeurent scellés et inviolés.
- L'audit repose exclusivement sur le code et les schémas réels existants dans le workspace.

---

## 2. Inventaire Exhaustif des Tables

Au sein du périmètre audité, **27 tables au total** ont été inventoriées, comprenant **24 tables appartenant en propre aux deux modules audités** et **3 tables transversales** appartenant aux fondations du workspace :
- **13 tables propriétaires** pour [`lyxal_catalogue`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema)
- **11 tables propriétaires** pour [`lyxal_pipeline_ingestion`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema)
- **3 tables transversales** consommées par ces modules, sans transfert de propriété ([`lyxal_base`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_base/schema) : `base_unite`, `base_unite_type` ; [`lyxal_error`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_error/schema) : `error_definition`)

---

### 2.1. Module `lyxal_catalogue` (13 Tables)

```
                    ┌────────────────────────┐
                    │   catalogue_session    │
                    └────────────────────────┘
                                │ (RLS Scope / Context)
                                ▼
┌──────────────────┐    ┌────────────────────┐    ┌─────────────────────────┐
│  catalogue_type  │◄───┤   catalogue_item   ├───►│ base_unite (lyxal_base) │
└──────────────────┘    └─────────┬──────────┘    └─────────────────────────┘
                                  │
      ┌───────────────────────────┼───────────────────────────┐
      │ (1:N)                     │ (N:M Junction)            │ (Graph Link)
      ▼                           ▼                           ▼
┌──────────────┐      ┌────────────────────────┐      ┌─────────────────────┐
│  variante    │      │ catalogue_item_        │      │ catalogue_relation  │
│              │      │ categorie              │      │ (source / cible)    │
└──────┬───────┘      └───────────┬────────────┘      └──────────┬──────────┘
       │                          │                              │
       ▼                          ▼                              ▼
┌──────────────┐      ┌────────────────────────┐      ┌─────────────────────┐
│ cva (matrice)│      │  catalogue_categorie   │      │ catalogue_relation_ │
│              │      │  (arborescence parent) │      │ type (ACCESSOIRE...)│
└──────────────┘      └────────────────────────┘      └─────────────────────┘
```

#### Table 1 : `catalogue_session`
- **Fichier de schéma :** [`00_catalogue_session.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/00_catalogue_session.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_session TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE id = $auth.id FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** Aucun champ record (entité racine de session).
- **Fonctions SurrealQL consommatrices :** Utilisée implicitement par le moteur SurrealDB pour résoudre `$auth` et `$auth.id` dans toutes les règles RLS.
- **Utilisation du graphe / RELATE :** Aucune.
- **Index et contraintes :** Aucun index explicite (clé primaire `id = catalogue_session:<token>`).
- **Événements :** Aucun.

#### Table 2 : `catalogue_type`
- **Fichier de schéma :** [`01_catalogue_type.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/01_catalogue_type.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_type TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** Aucun.
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_type_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/type/catalogue_type_list.surql), [`fn::catalogue_item_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_create.surql), [`fn::catalogue_item_update`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_update.surql), [`fn::catalogue_item_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_list.surql).
- **Utilisation du graphe / RELATE :** Aucune.
- **Index et contraintes :** `idx_catalogue_type_code` (`code UNIQUE`). Valeurs normalisées `PRODUIT`, `SERVICE`, `OUVRAGE`, `RESSOURCE`, `ENSEMBLE`.
- **Événements :** Aucun.

#### Table 3 : `catalogue_item`
- **Fichier de schéma :** [`02_catalogue_item.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/02_catalogue_item.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_item TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create WHERE ... FOR update WHERE ... FOR delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :**  
  - `type: record<catalogue_type>` (REFERENCE)  
  - `unite_reference: record<base_unite>` (REFERENCE)  
  - `conditionnement.type_unite: option<record<base_unite>>`
- **Fonctions SurrealQL consommatrices :**  
  - Écriture : [`fn::catalogue_item_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_create.surql), [`fn::catalogue_item_update`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_update.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql).  
  - Lecture : [`fn::catalogue_item_get`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_get.surql), [`fn::catalogue_item_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_list.surql), [`fn::catalogue_relation_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_create.surql), [`fn::catalogue_composition_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_create.surql), [`fn::catalogue_composition_add_line`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_add_line.surql).
- **Utilisation du graphe / RELATE :** Nœud central (Node). Non utilisé en arête.
- **Index et contraintes :** `idx_catalogue_item_code` (`code UNIQUE`), `idx_catalogue_item_code_barre` (`code_barre UNIQUE`), `idx_catalogue_item_fab_ref` (`fabricant, reference_fabricant UNIQUE`), `idx_catalogue_item_master_id` (`master_id UNIQUE`), `idx_catalogue_item_tenant`.
- **Événements :** [`evt_catalogue_item_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/02_catalogue_item.surql#L296) (contrôle strict générique vs commercial, validation GS1 Modulo 10, isolation multi-tenant et protection immuable des articles Master).

#### Table 4 : `catalogue_categorie`
- **Fichier de schéma :** [`03_catalogue_categorie.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/03_catalogue_categorie.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_categorie TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** `parent: option<record<catalogue_categorie>>` (auto-référence hiérarchique).
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_categorie_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/categorie/catalogue_categorie_create.surql), [`fn::catalogue_categorie_update`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/categorie/catalogue_categorie_update.surql), [`fn::catalogue_categorie_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/categorie/catalogue_categorie_delete.surql), [`fn::catalogue_categorie_tree`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/categorie/catalogue_categorie_tree.surql).
- **Utilisation du graphe / RELATE :** Structure arborescente gérée par liste d'adjacence (`parent`). Pas de `RELATE`.
- **Index et contraintes :** `idx_catalogue_categorie_code` (`code UNIQUE`), `idx_catalogue_categorie_parent`.
- **Événements :** Aucun.

#### Table 5 : `catalogue_item_categorie`
- **Fichier de schéma :** [`04_catalogue_item_categorie.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/04_catalogue_item_categorie.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_item_categorie TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update, delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :**  
  - `item: record<catalogue_item>` (REFERENCE)  
  - `categorie: record<catalogue_categorie>` (REFERENCE)
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_item_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_create.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql), [`fn::catalogue_item_get`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_get.surql), [`fn::catalogue_item_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_list.surql), [`fn::catalogue_categorie_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/categorie/catalogue_categorie_delete.surql).
- **Utilisation du graphe / RELATE :** Table de jonction N-à-N relationnelle classique (`is_primary: bool`).
- **Index et contraintes :** `idx_item_cat_unique` (`item, categorie UNIQUE`), `idx_item_cat_lookup` (`categorie, item`).
- **Événements :** Aucun.

#### Table 6 : `catalogue_attribut`
- **Fichier de schéma :** [`05_catalogue_attribut.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/05_catalogue_attribut.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_attribut TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** `unite: option<record<base_unite>>` (REFERENCE).
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_attribut_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/attribut/catalogue_attribut_create.surql), [`fn::catalogue_attribut_set_static`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/attribut/catalogue_attribut_set_static.surql), [`fn::catalogue_variante_set_attributs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/variante/catalogue_variante_set_attributs.surql).
- **Index et contraintes :** `idx_catalogue_attribut_code` (`code UNIQUE`). Types autorisés : `STRING`, `NUMBER`, `BOOLEAN`, `DATE`, `COLOR`.
- **Événements :** Aucun.

#### Table 7 : `catalogue_attribut_valeur`
- **Fichier de schéma :** [`06_catalogue_attribut_valeur.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/06_catalogue_attribut_valeur.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_attribut_valeur TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** `attribut: record<catalogue_attribut>` (REFERENCE).
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_attribut_valeur_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/attribut/catalogue_attribut_valeur_create.surql), [`fn::catalogue_attribut_set_static`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/attribut/catalogue_attribut_set_static.surql), [`fn::catalogue_variante_set_attributs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/variante/catalogue_variante_set_attributs.surql).
- **Index et contraintes :** `idx_attr_val_unique` (`attribut, code UNIQUE`), `idx_attr_val_lookup` (`attribut, enabled`).
- **Événements :** Aucun.

#### Table 8 : `catalogue_variante`
- **Fichier de schéma :** [`07_catalogue_variante.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/07_catalogue_variante.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_variante TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update, delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** `item: record<catalogue_item>` (REFERENCE).
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_variante_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/variante/catalogue_variante_create.surql), [`fn::catalogue_variante_set_attributs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/variante/catalogue_variante_set_attributs.surql), [`fn::catalogue_item_get`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_get.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql), [`fn::catalogue_composition_add_line`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_add_line.surql).
- **Index et contraintes :** `idx_catalogue_variante_code` (`code UNIQUE`), `idx_var_item_fingerprint` (`item, empreinte_attributs UNIQUE`), `idx_catalogue_variante_item`.
- **Événements :** [`evt_variante_protect_fingerprint`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/07_catalogue_variante.surql#L97) (recalcul et vérification de conformité de l'empreinte SHA-256 des attributs).

#### Table 9 : `catalogue_variante_attribut`
- **Fichier de schéma :** [`08_catalogue_variante_attribut.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/08_catalogue_variante_attribut.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_variante_attribut TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update, delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :**  
  - `item: record<catalogue_item>` (REFERENCE)  
  - `variante: option<record<catalogue_variante>>` (REFERENCE)  
  - `attribut: record<catalogue_attribut>` (REFERENCE)  
  - `attribut_valeur: record<catalogue_attribut_valeur>` (REFERENCE)
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_attribut_set_static`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/attribut/catalogue_attribut_set_static.surql), [`fn::catalogue_variante_set_attributs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/variante/catalogue_variante_set_attributs.surql), [`fn::catalogue_item_get`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_get.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql).
- **Index et contraintes :** `idx_scope_attr` (`target_scope, attribut UNIQUE`), `idx_attr_val_lookup` (`attribut, attribut_valeur`).
- **Événements :** [`evt_cva_recalc_fingerprint`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/08_catalogue_variante_attribut.surql#L76) (recalcul atomique automatique de l'empreinte SHA-256 sur la variante parente).

#### Table 10 : `catalogue_composition`
- **Fichier de schéma :** [`09_catalogue_composition.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/09_catalogue_composition.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_composition TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update, delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** `parent_item: record<catalogue_item>` (REFERENCE).
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_composition_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_create.surql), [`fn::catalogue_composition_publish`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_publish.surql), [`fn::catalogue_composition_clone_version`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_clone_version.surql), [`fn::catalogue_composition_add_line`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_add_line.surql), [`fn::catalogue_item_get`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_get.surql).
- **Index et contraintes :** `idx_comp_parent_version` (`parent_item, version UNIQUE`), `idx_comp_parent_statut` (`parent_item, statut`).
- **Événements :** [`evt_composition_protect`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/09_catalogue_composition.surql#L88) (verrou d'immuabilité scellé), [`evt_composition_no_del`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/09_catalogue_composition.surql#L111).

#### Table 11 : `catalogue_composition_ligne`
- **Fichier de schéma :** [`10_catalogue_composition_ligne.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/10_catalogue_composition_ligne.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_composition_ligne TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update, delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :**  
  - `composition: record<catalogue_composition>` (REFERENCE)  
  - `composant_item: record<catalogue_item>` (REFERENCE)  
  - `composant_variante: option<record<catalogue_variante>>` (REFERENCE)  
  - `unite: record<base_unite>` (REFERENCE)
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_composition_add_line`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_add_line.surql), [`fn::catalogue_composition_check_cycle`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_check_cycle.surql), [`fn::catalogue_composition_clone_version`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_clone_version.surql), [`fn::catalogue_composition_publish`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/composition/catalogue_composition_publish.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql).
- **Index et contraintes :** `idx_comp_ligne_unique` (`composition, composant_item, composant_variante UNIQUE`).
- **Événements :** [`evt_comp_ligne_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/10_catalogue_composition_ligne.surql#L93) (interdiction d'ajout, modification ou suppression sur composition scellée).

#### Table 12 : `catalogue_relation_type`
- **Fichier de schéma :** [`11_catalogue_relation_type.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/11_catalogue_relation_type.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_relation_type TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** Aucun.
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_relation_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_create.surql), [`fn::catalogue_relation_check_cycle`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_check_cycle.surql).
- **Index et contraintes :** `idx_catalogue_relation_type_code` (`code UNIQUE`). Types standards : `ACCESSOIRE`, `SUBSTITUT`, `SIMILAIRE`, `COMPATIBLE`, `OBLIGATOIRE`, `COMMERCIAL_SPECIFICATION`, `REMPLACEMENT`.
- **Événements :** Aucun.

#### Table 13 : `catalogue_relation`
- **Fichier de schéma :** [`12_catalogue_relation.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/12_catalogue_relation.surql)
- **Module propriétaire :** `lyxal_catalogue`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE catalogue_relation TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update, delete WHERE ...`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :**  
  - `source: record<catalogue_item>` (REFERENCE)  
  - `cible: record<catalogue_item>` (REFERENCE, `ASSERT $value != source`)  
  - `relation_type: record<catalogue_relation_type>` (REFERENCE)
- **Fonctions SurrealQL consommatrices :** [`fn::catalogue_relation_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_create.surql), [`fn::catalogue_relation_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_delete.surql), [`fn::catalogue_relation_check_cycle`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_check_cycle.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql).
- **Utilisation du graphe / RELATE :** **Modélisation d'arête relationnelle sous forme de table normale**. Requêtée par `SELECT ... WHERE source = $s AND relation_type = $rt` et DFS manuel via sous-fonctions récursives.
- **Index et contraintes :** `idx_cat_rel_unique` (`source, cible, relation_type UNIQUE`), `idx_cat_rel_reverse` (`cible, relation_type`).
- **Événements :** [`evt_catalogue_relation_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/12_catalogue_relation.surql#L99) (187 lignes de contrôles : habilitation multi-tenant sur `$before` et `$after`, validation de sens commercial pour `COMMERCIAL_SPECIFICATION`, conformité d'obsolescence et détection anti-cycle pour `REMPLACEMENT`).

---

### 2.2. Module `lyxal_pipeline_ingestion` (11 Tables)

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ingestion_session (Auth)                        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Agent Execution)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        ingestion_batch (Job ETL)                       │
│              (file_hash_blake3, cursor_offset, chunk_size)             │
└───────┬───────────────────────────┬────────────────────────────┬───────┘
        │ (1:N Raw Streaming)       │ (1:N Staging)              │ (1:N Rejected)
        ▼                           ▼                            ▼
┌──────────────────┐      ┌─────────────────────────┐   ┌────────────────────────┐
│ ingestion_raw_   │      │ ingestion_staged_item   │   │ ingestion_quarantine_  │
│ record           │◄─────┤ (canonical_fingerprint, │   │ record                 │
│ (payload_brut)   │      │  commercial_proof)      │   │ (dead letter journal)  │
└──────────────────┘      └────────────┬────────────┘   └────────────────────────┘
                                       │ (1:N Approved)
                                       ▼
                          ┌─────────────────────────┐
                          │ ingestion_publication_  │
                          │ manifest (seal_hash)    │
                          └─────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│                DICTIONNAIRES & RÈGLES DE NORMALISATION                 │
│  - ingestion_family_rule (Familles BTP, mots-clés)                     │
│  - ingestion_specification (Nominal & tolérances métrologiques)        │
│  - ingestion_manufacturer_alias (Alias brut -> Nom canonique)          │
│  - ingestion_unit_alias (Alias unité -> base_unite)                    │
│  - ingestion_substitution_rule (Règles Niveau 4 contextualisées PV)    │
└────────────────────────────────────────────────────────────────────────┘
```

#### Table 14 : `ingestion_session`
- **Fichier de schéma :** [`00_ingestion_session.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/00_ingestion_session.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_session SCHEMAFULL PERMISSIONS FOR select WHERE id = $auth.id FOR create, update, delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** Aucun.
- **Rôle :** Table d'authentification des agents Record Users (`ingestion_agent`, `qualification_agent`, `steward_admin`, `catalogue_sync_agent`).

#### Table 15 : `ingestion_batch`
- **Fichier de schéma :** [`01_ingestion_batch.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/01_ingestion_batch.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_batch SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create WHERE ... FOR update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** Aucun.
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_batch_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/batch/ingestion_batch_create.surql), [`fn::ingestion_batch_transition`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/batch/ingestion_batch_transition.surql), [`fn::ingestion_batch_checkpoint`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/batch/ingestion_batch_checkpoint.surql), [`fn::ingestion_dashboard_metrics`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/dashboard/ingestion_dashboard_metrics.surql), [`fn::ingestion_manifest_save`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/manifest/ingestion_manifest_save.surql).
- **Index et contraintes :** `idx_batch_source_file_hash` (`source_type, file_hash_blake3 UNIQUE`), `idx_batch_fournisseur_statut` (`fournisseur_id, statut`).
- **Événements :** [`evt_batch_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/01_ingestion_batch.surql#L153) (machine à états `RECEIVED -> PARSING -> VALIDATING -> STAGED -> PUBLISHED / FAILED`).

#### Table 16 : `ingestion_raw_record`
- **Fichier de schéma :** [`02_ingestion_raw_record.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/02_ingestion_raw_record.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_raw_record SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create WHERE ... FOR update, delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** `batch: record<ingestion_batch>` (REFERENCE).
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_staged_save`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/staged/ingestion_staged_save.surql), [`fn::ingestion_quarantine_log`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/quarantine/ingestion_quarantine_log.surql).
- **Index et contraintes :** `idx_raw_batch_line` (`batch, ligne_numero UNIQUE`), `idx_raw_batch_row_hash` (`batch, row_hash`).
- **Rôle :** Zone tampon immuable garantissant la traçabilité intégrale du flux d'entrée.

#### Table 17 : `ingestion_staged_item`
- **Fichier de schéma :** [`03_ingestion_staged_item.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/03_ingestion_staged_item.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_staged_item SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create WHERE ... FOR update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :**  
  - `batch: record<ingestion_batch>` (REFERENCE)  
  - `raw_record: record<ingestion_raw_record>` (REFERENCE)
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_staged_save`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/staged/ingestion_staged_save.surql), [`fn::ingestion_staged_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/staged/ingestion_staged_list.surql), [`fn::ingestion_staged_requalify`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/staged/ingestion_staged_requalify.surql), [`fn::ingestion_quarantine_resolve`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/quarantine/ingestion_quarantine_resolve.surql), [`fn::ingestion_dashboard_metrics`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/dashboard/ingestion_dashboard_metrics.surql).
- **Index et contraintes :** `idx_staged_batch_line` (`batch, ligne_numero UNIQUE`), `idx_staged_business_id` (`batch, fabricant, reference_fabricant UNIQUE`), `idx_staged_fingerprint` (`batch, canonical_fingerprint`), `idx_staged_qualif` (`batch, qualification`).
- **Événements :** [`evt_staged_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/03_ingestion_staged_item.surql#L200) (transitions de qualification `VERIFIED / TO_CONFIRM / REJECTED` et verrou d'approbation `steward_admin`).

#### Table 18 : `ingestion_quarantine_record`
- **Fichier de schéma :** [`04_ingestion_quarantine_record.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/04_ingestion_quarantine_record.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_quarantine_record SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create WHERE ... FOR update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :**  
  - `batch: record<ingestion_batch>` (REFERENCE)  
  - `raw_record: record<ingestion_raw_record>` (REFERENCE)
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_quarantine_log`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/quarantine/ingestion_quarantine_log.surql), [`fn::ingestion_quarantine_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/quarantine/ingestion_quarantine_list.surql), [`fn::ingestion_quarantine_resolve`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/quarantine/ingestion_quarantine_resolve.surql), [`fn::ingestion_dashboard_metrics`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/dashboard/ingestion_dashboard_metrics.surql).
- **Index et contraintes :** `idx_quarantine_batch_severite` (`batch, severite`), `idx_quarantine_code` (`code_erreur`).
- **Rôle :** Journal d'audit d'anomalies (dead-letter table).

#### Table 19 : `ingestion_publication_manifest`
- **Fichier de schéma :** [`05_ingestion_publication_manifest.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/05_ingestion_publication_manifest.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_publication_manifest SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create WHERE ... FOR update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** `batch: record<ingestion_batch>` (REFERENCE).
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_manifest_save`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/manifest/ingestion_manifest_save.surql), [`fn::ingestion_manifest_approve`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/manifest/ingestion_manifest_approve.surql), [`fn::ingestion_manifest_record_exec`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/manifest/ingestion_manifest_record_exec.surql), [`fn::ingestion_manifest_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/manifest/ingestion_manifest_list.surql), [`fn::ingestion_manifest_get_detail`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/manifest/ingestion_manifest_get_detail.surql), [`fn::ingestion_dashboard_metrics`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/dashboard/ingestion_dashboard_metrics.surql).
- **Index et contraintes :** `idx_manifest_batch_version` (`batch, manifest_version UNIQUE`), `idx_manifest_ref` (`manifest_ref UNIQUE`), `idx_manifest_statut` (`statut`).
- **Événements :** [`evt_manifest_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/05_ingestion_publication_manifest.surql#L143) (machine à états `DRAFT -> SEALED -> APPROVED -> EXECUTING -> COMMITTED`).

#### Table 20 : `ingestion_family_rule`
- **Fichier de schéma :** [`06_ingestion_family_rule.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/06_ingestion_family_rule.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_family_rule SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** `standard_unit: option<string>` (code textuel vers `base_unite`).
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_rule_family_add`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/rule/ingestion_rule_family_add.surql).
- **Index et contraintes :** `idx_family_rule_code` (`code UNIQUE`).

#### Table 21 : `ingestion_specification`
- **Fichier de schéma :** [`07_ingestion_specification.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/07_ingestion_specification.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_specification SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** `family_code: string` (clé étrangère textuelle vers `ingestion_family_rule.code`).
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_rule_spec_add`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/rule/ingestion_rule_spec_add.surql).
- **Index et contraintes :** `idx_spec_tech_key` (`technical_identity_key UNIQUE`), `idx_spec_family` (`family_code`).

#### Table 22 : `ingestion_manufacturer_alias`
- **Fichier de schéma :** [`08_ingestion_manufacturer_alias.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/08_ingestion_manufacturer_alias.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_manufacturer_alias SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** Aucun.
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_resolve_manufacturer`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/rule/ingestion_resolve_manufacturer.surql).
- **Index et contraintes :** `idx_mfg_raw_alias` (`raw_alias UNIQUE`), `idx_mfg_canonical` (`canonical_name`).

#### Table 23 : `ingestion_unit_alias`
- **Fichier de schéma :** [`09_ingestion_unit_alias.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/09_ingestion_unit_alias.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_unit_alias SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** `canonical_unit: string` (clé textuelle vers `base_unite.code`).
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_resolve_unit`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/rule/ingestion_resolve_unit.surql).
- **Index et contraintes :** `idx_unit_raw_alias` (`raw_alias UNIQUE`), `idx_unit_canonical` (`canonical_unit`).

#### Table 24 : `ingestion_substitution_rule`
- **Fichier de schéma :** [`10_ingestion_substitution_rule.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/10_ingestion_substitution_rule.surql)
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE ingestion_substitution_rule SCHEMAFULL PERMISSIONS FOR select WHERE ... FOR create, update WHERE ... FOR delete NONE`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Champs `record` et références :** Aucun champ de type `record<...>`. Utilise des quadruplets textuels :  
  - `source_mfg: string`, `source_ref: string`  
  - `target_mfg: string`, `target_ref: string`  
  - `system_scope: string` (ex: `SYSTEME_CLOISON_DISTRIBUTION_72_48`)
- **Fonctions SurrealQL consommatrices :** [`fn::ingestion_rule_substitution_add`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/rule/ingestion_rule_substitution_add.surql).
- **Index et contraintes :** `idx_subst_rule_id` (`rule_id UNIQUE`), `idx_subst_source_target` (`source_mfg, source_ref, target_mfg, target_ref`).
- **Rôle :** Table de règles d'équivalence constructive Niveau 4 certifiées par PV technique.

---

### 2.3. Référentiels Transversaux (3 Tables)

#### Table 25 : `base_unite`
- **Fichier de schéma :** [`crates/lyxal_base/schema/base_unite.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_base/schema/base_unite.surql)
- **Module propriétaire :** `lyxal_base`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE base_unite TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** `type: record<base_unite_type>` (REFERENCE).
- **Consommateurs :**  
  - `lyxal_catalogue` : `catalogue_item.unite_reference`, `catalogue_composition_ligne.unite`, `catalogue_attribut.unite`.  
  - `lyxal_pipeline_ingestion` : Rapprochement dans `ingestion_resolve_unit` et validation staging.
- **Index et contraintes :** `idx_base_unite_code` (`code UNIQUE`).

#### Table 26 : `base_unite_type`
- **Fichier de schéma :** [`crates/lyxal_base/schema/base_unite_type.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_base/schema/base_unite_type.surql)
- **Module propriétaire :** `lyxal_base`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE base_unite_type TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`
- **Type actuel :** `TYPE NORMAL`
- **Champs `record` et références :** Aucun.
- **Index et contraintes :** `idx_base_unite_type_code` (`code UNIQUE`). Typologie dimensionnelle (`LONGUEUR`, `SURFACE`, `VOLUME`, `MASSE`, etc.).

#### Table 27 : `error_definition`
- **Fichier de schéma :** [`crates/lyxal_error/schema/error_definition.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_error/schema/error_definition.surql)
- **Module propriétaire :** `lyxal_error`
- **Déclaration actuelle :** `DEFINE TABLE OVERWRITE error_definition SCHEMAFULL`
- **Type actuel :** `TYPE NORMAL` (implicite)
- **Consommateurs :** `fn::error_result` et tous les seeds de définitions d'erreurs des modules.

---

## 3. Analyse Architecturale Fondamentale

Pour chaque table ou famille de tables, l'analyse répond aux **7 questions obligatoires** du mandat CTO.

```
                  ┌─────────────────────────────────────┐
                  │ 1. Entité métier vs Association ?   │
                  └──────────────────┬──────────────────┘
                                     │
      ┌──────────────────────────────┴──────────────────────────────┐
      ▼                                                             ▼
[ENTITÉ MÉTIER AUTONOME]                                  [ASSOCIATION / LIEN]
(catalogue_item, batch, staged...)                        (relation, item_cat, cva...)
      │                                                             │
      ▼                                                             ▼
2. Identité & cycle de vie propres ?                      3. Requêtes actuelles :
   OUI -> Conserver TYPE NORMAL                              Traversée de graphe requise ?
                                                                    │
                                     ┌──────────────────────────────┴──────────────────────────────┐
                                     ▼                                                             ▼
                                    NON                                                           OUI
                        (Arbre simple, 1:N, règles)                                    (Réseau sémantique N:M)
                                     │                                                             │
                                     ▼                                                             ▼
                        5. Pointeur record adapté ?                                   4. TYPE RELATION apporte-t-il
                           OUI -> CONSERVER NORMAL                                       simplification & cohérence ?
                                                                                                   │
                                                                    ┌──────────────────────────────┴──────────────────────────────┐
                                                                    ▼                                                             ▼
                                                                MINEURE                                                        MAJEURE
                                                        (Différence de syntaxe)                                        (Chemins, anti-cycle)
                                                                    │                                                             │
                                                                    ▼                                                             ▼
                                                            CONSERVER NORMAL                                              À ÉTUDIER (V2.0)
                                                                                                                  (catalogue_relation)
```

### 3.1. Grille d'Évaluation par Famille de Tables

| Famille de Tables | 1. Nature (Entité vs Association) | 2. Identité / Cycle propre ? | 3. Traversée graphe requise ? | 4. TYPE RELATION simplifierait ? | 5. Champ record déjà adapté ? | 6. Bénéfice réel vs syntaxe ? | 7. Recommandation préliminaire |
|---|---|---|---|---|---|---|---|
| **Articles & Types** (`catalogue_item`, `catalogue_type`) | Entité métier fondamentale | Oui, cycle de vie complet (DRAFT -> PUBLISHED -> OBSOLETE) | Non (sont des nœuds, pas des arêtes) | Non, dégraderait le modèle | Oui, parfait | Aucun bénéfice | **CONSERVER NORMAL** |
| **Arborescence Catégories** (`catalogue_categorie`) | Entité taxonomique hiérarchique | Oui | Non (arbre strict via `parent`) | Non (la liste d'adjacence suffit) | Oui (`parent: record`) | Différence de syntaxe | **CONSERVER NORMAL** |
| **Affectation Catégories** (`catalogue_item_categorie`) | Association N-à-N | Faible (attribut `is_primary`) | Non (recherche directe par catégorie ou item) | Faible (syntaxe `->` possible) | Oui (`item`, `categorie`) | Purement syntaxique, complique RLS | **CONSERVER NORMAL** |
| **Attributs & Valeurs** (`catalogue_attribut`, `valeur`) | Entités de dictionnaire | Oui | Non | Non | Oui | Aucun | **CONSERVER NORMAL** |
| **Variantes & Matrice** (`catalogue_variante`, `cva`) | Sous-entité et association ternaire | Oui (empreinte SHA-256) | Non | Non (relation ternaire non supportée en arête binaire) | Oui (`target_scope`) | Inapplicable en graphe pur | **CONSERVER NORMAL** |
| **Nomenclatures BOM** (`composition`, `composition_ligne`) | Entité header et lignes de recette | Oui (verrou scellé, versioning, perte, ordre) | Traversée récursive d'arborescence (anti-cycle) | Partiel sur la traversée, mais détruit le modèle de ligne de facture/ouvrage | Oui (`composition`, `composant_item`) | Risque élevé sur le verrouillage d'immuabilité | **CONSERVER NORMAL** |
| **Relations Inter-Articles** (`catalogue_relation`) | **Association sémantique N-à-N** | **Attributs légers (`ordre`, `commentaire`, `enabled`)** | **OUI (chaînes de remplacement, cycles, accessoires)** | **OUI (autorise `->catalogue_relation->`)** | Fonctionnel mais verbeux en SurrealQL | **Bénéfice réel en traversée et clarté** | **À ÉTUDIER (Cible V2.0)** |
| **Pipeline ETL & Staging** (11 tables d'ingestion) | Entités opérationnelles et journaux d'audit | Oui (machines à états, checkpoints, scellement BLAKE3) | Non (flux séquentiel direct parent-enfant 1:N) | Non, non-sens architectural | Oui (`batch`, `raw_record`) | Dégradation architecturale | **CONSERVER NORMAL** |
| **Règles d'Ingestion** (`family_rule`, `specification`, `alias`) | Règles configurables et dictionnaires | Oui | Non | Non | Oui | Aucun | **CONSERVER NORMAL** |
| **Règles de Substitution** (`ingestion_substitution_rule`) | Règle déclarative d'équivalence | Oui (PV technique, révocation) | Non dans l'ingestion (règle tabulaire) | Non dans l'ingestion | Oui (clés textuelles découplées) | Inadapté au staging | **CONSERVER NORMAL** |

---

## 4. Points d'Attention Spécifiques — `lyxal_catalogue`

### 4.1. Relations entre Articles (`catalogue_relation`)

La table [`catalogue_relation`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/12_catalogue_relation.surql) gère actuellement 7 types de liaisons fondamentales :

```
                               ┌─────────────────────────┐
                               │ catalogue_relation_type │
                               └────────────┬────────────┘
                                            │
        ┌───────────────────┬───────────────┼───────────────┬───────────────────┐
        ▼                   ▼               ▼               ▼                   ▼
  ACCESSOIRE            SUBSTITUT       SIMILAIRE       COMPATIBLE         OBLIGATOIRE
(Complément pose)    (Équivalence)    (Alternative)   (Inter-système)     (Accessoire lié)
        │
        ├───────────────────────────────────┐
        ▼                                   ▼
COMMERCIAL_SPECIFICATION               REMPLACEMENT
(Commerciale -> Générique)          (Obsolète -> Nouveau)
                                  [Détection Anti-Cycle]
```

#### Architecture Actuelle
- Modélisée en `TYPE NORMAL SCHEMAFULL`.
- Deux pointeurs de nœuds : `source: record<catalogue_item>` et `cible: record<catalogue_item>`.
- La bidirectionnalité est implémentée dans [`fn::catalogue_relation_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_create.surql#L85-L98) par l'insertion de **deux enregistrements physiques symétriques** :
  ```surql
  CREATE catalogue_relation CONTENT { source: $source_id, cible: $cible_id, ... };
  CREATE catalogue_relation CONTENT { source: $cible_id, cible: $source_id, ... };
  ```
- La détection de cycles orientés pour `REMPLACEMENT` est déléguée à [`fn::catalogue_relation_check_cycle`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_check_cycle.surql), qui effectue un **parcours récursif en profondeur (DFS) manuel** en interrogeant la table via `SELECT VALUE cible FROM catalogue_relation WHERE source = $current AND relation_type = $rel_type`.

#### Opportunité d'une Modélisation en Graphe Natif (`TYPE RELATION`)
`catalogue_relation` est la **seule table du catalogue** répondant intrinsèquement à la définition d'une arête de graphe SurrealDB :
1. Elle relie deux instances homogènes de la même table de nœuds (`catalogue_item` $\rightarrow$ `catalogue_item`).
2. Les requêtes métiers typiques consistent à naviguer le graphe : *"Quels sont les accessoires compatibles de cet article ?"*, *"Quelle est la chaîne complète de remplacement menant à l'article actif ?"*.
3. En `TYPE RELATION`, la syntaxe de traversée native SurrealDB 3.2.0 s'exprimerait ainsi :
   ```surql
   -- Recherche directe des accessoires
   SELECT ->catalogue_relation[WHERE relation_type = catalogue_relation_type:ACCESSOIRE]->catalogue_item.* 
   FROM catalogue_item:PLACO_BA13_2500;

   -- Recherche bidirectionnelle des compatibles
   SELECT <->catalogue_relation[WHERE relation_type = catalogue_relation_type:COMPATIBLE]<->catalogue_item.* 
   FROM catalogue_item:PLACO_BA13_2500;
   ```

#### Pourquoi Antigravity Recommande de Conserver `TYPE NORMAL` en V1.1 ?
Bien que la modélisation en graphe soit élégante, une conversion immédiate en V1.1 présente des **risques architecturaux inacceptables** :
1. **Rupture des champs obligatoires :** `TYPE RELATION` impose `in` et `out`. Les champs `source` et `cible` doivent être renommés, brisant l'ensemble des fonctions SurrealQL consommatrices.
2. **Complexité du gardien moteur :** [`evt_catalogue_relation_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/12_catalogue_relation.surql#L99) compte 187 lignes de vérifications multi-tenants (`$before.source`, `$after.cible`, etc.). Adapter ces règles sur `$before.in` / `$after.out` sous SurrealDB 3.2.0 présente un risque élevé de régression de sécurité.
3. **Statut clôturé et scellé :** `lyxal_catalogue` V1.1 est officiellement figé.

---

### 4.2. Nomenclatures et Compositions (`catalogue_composition_ligne`)

Certains moteurs de graphes recommandent de transformer les lignes de nomenclature (BOM) en arêtes `composant_de`. Dans Lyxal OS, l'audit démontre que ce choix serait une **erreur de conception** :
- Une ligne de nomenclature [`catalogue_composition_ligne`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/10_catalogue_composition_ligne.surql) ne relie pas simplement deux articles : elle appartient à une **version précise d'une composition** (`composition: record<catalogue_composition>`), porte une quantité décimale, une unité de consommation, un coefficient de perte (`coefficient_perte`), un ordre d'affichage et un commentaire technique.
- Elle est protégée par un verrou d'immuabilité scellé ([`evt_comp_ligne_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/10_catalogue_composition_ligne.surql#L93)) qui dépend du statut de l'en-tête de recette (`is_locked = true`).
- Le modèle En-tête / Lignes relationnel actuel est **robuste, auditable, versionnable et parfaitement adapté**.

---

### 4.3. Matrice d'Attributs (`catalogue_variante_attribut`)

[`catalogue_variante_attribut`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/08_catalogue_variante_attribut.surql) est une **relation ternaire (hyper-arête)** liant :
1. Une cible (Item ou Variante via `target_scope`)
2. Une caractéristique ([`catalogue_attribut`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/05_catalogue_attribut.surql))
3. Une valeur prédéfinie ([`catalogue_attribut_valeur`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/06_catalogue_attribut_valeur.surql))

Dans SurrealDB, `TYPE RELATION` est strictement binaire (`in` $\rightarrow$ `out`). Tenter de forcer une relation ternaire dans une arête binaire nécessiterait d'attacher `attribut_valeur` comme simple propriété d'arête, perdant l'intégrité référentielle native et compliquant l'index d'unicité `idx_scope_attr`.  
Le modèle relationnel actuel avec recalcul d'empreinte SHA-256 par événement est optimal.

---

### 4.4. Affectation des Catégories (`catalogue_item_categorie`)

#### Faisabilité Technique d'une Modélisation en Arête
Techniquement, [`catalogue_item_categorie`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/04_catalogue_item_categorie.surql) pourrait être déclarée en arête de graphe native :
```surql
DEFINE TABLE catalogue_item_categorie TYPE RELATION IN catalogue_item OUT catalogue_categorie SCHEMAFULL;
```
Cela autoriserait une syntaxe de navigation expressive :
```surql
-- Trouver les catégories d'un article
SELECT ->catalogue_item_categorie->catalogue_categorie.* FROM catalogue_item:PLACO_BA13_2500;

-- Trouver les articles d'une catégorie principale
SELECT <-(catalogue_item_categorie WHERE is_primary = true)<-catalogue_item.* FROM catalogue_categorie:CLOISONS;
```

#### Justification du Maintien en `TYPE NORMAL`
Malgré cette élégance syntaxique, la table est **maintenue en `TYPE NORMAL`** pour cinq raisons techniques majeures :
1. **Jonction relationnelle standard éprouvée :** La table associe deux entités hétérogènes (`catalogue_item` et `catalogue_categorie`) avec un attribut de qualification propre (`is_primary: bool`). La modélisation relationnelle N-à-N classique est parfaitement standard, prédictible et sans risque.
2. **Absence de traversée multi-sauts :** Les requêtes applicatives du catalogue ne réalisent jamais de parcours de graphe complexe sur les catégories. Elles se limitent à deux opérations simples :
   - Lister les catégories rattachées à un article (`WHERE item = $item`)
   - Lister les articles rattachés à une catégorie (`WHERE categorie = $categorie`)  
   Ces deux accès sont déjà couverts de manière optimale par les index composites bidirectionnels `idx_item_cat_unique` (`item, categorie UNIQUE`) et `idx_item_cat_lookup` (`categorie, item`).
3. **Sécurité Row-Level Security (RLS) étanche :** Les règles RLS actuelles de [`catalogue_item_categorie`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/04_catalogue_item_categorie.surql#L10-L30) évaluent `item.is_custom` et `item.tenant_id`. Sur une table normale, la résolution de ces propriétés sur le champ de clé étrangère `item` est directe. Sur une table `TYPE RELATION`, l'évaluation via `$this.in` dans les clauses RLS sous concurrence présente des subtilités sans gain métier.
4. **Impact sur les fonctions existantes :** Une conversion briserait immédiatement 5 fonctions SurrealQL en production ([`fn::catalogue_item_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_create.surql), [`fn::catalogue_item_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_delete.surql), [`fn::catalogue_item_get`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_get.surql), [`fn::catalogue_item_list`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/item/catalogue_item_list.surql), [`fn::catalogue_categorie_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/categorie/catalogue_categorie_delete.surql)).
5. **Sanctuarisation de la V1.1 gelée :** Le module est formellement clôturé. Une telle modification représenterait un coût de dégel et de non-régression sans aucun bénéfice fonctionnel.

---

## 5. Points d'Attention Spécifiques — `lyxal_pipeline_ingestion`

### 5.1. Nature du Pipeline ETL : Traçabilité vs Graphe

L'ensemble du module [`lyxal_pipeline_ingestion`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion) repose sur une **chaîne séquentielle de traitement par lots** :

$$\text{Fichier Fabricant} \xrightarrow{\text{BLAKE3}} \text{Batch} \xrightarrow{\text{Chunk}} \text{Raw Records} \xrightarrow{\text{Normalisation}} \text{Staged Items} \xrightarrow{\text{Approbation}} \text{Manifeste}$$

Aucune de ces étapes ne constitue un graphe au sens réseau :
- Le lien `raw_record.batch` est une **clé de traçabilité 1-à-N descendante**.
- Le lien `staged_item.raw_record` est un **pointeur d'origine d'audit immuable**.
- Le lien `quarantine_record.raw_record` est un **journal d'anomalie**.
- Le lien `manifest.batch` est un **agrégat d'approbation scellé**.

Transformer ces liens en arêtes `TYPE RELATION` alourdirait le schéma, imposerait une syntaxe verbeuse sans aucun bénéfice, et dégraderait les performances de streaming lors de l'insertion de lots massifs (plusieurs dizaines de milliers de lignes).

---

### 5.2. Règles de Substitution Industrielle (`ingestion_substitution_rule`)

La table [`ingestion_substitution_rule`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/10_ingestion_substitution_rule.surql) gère les équivalences certifiées de Niveau 4 :
- Elle n'utilise délibérément **aucun champ `record<catalogue_item>`**, mais des quadruplets textuels (`source_mfg`, `source_ref`, `target_mfg`, `target_ref`) associés à un `system_scope` (ex: `SYSTEME_CLOISON_DISTRIBUTION_72_48`) et à une référence de certification (ex: `Avis Technique CSTB n° 9/21-1050_V1`).
- **Justification architecturale :** Les règles de substitution sont ingérées et configurées **avant** que les articles correspondants ne soient créés ou publiés dans le Master Catalogue. Elles constituent des règles d'évaluation pour le moteur de qualification, et non des liens entre des enregistrements existants en base.
- **Évolution future (V1.2) :** Lors de l'exécution de la publication vers le Master Catalogue, ces règles pourront générer des arêtes de substitution contextualisées dans `lyxal_catalogue` (voir Section 7). Mais au sein du pipeline, la table doit impérativement rester `TYPE NORMAL`.

---

## 6. Analyse des Dépendances, Risques et Impacts de Migration

Pour toute tentative de conversion de table vers `TYPE RELATION`, la matrice d'impacts techniques suivante s'impose :

```
┌────────────────────────────────────────────────────────────────────────────────┐
│               ANALYSE DES IMPACTS D'UNE CONVERSION EN TYPE RELATION            │
├─────────────────────┬──────────────────────────────────────────────────────────┤
│ Composant           │ Nature de l'Impact & Risques                             │
├─────────────────────┼──────────────────────────────────────────────────────────┤
│ Syntaxe DDL         │ Remplacement obligatoire de source/cible par in/out.     │
│ Identifiants (IDs)  │ Format modifié en relation:['id_in', 'id_out'].          │
│ Fonctions SurrealQL │ Réécriture des SELECT, CREATE, DELETE et anti-cycles.    │
│ Code Rust           │ Renommage des champs (attribut #[serde(rename = "in")]). │
│ Permissions RLS     │ Réévaluation complète de $this.in et $this.out.          │
│ Gardiens Moteurs    │ Réécriture intégrale de evt_catalogue_relation_guard.    │
│ Seeds & Migrations  │ Script de migration complexe pour réécrire les données.  │
│ Stabilité Versions  │ Dégel forcé des versions V1.1 / V1.0.0 clôturées.        │
└─────────────────────┴──────────────────────────────────────────────────────────┘
```

### 6.1. Détail par Type d'Impact

1. **Impact sur les Fonctions SurrealQL :**
   - [`fn::catalogue_relation_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_create.surql) utilise actuellement `CREATE catalogue_relation CONTENT { source: ..., cible: ... }`. Avec `TYPE RELATION`, cette écriture doit être convertie en `RELATE $source->catalogue_relation->$cible SET ...`.
   - [`fn::catalogue_relation_check_cycle`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_check_cycle.surql) et [`fn::catalogue_relation_delete`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_delete.surql) doivent être réécrites pour interroger `in` et `out`.

2. **Impact sur le Code Rust :**
   - Dans les structs Rust (`RelationModel`, `CreateRelationParams`), le mot-clé `in` est un mot réservé Rust. Il impose l'utilisation de syntaxe brute `r#in` ou d'attributs Serde :
     ```rust
     #[derive(Debug, Serialize, Deserialize)]
     pub struct CatalogueRelation {
         pub id: Thing,
         #[serde(rename = "in")]
         pub r#in: Thing,
         #[serde(rename = "out")]
         pub out: Thing,
         pub relation_type: Thing,
         pub ordre: i32,
     }
     ```

3. **Risque de Perte de Données et Rupture d'Identifiants :**
   - SurrealDB génère par défaut les identifiants de relations sous la forme `table:['source', 'cible']`. Toute application cliente ou test s'appuyant sur des identifiants conventionnels subirait une rupture immédiate.
   - Les migrations SurrealDB 3.2.0 ne supportent pas `ALTER TABLE ... TYPE RELATION` in-place si des colonnes existantes ne sont pas nommées `in` et `out`. Une table temporaire et un export/import complet des relations seraient obligatoires.

4. **Complexité Globale :**
   - Pour `catalogue_relation` : **Complexité ÉLEVÉE** (gardiens RLS, anti-cycle, multi-tenancy).
   - Pour les autres tables : **Inapproprié ou Inutile**.

---

## 7. Tableau de Décision Obligatoire

| Module | Table | Type Actuel | Type Recommandé | Justification Architecturale | Impact Technique | Priorité |
|---|---|---|---|---|---|---|
| `lyxal_catalogue` | `catalogue_session` | `TYPE NORMAL` | **CONSERVER NORMAL** | Table opérationnelle d'authentification et de session RLS. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_type` | `TYPE NORMAL` | **CONSERVER NORMAL** | Référentiel fondamental de typologie (PRODUIT, SERVICE, etc.). | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_item` | `TYPE NORMAL` | **CONSERVER NORMAL** | Nœud central universel du catalogue (Node). Ne peut pas être une arête. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_categorie` | `TYPE NORMAL` | **CONSERVER NORMAL** | Taxonomie arborescente gérée par liste d'adjacence (`parent`). | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_item_categorie` | `TYPE NORMAL` | **CONSERVER NORMAL** | Jonction N-à-N relationnelle standard avec RLS multi-tenant étanche. | Faible | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_attribut` | `TYPE NORMAL` | **CONSERVER NORMAL** | Dictionnaire de caractéristiques techniques. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_attribut_valeur` | `TYPE NORMAL` | **CONSERVER NORMAL** | Dictionnaire de valeurs discrètes autorisées. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_variante` | `TYPE NORMAL` | **CONSERVER NORMAL** | Déclinaison physique/commerciale de l'article parent. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_variante_attribut` | `TYPE NORMAL` | **CONSERVER NORMAL** | Relation ternaire (Item/Variante + Attribut + Valeur) incompatible avec arête binaire pure. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_composition` | `TYPE NORMAL` | **CONSERVER NORMAL** | En-tête de nomenclature avec cycle de vie, versioning et verrou scellé. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_composition_ligne` | `TYPE NORMAL` | **CONSERVER NORMAL** | Ligne de nomenclature détaillée (quantité, unité, perte, ordre). Modèle de document robuste. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_relation_type` | `TYPE NORMAL` | **CONSERVER NORMAL** | Dictionnaire de typologie des liaisons. | Aucun | P3 — Neutre |
| `lyxal_catalogue` | `catalogue_relation` | `TYPE NORMAL` | **À ÉTUDIER (V2.0)** | Arête de graphe naturelle inter-articles. Bénéfice réel sur traversées et anti-cycles. À planifier pour V2.0 afin de ne pas déstabiliser la V1.1 gelée. | Élevé | P2 — Évolution V2.0 |
| `lyxal_pipeline_ingestion` | `ingestion_session` | `TYPE NORMAL` | **CONSERVER NORMAL** | Table d'authentification des agents Record Users. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_batch` | `TYPE NORMAL` | **CONSERVER NORMAL** | Entité racine de lot d'ingestion avec machine à états et checkpointing. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_raw_record` | `TYPE NORMAL` | **CONSERVER NORMAL** | Zone tampon immuable de traçabilité des lignes sources brutes. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_staged_item` | `TYPE NORMAL` | **CONSERVER NORMAL** | Entité de staging normalisée avec triptyque de qualification. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_quarantine_record` | `TYPE NORMAL` | **CONSERVER NORMAL** | Journal d'audit scellé des rejets (Dead Letter Queue). | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_publication_manifest` | `TYPE NORMAL` | **CONSERVER NORMAL** | Manifeste de publication scellé par BLAKE3 et approuvé par le Data Steward. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_family_rule` | `TYPE NORMAL` | **CONSERVER NORMAL** | Table de règles configurables pour le regroupement de familles. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_specification` | `TYPE NORMAL` | **CONSERVER NORMAL** | Spécifications patronnes et tolérances métrologiques. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_manufacturer_alias` | `TYPE NORMAL` | **CONSERVER NORMAL** | Dictionnaire de résolution d'alias fabricants vers noms canoniques. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_unit_alias` | `TYPE NORMAL` | **CONSERVER NORMAL** | Dictionnaire de correspondance des unités brutes vers `base_unite`. | Aucun | P3 — Neutre |
| `lyxal_pipeline_ingestion` | `ingestion_substitution_rule` | `TYPE NORMAL` | **CONSERVER NORMAL** | Règles de substitution Niveau 4 fondées sur des références fabricants découplées. | Aucun | P3 — Neutre |
| `lyxal_catalogue` (Futur V1.2) | `catalogue_substitution` | *Nouvelle table* | **CRÉER UNE TABLE RELATION DÉDIÉE** | Arête native SurrealDB pour matérialiser les substitutions contextualisées certifiées entre articles Master avec périmètre système constructif. | Moyen | P2 — Roadmap V1.2 |
| `lyxal_base` | `base_unite` | `TYPE NORMAL` | **CONSERVER NORMAL** | Référentiel universel des unités de mesure. | Aucun | P3 — Neutre |
| `lyxal_base` | `base_unite_type` | `TYPE NORMAL` | **CONSERVER NORMAL** | Typologie dimensionnelle physique des unités. | Aucun | P3 — Neutre |
| `lyxal_error` | `error_definition` | `TYPE NORMAL` | **CONSERVER NORMAL** | Définitions d'erreurs standardisées Lyxal OS. | Aucun | P3 — Neutre |

---

### 7.1. Exemples Conceptuels de DDL Graphe Natif SurrealDB 3.2.0

#### Exemple 1 : Arête Dédiée pour les Substitutions Contextualisées (Roadmap V1.2)
Dans le cadre de la roadmap V1.2 de `lyxal_catalogue` (*Substitutions et équivalences contextualisées*), plutôt que de modifier la table existante `catalogue_relation`, la création d'une arête dédiée `catalogue_substitution` permettrait d'exploiter le graphe natif **sans aucun breaking change sur l'existant** :

```surql
-- ============================================================================
-- TABLE  : catalogue_substitution
-- MODULE : lyxal_catalogue (Cible V1.2)
-- RÔLE   : Arête de graphe natif pour substitutions certifiées et contextualisées
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_substitution
    TYPE RELATION
    IN catalogue_item
    OUT catalogue_item
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue")
            OR ($auth != NONE)
        )
        FOR create, update, delete WHERE (
            ($token != NONE AND $token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope)
            OR ($auth != NONE AND $auth.role = "catalogue_sync_agent")
        )
    COMMENT "Arête de graphe natif représentant une substitution technique certifiée entre deux articles";

DEFINE FIELD OVERWRITE system_scope ON TABLE catalogue_substitution
    TYPE string
    ASSERT string::len($value) >= 3
    COMMENT "Système constructif dans lequel la substitution est valide (ex: SYSTEME_CLOISON_DISTRIBUTION_72_48)";

DEFINE FIELD OVERWRITE certification_ref ON TABLE catalogue_substitution
    TYPE string
    COMMENT "Référence de l'Avis Technique, PV CSTB ou certification officielle";

DEFINE FIELD OVERWRITE valid_until ON TABLE catalogue_substitution
    TYPE datetime
    COMMENT "Date de fin de validité de la certification";

DEFINE FIELD OVERWRITE is_revoked ON TABLE catalogue_substitution
    TYPE bool
    DEFAULT false
    COMMENT "Indique si l'équivalence a été formellement révoquée";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_substitution
    TYPE datetime
    DEFAULT time::now()
    READONLY;

-- Index garantissant l'unicité du triplet orienté par système constructif
DEFINE INDEX OVERWRITE idx_subst_graph_unique ON TABLE catalogue_substitution 
    FIELDS in, out, system_scope UNIQUE;
```

#### Exemple de Création via `RELATE` :
```surql
-- Création idempotente d'une arête de substitution native
RELATE catalogue_item:PLACO_BA13_2500->catalogue_substitution->catalogue_item:KNAUF_BA13_2500 CONTENT {
    system_scope: "SYSTEME_CLOISON_DISTRIBUTION_72_48",
    certification_ref: "Avis Technique CSTB n° 9/21-1050_V1",
    valid_until: '2028-12-31T23:59:59Z',
    is_revoked: false,
    created_at: time::now()
};
```

#### Exemple de Requête de Traversée de Graphe :
```surql
-- Trouver tous les substituts valides d'un article dans un système constructif donné
SELECT 
    ->catalogue_substitution[WHERE system_scope = "SYSTEME_CLOISON_DISTRIBUTION_72_48" AND is_revoked = false AND valid_until > time::now()]->catalogue_item.* AS substitutes
FROM catalogue_item:PLACO_BA13_2500;
```

---

## 8. Recommandation Finale d'Antigravity

### 8.1. Synthèse de l'Arbitrage Architectural

L'analyse exhaustive et factuelle du code source conduit aux conclusions suivantes :

1. **Sur l'ensemble du module `lyxal_pipeline_ingestion` (11 tables) :**  
   L'utilisation de `TYPE RELATION` est **totalement injustifiée et contre-indiquée**. Le module est un pipeline ETL transactionnel séquentiel fondé sur l'idempotence cryptographique (BLAKE3) et l'immuabilité des traces d'audit. Le modèle `TYPE NORMAL` actuel avec pointeurs `record<...>` est la solution la plus performante, la plus simple et la plus sûre.

2. **Sur les tables structurelles de `lyxal_catalogue` (12 tables sur 13) :**  
   Les tables d'articles, catégories, attributs, variantes et compositions doivent **impérativement demeurer en `TYPE NORMAL`**. Leurs contraintes métier (nomenclatures versionnées, empreintes SHA-256 déterministes, relations ternaires) ne correspondent pas à des arêtes de graphe binaires simples.

3. **Sur la table `catalogue_relation` :**  
   Elle constitue la **seule arête conceptuelle** du domaine. Cependant, la convertir rétroactivement en V1.1 briserait les contrats d'API, invaliderait la suite de tests validée, et forcerait le dégel d'une version clôturée sans apporter de nouvelle fonctionnalité métier aux utilisateurs.

---

### 8.2. Recommandation Stratégique en 3 Étapes Soumise au CTO

```
┌────────────────────────────────────────────────────────────────────────┐
│                      STRATÉGIE RECOMMANDÉE PAR ANTIGRAVITY             │
├────────────────────────────────────────────────────────────────────────┤
│ ÉTAPE 1 : SANCTUARISATION DU SOCLE V1 (IMMÉDIAT)                       │
│ - Conserver 100% des tables actuelles en TYPE NORMAL.                  │
│ - Maintenir le gel officiel de lyxal_catalogue V1.1.                   │
│ - Maintenir le gel officiel de lyxal_pipeline_ingestion V1.0.0.       │
│                                                                        │
│ ÉTAPE 2 : INTRODUCTION NON-DESTRUCTIVE DU GRAPHE EN V1.2 (TRANSITION)  │
│ - Conserver catalogue_relation pour les relations génériques.          │
│ - Créer la table dédiée TYPE RELATION catalogue_substitution           │
│   pour les substitutions contextualisées certifiées.                   │
│ - Valider le comportement du graphe natif SurrealDB 3.2.0 en isolation.│
│                                                                        │
│ ÉTAPE 3 : UNIFICATION DU GRAPHE MAJEURE EN V2.0 (FUTUR)                │
│ - Évaluer la migration de catalogue_relation vers TYPE RELATION        │
│   uniquement dans le cadre d'une release majeure V2.0, accompagnée     │
│   d'un plan de migration ordonné et de la dépréciation des fonctions.  │
└────────────────────────────────────────────────────────────────────────┘
```

> **Avis d'Antigravity :**  
> **L'architecture actuelle est saine, rigoureuse et parfaitement conforme aux exigences opérationnelles de Lyxal OS.**  
> Il n'y a aucune urgence technique à migrer les tables existantes vers `TYPE RELATION`. L'introduction du graphe natif SurrealDB doit s'effectuer de manière incrémentale et ciblée, via de nouveaux contrats dédiés (V1.2), sans jamais déstabiliser les fondations de production.

---

*Rapport d'audit officiel établi et scellé pour examen par la Direction Technique (CTO) de Lyxal OS.*
