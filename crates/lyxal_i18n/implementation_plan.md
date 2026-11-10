# Plan détaillé — lot 3 `lyxal_i18n` : rendu

Lot 3 du programme `lyxal_i18n` (`implementation_plan.md` à la racine, décisions Q1 à Q7).
État des lots 1 et 2 : [`README.md`](README.md). Aucune ligne de code avant la validation de ce
plan (`.agents/AGENTS.md` §3). Plan supprimé une fois exécuté.

## 1. Objectif

* Rendre un message ICU MessageFormat 1 : paramètres, pluriels, sélections, nombres, dates.
* Afficher une date dans un fuseau horaire, un nombre et un montant selon la langue.
* Traduire une clé en une étape (`fn::i18n_resolve` puis rendu).
* Sonde de santé du module ; filtres de dates, nombres et montants dans les gabarits de
  `lyxal_notification`.
* Tout le lot est en Rust : SurrealDB n'a pas ICU. Aucune fonction SurrealQL publique nouvelle.

## 2. Essai préalable (10 novembre 2026)

Les dépendances ont été essayées ensemble dans un projet jetable :

| Brique | Résultat |
| :--- | :--- |
| Pluriels (`icu` 2.4) | `fr` : 1 → `one`, 1 000 000 → `many` |
| Nombres | `12 345,67` en `fr` |
| Dates (`jiff` 0.2 + `jiff-icu` 0.2 + `icu`) | l'instant `2026-03-29T01:30Z` s'affiche `29 mars 2026 à 03:30` à Paris (jour du changement d'heure) et `Mar 29, 2026, 3:30 AM` en `en-US` |
| Montants (`icu_experimental` 0.7) | `1 234,56 €` en `fr`, `€1,234.56` en `en-US` |
| Lecture des messages (`formatjs_icu_messageformat_parser` 2.0.1, MIT) | arbre obtenu pour un message avec pluriel imbriqué ; erreur localisée pour `{a` |
| Taille | exécutable d'essai avec les données de **toutes** les langues : 3,8 Mo |

## 3. Dépendances Rust ajoutées à `lyxal_i18n`

| Crate | Version | Licence | Usage |
| :--- | :--- | :--- | :--- |
| `icu` | 2.4 | Unicode-3.0 | pluriels, nombres, dates, étiquettes de langue |
| `icu_experimental` | 0.7 | Unicode-3.0 | montants ; API instable, isolée dans `format/currency.rs` |
| `fixed_decimal` | 0.7 | Unicode-3.0 | nombres décimaux exacts |
| `jiff`, `jiff-icu` | 0.2 | MIT ou Unlicense | instants, fuseaux horaires, conversion vers ICU4X |
| `formatjs_icu_messageformat_parser` | 2.0 | MIT | lecture des messages (sans ses données par défaut) |

Versions fixées par `Cargo.lock`. Aucune de ces crates n'est une crate cryptographique.

## 4. API Rust (`crates/lyxal_i18n/src/format/`)

### Valeurs et erreurs

```rust
pub enum ArgValue { Text(String), Number(Decimal), DateTime(Timestamp) }
pub struct MessageArgs(BTreeMap<String, ArgValue>);   // constructeurs : text, number, datetime

pub enum FormatError {
    LocaleUnsupported { locale: String },
    MessageInvalid { reason: String, offset: usize },
    ArgumentMissing { name: String },
    ArgumentType { name: String, expected: &'static str },
    TimezoneUnknown { zone: String },
    CurrencyUnknown { code: String },
    NumberInvalid { value: String },
}
impl FormatError { pub fn code(&self) -> &'static str }   // I18N_MESSAGE_INVALID, …
```

Un nombre est lu depuis un entier ou depuis un texte décimal (`"1234.56"`), jamais depuis un
flottant, pour ne pas perdre de précision sur les montants.

### `Formatter` (une langue)

```rust
impl Formatter {
    pub fn new(locale: &str) -> Result<Self, FormatError>;
    pub fn format_message(&self, text: &str, syntax: Syntax, args: &MessageArgs, zone: &str)
        -> Result<String, FormatError>;
    pub fn check_message(&self, text: &str, syntax: Syntax) -> Result<(), FormatError>;
    pub fn format_number(&self, value: &Decimal) -> String;
    pub fn format_percent(&self, value: &Decimal) -> String;
    pub fn format_date(&self, instant: Timestamp, zone: &str, style: DateStyle)
        -> Result<String, FormatError>;
    pub fn format_currency(&self, amount: &Decimal, currency: &str)
        -> Result<String, FormatError>;
}
pub enum Syntax { IcuMf1, Plain }
pub enum DateStyle { Date(Length), Time(Length), DateTime(Length) }   // Length : Short, Medium, Long
```

Éléments d'un message pris en charge (sous-ensemble de la décision Q1) :

| Élément | Rendu |
| :--- | :--- |
| `{nom}` | texte tel quel ; nombre et date mis en forme dans la langue |
| `{n, number}`, `{n, number, integer}`, `{n, number, percent}` | nombre selon la langue |
| `{d, date, short\|medium\|long}`, `{d, time, short\|medium}` | date ou heure dans le fuseau donné |
| `{n, plural, …}`, `{n, selectordinal, …}` | catégorie CLDR de la langue, valeurs exactes `=N`, `offset`, `#` |
| `{s, select, …}` | branche du texte, sinon `other` |
| apostrophes d'échappement | comme ICU |

Un style non pris en charge (squelette `::…`, `spellout`, balises) est refusé :
`I18N_MESSAGE_INVALID`. Un texte `plain` est rendu tel quel.

### `Translator` (clé → texte rendu)

```rust
impl Translator {
    pub fn new(store: I18nStore) -> Self;
    pub async fn translate(&self, request: TranslateRequest) -> Result<Translated, TranslateError>;
    pub fn formatter(&self, locale: &str) -> Result<Arc<Formatter>, FormatError>;
}
pub struct TranslateRequest { key, locale, tenant: Option<String>, args: MessageArgs, zone: String }
pub struct Translated { text: String, locale: Option<String>, missing: bool, overridden: bool }
pub enum TranslateError { Store(LyxalSurrealError), Format(FormatError) }
```

`translate` appelle `fn::i18n_resolve`, puis rend le texte avec le `Formatter` de la langue du
texte **retenu** (pas de la langue demandée : un texte de repli en anglais suit les pluriels
anglais). Les `Formatter` sont gardés en cache par langue (64 au plus). Une clé non déclarée
renvoie la clé avec `missing: true`, sans erreur. Aucune erreur n'est masquée.

## 5. Master data d'erreurs (`error/rendu/`)

`I18N_MESSAGE_INVALID`, `I18N_ARGUMENT_MISSING`, `I18N_ARGUMENT_TYPE`,
`I18N_LOCALE_UNSUPPORTED`, `I18N_TIMEZONE_UNKNOWN`, `I18N_CURRENCY_UNKNOWN`,
`I18N_NUMBER_INVALID` : codes renvoyés par `FormatError::code`, définis en `fr` et `en`.

## 6. Module et sonde de santé

* `I18nModule` (`LyxalModule`) remplace le module de manifeste dans l'hôte
  (`apps/lyxal-server/src/modules/i18n.rs`).
* `I18nHealthCheck` (`ModuleHealthCheck`) :
  * réglages lisibles et langue par défaut active ;
  * un `Formatter` peut être construit pour la langue par défaut ;
  * `Europe/Paris` est connu de la base des fuseaux ;
  * message : version CLDR du référentiel, origine de la base des fuseaux (système ou copie
    embarquée).
* Aucun worker.

## 7. `lyxal_notification`

`render.rs` ajoute trois filtres MiniJinja ; la langue est celle du destinataire
(`recipient.locale`, sinon la langue par défaut du message) :

| Filtre | Exemple | Résultat (`fr`) |
| :--- | :--- | :--- |
| `format_number` | `{{ payload.count \| format_number }}` | `12 345` |
| `format_currency(code)` | `{{ payload.total \| format_currency("EUR") }}` | `1 234,56 €` |
| `format_date(style, zone)` | `{{ payload.due_at \| format_date("long", "Europe/Paris") }}` | `29 mars 2026` |

* Une date arrive en texte RFC 3339 dans la charge utile ; `zone` vaut `UTC` par défaut.
* Une valeur invalide fait échouer le rendu (`NotificationError::Render`), comme une variable
  inconnue aujourd'hui : rien n'est envoyé avec une valeur fausse.
* `lyxal_notification` dépend de la crate `lyxal_i18n`. Ses gabarits ne changent pas dans ce lot
  (bascule vers les clés : lot 5).

## 8. Tests

* **Pluriels** : vecteurs CLDR pour `fr`, `en`, `ar`, `pl`, `ru`, `ja` (cardinal), `en` et `fr`
  (ordinal), `=N`, `offset`.
* **Messages** : imbrication, apostrophes, `select` sans correspondance, argument manquant ou de
  mauvais type, message invalide (position de l'erreur), style refusé, texte `plain`.
* **Dates** : passage à l'heure d'été et d'hiver à Paris, fuseau à décalage d'une demi-heure,
  fuseau inconnu ; styles par langue.
* **Nombres et montants** : séparateurs `fr`, `en`, `de` ; monnaie sans décimale (`JPY`) ; code
  inconnu.
* **Cohérence avec la base** : les messages acceptés puis refusés par `fn::i18n_message_check`
  (banc `controles.test.surql`) donnent le même verdict avec `check_message`.
* **`Translator`** (base embarquée) : clé traduite, repli sur une autre langue rendu avec ses
  pluriels, surcharge d'une organisation, clé manquante.
* **Notifications** : les trois filtres, valeur invalide refusée.
* **Hôte** : sonde `lyxal_i18n` saine au démarrage.
* `scripts/ci/ci_local.sh`.

## 9. Documentation

`README.md` (rendu, `Translator`, sonde, licences), `ROADMAP.md` (lot 3 retiré), plan du
programme (ligne **3** « Réalisé »), `README.md` de `lyxal_notification` (filtres),
`RECHERCHE_SOURCES.md` (données de toutes les langues).

## 10. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| R1 | Langues rendues. La décision Q5 prévoyait de n'embarquer que 7 langues pour limiter la taille. L'essai montre que **toutes** les langues ne pèsent que 3,8 Mo | Embarquer toutes les langues : toute langue activée est rendue correctement, sans outil de génération à maintenir |
| R2 | Base des fuseaux horaires. Celle du système peut manquer sur un serveur minimal ; une copie embarquée ne se met à jour qu'avec une nouvelle version du serveur | Base du système si elle existe, copie embarquée sinon ; la sonde de santé indique laquelle sert |
| R3 | Commande qui liste les messages invalides (décision Q4) | La livrer au lot 4, avec l'export qui parcourt tous les textes ; le lot 3 fournit la vérification (`check_message`) |
| R4 | Version des données. ICU4X embarque sa propre version de CLDR, qui peut différer de celle du référentiel (CLDR 49) le temps d'une mise à jour | Accepter l'écart, afficher les deux versions dans la sonde |
