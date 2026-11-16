# Lyxal Notification

Module du Noyau Technique de Lyxal OS : **notifications sortantes**. Canal e-mail, assez complet
pour les messages de `lyxal_auth` (vérification d'adresse, récupération, invitation, alertes de
sécurité) et pour les parcours des modules métiers ; destinataires (**abonnés**, **sujets**),
**catégories**, **préférences** à tous les niveaux, **heures calmes**, **désabonnement en un
clic** et **diffusion** à un sujet ou à tous. Toutes les règles vivent dans SurrealDB (fonctions
`fn::notification_*`) ; le crate Rust ouvre et scelle les secrets (`lyxal_crypto`), rend les
gabarits (MiniJinja), calcule les heures calmes dans le fuseau de l'abonné (`jiff`), signe les
liens de désabonnement (`lyxal_crypto`) et envoie par SMTP (`lettre`). Modèle repris de Novu et
Postal ([`MODELE_SOURCES.md`](MODELE_SOURCES.md)) ; lots suivants dans [`ROADMAP.md`](ROADMAP.md).

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `notification_settings` | réglages de l'installation, surchargés par organisation : expéditeur, adresse de réponse, fuseau horaire par défaut des abonnés, tentatives au plus, durées de conservation |
| `notification_subscriber` | abonné : `subscriber_id` stable choisi par l'application (unique par portée), compte `lyxal_auth` lié facultatif (`identity`, supprimé avec lui), e-mail, téléphone (E.164), prénom, nom, langue, fuseau, `data` (8 Kio) ; clé d'enregistrement aléatoire |
| `notification_topic`, `notification_topic_member` | sujets (clé unique par portée) et abonnements, avec condition `lyxal_core` facultative ; supprimés avec le sujet ou l'abonné |
| `notification_category` | catégorie de désabonnement des parcours ; celles de l'installation servent à toutes les organisations |
| `notification_preference` | choix par canal (`email`, `sms`, `chat`, `push`, `in_app`, `webhook` : vrai, faux ou absent) d'un niveau : `tenant_workflow`, `subscriber_global` (avec les heures calmes), `subscriber_category`, `subscriber_workflow` ; unique par cible |
| `notification_workflow` | parcours : clé unique dans sa portée, événement déclencheur (`lyxal_event`), état `draft` / `active` / `inactive` (jamais supprimé), `critical`, `sensitive`, `category`, `preferences` (`{ channels, enforced }` : défauts et canaux imposés), schéma des variables (`lyxal_core`), étapes ordonnées `[{ key, channel }]` |
| `notification_layout` | mise en page HTML et texte contenant `{{ content }}` |
| `notification_template` | gabarit d'une étape, en une seule version : objet, HTML, texte, mise en page, et `keys`, les clés `lyxal_i18n` de ses phrases |
| `notification_broadcast` | diffusion d'un parcours à un sujet ou à tous les abonnés d'une portée, idempotente par (portée, clé) : auteur exclu, curseur, compteurs, réservation du worker |
| `notification_run` | déclenchement pour un abonné, **idempotent** par (portée, clé) : abonné (retiré s'il est supprimé), adresse copiée au déclenchement (`address`), diffusion d'origine, auteur ; secret scellé effacé dès la fin de ses étapes ou à son expiration |
| `notification_job` | étape à exécuter : file réservée par `locked_until` et `claim_token`, tentatives, dernière erreur, motif d'une étape écartée (`preference:<niveau>`, `no_address:<canal>`) |
| `notification_message` | message envoyé (destinataire, `Message-ID`) ; **aucun corps**, objet absent pour un parcours sensible |
| `notification_delivery_log` | journal en ajout seul (tentative, issue, code), jamais de secret |
| `notification_suppression` | adresses à ne plus contacter : `hard_bounce`, `complaint`, `manual` (le désabonnement est une préférence, pas une suppression de l'adresse) |

Portée : champ `tenant` (organisation `lyxal_auth`, absent pour l'installation) et clé
`scope_key` (`installation` ou clé de l'organisation) pour les index uniques. Un parcours, une
mise en page ou une liste de suppression de l'installation sert de repli à toutes les
organisations. Les données d'une organisation (réglages, abonnés, sujets, catégories,
préférences, parcours, mises en page, gabarits, diffusions, déclenchements et leurs envois, liste
de suppression) sont supprimées avec elle quand `lyxal_auth` la purge (`REFERENCE ON DELETE
CASCADE` sur `tenant`).

### 1.1. Abonnés et déclenchement

Un déclenchement vise (`to`) :

* **un abonné** `{ subscriber_id, email, phone, first_name, last_name, locale, timezone, data,
  identity }`, créé ou mis à jour à la volée (seuls les champs fournis changent) ; un identifiant
  seul (`"client-42"` ou `{ subscriber_id }`) doit exister (`NOTIFICATION_SUBSCRIBER_NOT_FOUND`) ;
  un abonné sans adresse pour aucun canal du parcours est refusé
  (`NOTIFICATION_SUBSCRIBER_NO_ADDRESS`) ;
* **une liste** de 100 abonnés au plus : un déclenchement par abonné, de clé
  `<idempotency_key>/<subscriber_id>`, et une issue par abonné (`created`, `duplicate`,
  `skipped`, `no_address`, `rejected`) ;
* **un sujet** `{ topic }` ou **tous les abonnés de la portée** `{ all: true }` : une diffusion,
  traitée par le worker par paquets de 500 (paquet suivant après le curseur, une transaction par
  paquet) ; chaque abonné reçoit un déclenchement de clé `<clé de la diffusion>/<subscriber_id>`
  (index unique) : une reprise après arrêt ou une réservation perdue ne renvoie rien deux fois.
  Une condition d'abonnement est évaluée par `fn::utils_condition_evaluate` sur
  `{ subscriber : { subscriber_id, locale, timezone, data }, payload }`.

L'auteur de l'action (`actor`, un `subscriber_id`) n'est pas prévenu, sauf `exclude_actor` faux.
Un secret (code, lien) n'est accepté que pour un seul abonné.

Personnes de `lyxal_auth` (décision B1) : celle qui a un compte est l'abonné `auth:<clé de
l'identité>` lié à son compte ; une personne invitée sans compte est l'abonné `email:<adresse>`.
Quand l'abonné `auth:` est créé, il reprend les préférences de l'abonné `email:` de même adresse
dans la même portée.

Données personnelles : supprimer un abonné supprime ses préférences et ses abonnements ; ses
déclenchements perdent le lien vers lui mais gardent l'adresse utilisée jusqu'à leur purge (durée
des réglages). Les événements ne portent que des identifiants.

### 1.2. Préférences

Calcul unique `fn::notification_preference_resolve` (décision B4), du plus général au plus précis,
le dernier niveau qui s'exprime gagne : défaut du parcours (`preferences.channels`, vrai si
absent) → organisation pour ce parcours (`tenant_workflow`) → choix global de l'abonné → choix de
l'abonné pour la catégorie du parcours → choix de l'abonné pour le parcours. Un parcours
**critique** ignore les choix de l'abonné ; un canal **imposé** (`preferences.enforced`) aussi, et
l'abonné ne peut pas le régler pour ce parcours (`NOTIFICATION_PREFERENCE_ENFORCED`). Le résultat
donne, par canal, `{ allowed, level }`. Il est appliqué à la création de chaque étape (étape
refusée : `skipped`, motif `preference:<niveau>`) et relu à la réservation (un choix fait
entre-temps est respecté).

**Heures calmes** (décision B5, niveau `subscriber_global`) : plages
`{ days : 1 (lundi) à 7, start, end : minutes depuis minuit }`, dans le fuseau de l'abonné, sinon
celui des réglages, sinon UTC ; `end <= start` : la plage passe minuit. Un envoi non critique qui
tombe dans une plage est rendu à la file jusqu'à sa fin, sans tentative comptée ; jamais pour un
parcours critique.

**Désabonnement en un clic** (décisions B6, K9) : chaque e-mail non critique porte un lien signé
(variable `unsubscribe_url` des gabarits et mises en page, en-têtes `List-Unsubscribe` et
`List-Unsubscribe-Post: List-Unsubscribe=One-Click`, RFC 8058). Le lien coupe l'e-mail pour la
**catégorie** du parcours (ou le parcours s'il n'en a pas), au niveau de l'abonné. Jeton :
portée, abonné, catégorie ou parcours, canal, signé HMAC-SHA256 par une clé dérivée de la clé
applicative (HKDF-SHA256), sans date d'expiration et sans compte à ouvrir ; vérifié par l'hôte.

Règles :

* parcours d'une organisation, sinon de l'installation, choisi par clé ou par événement ;
* variables validées par le schéma du parcours ; adresse normalisée par `lyxal_core` ;
* adresse supprimée (organisation ou installation) : déclenchement abandonné
  (`suppressed:<motif>`) ; un parcours **critique** n'est arrêté que par un rejet définitif ou un
  blocage manuel ;
* activation d'un parcours seulement si chaque étape a un gabarit
  (`NOTIFICATION_TEMPLATE_REQUIRED`) ;
* **traduction** : le gabarit porte la structure (HTML, liens, variables) et appelle
  `t("clé", nom=valeur)` pour chaque phrase. Les clés sont déclarées dans `keys` (100 au plus)
  et doivent exister dans `lyxal_i18n` (`NOTIFICATION_TEMPLATE_KEY_UNKNOWN`). Les textes
  s'écrivent et se traduisent par `lyxal_i18n` ; une organisation surcharge ceux d'un e-mail
  du système par `fn::i18n_translation_set` avec son `tenant`. Les e-mails du système ont
  leurs phrases dans l'espace de noms `notification` (texte source en français, traduction
  anglaise fournie). Un gabarit propre à une organisation peut appeler les clés existantes ou
  écrire ses phrases en clair, dans une seule langue ;
* langue du message (`fn::i18n_locale_resolve`) : celle du destinataire, sinon celle de son
  organisation (`auth_organization.locale`, notée sur le déclenchement par la base : ni qui
  déclenche ni le worker n'ont à lire l'organisation), sinon la langue par défaut de
  l'installation ;
  seule une langue active est retenue (`fr-CA` inactive → `fr`). Les textes des clés sont lus
  dans cette langue à la réservation, avec le repli de `lyxal_i18n` ;
* HTML des gabarits et mises en page nettoyé à l'enregistrement (scripts, iframes, gestionnaires
  d'événement) ; objet sans caractère de contrôle.

## 2. Droits

| Permission | Portée | Accès |
| :--- | :--- | :--- |
| `notification.read` | organisation | abonnés, sujets, préférences, parcours, gabarits, réglages, liste de suppression, activité |
| `notification.manage` | organisation | gestion de tout ce qui précède (abonnés, import, sujets, catégories, préférences de l'organisation et des abonnés) |
| `notification.send` | organisation | déclenchement (abonnés créés ou mis à jour à la volée) ; relecture de ses déclenchements |
| `notification.installation.manage` | installation | configuration et activité de l'installation |
| `notification.worker` | installation | compte de service du worker : file d'envoi de toutes les portées |

`organization_admin` reçoit les trois permissions d'organisation, `platform_admin` la gestion de
l'installation ; `notification.worker` n'est attribuée à aucun rôle. Sans permission, chaque
personne connectée (session `lyxal_auth` avec une identité) lit et règle **ses propres**
préférences (`notification_my_*`, décision B2) dans son organisation active ou pour
l'installation : son abonné `auth:<identité>`, créé au besoin avec l'adresse et la langue de son
compte ; elle voit les parcours et les catégories de sa portée, jamais les autres abonnés.
Contrôle unique : `fn::notification_can({ action, tenant, identity })` (actions `read`,
`read_config`, `manage`, `send`, `worker`, `member`, `self`), utilisé par les fonctions et les
`PERMISSIONS`. Le secret d'un déclenchement n'est lisible que par le worker (permission de champ).
Le désabonnement par lien est appelé par l'hôte (session système) après vérification du jeton.

## 3. Fonctions publiques

| Domaine | Fonctions |
| :--- | :--- |
| Déclenchement | `notification_trigger` (`to` : abonné, liste, `{ topic }`, `{ all: true }` ; `actor`, `exclude_actor`) |
| Abonnés | `notification_subscriber_upsert`, `_get`, `_list` (recherche, pagination), `_delete`, `_import` (500 au plus, rapport créés / modifiés / inchangés / refusés par ligne) |
| Sujets | `notification_topic_create`, `_update`, `_get`, `_list`, `_delete`, `_subscribe` (100 abonnés au plus, condition facultative), `_unsubscribe`, `_members` |
| Catégories | `notification_category_create`, `_update`, `_list`, `_delete` (refusée si un parcours l'utilise) |
| Préférences | `notification_preference_get` (par niveau, et résultat calculé pour un parcours), `_set` (organisation ou abonné), `notification_my_preference_get`, `notification_my_preference_set` (personne connectée), `notification_unsubscribe` (lien vérifié par l'hôte) |
| Diffusions (worker) | `notification_broadcast_claim`, `_step` (paquet suivant, 500 au plus), `_complete` |
| Parcours | `notification_workflow_create`, `_update` (`category` par clé, `clear_category`, `preferences`), `_get`, `_list`, `_set_status` |
| Mises en page | `notification_layout_create`, `_update`, `_get`, `_list` |
| Gabarits | `notification_template_create` (**workflow**, **step_key**, **subject**, **html_body**, **text_body**, `keys`, `layout`), `_update` (champs fournis seulement, `clear_layout`), `_get` |
| Réglages | `notification_settings_get`, `_set` |
| Liste de suppression | `notification_suppression_add`, `_remove`, `_list` |
| Activité | `notification_run_get`, `_list` |
| File d'envoi (worker) | `notification_job_claim`, `_renew`, `_release` (`not_before` : fin des heures calmes), `_complete`, `_fail`, `notification_purge` |

Entrées validées et nettoyées par `lyxal_core` ; erreurs `NOTIFICATION_*` (master data
`error/`) ; toute écriture vérifiée (`NOTIFICATION_WRITE_FORBIDDEN`). Conditions d'abonnement
contrôlées à l'enregistrement par `fn::utils_condition_check` (`NOTIFICATION_CONDITION_INVALID`).
Fonctions internes (appelées par les précédentes) : `notification_subscriber_fields`, `_save`,
`_find`, `notification_topic_find`, `notification_category_find`, `notification_channels`,
`notification_preference_key`, `_fields`, `_resolve`, `_write`, `_apply`, `_targets`, `_view`,
`notification_my_subscriber`, `notification_trigger_target`, `notification_run_create`.

File d'envoi : réservation conditionnelle (une étape n'est réservée qu'une fois ; une
réservation expirée est reprise, sauf après la dernière tentative : échec définitif),
renouvelée juste avant chaque envoi ; étape non commencée rendue à la file à l'arrêt du worker ; étape
dont le secret a expiré annulée, jamais envoyée en retard ; échec temporaire rejoué tant que
`attempts < max_attempts` ; destinataire refusé : échec définitif et adresse supprimée
(`hard_bounce`) ; à la réservation, les préférences sont relues (étape désormais refusée :
écartée) et l'étape porte les heures calmes de l'abonné et la cible de son lien de
désabonnement.

## 4. Événements

Consommés (contrat fixé avec `lyxal_auth`) : `auth.verification.requested`,
`auth.recovery.requested`, `auth.invitation.created`. Le code ou le lien y voyage scellé
(`enc:v2`) sous `with_tenant(tenant ?? "lyxal_installation", "lyxal_auth", <type d'événement,
points remplacés par _>, <event_id>, "secret")` : une enveloppe recopiée dans un autre
événement ne s'ouvre pas. Le module l'ouvre, le rescelle sous `with_tenant(…,
"lyxal_notification", "notification_run", <idempotency_key>, "secret")` et déclenche le parcours
de même événement (idempotent par l'identifiant d'événement) pour l'abonné `auth:<identité>`
(identité connue) ou `email:<adresse>` (invitée sans compte), créé ou mis à jour à la volée.

Alertes de sécurité (sans secret) : `auth.mfa.enrolled`, `auth.mfa.removed`,
`auth.mfa.recovery_codes_generated`, `auth.mfa.recovery_code_used`, `auth.password.changed`
(sauf le premier mot de passe d'un compte), `auth.passkey.clone_detected` → parcours critique
`auth_security_alert` (une phrase par nature d'alerte, choisie par `payload.alert`), pour
l'abonné `auth:<identité>` de l'installation (adresse, langue et prénom pris dans la charge
utile), idempotent par l'identifiant d'événement.

Publiés : `notification.message.sent`, `notification.message.failed`,
`notification.address.suppressed` (identifiants, parcours, canal, adresse pour la suppression ;
jamais de contenu ni de secret) ; `notification.subscriber.created`, `.updated` (adresse, nom,
langue, fuseau ou données changés), `.deleted`, `notification.subscriber.unsubscribed` (lien de
désabonnement : catégorie ou parcours, canal), `notification.preference.updated`,
`notification.topic.subscribed`, `.unsubscribed` : identifiants seulement, jamais l'adresse, le
téléphone ni le nom.

## 5. Rust

* `NotificationStore` : appels typés (`LyxalSurrealCall`) ; `XxxParams` / résultats dans
  `models/` (déclenchement et `TriggerTarget`, abonnés, sujets et catégories, préférences,
  diffusions, file, purge, réglages). Les fonctions de gestion des parcours, gabarits et mises en
  page sont appelées par la console. Adresses, téléphones et noms masqués dans `Debug`.
* `SecretCodec` : ouverture et rescellement (`CryptoEngine`, contextes non vides).
* `NotificationConsumer` (`EventConsumerModule`) et `AuthMessageHandler` : secret illisible,
  charge utile invalide ou parcours absent → lettre morte ; base indisponible → rejoué.
  `SecurityAlertHandler` : alertes de sécurité vers `auth_security_alert`. `auth_subscriber` :
  abonné `auth:<identité>` ou `email:<adresse>` d'un événement `auth.*`.
* `Renderer` : MiniJinja sans chargeur, variable affichée inconnue = erreur, échappement HTML
  automatique, budget d'exécution, mise en page autour du contenu. Variables `recipient`,
  `payload`, `secret`, `organization`, `unsubscribe_url` (lien de désabonnement, absent pour un
  parcours critique : `{% if unsubscribe_url %}`).
  Fonction `t("clé", nom=valeur, …)` : texte de la clé, lu à la réservation (`ClaimedJob.texts`),
  rendu par `lyxal_i18n` (ICU MessageFormat 1 : arguments, pluriels) dans la **langue du texte
  retenu** — un texte français servi en repli à un envoi en anglais garde les pluriels du
  français — puis échappé dans le HTML comme toute variable. Le rendu échoue, sans envoi, pour
  une clé absente de `keys`, une clé inconnue de `lyxal_i18n`, un argument absent ou d'un type
  autre que texte ou nombre, un message invalide, ou des textes illisibles à la réservation
  (`ClaimedJob.texts_error`).
  Filtres de `lyxal_i18n`, dans la langue de l'envoi (avec la région du destinataire quand sa
  langue est celle de l'envoi) ; une valeur invalide fait échouer le rendu, rien n'est envoyé :

  | Filtre | Exemple | Résultat (`fr`) |
  | :--- | :--- | :--- |
  | `format_number` | `{{ payload.count \| format_number }}` | `12 345` |
  | `format_currency(code)` | `{{ payload.total \| format_currency("EUR") }}` | `1 234,50 €` |
  | `format_date(style, zone)` | `{{ payload.due_at \| format_date("long", "Europe/Paris") }}` | `29 mars 2026` |

  Une date est un texte RFC 3339 ; `style` vaut `short`, `medium` (défaut) ou `long` pour la
  date seule, `datetime_short`, `datetime_medium` ou `datetime_long`, ou `time` ; `zone` est un
  identifiant IANA (`UTC` par défaut). Un montant est un entier ou un texte décimal (`"1234.50"`).
* `SmtpTransport` (`lettre`, TLS rustls, connexions réutilisées) et `EmailTransport` ;
  classement : connexion ou 4xx → `transient`, 550 / 551 / 553 → `recipient_rejected`, autre 5xx →
  `permanent`. Signature DKIM par le relais. En-têtes `List-Unsubscribe` et
  `List-Unsubscribe-Post` quand le message a un lien de désabonnement.
* `UnsubscribeLinks` : lien `{public_url}/api/v1/notification/unsubscribe?t=<jeton>` ; jeton
  JSON en Base64url (portée, abonné, catégorie ou parcours, canal) suivi de sa signature
  HMAC-SHA256 ; clé dérivée de la clé applicative par `lyxal_crypto::hkdf_sha256` (domaine
  `lyxal_notification/unsubscribe/v1`) ; vérification en temps constant
  (`verify_hmac_sha256`) avant toute lecture du contenu ; rend les paramètres de
  `fn::notification_unsubscribe`.
* `quiet_until` : fin des heures calmes en cours dans le fuseau de l'abonné (`jiff`, base des
  fuseaux embarquée ; plages enchaînées, passage de minuit, changement d'heure ; fuseau inconnu lu
  comme UTC).
* Le worker lit les textes de toutes les organisations : il tourne sous la session système
  de l'hôte ; un compte de service porte `notification.worker` et `i18n.translation.read`.
* `NotificationEmailWorker` (une étape à la fois, réservation renouvelée avant l'envoi, traitement
  borné, aucun envoi commencé après l'annulation ; étape dans les heures calmes de l'abonné rendue
  à la file jusqu'à leur fin, sans tentative ; lien de désabonnement avec
  `with_unsubscribe_links` ; attente exponentielle plafonnée avec gigue complète, base 30 s,
  plafond 6 h), `NotificationBroadcastWorker` (diffusions par paquets de 500, réservation
  renouvelée à chaque paquet ; arrêté, il laisse expirer la réservation et la diffusion reprend
  au paquet suivant) et `NotificationPurgeWorker` (`LyxalWorker`) ; `NotificationModule`,
  `NotificationHealthCheck` (« dégradé » sans relais ou sans clé).

Hébergé par `lyxal-server` (`build.rs`, `src/modules/notification.rs`) : clé applicative
`LYXAL__CRYPTO__APPLICATION_KEY` et relais `LYXAL__NOTIFICATION__SMTP__*` ; sans l'un des deux,
aucun e-mail n'est envoyé et les abonnements `auth.*` restent suspendus. Liens de désabonnement :
clé applicative et `LYXAL__NOTIFICATION__PUBLIC_URL` ; routes de l'hôte
`GET` / `POST /api/v1/notification/unsubscribe` (`apps/lyxal-server/README.md`).

## 6. Vérification

* Banc SurrealQL `tests/*.test.surql` (socle, gestion, déclenchement, file d'envoi, fonctions
  internes ; abonnés : portée, unicité, import avec erreurs par ligne, droits, données
  personnelles supprimées, reprise des préférences de l'invité ; sujets et conditions ;
  catégories ; préférences : chaque niveau, ordre B4, parcours critique, canal imposé, heures
  calmes, préférences de la personne connectée, désabonnement par lien, préférences relues à la
  réservation ; diffusions : paquets, reprise sans doublon, auteur exclu, condition, réservation
  perdue ; listes), exécuté par `scripts/ci/test_lyxal_modules.py`.
* Tests Rust : rendu (textes traduits, pluriel d'un texte servi en repli, échappement, clés et
  arguments refusés), classement SMTP, délais ; `tests/it/` de bout en bout sur le moteur
  embarqué avec un serveur SMTP de test (invitation de `lyxal_auth` reçue, aucune trace du jeton
  en base ; enveloppe d'un autre événement refusée ; 4xx puis succès ; 550 → suppression) ;
  les quatre e-mails du système et chaque alerte de sécurité rendus en français et en anglais ;
  invitation reçue via l'abonné `email:`, alerte de sécurité via l'abonné `auth:` ; lien de
  désabonnement reçu (en-têtes et corps) puis utilisé : plus d'e-mail de la catégorie, un parcours
  critique passe toujours, sans lien ; jeton modifié refusé ; heures calmes qui reportent un
  envoi ; diffusion à un sujet de 1 200 abonnés en trois paquets, auteur exclu. Unitaires : jeton
  (aller-retour, falsification, autre clé), heures calmes (fuseau, passage de minuit, jours,
  plages enchaînées, changement d'heure), lien dans le rendu.
* `scripts/ci/ci_local.sh`.
