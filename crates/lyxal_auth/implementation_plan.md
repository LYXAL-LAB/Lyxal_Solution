# Plan d'implémentation — programme courrier, agendas et contacts, lot 1 (mots de passe d'application)

Plan détaillé du lot 1 du programme courrier, agendas et contacts (`implementation_plan.md` à la
racine, §5 et décision **P8**) : **mots de passe d'application** dans `lyxal_auth`. Un logiciel de
courrier, d'agenda ou de contacts (Thunderbird, Apple Mail, Outlook, DAVx⁵, Calendrier d'Apple…)
envoie un identifiant et un mot de passe à chaque connexion et ne sait pas répondre à un second
facteur. L'utilisateur crée donc, depuis son compte, un mot de passe propre à chaque appareil,
limité à quelques droits, révocable à tout moment.

Ce lot ne crée **aucune écoute réseau** : il fournit la création, la gestion et la vérification.
Les serveurs SMTP, IMAP, POP3, ManageSieve (lots 5, 6, 8, 9, 10), CalDAV / CardDAV (lots 15, 16,
19) et JMAP (lots 12, 20) de `apps/lyxal-groupware` appelleront la vérification de ce lot.

Touche : `lyxal_auth`, `apps/lyxal-server` (routes de gestion), `lyxal_notification` (deux alertes
de sécurité, E2). Aucun besoin nouveau dans `lyxal_core` ni dans `lyxal_crypto`. Aucune ligne de
code avant la validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Méthode : constats faits **par lecture du code** (`crates/lyxal_auth`, `apps/lyxal-server`,
`crates/lyxal_notification`). Rien n'a été compilé ni exécuté pour ce plan. Ce qui n'est pas
vérifié est marqué « non vérifié ».

Modèle (comportement seulement, aucun code repris, règle du §4.1 du programme : aucun code AGPL
dans un crate existant) : mots de passe d'application de Stalwart (identifiant du moyen et secret
aléatoire, expiration, refus de l'emprunt d'identité) et jetons d'application de RustiCal (secret
de forte entropie, empreinte rapide, date de dernier usage) ; pratiques publiques de Google,
Apple et Fastmail. Modèle interne : clés d'API (`auth_api_key`, session `api_key`) et codes de
secours (`auth_recovery_code`, HMAC `code_pepper`) de `lyxal_auth`.

## 0. Écarts au plan du programme (à valider)

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | Le « journal des connexions » est **regroupé** : une ligne par mot de passe, protocole et adresse IP (première et dernière connexion, nombre), et non une ligne par connexion | Un logiciel CalDAV interroge le serveur toutes les quelques minutes et HTTP Basic renvoie le mot de passe à chaque requête : une ligne par connexion ferait des millions de lignes sans rien apprendre de plus à l'utilisateur (A9) |
| E2 | Le lot touche aussi `lyxal_notification` (deux alertes de sécurité), absent de la colonne « Touche » du programme | Prévenir le titulaire à la création d'un mot de passe d'application est demandé par P8 (contournement du double facteur à borner) ; les alertes passent par le consommateur existant `auth_security_alert` (A12) |
| E3 | Un champ `app_password` est ajouté à `auth_permission` : chaque module déclare quelles permissions peuvent être données à un mot de passe d'application | `lyxal_auth` ne doit pas connaître les modules du courrier (§5.6.1, §6) ; les permissions `mail.*`, `calendar.*`, `contacts.*` n'existent pas encore et seront déclarées par leurs lots (A4) |

## 1. Périmètre

**Dans le lot 1** :

* création d'un mot de passe d'application par l'utilisateur connecté (action sensible) :
  nom de l'appareil, permissions choisies, expiration facultative ; mot de passe affiché **une
  seule fois** ;
* liste de ses mots de passe (sans secret), journal des connexions de chacun, révocation d'un
  mot de passe ou de tous ;
* liste et révocation par un administrateur (installation, ou administrateur de l'organisation
  pour ses membres) ;
* **vérification** par l'hôte des protocoles (identifiant + mot de passe, protocole, adresse du
  client, connexion chiffrée) → session `app_password` aux droits limités et jeton d'accès,
  avec mémoire courte pour HTTP Basic et renouvellement du jeton pour les connexions longues
  (IMAP) ;
* limitation des essais par adresse IP ; compteur par identifiant ;
* révocations automatiques (récupération du compte, remise à zéro du double facteur, sortie de
  l'organisation) ;
* politique de l'installation et des organisations (activer ou désactiver, nombre maximal,
  durée maximale) ;
* événements et alertes de sécurité par e-mail ;
* routes HTTP de gestion dans `lyxal-server`.

**Hors lot 1** : écoutes réseau, analyse de SASL PLAIN / LOGIN et de l'en-tête HTTP Basic (lots
3 et suivants, dans `lyxal-groupware` et `lyxal_mail_proto`) ; SCRAM-SHA-256 (P6(h), lot 8, A14) ;
adresses de courrier comme identifiant (lot 4, A3) ; profils de configuration automatique
(Apple `.mobileconfig`, autoconfig : lot 13) ; alerte « nouvel appareil » et rappel avant
expiration (`ROADMAP.md`) ; écrans de la console.

## 2. Fonctionnement, en clair

```text
Création (console, session interactive, authentification récente au niveau le plus haut)
  nom « iPhone de Marie », permissions [mail.mailbox.access, calendar.access], expiration facultative
  → mot de passe affiché une fois : 7kq2m-x9tab-hc4wp-3nrfe
  → e-mail d'alerte au titulaire

Connexion d'un logiciel (hôte des protocoles, connexion chiffrée obligatoire)
  identifiant marie@exemple.fr + mot de passe
  → adresse IP bloquée ?                         → refus (trop d'essais)
  → empreinte du mot de passe connue,
    même identité que l'identifiant ?            → sinon : échec compté (IP), refus
  → révoqué, expiré, désactivé par la politique,
    identité ou organisation inactive ?          → refus (non compté : c'est un ancien appareil)
  → droits = permissions du mot de passe
             ∩ permissions encore détenues        → aucune : refus
  → session « app_password » (partagée par ce mot de passe), jeton d'accès de 15 min
  → journal : (mot de passe, protocole, IP) première / dernière fois, nombre
```

* Le mot de passe d'application ne sert **qu'aux protocoles** : il n'ouvre ni la console, ni
  l'API de `lyxal-server`, ni la gestion du compte (aucune permission `auth.*`).
* La session est de niveau d'assurance 1 : une permission qui exige un second facteur
  (`min_aal: 2`) ne lui est jamais accordée.
* La révocation vaut dès l'opération suivante, même sur une connexion IMAP restée ouverte : la
  base relit la session et le mot de passe à chaque contrôle des droits.

## 3. Modèle de données (`schema/`)

Une seule migration par module (§0) : `lyxal_auth` n'a pas de migration, ses schémas sont
réécrits en place. Fichier nouveau `schema/17_auth_app_password.surql`.

| Table | Changement |
| :--- | :--- |
| `auth_app_password` (nouvelle) | `identity` (`record<auth_identity>`, `REFERENCE ON DELETE CASCADE`, `READONLY`) ; `organization` (`record<auth_organization>`, cascade, `READONLY`, obligatoire) ; `name` (1 à 64 caractères) ; `password_hash` (HMAC-SHA256 hex, 64 caractères, `READONLY`, `PERMISSIONS FOR select NONE`) ; `permissions` (`array<string>`, `READONLY`) ; `expires_at` (option, `READONLY`) ; `last_used_at`, `last_used_protocol`, `last_used_ip` (option) ; `revoked_at`, `revoked_reason` (`owner`, `admin`, `recovery`, `mfa_reset`, `membership_removed`) ; `revoked_by` (`option<record<auth_identity>>`, `REFERENCE ON DELETE UNSET`) ; `created_at`. Index unique `password_hash` ; index `identity, organization` |
| `auth_app_password_use` (nouvelle, E1) | `app_password` (cascade, `READONLY`) ; `identity`, `organization` (cascade, `READONLY`, pour les listes et la purge) ; `protocol` (`smtp`, `imap`, `pop3`, `managesieve`, `dav`, `jmap`) ; `ip` (texte) ; `client_name` (option, 128 caractères : en-tête `User-Agent` ou commande IMAP `ID`) ; `first_seen_at`, `last_seen_at`, `count`. Index unique `app_password, protocol, ip` ; index `last_seen_at` (purge) |
| `auth_session` | `kind` : ajout de `app_password` ; champ `app_password` (`option<record<auth_app_password>>`, cascade, `READONLY`) ; index `app_password, state` |
| `auth_permission` | `app_password` (`bool`, défaut `false`) : permission utilisable par un mot de passe d'application ; `ASSERT` : vrai seulement si `scope = "organization"` et `min_aal = 1` (E3) |
| `auth_login_failure` | `kind` : ajout de `app_password_ip` et `app_password_identifier` (A8) |
| `auth_policy` | thème `app_password` (A11) : `enabled` (bool), `max_per_identity` (1 à 100), `max_lifetime_days` (option, 1 à 3650), `session_seconds` (900 à 86400), `ip_max_failures` (5 à 10000), `identifier_alert_failures` (10 à 10000), `log_days` (7 à 365) |

**Permissions des tables** :

* `auth_app_password` : lecture par son titulaire (`identity = $auth.identity`), par
  `auth.identity.manage`, ou par `auth.member.manage` de son organisation ; `password_hash`
  illisible pour tous ; **création et modification refusées à tous** (`FOR create, update,
  delete NONE`) : seules les fonctions de la session système écrivent. C'est plus strict que
  `auth_api_key` (écriture directe soumise à une règle) : ici le mot de passe est produit par
  l'hôte, jamais par l'appelant.
* `auth_app_password_use` : mêmes lectures ; écriture par la session système seulement.
* Une révocation est définitive : `DEFINE EVENT` qui refuse un `revoked_at` modifié une fois posé
  (`THROW "AUTH_APP_PASSWORD_INVALID"`, comme la garde des clés d'API).

**Événements de la base** (`events/auth_events.surql`) :

* révocation d'un mot de passe → ses sessions `app_password` révoquées (motif
  `app_password_revoked`), dans la même transaction ;
* adhésion supprimée (`auth_member_of`, `DELETE`) → mots de passe de cette identité dans cette
  organisation révoqués (`membership_removed`) ;
* politique enregistrée avec `app_password.enabled = false` → sessions `app_password` de sa
  portée (installation ou organisation) révoquées ; les mots de passe restent (A11).

## 4. Mot de passe : format, génération, empreinte

| Point | Proposition |
| :--- | :--- |
| Génération | `OsRng` (`rand_core`), tirage sans biais (rejet), en Rust (`services/app_password.rs`) |
| Alphabet | 31 signes sans ambiguïté : `23456789abcdefghjkmnpqrstuvwxyz` (celui des codes de secours : ni `0`/`o`, ni `1`/`l`/`i`) |
| Longueur | 20 signes, soit **environ 99 bits** d'aléa |
| Affichage | 4 groupes de 5 séparés par des tirets : `7kq2m-x9tab-hc4wp-3nrfe` (23 caractères) |
| Saisie | Majuscules, espaces et tirets ignorés (claviers de téléphone qui mettent une majuscule, copie avec espaces) ; tout autre caractère ou une longueur fausse → échec immédiat, sans lecture en base de l'empreinte (l'échec est quand même compté) |
| Préfixe | Aucun : le mot de passe est souvent tapé à la main sur un téléphone (A2) |
| Empreinte | HMAC-SHA256 (`lyxal_crypto::sign_hmac_sha256_hex`) avec la clé `code_pepper` existante, sur `"lyxal_auth.app_password:" + forme normalisée` (séparation des usages avec les codes de secours) ; recherche directe par l'index unique (A1) |
| Retour à l'utilisateur | `{ app_password, username, password }` : `username` est l'adresse de connexion à saisir dans le logiciel ; réponse `Cache-Control: no-store` (déjà posé sur `/api/v1/auth/*`) |

Coût d'une connexion : un HMAC (quelques microsecondes) et **un** appel SurrealQL. Avec
Argon2id aux réglages de `lyxal_crypto` (64 Mio, 3 passes, `crates/lyxal_crypto/src/password.rs`),
chaque vérification coûterait de l'ordre de 0,1 à 0,3 s de calcul et 64 Mio de mémoire (ordre de
grandeur, **non mesuré**). Or un logiciel CalDAV envoie le mot de passe à chaque requête, un
client IMAP ouvre plusieurs connexions, et un attaquant pourrait faire travailler le serveur
avec de faux mots de passe. Un hachage lent ne protège que des mots de passe devinables ; un tirage
de 99 bits ne l'est pas, même si la base fuyait (RustiCal fait le même raisonnement avec 1 000
tours de PBKDF2 ; les clés d'API de Lyxal sont déjà en BLAKE3 simple).

## 5. Règles

* **Identifiant** (A3) : l'adresse e-mail de connexion du compte (`auth_credential_identifier`,
  type `email`), normalisée par `fn::sanitize_pipeline_execute` (règle `email`), comme
  `fn::auth_password_credential_get`. Le mot de passe est trouvé par son empreinte ; l'identifiant
  doit désigner la même identité, sinon échec.
* **Organisation** : celle de la session interactive à la création, obligatoire
  (`AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED` pour une session sans organisation active). Un
  utilisateur membre de deux organisations crée un mot de passe par organisation.
* **Permissions à la création** (A4) : non vides ; chacune détenue par l'utilisateur dans cette
  organisation (droits recalculés en base par `fn::auth_subject_permissions`, pas lus dans un
  jeton) **et** déclarée `app_password = true`. Jamais `auth.*` (aucune n'est déclarée ainsi).
* **Permissions à la connexion** (A5) : permissions du mot de passe ∩ permissions déclarées
  `app_password` ∩ permissions encore détenues (paramètre `limit` existant de
  `fn::auth_session_open`). Ensemble vide → `AUTH_APP_PASSWORD_NO_PERMISSION` ; le mot de passe
  est gardé (le droit peut revenir). Un retrait de droit pendant une connexion rend la session
  obsolète (`permissions_version`, mécanisme existant) : l'hôte renouvelle et obtient les droits
  réduits.
* **Création = action sensible** (A7) : session **interactive** d'une identité, permission
  `auth.self.manage`, AAL la plus haute disponible et authentification de moins de 15 min
  (`fn::auth_assurance_state`, comme les clés d'API) ; sinon `AUTH_AAL_INSUFFICIENT` ou
  `AUTH_REAUTHENTICATION_REQUIRED`, résolus par la réauthentification du lot 4 de `lyxal_auth`.
  Révoquer ses propres mots de passe n'est pas une action sensible (cela retire des droits).
* **Nombre maximal** : `app_password.max_per_identity` (20 par défaut) mots de passe actifs
  (non révoqués, non expirés) par identité et organisation → `AUTH_APP_PASSWORD_LIMIT_REACHED`.
* **Expiration** : facultative ; au plus `max_lifetime_days` si la politique le fixe
  (`AUTH_APP_PASSWORD_EXPIRY_TOO_LONG`) ; si la politique fixe une durée et que l'utilisateur
  n'en donne pas, l'expiration vaut cette durée.
* **Connexion chiffrée** (A13) : l'hôte indique `secure` ; `false` → refus
  `AUTH_APP_PASSWORD_INSECURE_TRANSPORT` dans `lyxal_auth`, avant tout calcul (une seule règle
  pour tous les protocoles).
* **Essais** (A8) :
  * par **adresse IP** (`app_password_ip`, empreinte BLAKE3 de l'adresse) : au-delà de
    `ip_max_failures` (20) échecs dans la fenêtre `lockout.window_seconds` (15 min), adresse
    bloquée `lockout.lock_seconds` (15 min) pour les mots de passe d'application seulement →
    `AUTH_TOO_MANY_ATTEMPTS` ; événement `auth.app_password.ip_locked` au blocage ;
  * par **identifiant** (`app_password_identifier`) : compté, **jamais bloqué** (un tiers
    pourrait sinon couper la messagerie de quelqu'un en tapant de faux mots de passe) ; au seuil
    `identifier_alert_failures` (50), événement `auth.app_password.failed` une fois par fenêtre ;
  * ne sont comptés que les mots de passe **inconnus** ou présentés avec un autre identifiant.
    Un mot de passe juste mais révoqué ou expiré n'est pas compté : c'est un ancien appareil qui
    réessaie, et il ne doit pas bloquer l'adresse IP d'un bureau entier ;
  * les compteurs du mot de passe principal (`identifier`, `ip`) ne sont pas touchés : les essais
    sur IMAP ne verrouillent pas la connexion à la console, et inversement.
* **Révocations automatiques** (A6) : récupération du compte (`recovery`), remise à zéro du double
  facteur par un administrateur (`mfa_reset`), sortie de l'organisation (`membership_removed`).
  Le changement volontaire du mot de passe principal ne les révoque pas (il révoque déjà les
  autres sessions, que l'hôte rouvre seul).
* **Identité ou organisation inactive, adhésion suspendue** : refus à la connexion par les règles
  existantes de `fn::auth_session_open` ; pas de révocation (état réversible).
* **Administrateur** : `auth.identity.manage`, ou `auth.member.manage` de l'organisation du mot de
  passe pour un membre qu'il peut gérer (`fn::auth_org_admin_can_manage`, mêmes règles que
  `fn::auth_mfa_reset`). Il voit les mots de passe (sans secret) et le journal, et révoque ; il
  n'en crée jamais pour quelqu'un d'autre.
* **Pas d'emprunt d'identité** : un mot de passe d'application ne peut servir qu'à son titulaire.

## 6. Sessions et jetons (A10)

* Nature `app_password` : sujet = identité, organisation = celle du mot de passe, `amr`
  `[app_password]`, AAL 1, sans jeton de renouvellement. `fn::auth_session_open` n'applique pas la
  règle « double facteur exigé » aux sessions non interactives (comportement actuel des clés
  d'API) : c'est le contournement voulu par P8, borné par A4, A7 et la règle `min_aal`.
* **Une session par mot de passe**, partagée par toutes les connexions de ses appareils : la
  vérification reprend la session active de ce mot de passe s'il lui reste plus de 5 min, sinon
  en ouvre une nouvelle (expiration `app_password.session_seconds`, 12 h par défaut). Évite une
  ligne `auth_session` et un événement `auth.session.created` par requête CalDAV.
* `fn::auth_session_valid` et `fn::auth_session_check` refusent une session `app_password` dont le
  mot de passe est révoqué ou expiré (même contrôle que pour une clé d'API) : révocation
  effective à l'opération suivante, sur toute connexion.
* **Jeton** : JWT de 15 min (politique `session.access_seconds`), mêmes claims que les autres
  sessions, accepté par l'accès SurrealDB `lyxal_auth_a|b` : l'hôte des protocoles ouvre une
  connexion SurrealDB **au nom de l'utilisateur** avec ce jeton (comme `caller_session` de
  `lyxal-server`), et les fonctions et permissions de `lyxal_mail`, `lyxal_calendar` et
  `lyxal_contacts` décident. Le jeton ne quitte jamais l'hôte : le logiciel n'envoie que son mot
  de passe.
* **Renouvellement** (connexions longues, IMAP en veille) : `renew` réémet un jeton pour la même
  session sans redemander le mot de passe, après contrôle en base (mot de passe et session
  valides, droits recalculés). Session expirée → l'hôte ferme la connexion ; le logiciel se
  reconnecte avec son mot de passe.
* **Mémoire courte pour HTTP Basic** (dans `lyxal_auth`, `AppPasswordService`) : résultat d'une
  vérification réussie gardé jusqu'à 1 min avant l'expiration de son jeton, par
  (empreinte, identifiant, protocole, adresse IP) ; 10 000 entrées au plus (les plus anciennes
  sortent) ; aucun échec gardé. Une requête qui la trouve ne touche pas la base pour
  l'authentification ; la révocation reste effective à l'opération suivante (la base relit la
  session). Le journal et `last_used_at` sont mis à jour à chaque vérification réelle, donc au
  plus toutes les 15 min environ par appareil et adresse.

## 7. Fonctions publiques (`functions/app_password/auth_app_password.surql`, `fn::auth_*($params: object)`)

Entrées par le moteur `lyxal_core` (§5.7.8), retour `fn::result_ok` / `fn::error_result`,
écriture vérifiée (`AUTH_WRITE_FORBIDDEN`), `COMMENT`, moins de 300 lignes chacune. Les
fonctions qui reçoivent une empreinte sont réservées à la **session système** de l'hôte ; elles
reçoivent l'acteur (session de l'utilisateur ou de l'administrateur) dont la base revérifie
droits, AAL et ancienneté.

| Fonction | Paramètres | Résultat | Appelant |
| :--- | :--- | :--- | :--- |
| `auth_app_password_create` | `session` (acteur), `name`, `permissions`, `expires_at`, `password_hash` | `{ id, name, organization, permissions, expires_at, created_at, username }` | système (acteur : session interactive) |
| `auth_app_password_list` | `identity` (défaut : celle de la session), `organization` | liste sans empreinte, avec `state` calculé (`active`, `expired`, `revoked`) | titulaire ; administrateur |
| `auth_app_password_uses` | `app_password`, `limit` | journal (protocole, IP, logiciel, première et dernière fois, nombre), du plus récent au plus ancien | titulaire ; administrateur |
| `auth_app_password_revoke` | `session` (acteur), `app_password` **ou** `identity` (tous ses mots de passe, dans l'organisation donnée ou toutes) | `{ revoked: <nombre> }` | système (acteur : titulaire ou administrateur) |
| `auth_app_password_eligible` | — | permissions que l'appelant peut donner (détenues dans son organisation active et `app_password = true`), avec module et description | titulaire |
| `auth_app_password_verify` | `password_hash`, `identifier`, `protocol`, `client` `{ ip, user_agent }`, `client_name`, `ip_hash`, `identifier_hash`, `access_slot` | ce que porte le jeton (`session`, `identity`, `organization`, `permissions`, `version`, `aal`, `access_seconds`, `expires_at`) et `app_password` | système |
| `auth_app_password_session_renew` | `session`, `access_slot` | même résultat que `verify` | système |
| `auth_app_password_failure_record` (interne) | `ip_hash`, `identifier_hash`, `identity` | `{ locked, until }` ; événements au seuil | appelée par `verify` |
| `auth_app_password_log` (interne) | `app_password`, `protocol`, `ip`, `client_name` | — (ligne du journal créée ou mise à jour, `last_used_*`) | appelée par `verify` |

Fonctions existantes étendues :

| Fonction | Changement |
| :--- | :--- |
| `auth_session_open` | `app_password` (référence) ; nature `app_password` ; expiration `app_password.session_seconds` |
| `auth_session_valid`, `auth_session_check` | mot de passe révoqué ou expiré → `AUTH_SESSION_REVOKED` |
| `auth_permission_register`, `auth_permission_update` | champ `app_password` |
| `auth_policy_get`, `auth_policy_save` | thème `app_password` ; une organisation ne peut que restreindre : `enabled` = installation **et** organisation, plafonds = le plus petit des deux |
| `auth_password_set` | paramètre `revoke_app_passwords` (vrai pour la récupération, faux pour un changement volontaire) |
| `auth_mfa_reset` | révoque les mots de passe d'application (`mfa_reset`) |
| `auth_login_failure_*` | nouvelles natures de compteur (lecture du verrou par IP) |
| `auth_purge` | mots de passe révoqués ou expirés depuis plus de `session_retention_days` (30 j) supprimés ; journal plus vieux que `app_password.log_days` (90 j) supprimé ; compteurs des nouvelles natures |

**Fonctions Core réutilisées** : `fn::validation_object_execute` (règles `required_string`,
`record`, `enum`, `hexadecimal`, `array_of_strings`, `each`, `array_unique`, `future_datetime`,
`ip`, `optional_string`, `integer`, `boolean`, `email`, `language_code`, `is_object`, `object`),
`fn::sanitize_object_execute` (`lowercase`, `trim`), `fn::sanitize_pipeline_execute` (`email`).
**Fonctions métier nouvelles** : celles du tableau ci-dessus. **Fonctions Core manquantes** :
aucune.

## 8. Contrats Rust (`src/`)

`models/app_password.rs` (re-exportés par `models/mod.rs`), `Debug` masqué
(`redacted_debug!`) pour toute empreinte, tout mot de passe et tout jeton :

| Type | Champs |
| :--- | :--- |
| `AppPasswordCreateParams` | `session`, `name`, `permissions`, `expires_at: Option<AuthDatetime>`, `password_hash` (masqué) |
| `AppPasswordSummary` (résultat de `create` et `list`) | `id`, `name`, `organization`, `permissions`, `expires_at`, `state`, `last_used_at`, `last_used_protocol`, `last_used_ip`, `revoked_at`, `revoked_reason`, `created_at` |
| `AppPasswordListParams` | `identity: Option<String>`, `organization: Option<String>` |
| `AppPasswordUsesParams` / `AppPasswordUse` | `app_password`, `limit` / `protocol`, `ip`, `client_name`, `first_seen_at`, `last_seen_at`, `count` |
| `AppPasswordRevokeParams` / `AppPasswordRevoked` | `session`, `app_password: Option<String>`, `identity: Option<String>`, `organization: Option<String>` / `revoked: i64` |
| `EligiblePermission` | `code`, `module`, `description` |
| `AppPasswordVerifyParams` | `password_hash` (masqué), `identifier`, `identifier_hash`, `protocol`, `client: ClientInfo`, `client_name`, `ip_hash`, `access_slot` |
| `AppPasswordSessionRenewParams` | `session`, `access_slot` |
| `AppPasswordSessionIssued` | `SessionIssued` existant + `app_password` |

`AuthStore` : un wrapper 1 ligne `store.call_fn("auth_app_password_…", params)` par fonction
(§5.4).

`services/app_password.rs` — `AppPasswordService<R: KeyResolver>`, obtenu par
`AccessService::app_passwords()` (comme `mfa()`) :

```rust
/// Protocole qui présente le mot de passe (journal).
pub enum AppProtocol { Smtp, Imap, Pop3, ManageSieve, Dav, Jmap }

/// Tentative de connexion présentée par l'hôte des protocoles.
pub struct AppPasswordAttempt {
    pub username: String,
    pub password: SecretString,
    pub protocol: AppProtocol,
    pub client: ClientInfo,
    pub client_name: Option<String>,
    /// Connexion chiffrée (TLS, ou HTTPS terminé par un proxy de confiance).
    pub secure: bool,
}

/// Connexion réussie : jeton d'accès (masqué en `Debug`), session, droits, expiration.
pub struct AppPasswordLogin { pub access_token: SecretString, pub expires_in: i64,
    pub session: SessionIssued, pub app_password: AuthRecordId }

/// Mot de passe créé, affiché une seule fois (masqué en `Debug`).
pub struct AppPasswordIssued { pub summary: AppPasswordSummary, pub username: String,
    pub password: SecretString }

impl<R: KeyResolver + 'static> AppPasswordService<R> {
    pub async fn create(&self, caller: &SessionCaller, name: &str, permissions: Vec<String>,
        expires_at: Option<AuthDatetime>) -> AuthResult<AppPasswordIssued>;
    pub async fn authenticate(&self, attempt: AppPasswordAttempt) -> AuthResult<AppPasswordLogin>;
    pub async fn renew(&self, login: &AppPasswordLogin) -> AuthResult<AppPasswordLogin>;
    pub async fn revoke(&self, actor: &SessionCaller, target: AppPasswordTarget) -> AuthResult<i64>;
}
```

* Génération et normalisation : fonctions privées `app_password()` et `normalize_app_password()`
  (alphabet et tirage du §4) ; empreinte par `lyxal_crypto::sign_hmac_sha256_hex` avec
  `SigningKeyService::code_pepper()` ; empreintes d'IP et d'identifiant par `blake3_hex` ;
  jeton par `tokens::access_token`.
* Mémoire courte : structure bornée (`HashMap` + ordre d'arrivée) sous `tokio::sync::Mutex`,
  sans tâche de fond (entrées expirées retirées à la lecture) ; aucune dépendance nouvelle.
* C'est l'API que `lyxal-groupware` appellera (lots 3 et suivants) : `authenticate` après
  `AUTH PLAIN` / `AUTH LOGIN` / `LOGIN` / `USER`+`PASS` / HTTP Basic, puis `renew` à l'expiration
  du jeton. Aucun `panic!` ; toute erreur remonte en `AuthError` (`AUTH_*`), jamais avalée.
* Aucune crate cryptographique importée ; aucune dépendance nouvelle.

## 9. Hôte (`apps/lyxal-server`)

Fichier nouveau `src/http/auth_app_passwords.rs`, monté sous `/api/v1/auth`. 🔒 : jeton d'une
session **interactive** (`identity_of`) ; ✱ : action sensible (A7).

| Route | Corps / réponse |
| :--- | :--- |
| `GET /app-passwords` 🔒 | ses mots de passe (sans secret) |
| `GET /app-passwords/permissions` 🔒 | permissions qu'il peut donner (aide de l'interface) |
| `POST /app-passwords` 🔒✱ | `name`, `permissions`, `expires_at` → `app_password`, `username`, `password` (une seule fois) |
| `DELETE /app-passwords/{id}` 🔒 | révoque ce mot de passe |
| `DELETE /app-passwords` 🔒 | révoque tous ses mots de passe de l'organisation active |
| `GET /app-passwords/{id}/uses` 🔒 | journal des connexions |
| `GET /identities/{identity}/app-passwords` 🔒 | administrateur : mots de passe d'une identité |
| `DELETE /identities/{identity}/app-passwords/{id}`, `DELETE /identities/{identity}/app-passwords` 🔒✱ | administrateur : révocation |

* Erreurs `AUTH_*` rendues dans la langue de l'appelant (mécanisme existant) ; identifiants dans
  le chemin encodés en pourcentage.
* **Aucune** authentification HTTP Basic n'est ajoutée à `lyxal-server` (A15) : un mot de passe
  d'application n'ouvre pas l'API de la plateforme. L'appel `authenticate` est exercé par les
  tests de `lyxal_auth` jusqu'au lot 3.
* Aucune configuration nouvelle.

## 10. Master data (`error/app_passwords/error_app_passwords.surql`, préfixe `AUTH_`)

Forme `IF !record::exists(...) THEN ( CREATE ... ) END;`, fr et en, catégorie, statut HTTP,
réessayable.

| Code | HTTP | Sens |
| :--- | :-: | :--- |
| `AUTH_APP_PASSWORD_INVALID` | 401 | Identifiant ou mot de passe d'application faux, inconnu, révoqué ou expiré (message unique côté protocole) |
| `AUTH_APP_PASSWORD_NOT_FOUND` | 404 | Mot de passe désigné par la gestion introuvable ou invisible |
| `AUTH_APP_PASSWORD_DISABLED` | 403 | Désactivés par la politique de l'installation ou de l'organisation |
| `AUTH_APP_PASSWORD_LIMIT_REACHED` | 409 | Nombre maximal atteint |
| `AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED` | 403 | Permission non détenue ou non utilisable par un mot de passe d'application (détails : liste) |
| `AUTH_APP_PASSWORD_NO_PERMISSION` | 403 | Plus aucune permission utilisable à la connexion |
| `AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED` | 400 | Session sans organisation active |
| `AUTH_APP_PASSWORD_EXPIRY_TOO_LONG` | 400 | Expiration au-delà de la durée maximale de la politique |
| `AUTH_APP_PASSWORD_INSECURE_TRANSPORT` | 403 | Connexion non chiffrée |

Codes existants réutilisés : `AUTH_TOO_MANY_ATTEMPTS`, `AUTH_PERMISSION_DENIED`,
`AUTH_INVALID_PARAMETERS`, `AUTH_WRITE_FORBIDDEN`, `AUTH_SESSION_*`, `AUTH_AAL_INSUFFICIENT`,
`AUTH_REAUTHENTICATION_REQUIRED`, `AUTH_IDENTITY_INACTIVE`, `AUTH_ORGANIZATION_INACTIVE`.
Les hôtes des protocoles traduisent tout refus en réponse d'échec du protocole (SMTP 535, IMAP
`NO [AUTHENTICATIONFAILED]`, HTTP 401), sans détail pour le client.

## 11. Événements

Publiés dans la transaction de la mutation par `fn::event_publish`, résultat vérifié (`THROW`
sinon). Aucun mot de passe, empreinte de mot de passe ni jeton dans une charge utile.

| Événement | Charge utile | Alerte au titulaire (A12) |
| :--- | :--- | :-: |
| `auth.app_password.created` | `app_password_id`, `identity_id`, `organization_id`, `name`, `permissions`, `expires_at`, `recipient_email`, `recipient_locale`, `recipient_name`, `at` | oui |
| `auth.app_password.revoked` | `app_password_id`, `identity_id`, `organization_id`, `name`, `reason`, `revoked_by`, `recipient_*`, `at` | oui, sauf motif `owner` |
| `auth.app_password.ip_locked` | `ip_hash`, `until` | non |
| `auth.app_password.failed` | `identifier_hash`, `identity_id` (si connue), `failures` — au seuil seulement | non |

Les sessions `app_password` publient les événements existants `auth.session.created` /
`auth.session.revoked`. Aucun événement par connexion réussie (volume, E1).

`lyxal_notification` (E2) : `security_alert!` étendu à `AppPasswordCreated`
(`app_password_created`) et `AppPasswordRevoked` (`app_password_revoked`, ignoré quand le motif
est `owner`) ; phrases fr et en du parcours existant `auth_security_alert`
(`seeds/notification_texts.surql`) ; `README.md`. Aucun parcours nouveau.

## 12. Cryptographie

Primitives existantes seulement : `sign_hmac_sha256_hex` (`HmacKey` `code_pepper`), `blake3_hex`,
`OsRng`, `SecretString`, signature du jeton (`tokens::access_token`). **Aucune extension de
`lyxal_crypto`**, aucune crate cryptographique ajoutée.

SCRAM-SHA-256 (P6(h)) n'est **pas** dans ce lot (A14) : il demande PBKDF2, absent de
`lyxal_crypto`, et n'a d'intérêt qu'avec IMAP (lot 8). S'il est retenu, le serveur devra garder,
pour chaque mot de passe d'application, une clé SCRAM calculée **à la création** (seul moment où
le mot de passe est connu en clair) ; les mots de passe créés avant devront être recréés, ce qui
ne coûte rien en pré-production (§0).

## 13. Tests

* **Banc SurrealQL** (`tests/motsdepasseapp.test.surql`, `scripts/ci/test_lyxal_modules.py`) :
  * chaque fonction publique, cas nominal et paramètres refusés ;
  * création : session non interactive, clé d'API et compte de service refusés ; AAL ou
    ancienneté insuffisante refusée ; permission non détenue, non déclarée `app_password` ou
    `auth.*` refusée ; organisation absente ; nombre maximal ; politique désactivée ; expiration
    trop longue ; expiration imposée par la politique ;
  * empreinte illisible pour le titulaire et l'administrateur ; écriture directe refusée à une
    identité (`CREATE`, `UPDATE`) ; révocation définitive ;
  * liste et journal : titulaire, administrateur de l'installation, administrateur de
    l'organisation (son membre seulement), autre membre refusé ; isolation entre organisations ;
  * vérification : nominale (session `app_password`, AAL 1, permissions réduites) ; mauvais
    identifiant ; empreinte inconnue comptée ; blocage de l'IP au seuil ; mot de passe révoqué
    ou expiré refusé **sans** compter ; seuil par identifiant sans blocage ; compteurs de la
    console non touchés ; permission perdue → droits réduits puis `NO_PERMISSION` ; permission
    `min_aal: 2` jamais accordée ; identité suspendue, organisation suspendue, adhésion suspendue ;
  * session partagée reprise, nouvelle session près de l'expiration ; renouvellement ;
  * révocation → sessions révoquées et `fn::auth_session_valid` faux à l'opération suivante ;
    sortie de l'organisation, récupération, remise à zéro du double facteur → révocation ;
    changement volontaire du mot de passe → pas de révocation ;
  * politique : une organisation ne peut que restreindre ; désactivation → sessions révoquées,
    mots de passe gardés ;
  * journal regroupé (création puis mise à jour de la ligne) ; purge ;
  * événements publiés (outbox) avec `recipient_*`, sans secret ;
  * fonctions système refusées à une identité.
* **Rust** (`tests/it/app_passwords.rs` et tests unitaires du service) :
  * format : longueur, alphabet, groupes ; normalisation (majuscules, espaces, tirets) ; saisie
    invalide refusée sans appel de vérification en base ; `Debug` masqué ;
  * `authenticate` de bout en bout sur le moteur embarqué : le jeton est accepté par l'accès
    SurrealDB, une fonction protégée par une permission du mot de passe réussit, une autre est
    refusée ; après révocation, refus sur **la même connexion** ;
  * mémoire courte : deuxième appel sans nouvelle session ; `secure: false` refusé ; `renew`
    après retrait d'un droit ;
  * alertes reçues par le serveur SMTP de test de `lyxal_notification` (création, révocation par
    un administrateur ; aucune pour une révocation par le titulaire).
* **Serveur** (`tests/it/auth_routes.rs`) : chaque route ; création refusée sans
  authentification récente puis acceptée après réauthentification ; jeton de clé d'API refusé
  sur les routes 🔒 ; mot de passe présent une seule fois et `Cache-Control: no-store` ;
  routes d'administration (installation, organisation, membre d'une autre organisation refusé).
* `scripts/ci/ci_local.sh` complet ; revue ciblée OWASP ASVS niveau 2 (V2.1 à V2.2 : secrets
  générés et limitation des essais ; V3 : sessions).

## 14. Fichiers

`crates/lyxal_auth/` :

* `schema/17_auth_app_password.surql` (nouveau) ; `07_auth_permission.surql`,
  `10_auth_policy.surql`, `12_auth_session.surql`, `16_auth_token.surql` étendus ;
* `functions/app_password/auth_app_password.surql` (nouveau) ; fonctions existantes du §7 ;
* `events/auth_events.surql`, `error/app_passwords/error_app_passwords.surql` (nouveau),
  `seeds/auth_initial.surql` (politique `app_password` de l'installation), `manifest.toml` ;
* `src/services/app_password.rs`, `src/models/app_password.rs` (nouveaux), `store.rs`,
  `services/access.rs`, `purge.rs` ;
* `tests/motsdepasseapp.test.surql`, `tests/it/app_passwords.rs` ;
* `README.md` (tables, contrôle des droits, nouvelle section « Mots de passe d'application »,
  fonctions, événements, Rust), `ROADMAP.md` (alerte « nouvel appareil », rappel avant
  expiration, adresses de courrier comme identifiant au lot 4, SCRAM si P6(h)),
  `MODELE_SOURCES.md` (modèles : Stalwart, RustiCal, comportement seulement).

`crates/lyxal_notification/` : `src/consumer.rs`, `seeds/notification_texts.surql`, tests,
`README.md`.

`apps/lyxal-server/` : `src/http/auth_app_passwords.rs`, `src/http/router.rs` (ou `auth.rs`),
`tests/it/auth_routes.rs`, `README.md`.

Racine : `implementation_plan.md` du programme (lot 1 réalisé). `crates/lyxal_mail/README.md`,
`crates/lyxal_calendar/README.md`, `crates/lyxal_contacts/README.md` : prérequis « lot 1 » noté
comme fait. Ce plan est supprimé une fois exécuté.

Taille estimée : **S** (environ 2 000 à 2 800 lignes Rust + SurrealQL, tests compris).

## 15. Décisions du CTO

À valider par le CTO.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **A1** | Comment garder le mot de passe en base ? | Une **empreinte rapide avec clé secrète** (HMAC-SHA256 avec la clé `code_pepper` déjà en place), pas Argon2id. Raison : le mot de passe est tiré au hasard (99 bits), il ne se devine pas, même si la base fuyait ; Argon2id coûterait à chaque requête d'agenda et à chaque connexion IMAP environ 0,1 à 0,3 s et 64 Mio (non mesuré), et donnerait à un attaquant un moyen simple de saturer le serveur. C'est le sens de « sans Argon2 complet » du programme. |
| **A2** | À quoi ressemble le mot de passe ? | 20 lettres et chiffres sans signes ambigus, en 4 groupes de 5 (`7kq2m-x9tab-hc4wp-3nrfe`), affiché une seule fois. Majuscules, espaces et tirets ignorés à la saisie. Pas de préfixe : il est souvent tapé sur un téléphone. |
| **A3** | Quel identifiant le logiciel envoie-t-il ? | L'adresse e-mail de connexion du compte. Les adresses de courrier du compte (si elles diffèrent) seront acceptées à partir du lot 4 : `lyxal_mail` retrouvera l'identité, puis appellera la même vérification. |
| **A4** | Quels droits peut porter un mot de passe ? | Ceux que l'utilisateur choisit parmi ses propres droits dans **une** organisation, et seulement ceux qu'un module a déclarés utilisables ainsi (nouveau champ `app_password` des permissions, posé par les seeds de `lyxal_mail`, `lyxal_calendar`, `lyxal_contacts`). Jamais la gestion du compte (`auth.*`), jamais un droit qui exige le second facteur. |
| **A5** | Que se passe-t-il si l'utilisateur perd un droit ? | Le mot de passe reste, mais il ne donne plus que les droits encore détenus, recalculés à chaque connexion ; s'il ne reste rien, la connexion est refusée. Un droit retiré pendant une connexion ouverte disparaît au prochain contrôle. |
| **A6** | Quand les mots de passe sont-ils révoqués d'office ? | À la récupération du compte (mot de passe oublié), à la remise à zéro du double facteur par un administrateur (appareil perdu), et à la sortie de l'organisation. **Pas** quand l'utilisateur change lui-même son mot de passe : il n'aurait sinon qu'à reconfigurer tous ses appareils. |
| **A7** | Comment borner le contournement du double facteur ? | Créer un mot de passe d'application est une action sensible : session de la console, second facteur si l'utilisateur en a un, authentification de moins de 15 min. Ensuite le mot de passe s'utilise sans second facteur, mais seulement pour les droits choisis, et chaque création envoie un e-mail d'alerte. |
| **A8** | Comment limiter les essais ? | Blocage **par adresse IP** : 20 échecs en 15 min bloquent cette adresse 15 min (réglable). **Pas de blocage par compte** : sinon n'importe qui couperait la messagerie d'un collègue en tapant de faux mots de passe ; les échecs par compte sont comptés et signalés par un événement. Un ancien appareil dont le mot de passe a été révoqué n'est pas compté, pour ne pas bloquer l'adresse d'un bureau entier. Ces blocages sont séparés de ceux de la console. |
| **A9** | Que contient le journal des connexions ? | Une ligne par mot de passe, protocole et adresse IP, avec première et dernière connexion, nombre et nom du logiciel s'il est connu. Adresse IP en clair (comme les sessions actuelles), gardée 90 jours. Pas d'événement à chaque connexion. |
| **A10** | Comment éviter une vérification et une session par requête ? | Une session par mot de passe d'application, partagée par ses connexions, avec un jeton de 15 min que l'hôte renouvelle sans redemander le mot de passe ; une mémoire de quelques minutes dans `lyxal_auth` pour HTTP Basic. La révocation compte quand même dès l'opération suivante. |
| **A11** | Que peuvent régler l'installation et les organisations ? | Un thème `app_password` de la politique : activé (oui par défaut), 20 mots de passe au plus par personne et par organisation, durée de vie maximale (aucune par défaut), seuils d'essais, durée du journal. Une organisation peut seulement restreindre. Désactiver coupe les connexions en cours mais garde les mots de passe : les réactiver les rend utilisables. |
| **A12** | Faut-il prévenir le titulaire ? | Oui, par l'alerte de sécurité existante de `lyxal_notification` : à la création, et à chaque révocation qu'il n'a pas faite lui-même (administrateur, récupération, sortie de l'organisation). Cela touche `lyxal_notification` (E2). |
| **A13** | Connexion chiffrée obligatoire : qui la contrôle ? | `lyxal_auth`, à partir de l'information donnée par l'hôte des protocoles (TLS, ou HTTPS terminé par un proxy de confiance) : un mot de passe envoyé en clair est refusé, quel que soit le protocole. |
| **A14** | SCRAM-SHA-256 (P6(h)) ? | Hors de ce lot, décidé au lot 8 (IMAP). S'il est retenu, une clé SCRAM est calculée à la création de chaque mot de passe (extension PBKDF2 de `lyxal_crypto`, validée à ce moment-là) et les mots de passe déjà créés sont recréés. |
| **A15** | Un mot de passe d'application ouvre-t-il l'API de `lyxal-server` ? | Non. Il ne sert qu'aux protocoles de `lyxal-groupware`. L'API de la plateforme garde ses jetons et ses clés d'API. |

## 16. Risques

| Risque | Ce qu'il faut savoir | Réponse |
| :--- | :--- | :--- |
| Contournement du double facteur | Un mot de passe d'application volé donne accès sans second facteur aux droits choisis | A4, A7, A12 ; journal visible par le titulaire ; révocation immédiate |
| Blocage d'un bureau entier | Plusieurs personnes derrière la même adresse IP ; un appareil mal configuré peut faire monter le compteur | Seuls les mots de passe inconnus comptent ; seuil réglable ; blocage limité aux mots de passe d'application |
| Charge en base sous attaque | Chaque échec écrit un compteur | Refus immédiat d'une saisie au mauvais format ; limites par IP en mémoire de l'hôte au lot 3 (« limites par IP » du programme) |
| Mémoire courte HTTP Basic | Un mot de passe révoqué peut encore passer l'étape d'authentification de l'hôte quelques minutes | La base refuse dès la première opération (session relue) ; l'hôte traite ce refus comme un échec d'authentification (contrat écrit pour le lot 3) |
| Nombre maximal en course | Deux créations simultanées peuvent dépasser la limite d'une unité | Sans conséquence de sécurité ; test de concurrence noté, non bloquant |
| SurrealDB 3.3.4 | Mise à jour d'une ligne existante du journal sous accès concurrents (même appareil, deux connexions) : conflit d'écriture possible, **non vérifié** | Lecture puis `CREATE` / `UPDATE` comme `auth_login_failure` ; conflit réessayé par l'hôte ; test dédié |
| Faits non vérifiés | Coût réel d'Argon2id sur le matériel cible ; acceptation d'un mot de passe de 23 caractères avec tirets par chaque logiciel (attendu, courant chez Apple et Google) ; majuscule automatique des claviers de téléphone ; nom du logiciel transmis par chaque client (commande IMAP `ID`, `User-Agent`) | Essais réels du lot 8 et des lots DAV (`ROADMAP.md` des modules concernés) |

## 17. Checklist (§13)

* [ ] **Architecture** : responsabilité dans `lyxal_auth` (P8) ; aucun lien vers les modules du
  courrier (E3) ; aucune dépendance nouvelle ; pas de cycle ; règles en SurrealQL, génération,
  empreinte, mémoire courte et jeton en Rust.
* [ ] **Core** : `validation`, `sanitize`, `security`, `utils` vérifiés ; entrées par
  `fn::validation_object_execute` / `fn::sanitize_object_execute` ; aucune primitive recopiée ;
  aucun `THROW` pour une donnée invalide (seule la garde de révocation définitive en lève un).
* [ ] **SurrealQL** : `$params: object`, `fn::result_ok` / `fn::error_result`, `COMMENT`, moins
  de 300 lignes, écriture principale vérifiée (`AUTH_WRITE_FORBIDDEN`), banc complet.
* [ ] **Rust** : `XxxParams` / `XxxResult` nommés, wrappers `call_fn`, aucun `panic!`, aucun
  `raw_query()` métier, secrets en `SecretString` et `Debug` masqué.
* [ ] **Erreurs** : neuf codes `AUTH_APP_PASSWORD_*` en master data, fr et en ; aucune erreur
  masquée.
* [ ] **Événements** : `fn::event_publish` vérifié ; producteur sans connaissance des
  consommateurs ; consommateur de `lyxal_notification` idempotent par identifiant d'événement.
* [ ] **Cryptographie** : `lyxal_crypto` seul (HMAC, BLAKE3, `OsRng`) ; aucune crate crypto ;
  aucun besoin nouveau (SCRAM reporté, A14).
* [ ] **Zéro dette** : schémas réécrits en place ; aucun alias ; tous les appelants de
  `fn::auth_password_set` mis à jour dans le lot ; versions `0.y.z` ; `ROADMAP.md` tenue ; plan
  supprimé une fois exécuté.
* [ ] **Provenance** : aucun code AGPL repris (comportements de Stalwart et RustiCal seulement,
  notés dans `MODELE_SOURCES.md`).
* [ ] **Validation CTO** : écarts E1 à E3, décisions A1 à A15.
