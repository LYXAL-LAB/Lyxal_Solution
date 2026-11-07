# `lyxal_parsing` — lecture des formats sources

Crate du Noyau Technique Lyxal OS (`.agents/AGENTS.md` §6). Il lit des sources **CSV**, **JSON**
et **XML** en flux et rend, pour chaque enregistrement, **soit ses valeurs telles que lues, soit
un rejet explicite** (position, cause). Rust pur, sans base de données, sans SurrealQL ni
`LyxalModule`, sans dépendance Lyxal : il se place au même niveau que `lyxal_crypto`.

## Frontière

| Dans `lyxal_parsing` | Dans le module consommateur (ex. `lyxal_pipeline_ingestion`) |
| :--- | :--- |
| décodage du texte (encodage déclaré), découpage en enregistrements, en-tête CSV, entités XML, type des éléments JSON, limites, positions, rejets | choix des colonnes et balises (FAB-DIS, BMEcat), noms normalisés, conversions (prix, unités), nettoyage des valeurs (`lyxal_core`), qualification, message montré à l'utilisateur |

Les valeurs sont rendues **sans `trim` ni conversion**.

## Bibliothèques

| Format | Bibliothèque | Rôle |
| :--- | :--- | :--- |
| CSV | `csv` 1.4 (BurntSushi) | champs entre guillemets sur plusieurs lignes, guillemets doublés, ligne de début de chaque enregistrement |
| XML | `quick-xml` 0.42 (tafia) | lecture en flux ; entités prédéfinies et numériques, CDATA ; aucune DTD ni entité externe résolue |
| JSON | `serde_json` | chaque élément de tableau ou ligne NDJSON décodé séparément |
| Encodage | `encoding_rs` 0.8 | Windows-1252 |

Dépendances Cargo à version fixée par `Cargo.lock` (choix du CTO : pas de copie du code).

## Contrat

Chaque lecteur est un itérateur dont chaque élément est :

* un enregistrement (`CsvRecord`, `JsonRecord`, `XmlRecord`) avec sa `Position`
  (`record` à partir de 1, rejets comptés, en-tête CSV exclu ; `line` de début) ;
* `ReadFailure::Rejected(Rejection)` : enregistrement écarté, **la lecture continue** ;
* `ReadFailure::Fatal(ParseError)` : la suite n'est plus fiable, **c'est le dernier élément**.

Aucun enregistrement n'est ignoré sans être rendu ou rejeté. Les diagnostics ne reprennent pas
le contenu des enregistrements.

| Lecteur | Ouverture | Options |
| :--- | :--- | :--- |
| `CsvReader` | `CsvReader::new(source, options) -> Result<_, ParseError>` (en-tête lu tout de suite) | `delimiter` (`Auto` : le plus fréquent de `;` `,` tabulation `\|` hors guillemets sur l'en-tête, `;` par défaut ; ou `Byte`), `encoding`, `limits` |
| `JsonReader` | `JsonReader::new(source, options)` | `layout` (`Auto` : tableau si le premier caractère est `[`, NDJSON sinon ; `Array` ; `Lines`), `encoding`, `limits` |
| `XmlReader` | `XmlReader::new(source, options)` | `record_elements` (noms des éléments qui forment un enregistrement), `encoding`, `limits` |

* **CSV** : en-tête obligatoire (colonne vide ou en double : arrêt) ; lignes vides ignorées ;
  `CsvRecord::get(colonne)`.
* **JSON** : `JsonRecord::value` est l'objet lu ; dans un tableau, un élément mal formé est
  rejeté et le suivant lu (le découpage suit la structure, chaînes comprises) ; un tableau non
  terminé ou suivi d'autre chose arrête la lecture.
* **XML** : champs repérés par chemin relatif (`A/B`, `A/@x`, `@x` pour un attribut de
  l'élément d'enregistrement, `.` pour son propre texte) ; un élément sans enfant donne sa valeur,
  vide comprise ; les éléments répétés sont gardés dans l'ordre (`XmlRecord::get_all`) ; un
  élément d'enregistrement imbriqué dans un autre est un champ de celui-ci ; XML mal formé :
  arrêt avec la ligne.

### Encodage (`SourceEncoding`)

Toujours déclaré par l'appelant, jamais deviné : `Utf8` (défaut, BOM retiré), `Windows1252`,
`Iso8859_1` (Latin-1 strict). En UTF-8, un texte non décodable est rejeté (CSV, JSON) ou arrête
la lecture (XML). La déclaration `<?xml encoding?>` n'est pas suivie.

### Limites (`Limits`)

| Champ | Défaut | Effet |
| :--- | :--- | :--- |
| `max_record_bytes` | 1 Mio | enregistrement isolable (JSON, ligne CSV complète) plus grand : rejet ; sinon (champ CSV ou élément XML sans fin) : arrêt `PARSING_LIMIT` avant de charger la suite. La mémoire par enregistrement reste bornée par cette taille et un tampon de 64 Kio. |
| `max_fields` | 10 000 | rejet (en-tête CSV : arrêt) |
| `max_depth` | 64 | imbrication JSON ou XML plus profonde : rejet |

## Codes

| Rejet (`RejectionKind::code`) | Cause |
| :--- | :--- |
| `PARSING_CSV_FIELD_COUNT` | nombre de champs différent de l'en-tête |
| `PARSING_JSON_NOT_OBJECT` | élément qui n'est pas un objet |
| `PARSING_JSON_SYNTAX` | élément ou ligne NDJSON mal formé, élément vide |
| `PARSING_XML_ENTITY` | entité inconnue (seules `&amp;` `&lt;` `&gt;` `&apos;` `&quot;` et les références numériques sont décodées), attribut invalide |
| `PARSING_TOO_DEEP` | imbrication au-delà de `max_depth` |
| `PARSING_RECORD_TOO_LARGE` | enregistrement au-delà de `max_record_bytes` |
| `PARSING_TOO_MANY_FIELDS` | champs au-delà de `max_fields` |
| `PARSING_INVALID_TEXT` | texte non décodable dans l'encodage déclaré |

| Arrêt (`ParseError::code`) | Cause |
| :--- | :--- |
| `PARSING_IO` | lecture de la source impossible |
| `PARSING_ENCODING` | texte non décodable là où l'enregistrement ne peut pas être isolé |
| `PARSING_SYNTAX` | XML mal formé, tableau JSON cassé |
| `PARSING_HEADER_INVALID` | en-tête CSV absent, colonne vide ou en double |
| `PARSING_LIMIT` | limite dépassée là où l'enregistrement ne peut pas être sauté |

Ces codes ne sont pas des master data (aucune base) : le module consommateur consigne le rejet
avec son propre code `<MODULE>_*` et reprend le code `PARSING_*` en détail.

## Tests

`cargo test -p lyxal_parsing` : un fichier par format (`tests/csv.rs`, `tests/json.rs`,
`tests/xml.rs`), dont les trois cas du constat A05 de l'audit externe (champ CSV multiligne,
éléments JSON non objets, entités XML), les rejets, les encodages, les limites et la lecture en
flux d'une grande source.
