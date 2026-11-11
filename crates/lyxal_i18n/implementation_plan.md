# Plan d'implémentation — `lyxal_i18n`, lot 5 : bascule de `lyxal_base` et de `lyxal_notification`

Lot 5 du programme `lyxal_i18n` (`implementation_plan.md` à la racine, décisions Q1 à Q7). Aucune
ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3). Rupture coordonnée (§0.3) :
tous les appelants du dépôt sont mis à jour dans le même changement, rien n'est conservé pour
compatibilité.

## 1. Objet

Les deux modules qui portent aujourd'hui leurs propres textes passent aux clés de `lyxal_i18n` :

* `lyxal_base` : le libellé des unités et des types d'unités, aujourd'hui en français seul ;
* `lyxal_notification` : les e-mails, aujourd'hui une copie complète du gabarit par langue
  (`notification_template_locale`).

## 2. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **B1** | Les abréviations des unités (`m`, `kg`, `h`) sont-elles traduites ? | **Non.** Elles sont internationales ; seul le libellé (« Mètre ») est traduit. L'abréviation reste un champ de l'unité |
| **N1** | Comment traduire un e-mail ? | **Un seul gabarit par étape, dont les phrases sont des clés** (modèle de Novu) : le gabarit garde la structure (HTML, liens, variables) et appelle `t("clé")` pour chaque phrase. Le traducteur voit des phrases, jamais du HTML. L'autre choix (tout le gabarit copié dans chaque langue) est écarté : un texte `lyxal_i18n` est limité à 10 000 caractères et le traducteur pourrait casser le HTML |
| **N2** | Une organisation qui crée **son propre** parcours d'e-mail peut-elle le traduire ? | **Pas dans ce lot.** Les clés appartiennent à l'installation. Une organisation peut : changer le texte d'un e-mail du système dans chaque langue (surcharge, déjà en place) ; écrire son propre gabarit dans une seule langue. Les clés propres à une organisation sont inscrites à la feuille de route de `lyxal_i18n` |
| **N3** | Garde-t-on le réglage « langue par défaut » propre aux notifications ? | **Non.** Il fait doublon : la langue vient du destinataire, sinon de son organisation, sinon de la langue par défaut de l'installation (`fn::i18n_locale_resolve`) |

## 3. `lyxal_base`

### 3.1. Modèle

* Champ `libelle` **supprimé** de `base_unite` et de `base_unite_type` : le texte vit dans
  `lyxal_i18n` (une responsabilité = un endroit, §5.1).
* Espace de noms `base` (module `lyxal_base`, langue source `fr`). Clés, syntaxe `plain` :
  `base.unite.<code>` et `base.unite_type.<code>` (code en minuscules : `base.unite.km`,
  `base.unite_type.longueur`).
* Seeds : les 11 types et 30 unités du socle gardent leur texte français (texte source) et
  reçoivent leur traduction anglaise. Forme `IF !record::exists(...) THEN ( CREATE ... ) END;`.
* Dépendances du manifeste : ajout de `lyxal_i18n` (donc `lyxal_auth` et `lyxal_event`).
  `lyxal_base` passe sous `lyxal_i18n` dans la hiérarchie (§6) ; aucun cycle, `lyxal_auth` et
  `lyxal_i18n` ne dépendent pas de `lyxal_base`.

### 3.2. Fonctions (signatures inchangées : `$params: object`)

| Fonction | Changement |
| :--- | :--- |
| `fn::base_unite_get`, `fn::base_unite_list`, `fn::base_unite_resolve` | Nouveau paramètre `locale` (règle `locale` de `lyxal_core`, par défaut la valeur de `language`). Le résultat garde le champ `libelle`, rendu dans cette langue par `fn::i18n_resolve_many` (repli : langue parente, langue par défaut, texte source) |
| `fn::base_unite_type_get`, `fn::base_unite_type_list` | Idem |
| `fn::base_unite_create`, `fn::base_unite_type_create` | `libelle` reste obligatoire : il devient le texte source de la clé, créée par `fn::i18n_key_create`. Si l'une des deux écritures échoue, l'autre n'est pas conservée |
| `fn::base_unite_update`, `fn::base_unite_type_update` | `libelle` fourni : texte source modifié par `fn::i18n_translation_set` (les traductions passent à l'état « obsolète », règle du lot 2) |
| `fn::base_unite_delete`, `fn::base_unite_type_delete` | Supprime aussi la clé (`fn::i18n_key_delete`) |

Une traduction s'écrit par les fonctions de `lyxal_i18n` (`fn::i18n_translation_set`, import) :
`lyxal_base` n'ajoute aucune fonction de traduction.

### 3.3. Erreurs

* Nouvelle : `BASE_LIBELLE_WRITE_FAILED` (thème `unite`) — la clé du libellé n'a pas pu être
  écrite (détail : code d'erreur `I18N_*` reçu).
* Core réutilisé : `fn::validation_object_execute` (règles `locale`, `required_string`,
  `record`), `fn::sanitize_object_execute` (`lowercase`). Aucune fonction Core manquante.

### 3.4. Appelants

`lyxal_catalogue` et `lyxal_pipeline_ingestion` référencent les unités par leur code : leurs
fonctions ne lisent pas `libelle`. Leurs tests et fixtures qui créent des unités sont mis à
jour, ainsi que la console (`surrealist`) si elle lit le champ.

## 4. `lyxal_notification`

### 4.1. Modèle

* Table `notification_template_locale` **supprimée**. `notification_template` porte une seule
  version : `subject`, `html_body`, `text_body` (mêmes limites et même nettoyage qu'aujourd'hui).
* Nouveau champ `keys: array<string>` : les clés `lyxal_i18n` que le gabarit utilise (100 au
  plus), vérifiées déclarées à l'enregistrement.
* Champs supprimés : `notification_template.default_locale`,
  `notification_settings.default_locale` (N3).
* Espace de noms `notification` (langue source `fr`). Les quatre e-mails du système
  (vérification d'adresse, récupération de compte, invitation, alerte de sécurité) deviennent
  un gabarit chacun ; leurs phrases sont des clés `notification.<parcours>.<phrase>` en ICU
  MessageFormat 1 (ex. `notification.auth_invitation.subject` :
  « {organization} vous invite à rejoindre Lyxal »), avec la traduction anglaise en seed.
* Dépendance du manifeste : ajout de `lyxal_i18n`.

### 4.2. Fonctions SurrealQL

| Fonction | Changement |
| :--- | :--- |
| `fn::notification_template_create`, `_update` | Paramètres `subject`, `html_body`, `text_body`, `keys` à la place de `default_locale` ; clé non déclarée : `NOTIFICATION_TEMPLATE_KEY_UNKNOWN` |
| `fn::notification_template_get` | Rend le gabarit avec son contenu et ses clés (plus de `locales`) |
| `fn::notification_template_locale_set`, `_locale_delete` | **Supprimées** |
| Réservation d'un envoi (`notification_queue.surql`) | La langue est choisie par `fn::i18n_locale_resolve` (destinataire, puis organisation). Les textes des clés du gabarit sont lus par `fn::i18n_resolve_many` dans cette langue, avec la surcharge de l'organisation, et joints à l'envoi réservé (`texts`) |
| Activation d'un parcours (`notification_workflow.surql`) | Exige un gabarit avec contenu (au lieu d'une version dans la langue par défaut) |

Erreurs : `NOTIFICATION_TEMPLATE_KEY_UNKNOWN` ajoutée ;
`NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED` et `NOTIFICATION_TEMPLATE_LOCALE_MISSING`
supprimées. Core réutilisé : moteur `fn::validation_object_execute` (règles `array_length`,
`each`, `lyxal_event_name`), `fn::sanitize_pipeline_execute`.

### 4.3. Rust

* `models/queue.rs` : `ClaimedJob` reçoit `texts: Vec<ResolvedText>` (`key`, `text`, `syntax`,
  `locale`, `missing`) ; les champs de version par langue disparaissent. Les modèles de gabarit
  (`TemplateCreateParams`, `TemplateUpdateParams`, `Template`) suivent le §4.2 ; les types et
  wrappers de `template_locale_*` sont supprimés. Wrappers `store.call_fn(...)` d'une ligne.
* `render.rs` : fonction MiniJinja `t(clé, nom=valeur, …)`, rendue par
  `lyxal_i18n::Formatter::format_message` dans la **langue du texte retenu**
  (`ResolvedText.locale`) : un texte français servi en repli à un destinataire anglais suit
  les pluriels du français. Les filtres de nombres et de dates gardent la langue de l'envoi.
  La sortie de `t` est échappée dans le HTML comme toute variable. Échec du rendu, sans envoi (aucune erreur silencieuse) :
  clé absente de `keys`, clé non déclarée (`missing`), argument manquant ou message invalide.
* Les filtres `format_number`, `format_currency`, `format_date` du lot 3 sont inchangés.

## 5. Nettoyage (§0.3)

* `crates/lyxal_base/ROADMAP.md` : étape 2 « Libellés traduits » retirée (réalisée).
* `crates/lyxal_notification/ROADMAP.md` : « traductions `lyxal_i18n` » retirée de la V2 et des
  solutions d'attente.
* `crates/lyxal_i18n/ROADMAP.md` : lot 5 retiré ; « clés propres à une organisation » ajoutée à
  « Plus tard » (N2).
* `README.md` des trois modules, `.agents/AGENTS.md` §6 (place de `lyxal_base`),
  `docs/14-roadmap/ROADMAP_NOYAU.md`, ligne 5 du plan racine passée à « Réalisé ».
* Ce plan est supprimé dans la demande de fusion de l'implémentation.

## 6. Tests

* **Banc `lyxal_base`** : libellé rendu en `fr`, en `en`, dans une langue sans traduction
  (repli) ; création, modification (traductions obsolètes) et suppression d'une unité avec sa
  clé ; rejeu des seeds ; écriture refusée sous une identité non autorisée.
* **Banc `lyxal_notification`** : gabarit avec clés, clé inconnue refusée, envoi réservé avec
  les textes dans la langue du destinataire, repli sur la langue de l'organisation puis de
  l'installation, surcharge d'une organisation visible d'elle seule, activation refusée sans
  contenu.
* **Rust** : rendu des quatre e-mails du système en `fr` et en `en` ; pluriel, y compris d'un
  texte servi en repli dans une autre langue que celle de l'envoi ; échappement
  HTML d'un texte traduit ; échec sur clé non déclarée et sur argument manquant.
* **Hôte** : parcours d'inscription et d'invitation de bout en bout (tests existants mis à jour).
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 7. Checklist (§13)

* Architecture : `lyxal_base` et `lyxal_notification` appellent les seules fonctions publiques
  de `lyxal_i18n` ; aucun cycle ; aucune lecture directe des tables `i18n_*`, hors seeds.
* Core : aucune validation locale ; aucune extension demandée.
* Crypto : aucune opération ajoutée.
* Événements : aucun nouvel événement ; ceux de `lyxal_i18n` (`i18n.translation.updated`,
  `i18n.key.missing`) couvrent les textes.
* Zéro dette : table, champs, fonctions, erreurs et types remplacés supprimés ; une seule
  migration par module, réécrite en place ; versions `0.y.z`.
