# `lyxal_base` — Référentiels de base

Référentiel transversal des unités de mesure, de leurs types (longueur, surface, conditionnement,
énergie…) et de leurs codes d'échange normalisés, utilisé par les modules métiers. Module **SurrealQL seul** : tables, fonctions, erreurs
et seeds, sans crate Rust.

| | |
| :--- | :--- |
| Identifiant | `lyxal_base` (version `0.1.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_error` |
| Hébergement | `apps/lyxal-server` (`ManifestModule`, installé depuis le manifeste) |
| Consommateurs | `lyxal_catalogue`, `lyxal_pipeline_ingestion` |
| Évolutions prévues | [`ROADMAP.md`](ROADMAP.md) |

---

## 1. Contrat public

* **Fonctions** `fn::base_*($params: object)` (§3), au contrat `fn::result_ok` /
  `fn::error_result`. Un module consommateur lit les unités **uniquement** par
  `fn::base_unite_get`, jamais par les tables (`.agents/AGENTS.md` §1).
* **Identifiants** : `base_unite:<CODE>` et `base_unite_type:<CODE>`, où `<CODE>` est le code
  alphanumérique en majuscules. Un module consommateur les stocke dans des champs
  `record<base_unite>` déclarés `REFERENCE ON DELETE REJECT` : une unité utilisée ne peut pas être
  supprimée.
* **Unité utilisable** (`usable` dans `fn::base_unite_get`) : unité **et** type actifs. C'est la
  seule règle d'emploi d'une unité dans un nouveau document ; les consommateurs ne la recopient
  pas.

---

## 2. Tables (`schema/`)

3 tables `TYPE NORMAL SCHEMAFULL`, lisibles par toute identité, écrites seulement par une session
d'administration (root ou système de l'hôte).

| Table | Champs | Contraintes |
| :--- | :--- | :--- |
| `base_unite_type` | `code`, `libelle`, `enabled`, `is_system`, `created_at`, `updated_at` | `code` unique, alphanumérique en majuscules (1 à 32) ; `libelle` sans espaces périphériques (1 à 128) ; `is_system` et `created_at` immuables |
| `base_unite` | idem, plus `abreviation` (1 à 10) et `type` (`record<base_unite_type>`, `REFERENCE ON DELETE REJECT`) | mêmes contraintes ; un type portant des unités ne se supprime pas |
| `base_unite_code` | `norme` (`UNECE_REC20` : unités de mesure ; `UNECE_REC21` : types d'emballage), `code`, `unite` (`record<base_unite>`, `REFERENCE ON DELETE REJECT`), `created_at` | identifiant `base_unite_code:[<NORME>, <CODE>]` ; (`norme`, `code`) unique ; plusieurs codes par unité |

Les libellés sont conservés tels que saisis (« Mètre carré ») ; le nettoyage est fait par les
fonctions, le schéma vérifie le résultat (`ASSERT`).

---

## 3. Fonctions (`functions/`)

11 fonctions. Entrées validées puis nettoyées par le moteur de `lyxal_core`
(`fn::validation_object_execute`, `fn::sanitize_object_execute`, `unknown_keys: "reject"`) ;
donnée invalide : `BASE_INVALID_PARAMETERS` avec le détail par champ (`details.fields`).
Identifiants transmis en texte et contrôlés par table (règle `record`) : un identifiant d'une
autre table est refusé. Chaque écriture est vérifiée : `BASE_WRITE_FORBIDDEN` si les permissions
la filtrent. Paramètre commun : `language` (`fr` par défaut), langue des messages d'erreur.

| Fonction | Paramètres | Règles |
| :--- | :--- | :--- |
| `fn::base_unite_type_create` | `code`, `libelle` | code unique (`BASE_UNITE_TYPE_ALREADY_EXISTS`) ; type créé actif, non système |
| `fn::base_unite_type_get` | `id` ou `code` | `BASE_UNITE_TYPE_NOT_FOUND` |
| `fn::base_unite_type_list` | `enabled`, `limit` (1 à 200, défaut 50), `start` | tri par code |
| `fn::base_unite_type_update` | `id`, `libelle`, `enabled` | au moins un champ (`BASE_NO_UPDATABLE_FIELDS_PROVIDED`) ; la désactivation ne modifie pas les unités rattachées |
| `fn::base_unite_type_delete` | `id` | refus si système (`BASE_UNITE_TYPE_IS_SYSTEM`) ou référencé (`BASE_UNITE_TYPE_IN_USE`, nombre de références) |
| `fn::base_unite_create` | `code`, `libelle`, `abreviation`, `type` | type existant (`BASE_UNITE_TYPE_INVALID`) et actif (`BASE_UNITE_TYPE_DISABLED`) ; code unique (`BASE_UNITE_ALREADY_EXISTS`) |
| `fn::base_unite_get` | `id` ou `code`, `fetch_type` | renvoie l'unité, `usable`, ses codes d'échange (`codes` : `[{ norme, code }]`) et, si `fetch_type`, le type (`type_detail`) ; `BASE_UNITE_NOT_FOUND` |
| `fn::base_unite_resolve` | `codes` (tableau de chaînes, 500 au plus) | résolution d'un bloc en une requête : code Lyxal, puis code d'échange (`UNECE_REC20` avant `UNECE_REC21`), recherche en majuscules ; renvoie `{ <brut sans espaces périphériques>: { code, usable } }`, sans entrée pour un code inconnu |
| `fn::base_unite_list` | `type`, `enabled`, `for_new_documents`, `limit`, `start` | `for_new_documents` : unités utilisables seulement |
| `fn::base_unite_update` | `id`, `libelle`, `abreviation`, `type`, `enabled` | jamais rattachée à un type inactif ni réactivée sur un type inactif (`BASE_UNITE_TYPE_DISABLED`) |
| `fn::base_unite_delete` | `id` | refus si système (`BASE_UNITE_IS_SYSTEM`) ou référencée par une autre table (`BASE_UNITE_IN_USE`) ; ses codes d'échange sont supprimés avec elle |

Les références entrantes sont comptées de façon générique (`SELECT VALUE <~? FROM ONLY $id`) :
`lyxal_base` ne connaît pas les tables qui le référencent. Seuls les champs de premier niveau
déclarés `REFERENCE` sont suivis par SurrealDB 3.3.4 ; un consommateur ne range donc pas une
unité dans un objet imbriqué.

---

## 4. Erreurs (`error/`)

13 définitions `BASE_*`, créées seulement si elles n'existent pas.

| Thème | Codes |
| :--- | :--- |
| `parametres` | `BASE_INVALID_PARAMETERS`, `BASE_NO_UPDATABLE_FIELDS_PROVIDED` |
| `permissions` | `BASE_WRITE_FORBIDDEN` |
| `unite_type` | `BASE_UNITE_TYPE_NOT_FOUND`, `BASE_UNITE_TYPE_ALREADY_EXISTS`, `BASE_UNITE_TYPE_IS_SYSTEM`, `BASE_UNITE_TYPE_IN_USE` |
| `unite` | `BASE_UNITE_NOT_FOUND`, `BASE_UNITE_ALREADY_EXISTS`, `BASE_UNITE_IS_SYSTEM`, `BASE_UNITE_IN_USE`, `BASE_UNITE_TYPE_INVALID`, `BASE_UNITE_TYPE_DISABLED` |

---

## 5. Seeds (`seeds/`)

Socle système (`is_system: true`), rejouable (`IF !record::exists(...) THEN ( CREATE ... ) END`) :
11 types et 30 unités. Un élément système se désactive mais ne se supprime pas.

| Type | Unités |
| :--- | :--- |
| `LONGUEUR` | `KM`, `M`, `ML`, `CM`, `MM` |
| `SURFACE` | `HA`, `M2` |
| `VOLUME` | `M3`, `LTR` |
| `MASSE` | `T`, `KG`, `G` |
| `DUREE` | `MOIS`, `SEM`, `J`, `H` |
| `QUANTITE` | `U`, `PCE`, `ENS`, `PAIRE`, `FORFAIT` |
| `CONDITIONNEMENT` | `ROUL`, `SAC`, `PAL`, `BTE`, `CART` |
| `ENERGIE` | `KWH` |
| `PUISSANCE` | `W` |
| `PRESSION` | `BAR` |
| `DEBIT` | `M3H` |

Les codes sont ceux que produit la normalisation de `lyxal_pipeline_ingestion`, sans alias : un
banc de l'ingestion vérifie que chacun de ses alias d'unités pointe vers une unité utilisable.

Codes d'échange (31) : Rec. 20 pour les grandeurs (`KMT`, `MTR`, `LM`, `CMT`, `MMT`, `HAR`, `MTK`,
`MTQ`, `LTR`, `TNE`, `KGM`, `GRM`, `MON`, `WEE`, `DAY`, `HUR`, `C62` → `U`, `H87` et `EA` → `PCE`,
`SET`, `PR`, `LS` → `FORFAIT`, `KWH`, `WTT`, `BAR`, `MQH`) ; Rec. 21 pour les conditionnements
(`RO` → `ROUL`, `BG` → `SAC`, `PX` → `PAL`, `BX` → `BTE`, `CT` → `CART`).

---

## 6. Vérification

* Banc SurrealQL (`scripts/ci/test_lyxal_modules.py`, module installé depuis son manifeste dans
  une base neuve, identités simulées) : `parametres`, `permissions`, `referentiel`, `integrite`,
  `types`, `unites`, `codes` ; chaque fonction publique est appelée.
* `apps/lyxal-server` : installation et rejeu sans doublon (11 types).
* `scripts/ci/ci_local.sh` rejoue la CI complète.
