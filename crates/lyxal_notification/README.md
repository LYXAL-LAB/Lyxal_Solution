# Lyxal Notification

Module du Noyau Technique de Lyxal OS : **notifications sortantes**. Canaux **e-mail** (assez
complet pour les messages de `lyxal_auth` : vérification d'adresse, récupération, invitation,
alertes de sécurité), **SMS** (Brevo, Twilio, Vonage), **messageries d'équipe** (Slack,
Microsoft Teams, Discord, Mattermost, Google Chat, Telegram), **appel signé d'une adresse
web**, **fil dans l'application** (la « cloche », en temps réel par un flux de l'hôte) et
**notifications push** (navigateurs par Web Push, Android par Firebase Cloud Messaging, iPhone
par Apple Push Notification service), pour
les parcours des modules métiers ; destinataires (**abonnés**, leurs **adresses**
de messagerie et web, **sujets**),
**catégories**, **préférences** à tous les niveaux, **heures calmes**, **désabonnement en un
clic**, **diffusion** à un sujet ou à tous, et **parcours à étapes** : attente, regroupement
(digest), limitation (throttle), conditions d'étape, surcharges au déclenchement, envoi groupé,
annulation, aperçu et envoi de test ; **intégrations** (fournisseur d'un canal par organisation,
avec repli sur l'installation), identifiants dans `lyxal_secrets`, bascule après une panne et
**retours des fournisseurs** (délivré, rejeté, plainte) avec suppression automatique des adresses
et numéros rejetés. Toutes les règles vivent dans
SurrealDB (fonctions `fn::notification_*`) ; les attentes et la purge passent par
`lyxal_scheduler` ; le crate Rust ouvre et scelle les secrets (`lyxal_crypto`), rend les gabarits
(MiniJinja), calcule les heures calmes dans le fuseau de l'abonné (`jiff`), signe les liens de
désabonnement (`lyxal_crypto`), lit les identifiants des intégrations dans `lyxal_secrets`, envoie
par SMTP (`lettre`) ou par les API des fournisseurs (`reqwest`), appelle les messageries et les
adresses web par un client sortant contrôlé (SSRF), scelle les adresses et les jetons des
appareils (`lyxal_crypto`), signe les jetons des services push et chiffre les messages Web Push
(`lyxal_crypto`, décision K8) et vérifie les retours (`lyxal_crypto`). Modèle repris de Novu et
Postal ([`MODELE_SOURCES.md`](MODELE_SOURCES.md)) ; évolutions à venir dans [`ROADMAP.md`](ROADMAP.md).

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `notification_settings` | réglages de l'installation, surchargés par organisation : fuseau horaire par défaut des abonnés, tentatives au plus, durées de conservation, `retention_days_inbox` (conservation des messages du fil, 90 jours par défaut, 1 à 365),
`max_wait_days` (durée maximale d'une attente ou d'une fenêtre, 30 jours par défaut, 1 à 366) ; `allowed_hosts` (installation seulement : hôtes autorisés des adresses web et de Mattermost, 100 au plus ; vide : tout hôte public) |
| `notification_subscriber` | abonné : `subscriber_id` stable choisi par l'application (unique par portée), compte `lyxal_auth` lié facultatif (`identity`, supprimé avec lui), e-mail, téléphone (E.164), prénom, nom, langue, fuseau, `data` (8 Kio) ; clé d'enregistrement aléatoire |
| `notification_endpoint` | adresse d'un abonné pour la messagerie (`chat` : `slack`, `teams`, `discord`, `mattermost`, `google_chat`, `telegram`), l'adresse web (`webhook`) ou appareil push (`push` : `webpush`, `fcm`, `apns`, §1.7 : plateforme `web` / `android` / `ios`, empreinte SHA-256 du jeton (`fingerprint`, unique par abonné), jeton scellé (`token`) et clés du navigateur scellées (`p256dh`, `auth`), lus par le worker seulement, date d'inscription `registered_at` ; 10 appareils au plus ; nom invisible d'un gestionnaire) : nom, **hôte** (lisible), adresse **scellée** (`url`, `enc:v2`, lisible par le worker seulement), identifiant du salon Telegram (`chat_id`), clé de signature scellée d'une adresse web (`signing_secret`, worker seulement) et sa date, active, dernier résultat (`last_result`) ; 10 au plus par abonné et par canal ; supprimée avec l'abonné et l'organisation |
| `notification_topic`, `notification_topic_member` | sujets (clé unique par portée) et abonnements, avec condition `lyxal_core` facultative ; supprimés avec le sujet ou l'abonné |
| `notification_category` | catégorie de désabonnement des parcours ; celles de l'installation servent à toutes les organisations |
| `notification_preference` | choix par canal (`email`, `sms`, `chat`, `push`, `in_app`, `webhook` : vrai, faux ou absent) d'un niveau : `tenant_workflow`, `subscriber_global` (avec les heures calmes), `subscriber_category`, `subscriber_workflow` ; unique par cible |
| `notification_workflow` | parcours : clé unique dans sa portée, événement déclencheur (`lyxal_event`), état `draft` / `active` / `inactive` (jamais supprimé), `critical`, `sensitive` (sans étape `in_app` ni `push`), `severity` (`high`, `medium`, `low`, `none` : gravité copiée sur les messages du fil), `category`, `preferences` (`{ channels, enforced }` : défauts et canaux imposés), schéma des variables (`lyxal_core`), étapes typées exécutées dans l'ordre (§1.3, 20 au plus) |
| `notification_layout` | mise en page HTML et texte contenant `{{ content }}` |
| `notification_template` | gabarit d'une étape, en une seule version : e-mail : objet, HTML, texte, mise en page ; SMS, messagerie, adresse web : texte seul et objet (titre) facultatif (décision E5) ; fil (`in_app`) : titre (objet) et texte requis, `avatar`, `redirect`, `actions` (deux boutons au plus `{ kind, label, url }`), `data` (`{ clé : gabarit }`) ; push : titre (objet) et texte requis, `redirect` (lien), `icon`, `data` (2 Kio au plus) ; `keys`, les clés `lyxal_i18n` de ses phrases |
| `notification_broadcast` | diffusion d'un parcours à un sujet ou à tous les abonnés d'une portée, idempotente par (portée, clé) : auteur exclu, curseur, compteurs, réservation du worker |
| `notification_run` | déclenchement pour un abonné, **idempotent** par (portée, clé) : abonné (retiré s'il est supprimé), adresse copiée au déclenchement (`address`), diffusion d'origine, auteur, étape courante (`cursor`), surcharges (`overrides`), envoi de test (`test`), regroupement porté ou rejoint (`digest`) ; états `pending`, `waiting`, `completed`, `failed`, `skipped`, `canceled`, `merged` ; secret scellé effacé dès la fin de ses étapes, à l'annulation ou à son expiration |
| `notification_job` | étape engagée (une par étape et par déclenchement, index unique) : type de l'étape, file d'envoi réservée par `locked_until` et `claim_token` (canaux), intégration de la dernière tentative (`integration`, bascule D3), fin d'une attente (`wait_until`) et exécution différée du planificateur (`scheduler_run`), tentatives, dernière erreur, motif d'une étape écartée (`preference:<niveau>`, `no_address:<canal>`, `condition`, `override`, `throttled`, `test`, `canceled`) ; états `queued`, `running`, `waiting`, `completed`, `failed`, `skipped`, `canceled`, `merged` |
| `notification_digest` | regroupement : portée, parcours, abonné, étape, clé de regroupement, déclenchement porteur, fin de la fenêtre, nombre et données des événements (100 premiers), état `open` / `closed` ; un seul ouvert par clé (index unique sur `open_slot`) |
| `notification_rate_limit` | compteur de limitation d'une fenêtre fixe (identifiant : portée, parcours, abonné, étape, clé, début de la fenêtre), date de purge |
| `notification_inbox` | message du fil d'une personne (§1.6) : portée, abonné `auth:<identité>`, compte (`identity`, base des droits), déclenchement, étape et parcours d'origine, étiquettes et gravité copiées du parcours, titre, texte, avatar, lien, boutons, `data` (**contenu en lecture seule**) ; états `seen_at`, `read_at`, `archived_at`, `snoozed_until`, état des boutons (`action_status`) ; `purge_after` (`retention_days_inbox`) ; un message au plus par étape (index unique) ; supprimé avec l'abonné, son compte et son organisation |
| `notification_message` | message envoyé : canal, destinataire (adresse e-mail, téléphone E.164, **hôte** de l'adresse de messagerie ou web, jamais l'adresse complète, **type** d'un appareil push `<service>:<plateforme>`, jamais le jeton, ou identifiant de l'abonné pour le fil : trace sans contenu), appareil ou adresse servi (`endpoint`, effacé quand il est retiré), adresse servie (`endpoint`), nombre de parties d'un SMS (`parts`), intégration, fournisseur, identifiant chez le fournisseur (`provider_message_id`, unique par intégration), état `sent` puis, d'après les retours, `delivered`, `bounced`, `complained` ; **aucun corps**, objet absent pour un parcours sensible |
| `notification_integration` | intégration : portée (organisation ou installation), clé unique dans la portée, canal (`email`, `sms`, `chat`, `webhook`, `push`), fournisseur propre au canal (e-mail : `smtp`, `brevo`, `mailgun`, `postmark`, `resend` ; SMS : `brevo`, `twilio`, `vonage` ; messagerie : `slack`, `teams`, `discord`, `mattermost`, `google_chat`, `telegram` ; adresse web : `webhook` ; push : `webpush`, `fcm`, `apns`), nom, active, principale (une au plus par portée et canal, index unique sur `primary_slot`), priorité (plus petite d'abord), condition `lyxal_core` facultative, réglages non secrets (e-mail : `from_address`, `from_name`, `reply_to` ; SMTP : `host`, `port`, `security` ; Mailgun : `domain`, `region` `us` / `eu` ; SMS : `sender`, numéro E.164 ou nom court de 11 caractères ; Web Push : `vapid_subject` (`mailto:` ou `https:`), `vapid_public_key` ; FCM : `project_id` ; APNs : `team_id`, `bundle_id`, `environment` `production` / `sandbox`), **chemin** du secret des identifiants (`credentials_path` : e-mail, SMS, Telegram) et du secret des retours (`webhook_path` : e-mail par API, SMS) dans `lyxal_secrets`, dernier essai (`last_test`) ; jamais une valeur secrète |
| `notification_provider_event` | retour normalisé d'un fournisseur : intégration, identifiant de l'événement chez le fournisseur (unique par intégration), type (`delivered`, `bounced`, `soft_bounced`, `complained`), message lié, adresse du message, date ; purgé selon `retention_days_log` ; aucun corps |
| `notification_delivery_log` | journal en ajout seul (tentative, issue, code), jamais de secret |
| `notification_suppression` | adresses (canal `email`) et numéros E.164 (canal `sms`) à ne plus contacter : `hard_bounce`, `complaint`, `manual` (le désabonnement est une préférence, pas une suppression de l'adresse) |

Portée : champ `tenant` (organisation `lyxal_auth`, absent pour l'installation) et clé
`scope_key` (`installation` ou clé de l'organisation) pour les index uniques. Un parcours, une
mise en page ou une liste de suppression de l'installation sert de repli à toutes les
organisations. Les données d'une organisation (réglages, abonnés, sujets, catégories,
préférences, parcours, mises en page, gabarits, diffusions, déclenchements et leurs envois,
regroupements et compteurs, intégrations et leurs retours, liste de suppression) sont supprimées
avec elle quand `lyxal_auth`
la purge (`REFERENCE ON DELETE CASCADE` sur `tenant`) ; les regroupements et compteurs d'un
abonné partent avec lui.

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

### 1.3. Parcours à étapes

Chaque étape a un `type` et une `key` unique dans le parcours ; les étapes s'exécutent **dans
l'ordre** (décision C1) : une étape n'est engagée qu'à la fin de la précédente. Forme contrôlée
par `fn::notification_step_check` (moteur de `lyxal_core`, détail par étape et par champ :
`NOTIFICATION_STEP_INVALID`) :

| Type | Champs |
| :--- | :--- |
| `email`, `sms`, `chat`, `webhook`, `in_app` | canal (e-mail ; SMS au téléphone de l'abonné ; toutes ses adresses de messagerie actives ; toutes ses adresses web actives ; fil de l'abonné lié à un compte, §1.6) |
| `delay` | `amount` + `unit` (`seconds` … `weeks`), ou `until` : chemin d'une date RFC 3339 dans les données (ex. `payload.rendez_vous`), avec `offset` facultatif (`{ amount: -1, unit: "days" }`) |
| `digest` | `window` (`{ amount, unit }`), `group_by` (chemin facultatif de la clé de regroupement), `lookback` facultatif |
| `throttle` | `limit` (1 à 1000), `window`, `group_by` (chemin facultatif) |

Champ commun `condition` (forme `lyxal_core`, contrôlée par `fn::utils_condition_check` :
`NOTIFICATION_CONDITION_INVALID`), évaluée par `fn::utils_condition_evaluate` sur
`{ payload, subscriber: { subscriber_id, locale, timezone, data }, steps: { <clé>: { status } } }`
(jamais le secret) : fausse, l'étape est sautée (`skipped`, motif `condition`). Un parcours a au
moins une étape de canal ; un regroupement ou une limitation précède au moins une étape de
canal ; toute durée est bornée par `max_wait_days` (`NOTIFICATION_WAIT_TOO_LONG`). Seules les
étapes de canal ont un gabarit.

Moteur (`fn::notification_run_advance`, idempotente, appelée au déclenchement, à la fin de
chaque envoi et à la fin de chaque attente) : depuis l'étape courante, il engage les étapes
jusqu'à la première qui attend :

* **canal** : étape en file (adresse et préférences appliquées, relues à la réservation ; heures
  calmes à la réservation) ; envoyée par le worker du canal, puis le déclenchement avance ;
* **attente** : étape en file avec sa fin (`wait_until`, date passée : terminée aussitôt ; date
  absente ou illisible : `NOTIFICATION_PAYLOAD_INVALID` ; au-delà de `max_wait_days` :
  `NOTIFICATION_WAIT_TOO_LONG` ; l'étape et le déclenchement échouent) ; le worker d'étapes la
  confie au planificateur (`fn::notification_wait_schedule` → `fn::scheduler_run_enqueue`, tâche
  `notification.run_resume`, unique par déclenchement et étape) et la passe `waiting` ; à
  l'échéance, le planificateur appelle `fn::notification_run_resume`, qui termine l'attente et
  fait avancer le déclenchement. Qui déclenche n'a besoin d'aucune permission `scheduler.*` ;
* **regroupement** (C3) : fenêtre fixe et clé lue dans les données ; un regroupement ouvert pour
  la clé est rejoint (déclenchement et étape `merged`, événement `notification.run.merged`) ;
  sinon le déclenchement l'ouvre, le porte et attend la fin de la fenêtre comme une attente. Avec
  `lookback`, sans arrivée pour la clé depuis cette durée, le message part tout de suite. À la
  fermeture, le gabarit reçoit `digest.count` et `digest.events` (100 premiers `{ payload, at }`).
  Le regroupement à heure fixe est à la feuille de route ;
* **limitation** (C4) : au plus `limit` messages par fenêtre fixe, par abonné, parcours et clé ;
  au-delà, le déclenchement s'arrête (motif `throttled`, rien n'attend). Un parcours critique
  n'est jamais limité.

Surcharges au déclenchement (C5, `overrides: { steps: { <clé>: { skip, amount, unit, window } } }`,
contrôlées par `fn::notification_override_check`, `NOTIFICATION_OVERRIDE_INVALID`) : sauter
toute étape, changer la durée d'une attente ou la fenêtre d'un regroupement ; aucun texte
remplacé. Annulation (`fn::notification_cancel`) : les déclenchements en cours de la clé (et
`<clé>/…` d'une liste ou d'une diffusion) passent `canceled`, leurs étapes en file ou en attente
aussi, un regroupement porté est refermé sans envoi ; un envoi déjà parti n'est pas rappelé ;
l'exécution différée du planificateur se termine alors sans rien faire. Envoi de test (C7,
`fn::notification_test_send`, `notification.manage`) : un abonné, parcours quel que soit son
état, attentes, regroupements et limitations ignorés (`skipped`, motif `test`), liste de
suppression et préférences appliquées. « Sauter si déjà lu » (C6, décision F7) : pour une étape
`in_app` passée, le contexte des conditions porte `steps.<clé>.seen` et `steps.<clé>.read`
(message du fil vu, lu ; faux sans message), lus quand l'étape suivante est engagée. Ex. : un
e-mail 6 h plus tard seulement si le message du fil n'est pas lu : `[{ key: "fil", type:
"in_app" }, { key: "pause", type: "delay", amount: 6, unit: "hours" }, { key: "mail", type:
"email", condition: { field: "steps.fil.read", op: "eq", value: false } }]`.

Tâches de `lyxal_scheduler` déclarées par le seed du module (exécuteur `function`, portée
`installation`, file `default`, permission propre `notification.worker`) :

| Tâche | Cible | Usage |
| :--- | :--- | :--- |
| `notification.run_resume` | `fn::notification_run_resume` | fin d'une attente ou d'un regroupement (`unique_for` 1 j, arguments `{ run, step_key }`) |
| `notification.purge` | `fn::notification_purge` | planification horaire `notification-purge` (cron `0 * * * *`, décalage de 5 min au plus), créée par le hook d'installation du module si elle est absente : une fois par release pour toute la base ; supprimée ensuite, elle n'est pas recréée au démarrage suivant |

### 1.4. Intégrations et fournisseurs

Une **intégration** dit par quel fournisseur part un canal (`email`, `sms`, `chat`, `webhook`)
pour une organisation, ou pour l'installation (repli de toutes les organisations). Messagerie :
une intégration par service (`slack`…) l'active ; seule Telegram a un secret (le jeton du
robot). Adresse web : une intégration `webhook` par portée active le canal (aucune valeur
secrète).

* **Choix pour un envoi** (D1, à la réservation de l'étape) : intégrations actives de
  l'organisation pour le canal dont la condition (forme `lyxal_core`, évaluée sur
  `{ workflow: { key, critical, sensitive }, subscriber: { subscriber_id, locale, timezone,
  data }, payload }`) est vraie, la **principale** d'abord, puis par priorité croissante ; aucune
  éligible : celles de l'installation, dans le même ordre ; aucune : l'étape reste en file
  (nouvel essai une minute plus tard, sans tentative comptée, `last_error`
  `NOTIFICATION_INTEGRATION_UNAVAILABLE`) et la sonde est dégradée.
* **Bascule** (D3) : un échec temporaire (réseau, délai, 429, 5xx, identifiants illisibles) fait
  passer la tentative suivante à l'intégration éligible **suivante** (dans l'ordre D1, en
  boucle) ; le message suivant repart de la principale. Un refus définitif (400, 401, 403, 422,
  autre 4xx, adresse refusée par le relais) ne bascule pas. L'intégration utilisée est notée sur
  l'étape et sur le message.
* **Identifiants** (D2) : rangés dans `lyxal_secrets` (routes `/api/v1/secrets/*`), sous le
  dossier `notification/` de la **même portée**, en JSON : SMTP `{ username, password }` (ou `{}`
  pour un relais sans authentification) ; Brevo (e-mail et SMS), Mailgun, Postmark, Resend
  `{ api_key }` ; Twilio `{ account_sid, auth_token }` ; Vonage `{ api_key, api_secret }` ;
  Telegram `{ bot_token }`. Secret des retours : Mailgun `{ signing_key }`, Resend
  `{ signing_secret }` (`whsec_…`), Postmark et Brevo `{ username, password }` (authentification
  Basic réglée chez le fournisseur), Twilio `{ auth_token }` (ou le secret des identifiants),
  Vonage `{ signature_secret }` (méthode « HMAC SHA-256 » du compte).
  L'intégration ne garde que les chemins ; le worker lit la valeur par le chemin tracé
  (`SecretsClient`, session système, `lyxal_notification` annoncé comme consommateur : une fiche
  qui liste ses consommateurs doit le nommer). Créer ou modifier une intégration exige, en plus
  de la gestion des notifications, le **droit de lire ce secret** : `secrets.value.read` dans
  l'organisation, `secrets.installation.manage` pour l'installation (sinon un gestionnaire des
  notifications pourrait faire envoyer un secret vers un serveur de son choix) ; l'existence de
  la fiche est vérifiée par `fn::secrets_secret_get` au nom de l'appelant. Une écriture directe
  dans la table est gardée de même (`notification_integration_guard`). Supprimer une intégration
  ne touche pas au secret.
* **Organisation** : pas de relais SMTP en clair (`local_plain`), ni d'hôte IP ou local ; le
  relais en clair est réservé à l'installation et à la boucle locale.
* **Relais SMTP, appel sortant contrôlé** (H1) : le nom du relais est **résolu à chaque envoi**
  (et à chaque essai) et **chaque** adresse obtenue passe le même contrôle que les messageries et
  adresses web (§1.5 : boucle locale, privée, lien local dont métadonnées des plateformes,
  partagée, réservée, documentation, IPv4 portée par IPv6… refusées) ; une seule adresse interdite
  refuse le relais (`NOTIFICATION_DESTINATION_FORBIDDEN`, définitif, sans connexion). La
  connexion se fait à l'adresse vérifiée (aucune seconde résolution), le nom servant au TLS
  (certificat du relais). Seul le relais de l'**installation**, réglé par l'exploitant, peut être
  sur la boucle locale (dont `local_plain` sur `localhost` ou `127.0.0.1`) ; jamais un réseau
  privé. L'essai d'une intégration ne peut donc pas sonder le réseau interne.
* **Fournisseurs** : adresses des API fixées dans le code (Brevo `api.brevo.com/v3/smtp/email`,
  en-tête `api-key` ; Mailgun `api.mailgun.net` ou `api.eu.mailgun.net` `/v3/{domaine}/messages`,
  authentification `api:<clé>`, formulaire ; Postmark `api.postmarkapp.com/email`, en-tête
  `X-Postmark-Server-Token` ; Resend `api.resend.com/emails`, `Authorization: Bearer`) ; le
  domaine Mailgun n'est qu'un segment de chemin encodé. Chaque message non critique porte
  `List-Unsubscribe` et `List-Unsubscribe-Post`.
* **Retours** (D4) : une adresse de l'hôte par intégration
  (`POST /api/v1/notification/webhooks/{intégration}`, sans session) ; vérification propre à
  chaque fournisseur par `lyxal_crypto` (§5), horodatage signé à moins de 5 minutes (Mailgun,
  Resend), corps de 256 Kio au plus ; événements dédoublonnés par (intégration, identifiant chez
  le fournisseur). Retenus : délivré (`sent` → `delivered`), rejet définitif (`bounced`, adresse
  ajoutée à la liste de suppression de l'organisation du message, motif `hard_bounce`), rejet
  temporaire (gardé, sans effet), plainte (`complained`, motif `complaint`). Ouvertures et clics
  ignorés (V2). Un retour dont le message est inconnu est gardé sans effet (`unmatched`).
* **Essai** (D6) : `POST /api/v1/notification/integrations/{intégration}/test` (`{ to }` : e-mail,
  numéro E.164 pour un SMS, identifiant d'une adresse du même service pour la messagerie et
  l'adresse web ; droit de gestion) envoie un message d'essai par le vrai fournisseur ; réponse
  `{ accepted, code }`, sans secret ; issue notée sur l'intégration (`last_test`).

### 1.5. SMS, messageries d'équipe et adresse web

* **Destinataires** (E1) : SMS au téléphone de l'abonné (E.164) ; messagerie et adresse web à
  **toutes** les adresses actives de l'abonné pour le canal (`notification_endpoint`, 10 au plus),
  chacune servie par l'intégration éligible de son service (ordre D1, bascule D3). Une adresse
  servie par une tentative n'est pas rappelée par la suivante ; toutes servies (ou refusées
  définitivement après au moins une servie) : étape terminée ; une adresse en échec temporaire :
  nouvel essai des seules adresses restantes. Sans adresse : étape écartée (`no_address:<canal>`) ;
  un déclenchement n'a d'adresse pour aucun canal du parcours : `NOTIFICATION_SUBSCRIBER_NO_ADDRESS`
  (`NOTIFICATION_SUBSCRIBER_NO_PHONE` pour un parcours de SMS seulement).
* **Adresses scellées** (E2) : une adresse de webhook donne à elle seule le droit d'écrire ;
  elle n'entre en base que **scellée** par l'hôte (`enc:v2`, contexte
  `with_tenant(<organisation> ?? "lyxal_installation", "lyxal_notification",
  "notification_endpoint", <clé de l'adresse>, "url")`), lue par le worker seulement (permission
  de champ) et ouverte en mémoire (`SecretString`) le temps de l'appel ; la personne ne voit que
  l'hôte. La fonction reçoit l'adresse en clair **pour la contrôler seulement** par `lyxal_core`
  (`http_url` HTTPS, `hostname`, liste des hôtes officiels) et n'enregistre que la valeur
  scellée. Telegram : l'adresse ne porte que l'identifiant du salon (`-100…` ou `@nom`).
  Modifier l'adresse : en créer une autre.
* **Sécurité des appels sortants** (E3, K7) : messageries et adresses web passent par
  `OutboundClient` : HTTPS seulement, ni identifiants dans l'adresse ni adresse IP ; hôtes
  officiels pour Slack (`hooks.slack.com`), Teams (`*.webhook.office.com`, flux Power Automate
  `*.logic.azure.com` et `*.environment.api.powerplatform.com`), Discord (`discord.com`,
  `discordapp.com`), Google Chat (`chat.googleapis.com`), Telegram (`api.telegram.org`, fixe) ;
  Mattermost et adresse web : tout hôte public, dans `allowed_hosts` de l'installation si réglée
  (contrôlé à la création et à chaque envoi). Le nom est **résolu à chaque envoi** et chaque
  adresse obtenue vérifiée (refus : non spécifiée, boucle locale, privée, lien local dont
  métadonnées des plateformes, partagée 100.64/10, multidiffusion, diffusion, réservée,
  documentation, IPv6 locale unique fc00::/7 et de lien local fe80::/10, adresses IPv4 portées par
  IPv6 : mappées, compatibles, NAT64, 6to4) ; la connexion est faite **à l'adresse vérifiée**
  (aucune seconde résolution), sans mandataire ; **aucune redirection**, délai de 10 s, réponse
  lue sur 64 Kio au plus. Refus : `NOTIFICATION_DESTINATION_FORBIDDEN` (définitif, sans appel).
* **SMS** (K5) : Brevo (`api.brevo.com/v3/transactionalSMS/sms`, en-tête `api-key`, JSON),
  Twilio (`api.twilio.com/2010-04-01/Accounts/{compte}/Messages.json`, formulaire, Basic), Vonage
  (`rest.nexmo.com/sms/json`, formulaire) ; numéro sans « + » pour Brevo et Vonage ; adresse des
  retours demandée par message (`{public_url}/api/v1/notification/webhooks/{intégration}`) quand
  l'intégration a un secret des retours. **Parties** (E5) : GSM-7 (160, puis 153 par partie ;
  `^ { } \ [ ~ ] | €` comptent double) ou UCS-2 dès un caractère hors alphabet GSM (70, puis 67 ;
  emoji compté double), **10 parties au plus**, refus à l'enregistrement du gabarit (texte tel
  qu'écrit, `fn::notification_sms_segments`) et au rendu (`SmsSegments`, sans envoi :
  `NOTIFICATION_SMS_TOO_LONG`). Refus à l'envoi : numéro invalide (Twilio 21211, 21614…) →
  destinataire refusé, numéro supprimé (rejet définitif) ; désinscrit (Twilio 21610, Vonage 7)
  → numéro supprimé (plainte).
* **Retours des SMS** (E6) : Twilio (`X-Twilio-Signature`, HMAC-SHA1 vérifié par
  `verify_external_hmac_sha1`, extension K8) ; Vonage (paramètre `sig`, HMAC-SHA256 des
  paramètres triés sous le secret de signature, `ExternalHmacKey`, horodatage à 5 minutes) ;
  Brevo (Basic). Numéro inexistant (Twilio 30005, 30006 ; Vonage 3, 9) : `bounced`, numéro
  supprimé ; STOP (Twilio 21610, 30004 ; Vonage 4) : `complained`, numéro supprimé ; autres
  échecs : rejet temporaire. Messageries et adresse web : pas de retours (issue connue à l'appel,
  notée sur l'adresse : `last_result`).
* **Messageries** : texte simple (Markdown du service laissé tel quel), titre en gras ; Slack,
  Mattermost, Google Chat `{ text }` ; Teams : carte adaptative ; Discord `{ content,
  allowed_mentions: { parse: [] } }` (2 000 caractères) ; Telegram `sendMessage` (`chat_id`,
  4 096 caractères). 2xx accepté ; 429 et 5xx temporaires ; autres refus définitifs.
* **Adresse web** (E4) : `POST` JSON `{ id, type: "notification.message", workflow, step, run,
  subscriber_id, payload, text, sent_at }` (jamais le secret du déclenchement), en-têtes
  `Lyxal-Signature: t=<secondes>,v1=<hex>` (HMAC-SHA256 de `<t>.<corps>`) et `Lyxal-Delivery:
  <id>` (stable d'une tentative à l'autre : dédoublonnage chez le destinataire). Clé de signature :
  32 octets tirés par le générateur du système à la création, montrés **une seule fois** en
  hexadécimal, puis scellés ; renouvelable. Le destinataire décode la clé (hexadécimal) et vérifie
  `HMAC-SHA256(clé, t + "." + corps)` en temps constant, en refusant un `t` trop ancien. Réponse
  2xx : livré ; 4xx sauf 408 et 429 : refus définitif ; sinon (3xx compris) nouvel essai.
* **Préférences et heures calmes** (E7) : choix par canal (`sms`, `chat`, `webhook`) ; heures
  calmes pour le SMS et la messagerie, jamais pour l'adresse web.
* **Liste de suppression** : le déclenchement n'est arrêté que si toutes ses adresses sont
  supprimées ; sinon l'étape dont l'adresse (e-mail ou numéro) est supprimée est écartée
  (`suppressed:<motif>`).

### 1.6. Fil dans l'application

* **Destinataire** (F2) : l'abonné `auth:<identité>` lié à un compte `lyxal_auth` ; un invité sans
  compte (`email:…`) n'a pas de fil (étape écartée, `no_address:in_app`). Le fil d'une personne
  est celui de son abonné dans son **organisation active** (l'installation sans organisation
  active).
* **Contenu** (F3) : rendu à l'envoi depuis le gabarit de l'étape (clés `lyxal_i18n`, langue de
  la personne) : titre, texte (Markdown simple affiché tel quel par la console), avatar, lien de
  redirection, deux boutons au plus (principal, secondaire : libellé et lien), `data` (textes,
  8 Kio au plus). Variables échappées (HTML) dans le titre, le texte et les libellés ; jamais le
  secret du déclenchement (une étape `in_app` d'un parcours `sensitive` est refusée à
  l'enregistrement, `in_app_sensitive`). Liens : chemin de l'application (`/…`, jamais `//` ni
  `/\`) ou adresse HTTPS, contrôlés par `lyxal_core` (`fn::notification_link_valid` :
  `validation_http_url`, `sanitize_safe_redirect`, `security_detect_open_redirect`, sans
  caractère de contrôle) à l'enregistrement du gabarit (sa partie fixe, avant la première
  variable) et au rendu (lien rendu, `fn::notification_inbox_deliver`) : `javascript:`, `data:`
  et tout autre schéma sont refusés ; un lien rendu refusé fait échouer l'étape sans rien
  écrire.
* **États** (F4) : vu (ouverture de la cloche), lu (vu aussi), non lu, archivé, supprimé
  (définitivement), en sommeil de 3 minutes à 90 jours (`NOTIFICATION_SNOOZE_INVALID`) : caché
  jusqu'à son échéance, puis de nouveau visible, non vu et non lu, **calculé à la lecture** (aucun
  worker de réveil). Actions groupées par onglet : tout marquer vu, tout marquer lu, archiver
  tous les lus (`filter: { read: true }`), tout supprimer. Boutons : état `done` ou `reverted`
  enregistré sur le message (`NOTIFICATION_FEED_ACTION_INVALID` pour un bouton absent).
* **Compteurs et onglets** (F5) : non vus, non lus, total, calculés à la demande ; onglet =
  filtre `{ tags, severity, data : { clé : valeur }, archived, read }` ; liste du plus récent au
  plus ancien, paginée par curseur (identifiants croissants dans le temps).
* **Temps réel** (F6, K6) : flux SSE de l'hôte (`GET /api/v1/notification/feed/stream`, §5) ; le
  navigateur ne parle jamais à SurrealDB.
* **Pas d'heures calmes** pour le fil (F8, décision B5) ; préférence par canal `in_app`
  appliquée ; conservation `retention_days_inbox` (90 jours par défaut, 1 à 365), purge par la
  planification `notification-purge`.

### 1.7. Notifications push

* **Appareils** (G1) : adresses `push` de l'abonné, inscrites **par la personne elle-même**
  (`fn::notification_my_device_register`, route `POST /api/v1/notification/my/devices` de l'hôte,
  abonné `auth:<identité>` de son organisation active créé au besoin), 10 au plus. Web Push :
  l'abonnement du navigateur (adresse du service push, clés `p256dh` et `auth`) ; FCM et APNs : le
  jeton de l'appareil. L'hôte calcule l'**empreinte** du jeton (SHA-256, `lyxal_crypto`) et
  **scelle** jeton et clés (`enc:v2`, `with_tenant(<organisation> ?? "lyxal_installation",
  "lyxal_notification", "notification_endpoint", <empreinte>, "token" | "p256dh" | "auth")`) ;
  la fonction reçoit les valeurs en clair pour les **contrôler** seulement (`lyxal_core` : adresse
  HTTPS d'un service push connu, forme du jeton et des clés) et n'enregistre que les valeurs
  scellées. Une inscription renvoyée (même empreinte) **met à jour** l'appareil (valeurs scellées,
  plateforme, nom, actif, date) au lieu d'en créer un autre. La personne voit ses appareils (type,
  nom, hôte du service, date, dernier résultat), jamais le jeton ; un gestionnaire voit le type
  (service et plateforme) et la date d'inscription seulement (`fn::notification_device_list`).
  Plateforme : `web` (Web Push), `android` (FCM, par défaut) ou `ios` (FCM ou APNs).
* **Services** (G2, G6) : une intégration `channel: "push"` par service. Web Push : services push
  connus seulement (`fcm.googleapis.com`, `updates.push.services.mozilla.com`,
  `*.push.services.mozilla.com`, `*.notify.windows.com`, `web.push.apple.com`), en HTTPS, par le
  client contrôlé du §1.5 (adresses résolues vérifiées, aucune redirection) ; jeton VAPID ES256
  (`aud` : origine de l'adresse, `exp` 12 h, `sub` : contact) dans `Authorization: vapid t=…,
  k=…`, corps chiffré `aes128gcm` (RFC 8291), en-têtes `TTL` (1 jour) et `Urgency` (`high` pour un
  parcours critique). FCM : jeton RS256 du compte de service échangé à
  `oauth2.googleapis.com/token` contre un jeton d'accès gardé en mémoire jusqu'à son échéance,
  puis `POST fcm.googleapis.com/v1/projects/{projet}/messages:send`. APNs : HTTP/2 vers
  `api.push.apple.com` (ou `api.sandbox.push.apple.com`), jeton ES256 du fournisseur (`kid`,
  `iss` : équipe, `iat`) renouvelé toutes les 50 minutes, en-têtes `apns-topic`,
  `apns-push-type: alert`, `apns-priority`, `apns-expiration`.
* **Contenu** (G4) : titre, texte, lien (règles du fil, §1.6 : chemin de l'application ou HTTPS,
  contrôlé à l'enregistrement du gabarit et après le rendu, `fn::notification_push_links_check`),
  icône, données ; jamais le secret du déclenchement ni de lien de désabonnement ; **4 Kio au
  plus** une fois chiffré : texte tronqué proprement (`…`), sinon `NOTIFICATION_PUSH_TOO_LARGE`
  sans envoi. Web Push reçoit `{ title, body, link, icon, data }` (à lire par le service worker du
  navigateur) ; FCM `notification { title, body }` et `data` (textes, `link`, `icon` compris) ;
  APNs `aps.alert { title, body }` puis `link`, `icon` et les données. Une étape `push` d'un parcours
  `sensitive` est refusée (`push_sensitive`). Préférence du canal `push` et heures calmes
  appliquées.
* **Appareils invalides** (G5) : Web Push 404 / 410, FCM `UNREGISTERED` / `NOT_FOUND` (motif
  `expired`) ou `INVALID_ARGUMENT` sur le jeton, APNs 410 (`expired`) ou 400 `BadDeviceToken`
  (`invalid`) : appareil retiré par le worker (`fn::notification_device_remove`, événement
  `notification.endpoint.removed`, identifiants seulement) ; l'étape réussit si un autre appareil
  a reçu la notification (dans cette tentative ou une précédente), sinon elle échoue
  (`NOTIFICATION_DEVICE_INVALID`). Un appareil servi n'est pas rappelé à la tentative suivante.

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
**Exception documentée** (H3) : l'événement `notification_run_organization_locale` lit
directement le champ `locale` de `auth_organization` (table de `lyxal_auth`, module dont
`lyxal_notification` dépend) pour noter la langue de l'organisation sur le déclenchement.
`fn::auth_organization_get` ne convient pas : il vérifie les droits de la personne qui
déclenche, alors que la langue doit être lue quels que soient ses droits (ni qui déclenche ni le
worker n'ont à lire l'organisation). C'est la seule lecture d'une table d'un autre module.
Appareils et adresses de la personne : elle les inscrit, les liste et les retire elle-même
(routes `/api/v1/notification/my/devices` et `/my/endpoints` de l'hôte, §5) ; ceux d'une autre
personne sont introuvables.
Intégrations : lecture `notification.read` (jamais de secret), gestion `notification.manage`
(installation : `notification.installation.manage`) **et** droit de lire le secret
(`secrets.value.read` ; installation : `secrets.installation.manage`) ; choix, retours et issue
d'un essai : worker ou session système de l'hôte.

Fil (F2) : un message de `notification_inbox` n'est lu et modifié que par **la personne
elle-même** (`fn::notification_can({ action: "self", tenant, identity })` : compte de la session
égal au compte de l'abonné, organisation active égale à celle du message), dans les fonctions
comme dans les `PERMISSIONS` ; un gestionnaire (`notification.read`, `notification.manage`), une
autre personne, la même personne dans une autre organisation ou une autre organisation n'y
voient rien et n'y écrivent rien ; un gestionnaire voit l'envoi dans le journal
(`notification_message`, canal `in_app`, sans titre ni texte). Seul le worker crée un message ;
titre, texte, liens, boutons, données, abonné, compte et organisation sont en lecture seule
(seuls les états et l'état des boutons changent) ; le compte de service du worker
(`notification.worker`, attribué à aucun rôle) le lit aussi (valeurs « vu » et « lu » des
conditions, F7) et le purge.

## 3. Fonctions publiques

| Domaine | Fonctions |
| :--- | :--- |
| Déclenchement | `notification_trigger` (`to` : abonné, liste, `{ topic }`, `{ all: true }` ; `actor`, `exclude_actor`, `overrides`), `notification_trigger_bulk` (1 à 100 déclenchements, rapport par entrée), `notification_cancel` (`notification.send`), `notification_test_send` (`notification.manage`) |
| Abonnés | `notification_subscriber_upsert`, `_get`, `_list` (recherche, pagination), `_delete`, `_import` (500 au plus, rapport créés / modifiés / inchangés / refusés par ligne) |
| Sujets | `notification_topic_create`, `_update`, `_get`, `_list`, `_delete`, `_subscribe` (100 abonnés au plus, condition facultative), `_unsubscribe`, `_members` |
| Catégories | `notification_category_create`, `_update`, `_list`, `_delete` (refusée si un parcours l'utilise) |
| Préférences | `notification_preference_get` (par niveau, et résultat calculé pour un parcours), `_set` (organisation ou abonné), `notification_my_preference_get`, `notification_my_preference_set` (personne connectée), `notification_unsubscribe` (lien vérifié par l'hôte) |
| Diffusions (worker) | `notification_broadcast_claim`, `_step` (paquet suivant, 500 au plus), `_complete` |
| Parcours | `notification_workflow_create`, `_update` (`category` par clé, `clear_category`, `preferences`, étapes typées), `_get`, `_list`, `_set_status` ; `notification_step_preview` (données de l'aperçu d'une étape, `notification.read`) |
| Mises en page | `notification_layout_create`, `_update`, `_get`, `_list` |
| Gabarits | `notification_template_create` (**workflow**, **step_key**, **subject**, **html_body**, **text_body**, `keys`, `layout`), `_update` (champs fournis seulement, `clear_layout`), `_get` |
| Fil (personne connectée) | `notification_feed_list` (`filter`, `cursor`, `limit`), `_counts` (`filter`), `_mark` (`ids` ou `all` + `filter`, `state` : `seen`, `read`, `unread`, `archived`, `unarchived`), `_snooze` (`id`, `until`), `_unsnooze`, `_delete` (`id`, ou `all` + `filter`), `_action` (`id`, `action`, `status`) ; `notification_inbox_deliver` (worker : message rendu d'une étape `in_app`) ; `notification_feed_view` (`{ item }` : vue d'un message, projection publique à **retour brut**, sans `result_ok`, pour une projection `SELECT` : requête `LIVE SELECT` de l'hôte) |
| Réglages | `notification_settings_get`, `_set` (`max_wait_days`, `retention_days_inbox` compris ; expéditeur et adresse de réponse : réglages de l'intégration) |
| Intégrations | `notification_integration_create`, `_update` (champs fournis, réglages remplacés en entier, `clear_condition`, `clear_webhook`), `_get` (par clé ou identifiant), `_list`, `_delete`, `_set_primary`, `_test` (essai : contrôle au nom de l'appelant, D6) ; `_select` (worker : ordre D1 / D3 d'une étape), `_test_record` et `notification_provider_event_record` (hôte) |
| Appareils push | `notification_my_device_register` (valeurs scellées par l'hôte, contrôlées en clair ; inscription renvoyée mise à jour), `notification_my_device_list`, `_delete` (personne connectée) ; `notification_device_list` (`notification.read` : type et date) ; `notification_device_remove` (worker, G5) ; `notification_push_links_check` (worker : liens rendus) ; `notification_push_vapid_key` (hôte : clé publique VAPID d'une portée) |
| Adresses de messagerie et web | `notification_endpoint_create` (adresse scellée par l'hôte, contrôlée en clair), `_update` (nom, active, salon Telegram), `_delete`, `_list` (hôte seulement), `_rotate_secret` (nouvelle clé scellée par l'hôte) ; `notification_my_endpoint_create`, `_update`, `_delete`, `_list`, `_rotate_secret` (personne connectée) ; `notification_endpoint_resolve` (hôte : adresse scellée d'un essai) |
| Liste de suppression | `notification_suppression_add`, `_remove` (`channel` : `email` par défaut ou `sms`), `_list` |
| Activité | `notification_run_get`, `_list` |
| File d'envoi (worker) | `notification_job_claim` (`channel` : un worker par canal, `in_app` compris (sans intégration ni secret) ; avec l'intégration de l'envoi et, pour la messagerie, l'adresse web et le push, les adresses ou appareils scellés non encore servis ; jamais le secret pour le fil et le push), `_renew`, `_release` (`not_before` : fin des heures calmes), `_complete` (`integration`, `provider_message_id`, `response_code`, `parts`, `endpoints` : issue de chaque adresse servie ; renvoie `messages`), `_fail` (`integration`, classe `recipient_opted_out` en plus, `endpoints`) |
| Attentes (worker, planificateur) | `notification_wait_schedule` (paquet de 500 au plus), `notification_run_resume` et `notification_purge` (forme d'appel du planificateur `{ args, run, tenant, scheduled_for, attempt }`) |

Entrées validées et nettoyées par `lyxal_core` ; erreurs `NOTIFICATION_*` (master data
`error/`) ; toute écriture vérifiée (`NOTIFICATION_WRITE_FORBIDDEN`). Conditions d'abonnement
contrôlées à l'enregistrement par `fn::utils_condition_check` (`NOTIFICATION_CONDITION_INVALID`).
Fonctions internes (appelées par les précédentes) : `notification_subscriber_fields`, `_save`,
`_find`, `notification_topic_find`, `notification_category_find`, `notification_channels`,
`notification_preference_key`, `_fields`, `_resolve`, `_write`, `_apply`, `_targets`, `_view`,
`notification_my_subscriber`, `notification_trigger_target`, `_workflow`, `_one`, `_single`,
`notification_run_create`, `notification_settings_effective` ; file d'envoi :
`notification_job_payload`, `_check` ; gabarits : `notification_html_clean`,
`notification_has_content_slot`, `notification_template_content`, `_unknown_keys`,
`notification_workflow_missing_templates` ; retours : `notification_provider_event_apply`,
`_reconcile` ; parcours à étapes : `notification_duration_seconds`,
`notification_step_fields`, `_check`, `_context`, `_enter`, `notification_override_check`,
`notification_job_add`, `notification_wait_due`, `_end`, `notification_group_key`,
`notification_digest_join`, `_merge`, `notification_throttle_hit`, `notification_run_advance`,
`_finalize` ; intégrations : `notification_integration_find`, `_secret_check`,
`_settings_refusal`, `_refusal` (garde), `_fields`, `_view`, `_checked`, `_clean_settings`,
`_unset_primary`, `_eligible`, `_for_job`, `_payload`, `_secrets_refusal` ; canaux :
`notification_channel_address`, `notification_suppression_address`, `_reason`,
`notification_sms_segments`, `notification_template_channel_refusal`,
`notification_endpoint_official_hosts`, `_host_refusal`, `_fields`, `_view`, `_write`, `_find`,
`_change`, `_payload`, `notification_my_endpoint_change`, `notification_job_endpoints`,
`notification_job_endpoint_fields`, `notification_job_endpoint_record` ; fil :
`notification_link_valid`, `notification_feed_scope`, `_filter_fields`, `_match`, `_mine`,
`_targets`, `notification_template_action_fields`, `_feed_refusal` ; push :
`notification_device_fields`, `_shape`, `_view`, `_write`, `notification_template_push_refusal`.

File d'envoi (étapes de canal seulement) : réservation conditionnelle (une étape n'est réservée qu'une fois ; une
réservation expirée est reprise, sauf après la dernière tentative : échec définitif),
renouvelée juste avant chaque envoi ; étape non commencée rendue à la file à l'arrêt du worker ; étape
dont le secret a expiré annulée, jamais envoyée en retard ; échec temporaire rejoué tant que
`attempts < max_attempts` ; destinataire refusé : échec définitif et adresse supprimée
(`hard_bounce`) ; à la réservation, les préférences sont relues (étape désormais refusée :
écartée) et l'étape porte les heures calmes de l'abonné, la cible de son lien de désabonnement
et le regroupement porté. Une étape terminée (envoyée, écartée, en échec définitif) fait avancer
son déclenchement. Purge (planificateur, toutes les heures) : secrets expirés, journal,
déclenchements terminés, diffusions terminées, regroupements fermés, compteurs expirés,
retours des fournisseurs et messages du fil échus (§6.4).

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
(sauf le premier mot de passe d'un compte), `auth.passkey.clone_detected`,
`auth.app_password.created`, `auth.app_password.revoked` (sauf une révocation faite par le
titulaire lui-même, motif `owner` ; nom de l'appareil dans `payload.label`) → parcours critique
`auth_security_alert` (une phrase par nature d'alerte, choisie par `payload.alert`), pour
l'abonné `auth:<identité>` de l'installation (adresse, langue et prénom pris dans la charge
utile), idempotent par l'identifiant d'événement.

Publiés : `notification.run.canceled` (`run_id`, `tenant`, `workflow_id`),
`notification.run.merged` (`run_id`, `digest_id`), `notification.message.sent`,
`notification.message.failed` (étapes de canal),
`notification.address.suppressed` (identifiants, parcours, canal, adresse pour la suppression ;
jamais de contenu ni de secret) ; `notification.subscriber.created`, `.updated` (adresse, nom,
langue, fuseau ou données changés), `.deleted`, `notification.subscriber.unsubscribed` (lien de
désabonnement : catégorie ou parcours, canal), `notification.preference.updated`,
`notification.topic.subscribed`, `.unsubscribed` ; `notification.integration.created`,
`.updated`, `.deleted` (`integration_id`, `tenant`, `channel`) ; `notification.endpoint.created`,
`.updated`, `.deleted` (`endpoint_id`, `subscriber_id`, `tenant`, `channel` ; le dernier résultat
noté par le worker n'est pas une modification ; une nouvelle inscription d'un appareil push en
est une) et `notification.endpoint.removed` (appareil push retiré par le worker sur réponse de son
service, mêmes identifiants : jamais le jeton, l'empreinte ni l'hôte) ; `notification.message.delivered`, `.bounced`,
`.complained` (`message_id`, `run_id`, `integration_id`) : identifiants seulement, jamais
l'adresse, le téléphone, l'hôte ou l'adresse web, le nom, un chemin de secret ni un réglage.
`notification.address.suppressed` d'un numéro (canal `sms`) ne porte pas le numéro. Fil :
`notification.inbox.delivered` (`item_id`, `subscriber_id`, `workflow_id`) et
`notification.inbox.action` (`item_id`, `action`, `status` : bouton « fait » ou « annulé »,
utile à un module métier qui réagit à « Valider le devis ») ; jamais le titre, le texte ni les
données.

## 5. Rust

* `NotificationStore` : appels typés (`LyxalSurrealCall`) ; `XxxParams` / résultats dans
  `models/` (déclenchement, `TriggerTarget` et `TriggerOverrides`, envoi groupé, annulation,
  envoi de test, abonnés, sujets et catégories, préférences, diffusions, file, attentes, aperçu,
  purge, réglages ; étapes typées `WorkflowStep`, énumération par `type`). Les fonctions de
  gestion des parcours, gabarits et mises en page sont appelées par la console. Les appels des
  workers qui enregistrent une issue (`job_complete`, `job_fail`, `wait_schedule`) sont rejoués
  après un conflit d'écriture transitoire de SurrealDB (transaction non validée) : un envoi fait
  n'est jamais refait faute d'avoir pu l'enregistrer. Adresses, téléphones et noms masqués dans
  `Debug`.
* `SecretCodec` : ouverture et rescellement (`CryptoEngine`, contextes non vides) ; scellement et
  ouverture des adresses (`seal_endpoint_value`, `open_endpoint_value`, `EndpointField`) ;
  `generate_signing_key` (clé de signature d'une adresse web : `rand_core::OsRng`, vérifiée comme
  `HmacKey`).
* `OutboundClient` (E3) : contrôles SSRF, résolution par `HostResolver` (`SystemResolver` ;
  `StaticResolver` et `OutboundClient::for_local_tests` réservés aux tests : seule la boucle
  locale s'ajoute aux adresses publiques), `forbidden_ip`, `HostRule`. Le relais SMTP passe par
  la même résolution et le même `forbidden_ip` (H1, `SmtpProvider::with_resolver`,
  `EmailProviders::with_resolver` pour les tests).
* `SmsApi` (Brevo, Twilio, Vonage ; `SmsEndpoints` fixes, `for_local_tests`), `SmsCredentials`,
  `SmsSegments` ; `ChatSender` (`ChatService`, `ChatTarget`, `chat_body`, appel signé
  `call_webhook`, `signature`) ; `ChannelDispatcher` : identifiants lus dans `lyxal_secrets`,
  adresse des retours des SMS, vérification des retours des SMS (`ProviderWebhook::verify_sms`) ;
  `deliver_to_endpoint` : appel d'une adresse (worker et essai de l'hôte).
* `NotificationChannelWorker` (`TextChannel` : `Sms`, `Chat`, `Webhook`, `InApp`) : même file,
  mêmes réservations, heures calmes (sauf adresse web et fil) et nouvelles tentatives que
  l'e-mail (`SendWorkerSettings`) ; `Renderer::render_text` (titre facultatif et texte, sans
  échappement HTML). Fil : `NotificationChannelWorker::in_app` (sans clé ni coffre-fort),
  `Renderer::render_in_app` (`RenderedInApp` : titre, texte et libellés échappés, liens et
  données rendus tels quels, jamais de secret) puis `NotificationStore::inbox_deliver` ; un refus
  de la base (lien rendu refusé) est un échec définitif, une base indisponible laisse expirer la
  réservation. Appels du fil au nom de la personne : `feed_list`, `feed_counts`, `feed_mark`,
  `feed_snooze`, `feed_unsnooze`, `feed_delete`, `feed_action` (`models::Feed*`).
* Push : `PushApi` (Web Push par `OutboundClient`, FCM, APNs en HTTP/2 ; adresses fixes,
  `PushEndpoints::local` et `PushApi::for_local_tests` réservés aux faux services ; horloge
  injectée `PushClock`), `PushCredentials` (clé VAPID `{ private_key }`, fichier du compte de
  service Google, clé APNs `{ key_id, private_key }`, `Debug` masqué), jetons `vapid_token`,
  `fcm_assertion`, `apns_token` (`lyxal_crypto::EcdsaP256SigningKey`, `RsaSigningKey`), jeton
  d'accès FCM et jeton du fournisseur APNs gardés en mémoire (`SecretString`), `PushMessage`
  (`fitted` : 4 Kio, texte tronqué), `PushFailure` et `DeviceRemoval` (appareil à retirer) ;
  `PushDispatcher` (identifiants lus dans `lyxal_secrets`) ; `NotificationPushWorker` (canal
  `push`, heures calmes, `Renderer::render_push`, liens contrôlés, chaque appareil ouvert en
  mémoire et servi, appareil invalide retiré ; réservation, renouvellement, contrôle des liens,
  lecture des identifiants et chaque envoi en course avec l'arrêt, écritures de clôture bornées
  par `PUSH_CLEANUP_BUDGET`) ; `push_to_device` (essai d'une intégration par l'hôte) ;
  `SecretCodec::seal_device_value` / `open_device_value` (`DeviceField`), `device_fingerprint`.
* `NotificationConsumer` (`EventConsumerModule`) et `AuthMessageHandler` : secret illisible,
  charge utile invalide ou parcours absent → lettre morte ; base indisponible → rejoué.
  `SecurityAlertHandler` : alertes de sécurité vers `auth_security_alert` (`SecurityAlert::SILENT_REASON` :
  motif sans alerte, `owner` pour `AppPasswordRevoked`). `auth_subscriber` :
  abonné `auth:<identité>` ou `email:<adresse>` d'un événement `auth.*`.
* `Renderer` : MiniJinja sans chargeur, variable affichée inconnue = erreur, échappement HTML
  automatique, budget d'exécution, mise en page autour du contenu ; rend tout `MessageSource`
  (étape réservée, aperçu). Variables `recipient`, `payload`, `secret`, `organization`, `digest`
  (`count`, `events` : regroupement porté, `{% if digest %}`), `unsubscribe_url` (lien de
  désabonnement, absent pour un parcours critique : `{% if unsubscribe_url %}`).
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
* `EmailProvider` (trait : `send(portée, réglages, EmailMessage, Credentials) -> ProviderReceipt`
  ou `ProviderError` ; `IntegrationScope` : `Installation` ou `Organization`, tirée de
  l'intégration) et `EmailProviders` : `SmtpProvider` (`lettre`, TLS rustls, une connexion par
  envoi à l'adresse vérifiée du relais (H1) ; classement : connexion ou 4xx → `transient`, 550 / 551 / 553 → `recipient_rejected`,
  autre 5xx → `permanent` ; DKIM par le relais) et les API de Brevo, Mailgun, Postmark et Resend
  (`reqwest`, rustls seulement, délai de 10 s, **aucune redirection suivie**, réponse lue sur
  64 Kio au plus ; adresses fixes dans le code, HTTPS seulement ; `EmailProviders::for_local_tests`
  réservé aux faux fournisseurs de la boucle locale ; classement : 2xx accepté, 429 et 5xx
  temporaires, autres refus définitifs ; une réponse acceptée illisible ou trop grande n'est pas
  renvoyée). En-têtes `List-Unsubscribe` et `List-Unsubscribe-Post` quand le message a un lien.
  `Credentials` (JSON du coffre-fort, en `SecretString`, `Debug` masqué) ; `EmailDispatcher` :
  identifiants lus par `SecretsClient` (chemin tracé) puis envoi, essai (`send_test`) et
  vérification des retours (`verify_webhook`).
* `ProviderWebhook` (D4) : Mailgun (HMAC-SHA256 hexadécimal de `timestamp` + `token`), Resend /
  Svix (HMAC-SHA256 de `<svix-id>.<svix-timestamp>.<corps>`, signatures `v1,<base64>`, secret
  `whsec_<base64>`), Postmark et Brevo (identifiants Basic comparés en temps constant : étiquettes
  HMAC-SHA256 sous une clé éphémère, `verify_hmac_sha256`) ; horodatage signé à 5 minutes, corps
  de 256 Kio au plus ; `lyxal_crypto` seulement. Clé de signature du fournisseur de longueur
  quelconque (1 à 1024 octets), utilisée telle quelle : `ExternalHmacKey` et
  `verify_external_hmac_sha256` de `lyxal_crypto`.
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
* `NotificationEmailWorker` (une étape à la fois, avec l'intégration retenue à la réservation,
  identifiants lus du coffre-fort juste avant l'envoi, réservation renouvelée avant l'envoi, traitement
  borné, aucun envoi commencé après l'annulation ; étape dans les heures calmes de l'abonné rendue
  à la file jusqu'à leur fin, sans tentative ; lien de désabonnement avec
  `with_unsubscribe_links` ; attente exponentielle plafonnée avec gigue complète, base 30 s,
  plafond 6 h), `NotificationBroadcastWorker` (diffusions par paquets de 500, réservation
  renouvelée à chaque paquet ; arrêté, il laisse expirer la réservation et la diffusion reprend
  au paquet suivant) et `NotificationStepWorker` (attentes et regroupements confiés au
  planificateur, toutes les secondes quand il y a du travail, sinon toutes les 5 s) ;
  `NotificationModule` (son installation crée la planification horaire de la purge par
  `SchedulerClient::schedule`, `ensure_purge_schedule`, si elle est absente),
  `NotificationHealthCheck` (« dégradé » sans clé applicative ou clé maîtresse du coffre-fort,
  ou sans intégration e-mail active pour l'installation).
* `NotificationPreview` (C7) : aperçu d'une étape (objet, HTML, texte) avec des données
  d'exemple, par le moteur de rendu du worker (`Renderer::preview` : une variable absente,
  secret compris, s'affiche vide), sans écriture ; données lues par
  `fn::notification_step_preview` au nom de l'appelant.

Hébergé par `lyxal-server` (`build.rs`, `src/modules/notification.rs`) : clé applicative
`LYXAL__CRYPTO__APPLICATION_KEY` et clé maîtresse du coffre-fort `LYXAL__SECRETS__MASTER_KEY` ;
sans l'une des deux, aucun e-mail n'est envoyé et les abonnements `auth.*` restent suspendus.
L'hôte n'a aucun réglage d'envoi : les fournisseurs sont des intégrations. Retours :
`POST /api/v1/notification/webhooks/{intégration}` ; essai :
`POST /api/v1/notification/integrations/{intégration}/test`. Appareils et adresses de la
personne connectée : `GET` / `POST /api/v1/notification/my/devices`,
`DELETE /api/v1/notification/my/devices/{appareil}`, `GET` / `POST /api/v1/notification/my/endpoints`,
`DELETE /api/v1/notification/my/endpoints/{adresse}` (`?tenant=` : organisation active ; liste
`{ devices }` ou `{ endpoints }` sans jeton, clé ni adresse complète ; retrait `{ deleted }`).
Liens de désabonnement :
clé applicative et `LYXAL__NOTIFICATION__PUBLIC_URL` ; routes de l'hôte
`GET` / `POST /api/v1/notification/unsubscribe` ; aperçu : `POST /api/v1/notification/preview`
(jeton d'accès, `notification.read`) ; fil : routes `/api/v1/notification/feed*` et flux SSE
`GET /api/v1/notification/feed/stream` (`apps/lyxal-server/README.md`). Temps réel (K6, F6) :
`FeedHub` de l'hôte, une requête `LIVE SELECT` sur `notification_inbox` (session système, vue
projetée par `fn::notification_feed_view`) tenue par un worker supervisé (`FeedHubWorker`,
annulation coopérative), rouverte après une erreur, la fin du flux ou sa disparition (contrôlée toutes les minutes par `INFO FOR TABLE` : la base ne signale pas un `KILL` au flux) ; chaque changement est
réparti aux seules connexions de sa personne (compte et organisation du message) : événement
`notification` (nouveau message), puis `counts`, relus par `fn::notification_feed_counts` dans
la session de la personne ; compteurs de toutes les connexions relus toutes les minutes (fin des
sommeils) et après chaque reprise ; 5 connexions au plus par personne
(`NOTIFICATION_FEED_STREAM_LIMIT`), signe de vie toutes les 25 s avec contrôle de la session
(expirée, révoquée, jeton expiré : flux fermé), connexion lente ou client parti retirés, tous les
flux fermés à l'arrêt. L'hôte installe
`lyxal_scheduler` avant ce module (dépendance du manifeste) et sert la file `default` du
planificateur, qui exécute les reprises et la purge.

## 6. Exploitation

### 6.1. Mise en service

Clés de l'hôte : `LYXAL__CRYPTO__APPLICATION_KEY` (scellement des secrets des messages, des
adresses et des appareils ; liens de désabonnement) et `LYXAL__SECRETS__MASTER_KEY` (lecture des
identifiants des intégrations) ; adresse publique `LYXAL__NOTIFICATION__PUBLIC_URL` (liens de
désabonnement, retours des SMS). Chaque secret d'une intégration se range dans `lyxal_secrets`
sous `notification/` de la **même portée** que l'intégration (installation ou organisation),
consommateur `lyxal_notification` ; créer ou modifier l'intégration demande le droit de lire ce
secret (`secrets.value.read`, ou `secrets.installation.manage` pour l'installation).

* **Première mise en service** (D5) : une installation neuve n'envoie aucun e-mail tant qu'un
  administrateur de la plateforme (`platform_admin` : `notification.installation.manage` et
  `secrets.installation.manage`) n'a pas créé l'intégration e-mail de l'installation ; les
  e-mails déclenchés entre-temps attendent en file (sonde dégradée). Marche à suivre :
  1. créer le secret de l'installation sous `notification/` (`POST /api/v1/secrets/secrets`,
     ex. `notification/smtp/relais`, consommateurs `["lyxal_notification"]`), puis sa valeur
     JSON (`{ "username": "…", "password": "…" }` pour un relais SMTP, `{ "api_key": "…" }` pour
     une API) ;
  2. créer l'intégration (`fn::notification_integration_create`, sans `tenant`, `primary: true`,
     `settings: { from_address, from_name, reply_to, host, port, security }` pour SMTP ou
     `{ from_address, … , domain, region }` pour Mailgun, `credentials_path`) ;
  3. l'essayer (`POST /api/v1/notification/integrations/{intégration}/test`, `{ "to": "…" }`) ;
     la sonde redevient saine. Une organisation qui veut son propre fournisseur fait de même dans
     sa portée (`secrets.value.read` requis).
* **Retours des fournisseurs** : créer le secret des retours sous `notification/` de la même
  portée, le noter dans `webhook_path`, puis régler chez le fournisseur l'adresse
  `{adresse publique de l'hôte}/api/v1/notification/webhooks/{clé de l'intégration}` :
  * **Mailgun** : *Sending → Webhooks*, événements *Delivered*, *Permanent failure*, *Temporary
    failure*, *Spam complaints* ; secret `{ "signing_key": "<HTTP webhook signing key>" }` ;
  * **Resend** : *Webhooks*, événements `email.delivered`, `email.bounced`,
    `email.delivery_delayed`, `email.complained` ; secret `{ "signing_secret": "whsec_…" }` ;
  * **Postmark** : *Servers → Webhooks*, *Delivery*, *Bounce*, *Spam complaint*, avec
    l'authentification HTTP Basic ; secret `{ "username": "…", "password": "…" }` ;
  * **Brevo** : *Transactional → Settings → Webhook*, événements *Delivered*, *Hard bounce*,
    *Soft bounce*, *Spam*, avec l'authentification Basic ; secret `{ "username": "…",
    "password": "…" }`.
  Une intégration SMTP n'a pas de retours (rejets connus à l'envoi : 550, 551, 553).
* **SMS** : secret des identifiants (Twilio `{ account_sid, auth_token }`, Vonage `{ api_key,
  api_secret }`, Brevo `{ api_key }`), intégration `channel: "sms"` avec `settings: { sender }`
  (numéro de l'expéditeur, ou nom court là où l'opérateur l'accepte). Retours : `webhook_path`
  (Twilio `{ auth_token }` ; Vonage `{ signature_secret }` et méthode « HMAC SHA-256 » dans le
  tableau de bord ; Brevo `{ username, password }`) et `LYXAL__NOTIFICATION__PUBLIC_URL` : l'adresse
  des retours est demandée message par message. Twilio signe l'adresse publique exacte : un
  mandataire inverse ne doit pas la réécrire.
* **Messageries** : une intégration `channel: "chat"` par service utilisé (Telegram : secret
  `{ bot_token }`), puis les adresses des abonnés par `POST /api/v1/notification/endpoints`
  (ou `/my/endpoints` pour la personne connectée) avec l'adresse fournie par le service.
* **Adresses web** : une intégration `channel: "webhook", provider: "webhook"` par portée ; à la
  création d'une adresse, l'hôte rend la clé de signature **une seule fois** (à transmettre au
  destinataire) ; `POST /api/v1/notification/endpoints/{adresse}/rotate` en tire une nouvelle.
  `allowed_hosts` (`fn::notification_settings_set` sans `tenant`) limite les hôtes des adresses
  web et de Mattermost.

* **Notifications push** (G2) : une intégration `channel: "push"` par service, son secret sous
  `notification/` de la même portée :
  * **Web Push** : créer le secret (ex. `notification/push/vapid`, valeur provisoire `{}`), puis
    l'intégration `provider: "webpush"`, `settings: { vapid_subject: "mailto:…" }`,
    `credentials_path` ; puis `POST /api/v1/notification/integrations/{intégration}/vapid` (droit
    de gestion et d'écriture du secret) : l'hôte tire une paire P-256, range la clé privée dans le
    secret (`{ "private_key": "<PKCS#8 PEM>" }`) sans la montrer et note la clé publique
    (`vapid_public_key`). Une paire existante peut être rangée à la main (même forme, PEM PKCS#8
    avec sa clé publique) avec sa clé publique dans les réglages. L'application web lit la clé par
    `GET /api/v1/notification/push/vapid-key?tenant=…`, s'abonne (`pushManager.subscribe({
    userVisibleOnly: true, applicationServerKey })`) et envoie `subscription.toJSON()` à
    `POST /api/v1/notification/my/devices` ; son service worker affiche `{ title, body, icon }` et
    ouvre `link` au clic. Changer de paire rend les abonnements existants inutilisables (ils sont
    retirés au premier envoi refusé) ;
  * **FCM** : dans la console Firebase, *Paramètres du projet → Comptes de service → Générer une
    nouvelle clé privée* ; ranger le fichier JSON tel quel dans le secret ; intégration
    `provider: "fcm"`, `settings: { project_id }` ; l'application Android envoie son jeton
    d'enregistrement (`{ provider: "fcm", token }`) ;
  * **APNs** : dans le compte développeur Apple, *Certificates, Identifiers & Profiles → Keys*,
    clé avec le service APNs (fichier `.p8`, identifiant de la clé) ; secret `{ "key_id": "…",
    "private_key": "<contenu du .p8>" }` ; intégration `provider: "apns"`, `settings: { team_id,
    bundle_id, environment: "sandbox" | "production" }` (une application en développement reçoit
    ses notifications du bac à sable) ; l'application iOS envoie son jeton d'appareil en
    hexadécimal (`{ provider: "apns", token }`).
  L'essai d'une intégration push (`POST /api/v1/notification/integrations/{intégration}/test`,
  `{ "to": "notification_endpoint:<clé>" }`) envoie une notification à un appareil du même
  service et de la même organisation.
* **Réglages de l'installation** (`fn::notification_settings_set` sans `tenant`, une
  organisation surcharge les siens sauf `allowed_hosts`) : `timezone` (fuseau par défaut des
  abonnés), `max_attempts` (tentatives d'une étape, 8 par défaut), `max_wait_days` (borne de toute
  attente, fenêtre de regroupement ou de limitation, 30 jours par défaut, contrôlée à
  l'enregistrement d'un parcours comme au déclenchement), `allowed_hosts` (hôtes des adresses web
  et de Mattermost) et les durées de conservation (§6.4).
* **Fil dans l'application** : aucun fournisseur ni clé ; une étape `in_app` dans un parcours,
  son gabarit (titre, texte, liens, boutons), puis l'interface lit `GET /api/v1/notification/feed`
  et écoute `GET /api/v1/notification/feed/stream` avec le jeton de la personne (lecture par
  `fetch` : un `EventSource` natif n'envoie pas l'en-tête `Authorization`) ; à la fermeture du
  flux (session expirée, arrêt de l'hôte, connexion lente), le client se reconnecte avec un
  jeton frais et relit sa liste. Derrière un mandataire inverse : pas de tampon sur ce chemin
  (l'hôte envoie `X-Accel-Buffering: no`) et un délai d'inactivité supérieur à 25 s.

### 6.2. Surveillance

* **Sonde de santé** (`GET /health`, module `lyxal_notification`) : « dégradé » sans clé
  applicative ou clé maîtresse du coffre-fort (aucun envoi par fournisseur, abonnements `auth.*`
  suspendus, `NOTIFICATION_CONFIGURATION_INVALID`) ou sans intégration e-mail active pour
  l'installation (`NOTIFICATION_INTEGRATION_UNAVAILABLE`) ; « en panne » si les réglages ou les
  intégrations sont illisibles (base indisponible).
* **File d'envoi** : étapes `queued` (avec `next_retry_at` et `last_error`) et `running` (avec
  `locked_until`) de `notification_job` ; une étape qui attend une intégration porte
  `last_error.code = NOTIFICATION_INTEGRATION_UNAVAILABLE`. Activité par déclenchement :
  `fn::notification_run_get` / `_list` (état, motif d'une étape écartée, intégration de chaque
  tentative), journal `notification_delivery_log` (tentatives, codes), messages
  `notification_message` (état `sent`, `delivered`, `bounced`, `complained`).
* **Échecs et retours** : événements `notification.message.failed`,
  `notification.message.bounced`, `.complained`, `notification.address.suppressed` (adresse ou
  numéro ajouté à la liste de suppression) ; retours sans message connu gardés `unmatched` dans
  `notification_provider_event` ; dernier essai de chaque intégration (`last_test`, `ok`, `code`).
* **Appareils et adresses** : `notification.endpoint.removed` (appareil push retiré sur réponse de
  son service) ; dernier résultat de chaque adresse ou appareil (`last_result`).
* **Attentes et purge** : exécutions des tâches `notification.run_resume` et `notification.purge`
  par les routes `/api/v1/scheduler/*` (historique, échecs) ; le worker d'étapes journalise les
  codes d'une attente refusée par le planificateur.
* **Journaux de l'hôte** : workers et routes ne journalisent que des identifiants et des codes
  `NOTIFICATION_*` (jamais d'adresse, de jeton ni de secret) ; un échec d'écriture d'un worker est
  journalisé et l'étape reprend à l'expiration de sa réservation.

### 6.3. Incidents

* **Fournisseur en panne** : un échec temporaire (réseau, délai, 429, 5xx) fait passer la
  tentative suivante à l'intégration éligible suivante (bascule D3), avec attente exponentielle ;
  sans seconde intégration, l'étape est rejouée tant que `attempts < max_attempts`. Ajouter une
  intégration de secours (priorité plus grande) suffit, sans redémarrage ; `notification_run_get`
  montre l'intégration de chaque tentative.
* **Identifiants refusés ou jeton révoqué** (401, 403 chez le fournisseur, compte de service
  Google ou clé APNs révoqués, jeton du robot Telegram) : refus **définitif**, sans bascule
  (`NOTIFICATION_PROVIDER_REJECTED`) ; ranger les nouveaux identifiants dans le secret (nouvelle
  version `current`), vérifier par l'essai de l'intégration, puis relancer les envois perdus
  (nouveau déclenchement, nouvelle clé d'idempotence).
* **Secret tourné** : le worker lit la version `current` du secret à **chaque** envoi : une
  nouvelle version sert dès l'envoi suivant ; la rotation sans coupure de `lyxal_secrets` (quatre
  étapes) s'applique telle quelle (révoquer l'ancienne valeur chez le fournisseur une fois la
  nouvelle en place). Secret des retours : tant que le fournisseur signe avec l'ancienne valeur,
  ses retours sont refusés (401) et il les renvoie.
* **Clé VAPID changée** : les abonnements des navigateurs faits avec l'ancienne clé ne servent
  plus ; ils sont retirés au premier envoi refusé (404, 410). L'application web relit la clé
  (`GET /api/v1/notification/push/vapid-key`) et réinscrit l'appareil.
* **Clé applicative changée ou perdue** : les valeurs scellées (adresses, appareils, secrets des
  déclenchements en attente) ne s'ouvrent plus ; adresses et appareils sont à réinscrire, les
  déclenchements en attente à relancer.
* **Un abonné ne reçoit rien** : lire son déclenchement (`fn::notification_run_get`) : motif
  d'étape écartée `preference:<niveau>` (préférences : `fn::notification_preference_get` avec
  le parcours donne le résultat par canal et le niveau qui décide ; désabonnement par lien =
  préférence `subscriber_category` fausse), `suppressed:<motif>` (liste de suppression :
  `fn::notification_suppression_list`, retrait par `_remove`), `no_address:<canal>` (adresse,
  téléphone, adresses de messagerie actives, appareils, compte lié pour le fil), `condition`,
  `throttled` ; une étape rendue à la file jusqu'à la fin de ses **heures calmes** est `queued`
  avec `next_retry_at` ; un message `bounced` ou `complained` a supprimé l'adresse.
* **Relais SMTP refusé** (`NOTIFICATION_DESTINATION_FORBIDDEN`) : son nom se résout en adresse
  interdite (réseau privé, boucle locale pour une organisation) ; le relais d'une organisation
  doit être public.

### 6.4. Purge et rétentions

Planification horaire `notification-purge` (tâche `notification.purge`, créée à l'installation ;
pause, déclenchement immédiat et historique par les routes `/api/v1/scheduler/*`), argument
facultatif `limit` (1 000 par catégorie et par passage). Elle efface :

* les secrets scellés des déclenchements expirés (un déclenchement terminé ou annulé perd son
  secret aussitôt) ;
* les déclenchements terminés au-delà de `retention_days_runs` (90 jours par défaut, 1 à 3 650),
  avec leurs étapes et leurs messages ;
* le journal `notification_delivery_log` et les retours des fournisseurs au-delà de
  `retention_days_log` (30 jours par défaut, 1 à 3 650) ;
* les diffusions terminées, les regroupements fermés et les compteurs de limitation échus ;
* les messages du fil au-delà de `retention_days_inbox` (90 jours par défaut, 1 à 365).

Durées réglées par `fn::notification_settings_set` (installation, ou organisation pour ses
données). Un abonné supprimé emporte ses préférences, abonnements, adresses, appareils et
messages du fil ; une organisation purgée par `lyxal_auth` emporte toutes ses données (§1).

### 6.5. Exploitation courante

* **Attentes en cours** : étapes `delay` / `digest` `queued` (pas encore confiées) ou `waiting`
  (exécution différée `scheduler_run` notée sur l'étape, lisible par `fn::scheduler_run_get`).
  Une exécution refusée par le planificateur (ex. `SCHEDULER_LIMIT_REACHED`, réglage
  `max_pending_runs` de l'installation) laisse l'étape en file : le worker d'étapes la représente
  au passage suivant et journalise les codes.
* **Reprise après panne** : une reprise est idempotente (étape déjà terminée, déclenchement
  annulé ou purgé : rien) ; le planificateur la retente selon la politique de la tâche
  (5 tentatives) ; une attente échue avant d'avoir été confiée est reprise directement par le
  worker d'étapes.

## 7. Vérification

* Banc SurrealQL `tests/*.test.surql` (intégrations : création, contrôles des réglages, chemin du
  secret et droit de le lire (D2) pour la création, la modification et une écriture directe,
  principale unique, suppression ; choix D1 (organisation, repli, condition, priorité, inactive),
  bascule D3, envoi qui attend faute d'intégration ; retours : dédoublonnage, état du message,
  suppression sur rejet et plainte, rejet temporaire, retour inconnu, événements ; essai ;
  droits : organisation, installation, autre organisation, sans droit ; socle, gestion,
  déclenchement, file d'envoi, fonctions
  internes ; abonnés : portée, unicité, import avec erreurs par ligne, droits, données
  personnelles supprimées, reprise des préférences de l'invité ; sujets et conditions ;
  catégories ; préférences : chaque niveau, ordre B4, parcours critique, canal imposé, heures
  calmes, préférences de la personne connectée, désabonnement par lien, préférences relues à la
  réservation ; diffusions : paquets, reprise sans doublon, auteur exclu, condition, réservation
  perdue ; listes ; étapes typées et refus (forme, bornes, condition, ordre, `max_wait_days`),
  surcharges, aperçu ; moteur : ordre, condition fausse, étape sautée, idempotence, attente sur
  durée, date des données, décalage, date passée, absente ou trop lointaine, attentes confiées au
  planificateur, reprise normale, rejouée, après annulation, tâches déclarées ; regroupement :
  ouverture, rejoint, clé, 100 événements, fermeture et variables, recul ; limitation : sous et
  au-dessus de la limite, clé, fenêtre suivante, parcours critique ; annulation : abonné, liste,
  regroupement porté, envoi déjà parti, rien en cours ; envoi groupé ; envoi de test ; purge des
  regroupements et compteurs ; droits), exécuté par `scripts/ci/test_lyxal_modules.py`.
* Tests Rust : rendu (textes traduits, pluriel d'un texte servi en repli, échappement, clés et
  arguments refusés), classement SMTP et HTTP, délais, identifiants masqués, clés HMAC (vecteurs
  RFC 4231), exemple de référence Svix, comparaison en temps constant, retours Postmark et
  Brevo ; chaque fournisseur contre un faux fournisseur local (requête, en-têtes, réponse
  acceptée, refus définitifs, 429 et 5xx, redirection non suivie, réponse trop grande,
  fournisseur injoignable) ; de bout en bout : intégration de l'organisation → faux Postmark →
  retour « rejeté » vérifié (rejeu dédoublonné, identifiants faux refusés) → adresse supprimée,
  aucun identifiant en base ; bascule vers la seconde intégration après une panne, retour à la
  principale, refus définitif sans bascule ; retours Mailgun et Resend (signature valide,
  fausse, horodatage trop ancien, corps modifié, rejeu) ; `tests/it/` sur le moteur
  embarqué avec un serveur SMTP de test (intégration SMTP de l'installation, secret dans le
  coffre-fort) (invitation de `lyxal_auth` reçue, aucune trace du jeton
  en base ; enveloppe d'un autre événement refusée ; 4xx puis succès ; 550 → suppression) ;
  les quatre e-mails du système et chaque alerte de sécurité rendus en français et en anglais ;
  invitation reçue via l'abonné `email:`, alerte de sécurité via l'abonné `auth:` ; lien de
  désabonnement reçu (en-têtes et corps) puis utilisé : plus d'e-mail de la catégorie, un parcours
  critique passe toujours, sans lien ; jeton modifié refusé ; heures calmes qui reportent un
  envoi ; diffusion à un sujet de 1 200 abonnés en trois paquets, auteur exclu ; avec le moteur
  réel de `lyxal_scheduler` (planificateur, exécuteur, worker d'étapes, worker d'envoi) : attente
  réellement reprise puis second e-mail, trois déclenchements regroupés en un e-mail, annulation
  pendant une attente sans envoi, purge exécutée par l'exécuteur `function`, planification de la
  purge créée une seule fois, aperçu d'une étape. Unitaires : jeton
  (aller-retour, falsification, autre clé), heures calmes (fuseau, passage de minuit, jours,
  plages enchaînées, changement d'heure), lien dans le rendu.
* Canaux de texte : banc `tests/canaux.test.surql` (parties d'un SMS ; intégrations par canal et refus ;
  adresses : création, hôtes officiels, HTTP, adresse IP, nom local, valeur non scellée, jamais
  relue, liste d'hôtes de l'installation, limite, droits, écriture filtrée, adresses de la
  personne connectée, nouvelle clé, événements ; gabarits par canal et longueur d'un SMS ; abonné
  sans téléphone ; préférence par canal ; numéro supprimé, parcours critique ; file par canal,
  heures calmes sauf adresse web, adresses servies une fois ; retour d'un SMS ; STOP ; essai par
  canal ; fonctions internes) ; tests Rust : SSRF (adresses interdites, contrôles avant appel,
  noms privés v4, v6 et mappés, métadonnées, nom mixte, HTTP, adresse IP, identifiants, liste
  d'hôtes, redirection non suivie), chaque fournisseur de SMS et chaque messagerie contre un faux
  service local, appel d'une adresse web vérifié par le destinataire, signatures Twilio (vecteur
  calculé indépendamment, fausse, autre adresse, paramètre modifié) et Vonage (formulaire, JSON,
  horodatage), parties d'un SMS, rendu texte ; de bout en bout : déclenchement → SMS (Twilio) +
  Slack + adresse web, aucune adresse en clair en base ni dans un événement, retour Twilio →
  numéro supprimé ; SMS rendu trop long refusé sans envoi ; hôte : routes des adresses et retour
  Twilio (`apps/lyxal-server/tests/notification_channels_http.rs`).
* Fil : banc `tests/fil.test.surql` (liens du fil, gabarits du fil, gravité, étape in_app
  refusée dans un parcours sensible ; livraison : abonné avec compte, invité écarté, liens rendus
  refusés, rejeu, trace d'envoi sans contenu, événements ; lecture par la personne seule : autre
  personne, même personne dans une autre organisation, autre organisation, gestionnaire, session
  sans compte ; écritures directes refusées (modification, suppression, création forgée) ; états,
  actions groupées, sommeil (bornes, réapparition non lue à l'échéance), onglets et compteurs,
  pagination, boutons, suppression, préférence in_app, « sauter si déjà lu », abonné supprimé
  avant la livraison, conservation et purge, fonctions internes) ; tests Rust : rendu du fil
  (échappement, liens, boutons, données, secret absent), de bout en bout sur le moteur embarqué
  (déclenchement → message du fil, lien rendu dangereux refusé, contenu en lecture seule même
  pour la session système) ; hôte (`apps/lyxal-server/tests/notification_feed_http.rs`) : flux
  SSE de la seule personne concernée, compteurs poussés après « lu », routes du fil (404 pour
  une autre personne), limite de 5 flux, session sans compte, fermeture à l'expiration de la
  session, reprise de la requête `LIVE SELECT` après `KILL`, fermeture à l'arrêt du worker.
* Push : banc `tests/push.test.surql` (intégrations push : réglages et secrets ; inscription par
  la personne seule, valeurs scellées exigées, service push inconnu, HTTP, jeton et clés mal
  formés, plateforme, autre organisation, inscription renvoyée mise à jour, limite de 10, écriture
  filtrée ; lecture sans jeton par la personne, une autre personne, un gestionnaire (type et date) ;
  fonctions des adresses aveugles aux appareils ; étape push refusée dans un parcours sensible ;
  gabarits push ; préférence et heures calmes ; file du canal push ; appareil invalide retiré,
  étape réussie par les autres, événement `notification.endpoint.removed` ; appareil déjà servi
  retiré ; clé VAPID ; liens rendus ; essai ; suppression avec l'abonné ; fonctions internes) ;
  tests Rust : cryptographie dans `lyxal_crypto` (vecteur RFC 8291, ES256 et RS256 vérifiés par
  `ring` en test, signature RS256 égale à celle d'OpenSSL) ; Web Push, FCM et APNs contre de faux
  services locaux (`tests/it/push.rs` : jeton VAPID, corps chiffré et en-têtes, refus d'un service
  inconnu, jeton d'accès FCM échangé, gardé puis renouvelé par l'horloge injectée, 401, APNs en
  HTTP/2 et jeton du fournisseur renouvelé à 50 minutes, appareils invalides) ; de bout en bout :
  déclenchement → navigateur, Android et iPhone, l'iPhone désinscrit retiré, aucun jeton en clair ;
  hôte (`apps/lyxal-server/tests/notification_push_http.rs`) : paire VAPID rangée dans le
  coffre-fort, clé publique, inscription scellée, inscription renvoyée, refus ; liste et retrait
  de ses appareils et de ses adresses par la personne, refus pour ceux d'une autre personne.
* Sécurité et contrats : relais SMTP résolu en adresse privée, mêlée ou locale refusé à l'envoi
  (`src/provider/smtp.rs`, `tests/it/providers.rs`) et à l'essai de l'hôte
  (`notification_webhooks_http.rs`) ; `Debug` sans adresse ni donnée personnelle
  (`src/models/mod.rs`) ; descripteur du module égal à celui tiré de `manifest.toml`
  (`src/module.rs`) ; chaque enveloppe de `NotificationStore` appelée et son résultat relu
  (`tests/it/store.rs`) ; clôture d'une étape refusée par les permissions
  (`NOTIFICATION_WRITE_FORBIDDEN`, `file.test.surql`, `fil.test.surql`).
* `scripts/ci/ci_local.sh`.
