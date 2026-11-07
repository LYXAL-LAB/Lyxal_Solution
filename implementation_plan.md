# Plan d'implémentation — création de `lyxal_parsing`

Préalable au lot 6 de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md)
(A05 : adaptateurs d'ingestion permissifs). Ce lot **crée le crate seul** : les adaptateurs de
`lyxal_pipeline_ingestion` le consommeront au lot suivant (A05). Plan placé à la racine comme les
lots précédents, supprimé une fois exécuté.

**En attente de validation du CTO (Q1 à Q3).**

## 1. Constat et objectif

A05 (reproduit par l'audit) : les adaptateurs actuels lisent les formats à la main.

| Format | Défaut | Preuve |
| :- | :--- | :--- |
| CSV | un champ entre guillemets sur plusieurs lignes est découpé en plusieurs articles (lecture ligne par ligne) | `src/adapters/csv.rs` (`content.lines()`, `parse_csv_line`) |
| JSON | un élément qui n'est pas un objet est ignoré sans trace | `src/adapters/json.rs` (`if let Some(record) = …`) |
| XML | entités (`&amp;`, `&#233;`…) non décodées, blocs repérés par recherche de texte | `src/adapters/xml.rs` (`find("<TAG")`) |

Objectif : un crate du Noyau Technique qui lit CSV, JSON et XML avec des parseurs éprouvés et
rend, pour chaque enregistrement, **soit des valeurs brutes, soit un rejet explicite** (position,
cause). Il ne contient aucune logique métier, comme `lyxal_crypto`.

## 2. Périmètre et frontière

* **Identifiant** : `lyxal_parsing`, chemin `crates/lyxal_parsing`, membre du workspace.
* **Nature** : Rust pur, sans base de données, sans SurrealQL, sans `LyxalModule` (comme
  `lyxal_crypto`). Aucune dépendance Lyxal : il se place au niveau de `lyxal_crypto` dans la
  hiérarchie (`AGENTS.md` §6), sans cycle possible.
* **Dans `lyxal_parsing`** : décodage du texte, découpage en enregistrements, en-têtes CSV,
  décodage des entités XML, contrôle du type des éléments JSON, limites de taille, positions
  et rejets.
* **Hors de `lyxal_parsing`** (reste dans `lyxal_pipeline_ingestion`) : choix des colonnes et
  balises (FAB-DIS, BMEcat), noms de colonnes normalisés, conversions (prix, unités), nettoyage
  des valeurs (`trim`, casse : `lyxal_core`), qualification. Les valeurs sont rendues **telles
  que lues**, sans `trim`.
* **Réutilisation** : aucune primitive `lyxal_core` ne s'applique (le Core est du SurrealQL qui
  travaille sur des valeurs déjà lues) ; aucune primitive `lyxal_crypto` n'est nécessaire (le
  hachage des lignes reste à l'ingestion). Aucun besoin Core ou crypto à signaler.

## 3. Bibliothèques

| Format | Bibliothèque | Raison |
| :- | :--- | :--- |
| CSV | `csv` 1.4 (BurntSushi, déjà dans `Cargo.lock`) | référence Rust ; champs multilignes entre guillemets, guillemets doublés, position de chaque enregistrement (ligne de début) |
| XML | `quick-xml` (dernière version stable 0.x) | lecture en flux ; entités prédéfinies et numériques décodées, CDATA ; **aucune résolution d'entité externe ni de DTD** (pas d'attaque XXE) |
| JSON | `serde_json` (workspace) | déjà utilisé ; lecture élément par élément d'un tableau et ligne par ligne en NDJSON |
| Encodage | `encoding_rs` 0.8 (déjà dans `Cargo.lock`) | seulement si Q2-B |

`xan` reste un outil en ligne de commande d'appoint, pour inspecter un catalogue à la main.

## 4. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Codes de rejet et master data | **A.** Codes Rust stables `PARSING_*` portés par le crate (énumération et `code()`), **sans** manifeste ni master data, comme `lyxal_crypto`. Le module consommateur consigne le rejet avec **son** code (ex. `INGESTION_SOURCE_ROW_REJECTED`) et la cause `PARSING_*` en détail. **B.** Un `manifest.toml` et des définitions `PARSING_*` en master data, installés par le runtime alors que le crate n'a rien d'autre en base. | **A** : pas de base pour un crate qui n'en utilise pas ; le message montré à l'utilisateur reste celui du module qui sait ce qu'est une ligne de catalogue. |
| Q2 | Encodage des fichiers | **A.** UTF-8 seul (BOM accepté) ; tout autre encodage est une erreur explicite. **B.** UTF-8, plus Windows-1252 et ISO-8859-1 **déclarés par l'appelant** (`encoding_rs`), jamais devinés. | **B** : les exports CSV d'Excel en France et beaucoup de fichiers FAB-DIS sont en Windows-1252 ; les refuser bloque des fournisseurs, et deviner l'encodage serait une source d'erreurs silencieuses. |
| Q3 | Lecture | **A.** En flux : l'entrée est un `std::io::Read`, la sortie un itérateur d'enregistrements, mémoire bornée par enregistrement. **B.** Texte complet en mémoire (`&str`), comme aujourd'hui. | **A** : corrige la lecture intégrale relevée par A06 et permet à l'ingestion de traiter par blocs sans charger tout le fichier. |

## 5. Contrat cible (si Q1-A, Q2-B, Q3-A)

### Types communs

```rust
/// Position d'un enregistrement dans la source.
pub struct Position {
    /// Numéro de l'enregistrement (1 pour le premier, en-tête CSV exclu).
    pub record: u64,
    /// Ligne de début dans le fichier, quand le format la fournit.
    pub line: Option<u64>,
}

/// Rejet d'un enregistrement : la lecture continue avec le suivant.
pub struct Rejection {
    pub position: Position,
    pub kind: RejectionKind,
    /// Diagnostic lisible, sans le contenu de l'enregistrement.
    pub detail: String,
}

/// Erreur qui arrête la lecture (le reste de la source n'est plus fiable).
pub enum ParseError { Io { .. }, Encoding { .. }, Syntax { position, detail }, Header { detail }, Limit { .. } }

/// Encodage déclaré de la source (Q2-B).
pub enum SourceEncoding { Utf8, Windows1252, Iso8859_1 }

/// Limites appliquées à chaque enregistrement (valeurs par défaut sûres, réglables).
pub struct Limits { pub max_record_bytes: usize, pub max_fields: usize, pub max_depth: usize }
```

Chaque format expose un lecteur `XxxReader::new(source: impl Read, options: XxxOptions)` qui
implémente `Iterator<Item = Result<Record, ReadFailure>>`, où `ReadFailure` est soit un
`Rejection` (enregistrement écarté, la lecture continue), soit un `ParseError` (dernier élément
rendu, la lecture s'arrête). Aucun enregistrement n'est jamais ignoré sans être rendu ou rejeté.

### CSV

* `CsvOptions { delimiter: Delimiter::{Auto, Byte(u8)}, encoding, limits }` ; détection du
  séparateur (`;`, `,`, tabulation, `|`) sur la ligne d'en-tête, hors guillemets.
* En-tête obligatoire : nom vide ou en double → `ParseError::Header`.
* `CsvRecord { position, fields: Vec<(String, String)> }` (ordre des colonnes conservé).
* Rejets : nombre de champs différent de l'en-tête (`PARSING_CSV_FIELD_COUNT`), enregistrement
  trop grand (`PARSING_RECORD_TOO_LARGE`), texte non décodable (`PARSING_INVALID_TEXT`).

### JSON

* `JsonOptions { layout: JsonLayout::{Auto, Array, Lines}, encoding, limits }` ; tableau
  d'objets lu élément par élément, ou NDJSON ligne par ligne (lignes vides ignorées).
* `JsonRecord { position, value: serde_json::Map<String, Value> }`.
* Rejets : élément qui n'est pas un objet (`PARSING_JSON_NOT_OBJECT`), ligne NDJSON mal formée
  (`PARSING_JSON_SYNTAX`, la ligne suivante est lue), enregistrement trop grand ou trop profond.
* Syntaxe d'un tableau cassée : `ParseError::Syntax` (impossible de retrouver l'élément suivant).

### XML

* `XmlOptions { record_elements: Vec<String>, encoding, limits }` : l'appelant nomme les éléments
  qui forment un enregistrement (ex. `ARTICLE`, `PRODUCT` pour BMEcat) ; le choix reste métier.
* `XmlRecord { position, element: String, fields: Vec<(String, String)> }` : chemins relatifs à
  l'enregistrement (`ARTICLE_DETAILS/DESCRIPTION_SHORT`), attributs en `@nom`, texte et CDATA
  décodés, éléments répétés conservés dans l'ordre.
* Rejets : enregistrement trop grand ou trop profond (`PARSING_RECORD_TOO_LARGE`,
  `PARSING_XML_TOO_DEEP`) ; entité inconnue (`PARSING_XML_ENTITY`).
* XML mal formé (balise non fermée, croisée) : `ParseError::Syntax` avec la ligne.
* DTD et entités externes jamais résolues.

### Codes (Q1-A)

`PARSING_CSV_FIELD_COUNT`, `PARSING_JSON_NOT_OBJECT`, `PARSING_JSON_SYNTAX`,
`PARSING_XML_ENTITY`, `PARSING_XML_TOO_DEEP`, `PARSING_RECORD_TOO_LARGE`, `PARSING_INVALID_TEXT`,
et pour les erreurs d'arrêt `PARSING_IO`, `PARSING_ENCODING`, `PARSING_SYNTAX`,
`PARSING_HEADER_INVALID`, `PARSING_LIMIT`. Rendus par `RejectionKind::code()` et
`ParseError::code()`.

## 6. Fichiers

```text
crates/lyxal_parsing/
├── Cargo.toml        csv, quick-xml, serde_json, thiserror (+ encoding_rs si Q2-B)
├── README.md         contrat, frontière, limites, codes
├── ROADMAP.md        évolutions à venir (ex. autres encodages déclarés, XLSX si besoin produit)
├── src/
│   ├── lib.rs        réexports
│   ├── common.rs     Position, Rejection, ParseError, Limits, SourceEncoding, décodage
│   ├── csv.rs
│   ├── json.rs
│   └── xml.rs
└── tests/            un fichier par format + limites
```

Mises à jour : `Cargo.toml` racine (membre et dépendance de workspace), `AGENTS.md` §6
(`lyxal_parsing` n'est plus « à créer »), `docs/14-roadmap/ROADMAP_NOYAU.md` (crate créé).
Pas de `manifest.toml` ni de `lyxal-server` à toucher (Q1-A : rien à installer).

## 7. Tests

| Cas | Preuve attendue |
| :- | :--- |
| A05 CSV | un champ entre guillemets sur trois lignes donne **un** enregistrement, valeur intacte, ligne de début correcte |
| A05 JSON | `[{"a":1}, 42, "x", {"b":2}]` : deux enregistrements et deux rejets `PARSING_JSON_NOT_OBJECT` aux positions 2 et 3 |
| A05 XML | `&amp;`, `&lt;`, `&#233;`, CDATA décodés ; attributs et éléments imbriqués rendus par chemin |
| Rejets CSV | ligne au nombre de champs faux rejetée, les suivantes lues ; en-tête vide ou en double refusé |
| NDJSON | ligne mal formée rejetée avec sa ligne, lecture poursuivie |
| XML mal formé | arrêt `PARSING_SYNTAX` avec la ligne ; aucune entité externe résolue (document avec DTD externe) |
| Encodage (Q2-B) | fichier Windows-1252 déclaré lu correctement (`é`, `€`) ; UTF-8 invalide → rejet ou arrêt explicite |
| Limites | enregistrement trop grand ou trop profond rejeté sans charger la suite en mémoire |
| Flux | lecture d'une source plus grande que les limites par enregistrement, sans la charger entièrement |

Contrôle complet : `scripts/ci/ci_local.sh` (le crate entre automatiquement dans clippy et les tests).

## 8. Checklist (§13)

* Architecture : responsabilité technique transversale, sans métier ; aucune dépendance Lyxal,
  pas de cycle ; frontière Rust (format, système) respectée.
* Rust : aucun `panic!`, `unwrap` ni `expect` hors tests ; aucune erreur silencieuse (tout
  enregistrement est rendu ou rejeté) ; types publics nommés, documentés en `///`.
* Crypto : aucune.
* Zéro dette : version `0.1.0` ; pas de `CHANGELOG.md` ; plan supprimé après exécution.

## 9. Lots suivants (rappel)

6 : A05, adaptateurs de `lyxal_pipeline_ingestion` sur `lyxal_parsing` (rejets consignés en
quarantaine) · 7 : A06 (source persistée et reprise automatique, dépend de `lyxal_storage`).
