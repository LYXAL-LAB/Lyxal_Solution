# Plan d'implémentation — `lyxal_notification`, lot 3 : intégrations et e-mail par fournisseur

Troisième lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées ; lots 1 et 2 livrés). Ce lot remplace le relais SMTP unique réglé dans
l'hôte par des **intégrations** (un fournisseur par canal, par organisation, avec repli sur
l'installation), range leurs identifiants dans **`lyxal_secrets`** (K4), ajoute l'**e-mail par
API** chez Brevo, Mailgun, Postmark et Resend (K5, client `reqwest` K10) et reçoit les **retours
des fournisseurs** (délivré, rejeté, plainte) avec suppression automatique des adresses rejetées.
Les SMS et messageries (lot 4) se brancheront sur les mêmes intégrations. Aucune ligne de code
avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions du CTO

Décisions D1 à D6 **validées par le CTO** le 16 novembre 2026, telles que proposées ci-dessous.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **D1** | Quelle intégration sert un envoi | Celles de l'organisation pour ce canal, actives et dont la condition (forme K2, sur le parcours, l'abonné et les données) est vraie : la **principale** d'abord, puis par priorité. Si l'organisation n'en a aucune, celles de l'installation, dans le même ordre. Aucune : l'envoi attend en file (sonde « dégradé »). |
| **D2** | Où sont saisis les identifiants | Dans le coffre-fort `lyxal_secrets`, par ses routes existantes, sous le dossier `notification/` de la même portée (organisation ou installation). L'intégration ne garde que le **chemin** du secret, jamais une valeur ; le worker le lit par le chemin tracé (`SecretsClient`, module annoncé). Créer ou modifier une intégration exige, en plus de `notification.manage`, le droit de **lire ce secret** (`secrets.value.read`, ou `secrets.installation.manage` pour l'installation) : sans cela, un gestionnaire des notifications pourrait faire envoyer un secret vers un serveur de son choix. |
| **D3** | Panne d'un fournisseur | Un échec temporaire (réseau, 429, 5xx) fait passer la tentative suivante à l'intégration éligible **suivante** (bascule), puis revient à la première au tour suivant. Un refus définitif (adresse rejetée, message refusé) ne bascule pas. L'intégration utilisée est notée sur le message. |
| **D4** | Retours des fournisseurs | Une adresse de l'hôte par intégration (`POST /api/v1/notification/webhooks/{intégration}`), sans session. Vérification propre à chaque fournisseur, par `lyxal_crypto` : **Mailgun** (HMAC-SHA256 de l'horodatage et du jeton), **Resend** (signature HMAC-SHA256 de l'en-tête `svix`), **Postmark** et **Brevo** (identifiants d'authentification du webhook comparés en temps constant). Horodatage à moins de 5 minutes quand le fournisseur en donne un ; événements dédoublonnés. Retenus : délivré, rejet définitif, rejet temporaire, plainte. Rejet définitif et plainte ajoutent l'adresse à la liste de suppression (existante). Ouvertures et clics : ignorés (V2). |
| **D5** | Fin du réglage SMTP de l'hôte (K4) | `LYXAL__NOTIFICATION__SMTP__*` disparaît sans repli. Une installation neuve n'envoie aucun e-mail tant qu'un administrateur de la plateforme n'a pas créé l'intégration de l'installation (le README d'exploitation donne la marche à suivre). Les e-mails déclenchés entre-temps attendent en file. |
| **D6** | Essai d'une intégration | `notification_integration_test` envoie un e-mail d'essai à une adresse donnée par la personne (droit de gestion), avec le vrai fournisseur ; le résultat (accepté ou code d'erreur) est rendu sans aucun secret. |

## 2. Modèle (SurrealQL, réécrit en place)

| Table | Contenu |
| :--- | :--- |
| `notification_integration` (nouvelle) | portée (organisation ou installation), clé unique dans la portée, canal (`email` ; les canaux du lot 4 s'ajoutent), fournisseur (`smtp`, `brevo`, `mailgun`, `postmark`, `resend`), nom, active, principale (une au plus par portée et canal), priorité, condition facultative (K2), réglages non secrets (expéditeur, nom, adresse de réponse ; SMTP : hôte, port, sécurité ; Mailgun : domaine, région `us` / `eu`), chemin du secret des identifiants, chemin facultatif du secret des retours, état du dernier essai |
| `notification_provider_event` (nouvelle) | retour normalisé : intégration, identifiant de l'événement chez le fournisseur (unique par intégration), type (`delivered`, `bounced`, `soft_bounced`, `complained`), message lié, adresse (pour la suppression), date, purge selon `retention_days_log` ; aucun corps |
| `notification_message` | + `integration`, `provider`, `provider_message_id` (unique par intégration), `status` (`sent`, `delivered`, `bounced`, `complained`) |
| `notification_job` | + `integration` de la dernière tentative (bascule D3) |
| `notification_settings` | `from_name` / `reply_to` passent sur l'intégration ; réglages restants inchangés |

Identifiants rangés dans le coffre (JSON) : SMTP `{ username, password }` ; Brevo, Postmark, Resend
`{ api_key }` ; Mailgun `{ api_key }`. Secret des retours : Mailgun `{ signing_key }`, Resend
`{ signing_secret }`, Postmark et Brevo `{ username, password }` (authentification du webhook).

## 3. Fonctions publiques (`fn::notification_*($params: object)`)

| Fonction | Rôle | Permission |
| :--- | :--- | :--- |
| `notification_integration_create`, `_update` | réglages contrôlés par `lyxal_core` (hôte, port, adresses, domaine) ; chemin du secret sous `notification/`, existence et droit de lecture vérifiés par les contrats de `lyxal_secrets` (D2) ; une seule principale | `notification.manage` + lecture du secret ; installation : `notification.installation.manage` + `secrets.installation.manage` |
| `notification_integration_get`, `_list` | sans aucun secret | `notification.read` |
| `notification_integration_delete` | permise même pour la dernière intégration (la sonde passe alors à « dégradé ») ; le secret du coffre n'est pas touché | `notification.manage` |
| `notification_integration_set_primary` | principale de la portée pour un canal | `notification.manage` |
| `notification_integration_select` (worker) | intégrations éligibles d'une étape, dans l'ordre D1 / D3 | `notification.worker` |
| `notification_provider_event_record` (hôte) | retour vérifié par l'hôte : dédoublonné, message mis à jour, suppression si rejet définitif ou plainte | session système de l'hôte |
| `notification_job_complete`, `_fail` (étendues) | + intégration, identifiant du message chez le fournisseur | `notification.worker` |

`notification_job_claim` rend désormais l'intégration retenue (fournisseur, réglages, chemins des
secrets) avec chaque étape réservée.

## 4. Erreurs (master data `error/integrations/`)

`NOTIFICATION_INTEGRATION_NOT_FOUND`, `NOTIFICATION_INTEGRATION_KEY_TAKEN`,
`NOTIFICATION_INTEGRATION_SECRET_INVALID` (chemin hors `notification/`, secret absent ou illisible
pour la personne), `NOTIFICATION_INTEGRATION_UNAVAILABLE` (aucune intégration pour l'envoi),
`NOTIFICATION_PROVIDER_REJECTED` (refus définitif du fournisseur), `NOTIFICATION_PROVIDER_UNAVAILABLE`
(échec temporaire), `NOTIFICATION_WEBHOOK_INVALID` (signature, horodatage ou corps refusé).

## 5. Événements (identifiants seulement)

`notification.integration.created` / `updated` / `deleted`, `notification.message.delivered`,
`notification.message.bounced`, `notification.message.complained` (`message_id`, `run_id`,
`integration_id`, jamais l'adresse).

## 6. Rust et hôte

* `EmailProvider` (trait) : `send(&EmailMessage, &Credentials) -> Result<ProviderReceipt,
  ProviderError>` ; implémentations `SmtpProvider` (l'actuel `SmtpTransport`, identifiants lus du
  coffre), `BrevoProvider`, `MailgunProvider`, `PostmarkProvider`, `ResendProvider` (API HTTP,
  en-têtes `List-Unsubscribe` transmis). Classement des réponses : 2xx accepté ; 400, 401, 403,
  422 définitif ; 429, 5xx, réseau temporaire.
* `reqwest` (K10) avec `rustls` : délai borné (10 s), **aucune redirection**, réponse lue sur
  64 Kio au plus ; adresses des API fixes dans le code (aucune adresse saisie par une personne,
  donc pas de risque SSRF ici) ; un constructeur réservé aux tests pointe vers les faux
  fournisseurs locaux.
* `ProviderWebhook` : vérification et lecture des retours par fournisseur (§1 D4) avec
  `lyxal_crypto::hmac` ; corps borné à 256 Kio.
* Worker e-mail : intégration de l'étape, identifiants lus par `SecretsClient` (gardés en
  `SecretBytes`, jamais journalisés), envoi, fin avec intégration et identifiant du message ;
  bascule D3.
* Hôte : `LYXAL__NOTIFICATION__SMTP__*` retiré (`NotificationConfig` ne garde que `public_url`) ;
  routes `POST /api/v1/notification/webhooks/{integration}` (sans session, réponses sans
  détail) et `POST /api/v1/notification/integrations/{integration}/test` (session, D6) ; sonde
  « dégradé » sans intégration e-mail active pour l'installation.
* Dépendances : `lyxal_secrets` (manifeste et Cargo du module), `reqwest` (K10).

## 7. Tests

* Banc SurrealQL : intégrations (création, contrôles, chemin du secret et droit de lecture D2,
  principale unique, suppression), choix D1 (organisation, repli, condition, priorité), bascule
  D3, retours (dédoublonnage, mise à jour du message, suppression sur rejet et plainte, retour
  inconnu), droits (organisation, installation, autre organisation, sans droit).
* Rust : chaque fournisseur contre un faux fournisseur local (requête attendue, en-têtes, réponse
  acceptée, refus définitif, 429 et 5xx temporaires, aucune redirection suivie, réponse trop
  grande) ; vérification des retours (signature valide, fausse, horodatage trop ancien, rejeu) ;
  de bout en bout : déclenchement → intégration de l'organisation → faux fournisseur → retour
  « rejeté » → adresse supprimée ; bascule vers la seconde intégration après une panne ;
  identifiants lus du coffre, jamais dans les journaux.
* Hôte : route des retours (signature, corps trop grand, intégration inconnue), route d'essai
  (droits), démarrage sans réglage SMTP.
* `scripts/ci/ci_local.sh` vert ; aucun appel réel à un fournisseur en CI.

## 8. Documents

`README.md` du module (intégrations, fournisseurs, retours, exploitation : créer l'intégration de
l'installation, régler les webhooks chez chaque fournisseur), `ROADMAP.md` (V1-d mise à jour),
README de l'hôte (réglage SMTP retiré, nouvelles routes). Ce plan est supprimé une fois exécuté.

## 9. Checklist (§13)

* `lyxal_core` : `fn::validation_object_execute` (e-mail, hôte, port, domaine, chemin),
  `fn::utils_condition_check` / `_evaluate` ; aucune primitive nouvelle.
* `lyxal_crypto` : HMAC-SHA256 et comparaison en temps constant existants ; aucune extension
  dans ce lot (HMAC-SHA1 de Twilio : lot 4, K8).
* `lyxal_secrets` : contrats publics seulement (`SecretsClient`, fonctions de lecture des fiches) ;
  aucune valeur en base du module ni dans les journaux.
* Écritures vérifiées, seeds rejouables, une seule migration, versions `0.y.z`, aucun code mort
  (réglage SMTP de l'hôte et `SmtpConfig` retirés).
