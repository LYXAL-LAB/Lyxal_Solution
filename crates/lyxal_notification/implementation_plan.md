# Plan d'implémentation — `lyxal_notification`, lot 4 : SMS, messageries et adresse web

Quatrième lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées ; lots 1 à 3 livrés). Ce lot ajoute trois canaux sur les
intégrations du lot 3 : le **SMS** (Brevo, Twilio, Vonage — K5), les **messageries d'équipe**
(Slack, Microsoft Teams, Discord, Mattermost, Google Chat, Telegram) et l'**appel signé d'une
adresse web** (K7). Les retours de livraison des SMS sont reçus comme ceux de l'e-mail. Aucune
ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **E1** | Où vont les messages de chaque canal | **SMS** : le téléphone de l'abonné (E.164, lot 1). **Messagerie** et **adresse web** : des **adresses par canal** de l'abonné (`notification_endpoint`) — par exemple le salon Slack d'une équipe, ou l'adresse web du logiciel d'un client. Un abonné peut en avoir plusieurs ; une étape les sert toutes. |
| **E2** | Protection des adresses de messagerie et web | Une adresse de webhook Slack, Teams, Discord ou Google Chat donne à elle seule le droit d'écrire dans le salon : c'est un secret. Elle est **scellée** (`enc:v2`, `lyxal_crypto`, contexte lié à l'organisation et à l'adresse) et seul le worker l'ouvre ; la personne ne la relit jamais, elle voit seulement l'hôte. Telegram : le jeton du robot est le secret de l'intégration (`lyxal_secrets`), l'adresse ne porte que l'identifiant du salon. |
| **E3** | Sécurité des appels sortants (K7, risque SSRF) | Pour la messagerie et l'adresse web : **HTTPS seulement** ; nom résolu à **chaque envoi** et refus des adresses privées, locales, de lien local, de multidiffusion, partagées (100.64/10) et de la plateforme, en IPv4 et IPv6 ; connexion faite à l'adresse vérifiée (pas de second résolution, pas de « rebinding ») ; **aucune redirection** ; délai 10 s ; réponse lue sur 64 Kio au plus. Liste d'hôtes autorisés réglable par l'installation (vide : tout hôte public). Slack, Teams, Discord, Google Chat et Telegram : hôtes officiels seulement ; Mattermost (auto-hébergé) : tout hôte public. |
| **E4** | Signature de l'appel d'une adresse web | Corps JSON (`{ id, type, workflow, step, run, subscriber_id, payload, text, sent_at }`, jamais de secret du déclenchement) signé HMAC-SHA256 avec horodatage : en-tête `Lyxal-Signature: t=<secondes>,v1=<hex>` sur `<t>.<corps>`, plus `Lyxal-Delivery: <id>` pour le dédoublonnage chez le destinataire. Clé de signature tirée par `lyxal_crypto` à la création de l'adresse, montrée **une seule fois**, puis scellée ; renouvelable. Réponse 2xx : livré ; 4xx (sauf 408 et 429) : refus définitif ; sinon nouvel essai. |
| **E5** | Texte des canaux | Le gabarit d'une étape SMS, messagerie ou adresse web n'a que l'objet (titre, facultatif) et le **texte** (avec les clés `lyxal_i18n` comme l'e-mail). SMS : longueur comptée (GSM-7 : 160 / 153 par partie ; sinon UCS-2 : 70 / 67), **10 parties au plus**, refus à l'enregistrement et au rendu au-delà. Messagerie : texte simple, Markdown du service laissé tel quel. |
| **E6** | Retours des SMS | Adresse de retour par intégration comme l'e-mail. **Twilio** : signature `X-Twilio-Signature` (HMAC-SHA1, extension de `lyxal_crypto` validée par K8 : vérification seulement) ; **Vonage** : signature HMAC-SHA256 du corps avec le secret de signature (`ExternalHmacKey`) ; **Brevo** : authentification Basic. Numéro invalide ou inexistant : liste de suppression (canal `sms`, rejet définitif) ; destinataire désinscrit chez l'opérateur (STOP) : suppression (plainte). Messageries et adresse web : pas de retours (l'issue est connue à l'appel). |
| **E7** | Préférences et heures calmes | Les choix par canal du lot 1 (`sms`, `chat`, `webhook`) s'appliquent ; heures calmes pour le SMS et la messagerie, pas pour l'adresse web (appel de machine à machine). |

## 2. Modèle (SurrealQL, réécrit en place)

| Table | Changement |
| :--- | :--- |
| `notification_endpoint` (nouvelle) | adresse d'un abonné pour un canal : abonné, portée, canal (`chat`, `webhook`), fournisseur (`slack`, `teams`, `discord`, `mattermost`, `google_chat`, `telegram` ; `webhook` pour l'adresse web), nom, hôte (lisible), adresse scellée (`enc:v2`, lisible par le worker seulement), identifiant de salon Telegram, clé de signature scellée (adresse web), active, dernier résultat ; supprimée avec l'abonné et l'organisation |
| `notification_integration` | canaux `sms`, `chat`, `webhook` ; fournisseurs SMS `brevo`, `twilio`, `vonage` (expéditeur : numéro ou nom court), messagerie (`telegram` porte le jeton du robot ; les autres n'ont pas d'identifiant), `webhook` (aucun identifiant ; une intégration par portée active le canal) |
| `notification_workflow.steps` | types `sms`, `chat`, `webhook` |
| `notification_template` | texte seul autorisé pour les nouveaux canaux (E5) |
| `notification_message` | `to` : téléphone ou hôte de l'adresse (jamais l'adresse complète) ; `endpoint` lié ; nombre de parties (SMS) |
| `notification_suppression` | canal `sms` (numéro E.164) en plus de `email` |
| `notification_settings` | `allowed_hosts` (installation seulement, E3) |

## 3. Fonctions publiques (`fn::notification_*($params: object)`)

| Fonction | Rôle | Permission |
| :--- | :--- | :--- |
| `notification_endpoint_create` | adresse contrôlée par `lyxal_core` (URL HTTPS, hôte du fournisseur, identifiant Telegram) ; scellement par l'hôte avant l'appel (la valeur n'entre en base que scellée) ; clé de signature rendue une fois pour une adresse web | `notification.manage` |
| `notification_endpoint_update`, `_delete`, `_list` (sans adresse), `_rotate_secret` (adresse web) | | `notification.manage` / `read` |
| `notification_my_endpoint_*` | la personne connectée gère ses propres adresses (comme ses préférences) | session `lyxal_auth` |
| `notification_template_create` / `_update` (étendues) | contrôle E5 (texte seul, longueur SMS) | `notification.manage` |
| `notification_job_claim` (étendue) | étapes SMS, messagerie, adresse web : intégration, adresses scellées de l'abonné | `notification.worker` |

Les fonctions d'intégration, de retours et d'essai du lot 3 couvrent les nouveaux fournisseurs
(réglages contrôlés par fournisseur).

## 4. Erreurs (`error/canaux/`)

`NOTIFICATION_ENDPOINT_NOT_FOUND`, `NOTIFICATION_ENDPOINT_INVALID` (adresse, hôte refusé),
`NOTIFICATION_DESTINATION_FORBIDDEN` (adresse résolue privée ou hors liste, à l'envoi),
`NOTIFICATION_SMS_TOO_LONG`, `NOTIFICATION_SUBSCRIBER_NO_PHONE`.

## 5. Événements (identifiants seulement)

`notification.endpoint.created` / `updated` / `deleted` ; `notification.message.delivered` /
`bounced` pour les SMS (existants).

## 6. Rust et hôte

* `lyxal_crypto` (K8, vérification seulement) : `verify_external_hmac_sha1(&ExternalHmacKey,
  data, tag)` pour Twilio, par `ring`, en temps constant ; contrat de l'API et règles mis à jour.
* `SmsProvider` (Brevo, Twilio, Vonage), `ChatProvider` (six services), `WebhookCaller` :
  client `reqwest` du lot 3 avec un **résolveur contrôlé** (E3) qui vérifie chaque adresse
  résolue et fixe la connexion sur elle ; adresses officielles des API en constantes.
* `SmsSegments` : comptage GSM-7 / UCS-2 (E5).
* Workers : un par canal (`sms`, `chat`, `webhook`), comme l'e-mail ; adresses ouvertes en
  mémoire (`SecretString`) le temps de l'appel, jamais journalisées.
* Hôte : scellement des adresses à la création (routes `POST /api/v1/notification/endpoints`
  et `/api/v1/notification/my/endpoints`) ; retours SMS sur la route des retours du lot 3.

## 7. Tests

* Banc SurrealQL : adresses (création, contrôles, scellement exigé, lecture sans adresse,
  droits, adresses de la personne), gabarits SMS (longueurs), choix de l'intégration par canal,
  préférences et heures calmes par canal, suppression d'un numéro.
* Rust : chaque fournisseur contre un faux service local ; contrôle SSRF (adresses privées v4 et
  v6, nom qui se résout en adresse privée, redirection refusée, liste d'hôtes, HTTPS exigé) avec
  un résolveur de test ; signature d'un appel web vérifiable par un destinataire ; Twilio
  (signature valide, fausse) ; comptage des parties SMS ; de bout en bout : déclenchement →
  SMS + messagerie + adresse web.
* Hôte : routes des adresses (droits, valeur jamais relue), retours SMS.
* `scripts/ci/ci_local.sh` vert ; **essais réels** de chaque fournisseur ajoutés à la liste de
  `ROADMAP.md` (« Essais réels à faire »).

## 8. Documents

`README.md` (canaux, adresses, sécurité des appels, exploitation), `ROADMAP.md` (V1-e mise à
jour, essais réels des nouveaux fournisseurs), README de l'hôte, contrat de `lyxal_crypto`. Ce
plan est supprimé une fois exécuté.

## 9. Checklist (§13)

* `lyxal_core` pour toutes les entrées (URL, E.164, longueurs) ; aucune primitive nouvelle.
* `lyxal_crypto` : `CryptoEngine::seal` / `open` (adresses), `HmacKey::generate` et
  `sign_hmac_sha256` (signature des appels web), `ExternalHmacKey` (Vonage), HMAC-SHA1 en
  vérification seulement (Twilio, K8).
* Aucune adresse ni clé en clair en base, dans un événement ou dans les journaux ; écritures
  vérifiées ; une seule migration ; versions `0.y.z`.
