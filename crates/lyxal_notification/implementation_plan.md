# Plan d'implémentation — `lyxal_notification`, lot 1 : destinataires et préférences

Premier lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées). Il remplace le destinataire « adresse e-mail passée au
déclenchement » par de vrais **abonnés**, ajoute les **sujets**, les **catégories**, les
**préférences** à tous les niveaux, les **heures calmes**, le **désabonnement en un clic** et la
**diffusion**. Il ajoute aussi à `lyxal_core` la règle de conditions validée par K2. Les autres
canaux viennent aux lots 3 à 6 ; ce lot reste sur l'e-mail mais prépare le téléphone et les
canaux suivants. Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **B1** | Identifiant d'un abonné | Chaque abonné a un identifiant stable choisi par l'application (`subscriber_id`, unique par organisation), comme Novu. Une personne qui a un compte `lyxal_auth` est l'abonné `auth:<identité>` lié à son compte ; une personne invitée sans compte est l'abonné `email:<adresse>`. Quand elle crée son compte, ses préférences sont reprises sur l'abonné `auth:` (même adresse, même organisation). |
| **B2** | Qui voit et modifie les abonnés | Données personnelles : lecture `notification.read`, gestion `notification.manage`, création à la volée au déclenchement `notification.send`. Chaque personne connectée lit et règle **ses propres** préférences sans autre permission (fonctions `notification_my_*`). |
| **B3** | Envoi à un sujet ou à tous | Asynchrone : le déclenchement enregistre une **diffusion** que le worker découpe par paquets de 500 abonnés (reprise sûre après arrêt, un seul envoi par abonné). L'auteur de l'action (`actor`) n'est pas prévenu, sauf demande contraire. |
| **B4** | Ordre des préférences | Du plus général au plus précis, le dernier qui s'exprime gagne : défaut du parcours → réglage de l'organisation pour ce parcours → choix global de l'abonné → choix de l'abonné pour la catégorie → choix de l'abonné pour le parcours. Un parcours **critique** ignore les choix de l'abonné ; un réglage « imposé » du parcours ne peut pas être changé par l'abonné. Une seule fonction SurrealQL calcule le résultat. |
| **B5** | Heures calmes | Plages par jour de la semaine dans le fuseau de l'abonné (sinon celui de l'organisation, sinon UTC). Un envoi non critique qui tombe dans une plage part à la fin de la plage (pas annulé). Ne concerne ni le fil in-app (lot 5), ni un parcours critique. |
| **B6** | Désabonnement | Lien en un clic dans chaque e-mail non critique (K9) : il coupe l'e-mail pour la **catégorie** du parcours (ou le parcours s'il n'en a pas). Jeton signé HMAC-SHA256 (`lyxal_crypto`, clé dérivée de la clé applicative par HKDF), sans date d'expiration, sans compte à ouvrir. Le motif `unsubscribe` quitte la liste de suppression, qui ne garde que les rejets et les blocages (une adresse n'est plus « désabonnée » de tout). |

## 2. `lyxal_core` (K2)

`fn::utils_condition_evaluate($value: any, $condition: object, $limits: option<object>) ->
object` dans `crates/lyxal_core/functions/utils/functions/condition_evaluate.surql`, avec son
contrôle de forme `fn::utils_condition_check($condition, $limits)` :

* forme : `{ all: [...] }`, `{ any: [...] }`, `{ not: {...} }`, ou règle
  `{ field: "payload.montant", op: "gt", value: 1000 }` ;
* opérateurs : `eq`, `ne`, `lt`, `lte`, `gt`, `gte`, `between`, `in`, `not_in`, `contains`,
  `starts_with`, `ends_with`, `exists`, `missing`, `empty` ; champ lu par
  `fn::utils_object_get_path`, comparaisons par `fn::utils_compare_*` ;
* bornes : profondeur 5, 50 règles (réglables, plafonds fixes) ; forme invalide → `THROW
  CORE_CONDITION_INVALID` (argument du programmeur, convention du Core) ; résultat
  `{ matched, error }` sans jamais lever pour une valeur absente ;
* tests au banc du Core ; documenté dans `crates/lyxal_core/Readme.md`.

Le module vérifie chaque condition à l'enregistrement avec `fn::utils_condition_check` et
renvoie `NOTIFICATION_CONDITION_INVALID`.

## 3. Modèle (SurrealQL, réécrit en place)

| Table | Contenu |
| :--- | :--- |
| `notification_subscriber` | `tenant`, `scope_key`, `subscriber_id` (1 à 128, unique par portée), `identity` (`record<auth_identity>`, facultatif, supprimé avec le compte), `email`, `phone` (E.164), `first_name`, `last_name`, `locale`, `timezone`, `data` (objet, 8 Kio), `created_at`, `updated_at` |
| `notification_topic` | `tenant`, `key` (unique par portée), `name`, `description`, `data` |
| `notification_topic_member` | `topic`, `subscriber`, `condition` (règle K2, facultative), `created_at` ; unique (sujet, abonné) ; supprimé avec l'un ou l'autre |
| `notification_category` | `tenant`, `key` (unique par portée), `name`, `description` ; catégories de l'installation visibles par toutes les organisations |
| `notification_preference` | `tenant`, `level` (`tenant_workflow`, `subscriber_global`, `subscriber_category`, `subscriber_workflow`), `subscriber`, `workflow`, `category`, `channels` (`{ email, sms, chat, push, in_app, webhook }`, chaque valeur `true`, `false` ou absente), `quiet_hours` (niveau global seulement) ; unique par (niveau, cible) |
| `notification_broadcast` | diffusion en cours : déclenchement d'origine, cible (sujet ou tous), auteur exclu, curseur, compteurs, état |
| `notification_workflow` (étendu) | `category`, `preferences` : `{ channels: { … défauts }, enforced: [canaux imposés] }` |
| `notification_run` (modifié) | `subscriber` (remplace `recipient`) ; copie de l'adresse au moment de l'envoi ; `broadcast` facultatif ; `actor` |
| `notification_suppression` (modifié) | motifs `hard_bounce`, `complaint`, `manual` |

Données personnelles : supprimer un abonné supprime ses préférences et appartenances ; ses
déclenchements gardent l'adresse utilisée jusqu'à leur purge (durée des réglages). Tout est
supprimé avec l'organisation (`REFERENCE ON DELETE CASCADE`).

## 4. Fonctions publiques (`fn::notification_*($params: object)`)

| Domaine | Fonctions |
| :--- | :--- |
| Abonnés | `subscriber_upsert`, `subscriber_get`, `subscriber_list` (recherche, pagination), `subscriber_delete`, `subscriber_import` (500 au plus, rapport créés / modifiés / refusés par ligne) |
| Sujets | `topic_create`, `topic_update`, `topic_get`, `topic_list`, `topic_delete`, `topic_subscribe` (100 abonnés au plus, condition facultative), `topic_unsubscribe`, `topic_members` |
| Catégories | `category_create`, `category_update`, `category_list`, `category_delete` (refusée si un parcours l'utilise) |
| Préférences | `preference_get` (résultat calculé et détail par niveau), `preference_set` (gestionnaire, pour un abonné ou l'organisation), `my_preference_get`, `my_preference_set` (personne connectée), `unsubscribe` (appelée par l'hôte après vérification du jeton) |
| Déclenchement | `trigger` : `to` = abonné (`{ subscriber_id, email, phone, … }`, créé ou mis à jour à la volée), liste de 100 abonnés au plus, `{ topic }` ou `{ all: true }` ; `actor`, `exclude_actor` (vrai par défaut) |
| Diffusion (worker) | `broadcast_claim`, `broadcast_step` (paquet suivant, idempotent), `broadcast_complete` |

Fonction interne : `notification_preference_resolve({ subscriber, workflow })` → canaux
autorisés, motif par canal, prochaine fin d'heures calmes. Appelée à la création de chaque étape
(étape refusée : `skipped` avec motif `preference:<niveau>`) et à la réservation (un choix fait
entre-temps est respecté).

Entrées par `fn::validation_object_execute` (adresse e-mail, téléphone E.164, langue, fuseau :
règles `email`, `phone`, `locale`, `timezone` du Core) ; erreurs `NOTIFICATION_*` ; écriture
principale vérifiée (`NOTIFICATION_WRITE_FORBIDDEN`).

**Rupture coordonnée** : `fn::notification_trigger` perd `recipient`. `NotificationConsumer`
(`auth.*`) passe à `to: { subscriber_id: "auth:<identité>" ou "email:<adresse>", email, locale,
first_name }`. Les alertes de sécurité restent critiques.

## 5. Erreurs (master data `error/`)

`NOTIFICATION_SUBSCRIBER_NOT_FOUND`, `NOTIFICATION_SUBSCRIBER_NO_ADDRESS`,
`NOTIFICATION_TOPIC_NOT_FOUND`, `NOTIFICATION_TOPIC_KEY_TAKEN`, `NOTIFICATION_CATEGORY_NOT_FOUND`,
`NOTIFICATION_CATEGORY_IN_USE`, `NOTIFICATION_CATEGORY_KEY_TAKEN`,
`NOTIFICATION_PREFERENCE_ENFORCED`, `NOTIFICATION_CONDITION_INVALID`,
`NOTIFICATION_IMPORT_TOO_LARGE`, `NOTIFICATION_UNSUBSCRIBE_INVALID` ; Core :
`CORE_CONDITION_INVALID`.

## 6. Événements (`fn::event_publish`)

`notification.subscriber.created`, `.updated`, `.deleted` ; `notification.preference.updated` ;
`notification.topic.subscribed`, `.unsubscribed` ; `notification.subscriber.unsubscribed`
(catégorie ou parcours). Identifiants seulement, jamais l'adresse ni le téléphone.

## 7. Rust et hôte

* `models/` : `XxxParams` / `XxxResult` de chaque fonction ; wrappers `store.call_fn`.
* `UnsubscribeLinks` : création du lien (`{public_url}/api/v1/notification/unsubscribe?t=…`) et
  vérification du jeton (`lyxal_crypto::kdf::hkdf_sha256` puis `hmac`, comparaison en temps
  constant) ; contenu du jeton : portée, abonné, catégorie ou parcours, canal.
* Rendu e-mail : variable `unsubscribe_url` pour les mises en page ; en-têtes `List-Unsubscribe`
  et `List-Unsubscribe-Post: List-Unsubscribe=One-Click` (sauf parcours critique).
* `NotificationBroadcastWorker` (`LyxalWorker`) : paquets de 500, annulation coopérative.
* `NotificationEmailWorker` : étape dont l'heure calme n'est pas finie remise à plus tard.
* Hôte : `POST /api/v1/notification/unsubscribe` (un clic, RFC 8058, réponse 200 sans contenu)
  et `GET` (petite page de confirmation qui fait le `POST`), sans session, jeton refusé → 400 ;
  limitation de débit de l'hôte ; `public_url` exigée pour activer les liens.

## 8. Tests

* Banc Core : chaque opérateur, `all` / `any` / `not`, champ absent, bornes, forme invalide.
* Banc du module : abonnés (portée, unicité, import avec erreurs par ligne, droits, données
  personnelles supprimées), sujets et conditions, catégories, préférences (chaque niveau, ordre
  B4, parcours critique, canal imposé), heures calmes (fuseau, passage de minuit, critique),
  diffusion (paquets, reprise, auteur exclu, aucun double envoi), déclenchement à la volée,
  désabonnement, identités non autorisées.
* Rust de bout en bout : invitation `auth.*` reçue via l'abonné `email:`, alerte de sécurité via
  `auth:`, lien de désabonnement reçu puis utilisé (plus d'e-mail de la catégorie, un parcours
  critique passe toujours), jeton modifié refusé, diffusion à un sujet de 1 200 abonnés.
* Hôte : routes de désabonnement (un clic, jeton invalide, page).
* `scripts/ci/ci_local.sh`.

## 9. Documents

`README.md` (abonnés, sujets, préférences, désabonnement), `ROADMAP.md` (V1-b retiré),
`crates/lyxal_core/Readme.md` (règle de conditions), `apps/lyxal-server/README.md` (routes).
Ce plan est supprimé dans la demande de fusion de l'implémentation.

## 10. Checklist (§13)

* Core : conditions ajoutées avec validation CTO (K2) ; email, téléphone, langue, fuseau par les
  règles existantes ; aucun validateur local.
* Crypto : HKDF et HMAC-SHA256 de `lyxal_crypto` seulement.
* Zéro dette : `recipient` et le motif `unsubscribe` supprimés, appelants mis à jour ; une seule
  migration.
* Aucune donnée personnelle dans les événements ni les journaux.
