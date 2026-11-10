# Plan détaillé — lot 4 `lyxal_i18n` : import, export et contrôle des textes

Lot 4 du programme `lyxal_i18n` (`implementation_plan.md` à la racine, décisions Q1 à Q7).
État des lots 1 à 3 : [`README.md`](README.md). Aucune ligne de code avant la validation de ce
plan (`.agents/AGENTS.md` §3). Plan supprimé une fois exécuté.

## 1. Objectif

* Exporter les textes d'une langue dans un fichier, pour les faire traduire ou relire.
* Importer un fichier traduit, sans écraser un texte relu ni un texte d'une autre portée.
* Lister les textes que le rendu refuserait (décisions Q4 et R3).
* Trois commandes de l'hôte ; aucune route HTTP dans ce lot (I4).

## 2. Formats de fichier

| Format | Usage | Forme |
| :--- | :--- | :--- |
| **JSON** (défaut) | échange avec Tolgee, FormatJS, Crowdin | objet à plat `{ "base.unite.metre": "mètre", … }`, textes en ICU MessageFormat 1 |
| **XLIFF 2.0** | échange avec des traducteurs professionnels | un `<file>` par espace de noms, un `<unit id="clé">` par clé, `<source>`, `<target>`, état dans `<segment state>`, contexte dans `<notes>` |

* Un fichier porte **une langue** et **une portée** (installation ou une organisation), données
  par la commande, jamais lues dans le fichier.
* XLIFF : texte seul dans `<source>` et `<target>` ; les éléments en ligne (`<ph>`, `<pc>`…) sont
  refusés à l'import (I3).
* Lecture par `lyxal_parsing` (`JsonReader`, `XmlReader`), écriture par `lyxal_i18n`
  (échappement JSON par `serde_json`, échappement XML des cinq caractères réservés).

## 3. Fonctions `lyxal_core` réutilisées

Moteur `fn::validation_object_execute` ; règles `locale`, `record`, `snake_case_name`,
`lyxal_event_name`, `max_length`, `required_string`, `enum`, `boolean`, `integer`,
`array_objects`, `array_length`, `each`, `object`. Aucune extension de `lyxal_core`.

## 4. Fonctions SurrealQL publiques

| Fonction | Paramètres | Résultat | Droits |
| :--- | :--- | :--- | :--- |
| `i18n_export` | **locale**, `namespace`, `tenant`, `limit` (1 à 1000, 500), `start` | `{ items: [{ key, namespace, description, params, max_length, source_locale, source_text, text, syntax, state, outdated, overridden }], total }` | lecture de la portée |
| `i18n_import` | **locale**, **entries** `[{ key, text, syntax }]` (500 au plus), `tenant`, `overwrite_reviewed` (défaut faux), `dry_run` (défaut faux) | `{ created, updated, unchanged, skipped: [{ key, reason }], invalid: [{ key, problems }] }` | écriture de la portée |
| `i18n_translation_scan` | `limit` (1 à 1000, 500), `start` | `{ items: [{ key, locale, tenant, text, syntax }], total }` : tous les textes, toutes portées | `i18n.translation.manage` |

Règles de `fn::i18n_import`, entrée par entrée :

| Cas | Effet |
| :--- | :--- |
| clé non déclarée | `skipped`, raison `key_not_found` : l'import ne crée pas de clé (I2) |
| texte identique au texte en base | `unchanged` ; l'état et l'obsolescence ne changent pas |
| texte en base à l'état `reviewed`, sans `overwrite_reviewed` | `skipped`, raison `reviewed` |
| texte refusé par `fn::i18n_message_check` | `invalid`, avec ses problèmes ; rien n'est écrit pour cette entrée |
| sinon | écrit par `fn::i18n_translation_set` : `created` ou `updated` |

* Les entrées sont indépendantes : une entrée refusée n'empêche pas les autres.
* `dry_run` rend le même rapport sans rien écrire.
* La portée est unique (`tenant` ou installation) : un import ne peut pas toucher une autre
  organisation. Les gardes d'identifiant du lot 2 s'appliquent.
* Une clé en double dans `entries` est refusée (`I18N_INVALID_PARAMETERS`).

Aucun code d'erreur nouveau en SurrealQL : `I18N_INVALID_PARAMETERS`, `I18N_PERMISSION_DENIED`,
`I18N_LOCALE_NOT_FOUND`, `I18N_NAMESPACE_NOT_FOUND`.

## 5. Rust (`crates/lyxal_i18n/src/exchange/`)

```rust
pub enum FileFormat { Json, Xliff }

pub struct ExportOptions { locale, namespace: Option<String>, tenant: Option<String> }
pub struct ImportOptions { locale, tenant: Option<String>, overwrite_reviewed: bool, dry_run: bool }

pub struct ImportReport {
    created: u64, updated: u64, unchanged: u64,
    skipped: Vec<SkippedEntry>,      // clé, raison
    invalid: Vec<InvalidEntry>,      // clé, problèmes de la base ou erreur du rendu
    rejected: Vec<RejectedRecord>,   // enregistrement illisible du fichier : position, cause
}
pub struct CheckReport { checked: u64, invalid: Vec<InvalidText> }   // clé, langue, portée, erreur

pub enum ExchangeError { Store(Box<LyxalSurrealError>), Parse(ParseError), Io(std::io::Error), Format(FormatError) }

impl Exchange {
    pub fn new(store: I18nStore) -> Self;
    pub async fn export(&self, options: &ExportOptions, format: FileFormat, output: &mut dyn Write)
        -> Result<u64, ExchangeError>;
    pub async fn import(&self, options: &ImportOptions, format: FileFormat, input: &mut dyn Read)
        -> Result<ImportReport, ExchangeError>;
    pub async fn check(&self) -> Result<CheckReport, ExchangeError>;
}
```

* **Export** : pages de 500 par `fn::i18n_export`. JSON : clés triées, un texte par clé (le
  texte de la langue, ou rien si la clé n'est pas traduite). XLIFF : texte source toujours
  présent, `<target>` si traduit, état `initial`, `translated` ou `reviewed`.
* **Import** :
  1. lecture du fichier par `lyxal_parsing` ; un enregistrement illisible va dans `rejected`,
     une erreur fatale arrête l'import avant toute écriture ;
  2. chaque texte est vérifié par `Formatter::check_message` (syntaxe complète, Q4) ; un texte
     refusé va dans `invalid` et n'est pas envoyé ;
  3. envoi par paquets de 500 à `fn::i18n_import`, rapports additionnés.
* **Contrôle** : `fn::i18n_translation_scan` par pages, `Formatter::check_message` sur chaque
  texte dans sa langue ; rien n'est modifié.
* Modèles et wrappers d'une ligne dans `I18nStore` pour les trois fonctions.
* Aucune erreur masquée : fichier illisible, base indisponible et écriture refusée remontent.

## 6. Extension de `lyxal_parsing` (I1)

Un fichier JSON à plat est **un seul objet**, souvent sur plusieurs lignes. `JsonReader` ne lit
aujourd'hui qu'un tableau d'objets ou un objet par ligne. Ajout proposé :
`JsonLayout::Document` — la source entière est un objet, rendu comme un seul enregistrement,
avec les mêmes limites et les mêmes rejets. Tests dans `lyxal_parsing`.

## 7. Commandes de l'hôte (`apps/lyxal-server/src/cli.rs`)

```text
lyxal-server i18n export --locale <langue> --output <fichier> [--format json|xliff] [--namespace <clé>] [--tenant <organisation>]
lyxal-server i18n import --locale <langue> --file <fichier> [--format json|xliff] [--tenant <organisation>] [--overwrite-reviewed] [--dry-run]
lyxal-server i18n check
```

* Session système de l'hôte, comme `admin setup`.
* `import` affiche le rapport (créés, modifiés, inchangés, ignorés, invalides, illisibles) ;
  `check` liste chaque texte invalide (clé, langue, portée, erreur et position).
* Code de sortie non nul si un texte est invalide ou illisible, pour un usage en intégration
  continue.

## 8. Tests

* **Banc SurrealQL** `tests/echange.test.surql` : export filtré et paginé, surcharge d'une
  organisation, import (chaque ligne du tableau du §4), `dry_run`, doublons, droits (membre,
  administrateur d'une autre organisation), parcours de tous les textes réservé.
* **`lyxal_parsing`** : `JsonLayout::Document` (objet sur plusieurs lignes, source vide, tableau
  refusé, limite de taille).
* **Rust** (`tests/it/exchange.rs`, base embarquée) :
  * aller-retour JSON et XLIFF : export, modification, import, textes en base attendus ;
  * caractères à échapper (guillemets, `<`, `&`, apostrophes d'un message) ;
  * texte relu protégé, puis écrasé avec l'option ;
  * fichier illisible : aucune écriture ; élément en ligne XLIFF refusé ;
  * texte que la base accepte mais que le rendu refuse : signalé `invalid`, non écrit ;
  * `check` : texte invalide posé directement en base, retrouvé avec sa clé et sa langue.
* **Hôte** : lecture des arguments des trois commandes (`cli.rs`).
* `scripts/ci/ci_local.sh`.

## 9. Documentation

`README.md` (échange, commandes), `ROADMAP.md` (lot 4 retiré), plan du programme (ligne **4**
« Réalisé »), `README.md` de `lyxal_parsing` (`Document`) et de `lyxal-server` (commandes).

## 10. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| I1 | Le format JSON à plat, celui que produisent les outils de traduction, demande un petit ajout à `lyxal_parsing` (lire un objet unique). Sans lui, il faudrait un format propre à Lyxal | Faire l'ajout : les fichiers restent compatibles avec les outils du marché |
| I2 | Un import peut-il créer des clés qui n'existent pas ? | Non : une clé se déclare avec ses paramètres par le module ou un administrateur. Une clé inconnue est signalée dans le rapport |
| I3 | XLIFF : texte seul, sans les éléments en ligne du format | Oui pour ce lot ; un fichier qui en contient est refusé avec un message clair |
| I4 | Import et export par commandes du serveur seulement, sans écran ni route HTTP | Oui : l'écran viendra avec la console (charte §15) |
