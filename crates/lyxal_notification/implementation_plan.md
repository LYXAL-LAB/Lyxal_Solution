# Plan d'implémentation — `lyxal_notification`, lot V1-a (e-mail pour `lyxal_auth`)

Plan détaillé du lot « 2 bis » du programme `lyxal_auth` V1 (`implementation_plan.md` à la
racine, décision D8). Il crée le crate `lyxal_notification` avec le seul canal e-mail, assez
complet pour les messages de `lyxal_auth` (vérification d'adresse, récupération, invitation).
Modèle et sources : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) (Novu, Postal) et
[`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md). Aucun code avant validation de ce plan par le
CTO (`.agents/AGENTS.md` §3).

**Ordre** : ce lot s'exécute **après le lot 2 de `lyxal_auth`** (organisations, permissions,
`fn::auth_context`, `fn::auth_has_permission`, dont dépendent les `PERMISSIONS` des tables) et
**avant son lot 3** (qui publie les événements consommés ici).

## 0. Décisions du CTO (8 novembre 2026)

| # | Décision |
| :- | :--- |
| N1 | Un code ou un lien voyage **scellé** (`enc:v2`) dans l'événement ; seul `lyxal_notification` l'ouvre. Jamais stocké ni journalisé en clair |
| N2 | En attendant `lyxal_secrets` : mot de passe SMTP lu dans la configuration de l'hôte (`SecretString`). En attendant `lyxal_i18n` : langue BCP 47 validée par `lyxal_core`, repli sur le français. Pas d'envoi différé avant `lyxal_scheduler` |
| N3 | Nouvelles tentatives dès V1-a : attente croissante avec gigue ; refus définitif d'une adresse → liste de suppression |
| N4 | Signature DKIM faite par le relais SMTP ; aucune cryptographie ajoutée |
| N5 | SMTP seul en V1-a ; fournisseurs par API (SES, Postmark…) en V1-e |
| N6 | HTML simple (gabarits MiniJinja) ; MJML plus tard |
| N7 | Agents IA hors module ; suivi des ouvertures et clics désactivé par défaut (V2) |

## 1. Périmètre

**Dans V1-a** : parcours à une étape e-mail déclenchés par événement ou par appel direct,
gabarits par langue, mise en page commune, file d'envoi avec tentatives, journal, liste de
suppression, réglages par locataire, purge, handlers des trois événements `auth.*`, worker
d'envoi, sonde de santé, hébergement par `lyxal-server`.

**Hors V1-a** (lots suivants de `MODELE_SOURCES.md` §4) : abonnés, sujets, préférences et tables
de relation associées (V1-b) ; délais, digest, throttle, conditions (V1-c) ; fil in-app (V1-d) ;
autres canaux et fournisseurs par API, retours de rejets asynchrones (V1-e) ; console, aperçu,
statistiques, traductions `lyxal_i18n`, intégrations par locataire avec `lyxal_secrets` (V2).

Conséquence assumée : pas de table `notification_integration` en V1-a. Le serveur SMTP est unique
pour l'installation (configuration de l'hôte) ; la table arrive avec `lyxal_secrets`, sans rien à
migrer (régime zéro dette).

## 2. Architecture

```text
lyxal_auth ──DEFINE EVENT──► event_outbox ──lyxal_event──► handler Rust (lyxal_notification)
                                                              │ ouvre le secret (N1)
                                                              │ le rescelle pour sa propre file
                                                              ▼
                                                fn::notification_trigger (SurrealQL)
                                                  run + job, idempotent, suppression
                                                              ▼
              NotificationEmailWorker (LyxalWorker) ◄── fn::notification_job_claim
                 rendu MiniJinja, envoi lettre (SMTP, TLS rustls)
                              │
                              ├─ succès ─► fn::notification_job_complete ─► message, journal
                              └─ échec  ─► fn::notification_job_fail ─► nouvelle tentative,
                                                                         échec définitif,
                                                                         suppression
```

| Couche | Rôle |
| :--- | :--- |
| SurrealQL | tables, validation par `lyxal_core`, idempotence, choix du parcours et du gabarit (langue de repli), file (réservation, tentatives, états), suppression, réglages, purge, événements `notification.*` |
| Rust | handlers `auth.*`, ouverture et rescellement des secrets (`lyxal_crypto`), rendu (`minijinja`), envoi SMTP (`lettre`), calcul du délai de nouvelle tentative (gigue, comme `lyxal_event`), worker, sonde |
| Hôte | configuration SMTP et trousseau applicatif (`CryptoEngine`) partagés, enregistrement du module, du consommateur, du worker et de la sonde |

### 2.1. Contrat des événements `auth.*` consommés (repris tel quel par le lot 3 de `lyxal_auth`)

Le producteur ne connaît pas le consommateur (§5.6.1) : ce contrat est celui de `lyxal_auth`,
fixé ici parce que ce lot est le premier à le lire. Champs de la charge utile :

| Champ | Type | Contenu |
| :--- | :--- | :--- |
| `tenant` | `option<string>` | clé de l'organisation ; absent pour un événement de l'installation (récupération d'une identité, D10) |
| `identity_id` | `string` | identité concernée |
| `recipient_email` | `string` | adresse de destination |
| `recipient_locale` | `option<string>` | BCP 47 |
| `recipient_name` | `option<string>` | nom affiché |
| `expires_at` | `datetime` | fin de validité du code ou du lien |
| `secret` | `string` | enveloppe `enc:v2` d'un objet JSON de variables sensibles (`action_url`, `code`) |
| `organization_name`, `inviter_name` | `option<string>` | `auth.invitation.created` seulement |

Événements : `auth.verification.requested`, `auth.recovery.requested`, `auth.invitation.created`.

**Contexte de scellement** (N1) : `SecretContext::with_tenant(tenant ?? "lyxal_installation",
"lyxal_auth", <type d'événement, points remplacés par `_`>, <event_id>, "secret")`. Il lie
l'enveloppe à son événement : une enveloppe recopiée dans un autre événement ne s'ouvre pas.

Dans la file, le secret est **rescellé** sous le contexte du module :
`with_tenant(tenant ?? "lyxal_installation", "lyxal_notification", "notification_run",
<idempotency_key>, "secret")`. Il est effacé (`secret = NONE`) dès que toutes les étapes du
déclenchement sont terminées (succès, échec définitif, annulation) ou à `expires_at`.

## 3. Modèle de données (`schema/`, préfixe `notification_`)

Toutes les tables sont `TYPE NORMAL SCHEMAFULL`. Champ `tenant : option<record<auth_organization>>`
(absent = installation) ; `PERMISSIONS` par `fn::auth_has_permission` (§6). Pas de table de
relation en V1-a : les associations de graphe (abonné ↔ sujet, préférences, adresses de canal)
arrivent en V1-b ; les liens parent → enfant restent des `record<…>` (pas de parcours de graphe).

| Table | Champs principaux | Index |
| :--- | :--- | :--- |
| `notification_settings` | `tenant`, `default_locale` (défaut `fr`), `from_name`, `reply_to`, `max_attempts` (défaut 8), `retention_days_runs` (90), `retention_days_log` (30) | unique `tenant` |
| `notification_workflow` | `tenant`, `key`, `name`, `trigger_event` (nom d'événement `lyxal_event`), `status` (`draft`, `active`, `inactive`), `critical` (ignore désabonnements et préférences), `sensitive` (aucun contenu rendu conservé), `payload_schema` (schéma `fn::validation_object_execute`), `steps` (tableau d'objets ordonnés ; V1-a : `{ key, channel: "email", template }`), `tags`, `created_at`, `updated_at` | unique (`tenant`, `key`) ; (`tenant`, `trigger_event`, `status`) |
| `notification_layout` | `tenant`, `key`, `name`, `html` (doit contenir `{{ content }}`), `text` | unique (`tenant`, `key`) |
| `notification_template` | `tenant`, `workflow`, `step_key`, `default_locale`, `layout` (`option<record>`) | unique (`workflow`, `step_key`) |
| `notification_template_locale` | `template`, `locale`, `subject`, `html_body`, `text_body`, `updated_at` | unique (`template`, `locale`) |
| `notification_run` | `tenant`, `workflow`, `idempotency_key`, `event_id`, `recipient` (`{ email, locale, name }`), `payload` (variables non sensibles), `secret` (`option<string>` `enc:v2`), `status` (`pending`, `completed`, `failed`, `skipped`), `skip_reason`, `created_at`, `expires_at` | unique (`tenant`, `idempotency_key`) |
| `notification_job` | `run`, `step_key`, `channel`, `status` (`queued`, `running`, `completed`, `failed`, `skipped`, `canceled`), `attempts`, `max_attempts`, `next_retry_at`, `locked_until`, `claim_token`, `last_error` (`{ class, code, detail }`) | (`status`, `next_retry_at`) |
| `notification_message` | `run`, `job`, `channel`, `to`, `subject` (absent si `sensitive`), `provider` (`smtp`), `provider_message_id`, `status` (`sent`, `rejected`), `sent_at`, `expires_at` | `run` |
| `notification_delivery_log` | `run`, `job`, `attempt`, `status`, `code`, `detail` (jamais de secret ni de corps), `at`, `expires_at` | `run`, `expires_at` |
| `notification_suppression` | `tenant`, `channel`, `address` (normalisée), `reason` (`hard_bounce`, `complaint`, `unsubscribe`, `manual`), `source`, `created_at`, `keep_until` | unique (`tenant`, `channel`, `address`) |

Règle de suppression : un parcours `critical` ignore `unsubscribe`, mais jamais `hard_bounce`
(une adresse inexistante ne recevra rien). Le comportement d'un index unique contenant `tenant =
NONE` est vérifié sur SurrealDB 3.3.4 au début du lot ; s'il ne garantit pas l'unicité, le champ
devient une clé explicite `scope` (`"installation"` ou clé d'organisation).

Seeds (rejouables, `IF !record::exists(...)`) : réglages de l'installation, mise en page par
défaut, trois parcours de l'installation (`auth_verification`, `auth_recovery`,
`auth_invitation`, `critical` et `sensitive`) avec gabarits `fr` et `en`.

## 4. Fonctions publiques (`functions/`, `fn::notification_*($params: object)`)

Entrées validées et nettoyées par `fn::validation_object_execute` / `fn::sanitize_object_execute`
(§5.7.8). Chaque écriture principale est vérifiée (`NOTIFICATION_WRITE_FORBIDDEN`, §11.4).

| Fonction | Rôle | Permission |
| :--- | :--- | :--- |
| `notification_trigger` | crée un déclenchement idempotent pour un destinataire : parcours actif par `workflow_key` ou `trigger_event`, validation du `payload` par son `payload_schema`, suppression, création des étapes ; un rejeu renvoie le déclenchement existant | `notification.send` |
| `notification_workflow_create` / `_update` / `_get` / `_list` / `_set_status` | gestion des parcours (pas de suppression : `inactive`) | `notification.manage` / `notification.read` |
| `notification_layout_create` / `_update` / `_get` / `_list` | mises en page (HTML nettoyé : scripts, iframes, attributs d'événement retirés) | idem |
| `notification_template_create` / `_get` | gabarit d'une étape | idem |
| `notification_template_locale_set` / `_delete` | version d'un gabarit dans une langue (HTML nettoyé) ; la langue par défaut ne peut pas être supprimée | idem |
| `notification_settings_get` / `_set` | réglages du locataire (repli sur ceux de l'installation) | idem |
| `notification_suppression_add` / `_remove` / `_list` | liste de suppression | idem |
| `notification_run_get` / `_list` | activité : déclenchements, étapes, messages, journal | `notification.read` |
| `notification_job_claim` | réserve jusqu'à `limit` étapes dues (`queued`, `next_retry_at <= now`, réservation expirée), pose `locked_until` et un `claim_token`, renvoie tout le nécessaire au rendu (gabarit dans la langue résolue : exacte → langue seule → défaut ; mise en page ; réglages ; secret scellé) | `notification.worker` |
| `notification_job_complete` | vérifie `claim_token`, crée le message et le journal, termine l'étape, efface le secret si le déclenchement est fini | `notification.worker` |
| `notification_job_fail` | vérifie `claim_token` ; `transient` : nouvelle tentative après `retry_delay_seconds` tant que `attempts < max_attempts`, sinon échec définitif ; `permanent` : échec définitif ; `recipient_rejected` : échec définitif et suppression `hard_bounce` | `notification.worker` |
| `notification_purge` | supprime les déclenchements, messages et journaux expirés, efface les secrets expirés, par paquets | `notification.worker` |

Permissions déclarées par le seed du module (`fn::auth_permission_register`, lot 2 de `lyxal_auth`) : `notification.read`,
`notification.manage`, `notification.send`, `notification.worker` (compte de service du worker).

## 5. Contrats Rust (`src/`)

Store `NotificationStore` (`Surreal<Any>`, `LyxalSurrealCall`) ; wrappers d'une ligne
`store.call_fn("notification_…", params)`. Types `SurrealValue`, identifiants `RecordId`, dates
`Datetime` (alias dans `models/types.rs`).

```rust
pub struct Recipient { pub email: String, pub locale: Option<String>, pub name: Option<String> }
pub struct TriggerParams {
    pub tenant: Option<NotificationRecordId>, pub workflow_key: Option<String>,
    pub trigger_event: Option<String>, pub idempotency_key: String, pub event_id: Option<String>,
    pub recipient: Recipient, pub payload: serde_json::Map<String, Value> /* converti SurrealValue */,
    pub secret: Option<String> /* enc:v2 sous le contexte du module */, pub expires_at: Option<NotificationDatetime>,
}
pub enum TriggerStatus { Created, Duplicate, Skipped }
pub struct TriggerResult { pub run_id: NotificationRecordId, pub status: TriggerStatus, pub skip_reason: Option<String>, pub job_ids: Vec<NotificationRecordId> }

pub struct JobClaimParams { pub worker_id: String, pub limit: u32, pub lease_seconds: u32 }
pub struct ClaimedJob {
    pub job_id: NotificationRecordId, pub claim_token: String, pub run_id: NotificationRecordId,
    pub tenant: Option<NotificationRecordId>, pub idempotency_key: String, pub attempt: u32,
    pub recipient: Recipient, pub locale: String, pub subject: String, pub html_body: String,
    pub text_body: String, pub layout_html: Option<String>, pub layout_text: Option<String>,
    pub payload: Value, pub secret: Option<String>, pub sensitive: bool,
    pub from_name: Option<String>, pub reply_to: Option<String>,
}
pub struct JobCompleteParams { pub job_id: NotificationRecordId, pub claim_token: String, pub provider_message_id: Option<String>, pub smtp_code: Option<u16>, pub subject: Option<String> }
pub enum FailureClass { Transient, Permanent, RecipientRejected }
pub struct JobFailParams { pub job_id: NotificationRecordId, pub claim_token: String, pub class: FailureClass, pub code: String, pub detail: String, pub retry_delay_seconds: u32 }
pub struct JobOutcome { pub status: JobStatus, pub next_retry_at: Option<NotificationDatetime> }
pub struct PurgeParams { pub limit: u32 }
pub struct PurgeResult { pub runs: u64, pub messages: u64, pub log_entries: u64, pub secrets_cleared: u64 }
```

Les `XxxParams` / `XxxResult` des fonctions de gestion (§4) suivent le même schéma : un champ par
clé de `$params`, vérifiés par le banc (contrôle DTO ↔ SurrealQL de `lyxal-audit`).

Composants :

* `NotificationModule` (`LyxalModule`) ; `NotificationConsumer` (`EventConsumerModule`) avec un
  handler typé par événement `auth.*` (`impl Event`, idempotent par `event_id` grâce à
  l'index unique ; secret illisible → `terminal: true`, base indisponible → `terminal: false`).
* `NotificationEmailWorker` (`LyxalWorker`, `CancellationToken`) : réserve, ouvre le secret, rend,
  envoie, termine ou échoue ; délai = attente exponentielle plafonnée avec gigue complète
  (base 30 s, plafond 6 h, réglables).
* Classement SMTP : connexion ou 4xx → `transient` ; 5xx sur le destinataire (550, 551, 553) →
  `recipient_rejected` ; autre 5xx, gabarit invalide → `permanent`.
* Rendu : `minijinja` sans chargeur de fichiers, variable inconnue = erreur, échappement HTML
  automatique pour le HTML, budget d'exécution (`fuel`) ; variables `recipient`, `payload`,
  `secret`, `organization` ; le corps rendu n'est conservé nulle part.
* `NotificationPurgeWorker` (`LyxalWorker`) : `notification_purge` toutes les 10 minutes.
* `NotificationHealthCheck` (`ModuleHealthCheck`) : connexion SMTP (`NOOP`), latence mesurée.
* Configuration de l'hôte : `LYXAL__NOTIFICATION__SMTP__HOST`, `__PORT`, `__SECURITY`
  (`starttls` ou `tls`), `__USERNAME`, `__PASSWORD` (`SecretPassword`), `__FROM_ADDRESS`,
  `__FROM_NAME`. Sans configuration : module installé, worker non démarré, sonde « dégradé »
  (même règle que la publication vers le catalogue).

Dépendances ajoutées : `lettre` 0.11 (sans options par défaut ; `tokio1-rustls`, `builder`,
`smtp-transport`, `pool` ; pas `dkim`, N4) et `minijinja` 3 (MIT / Apache-2.0). Aucune crate
cryptographique : tout passe par `lyxal_crypto`.

## 6. Permissions des tables

Lecture : `fn::auth_has_permission({ permission: "notification.read", tenant: $this.tenant })`. Écriture : par les
fonctions seulement (`notification.manage`, `notification.send`, `notification.worker`) ; un
locataire ne voit ni ne modifie jamais les données d'un autre ; les données de l'installation
(`tenant = NONE`) relèvent des administrateurs de l'installation. Les réglages fins (qui peut lire
le journal) suivent la portée des permissions définie par le lot 2 de `lyxal_auth`.

## 7. Master data (`error/`, préfixe `NOTIFICATION_`)

`INVALID_INPUT`, `WRITE_FORBIDDEN`, `NOT_FOUND`, `WORKFLOW_KEY_TAKEN`, `WORKFLOW_NOT_FOUND`,
`WORKFLOW_INACTIVE`, `PAYLOAD_INVALID`, `TEMPLATE_LOCALE_MISSING`, `TEMPLATE_DEFAULT_LOCALE_REQUIRED`,
`LAYOUT_CONTENT_SLOT_MISSING`, `JOB_CLAIM_LOST`, `JOB_STATE_INVALID`, `SECRET_UNAVAILABLE`,
`RENDER_FAILED`, `SMTP_TRANSIENT`, `SMTP_PERMANENT`, `SMTP_RECIPIENT_REJECTED`,
`SMTP_NOT_CONFIGURED` (fr et en, retryable renseigné).

## 8. Événements publiés (`events/`, `fn::event_publish`)

`notification.message.sent`, `notification.message.failed`, `notification.address.suppressed`
(identifiants, parcours, canal, adresse pour la suppression ; jamais de contenu ni de secret).
`DEFINE EVENT` vérifiant le résultat de `fn::event_publish` (`THROW` sinon).

## 9. Fonctions Core réutilisées et besoins signalés

Réutilisées : `fn::validation_object_execute` (règles `email`, `locale`, `lyxal_event_name`,
`snake_case_name`, `idempotency_key`, `max_length`, `integer_range`, `enum`, `record`),
`fn::sanitize_object_execute` (`email`, `trim`, `strip_scripts`, `strip_event_handlers`,
`strip_iframes`, `remove_control_chars`). Aucune fonction Core manquante identifiée ; le calcul du
délai de nouvelle tentative reste en Rust, comme dans `lyxal_event`. Aucun besoin crypto nouveau.

## 10. Tests

* **Banc SurrealQL** (`tests/*.test.surql`) : chaque fonction publique ; idempotence du
  déclenchement (rejeu = `Duplicate`, aucune étape en plus) ; suppression (`critical` contre
  `unsubscribe` et `hard_bounce`) ; langue de repli ; réservation concurrente (une étape réservée
  une seule fois), `claim_token` périmé refusé ; tentatives jusqu'à `max_attempts` ; effacement
  du secret ; purge ; permissions (autre organisation refusée, écriture filtrée →
  `NOTIFICATION_WRITE_FORBIDDEN`) ; seeds rejouées sans doublon.
* **Rust** : rendu (échappement, variable inconnue, budget), classement des codes SMTP, délai avec
  gigue borné, handlers (secret valide, enveloppe d'un autre événement refusée, rejeu), worker de
  bout en bout contre un **serveur SMTP de test** embarqué dans les tests (acceptation, 4xx puis
  succès, 550 → suppression), aucune trace du code dans la base ni dans les journaux.
* **Serveur réel** : installation et rejeu par `lyxal-server` sur SurrealDB 3.3.4.
* `scripts/ci/ci_local.sh` complet.

## 11. Fichiers

`crates/lyxal_notification/` : `manifest.toml`, `Cargo.toml`, `schema/`, `migrations/0001_initial.surql`,
`functions/`, `events/`, `error/`, `seeds/`, `tests/`, `src/` (`models/`, `store.rs`,
`consumer.rs`, `worker/`, `render.rs`, `smtp.rs`, `health.rs`, `lib.rs`), `README.md`,
`ROADMAP.md` (lots V1-b à V3). `RECHERCHE_SOURCES.md` et `MODELE_SOURCES.md` réduits aux sources
retenues ; `NOTICE` pour Novu et Postal (MIT) si du code est transcrit. Hébergement :
`apps/lyxal-server/build.rs`, `src/modules/notification.rs`, `src/config.rs`. Racine :
`Cargo.toml` (membre), `.agents/AGENTS.md` §6 et `ROADMAP_NOYAU.md` (rang de
`lyxal_notification` avancé, D8). Ce plan est supprimé une fois exécuté.

## 12. Checklist (§13)

* Architecture : responsabilité du module ; aucune dépendance vers un module métier ; producteurs
  ignorants du consommateur ; frontière SurrealQL / Rust respectée.
* Core : entrées par le moteur `lyxal_core` ; aucun `THROW` pour une donnée invalide.
* SurrealQL : `$params: object`, `result_ok` / `error_result`, `COMMENT`, < 300 lignes, écriture
  vérifiée, banc complet.
* Rust : `XxxParams` / `XxxResult`, wrappers `call_fn`, aucun `panic!`, secrets en `SecretString`,
  aucun `raw_query()` métier.
* Crypto : `lyxal_crypto` seulement, contextes non vides, aucune nouvelle primitive.
* Zéro dette : une migration, aucune table à moitié utilisée, versions `0.1.0`.

## 13. Questions au CTO

Q1 à Q3 validées par le CTO le 8 novembre 2026 : contrat des événements `auth.*` fixé ici
(§2.1) ; un seul serveur SMTP pour l'installation avant `lyxal_secrets` ; pas de limitation de
débit dans ce lot (anti-abus par `lyxal_auth`, `notification_rate_limit` en V1-c).
