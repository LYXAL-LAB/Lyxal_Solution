# 📋 Plan d'Implémentation V4 (Final) — Fonctions & Master Data `lyxal_base` (Unité & Type d'Unité)

> Version validée pour mise en production (Évaluation : 9.5/10) intégrant les règles de cohérence hiérarchique, de non-écrasement des seeds et de sécurité d'authentification contextuelle.

---

## 1. Principes Fondamentaux & Règles d'Intégrité Validées

### 1.1. Sécurité, Contexte Authentifié & Concurrence Transactionnelle (CTO Point 3)
* **Non-falsifiabilité de l'authentification** :
  * Interdiction formelle de s'en remettre à un `$params.auth` fourni arbitrairement par le client appelant.
  * Les vérifications d'identité et de permissions sont adossées au contexte de session serveur (`$auth` natif SurrealDB ou vérifié cryptographiquement par le middleware hôte `lyxal_server` / session `lyxal_auth`).
* **Protection transactionnelle** :
  * Les mutations sensibles (création avec vérification de type, suppression/désactivation en cascade conditionnelle) s'exécutent au sein de blocs transactionnels natifs SurrealQL (`BEGIN TRANSACTION ... COMMIT TRANSACTION`) ou de requêtes atomiques garantissant qu'aucune écriture concurrente ne s'intercale entre la vérification de conformité et l'enregistrement.

### 1.2. Cohérence Métier Hiérarchique & Désactivation (CTO Point 2)
* **Règles d'intégrité entre `unite` et `unite_type`** :
  1. **Création d'unité** : Interdiction absolue de créer une unité active (`enabled: true`) rattachée à un type désactivé (`enabled: false`). Rejet avec code `BASE_UNITE_TYPE_DISABLED` (HTTP 422).
  2. **Modification / Réactivation d'une unité** : Interdiction de réactiver (`enabled: true`) ou de rattacher une unité à un type dont l'`enabled` est à `false`. Rejet avec `BASE_UNITE_TYPE_DISABLED`.
  3. **Préservation historique immuable** : La désactivation d'un type d'unité ne mute pas rétroactivement les unités existantes (les données historiques des devis/factures restent parfaitement intègres et lisibles). Les unités actives déjà rattachées continuent d'exister pour lecture mais sont exclues de la sélection de nouveaux documents si le type est inactif.

### 1.3. Distanciation Seeds d'Initialisation vs Migrations (CTO Point 1)
* **Protection contre l'écrasement post-installation** :
  * Les scripts de seeds initiaux (`seeds/`) utilisent la stratégie `INSERT IGNORE` (ou vérification conditionnelle d'existence) sur identifiants déterministes :
  ```surql
  -- N'insère que si l'enregistrement n'existe pas encore
  -- Ne modifie JAMAIS un libellé ou un statut personnalisé par l'utilisateur après installation
  INSERT IGNORE INTO unite_type [
      { id: unite_type:LONGUEUR, code: "LONGUEUR", libelle: "LONGUEUR", enabled: true, created_at: time::now() },
      { id: unite_type:SURFACE, code: "SURFACE", libelle: "SURFACE", enabled: true, created_at: time::now() },
      { id: unite_type:VOLUME, code: "VOLUME", libelle: "VOLUME", enabled: true, created_at: time::now() },
      { id: unite_type:MASSE, code: "MASSE", libelle: "MASSE", enabled: true, created_at: time::now() },
      { id: unite_type:DUREE, code: "DUREE", libelle: "DUREE", enabled: true, created_at: time::now() },
      { id: unite_type:QUANTITE, code: "QUANTITE", libelle: "QUANTITE", enabled: true, created_at: time::now() }
  ];
  ```
  * Les migrations déclaratives (`migrations/`) sont quant à elles réservées aux évolutions structurelles intentionnelles pilotées par le runtime.

---

## 2. Évolution des Schémas (`schema/`)

Ajout du champ `enabled` dans :
* [unite_type.surql](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_base/schema/unite_type.surql) :
  ```surql
  DEFINE FIELD OVERWRITE enabled
      ON TABLE unite_type
      TYPE bool
      DEFAULT true
      COMMENT "Indique si le type d'unité est actif";
  ```
* [unite.surql](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_base/schema/unite.surql) :
  ```surql
  DEFINE FIELD OVERWRITE enabled
      ON TABLE unite
      TYPE bool
      DEFAULT true
      COMMENT "Indique si l'unité est active pour les nouveaux documents";
  ```

---

## 3. Master Data d'Erreurs Exhaustif (`BASE_*`)

Emplacement : `crates/lyxal_base/seeds/error_definitions.surql`

| Code d'erreur | Domaine | HTTP | Cause / Message |
|---|---|---|---|
| `BASE_UNITE_TYPE_NOT_FOUND` | `unite_type` | 404 | Type d'unité introuvable |
| `BASE_UNITE_TYPE_ALREADY_EXISTS` | `unite_type` | 409 | Un type d'unité avec ce code existe déjà |
| `BASE_UNITE_TYPE_CODE_REQUIRED` | `unite_type` | 400 | Le code du type d'unité est obligatoire |
| `BASE_UNITE_TYPE_CODE_INVALID` | `unite_type` | 422 | Le code du type d'unité est invalide (1-32 caractères alphanumériques) |
| `BASE_UNITE_TYPE_LIBELLE_REQUIRED` | `unite_type` | 400 | Le libellé du type d'unité est obligatoire |
| `BASE_UNITE_TYPE_LIBELLE_INVALID` | `unite_type` | 422 | Le libellé est invalide (1-128 caractères) |
| `BASE_UNITE_TYPE_IN_USE` | `unite_type` | 409 | Ce type d'unité est rattaché à une ou plusieurs unités et ne peut être supprimé physiquement |
| `BASE_UNITE_TYPE_DISABLED` | `unite_type` | 422 | Le type d'unité sélectionné est désactivé et ne peut accepter de nouvelles unités actives |
| `BASE_UNITE_NOT_FOUND` | `unite` | 404 | Unité introuvable |
| `BASE_UNITE_ALREADY_EXISTS` | `unite` | 409 | Une unité avec ce code existe déjà |
| `BASE_UNITE_CODE_REQUIRED` | `unite` | 400 | Le code de l'unité est obligatoire |
| `BASE_UNITE_CODE_INVALID` | `unite` | 422 | Le code de l'unité est invalide (1-32 caractères alphanumériques) |
| `BASE_UNITE_LIBELLE_REQUIRED` | `unite` | 400 | Le libellé de l'unité est obligatoire |
| `BASE_UNITE_LIBELLE_INVALID` | `unite` | 422 | Le libellé de l'unité est invalide (1-128 caractères) |
| `BASE_UNITE_ABREVIATION_REQUIRED` | `unite` | 400 | L'abréviation de l'unité est obligatoire |
| `BASE_UNITE_ABREVIATION_INVALID` | `unite` | 422 | L'abréviation est invalide (1-10 caractères) |
| `BASE_UNITE_TYPE_REQUIRED` | `unite` | 400 | La référence vers un type d'unité est obligatoire |
| `BASE_UNITE_TYPE_INVALID` | `unite` | 422 | Le type d'unité référencé est inexistant en base |
| `BASE_UNITE_IN_USE` | `unite` | 409 | Cette unité est référencée dans des documents ou modules métier et ne peut être supprimée physiquement |
| `BASE_NO_UPDATABLE_FIELDS_PROVIDED` | `general` | 400 | Aucun champ modifiable n'a été fourni |
| `BASE_PAGINATION_INVALID` | `general` | 422 | Paramètres de pagination invalides (limit entre 1 et 200, start >= 0) |

---

## 4. Spécification des Fonctions SurrealQL

### 4.1. Domaine `unite_type` (`crates/lyxal_base/functions/unite_type/`)

1. **`fn::base_unite_type_create($params: object)`**
   * Validation code (alphanum, 1-32) & libelle (1-128).
   * Identifiant déterministe généré : `type::thing("unite_type", $clean_code)`.
   * Création avec `enabled: true`.
   * Retourne `fn::result_ok($created)`.

2. **`fn::base_unite_type_get($params: object)`**
   * Recherche par `id` prioritaire, repli sur `code`.
   * Retourne `fn::result_ok($record)` ou 404.

3. **`fn::base_unite_type_list($params: object)`**
   * Filtrage optionnel sur `enabled` (`$params.enabled`).
   * Pagination bornée (1 à 200).
   * Retourne `fn::result_ok($records)`.

4. **`fn::base_unite_type_update($params: object)`**
   * Mise à jour de `libelle` et/ou `enabled`.
   * Rejet si aucun champ modifiable n'est fourni.
   * Retourne `fn::result_ok($updated)`.

5. **`fn::base_unite_type_delete($params: object)`**
   * Vérifie l'absence stricte de référence dans `unite`.
   * Si des unités y sont rattachées ➔ `BASE_UNITE_TYPE_IN_USE` (409) avec recommandation de désactiver (`enabled = false`).
   * Sinon suppression physique.

---

### 4.2. Domaine `unite` (`crates/lyxal_base/functions/unite/`)

1. **`fn::base_unite_create($params: object)`**
   * Validation code, libellé, abréviation.
   * **Contrôle hiérarchique de type** : Vérifie l'existence effective et que `enabled == true` du type rattaché. Si `enabled == false` ➔ `BASE_UNITE_TYPE_DISABLED` (422).
   * Identifiant déterministe : `type::thing("unite", $clean_code)`.
   * Création avec `enabled: true`.
   * Retourne `fn::result_ok($created)`.

2. **`fn::base_unite_get($params: object)`**
   * Recherche par `id` ou `code`.
   * Retourne `fn::result_ok($record)` ou 404.

3. **`fn::base_unite_list($params: object)`**
   * Filtre optionnel par `type` et par `enabled`.
   * Pagination bornée.
   * Retourne `fn::result_ok($records)`.

4. **`fn::base_unite_update($params: object)`**
   * Vérifie l'existence du record `$params.id`.
   * Si mise à jour de `type` : vérifie qu'il existe et est actif (`enabled == true`).
   * Si passage de `enabled` à `true` (réactivation) : vérifie impérativement que le type d'unité parent est actif (`enabled == true`). Sinon ➔ `BASE_UNITE_TYPE_DISABLED`.
   * Rejet si aucun champ modifiable n'est transmis.
   * Retourne `fn::result_ok($updated)`.

5. **`fn::base_unite_delete($params: object)`**
   * Vérifie que l'unité n'est pas utilisée.
   * Si utilisée dans des documents ou devis ➔ `BASE_UNITE_IN_USE` (409) et recommandation de désactiver (`enabled = false`).
   * Retourne `fn::result_ok({ deleted: true })`.

---

## 5. Données Initiales & Seeds Déterministes Non Destructifs

Ordre d'exécution garanti :
1. `seeds/error_definitions.surql` : Définitions d'erreurs `BASE_*` avec `UPSERT ONLY`.
2. `seeds/unite_type_initial.surql` : Types fondamentaux via `INSERT IGNORE` (`unite_type:LONGUEUR`, `unite_type:SURFACE`, etc.).
3. `seeds/unite_initial.surql` : Unités standard via `INSERT IGNORE` (`unite:M`, `unite:KG`, etc.).

---

## 6. Arborescence Cible des Fichiers

```text
crates/lyxal_base/
├── schema/
│   ├── unite_type.surql              <-- Contient le champ enabled
│   └── unite.surql                   <-- Contient le champ enabled
├── functions/
│   ├── unite_type/
│   │   ├── unite_type_create.surql
│   │   ├── unite_type_get.surql
│   │   ├── unite_type_list.surql
│   │   ├── unite_type_update.surql
│   │   └── unite_type_delete.surql
│   └── unite/
│       ├── unite_create.surql
│       ├── unite_get.surql
│       ├── unite_list.surql
│       ├── unite_update.surql
│       └── unite_delete.surql
├── seeds/
│   ├── error_definitions.surql       <-- Master data d'erreurs BASE_* (UPSERT)
│   ├── unite_type_initial.surql      <-- Étape 1 : Types déterministes (INSERT IGNORE)
│   └── unite_initial.surql           <-- Étape 2 : Unités déterministes (INSERT IGNORE)
└── implementation_plan.md
```
