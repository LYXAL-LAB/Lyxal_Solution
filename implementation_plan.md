# Plan d'implémentation — programme `lyxal_i18n` V1

Création du crate du Noyau Technique `lyxal_i18n` (rang 2 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](docs/14-roadmap/ROADMAP_NOYAU.md)) : langues, traductions
et formats régionaux. Sources et inventaire de l'existant :
[`crates/lyxal_i18n/RECHERCHE_SOURCES.md`](crates/lyxal_i18n/RECHERCHE_SOURCES.md).

**Deux niveaux de validation** (`AGENTS.md` §3) : ce plan fixe le programme (architecture,
modèle, lots, décisions). Chaque lot a ensuite son propre plan détaillé, soumis au CTO avant
toute ligne de code : contrats Rust `XxxParams` / `XxxResult`, signatures SurrealQL, codes
d'erreurs, tests.

## 1. Architecture

### 1.1. Répartition SurrealQL / Rust

SurrealDB n'a pas de bibliothèque ICU. Le travail est donc partagé :

| SurrealQL (données et règles) | Rust (crate `lyxal_i18n`, ICU4X) |
| :--- | :--- |
| Référentiel des langues : étiquette, noms, sens d'écriture, catégories de pluriel, **chaîne de repli calculée à l'avance** | Calcul des chaînes de repli et des catégories de pluriel depuis CLDR, pour générer le référentiel (outil de génération, résultat versionné en seed) |
| Clés, traductions, surcharges par organisation, états, indicateur « obsolète », permissions | Lecture des messages MF1 et **rendu** : paramètres, pluriels, nombres, dates, devises |
| Choix de la langue parmi des candidats (`fn::i18n_locale_resolve`) | Lecture de `Accept-Language` avec ses poids |
| Résolution d'une clé (`fn::i18n_resolve`) : texte brut, syntaxe, langue effectivement utilisée | Affichage d'une date dans un fuseau horaire (`jiff`), tri selon la langue |
| Contrôles à l'écriture : paramètres déclarés, formes de pluriel présentes | Import et export de fichiers (JSON, XLIFF) par `lyxal_parsing` |

### 1.2. Choix de la langue d'une requête

L'hôte rassemble les candidats, `fn::i18n_locale_resolve` garde la première langue active :

1. langue demandée explicitement par l'appel ;
2. préférence de l'utilisateur (trait `locale` de l'identité) ;
3. langue par défaut de l'organisation active (nouveau champ `locale` de `auth_organization`) ;
4. `Accept-Language`, toutes les entrées dans l'ordre de leurs poids ;
5. langue par défaut de l'installation.

`lyxal_i18n` ne lit ni l'identité ni l'organisation : il reçoit une liste de candidats. Il ne
dépend donc pas des données de `lyxal_auth`, seulement de son contrôle des droits.

### 1.3. Résolution d'une clé et repli

Pour une clé et une langue :

* la **chaîne de repli** suit les langues parentes de CLDR, pas une simple troncature
  (`es-MX → es-419 → es`, `en-AU → en-001 → en`), puis la langue par défaut de l'installation,
  puis la langue source de la clé ;
* pour chaque langue de la chaîne : d'abord la surcharge de l'organisation, puis le texte de
  l'installation ;
* clé absente partout : la clé elle-même est renvoyée avec `missing: true`, et un événement
  `i18n.key.missing` est publié (au plus une fois par clé et par langue). Jamais de texte vide.

### 1.4. Modèle (SurrealDB, préfixe `i18n_`)

| Table | Modèle | Contenu |
| :--- | :--- | :--- |
| `i18n_settings` | document | langue par défaut et langue source de l'installation |
| `i18n_locale` | document | étiquette BCP 47, nom anglais et nom dans la langue, sens d'écriture, catégories de pluriel cardinal et ordinal, `fallback` (chaîne de repli), `active` |
| `i18n_namespace` | document | un espace de noms par module propriétaire (`error`, `base`, `notification`…), langue source |
| `i18n_key` | document | espace de noms + nom (`base.unite.metre`), description pour le traducteur, **paramètres attendus** (nom, type), longueur maximale |
| `i18n_translation` | document | clé, langue, `tenant` (`NONE` : installation), texte, `syntax` (`icu_mf1`), état, empreinte du texte source (`source_hash`), auteur, dates ; unique sur (clé, langue, tenant) |

* **États** (modèle Tolgee) : `untranslated`, `translated`, `reviewed`. **`outdated`** est un
  indicateur posé par un `DEFINE EVENT` quand le texte source change (empreinte différente), qui
  publie `i18n.translation.outdated`.
* **Surcharge par organisation** : ligne de la même table avec `tenant` renseigné ; elle ne
  modifie que le texte, jamais la clé. Supprimée avec l'organisation (`REFERENCE ON DELETE
  CASCADE`, comme le lot 7 de `lyxal_auth`).
* **Contrôles à l'écriture** (modèle Weblate et Tolgee) : mêmes paramètres que le texte source,
  toutes les formes de pluriel de la langue cible, longueur maximale. Un import n'écrase pas un
  texte `reviewed` sans option explicite.
* **Permissions** par `fn::auth_has_permission` : `i18n.translation.manage` (installation),
  `i18n.organization.translation.manage` (surcharges de son organisation) ; lecture ouverte aux
  sessions authentifiées.

### 1.5. Rendu en Rust

`lyxal_i18n::Formatter` (une instance par langue, données ICU4X en cache) :

* `format_message(texte, syntaxe, arguments)` : MF1 limité à argument, `plural`,
  `selectordinal`, `select`, `number`, `date`, `time` ;
* `format_number`, `format_date` (avec fuseau IANA), `format_currency` (isolé, `icu_experimental`
  instable) ;
* données ICU4X générées pour les seules langues prévues (Q5), version CLDR figée.

Consommateurs : l'hôte (messages d'erreur), `lyxal_notification` (filtres MiniJinja de dates,
nombres et montants), les modules Rust qui affichent du texte.

## 2. Dépendances

`lyxal_i18n` dépend de `lyxal_core`, `lyxal_error`, `lyxal_event` et `lyxal_auth` (contrôle des
droits des surcharges). Conséquences :

* `ROADMAP_NOYAU.md` : colonne « Dépend de » de `lyxal_i18n` passée de « — » à `lyxal_auth` ;
* `lyxal_auth` ne dépend pas de `lyxal_i18n` (aucun cycle) : la langue de l'organisation est
  validée par la règle `locale` de `lyxal_core`, son activation est vérifiée à la résolution ;
* `lyxal_error` reste sous `lyxal_i18n` et garde ses propres traductions (Q3) ;
* `lyxal_base` et `lyxal_notification` dépendront de `lyxal_i18n` après leur bascule (lot 5).

## 3. Fonctions publiques (`fn::i18n_*($params: object)`)

| Domaine | Fonctions |
| :--- | :--- |
| Langues | `i18n_locale_list`, `i18n_locale_get`, `i18n_locale_activate`, `i18n_locale_deactivate`, `i18n_locale_resolve`, `i18n_settings_get`, `i18n_settings_update` |
| Espaces de noms et clés | `i18n_namespace_create`, `i18n_namespace_list`, `i18n_key_create`, `i18n_key_update`, `i18n_key_delete`, `i18n_key_list` |
| Traductions | `i18n_translation_set`, `i18n_translation_review`, `i18n_translation_delete`, `i18n_translation_list` (filtres : langue, état, obsolète, manquante) |
| Résolution | `i18n_resolve`, `i18n_resolve_many` (lot de clés pour un écran ou un gabarit) |
| Échange | `i18n_import` (objets déjà lus par Rust), `i18n_export` |

Entrées par le moteur `fn::validation_object_execute` de `lyxal_core` ; erreurs `I18N_*` en
master data (`error/<thème>/`) ; écriture principale vérifiée (`I18N_WRITE_FORBIDDEN`).

## 4. Événements (`fn::event_publish`)

`i18n.locale.activated`, `i18n.locale.deactivated`, `i18n.translation.updated`,
`i18n.translation.outdated`, `i18n.key.missing`.

## 5. Lots

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **1** | **Référentiel des langues et choix de la langue.** Crate et module hébergé ; outil de génération du référentiel depuis CLDR (seed versionné) ; `i18n_settings`, `i18n_locale`, fonctions Langues ; règle `language_tag` (BCP 47 complet) dans `lyxal_core` (Q6) ; champ `locale` de `auth_organization` ; hôte : `Accept-Language` avec poids, choix par `fn::i18n_locale_resolve` à la place du code actuel ; `lyxal_error` : défaut `default_language` aligné sur la résolution (`fr`) | `lyxal_i18n` (nouveau), `lyxal_core`, `lyxal_auth`, `lyxal_error`, `apps/lyxal-server` |
| **2** | **Traductions.** Espaces de noms, clés, traductions, surcharges par organisation, états, indicateur obsolète, contrôles, permissions, résolution avec repli et clé manquante, événements, banc complet | `lyxal_i18n` |
| **3** | **Rendu.** `Formatter` ICU4X (MF1, pluriels, nombres, dates avec fuseau, devises), données générées et figées, sonde de santé (versions CLDR et tz) ; filtres MiniJinja de `lyxal_notification` ; vecteurs de test CLDR | `lyxal_i18n`, `lyxal_notification` |
| **4** | **Import et export.** JSON MF1 et XLIFF 2 par `lyxal_parsing`, protection des textes relus, commandes de l'hôte | `lyxal_i18n`, `apps/lyxal-server` |
| **5** | **Bascule des consommateurs (rupture coordonnée).** `lyxal_base` : libellés des unités en clés (étape 2 de sa feuille de route) ; `lyxal_notification` : gabarits par langue remplacés par des clés (`notification_template_locale` supprimée, partie « traductions » de sa V2) ; tous les tests mis à jour | `lyxal_base`, `lyxal_notification`, `apps/lyxal-server` |
| **6** | **Clôture.** Audit `lyxal-audit`, `README.md`, `ROADMAP.md`, `AGENTS.md` §6, `ROADMAP_NOYAU.md`, `RECHERCHE_SOURCES.md` réduit aux sources retenues | docs |

## 6. Tests et critères de production

* **Banc SurrealQL** : chaque fonction publique ; repli complet (`es-MX → es-419 → es →` défaut) ;
  surcharge d'organisation prioritaire et invisible des autres organisations ; texte obsolète
  après changement de la source ; contrôles de paramètres et de pluriels ; clé manquante ;
  écritures refusées hors permission.
* **Rust** : vecteurs CLDR (pluriels de `fr`, `en`, `ar`, `pl`) ; dates dans plusieurs fuseaux,
  y compris aux changements d'heure ; messages MF1 invalides refusés avec `I18N_MESSAGE_INVALID`.
* **Hôte** : `Accept-Language` avec poids (`de;q=0.5, fr-CA, en;q=0.8`) ; langue de l'organisation.
* Contrôle complet : `scripts/ci/ci_local.sh` à chaque lot.

## 7. Checklist (§13)

* Core : règles existantes réutilisées ; extension `language_tag` soumise au CTO (Q6).
* Crypto : `source_hash` par `crypto::blake3` de SurrealDB, comme les autres modules ; aucune
  primitive ajoutée.
* Rust : aucun `panic!`, aucune erreur silencieuse ; `Formatter` sans `unwrap` hors tests.
* Zéro dette : au lot 5, les anciennes traductions de `lyxal_base` et `lyxal_notification` sont
  supprimées sans chemin conservé.
* Licences : ICU4X (Unicode-3.0), `jiff` (MIT), lecteur FormatJS (MIT) ; Tolgee, Weblate et
  Pontoon en conception seule ; mentions d'origine dans le `README.md`.

## 8. Décisions du CTO (9 novembre 2026)

Q1 à Q7 validées selon les recommandations ci-dessous.

| # | Question | Décision |
| :- | :--- | :--- |
| Q1 | Format des messages | **ICU MessageFormat 1** (sous-ensemble), champ `syntax` pour passer plus tard à MessageFormat 2. Alternatives : MF2 (pas de formateur Rust mûr), Fluent (peu d'outils de traduction) |
| Q2 | Fuseaux horaires | `lyxal_i18n` **affiche** une date dans un fuseau donné ; les conversions et préférences de fuseau restent au futur module décrit dans `Lyxal_timezone/` |
| Q3 | Messages d'erreur | `lyxal_error` **garde ses traductions** dans ses définitions : il est sous `lyxal_i18n` dans la hiérarchie, et les erreurs de `lyxal_i18n` elles-mêmes en ont besoin |
| Q4 | Contrôle de la syntaxe des messages | En SurrealQL : paramètres et formes de pluriel à l'écriture ; syntaxe complète vérifiée par Rust à l'import et au rendu (`I18N_MESSAGE_INVALID`), plus une commande qui liste les messages invalides |
| Q5 | Langues de la V1 | `fr` (défaut) et `en` actives ; données de rendu générées pour `fr`, `en`, `de`, `es`, `it`, `nl`, `pt` ; toutes les langues CLDR dans le référentiel, activables sans recompiler pour la résolution, avec rendu complet seulement pour ces sept |
| Q6 | Extension de `lyxal_core` | Nouvelle règle **`language_tag`** (BCP 47 complet : langue, script, région), la règle `locale` refusant les scripts (`zh-Hant`) |
| Q7 | Contenus métiers traduits (libellés du catalogue, de l'ingestion) | **Hors V1** : clés pour les textes du système seulement ; la traduction des données métier est décrite dans la feuille de route de `lyxal_i18n` |
