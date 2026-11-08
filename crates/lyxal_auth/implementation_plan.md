# Plan d'implémentation — `lyxal_auth`, lot 2 (fondations)

Plan détaillé du lot 2 du programme `lyxal_auth` V1 (`implementation_plan.md` à la racine, §6).
Il crée le crate `lyxal_auth` : identités, organisations, rôles, permissions, invitations,
politique, et le contrôle des droits utilisé par tous les modules. Modèle :
[`MODELE_SOURCES.md`](MODELE_SOURCES.md) (Logto, Kratos, Keycloak, Rauthy, Kanidm). Aucun code
avant validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Suite : lot 2 bis (`crates/lyxal_notification/implementation_plan.md`), puis lot 3
(mots de passe, parcours, émission des jetons, routes HTTP).

## 0. Écarts au plan du programme (à valider)

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | La table **`auth_session`** (schéma et lecture) arrive dès ce lot ; sa création, son renouvellement et sa révocation restent au lot 3 | `fn::auth_context` et `fn::auth_has_permission` relisent la session à chaque appel (révocation sur connexion ouverte) : sans la table, le contrôle des droits ne serait ni complet ni testable avant le lot 3, et `lyxal_notification` (lot 2 bis) en dépend |
| E2 | Les permissions s'écrivent avec des **points** (`notification.read`, `ingestion.batch.write`) | Format de la règle `fn::validation_lyxal_permission_name` de `lyxal_core` (les deux-points des exemples précédents sont corrigés partout) |
| E3 | Un événement qui transporte un secret (`auth.invitation.created`) est publié par la **fonction** qui écrit, dans la même transaction, et non par un `DEFINE EVENT` | Le secret scellé n'est ainsi jamais stocké dans la table, même chiffré ; l'échec de la publication annule l'écriture (`THROW`) |
| E4 | Version des permissions : l'identité porte `permissions_version`, incrémenté à chaque changement de rôle ou d'adhésion ; une session dont la version (claim `pv`) est dépassée est refusée (`AUTH_SESSION_STALE`) jusqu'au renouvellement | Un retrait de droit s'applique dès l'opération suivante, sans attendre la fin du jeton de 15 min |

## 1. Périmètre

**Dans le lot 2** : organisations et domaines vérifiés, schéma des traits, identités créées par
un administrateur (sans moyen de connexion), identifiants et adresses, permissions déclarées par
les modules, rôles (installation et organisation, composites), adhésions et attribution des rôles
(tables de relation), invitations, politique, contexte et contrôle des droits, événements,
hébergement par `lyxal-server`.

**Hors lot 2** : mots de passe, parcours de connexion, codes, émission et révocation des sessions
et jetons, accès `DEFINE ACCESS lyxal_auth`, applications et clés d'API, routes HTTP, premier
administrateur (lot 3) ; MFA (lot 4) ; bascule des autres modules (lot 5).

## 2. Modèle de données (`schema/`)

Entités `TYPE NORMAL SCHEMAFULL`, identifiants UUID v7, `created_at` / `updated_at` par `VALUE`,
pas de suppression physique des identités ni des organisations (état puis purge au lot 3).
Champ `tenant : option<record<auth_organization>>` sur les données qui en dépendent (absent =
installation).

### 2.1. Entités

| Table | Champs principaux | Index et gardes |
| :--- | :--- | :--- |
| `auth_organization` | `slug`, `name`, `description`, `state` (`active`, `suspended`, `deleted`), `branding` (objet : logo, couleurs), `custom_data` (objet), `mfa_required` | unique `slug` ; transitions d'état par `DEFINE EVENT` |
| `auth_organization_domain` | `organization` (`record … REFERENCE`, cascade), `domain` (normalisé), `state` (`pending`, `verified`), `challenge_hash` (empreinte du jeton DNS), `verified_at`, `auto_join` (rattachement par domaine e-mail), `default_roles` (`array<record<auth_role>>`) | unique `domain` (un domaine n'appartient qu'à une organisation) |
| `auth_identity_schema` | `key`, `version`, `traits` (schéma du moteur `fn::validation_object_execute`), `identifiers` (traits servant d'identifiant de connexion), `verifiable` (traits à vérifier), `is_default` | unique (`key`, `version`) ; un seul défaut |
| `auth_identity` | `schema` (`record`), `traits` (objet validé par le schéma), `state` (`active`, `inactive`, `locked`, `deleted`), `external_id`, `public_metadata`, `admin_metadata`, `available_aal`, `not_before`, `permissions_version` | unique `external_id` (si présent) |
| `auth_credential_identifier` | `identity` (`REFERENCE`, cascade), `type` (`email`, `username`, `phone`), `value` (normalisé par `lyxal_core`) | **unique (`type`, `value`)** pour toute l'installation (D10) |
| `auth_address` | `identity` (`REFERENCE`, cascade), `channel` (`email`, `phone`), `value`, `usage` (`verification`, `recovery`), `verified_at`, `primary` | unique (`channel`, `value`, `usage`) |
| `auth_permission` | `code` (règle `lyxal_permission_name`), `module`, `scope` (`installation`, `organization`), `description` (fr, en) | unique `code` |
| `auth_role` | `tenant` (absent = rôle défini par l'installation), `key` (règle `lyxal_role_name`), `name`, `description`, `scope` (`installation` : attribué à une identité ; `organization` : attribué à une adhésion), `kind` (`user`, `service`), `is_default` (attribué à toute nouvelle adhésion), `system` (non modifiable) | unique (`tenant`, `key`) |
| `auth_organization_invitation` | `organization`, `email` (normalisé), `roles` (`array<record<auth_role>>`), `inviter` (`record<auth_identity>`), `token_hash` (empreinte BLAKE3 du jeton), `state` (`pending`, `accepted`, `revoked`, `expired`), `expires_at`, `accepted_by` | une seule invitation `pending` par (`organization`, `email`) |
| `auth_policy` | `tenant` (absent = installation), `password` (objet : longueur, complexité, historique), `lockout` (objet : seuil, durée), `session` (objet : durées d'accès, d'inactivité, absolue), `mfa` (objet : exigence, méthodes), `invitation` (objet : durée de validité), `registration` (objet : `mode` = `invitation_only`, D9) | unique `tenant` ; la politique d'une organisation surcharge celle de l'installation, thème par thème |
| `auth_session` (E1) | `identity` (`REFERENCE`, cascade), `organization` (organisation active, option), `state` (`active`, `revoked`, `expired`), `aal`, `amr` (tableau d'objets), `permissions_version`, `created_at`, `last_seen_at`, `idle_expires_at`, `expires_at`, `revoked_at`, `revoked_reason` | lecture par `fn::auth_context` ; écriture par les fonctions du lot 3 seulement |

### 2.2. Relations (`TYPE RELATION ... ENFORCED`)

| Relation | `IN` → `OUT` | Champs | Gardes |
| :--- | :--- | :--- | :--- |
| `auth_member_of` | `auth_identity` → `auth_organization` | `state` (`active`, `suspended`), `joined_at`, `invited_by` | unique (`in`, `out`) |
| `auth_has_role` | `auth_identity` \| `auth_member_of` → `auth_role` | `granted_by`, `granted_at` | unique (`in`, `out`) ; `DEFINE EVENT` : rôle `installation` seulement depuis une identité, rôle `organization` seulement depuis une adhésion, et rôle d'une organisation seulement sur une adhésion à cette organisation |
| `auth_role_includes` | `auth_role` → `auth_role` | — | unique (`in`, `out`) ; même `scope` ; `DEFINE EVENT` refusant un cycle (`AUTH_ROLE_CYCLE`, parcours récursif borné à 8) |
| `auth_role_grants` | `auth_role` → `auth_permission` | — | unique (`in`, `out`) ; `scope` de la permission égal à celui du rôle |

Supprimer une adhésion supprime ses arêtes `auth_has_role` (cascade vérifiée sur SurrealDB 3.3.4,
plan du programme §1.3). Le comportement d'un index unique contenant `tenant = NONE` est vérifié
au début du lot ; s'il ne garantit pas l'unicité, le champ devient une clé explicite `scope_key`
(`"installation"` ou clé d'organisation), appliquée de la même façon à `lyxal_notification`.

### 2.3. Seeds (rejouables)

* Schéma de traits par défaut : `email` (obligatoire, identifiant, vérifiable), `name`
  (`first`, `last`), `locale` (BCP 47), `timezone`.
* Politique de l'installation : mot de passe de 12 caractères minimum, verrouillage après 10
  échecs pendant 15 min, accès 15 min, inactivité 12 h, absolue 30 jours, invitation 7 jours,
  `registration.mode = invitation_only`.
* Permissions `auth.*` (ex. `auth.organization.manage`, `auth.member.manage`,
  `auth.role.manage`, `auth.identity.manage`, `auth.identity.read`, `auth.policy.manage`).
* Rôles : `platform_admin` (installation, système), `organization_admin` et
  `organization_member` (organisation, système, `organization_member` par défaut).
* Aucun compte ni identifiant par défaut : le premier administrateur est créé au lot 3 par une
  commande explicite de l'hôte.

## 3. Contexte et contrôle des droits

```text
fn::auth_context({})
  session système (root de l'hôte)        → { system: true }
  sinon $token.sid → auth_session
     refus si : absente, state ≠ active, expires_at ou idle_expires_at passés,
                created_at < identity.not_before, identité non active,
                $token.pv < identity.permissions_version (AUTH_SESSION_STALE)
     → { identity, session, organization ($token.tenant), permissions ($token.permissions), aal }
  sinon                                   → AUTH_SESSION_REQUIRED

fn::auth_has_permission({ permission, tenant })
  système → vrai ; contexte invalide → faux (jamais d'erreur dans une clause PERMISSIONS)
  permission « installation » : présente dans les permissions de l'identité
  permission « organization » : présente ET tenant = organisation active de la session
```

Les permissions du jeton sont calculées à son émission (lot 3) par `fn::auth_identity_permissions`
(parcours du graphe, plan du programme §1.3) ; le contrôle n'interroge pas le graphe à chaque
ligne. Toute modification d'adhésion ou de rôle incrémente `permissions_version` des identités
concernées (E4). Dans le banc, les claims (`sid`, `pv`, `tenant`, `permissions`) sont portés par
les jetons de test, les sessions créées en préparation.

## 4. Fonctions publiques (`functions/`, `fn::auth_*($params: object)`)

Entrées par `fn::validation_object_execute` / `fn::sanitize_object_execute` (§5.7.8) ; écriture
principale vérifiée (`AUTH_WRITE_FORBIDDEN`) ; permission vérifiée en tête par
`fn::auth_has_permission`.

| Domaine | Fonctions | Permission |
| :--- | :--- | :--- |
| Contexte | `auth_context`, `auth_has_permission` | — |
| Organisations | `auth_organization_create`, `_get`, `_list`, `_update`, `_set_state` | `auth.organization.manage` (installation) ; lecture par les membres |
| Domaines | `auth_organization_domain_add` (reçoit l'empreinte du jeton), `_verify` (reçoit le résultat de la lecture DNS faite en Rust), `_remove`, `_list` | `auth.organization.manage` (organisation) |
| Schéma | `auth_identity_schema_save`, `_get` | `auth.identity.manage` (installation) |
| Identités | `auth_identity_create` (traits validés par le schéma, identifiants et adresses créés), `_get`, `_list`, `_update_traits`, `_set_state` (`not_before` posé si `inactive` ou `locked`) | `auth.identity.manage` / `auth.identity.read` |
| Membres | `auth_organization_member_add`, `_remove` (refus de retirer le dernier `organization_admin`), `_set_state`, `_list` | `auth.member.manage` |
| Permissions | `auth_permission_register` (appelée par les seeds des modules ; rejouable, met à jour la description), `auth_permission_list` | système ou `auth.role.manage` |
| Rôles | `auth_role_create`, `_update`, `_list`, `_permission_set` (remplace les permissions d'un rôle), `_include_set` (rôles inclus), `auth_role_assign`, `_unassign`, `auth_identity_permissions` (`{ identity, organization }` → permissions effectives) | `auth.role.manage` |
| Invitations | `auth_invitation_create` (reçoit l'empreinte et le secret scellé, publie `auth.invitation.created`, E3), `_accept` (identité connectée dont l'adresse correspond : adhésion et rôles prévus créés), `_revoke`, `_list` | `auth.member.manage` ; acceptation par l'invité |
| Politique | `auth_policy_get` (politique effective fusionnée), `_save` | `auth.policy.manage` |

L'acceptation d'une invitation par une personne sans compte (création de l'identité et du mot de
passe) est faite par le parcours d'inscription du lot 3, qui appelle ensuite
`auth_invitation_accept`.

## 5. Contrats Rust (`src/`)

Store `AuthStore` (`Surreal<Any>`, `LyxalSurrealCall`) ; wrappers d'une ligne ; alias
`AuthRecordId`, `AuthDatetime` (`models/types.rs`) ; modèles par domaine (`models/organization.rs`,
`identity.rs`, `role.rs`, `invitation.rs`, `policy.rs`, `context.rs`). Exemples (les autres
fonctions suivent le même schéma, un champ par clé de `$params`) :

```rust
pub struct AuthContext { pub system: bool, pub identity: Option<AuthRecordId>, pub session: Option<AuthRecordId>,
                         pub organization: Option<AuthRecordId>, pub permissions: Vec<String>, pub aal: Option<u8> }
pub struct HasPermissionParams { pub permission: String, pub tenant: Option<AuthRecordId> }

pub struct OrganizationCreateParams { pub slug: String, pub name: String, pub description: Option<String>,
                                      pub branding: Option<OrganizationBranding>, pub mfa_required: bool }
pub struct Organization { pub id: AuthRecordId, pub slug: String, pub name: String, pub state: OrganizationState, /* … */ }

pub struct IdentityCreateParams { pub schema_key: Option<String>, pub traits: Value, pub external_id: Option<String>,
                                  pub state: IdentityState, pub organization: Option<AuthRecordId>, pub roles: Vec<AuthRecordId> }
pub struct Identity { pub id: AuthRecordId, pub traits: Value, pub state: IdentityState, pub available_aal: u8, /* … */ }

pub struct RoleAssignParams { pub role: AuthRecordId, pub identity: AuthRecordId, pub organization: Option<AuthRecordId> }
pub struct IdentityPermissionsParams { pub identity: AuthRecordId, pub organization: Option<AuthRecordId> }
pub struct IdentityPermissions { pub installation: Vec<String>, pub organization: Vec<String>, pub version: u64 }

pub struct InvitationCreateParams { pub organization: AuthRecordId, pub email: String, pub roles: Vec<AuthRecordId>,
                                    pub token_hash: String, pub secret: String /* enc:v2 */, pub expires_at: Option<AuthDatetime> }
pub struct InvitationAcceptParams { pub token_hash: String }
pub struct DomainVerifyParams { pub domain: AuthRecordId, pub observed_txt: Vec<String> }
```

Services (logique système seulement ; les règles restent en SurrealQL) :

* `InvitationService` : jeton de 32 octets (`OsRng`), empreinte `blake3_hex`, lien
  `action_url` construit depuis l'URL publique de l'hôte, objet `{ action_url }` scellé
  (`CryptoEngine::seal`, contexte du contrat d'événement de `lyxal_notification` §2.1), appel de
  `auth_invitation_create` ; acceptation : empreinte du jeton reçu puis `auth_invitation_accept`.
* `DomainVerifier` : jeton de défi (`OsRng`), enregistrement TXT `_lyxal-challenge.<domaine>`
  attendu, lecture DNS par `hickory-resolver`, résultat transmis à `auth_organization_domain_verify`.
* `AuthModule` (`LyxalModule`), `AuthHealthCheck` (`ModuleHealthCheck` : lecture de la politique).
* Aucun secret en clair dans un modèle public ; `Debug` masqué pour les jetons.

Dépendances : `lyxal_core`, `lyxal_error`, `lyxal_surreal`, `lyxal_crypto`, `lyxal_event`,
`lyxal_runtime` ; externe : `hickory-resolver` (MIT / Apache-2.0, résolveur DNS en Rust).

## 6. Master data (`error/`, préfixe `AUTH_`)

Lot 2 : `AUTH_INVALID_PARAMETERS`, `AUTH_WRITE_FORBIDDEN`, `AUTH_PERMISSION_DENIED`,
`AUTH_SESSION_REQUIRED`, `AUTH_SESSION_REVOKED`, `AUTH_SESSION_EXPIRED`, `AUTH_SESSION_STALE`,
`AUTH_IDENTITY_NOT_FOUND`, `AUTH_IDENTITY_INACTIVE`, `AUTH_IDENTIFIER_TAKEN`, `AUTH_TRAITS_INVALID`,
`AUTH_SCHEMA_INVALID`, `AUTH_ORGANIZATION_NOT_FOUND`, `AUTH_ORGANIZATION_SLUG_TAKEN`,
`AUTH_ORGANIZATION_INACTIVE`, `AUTH_DOMAIN_TAKEN`, `AUTH_DOMAIN_NOT_VERIFIED`, `AUTH_NOT_A_MEMBER`,
`AUTH_ALREADY_A_MEMBER`, `AUTH_LAST_ADMIN`, `AUTH_ROLE_NOT_FOUND`, `AUTH_ROLE_KEY_TAKEN`,
`AUTH_ROLE_SCOPE_MISMATCH`, `AUTH_ROLE_CYCLE`, `AUTH_ROLE_SYSTEM`, `AUTH_PERMISSION_UNKNOWN`,
`AUTH_INVITATION_INVALID`, `AUTH_INVITATION_EXPIRED`, `AUTH_INVITATION_EMAIL_MISMATCH`
(fr et en, catégorie, statut HTTP, réessayable).

## 7. Événements

Par `DEFINE EVENT` (vérifiant le résultat de `fn::event_publish`) : `auth.organization.created`,
`auth.organization.state_changed`, `auth.identity.created`, `auth.identity.state_changed`,
`auth.member.added`, `auth.member.removed`, `auth.role.assigned`, `auth.role.unassigned`,
`auth.invitation.accepted`, `auth.invitation.revoked`. Par la fonction (E3) :
`auth.invitation.created` (contrat de `lyxal_notification` §2.1 : `secret` scellé, jamais de
jeton en clair). Aucune charge utile ne contient de secret en clair.

## 8. Fonctions Core réutilisées et besoins signalés

Réutilisées : `fn::validation_object_execute` (règles `email`, `locale`, `timezone`, `slug`,
`domain`, `lyxal_permission_name`, `lyxal_role_name`, `display_name`, `max_length`, `enum`,
`record`, `object`), `fn::sanitize_object_execute` (`email`, `trim`, `lowercase`, `domain`,
`collapse_whitespace`, `remove_control_chars`). Le schéma des traits est un schéma du moteur
`lyxal_core`, validé à l'enregistrement. Aucune fonction Core manquante identifiée. Crypto :
`blake3_hex`, `CryptoEngine::seal`, `OsRng` ; aucun besoin nouveau.

## 9. Tests

* **Banc SurrealQL** : chaque fonction publique ; cas nominaux et erreurs ; unicité (slug,
  domaine, identifiant e-mail, adhésion, rôle) ; gardes des relations (portée, organisation,
  cycle de rôles) ; cascade adhésion → rôles ; rôles composites et permissions effectives ;
  `permissions_version` et session dépassée ; session révoquée, expirée, antérieure à
  `not_before` ; isolement (une organisation ne lit ni ne modifie une autre ; écriture filtrée →
  `AUTH_WRITE_FORBIDDEN`) ; dernier administrateur ; invitation (création, acceptation par la
  bonne adresse, mauvaise adresse, expirée, révoquée, rejouée) ; seeds rejouées sans doublon.
* **Rust** : jeton d'invitation (longueur, empreinte, secret scellé ouvrable seulement avec le
  bon contexte), vérification de domaine contre un résolveur de test, wrappers DTO ↔ SurrealQL.
* **Serveur réel** : installation et rejeu par `lyxal-server` sur SurrealDB 3.3.4 ; révocation
  d'une session sur une connexion WebSocket restée ouverte (opération suivante refusée).
* `scripts/ci/ci_local.sh` complet.

## 10. Fichiers

`crates/lyxal_auth/` : `manifest.toml`, `Cargo.toml`, `schema/`, `migrations/0001_initial.surql`,
`functions/` (un fichier par domaine), `events/`, `error/<thème>/`, `seeds/`, `tests/`, `src/`,
`README.md`, `ROADMAP.md` (lots 3 à 6, V2, V3) ; `RECHERCHE_SOURCES.md`, `MODELE_SOURCES.md` et
`sources/` réduits aux sources retenues ; `NOTICE` (Rauthy, Kratos, Keycloak : Apache-2.0) si du
code est transcrit. Hébergement : `apps/lyxal-server/build.rs`, `src/modules/auth.rs`. Racine :
`Cargo.toml`. Correction E2 dans `crates/lyxal_notification/implementation_plan.md`. Ce plan est
supprimé une fois exécuté.

## 11. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | Écarts E1 à E4 (§0) | Valider |
| Q2 | Rôles définis par une organisation elle-même (en plus des rôles de l'installation) dès ce lot | Oui : `auth_role.tenant` le permet sans coût supplémentaire (modèle Logto + Keycloak) |
| Q3 | Vérification des domaines par enregistrement DNS TXT dès ce lot (dépendance `hickory-resolver`) | Oui : nécessaire au rattachement automatique par domaine e-mail, sans service externe |
