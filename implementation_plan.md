# Plan d'implémentation — audit externe, lot 6 (A05)

Sixième lot de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md).
Les adaptateurs de `lyxal_pipeline_ingestion` passent sur `lyxal_parsing` (crate créé au lot
précédent). Plan placé à la racine comme les lots précédents, supprimé une fois exécuté. La
source persistée, la lecture en flux de bout en bout et la reprise automatique restent au lot
suivant (A06).

**Validé par le CTO : Q1-A, Q2-A, Q3-A.**

## 1. Constat

| ID | Constat (reproduit par l'audit) | Preuve |
| :- | :--- | :--- |
| A05-a | CSV lu ligne par ligne : un champ entre guillemets sur plusieurs lignes devient plusieurs articles | `src/adapters/csv.rs` (`content.lines()`, `parse_csv_line`) |
| A05-b | JSON : un élément qui n'est pas un objet est ignoré sans trace (`if let Some(record)`) | `src/adapters/json.rs` |
| A05-c | XML repéré par recherche de texte (`find("<TAG")`) : entités (`&amp;`, `&#233;`) non décodées, balises imbriquées ou en commentaire mal lues | `src/adapters/xml.rs` |
| A05-d | Le FAB-DIS tabulaire 3.0 réutilise l'adaptateur CSV (même défaut) ; le FAB-DIS 2.3 découpe ses lignes par `split(';')`, sans guillemets | `src/adapters/fab_dis.rs` |
| A05-e | Une ligne illisible n'est jamais signalée : aucune anomalie, aucun compteur | adaptateurs, `src/worker/ingestion_worker.rs` |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Déclaration de l'encodage | **A.** Champ `source_encoding` du lot (`UTF-8` par défaut, `WINDOWS-1252`, `ISO-8859-1`), donné à `fn::ingestion_batch_create` avec le format, transmis à `lyxal_parsing`. **B.** UTF-8 seul pour l'instant. | **A** : les exports Excel français (Windows-1252) passent sans conversion préalable, et l'encodage reste une déclaration explicite et tracée, jamais devinée. |
| Q2 | Trace d'un enregistrement rejeté à la lecture | **A.** Il garde son numéro dans la suite des lignes ; il reçoit une ligne brute (`payload_brut` : code `PARSING_*`, diagnostic, ligne physique ; **pas** de contenu, que `lyxal_parsing` ne rend pas) et une anomalie de quarantaine `INGESTION_SOURCE_RECORD_REJECTED` (sévérité `ERROR`) ; il compte dans `lignes_rejetees`. **B.** Simple liste des rejets dans `provenance_details` du lot, sans quarantaine. | **A** : le steward voit chaque rejet au même endroit que les autres anomalies, la numérotation reste stable à la reprise (le point de reprise compte aussi les rejets), et le schéma ne change pas (une anomalie référence toujours une ligne brute). |
| Q3 | Erreur d'arrêt (XML mal formé, tableau JSON cassé, en-tête CSV invalide) | **A.** Le lot passe en `FAILED` (`INGESTION_SOURCE_INVALID`, détail : code `PARSING_*` et ligne) **avant** toute mise en staging : la source est lue en entier avant le premier bloc, comme aujourd'hui. **B.** Les blocs lus avant l'erreur sont mis en staging, puis le lot échoue. | **A** : un fichier cassé n'est jamais publié en partie ; la lecture en flux de bout en bout vient avec la source persistée (A06). |

## 3. Contrat cible (si Q1-A, Q2-A, Q3-A)

### `lyxal_parsing` (extension)

* `CsvOptions::header: CsvHeader::{FirstLine, None}` (défaut `FirstLine`, comportement actuel) :
  sans en-tête, les colonnes sont nommées par leur rang (`"1"`, `"2"`…) et le nombre de champs
  peut varier d'une ligne à l'autre (FAB-DIS 2.3 : blocs `C`, `L`, `R` de longueurs
  différentes). Aucun autre changement de contrat.

### Adaptateurs (`src/adapters/`)

* Le trait `SourceAdapter` devient :
  `fn read(&self, source: &[u8], encoding: SourceEncoding) -> Result<Vec<SourceItem>, IngestionError>`
  avec `enum SourceItem { Record(RawRecordDto), Rejected(SourceRejection) }` et
  `SourceRejection { record, source_line, code, detail }` (repris de `lyxal_parsing::Rejection`).
  Erreur d'arrêt → `IngestionError::SourceInvalid { code, line, detail }` (code
  `INGESTION_SOURCE_INVALID`, existant).
* `parse_content`, `validate_header` et `supported_versions` sont **supprimés** (zéro dette :
  les deux derniers ne sont appelés nulle part).
* **CSV** : `CsvReader` (séparateur détecté) ; la correspondance des colonnes (`find_field`,
  noms normalisés, `trim` des valeurs lues) est conservée telle quelle. `raw_payload` :
  `{ source: "CSV", line, fields }` (colonnes et valeurs) ; `raw_hash` : BLAKE3 de ces champs.
* **JSON** : `JsonReader` ; correspondance des clés conservée ; un élément non objet devient un
  `SourceItem::Rejected` (`PARSING_JSON_NOT_OBJECT`).
* **XML** : `XmlReader` avec les éléments d'enregistrement `ARTICLE`, `PRODUCT`, `ITEM` (et leurs
  formes en minuscules, comme aujourd'hui) ; une balise attendue (`SUPPLIER_AID`,
  `DESCRIPTION_SHORT`…) est cherchée par le dernier segment du chemin, au premier niveau où elle
  apparaît. `raw_payload` : `{ format, line, fields }` au lieu du bloc XML brut.
* **FAB-DIS** : 3.0 tabulaire par l'adaptateur CSV ; 2.3 multi-blocs par `CsvReader` sans
  en-tête (guillemets respectés), regroupement `C` / `L` / `R` par référence conservé ; une ligne
  `L` ou `R` sans ligne `C` de même référence devient un rejet
  (`INGESTION_FABDIS_ORPHAN_BLOCK`, code de l'adaptateur) au lieu d'être ignorée.
* Numérotation : `line_number` = numéro de l'enregistrement dans la suite (rejets compris),
  identité de la ligne brute `<lot>_<numéro>` inchangée ; la ligne physique est gardée dans
  `raw_payload.line` (et `source_line` du rejet).

### Lot et worker

* `ingestion_batch.source_encoding` (`string`, `ASSERT IN ["UTF-8", "WINDOWS-1252",
  "ISO-8859-1"]`, défaut `UTF-8`) ; `fn::ingestion_batch_create` l'accepte (moteur `lyxal_core`,
  règle `enum`) ; `NewBatch`, `IngestionBatch` et `SourceEncoding` côté Rust mis à jour
  (**rupture** du contrat de création, appelants du dépôt mis à jour).
* `IngestionWorker` : `adapter.read(raw_bytes, encoding)` ; les éléments forment la suite
  reprise depuis `cursor_offset` ; dans un bloc, un `Rejected` donne sa ligne brute de rejet et
  son anomalie (sous réservation, comme les autres écritures) et compte dans `lignes_rejetees`.
* Nouveau code master data (fr/en) : `INGESTION_SOURCE_RECORD_REJECTED` (422, non réessayable) ;
  `INGESTION_FABDIS_ORPHAN_BLOCK` (422). `INGESTION_ADAPTER_ERROR` est conservé s'il reste
  utilisé, supprimé sinon.

## 4. Tests

| Cas | Preuve attendue |
| :- | :--- |
| A05-a | Worker : un CSV dont une désignation tient sur trois lignes donne **un** article, libellé intact |
| A05-b | Worker : `[{…}, 42, {…}]` → deux articles, une anomalie `INGESTION_SOURCE_RECORD_REJECTED` (détail `PARSING_JSON_NOT_OBJECT`, numéro 2), `lignes_rejetees` = 1 |
| A05-c | Worker : BMEcat avec `&amp;`, `&#233;`, CDATA → libellé décodé en staging |
| A05-d | FAB-DIS 2.3 avec un champ entre guillemets contenant `;` → valeur intacte ; bloc `L` orphelin → rejet |
| Encodage | Lot `WINDOWS-1252` : `é`, `€` corrects en staging ; lot UTF-8 avec texte invalide → rejet de la ligne |
| Arrêt | XML mal formé → lot `FAILED` (`INGESTION_SOURCE_INVALID`, ligne en détail), aucun article en staging |
| Reprise | Interruption après un bloc contenant un rejet → reprise sans doublon, numéros identiques |
| Banc | `fn::ingestion_batch_create` : `source_encoding` accepté, valeur inconnue refusée |
| Adaptateurs | tests unitaires réécrits sur `read` (correspondance des colonnes et balises conservée) |

Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* Architecture : lecture des formats dans `lyxal_parsing`, correspondance métier dans
  l'ingestion ; aucune dépendance nouvelle hors `lyxal_parsing`.
* SurrealQL : `$params: object`, entrées par le moteur `lyxal_core`, codes `INGESTION_*`.
* Rust : aucune erreur silencieuse (tout élément rendu ou rejeté, et consigné) ; aucun `panic!`.
* Zéro dette : `parse_content`, `validate_header`, `supported_versions` et la lecture manuelle
  des formats supprimés ; rupture coordonnée ; plan supprimé après exécution.

## 6. Lots suivants (rappel)

7 : A06 (source persistée, file reconstruite au redémarrage, lecture en flux de bout en bout,
dépend de `lyxal_storage`).
