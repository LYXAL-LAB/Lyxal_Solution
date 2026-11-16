# Plan d'implémentation — programme `lyxal_notification` V1 complet

Fin du module `lyxal_notification` : tous les canaux (e-mail par fournisseur, SMS, messageries
d'équipe, appel d'une adresse web, fil dans l'application, notifications push) et ce dont ils ont
besoin (destinataires, préférences, parcours complets). Le lot V1-a (e-mail par relais SMTP) est en
place ([`crates/lyxal_notification/README.md`](crates/lyxal_notification/README.md)). Le modèle
cible et l'étude des sources existent déjà :
[`crates/lyxal_notification/MODELE_SOURCES.md`](crates/lyxal_notification/MODELE_SOURCES.md)
(Novu, MIT, hors `enterprise/` ; Postal, MIT ; Apprise, BSD-2 pour le catalogue des connecteurs).

**Deux niveaux de validation** (`AGENTS.md` §3) : ce plan fixe le programme (périmètre, lots,
décisions). Chaque lot a ensuite son plan détaillé (`XxxParams` / `XxxResult`, signatures
SurrealQL, codes d'erreurs, tests), soumis au CTO avant toute ligne de code.

## 1. Point de départ

| Élément | État |
| :--- | :--- |
| Parcours, gabarits traduits (`lyxal_i18n`), mises en page, déclenchement idempotent, file d'envoi, journal, liste de suppression, événements `auth.*` | Fait (V1-a) |
| Envoi | E-mail seulement, par **un relais SMTP unique** réglé dans l'hôte (`LYXAL__NOTIFICATION__SMTP__*`) : solution d'attente de `lyxal_secrets` |
| Destinataire | Une adresse e-mail passée au déclenchement : pas d'abonnés, pas de préférences |
| Attentes, nouvelles tentatives, purge | Workers du module : solution d'attente de `lyxal_scheduler` |
| `lyxal_secrets`, `lyxal_scheduler` | Livrés : les deux solutions d'attente peuvent être remplacées |

## 2. Lots

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **1. Destinataires et préférences** | Abonnés (création à la volée, import, profil, langue, fuseau), adresses par canal (e-mail, téléphone, appareils, messageries), sujets et abonnements conditionnels, catégories, préférences (installation, organisation, parcours, abonné), heures calmes, lien de désabonnement en un clic, diffusion à tous, exclusion de l'auteur | `lyxal_notification` |
| **2. Parcours complets** | Attente (courte et longue), regroupement (digest), limitation (throttle), conditions d'étape, « sauter si déjà lu », surcharges au déclenchement, envoi groupé, annulation, aperçu et envoi de test ; attentes, tentatives et purge confiées à `lyxal_scheduler` | `lyxal_notification`, `lyxal_core` (K2) |
| **3. Intégrations et e-mail par fournisseur** | `notification_integration` (fournisseur par canal, par organisation, avec repli sur l'installation, principale, priorité, conditions), identifiants dans `lyxal_secrets`, relais SMTP devenu une intégration, e-mail par API (K5), retours des fournisseurs (délivré, rejeté, plainte) reçus par l'hôte et suppression automatique | `lyxal_notification`, `apps/lyxal-server` |
| **4. SMS, messageries et adresse web** | SMS (K5), messageries d'équipe (Slack, Microsoft Teams, Discord, Mattermost, Google Chat, Telegram), appel signé d'une adresse web (K7) ; gabarits texte par canal, découpage SMS, retours de livraison | `lyxal_notification`, `apps/lyxal-server` |
| **5. Fil dans l'application** | Messages in-app : vu, lu, archivé, supprimé, mis en sommeil, compteurs, boutons d'action, onglets ; lecture par la seule personne destinataire (session `lyxal_auth`) ; temps réel (K6) | `lyxal_notification`, `apps/lyxal-server` |
| **6. Notifications push** | Navigateur (Web Push), Android (FCM), Apple (APNs) ; appareils inscrits, jetons invalides retirés ; cryptographie selon K8 | `lyxal_crypto` (K8), `lyxal_notification`, `apps/lyxal-server` |
| **7. Clôture** | Audit `lyxal-audit`, corrections, documentation d'exploitation, feuille de route ramenée à V2 / V3 | tout le module |

Ordre imposé : les canaux du lot 4 et le push du lot 6 ont besoin des adresses par canal (lot 1)
et des intégrations (lot 3) ; le fil in-app a besoin des abonnés (lot 1).

## 3. Modèle (ajouts, préfixe `notification_`)

Repris de `MODELE_SOURCES.md` §2 ; une seule migration réécrite en place (régime §0).

| Table | Lot | Contenu |
| :--- | :- | :--- |
| `notification_subscriber` | 1 | identifiant stable par organisation, profil, langue, fuseau, `data`, compte `lyxal_auth` lié facultatif |
| `notification_endpoint` | 1 | adresse d'un abonné pour un canal : e-mail, téléphone (E.164), appareil push, messagerie ; vérifiée par `lyxal_core` |
| `notification_topic`, `notification_topic_member` | 1 | sujets et abonnements, avec condition facultative |
| `notification_category` | 1 | catégorie de désabonnement des parcours |
| `notification_preference` | 1 | choix par canal : défaut du parcours, organisation, abonné global, abonné par parcours ou sujet ; heures calmes |
| `notification_digest`, `notification_rate_limit` | 2 | regroupements ouverts, compteurs de limitation |
| `notification_integration` | 3 | fournisseur, canal, portée, principale, priorité, conditions, **référence** `lyxal_secrets` (jamais une valeur) |
| `notification_provider_event` | 3 | retour d'un fournisseur, normalisé et dédoublonné |
| `notification_message` (étendu) | 5 | état du fil in-app : vu, lu, archivé, sommeil, action |

Le déclenchement vise désormais un **abonné**, un **sujet** ou **tous** (diffusion) ; le
déclenchement par adresse e-mail directe de `lyxal_auth` reste possible (abonné créé à la volée).

## 4. Décisions du CTO

Décisions K1 à K10 **validées par le CTO** le 16 novembre 2026, telles que proposées ci-dessous.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **K1** | Périmètre du programme | **Toute la V1** de la feuille de route (V1-b, V1-c, V1-d, V1-e) en 7 lots. Restent pour plus tard : la **V2** (écrans de la console, statistiques, suivi des ouvertures et clics, webhooks sortants vers les clients, révisions publiées, contrôle du domaine d'envoi, étape « appel d'API » dans un parcours) et la **V3** (questions avec réponse par message, courrier entrant, connexion Slack / Teams par OAuth), qui attend `lyxal_connect`. |
| **K2** | Moteur de conditions (conditions d'étape, abonnements conditionnels, choix d'intégration) | **Ajout à `lyxal_core`** (§5.7.7) : `fn::utils_condition_evaluate`, règle générique sans métier (et / ou / non ; champ par chemin ; égal, différent, plus petit, plus grand, entre, dans la liste, contient, commence par, présent), bâtie sur `fn::utils_object_get_path` et `fn::utils_compare_*`. Profondeur et taille bornées. Réutilisable par `lyxal_scheduler` (déclencheurs sur événement) et les modules métier. |
| **K3** | Attentes, nouvelles tentatives, purge | Confiées à `lyxal_scheduler` : attentes et fins de regroupement par **publication différée** (exécuteur `event`), purge par tâche périodique déclarée par le module. Les workers d'attente du module disparaissent ; l'envoi reste fait par les workers du module (un par canal). |
| **K4** | Configuration e-mail actuelle de l'hôte (`LYXAL__NOTIFICATION__SMTP__*`) | **Supprimée** (régime zéro dette) : le relais devient une intégration de l'installation, créée par un administrateur de la plateforme, son mot de passe rangé dans `lyxal_secrets`. Les organisations peuvent avoir leurs propres intégrations ; sans intégration propre, celle de l'installation sert. |
| **K5** | Fournisseurs livrés en V1 | **E-mail** : SMTP (existant), Brevo, Mailgun, Postmark, Resend. **SMS** : Brevo, Twilio, Vonage. Tous ont une API HTTP simple et des retours de livraison vérifiables avec `lyxal_crypto` (sauf Twilio : K8). Amazon SES, SendGrid et OVHcloud plus tard (signatures RSA ou SHA-1 à vérifier, ou API signée en SHA-1). D'autres fournisseurs s'ajoutent ensuite sans changer le modèle. |
| **K6** | Temps réel du fil in-app (point 2 de la feuille de route) | **Flux SSE de `lyxal-server`** (`/api/v1/notification/feed/stream`), ouvert avec la session `lyxal_auth` ; l'hôte écoute la base (`LIVE SELECT`) et ne transmet à chacun que ses propres messages et compteurs. Le navigateur ne se connecte jamais directement à SurrealDB. |
| **K7** | Canal « adresse web » et messageries (risque SSRF, point 7) | Adresses en **HTTPS seulement** ; refus des adresses privées, locales et de la plateforme (contrôle après résolution DNS, à chaque envoi) ; liste d'hôtes autorisés réglable par l'installation ; corps signé HMAC-SHA256 (`lyxal_crypto`) avec horodatage ; aucune redirection suivie. |
| **K8** | Cryptographie hors `lyxal_crypto` (point 5, §11.3) | **Extension de `lyxal_crypto`**, bornée aux besoins du push et des retours fournisseurs : signature ECDSA P-256 (jetons ES256 : Web Push VAPID et APNs), chiffrement Web Push (RFC 8291 : ECDH P-256, HKDF, AES-128-GCM), signature RSA-SHA256 (jeton du compte de service Google pour FCM), vérification HMAC-SHA1 (signature des retours Twilio). Bibliothèque : **`ring`** (déjà présente par `rustls` et `lettre`, auditée, RSA en temps constant), sous l'API de `lyxal_crypto` ; aucune crate crypto dans le module. Si refusé : pas de lot 6 (push), et Twilio retiré de K5. |
| **K9** | Désabonnement | Lien en un clic dans chaque e-mail non critique (en-têtes `List-Unsubscribe` et `List-Unsubscribe-Post`, RFC 8058, exigés par Gmail et Yahoo) ; jeton signé HMAC-SHA256 (`lyxal_crypto`), sans compte à ouvrir ; page et route de l'hôte. Un parcours critique n'en a pas. |
| **K10** | Client HTTP des fournisseurs | **`reqwest`** (MIT / Apache-2.0) avec `rustls`, nouvelle dépendance du module : délais bornés, aucune redirection, taille de réponse bornée. |

## 5. Points inchangés

* Toutes les règles en SurrealQL (`fn::notification_*($params: object)`), entrées par
  `lyxal_core`, erreurs `NOTIFICATION_*`, écritures vérifiées (`NOTIFICATION_WRITE_FORBIDDEN`),
  données d'une organisation supprimées avec elle.
* Aucun secret en base ni dans les journaux : identifiants des fournisseurs dans `lyxal_secrets`,
  secrets des messages scellés (`enc:v2`) ; parcours sensibles sans objet ni corps conservés.
* Le module ne connaît aucun module métier : les modules déclenchent par événement ou par
  `fn::notification_trigger`.

## 6. Dépendances

`lyxal_notification` ajoute `lyxal_secrets` et `lyxal_scheduler` à ses dépendances (manifeste et
Cargo). Nouvelles bibliothèques : `reqwest` (K10) ; `ring` dans `lyxal_crypto` (K8). Aucune
dépendance circulaire : `lyxal_secrets` et `lyxal_scheduler` ne dépendent pas de
`lyxal_notification`.

## 7. Vérification

Chaque lot : banc SurrealQL (cas nominaux, erreurs, identités, permissions), tests Rust de bout en
bout sur le moteur embarqué avec des **faux fournisseurs locaux** (serveur SMTP, API e-mail et SMS,
messageries, service push) ; aucun appel réel à un fournisseur en CI. `scripts/ci/ci_local.sh`
vert avant chaque demande de fusion. Un essai réel par fournisseur est possible sur demande du
CTO, avec ses propres identifiants rangés dans `lyxal_secrets`.
