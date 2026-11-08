# Lyxal Auth

Module du Noyau Technique de Lyxal OS : **identités, organisations, rôles, permissions,
invitations et contrôle des droits**. Toutes les règles vivent dans SurrealDB (fonctions
`fn::auth_*`) ; le crate Rust fournit les appels typés et ce qui relève du système (aléa,
empreintes, scellement, DNS). Modèle repris de Logto, Kratos, Keycloak, Rauthy et Kanidm
([`MODELE_SOURCES.md`](MODELE_SOURCES.md)).

État : lot 2 du programme `lyxal_auth` V1 (fondations). Connexion, sessions émises, jetons et
routes HTTP : lot 3 ; double facteur : lot 4 ([`ROADMAP.md`](ROADMAP.md)).

## 1. Modèle (SurrealDB multi-modèle)

| Table | Type | Contenu |
| :--- | :--- | :--- |
| `auth_organization` | document | organisation cliente, **locataire** des données métier (`tenant`) ; état `active` / `suspended` / `deleted` |
| `auth_organization_domain` | document | domaine e-mail, vérifié par DNS TXT (`_lyxal-challenge.<domaine>`) lu par l'hôte sur sa session système (seule à changer l'état et à lire l'empreinte du défi), rattachement automatique |
| `auth_identity_schema` | document | schéma des traits (moteur `lyxal_core`), versionné |
| `auth_identity` | document | identité : traits, état, `not_before`, `permissions_version` |
| `auth_credential_identifier` | document | identifiant de connexion normalisé, **unique pour l'installation** (un e-mail = une identité) |
| `auth_address` | document | adresses de vérification et de récupération |
| `auth_permission` | document | permission déclarée par un module (identifiant = code, une seule portée) |
| `auth_role` | document | rôle de l'installation ou propre à une organisation ; portée `installation` / `organization` |
| `auth_organization_invitation` | document | invitation expirante ; seule l'empreinte BLAKE3 du jeton est conservée |
| `auth_policy` | document | politique (mots de passe, verrouillage, sessions, MFA, invitations, inscription) de l'installation et surcharges par organisation |
| `auth_session` | document | session relue à chaque contrôle des droits (écrite par le lot 3) |
| `auth_member_of` | **relation** identité → organisation | adhésion |
| `auth_has_role` | **relation** identité ou adhésion → rôle | rôle d'installation (identité) ou d'organisation (adhésion, supprimé avec elle) |
| `auth_role_includes` | **relation** rôle → rôle | rôles composites, sans cycle |
| `auth_role_grants` | **relation** rôle → permission | permissions d'un rôle (même portée) |

Unicité « par installation ou par organisation » : champ `scope_key` (`installation` ou clé de
l'organisation), un index unique ignorant les valeurs absentes.

## 2. Contrôle des droits (pour tous les modules)

* `fn::auth_context({})` : `{ system, identity, session, organization, permissions, aal }`.
* `fn::auth_has_permission({ permission, tenant })` : booléen, jamais d'erreur, utilisable dans
  une clause `PERMISSIONS`. Permission d'installation : portée par le jeton. Permission
  d'organisation : portée par le jeton **et** `tenant` = organisation active de la session.
* La session (`$auth`) est relue à chaque appel : révoquée, expirée (absolue ou inactivité),
  antérieure au `not_before` de l'identité, identité inactive, ou version des droits du jeton
  (`pv`) dépassée → aucun droit, même sur une connexion WebSocket restée ouverte.
* Session système (root de l'hôte) : tous les droits.
* Tout retrait de droit (adhésion supprimée ou suspendue, rôle retiré, permission ou inclusion
  retirée d'un rôle) incrémente `permissions_version` des identités concernées par un événement
  de la base, après l'écriture : l'appelant qui retire ses propres droits n'est pas bloqué.

Permissions du socle (une portée par code) :

| Installation | Organisation |
| :--- | :--- |
| `auth.organization.manage`, `auth.identity.manage`, `auth.identity.read`, `auth.role.manage`, `auth.policy.manage` | `auth.organization.settings.manage`, `auth.member.manage`, `auth.member.read`, `auth.organization.role.manage`, `auth.organization.policy.manage` |

Rôles du socle : `platform_admin` (installation), `organization_admin` et `organization_member`
(organisation ; `organization_member` attribué par défaut).

Un module déclare ses permissions dans son seed, de façon rejouable et non destructive :

```surql
IF !record::exists(auth_permission:⟨notification.read⟩) THEN (
    CREATE auth_permission:⟨notification.read⟩ CONTENT { code: "notification.read", module: "lyxal_notification", scope: "organization", description: { fr: "…", en: "…" } }
) END;
```

## 3. Fonctions publiques

| Domaine | Fonctions |
| :--- | :--- |
| Contexte | `auth_context`, `auth_has_permission`, `auth_session_valid`, `auth_shares_organization`, `auth_invitation_pending` |
| Organisations | `auth_organization_create` (avec administrateur), `_get`, `_list`, `_update`, `_set_state` |
| Domaines | `auth_organization_domain_add`, `_get`, `_verify` (session système), `_update`, `_remove`, `_list` |
| Membres | `auth_organization_member_add`, `_remove`, `_set_state`, `_list`, `auth_membership_create`, `auth_is_last_admin` |
| Identités | `auth_identity_schema_save`, `_get`, `auth_identity_create`, `_get`, `_list`, `_update_traits`, `_set_state`, `auth_identity_derive` |
| Permissions | `auth_permission_register` (création seule), `_update`, `_list` |
| Rôles | `auth_role_create`, `_update`, `_list`, `_permission_set`, `_permission_grant`, `_include_set`, `auth_role_assign`, `_unassign`, `auth_role_can_manage`, `auth_role_target`, `auth_role_holders`, `auth_identity_permissions` |
| Invitations | `auth_invitation_create`, `_accept`, `_revoke`, `_list` |
| Politique | `auth_policy_get` (effective), `auth_policy_save` |

Entrées validées et nettoyées par `lyxal_core` ; erreurs `AUTH_*` (master data `error/`) ;
toute écriture vérifiée (`AUTH_WRITE_FORBIDDEN`). Un identifiant ou un domaine déjà utilisé par
une identité ou une organisation **invisible** pour l'appelant est détecté par l'index unique
(`INSERT IGNORE`), sans rien révéler de son propriétaire.

## 4. Événements

`auth.organization.created`, `auth.organization.state_changed`, `auth.identity.created`,
`auth.identity.state_changed`, `auth.member.added`, `auth.member.removed`, `auth.role.assigned`,
`auth.role.unassigned`, `auth.invitation.created`, `auth.invitation.accepted`,
`auth.invitation.revoked` — publiés par `DEFINE EVENT` dans la transaction de la mutation.

`auth.invitation.created` suit le contrat de `lyxal_notification` (son plan, §2.1) : le lien
d'acceptation y voyage **scellé** (`enc:v2`) sous le contexte
`with_tenant(<clé de l'organisation>, "lyxal_auth", "auth_invitation_created", <event_id>, "secret")`.
Il arrive dans le champ transitoire `delivery` (illisible), publié puis effacé dans la même
transaction : il n'est jamais enregistré.

## 5. Rust

* `AuthStore` : appels typés (`LyxalSurrealCall`) ; modèles et `XxxParams` dans `models/`.
* `InvitationService` : jeton de 32 octets (`OsRng`), empreinte `blake3_hex`, lien scellé par
  `CryptoEngine`, identifiant d'événement UUID v7 alloué avant le scellement.
* `DomainVerifier` : jeton de défi ; vérification sur la session système de l'hôte (nom du
  domaine relu en base, lecture TXT par `HickoryTxtLookup` / `hickory-resolver`, empreintes
  transmises à la base).
* `AuthModule` (`LyxalModule`), `AuthHealthCheck` (`ModuleHealthCheck`).

Hébergé par `lyxal-server` (`build.rs`, `src/modules/auth.rs`).

## 6. Vérification

* Banc SurrealQL `tests/*.test.surql` (contexte, socle, organisations, identités, rôles,
  membres, invitations, domaines, politique), exécuté par `scripts/ci/test_lyxal_modules.py`.
* Tests Rust `tests/it/` sur le moteur embarqué.
* `scripts/ci/ci_local.sh`.
