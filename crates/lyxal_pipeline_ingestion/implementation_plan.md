# Plan d'implémentation — normalisation sur les référentiels en base

Étape 1 de la [feuille de route de l'ingestion](ROADMAP.md) et son prérequis, l'étape 1 de la
[feuille de route de `lyxal_base`](../lyxal_base/ROADMAP.md) (codes d'échange des unités).
**En attente de validation du CTO (Q1 à Q3).** Changement multi-modules : `lyxal_base`,
`lyxal_pipeline_ingestion` (skill `lyxal-module-integration`) ; aucun autre consommateur.

## 1. Constat (lecture seule, `main` après #77)

| ID | Constat | Preuve |
| :- | :--- | :--- |
| N-01 | Le worker normalise unités et fabricants par deux tables statiques Rust (78 alias d'unités, 53 de fabricants), alors que les référentiels administrés par le Data Steward sont en base (`ingestion_unit_alias` : 11 alias seedés ; `ingestion_manufacturer_alias` : 17) avec `fn::ingestion_resolve_unit` et `fn::ingestion_resolve_manufacturer`, appelées une ligne à la fois. Deux sources de vérité qui divergent (§5.1). | `src/normalization/units.rs:33`, `manufacturer.rs:7`, `seeds/03_initial_aliases.surql` |
| N-02 | **Unité non résolue remplacée en silence par `PCE`** pour l'unité de référence et l'unité de vente. Un article approuvé par le steward serait publié avec une fausse unité (§11.4). | `src/worker/ingestion_worker.rs:278-281`, `:310` |
| N-03 | Les codes UN/CEFACT (`C62`, `MTK`, `KGM`…) sont des codes d'échange d'unités, propres au référentiel des unités, mais vivent dans la table Rust de l'ingestion. | `units.rs:46-104` |
| N-04 | La suppression des suffixes juridiques (`SAS`, `FRANCE`…) et le marqueur « `(INDETERMINE)` » n'existent qu'en Rust ; `fn::ingestion_resolve_manufacturer` ne les connaît pas (résultats différents selon le chemin). | `manufacturer.rs:93-135`, `normalization/mod.rs:284-286` |
| N-05 | Alias en mémoire (`register_unit_alias`, `register_manufacturer_alias`) sans appelant de production. | `normalization/mod.rs:96-106` |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Où ranger les codes d'échange des unités (`lyxal_base`) ? | **A.** Table `base_unite_code` (`norme`, `code`, `unite` en `record<base_unite>` `REFERENCE ON DELETE REJECT`), code unique par norme ; plusieurs codes par unité. **B.** Champ tableau `codes_un_cefact` sur `base_unite`. | **A** : une unité a plusieurs codes (pièce : `H87` ; « un » : `C62`) et d'autres normes viendront (EDI, ETIM) ; l'unicité par norme est garantie par un index. |
| Q2 | Normes et codes du socle (seeds, à valider) ? | **A.** UN/ECE Rec. 20 pour les grandeurs (`KMT`, `MTR`, `LM`, `CMT`, `MMT`, `HAR`, `MTK`, `MTQ`, `LTR`, `TNE`, `KGM`, `GRM`, `MON`, `WEE`, `DAY`, `HUR`, `C62` → `U`, `H87` et `EA` → `PCE`, `SET`, `PR`, `LS` → `FORFAIT`, `KWH`, `WTT`, `BAR`, `MQH`) et UN/ECE Rec. 21 (types d'emballage) pour les conditionnements (`RO` → `ROUL`, `BG` → `SAC`, `PX` → `PAL`, `BX` → `BTE`, `CT` → `CART`). **B.** Rec. 20 seulement ; conditionnements sans code d'échange. | **A** : les flux fabricants (FAB-DIS, BMEcat) emploient les deux recommandations ; chaque norme est nommée (`UNECE_REC20`, `UNECE_REC21`). |
| Q3 | Unité fournisseur non résolue (N-02) ? | **A.** Article mis en staging **sans unité** (`TO_CONFIRM`) et anomalie `INGESTION_UNIT_UNRESOLVED` en quarantaine liée à l'article ; le steward corrige par `fn::ingestion_quarantine_resolve` (`corrected_unit`, déjà prévu). **B.** Article sans unité en `TO_CONFIRM`, sans anomalie (motif de qualification seulement). | **A** : jamais de valeur inventée ; l'anomalie apparaît dans la file du steward, qui dispose déjà de la correction. Un article sans unité ne peut être ni `VERIFIED`, ni scellé dans un manifeste. |

## 3. Contrat cible (si Q1-A, Q2-A, Q3-A)

### `lyxal_base`

* Table `base_unite_code` : `norme` (`UNECE_REC20` | `UNECE_REC21`), `code` (alphanumérique,
  majuscules), `unite` (`record<base_unite>`, `REFERENCE ON DELETE REJECT`) ; index unique
  (`norme`, `code`) ; lecture pour tous, écriture d'administration. Seeds rejouables (Q2).
* **Nouvelle** `fn::base_unite_resolve($params: { codes: array<string>, language })` : pour un
  bloc de codes bruts (au plus 500), résolution par code Lyxal puis par code d'échange, en une
  requête ; résultat `{ <brut>: { code, usable } }` (absent si inconnu). Entrées par le moteur du
  Core ; `BASE_INVALID_PARAMETERS`.
* `fn::base_unite_get` renvoie aussi `codes` (`[{ norme, code }]`).
* Suppression d'une unité : ses codes d'échange la référencent (`<~?`) ; `fn::base_unite_delete`
  supprime d'abord les codes d'une unité non système non référencée par ailleurs.
* Aucune extension du Core ; règles réutilisées : `array`, `required_string`, `alphanumeric`,
  `language_code`, `uppercase`, `trim`.

### `lyxal_pipeline_ingestion` (SurrealQL)

* `fn::ingestion_resolve_unit` et `fn::ingestion_resolve_manufacturer` deviennent
  **`fn::ingestion_resolve_units`** (`raw_units: array`) et
  **`fn::ingestion_resolve_manufacturers`** (`raw_names: array`), par bloc (rupture coordonnée :
  `fn::ingestion_quarantine_resolve`, `IngestionStore`, tests mis à jour) :
  * unités : alias `ingestion_unit_alias` (libellés commerciaux, `M²`, `ROULEAU`…), puis
    `fn::base_unite_resolve` (codes Lyxal et d'échange) ; seule une unité utilisable est retenue ;
  * fabricants : nettoyage (casse, ponctuation, espaces), alias, suffixes juridiques retirés,
    seconde recherche ; `resolved`, `is_verified` et groupe lus dans l'alias (le marqueur
    « `(INDETERMINE)` » devient `is_verified = false`).
* Seeds `03_initial_aliases.surql` complétés depuis les tables Rust : tous les alias commerciaux
  d'unités (les codes UN/CEFACT passent dans `lyxal_base`) et les 53 alias de fabricants.
* Anomalie `INGESTION_UNIT_UNRESOLVED` (code existant) consignée par le worker (Q3).

### `lyxal_pipeline_ingestion` (Rust)

* Par bloc : les unités et fabricants distincts du bloc sont résolus en deux appels
  (`call_fn`), puis passés à la normalisation ; plus d'aller-retour par ligne.
* `normalization/units.rs` et `normalization/manufacturer.rs` supprimés (tables statiques,
  `CANONICAL_UNITS` et son test) ; alias en mémoire supprimés (N-05).
* Valeur par défaut `PCE` supprimée : `unite_reference` et `unite_vente` facultatives tant que
  l'unité n'est pas résolue (schéma `ingestion_staged_item` ajusté) ; qualification inchangée
  (unité non résolue : pas de `VERIFIED`) ; `fn::ingestion_manifest_save` refuse un article sans
  unité (`INGESTION_UNIT_UNRESOLVED`).
* Test d'intégration « chaque code canonique existe dans `base_unite` » remplacé par : chaque
  alias seedé pointe vers une unité utilisable.

### Erreurs

* Aucun nouveau code : `BASE_INVALID_PARAMETERS`, `INGESTION_UNIT_UNRESOLVED`,
  `INGESTION_INVALID_PARAMETERS` existent.

## 4. Tests

* `lyxal_base` : résolution par code Lyxal, par code Rec. 20 et Rec. 21, codes inconnus, bloc
  vide ou trop grand, unité inutilisable signalée (`usable: false`), unicité (norme, code),
  suppression d'une unité portant des codes.
* Ingestion (banc) : résolution par bloc (alias commerciaux, codes d'échange, inconnus),
  fabricants (suffixes, groupe, non vérifié), quarantaine d'une unité non résolue et correction
  par le steward ; chaque alias seedé résolu.
* Ingestion (Rust) : lot contenant une unité inconnue → article sans unité, anomalie liée,
  jamais `PCE` ; débit du banc maintenu (seuil 50 articles/s, mesuré aujourd'hui à 180).

## 5. Lots

| Lot | Contenu |
| :- | :--- |
| 1 | **`lyxal_base`** (Q1, Q2) : `base_unite_code`, seeds, `fn::base_unite_resolve`, `codes` dans `fn::base_unite_get`, suppression ; banc. |
| 2 | **Ingestion SurrealQL** : résolutions par bloc, seeds d'alias complétés, appelants SurrealQL ; banc. |
| 3 | **Ingestion Rust** (Q3) : worker par bloc, tables statiques et `PCE` supprimés, quarantaine d'une unité non résolue, schéma du staging ; tests et débit. |
| 4 | **Clôture** : README des deux modules ; étapes 1 retirées des deux `ROADMAP.md` ; suppression de ce plan. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.
