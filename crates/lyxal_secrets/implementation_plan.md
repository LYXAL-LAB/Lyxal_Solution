# Plan d'implémentation — `lyxal_secrets`, lot 1 : socle SurrealQL

Premier lot du programme `lyxal_secrets` (`implementation_plan.md` à la racine, décisions K1 à
B1 validées le 13 novembre 2026). Il crée le module et tout ce qui vit dans SurrealDB : réglages,
fiches de secrets, versions et étiquettes, états, suppression en trois temps, droits par
opération, visibilité, ticket de lecture, journal chaîné, événements. Aucune valeur n'est encore
scellée : le scellement par `lyxal_crypto` arrive au lot 2 ; ici, les tests posent des
enveloppes factices au format `enc:v2:`. Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **L1** | Forme du nom d'un secret | Un **chemin** (`notification/smtp/password`) contrôlé par la règle `lyxal_storage_path` de `lyxal_core` (segments `[A-Za-z0-9._-]` séparés par `/`, 256 caractères au plus), **unique par organisation** tant que le secret n'est pas purgé |
| **L2** | Écritures concurrentes | Chaque nouvelle version est scellée pour **un numéro précis** (le contexte de scellement contient le numéro) : si une autre écriture est passée entre-temps, la seconde est refusée (`SECRETS_VERSION_CONFLICT`) et le service Rust la rejoue (lot 2). Aucune écriture n'en écrase une autre sans le savoir (modèle Vault `cas`) |
| **L3** | Taille maximale d'une valeur | **64 Kio par défaut** (AWS), réglable jusqu'à 1 Mio (limite de `lyxal_crypto`) ; contrôlée par Rust au lot 2, réglage posé ici |
| **L4** | Remise d'une valeur | **Ticket de lecture à usage unique, valable 60 secondes** : créé avec les droits du demandeur et tracé au journal **dans la même transaction**, puis seul le service (session système) peut échanger ce ticket contre l'enveloppe. Sans trace, pas d'enveloppe : la règle « trace avant remise » est tenue par la base elle-même |
| **L5** | Lecture par un programme | Un programme (application ou module) lit avec la permission `secrets.value.read`. Si la fiche liste des **consommateurs prévus**, seul un consommateur listé peut lire (moindre privilège, OWASP 2.11) |
| **L6** | Journal en cas de forte concurrence | Journal **chaîné par organisation** (chaque entrée contient l'empreinte de la précédente) : deux écritures simultanées dans la même organisation se gênent, l'une échoue et est rejouée par le service Rust (lot 2). Choix assumé : pas de trou ni de fourche dans la chaîne |

## 2. Module

Structure canonique (§4) : `manifest.toml` (dépendances `lyxal_core`, `lyxal_error`,
`lyxal_event`, `lyxal_auth`), `schema/`, `functions/`, `events/`, `error/`, `seeds/`, `tests/`,
`README.md`, `ROADMAP.md`. Pas de migration (régime pré-production), version `0.1.0`. Aucun code
Rust dans ce lot : l'hôte porte le module par un `ManifestModule` (`build.rs`).

## 3. Schéma (`TYPE NORMAL SCHEMAFULL`, sans `CHANGEFEED` ni historique natif, décision H1)

| Table | Champs | Règles |
| :--- | :--- | :--- |
| `secrets_settings` | `tenant` (option, `REFERENCE ON DELETE CASCADE`), `scope_key`, `max_versions`, `deleted_retention_days`, `purge_protection`, `max_value_bytes`, `default_visibility`, `expiry_warning_days`, `updated_at` | une ligne par portée ; valeurs effectives : organisation, sinon installation, sinon défauts (10 versions, 30 jours, sans protection, 64 Kio, `restricted`, 30 jours). `purge_protection` ne repasse jamais à `false` (verrou par événement) |
| `secrets_secret` | `tenant`, `scope_key`, `path`, `kind`, `description`, `owner` (identité, `REFERENCE ON DELETE UNSET`), `contact`, `consumers`, `tags`, `metadata`, `visibility`, `expires_at`, `rotation_period`, `next_rotation_at`, `state`, `state_before_delete`, `deleted_at`, `purge_at`, `labels`, `latest_version`, `created_by`, `created_at`, `updated_at` | (`scope_key`, `path`) unique ; `owner`, `created_by`, `created_at` figés (`READONLY`) ; `labels` = `{ current: 3, previous: 2, … }`, une étiquette sur une seule version, 20 au plus ; `kind` parmi `api_key`, `password`, `token`, `oauth_client`, `certificate`, `private_key`, `signing_key`, `connection_string`, `generic` |
| `secrets_version` | `secret` (`REFERENCE ON DELETE CASCADE`), `tenant`, `number`, `envelope`, `key_id`, `keys`, `state`, `created_by`, `created_at`, `destroyed_at` | (`secret`, `number`) unique ; `number` figé ; `envelope` : `select NONE` pour tout utilisateur, format `enc:v2:<key_id>:…` vérifié, jamais modifiée, seulement effacée à la destruction (verrou par événement) ; `keys` = noms des clés d'une valeur JSON, sans valeurs (modèle Vault `subkeys`) |
| `secrets_read_ticket` | `secret`, `version`, `tenant`, `actor`, `consumer`, `expires_at`, `used_at` | créé par `secrets_read_begin` sous les droits du demandeur ; consommé une seule fois par la session système |
| `secrets_audit` | `tenant`, `scope_key`, `seq`, `action`, `outcome`, `actor` (identité ou application), `session_kind`, `ip`, `secret`, `path`, `version`, `details`, `previous_hash`, `entry_hash`, `created_at` | ajout seul : `create`, `update`, `delete` interdits à tout utilisateur ; écrit par des `DEFINE EVENT` ; empreinte par `fn::security_audit_entry` ; jamais de valeur |
| `secrets_audit_head` | `scope_key`, `seq`, `last_hash` | tête de chaîne par organisation |

**États d'un secret** : `active` ↔ `disabled` ; `active` ou `disabled` → `deleted` (date de purge =
maintenant + rétention) ; `deleted` → état d'avant la suppression (`restore`) ; `deleted` →
purgé (fiche et versions supprimées). Purge anticipée : permission `secrets.secret.purge`, et
refusée si l'organisation a activé la protection contre la purge (décision V3).

**États d'une version** : `enabled` ↔ `disabled` ; `enabled` ou `disabled` → `destroyed`
(enveloppe effacée, irréversible). Une version portant une étiquette ne peut pas être détruite :
il faut d'abord déplacer l'étiquette. Au-delà du nombre de versions conservées, la plus ancienne
version **sans étiquette** est détruite dans la même transaction (décision V2).

**Contexte de scellement** (utilisé au lot 2, fixé ici car il dépend du schéma) :
`SecretContext::with_tenant(<organisation> ou "lyxal_installation", "lyxal_secrets",
"secrets_version", "<identifiant du secret>:<numéro>", "value")`.

## 4. Droits

Permissions `lyxal_auth` créées en seed :

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `secrets.secret.list` | organisation | lire les fiches et les versions (sans valeur) |
| `secrets.value.read` | organisation | lire une valeur (humain : secret « révélable » et double facteur, décision V1) |
| `secrets.secret.write` | organisation | créer un secret, modifier sa fiche, ajouter une version, déplacer une étiquette, désactiver, réactiver |
| `secrets.secret.delete` | organisation | supprimer (suppression douce), détruire une version |
| `secrets.secret.restore` | organisation | restaurer un secret supprimé |
| `secrets.secret.purge` | organisation | purger avant la fin du délai |
| `secrets.audit.read` | organisation | lire et vérifier le journal |
| `secrets.settings.manage` | organisation | réglages de l'organisation (dont la protection contre la purge) |
| `secrets.installation.manage` | installation | secrets et réglages de l'installation |
| `secrets.worker` | installation | compte de service : purge à échéance |

Rôles : `organization_admin` reçoit les permissions d'organisation **sauf** `secrets.value.read`
et `secrets.secret.purge`, données explicitement (moindre privilège) ; `platform_admin` reçoit
`secrets.installation.manage` ; `secrets.worker` n'est donnée à aucun rôle. Contrôle unique :
`fn::secrets_can({ action, tenant })`, utilisé par les `PERMISSIONS` des tables et par les
fonctions. Les accès temporaires par chemin (`secrets_grant`) arrivent au lot 4.

## 5. Fonctions publiques (`fn::secrets_*($params: object)`)

Toutes renvoient `fn::result_ok` ou `fn::error_result`. Entrées par
`fn::validation_object_execute` ; règles Core : `record`, `lyxal_storage_path`, `enum`,
`boolean`, `integer`, `optional_string`, `array_of_strings`, `slug`, `lyxal_module_name`,
`future_datetime`, `duration`, `email`, `language_code`.

| Fonction | Paramètres (**obligatoires**) | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `secrets_settings_get` | `tenant` | `{ own, effective }` | liste |
| `secrets_settings_set` | `tenant`, `max_versions`, `deleted_retention_days`, `purge_protection`, `max_value_bytes`, `default_visibility`, `expiry_warning_days`, `clear` | réglages | réglages |
| `secrets_secret_create` | **path**, **kind**, `tenant`, `description`, `contact`, `consumers`, `tags`, `metadata`, `visibility`, `expires_at`, `rotation_period` | fiche, sans version | écriture |
| `secrets_secret_update` | **secret**, champs de la fiche, `clear` | fiche | écriture |
| `secrets_secret_get` | `secret` ou (`tenant`, `path`) | fiche et résumé des versions | liste |
| `secrets_secret_list` | `tenant`, `prefix`, `state`, `tag`, `limit`, `start` | `{ items, total }` | liste |
| `secrets_secret_disable` / `_enable` | **secret** | fiche | écriture |
| `secrets_secret_delete` | **secret** | fiche `deleted`, date de purge | suppression |
| `secrets_secret_restore` | **secret** | fiche dans son état d'avant | restauration |
| `secrets_secret_purge` | **secret** | `{ purged }` | purge |
| `secrets_version_add` | **secret**, **number** (suivant attendu, L2), **envelope**, **key_id**, `keys`, `stage` (`current` par défaut, ou `pending`) | version, étiquettes | écriture |
| `secrets_version_list` | **secret**, `state`, `limit`, `start` | `{ items, total }` sans enveloppe | liste |
| `secrets_version_label` | **secret**, **label**, **number** | étiquettes (retour arrière = déplacer `current`) | écriture |
| `secrets_version_disable` / `_enable` | **secret**, **number** | version | écriture |
| `secrets_version_destroy` | **secret**, **number** | version `destroyed` | suppression |
| `secrets_read_begin` | **secret**, `label` (`current` par défaut) ou `number`, `consumer` | `{ ticket, version, key_id }` | lecture de valeur |
| `secrets_read_envelope` | **ticket** | `{ envelope, context }` | session système seulement |
| `secrets_audit_list` | `tenant`, `secret`, `action`, `since`, `limit`, `start` | `{ items, total }` | journal |
| `secrets_audit_verify` | `tenant`, `from_seq`, `limit` | `{ valid, checked, broken_at }` (par `fn::security_audit_verify`) | journal |
| `secrets_purge_due` | `limit` | `{ purged }` : secrets supprimés dont la date de purge est passée | worker |

Règles de `secrets_read_begin` : refus si le secret est désactivé, supprimé ou expiré, si la
version est désactivée ou détruite, si le demandeur n'est pas un consommateur listé (L5) ; pour
une session humaine, refus d'un secret `restricted` (`SECRETS_REVEAL_FORBIDDEN`) et contrôle
`fn::auth_assurance_check` (double facteur récent) pour un secret `revealable`. La création du
ticket déclenche l'entrée `read` du journal ; les refus sont journalisés par le service Rust
(lot 2), qui seul a les droits d'écrire un refus.

Types Rust `XxxParams` / `XxxResult` et wrappers `store.call_fn` : définis au lot 2, avec le
crate Rust.

## 6. Erreurs (`error/<thème>/`, préfixe `SECRETS_`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `SECRETS_INVALID_PARAMETERS` |
| `permissions` | `SECRETS_PERMISSION_DENIED`, `SECRETS_WRITE_FORBIDDEN` |
| `secrets` | `SECRETS_SECRET_NOT_FOUND`, `SECRETS_SECRET_EXISTS`, `SECRETS_SECRET_STATE_INVALID`, `SECRETS_SECRET_DISABLED`, `SECRETS_SECRET_DELETED`, `SECRETS_SECRET_EXPIRED`, `SECRETS_PURGE_PROTECTED` |
| `versions` | `SECRETS_VERSION_NOT_FOUND`, `SECRETS_VERSION_CONFLICT`, `SECRETS_VERSION_STATE_INVALID`, `SECRETS_VERSION_LABELED`, `SECRETS_LABEL_INVALID`, `SECRETS_ENVELOPE_INVALID` |
| `lecture` | `SECRETS_REVEAL_FORBIDDEN`, `SECRETS_CONSUMER_NOT_ALLOWED`, `SECRETS_READ_TICKET_INVALID` |

## 7. Événements

**Bus `lyxal_event`** (`fn::event_publish`, résultat vérifié, jamais de valeur) :
`secrets.secret.created`, `.updated`, `.disabled`, `.enabled`, `.deleted`, `.restored`,
`.purged` ; `secrets.version.created`, `.disabled`, `.enabled`, `.destroyed`,
`secrets.version.labeled`. Charge : organisation, identifiant et chemin du secret, numéro de
version, étiquettes, auteur.

**Journal** (`DEFINE EVENT` vers `secrets_audit`) : chaque création, modification, changement
d'état, version, étiquette, ticket de lecture, réglage ; auteur (`$auth`), type de session et
adresse (`$session.ip`).

## 8. Core

Aucune extension : `lyxal_storage_path`, `slug`, `enum` et les autres règles existent ;
`fn::security_audit_entry` et `fn::security_audit_verify` fournissent la chaîne. Le contrôle de
l'enveloppe (`enc:v2:<key_id>:`) reste dans le module : c'est le format de `lyxal_crypto`, pas
une règle générique.

## 9. Hôte

`apps/lyxal-server/build.rs` : `lyxal_secrets` embarqué ; tests de démarrage mis à jour
(nombre de modules hébergés).

## 10. Documents

`README.md` et `ROADMAP.md` du module ; `.agents/AGENTS.md` §6 et
`docs/14-roadmap/ROADMAP_NOYAU.md` (`lyxal_secrets` créé) ; ligne 1 du plan racine passée à
« Réalisé ». Ce plan est supprimé dans la demande de fusion de l'implémentation.

## 11. Tests (banc SurrealQL)

* réglages : valeurs effectives, bornes, protection contre la purge irréversible ;
* fiches : création, chemin invalide, doublon dans une organisation et non entre deux,
  modification, champs figés ;
* versions : ajout, conflit de numéro, étiquettes (déplacement, retour arrière, 20 au plus,
  étiquette unique), conservation (la plus ancienne non étiquetée détruite), destruction refusée
  sur une version étiquetée, enveloppe effacée à la destruction ;
* enveloppe jamais lisible par un utilisateur (`SELECT`, `WHERE`, `LIVE`, fonctions), même avec
  toutes les permissions ;
* lecture : ticket créé et tracé ; refus (désactivé, supprimé, expiré, version détruite,
  consommateur non listé, secret `restricted` pour un humain, double facteur manquant) ; ticket
  à usage unique, expiré, refusé à une session non système ;
* suppression en trois temps : suppression, restauration à l'état d'avant, purge à échéance,
  purge anticipée refusée sous protection ;
* journal : une entrée par opération, chaîne vérifiée, modification par la racine détectée,
  aucune valeur ; écriture impossible pour un utilisateur ;
* droits : chaque fonction sous une identité sans permission ; organisations isolées ; écriture
  filtrée par les permissions (`SECRETS_WRITE_FORBIDDEN`) ;
* événements publiés ; rejeu des seeds ; chaque fonction appelée.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 12. Checklist (§13)

* Architecture : module du noyau, sans dépendance vers un module métier ; aucun cycle.
* Core : entrées par le moteur ; aucune extension demandée.
* Crypto : aucune opération dans ce lot ; le format d'enveloppe suit `ENVELOPE_FORMAT_V2.md`.
* Zéro dette : `0.1.0`, aucune migration, aucun alias.
