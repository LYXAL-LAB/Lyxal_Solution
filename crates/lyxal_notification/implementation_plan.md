# Plan d'implémentation — `lyxal_notification`, lot 5 : fil dans l'application

Cinquième lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées ; lots 1 à 4 livrés). Ce lot ajoute le canal **in-app** : le fil de
notifications que chaque personne voit dans l'application (la « cloche »), avec ses états (vu,
lu, archivé, en sommeil), ses compteurs, ses boutons d'action, ses onglets et le **temps réel**
par un flux de `lyxal-server` (K6). Il fournit aussi aux conditions d'étape la valeur « lu »
d'un message du fil (« sauter si déjà lu », décision C6). Les écrans eux-mêmes relèvent de la
console (V2). Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions du CTO

Décisions F1 à F8 **validées par le CTO** le 17 novembre 2026, telles que proposées ci-dessous.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **F1** | Où vivent les messages du fil | Une table dédiée, `notification_inbox`, plutôt que d'étendre `notification_message` comme le prévoyait le programme : ses droits sont différents (la personne lit et modifie **son** fil ; le journal des envois reste aux gestionnaires), elle a ses propres index (abonné, états) et sa propre durée de conservation. `notification_message` garde la trace de l'envoi (canal `in_app`) sans contenu. |
| **F2** | Qui lit un fil | **Seulement la personne elle-même**, avec sa session `lyxal_auth`, pour son abonné `auth:<identité>` dans son organisation active. Un gestionnaire ne lit pas le fil d'autrui (données personnelles) ; il voit l'envoi dans le journal (`notification_run_get`). Un abonné sans compte (invité `email:…`) n'a pas de fil : l'étape in-app est écartée (`no_address:in_app`). |
| **F3** | Contenu d'un message du fil | Rendu au moment de l'envoi depuis le gabarit de l'étape (clés `lyxal_i18n`, langue de la personne) : titre, texte (Markdown simple affiché tel quel par la console), avatar facultatif (l'auteur de l'action), lien de redirection (chemin de l'application ou adresse HTTPS), jusqu'à deux boutons (principal, secondaire : libellé et lien), objet `data` libre (8 Kio). Jamais de secret du déclenchement : une étape in-app d'un parcours `sensitive` est refusée à l'enregistrement. |
| **F4** | États et actions | Vu (à l'ouverture de la cloche), lu, archivé, supprimé (définitivement), mis en sommeil jusqu'à une date (3 minutes à 90 jours ; il réapparaît seul à l'échéance, comme non lu). Actions groupées : tout marquer vu, tout marquer lu, archiver tous les lus, tout supprimer (par onglet). Boutons : état « fait » ou « annulé » enregistré sur le message. |
| **F5** | Compteurs et onglets | Compteurs non vus, non lus, total, calculés à la demande (pas de compteur stocké qui pourrait dériver). Onglets = filtres passés à la lecture : étiquettes du parcours, **gravité** (nouveau champ du parcours : `high`, `medium`, `low`, `none`), clés de `data`, archivés. |
| **F6** | Temps réel (K6) | Flux SSE `GET /api/v1/notification/feed/stream` ouvert avec la session `lyxal_auth`. L'hôte tient **une** requête `LIVE SELECT` sur `notification_inbox` (session système) et ne transmet à chaque connexion que les messages de **son** abonné : événements `notification` (nouveau message), `counts` (non vus, non lus) à chaque changement, et toutes les minutes pour les réveils de sommeil. 5 connexions au plus par personne, signe de vie toutes les 25 s, fermeture à l'expiration de la session. Le navigateur ne parle jamais à SurrealDB. |
| **F7** | « Sauter si déjà lu » (C6) | Le contexte des conditions d'étape expose, pour une étape in-app passée, `steps.<clé>.seen` et `steps.<clé>.read`. Ex. : un e-mail 6 h plus tard seulement si le message du fil n'est pas lu (`{ field: "steps.fil.read", op: "eq", value: false }`). |
| **F8** | Conservation | Réglage `retention_days_inbox` (90 jours par défaut, 1 à 365) ; purge par la planification `notification-purge` existante. Pas d'heures calmes pour le fil (décision B5). |

## 2. Modèle (SurrealQL, réécrit en place)

| Table | Changement |
| :--- | :--- |
| `notification_inbox` (nouvelle) | message du fil : portée, abonné, identité (pour les droits), déclenchement et étape d'origine, parcours, étiquettes et gravité copiées du parcours, titre, texte, avatar, lien, boutons `[{ kind: primary / secondary, label, url, status: pending / done / reverted }]`, `data`, `seen_at`, `read_at`, `archived_at`, `snoozed_until`, `created_at`, `purge_after` ; index (abonné, archivé, lu), (abonné, créé) |
| `notification_workflow` | + `severity` ; type d'étape `in_app` |
| `notification_template` | champs in-app : `avatar`, `redirect`, `actions` (deux au plus), `data` (gabarits MiniJinja) |
| `notification_message` | canal `in_app` (trace d'envoi, `to` : l'abonné) |
| `notification_settings` | + `retention_days_inbox` |

Permissions de `notification_inbox` : lecture et modification **par la personne seulement**
(identité de la session = identité de l'abonné, organisation active), création par le worker,
suppression par la personne ou la purge ; champs de contenu `READONLY` (seuls les états et
l'état des boutons changent).

## 3. Fonctions publiques (`fn::notification_*($params: object)`)

| Fonction | Rôle | Accès |
| :--- | :--- | :--- |
| `notification_feed_list` | fil de la personne, paginé (curseur), filtres d'onglet (F5), sans les messages en sommeil | session de la personne |
| `notification_feed_counts` | non vus, non lus, total, par filtre | session de la personne |
| `notification_feed_mark` | `{ ids \| all, filter, state: seen, read, unread, archived, unarchived }` | session de la personne |
| `notification_feed_snooze` / `_unsnooze` | sommeil 3 min à 90 j | session de la personne |
| `notification_feed_delete` | un message, ou tous ceux d'un filtre | session de la personne |
| `notification_feed_action` | `{ id, action: primary / secondary, status: done / reverted }` | session de la personne |
| `notification_inbox_deliver` (worker) | écrit le message rendu, trace d'envoi, avance le déclenchement | `notification.worker` |
| `notification_settings_set` (étendue) | + `retention_days_inbox` | `notification.manage` |
| `notification_workflow_create` / `_update` (étendues) | `severity`, étape `in_app` (refusée pour un parcours `sensitive`) | `notification.manage` |

## 4. Erreurs (`error/fil/`)

`NOTIFICATION_FEED_ITEM_NOT_FOUND` (message absent ou d'une autre personne : même réponse),
`NOTIFICATION_FEED_ACTION_INVALID` (bouton absent), `NOTIFICATION_SNOOZE_INVALID` (durée hors
bornes), `NOTIFICATION_FEED_NO_ACCOUNT` (session sans compte ou sans abonné).

## 5. Événements (identifiants seulement)

`notification.inbox.delivered` (`item_id`, `subscriber_id`, `workflow_id`) ;
`notification.inbox.action` (`item_id`, `action`, `status`) — utile à un module métier qui
réagit au bouton « Valider le devis ». Jamais le titre ni le texte.

## 6. Rust et hôte

* `NotificationChannelWorker` pour le canal `in_app` (sans fournisseur ni intégration) : rendu
  du titre, du texte, des liens et des boutons (MiniJinja, échappement), puis
  `notification_inbox_deliver`.
* `FeedHub` (hôte) : une requête `LIVE SELECT` (session système), relancée après une coupure ;
  répartition en mémoire vers les connexions SSE de chaque abonné ; compteurs relus par
  `notification_feed_counts` au nom de la personne. Tâche supervisée par un `LyxalWorker`, pas de
  tâche libre.
* Routes de l'hôte : `GET /api/v1/notification/feed/stream` (SSE) et, pour les clients qui ne
  parlent pas SurrealQL, `GET /feed`, `GET /feed/counts`, `POST /feed/mark`, `/feed/snooze`,
  `/feed/delete`, `/feed/{id}/action` (même contrôle que les fonctions).
* Contexte des conditions : `seen` / `read` des étapes in-app (F7).

## 7. Tests

* Banc SurrealQL : livraison (abonné avec compte, invité écarté, parcours sensible refusé),
  lecture par la personne seule (autre personne, autre organisation, gestionnaire : rien),
  états et actions groupées, sommeil (bornes, réapparition à l'échéance), compteurs et onglets
  (étiquettes, gravité, `data`), boutons, suppression, conservation et purge, « sauter si déjà
  lu » (lu : étape suivante écartée ; non lu : envoyée), événements.
* Rust : rendu in-app (échappement, liens, boutons) ; de bout en bout : déclenchement → message du
  fil → événement SSE reçu par la bonne personne seulement ; compteurs poussés après « lu » ;
  limite de connexions ; fermeture à l'expiration de la session ; reprise après coupure de la
  requête `LIVE`. Aucun test lié à une fenêtre de temps réelle (horloge et délais injectés).
* `scripts/ci/ci_local.sh` vert. Essai réel : aucun fournisseur ; essai manuel du flux depuis un
  navigateur ajouté à la liste « Essais réels à faire ».

## 8. Documents

`README.md` (fil, droits, temps réel, exploitation), `ROADMAP.md` (V1-d retirée ; composants
d'interface en V2), README de l'hôte (routes du fil et du flux). Ce plan est supprimé une fois
exécuté.

## 9. Checklist (§13)

* `lyxal_core` pour toutes les entrées (durées, liens, filtres, `data`) ; aucune primitive nouvelle ;
  aucun besoin cryptographique.
* `lyxal_auth` : contrats publics seulement (`fn::auth_context`, session de la personne).
* Écritures vérifiées ; une seule migration ; versions `0.y.z` ; aucune donnée personnelle dans
  un événement.
