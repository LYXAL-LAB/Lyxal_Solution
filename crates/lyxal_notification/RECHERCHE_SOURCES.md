# `lyxal_notification` — recherche de sources open source

Document de travail préalable au plan d'implémentation de `lyxal_notification` (crate du Noyau
Technique, rang 6 de [`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md)).
Le crate n'existe pas encore : ce dossier ne contient que ce document. Aucun code ne sera écrit
avant un `implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3). Ce document est
retiré, ou réduit aux sources retenues, quand le crate est créé.

Recherche du 8 novembre 2026. Licences vérifiées sur le fichier `LICENSE` de chaque dépôt cloné.

## 1. Besoin

Décision du CTO (D8 du plan `lyxal_auth`) : **la partie e-mail est réalisée avant le lot 3 de
`lyxal_auth`** (invitations, vérification d'adresse, récupération, codes de connexion). Même
méthode que `lyxal_auth` : on reprend le modèle de données et les fonctionnalités de projets mûrs,
transcrits en SurrealDB multi-modèle et en Rust, sans déployer de produit à côté de Lyxal.

| Besoin | Détail |
| :--- | :--- |
| Canaux | e-mail SMTP d'abord ; ensuite SMS, push web et mobile, webhook, fil in-app, Slack / Teams |
| Gabarits | par canal et par langue, mise en page commune, variables vérifiées |
| Destinataires | abonnés, sujets (listes), préférences et désabonnement par catégorie |
| Parcours | étapes, délais, regroupement (digest), conditions, limitation de débit |
| Livraison | file d'envoi, tentatives avec attente croissante, statuts (envoyé, délivré, ouvert, rejeté, plainte), liste de suppression |
| Garanties | idempotence, multi-locataire, déclenchement par `lyxal_event`, identifiants des fournisseurs par `lyxal_secrets` |

## 2. Sources évaluées

| Projet | Langage | Licence (fichier lu) | Usage proposé |
| :--- | :--- | :--- | :--- |
| [Novu](https://github.com/novuhq/novu) | TypeScript | **MIT** hors `enterprise/packages/` (propriétaire) | **Modèle principal** : abonnés, sujets, workflows en étapes, préférences à plusieurs niveaux, intégrations multicanal, file d'étapes, messages, journal. Rien n'est repris de `enterprise/` (dont la traduction) |
| [Postal](https://github.com/postalserver/postal) | Ruby | **MIT** (`MIT-LICENCE`) | **Modèle e-mail** : file verrouillée (`queued_messages`), tentatives de livraison, liste de suppression |
| [Apprise](https://github.com/caronc/apprise) | Python | **BSD-2-Clause** | **Catalogue des connecteurs** (≈ 180) et configuration des canaux par URL, pour les canaux suivants |
| [ntfy](https://github.com/binwiederhier/ntfy) | Go | Apache-2.0 ou GPLv2 au choix | Référence secondaire (push web, sujets), sous l'option Apache-2.0 |
| [Notifuse](https://github.com/Notifuse/notifuse) | Go | **BSL 1.1** (AGPL jusqu'à la v39) | Conception seulement : file e-mail, historique par statut, classification des rejets |
| listmonk, Keila, Plunk, Hyvor Relay | Go, Elixir, TS, PHP | **AGPL-3.0** | Écartés comme source de code |
| Mautic | PHP | GPL-3.0 | Écarté |
| Stalwart Mail Server | Rust | AGPL-3.0 + licence propriétaire | Référence de conception seulement |
| Courier, Knock | — | services en ligne, pas de serveur open source | Écartés |

### Briques Rust (dépendances)

| Brique | Bibliothèque | Licence | Usage |
| :--- | :--- | :--- | :--- |
| Envoi SMTP | `lettre` 0.11 | MIT | **Dépendance** : `tokio1-rustls`, `pool`, `builder`, `smtp-transport`, sans les options par défaut (`native-tls`). Option `dkim` exclue (crypto hors `lyxal_crypto`) |
| Gabarits | `minijinja` 3 | Apache-2.0 | **Dépendance** : bac à sable, variable inconnue = erreur, échappement HTML automatique |
| Mise en page e-mail | `mrml` 6 (MJML) | MIT | **Option** |
| Push web, APNs, FCM | `web-push`, `a2`, `fcm` | Apache-2.0 / MIT | Plus tard ; leur cryptographie asymétrique est **soumise au CTO** (§11.3) |

Alternative SMTP : `mail-send` / `mail-builder` (Stalwart, Apache-2.0 ou MIT).

## 3. Correspondance préliminaire Novu → SurrealDB

Entités lues dans `libs/dal/src/repositories/*/*.entity.ts` (Novu). Organisation et environnement
Novu deviennent le locataire Lyxal (organisation de `lyxal_auth`).

| Novu | Table Lyxal | Type SurrealDB |
| :--- | :--- | :--- |
| `subscriber` | `notification_subscriber` (préférence globale en objet imbriqué) | document |
| `channel-endpoint` | `notification_endpoint` (abonné → intégration : adresse, jeton d'appareil) | **relation** `ENFORCED` |
| `topic` | `notification_topic` | document |
| `topic-subscribers` | `notification_topic_member` (abonné → sujet) | **relation** `ENFORCED`, unique (`in`, `out`) |
| `notification-group` | `notification_category` (catégorie de désabonnement) | document |
| `notification-template` (workflow) | `notification_workflow`, étapes en objets imbriqués ordonnés (`email`, `sms`, `push`, `chat`, `in_app`, `digest`, `delay`, `throttle`, `http_request`) ; déclencheur = type d'événement `lyxal_event` | document |
| `message-template`, `layout` | `notification_template`, `notification_template_locale`, `notification_layout` | document |
| `integration` | `notification_integration` (`credentials` = référence `lyxal_secrets`, jamais une valeur) | document |
| `preferences` | `notification_preference` (abonné → workflow, catégorie ou sujet) | **relation** `ENFORCED` |
| `notification` | `notification_run` (un déclenchement ; `transaction_id` unique = idempotence) | document |
| `job` | `notification_job` (une étape : statut, tentatives, `next_retry_at`, `locked_until`) | document |
| `message` | `notification_message` (envoi par canal, fil in-app, une date par statut) | document |
| `execution-details` | `notification_delivery_log` (journal en ajout seul) | document |
| statuts e-mail des fournisseurs | `notification_provider_event` (retours par webhook ou DSN) | document |
| Postal `suppressions` | `notification_suppression` (rejet définitif, plainte, désabonnement) | document |
| étape `throttle` | `notification_rate_limit` | document |

Différences voulues avec Novu : identifiants des fournisseurs scellés par `lyxal_crypto` (Novu :
AES-256-CBC maison), idempotence par index unique SurrealDB (Novu : cache Redis 24 h).

## 4. Périmètre « e-mail d'abord » (avant le lot 3 de `lyxal_auth`)

* Événements consommés : invitation, vérification d'adresse, récupération, code de connexion
  (`auth.*`), par `EventConsumerModule` et handlers idempotents (`event_id`).
* Tables : `notification_integration` (SMTP), `notification_workflow` (une étape e-mail,
  `critical` ignore les préférences), `notification_template` et `_locale`, `notification_run`,
  `notification_job`, `notification_message`, `notification_delivery_log`,
  `notification_suppression`, `notification_rate_limit`. Abonnés, sujets, préférences, digest,
  délais et autres canaux viennent ensuite.
* Rust : `LyxalWorker` d'envoi sous bail (`lettre`, TLS rustls, attente croissante, 4xx
  temporaire / 5xx définitif), rendu MiniJinja HTML + texte, sonde de santé SMTP.
* Sécurité : un corps contenant un code ou un lien n'est jamais stocké ni journalisé en clair.

## 5. Questions pour le plan

1. ~~Projets de départ~~ : **tranché** par le CTO : Novu, Postal et Apprise ; les fonctionnalités
   de la version payante de Novu sont aussi reprises (reconçues, aucun code repris). Inventaire
   complet et lots : [`MODELE_SOURCES.md`](MODELE_SOURCES.md).
Les questions 2 à 8 sont tranchées par le CTO (décisions N1 à N7 du
[plan du lot V1-a](implementation_plan.md)).
