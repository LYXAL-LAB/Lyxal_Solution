# Lyxal Notification

Module du Noyau Technique de Lyxal OS : **notifications sortantes**. Canal e-mail, assez complet
pour les messages de `lyxal_auth` (vérification d'adresse, récupération, invitation, alertes de
sécurité) et pour les parcours des modules métiers ; destinataires (**abonnés**, **sujets**),
**catégories**, **préférences** à tous les niveaux, **heures calmes**, **désabonnement en un
clic**, **diffusion** à un sujet ou à tous, et **parcours à étapes** : attente, regroupement
(digest), limitation (throttle), conditions d'étape, surcharges au déclenchement, envoi groupé,
annulation, aperçu et envoi de test ; **intégrations** (fournisseur d'un canal par organisation,
avec repli sur l'installation : SMTP, Brevo, Mailgun, Postmark, Resend), identifiants dans
`lyxal_secrets`, bascule après une panne et **retours des fournisseurs** (délivré, rejeté,
plainte) avec suppression automatique des adresses rejetées. Toutes les règles vivent dans
SurrealDB (fonctions `fn::notification_*`) ; les attentes et la purge passent par
`lyxal_scheduler` ; le crate Rust ouvre et scelle les secrets (`lyxal_crypto`), rend les gabarits
(MiniJinja), calcule les heures calmes dans le fuseau de l'abonné (`jiff`), signe les liens de
désabonnement (`lyxal_crypto`), lit les identifiants des intégrations dans `lyxal_secrets`, envoie
par SMTP (`lettre`) ou par les API des fournisseurs (`reqwest`) et vérifie leurs retours
(`lyxal_crypto`). Modèle repris de Novu et
Postal ([`MODELE_SOURCES.md`](MODELE_SOURCES.md)) ; lots suivants dans [`ROADMAP.md`](ROADMAP.md).

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `notification_settings` | réglages de l'installation, surchargés par organisation : fuseau horaire par défaut des abonnés, tentatives au plus, durées de conservation, `max_wait_days` (durée maximale d'une attente ou d'une fenêtre, 30 jours par défaut, 1 à 366) |
| `notification_subscriber` | abonné : `subscriber_id` stable choisi par l'application (unique par portée), compte `lyxal_auth` lié facultatif (`identity`, supprimé avec lui), e-mail, téléphone (E.164), prénom, nom, langue, fuseau, `data` (8 Kio) ; clé d'enregistrement aléatoire |
| `notification_topic`, `notification_topic_member` | sujets (clé unique par portée) et abonnements, avec condition `lyxal_core` facultative ; supprimés avec le sujet ou l'abonné |
| `notification_category` | catégorie de désabonnement des parcours ; celles de l'installation servent à toutes les organisations |
| `notification_preference` | choix par canal (`email`, `sms`, `chat`, `push`, `in_app`, `webhook` : vrai, faux ou absent) d'un niveau : `tenant_workflow`, `subscriber_global` (avec les heures calmes), `subscriber_category`, `subscriber_workflow` ; unique par cible |
| `notification_workflow` | parcours : clé unique dans sa portée, événement déclencheur (`lyxal_event`), état `draft` / `active` / `inactive` (jamais supprimé), `critical`, `sensitive`, `category`, `preferences` (`{ channels, enforced }` : défauts et canaux imposés), schéma des variables (`lyxal_core`), étapes typées exécutées dans l'ordre (§1.3, 20 au plus) |
| `notification_layout` | mise en page HTML et texte contenant `{{ content }}` |
| `notification_template` | gabarit d'une étape, en une seule version : objet, HTML, texte, mise en page, et `keys`, les clés `lyxal_i18n` de ses phrases |
| `notification_broadcast` | diffusion d'un parcours à un sujet ou à tous les abonnés d'une portée, idempotente par (portée, clé) : auteur exclu, curseur, compteurs, réservation du worker |
| `notification_run` | déclenchement pour un abonné, **idempotent** par (portée, clé) : abonné (retiré s'il est supprimé), adresse copiée au déclenchement (`address`), diffusion d'origine, auteur, étape courante (`cursor`), surcharges (`overrides`), envoi de test (`test`), regroupement porté ou rejoint (`digest`) ; états `pending`, `waiting`, `completed`, `failed`, `skipped`, `canceled`, `merged` ; secret scellé effacé dès la fin de ses étapes, à l'annulation ou à son expiration |
| `notification_job` | étape engagée (une par étape et par déclenchement, index unique) : type de l'étape, file d'envoi réservée par `locked_until` et `claim_token` (canaux), intégration de la dernière tentative (`integration`, bascule D3), fin d'une attente (`wait_until`) et exécution différée du planificateur (`scheduler_run`), tentatives, dernière erreur, motif d'une étape écartée (`preference:<niveau>`, `no_address:<canal>`, `condition`, `override`, `throttled`, `test`, `canceled`) ; états `queued`, `running`, `waiting`, `completed`, `failed`, `skipped`, `canceled`, `merged` |
| `notification_digest` | regroupement : portée, parcours, abonné, étape, clé de regroupement, déclenchement porteur, fin de la fenêtre, nombre et données des événements (100 premiers), état `open` / `closed` ; un seul ouvert par clé (index unique sur `open_slot`) |
| `notification_rate_limit` | compteur de limitation d'une fenêtre fixe (identifiant : portée, parcours, abonné, étape, clé, début de la fenêtre), date de purge |
| `notification_message` | message envoyé : destinataire, intégration, fournisseur, identifiant chez le fournisseur (`provider_message_id`, unique par intégration), état `sent` puis, d'après les retours, `delivered`, `bounced`, `complained` ; **aucun corps**, objet absent pour un parcours sensible |
| `notification_integration` | intégration : portée (organisation ou installation), clé unique dans la portée, canal (`email`), fournisseur (`smtp`, `brevo`, `mailgun`, `postmark`, `resend`), nom, active, principale (une au plus par portée et canal, index unique sur `primary_slot`), priorité (plus petite d'abord), condition `lyxal_core` facultative, réglages non secrets (`from_address`, `from_name`, `reply_to` ; SMTP : `host`, `port`, `security` ; Mailgun : `domain`, `region` `us` / `eu`), **chemin** du secret des identifiants (`credentials_path`) et du secret des retours (`webhook_path`) dans `lyxal_secrets`, dernier essai (`last_test`) ; jamais une valeur secrète |
| `notification_provider_event` | retour normalisé d'un fournisseur : intégration, identifiant de l'événement chez le fournisseur (unique par intégration), type (`delivered`, `bounced`, `soft_bounced`, `complained`), message lié, adresse du message, date ; purgé selon `retention_days_log` ; aucun corps |
| `notification_delivery_log` | journal en ajout seul (tentative, issue, code), jamais de secret |
| `notification_suppression` | adresses à ne plus contacter : `hard_bounce`, `complaint`, `manual` (le désabonnement est une préférence, pas une suppression de l'adresse) |

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
| `email` | canal (les autres canaux s'ajoutent aux lots suivants) |
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
suppression et préférences appliquées. « Sauter si déjà lu » (C6) arrive avec le fil in-app :
les conditions lisent déjà l'état des étapes précédentes.

Tâches de `lyxal_scheduler` déclarées par le seed du module (exécuteur `function`, portée
`installation`, file `default`, permission propre `notification.worker`) :

| Tâche | Cible | Usage |
| :--- | :--- | :--- |
| `notification.run_resume` | `fn::notification_run_resume` | fin d'une attente ou d'un regroupement (`unique_for` 1 j, arguments `{ run, step_key }`) |
| `notification.purge` | `fn::notification_purge` | planification horaire `notification-purge` (cron `0 * * * *`, décalage de 5 min au plus), créée à l'installation du module si elle est absente |

### 1.4. Intégrations et fournisseurs

Une **intégration** dit par quel fournisseur part un canal (`email` ; les canaux du lot 4
s'ajoutent) pour une organisation, ou pour l'installation (repli de toutes les organisations).

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
  pour un relais sans authentification) ; Brevo, Mailgun, Postmark, Resend `{ api_key }`. Secret
  des retours : Mailgun `{ signing_key }`, Resend `{ signing_secret }` (`whsec_…`), Postmark et
  Brevo `{ username, password }` (authentification Basic réglée chez le fournisseur).
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
* **Essai** (D6) : `POST /api/v1/notification/integrations/{intégration}/test` (`{ to }`, droit de
  gestion) envoie un e-mail d'essai par le vrai fournisseur ; réponse `{ accepted, code }`, sans
  secret ; issue notée sur l'intégration (`last_test`).

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
Intégrations : lecture `notification.read` (jamais de secret), gestion `notification.manage`
(installation : `notification.installation.manage`) **et** droit de lire le secret
(`secrets.value.read` ; installation : `secrets.installation.manage`) ; choix, retours et issue
d'un essai : worker ou session système de l'hôte.

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
| Réglages | `notification_settings_get`, `_set` (`max_wait_days` compris ; expéditeur et adresse de réponse : réglages de l'intégration) |
| Intégrations | `notification_integration_create`, `_update` (champs fournis, réglages remplacés en entier, `clear_condition`, `clear_webhook`), `_get` (par clé ou identifiant), `_list`, `_delete`, `_set_primary`, `_test` (essai : contrôle au nom de l'appelant, D6) ; `_select` (worker : ordre D1 / D3 d'une étape), `_test_record` et `notification_provider_event_record` (hôte) |
| Liste de suppression | `notification_suppression_add`, `_remove`, `_list` |
| Activité | `notification_run_get`, `_list` |
| File d'envoi (worker) | `notification_job_claim` (avec l'intégration de l'envoi), `_renew`, `_release` (`not_before` : fin des heures calmes), `_complete` (`integration`, `provider_message_id`, `response_code`), `_fail` (`integration`) |
| Attentes (worker, planificateur) | `notification_wait_schedule` (paquet de 500 au plus), `notification_run_resume` et `notification_purge` (forme d'appel du planificateur `{ args, run, tenant, scheduled_for, attempt }`) |

Entrées validées et nettoyées par `lyxal_core` ; erreurs `NOTIFICATION_*` (master data
`error/`) ; toute écriture vérifiée (`NOTIFICATION_WRITE_FORBIDDEN`). Conditions d'abonnement
contrôlées à l'enregistrement par `fn::utils_condition_check` (`NOTIFICATION_CONDITION_INVALID`).
Fonctions internes (appelées par les précédentes) : `notification_subscriber_fields`, `_save`,
`_find`, `notification_topic_find`, `notification_category_find`, `notification_channels`,
`notification_preference_key`, `_fields`, `_resolve`, `_write`, `_apply`, `_targets`, `_view`,
`notification_my_subscriber`, `notification_trigger_target`, `_workflow`, `_one`, `_single`,
`notification_run_create` ; parcours à étapes : `notification_duration_seconds`,
`notification_step_fields`, `_check`, `_context`, `_enter`, `notification_override_check`,
`notification_job_add`, `notification_wait_due`, `_end`, `notification_group_key`,
`notification_digest_join`, `_merge`, `notification_throttle_hit`, `notification_run_advance`,
`_finalize` ; intégrations : `notification_integration_find`, `_secret_check`,
`_settings_refusal`, `_refusal` (garde), `_fields`, `_view`, `_checked`, `_clean_settings`,
`_unset_primary`, `_eligible`, `_for_job`, `_payload`.

File d'envoi (étapes de canal seulement) : réservation conditionnelle (une étape n'est réservée qu'une fois ; une
réservation expirée est reprise, sauf après la dernière tentative : échec définitif),
renouvelée juste avant chaque envoi ; étape non commencée rendue à la file à l'arrêt du worker ; étape
dont le secret a expiré annulée, jamais envoyée en retard ; échec temporaire rejoué tant que
`attempts < max_attempts` ; destinataire refusé : échec définitif et adresse supprimée
(`hard_bounce`) ; à la réservation, les préférences sont relues (étape désormais refusée :
écartée) et l'étape porte les heures calmes de l'abonné, la cible de son lien de désabonnement
et le regroupement porté. Une étape terminée (envoyée, écartée, en échec définitif) fait avancer
son déclenchement. Purge (planificateur, toutes les heures) : secrets expirés, journal,
déclenchements terminés, diffusions terminées, regroupements fermés, compteurs expirés et
retours des fournisseurs.

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

Publiés : `notification.run.canceled` (`run_id`, `tenant`, `workflow_id`),
`notification.run.merged` (`run_id`, `digest_id`), `notification.message.sent`,
`notification.message.failed` (étapes de canal),
`notification.address.suppressed` (identifiants, parcours, canal, adresse pour la suppression ;
jamais de contenu ni de secret) ; `notification.subscriber.created`, `.updated` (adresse, nom,
langue, fuseau ou données changés), `.deleted`, `notification.subscriber.unsubscribed` (lien de
désabonnement : catégorie ou parcours, canal), `notification.preference.updated`,
`notification.topic.subscribed`, `.unsubscribed` ; `notification.integration.created`,
`.updated`, `.deleted` (`integration_id`, `tenant`, `channel`) ; `notification.message.delivered`,
`.bounced`, `.complained` (`message_id`, `run_id`, `integration_id`) : identifiants seulement,
jamais l'adresse, le téléphone, le nom, un chemin de secret ni un réglage.

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
* `SecretCodec` : ouverture et rescellement (`CryptoEngine`, contextes non vides).
* `NotificationConsumer` (`EventConsumerModule`) et `AuthMessageHandler` : secret illisible,
  charge utile invalide ou parcours absent → lettre morte ; base indisponible → rejoué.
  `SecurityAlertHandler` : alertes de sécurité vers `auth_security_alert`. `auth_subscriber` :
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
* `EmailProvider` (trait : `send(réglages, EmailMessage, Credentials) -> ProviderReceipt` ou
  `ProviderError`) et `EmailProviders` : `SmtpProvider` (`lettre`, TLS rustls, une connexion par
  envoi ; classement : connexion ou 4xx → `transient`, 550 / 551 / 553 → `recipient_rejected`,
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
  de 256 Kio au plus ; `lyxal_crypto` seulement. Une clé de signature de 32 octets au plus est
  complétée par des zéros, une clé de plus de 64 octets remplacée par son SHA-256 (même HMAC,
  RFC 2104) ; une clé de 33 à 64 octets est refusée (feuille de route).
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
`POST /api/v1/notification/integrations/{intégration}/test`. Liens de désabonnement :
clé applicative et `LYXAL__NOTIFICATION__PUBLIC_URL` ; routes de l'hôte
`GET` / `POST /api/v1/notification/unsubscribe` ; aperçu : `POST /api/v1/notification/preview`
(jeton d'accès, `notification.read`) (`apps/lyxal-server/README.md`). L'hôte installe
`lyxal_scheduler` avant ce module (dépendance du manifeste) et sert la file `default` du
planificateur, qui exécute les reprises et la purge.

## 6. Exploitation

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
* **Panne d'un fournisseur** : une seconde intégration (priorité plus grande) prend le relais à
  la tentative suivante ; `notification_run_get` montre l'intégration de chaque tentative.

* **Réglages** : `max_wait_days` (`fn::notification_settings_set`, organisation ou
  installation) borne toute attente, fenêtre de regroupement ou de limitation, à
  l'enregistrement d'un parcours comme au déclenchement.
* **Attentes en cours** : étapes `delay` / `digest` `queued` (pas encore confiées) ou `waiting`
  (exécution différée `scheduler_run` notée sur l'étape, lisible par `fn::scheduler_run_get`).
  Une exécution refusée par le planificateur (ex. `SCHEDULER_LIMIT_REACHED`, réglage
  `max_pending_runs` de l'installation) laisse l'étape en file : le worker d'étapes la représente
  au passage suivant et journalise les codes.
* **Reprise après panne** : une reprise est idempotente (étape déjà terminée, déclenchement
  annulé ou purgé : rien) ; le planificateur la retente selon la politique de la tâche
  (5 tentatives) ; une attente échue avant d'avoir été confiée est reprise directement par le
  worker d'étapes.
* **Purge** : planification `notification-purge` (pause, déclenchement immédiat et historique par
  les routes `/api/v1/scheduler/*`) ; argument facultatif `limit` (1 000 par catégorie et par
  passage).

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
* `scripts/ci/ci_local.sh`.
