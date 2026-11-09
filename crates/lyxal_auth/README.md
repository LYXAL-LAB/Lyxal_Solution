# Lyxal Auth

Module du Noyau Technique de Lyxal OS : **identités, organisations, rôles, permissions,
invitations, contrôle des droits, connexion, sessions, jetons et double facteur**. Toutes les règles vivent dans
SurrealDB (fonctions `fn::auth_*`) ; le crate Rust fournit les appels typés et ce qui relève du
système (aléa, mots de passe, signature des jetons, empreintes, scellement, DNS). Modèle repris de Logto, Kratos, Keycloak, Rauthy et Kanidm
([`MODELE_SOURCES.md`](MODELE_SOURCES.md)).

État : lots 2 (fondations), 3 (connexion, sessions, jetons, parcours, applications) et 4 (double
facteur, niveau d'assurance) du programme `lyxal_auth` V1. Suite : [`ROADMAP.md`](ROADMAP.md).

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
| `auth_policy` | document | politique (mots de passe, verrouillage, sessions, codes, renouvellement, double facteur — exigé, méthodes, rôles qui l'exigent, essais, nombre de codes de secours, ancienneté d'une action sensible —, invitations, inscription) de l'installation et surcharges par organisation |
| `auth_session` | document | session relue à chaque contrôle des droits : sujet identité **ou** application, nature (`interactive`, `service`, `api_key`), organisation active, appareil (`client`), emplacement de la clé du jeton, expirations absolue et d'inactivité, niveau d'assurance (`aal`), méthodes (`amr`), dernière authentification (`authenticated_at`) |
| `auth_credential` | document | moyens d'authentification : mot de passe (empreinte Argon2id scellée, historique), TOTP (secret scellé, en attente puis actif, dernier pas utilisé), passkeys (clé publique sérialisée par `webauthn-rs`, nom, identifiant WebAuthn unique pour l'installation) ; partie secrète illisible hors session système |
| `auth_recovery_code` | document | codes de secours (empreinte HMAC illisible), une génération à la fois, usage unique |
| `auth_required_action` | document | action imposée avant toute session (`verify_email`, `update_password`, `accept_terms`) |
| `auth_flow` | document | parcours persisté (connexion — dont `mfa_required` —, inscription, vérification, récupération, changement d'adresse, connexion par passkey, enrôlement, réauthentification), machine d'état par type, expiration courte, état scellé d'une cérémonie passkey lu une seule fois |
| `auth_one_time_code` | document | code à 6 chiffres (HMAC-SHA256 avec la clé `code_pepper`) et lien (BLAKE3), tentatives limitées, usage unique |
| `auth_pending_address_change` | document | changement d'adresse en attente de confirmation |
| `auth_refresh_token` | document | jeton de renouvellement (empreinte BLAKE3), famille, usage unique, réutilisation détectée |
| `auth_login_failure` | document | échecs de connexion par identifiant et par adresse IP (empreintes), verrouillage temporaire |
| `auth_signing_key` | document | clés de signature des jetons (emplacements `a` / `b`) et clé `code_pepper`, scellées, garde de réutilisation d'un emplacement |
| `auth_application` | document | application (`spa`, `native`, `machine`) de l'installation ou d'une organisation, `client_id`, durées des jetons |
| `auth_application_secret` | document | secret client (empreinte), plusieurs par application (rotation sans coupure) |
| `auth_api_key` | document | clé d'API personnelle (empreinte), permissions limitées à celles du propriétaire |
| `auth_member_of` | **relation** identité → organisation | adhésion |
| `auth_has_role` | **relation** identité, adhésion ou application → rôle | rôle d'installation (identité, application sans organisation) ou d'organisation (adhésion, supprimé avec elle ; application de l'organisation) |
| `auth_role_includes` | **relation** rôle → rôle | rôles composites, sans cycle |
| `auth_role_grants` | **relation** rôle → permission | permissions d'un rôle (même portée) |

Unicité « par installation ou par organisation » : champ `scope_key` (`installation` ou clé de
l'organisation), un index unique ignorant les valeurs absentes.

## 2. Contrôle des droits (pour tous les modules)

* `fn::auth_context({})` : `{ system, identity, application, session, organization, permissions, aal }`.
* `fn::auth_has_permission({ permission, tenant })` : booléen, jamais d'erreur, utilisable dans
  une clause `PERMISSIONS`. Permission d'installation : portée par le jeton. Permission
  d'organisation : portée par le jeton **et** `tenant` = organisation active de la session.
* La session (`$auth`) est relue à chaque appel : révoquée, expirée (absolue ou inactivité),
  antérieure au `not_before` de l'identité, identité inactive, ou version des droits du jeton
  (`pv`) dépassée → aucun droit, même sur une connexion WebSocket restée ouverte.
* Session d'application (compte de service, clé d'API) : application active, session postérieure
  à son `not_before`, version des droits à jour ; mêmes codes `AUTH_SESSION_*`.
* Session système (root de l'hôte) : tous les droits.
* Tout retrait de droit (adhésion supprimée ou suspendue, rôle retiré, permission ou inclusion
  retirée d'un rôle) incrémente `permissions_version` des identités concernées par un événement
  de la base, après l'écriture : l'appelant qui retire ses propres droits n'est pas bloqué.

Permissions du socle (une portée par code) :

| Installation | Organisation |
| :--- | :--- |
| `auth.organization.manage`, `auth.identity.manage`, `auth.identity.read`, `auth.role.manage`, `auth.policy.manage`, `auth.application.manage`, `auth.self.manage` (accordée à toute identité : ses sessions, clés d'API, adresses) | `auth.organization.settings.manage`, `auth.member.manage`, `auth.member.read`, `auth.organization.role.manage`, `auth.organization.policy.manage`, `auth.organization.application.manage`, `auth.session.manage` |

Rôles du socle : `platform_admin` (installation), `organization_admin` et `organization_member`
(organisation ; `organization_member` attribué par défaut).

Un module déclare ses permissions dans son seed, de façon rejouable et non destructive :

```surql
IF !record::exists(auth_permission:⟨notification.read⟩) THEN (
    CREATE auth_permission:⟨notification.read⟩ CONTENT { code: "notification.read", module: "lyxal_notification", scope: "organization", description: { fr: "…", en: "…" } }
) END;
```

## 3. Connexion, sessions et jetons

* **Mots de passe** : Argon2id (`lyxal_crypto::password`), empreinte scellée par identité ;
  politique (longueur 12 à 128, classes, historique) contrôlée avant toute écriture ;
  empreinte réhachée si ses paramètres sont dépassés.
* **Aucune énumération des comptes** : identifiant inconnu → même erreur
  (`AUTH_CREDENTIALS_INVALID`) après vérification contre une empreinte factice ; récupération
  et vérification répondent pareil que l'adresse existe ou non.
* **Anti-force-brute** : échecs comptés par identifiant (même inconnu) et par adresse IP ; au
  seuil de la politique, verrouillage temporaire (`AUTH_TOO_MANY_ATTEMPTS`) ; une connexion
  réussie remet le compteur de l'identifiant à zéro.
* **Actions imposées** : une action en attente met le parcours de connexion en
  `action_required` ; aucune session avant qu'elles soient faites.
* **Parcours** : inscription sur invitation ou par lien d'installation (premier administrateur,
  refusé s'il en existe déjà un), vérification d'adresse (rattachement automatique par domaine
  vérifié), récupération (toutes les sessions révoquées), changement d'adresse (mot de passe
  actuel exigé, code envoyé à la nouvelle adresse, événement vers l'ancienne).
* **Codes et liens** : code à 6 chiffres et lien de 32 octets (`OsRng`), stockés en empreinte ;
  le secret `{ action_url, code }` voyage scellé dans `auth.verification.requested` /
  `auth.recovery.requested` sous le contexte
  `with_tenant("lyxal_installation", "lyxal_auth", <type d'événement, « . » → « _ »>, <event_id>, "secret")`,
  par le champ transitoire `delivery` (jamais enregistré, même chiffré).
* **Jeton d'accès** : JWT HS256 de 15 min (politique), signé par `lyxal_crypto::hmac` avec la
  clé de l'emplacement actif ; claims `ac` (`lyxal_auth_a|b`), `ns`, `db`, `id` (session),
  `sub`, `tenant`, `permissions`, `pv`, `aal`, `jti`, `iat`, `exp`. SurrealDB l'accepte par
  `DEFINE ACCESS lyxal_auth_a|b … TYPE RECORD WITH JWT ALGORITHM HS256 … AUTHENTICATE` (session
  contrôlée par `fn::auth_session_valid`), puis contrôle la session à chaque opération.
* **Renouvellement** : jeton opaque à usage unique (famille) ; un jeton déjà utilisé révoque la
  session (`AUTH_REFRESH_REUSED`, événement `auth.refresh.reused`). L'expiration d'inactivité
  est repoussée, jamais l'expiration absolue.
* **Rotation des clés** : deux accès en alternance ; la nouvelle clé va dans l'emplacement
  inactif, refusé (`AUTH_SIGNING_KEY_ROTATION_TOO_SOON`) tant que des jetons signés par
  l'ancienne clé de cet emplacement peuvent être valides (désactivation + cache de 30 s +
  durée maximale d'un jeton) ; `force` écrase une clé compromise.
* **Applications** : secret client → session `service` sans renouvellement
  (`client_credentials`) ; clé d'API → session `api_key` aux permissions de la clé, bornées par
  celles du propriétaire.
* **Purge** (`AuthPurgeWorker`, 15 min) : parcours, codes, sessions et jetons expirés,
  compteurs d'échecs, invitations expirées, TOTP jamais confirmés.

## 3 bis. Double facteur et niveau d'assurance

* **Niveau d'assurance** (Kratos) : `auth_identity.available_aal` recalculé à chaque changement
  de moyen (2 dès qu'un TOTP ou une passkey actif existe) ; la session porte `aal`, calculé
  depuis ses méthodes (`amr`) : 2 dès qu'un second facteur y figure.
* **Connexion en deux temps** : mot de passe juste et second facteur actif → parcours
  `mfa_required` (méthodes utilisables), aucune session avant le second facteur. La base refuse
  d'ailleurs toute session interactive sur le seul mot de passe à une identité qui a un second
  facteur ou à qui il est exigé (`AUTH_MFA_REQUIRED`).
* **TOTP** (`lyxal_crypto::totp`) : secret de 20 octets scellé sur l'identifiant du moyen, URI
  `otpauth://` affichée une fois, actif après un premier code juste, fenêtre ±1 pas,
  **anti-rejeu** par pas (mise à jour conditionnelle).
* **Passkeys** (`webauthn-rs` 0.6) : second facteur, ou **connexion sans mot de passe** (clé
  découvrable, vérification de l'utilisateur exigée) qui vaut AAL2. Partie de confiance tirée
  de l'adresse publique (`passkey_rp_id` pour la surcharger). État de cérémonie scellé dans le
  parcours, lu une seule fois ; compteur et indicateurs de sauvegarde mis à jour ; clé dont le
  compteur recule refusée et signalée (`auth.passkey.clone_detected`).
* **Codes de secours** : 10 codes (politique) de 10 caractères sans caractères ambigus (`OsRng`),
  affichés une fois, empreinte HMAC, consommation atomique ; ils complètent un second facteur.
* **Tentatives** : `mfa.max_attempts` essais par parcours (puis parcours échoué) ; échecs comptés
  par identité et verrouillés comme le mot de passe (`AUTH_TOO_MANY_ATTEMPTS`) ; message unique
  `AUTH_MFA_INVALID`.
* **Double facteur exigé** : politique (`mfa.required`), organisation (`mfa_required`, à
  l'entrée dans l'organisation), rôle (`mfa.required_roles`, `platform_admin` à l'installation)
  → action `configure_mfa` ; l'enrôlement se fait depuis le parcours de connexion, puis la
  session s'ouvre en AAL2.
* **Actions sensibles** (`fn::auth_assurance_check`, utilisable par tout module) : AAL la plus
  haute disponible et authentification de moins de `mfa.privileged_max_age_seconds` (15 min) —
  gestion des facteurs, mot de passe, adresse, clés d'API, révocation d'une autre session ;
  sinon `AUTH_AAL_INSUFFICIENT` / `AUTH_REAUTHENTICATION_REQUIRED`, résolus par la
  **réauthentification** (second facteur si l'identité en a un, mot de passe sinon), seule à
  mettre à jour `authenticated_at`.
* **Niveau minimal par permission** : `auth_permission.min_aal` (1 par défaut) ; une
  permission d'AAL2 n'est accordée qu'à une session AAL2, relue en base à chaque contrôle.
* **Dernier facteur** protégé quand le double facteur est exigé (`AUTH_MFA_LAST_FACTOR`) ;
  **remise à zéro** par un administrateur (`auth.identity.manage`, ou `auth.member.manage` de
  son organisation) : facteurs et codes supprimés, sessions révoquées, `configure_mfa` posée.
* **Alertes de sécurité** : chaque ajout ou retrait de facteur, génération ou utilisation de
  code de secours, changement de mot de passe et clé clonée publie un événement adressé au
  titulaire, envoyé par `lyxal_notification`.

## 4. Fonctions publiques

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
| Politique | `auth_policy_get` (effective), `auth_policy_save`, `auth_policy_value` |
| Mots de passe, actions imposées | `auth_password_credential_get`, `auth_password_set`, `auth_required_action_add`, `_list`, `_complete` |
| Parcours | `auth_flow_start`, `_load`, `_get`, `_submit`, `auth_flow_states`, `auth_code_issue`, `auth_code_verify`, `auth_registration_start`, `_complete`, `auth_setup_start`, `auth_address_verify`, `auth_address_change_request`, `_confirm`, `auth_domain_auto_join` |
| Sessions | `auth_session_open`, `_create`, `_refresh`, `_revoke`, `_revoke_all`, `_switch_organization`, `_list`, `_check`, `auth_subject_permissions`, `auth_login_failure_status`, `_check`, `_record`, `_reset` |
| Applications, clés d'API | `auth_application_can`, `_create`, `_update`, `_list`, `_secret_add`, `_secret_revoke`, `_permissions`, `auth_service_session_create`, `auth_api_key_create`, `_list`, `_revoke`, `auth_api_key_session_create` |
| Clés de signature, purge | `auth_signing_key_get_active`, `auth_signing_key_rotate`, `auth_purge` |
| Double facteur | `auth_mfa_factor_list`, `auth_mfa_totp_begin`, `_secret_get`, `_activate`, `_step_use`, `auth_mfa_passkey_save`, `_find`, `_list_for`, `_update`, `_rename`, `_flag`, `auth_mfa_recovery_codes_replace`, `auth_mfa_recovery_code_use`, `auth_mfa_factor_remove`, `auth_mfa_reset`, `auth_mfa_failure_check`, `_record`, `_reset`, `auth_mfa_actor`, `auth_mfa_enrolled`, `auth_mfa_publish`, `auth_mfa_required`, `auth_mfa_methods` |
| Assurance, réauthentification | `auth_login_requirements`, `auth_assurance_check`, `auth_assurance_state`, `auth_session_reauthenticate`, `auth_flow_state_save`, `auth_flow_state_take` |

Les fonctions de parcours, de session, de clés, de purge et d'écriture des seconds facteurs sont
réservées à la **session système** de l'hôte : elles reçoivent des empreintes et des résultats
de vérification calculés en Rust, et l'acteur (session de l'utilisateur ou parcours de
connexion) dont la base revérifie les droits, l'AAL et l'ancienneté.

Entrées validées et nettoyées par `lyxal_core` ; erreurs `AUTH_*` (master data `error/`) ;
toute écriture vérifiée (`AUTH_WRITE_FORBIDDEN`). Un identifiant ou un domaine déjà utilisé par
une identité ou une organisation **invisible** pour l'appelant est détecté par l'index unique
(`INSERT IGNORE`), sans rien révéler de son propriétaire.

## 5. Événements

`auth.organization.created`, `auth.organization.state_changed`, `auth.identity.created`,
`auth.identity.state_changed`, `auth.member.added`, `auth.member.removed`, `auth.role.assigned`,
`auth.role.unassigned`, `auth.invitation.created`, `auth.invitation.accepted`,
`auth.invitation.revoked`, `auth.session.created`, `auth.session.revoked`, `auth.login.failed`
(empreinte de l'identifiant, jamais l'identifiant), `auth.identity.locked`, `auth.refresh.reused`,
`auth.verification.requested`, `auth.recovery.requested`, `auth.password.changed`,
`auth.address.changed`, `auth.application.created`, `auth.api_key.created`,
`auth.api_key.revoked`, `auth.mfa.enrolled`, `auth.mfa.removed`,
`auth.mfa.recovery_codes_generated`, `auth.mfa.recovery_code_used`, `auth.mfa.failed`
(empreinte de l'identité), `auth.passkey.clone_detected`, `auth.session.reauthenticated` —
publiés dans la transaction de la mutation. Aucun code, jeton, secret ni mot de passe en clair
dans une charge utile ; les alertes de sécurité (`auth.mfa.*` sauf `failed`,
`auth.passkey.clone_detected`, `auth.password.changed`) portent `recipient_email`,
`recipient_locale` et `recipient_name`.

`auth.invitation.created` suit le contrat de `lyxal_notification` (son `README.md` §4) : le lien
d'acceptation y voyage **scellé** (`enc:v2`) sous le contexte
`with_tenant(<clé de l'organisation>, "lyxal_auth", "auth_invitation_created", <event_id>, "secret")`.
Il arrive dans le champ transitoire `delivery` (illisible), publié puis effacé dans la même
transaction : il n'est jamais enregistré.

## 6. Rust

* `AuthStore` : appels typés (`LyxalSurrealCall`) ; modèles et `XxxParams` dans `models/`.
* `InvitationService` : jeton de 32 octets (`OsRng`), empreinte `blake3_hex`, lien scellé par
  `CryptoEngine`, identifiant d'événement UUID v7 alloué avant le scellement.
* `DomainVerifier` : jeton de défi ; vérification sur la session système de l'hôte (nom du
  domaine relu en base, lecture TXT par `HickoryTxtLookup` / `hickory-resolver`, empreintes
  transmises à la base).
* `AccessService` : connexion, actions imposées, renouvellement, révocation, changement
  d'organisation, mot de passe, parcours (inscription, récupération, vérification, changement
  d'adresse), comptes de service, clés d'API, lien d'installation ; `authenticate` identifie
  l'appelant d'un jeton d'accès (signature vérifiée avec la clé de son emplacement, puis
  session contrôlée par `fn::auth_session_check`).
* `SigningKeyService` : clés générées (`OsRng`), scellées sous
  `SecretContext::global("lyxal_auth.<usage>")`, relues au plus toutes les 30 s ; accès
  `lyxal_auth_a|b` définis ; rotation.
* `MfaService` : TOTP (`lyxal_crypto::totp`), codes de secours (`OsRng`, HMAC `code_pepper`),
  passkeys (`webauthn-rs` : enregistrement, second facteur, connexion sans mot de passe), états
  de cérémonie scellés sous `with_tenant("lyxal_installation", "lyxal_auth", "auth_flow",
  <parcours>, "webauthn_state")`, secret TOTP sous `… "auth_credential", <moyen>, "totp")`.
  `AccessService` l'orchestre : connexion en deux temps (`LoginOutcome::MfaRequired`,
  `complete_login_mfa`), connexion par passkey, réauthentification (`ReauthProof`), acteurs
  (`session_actor`, `login_actor`), exigence d'action sensible (`require_fresh`).
* `PasswordService`, jetons (`access_token`, jetons opaques et empreintes) dans `services/`.
* `AuthModule` (`LyxalModule`), `AuthHealthCheck` (`ModuleHealthCheck`, « dégradé » si l'hôte ne
  sert pas la connexion), `AuthPurgeWorker` (`LyxalWorker`).

Hébergé par `lyxal-server` (`build.rs`, `src/modules/auth.rs`) : routes `/api/v1/auth/*`,
commandes `admin setup` et `auth rotate-signing-key` (README du serveur).

## 7. Vérification

* Banc SurrealQL `tests/*.test.surql` (contexte, socle, organisations, identités, rôles,
  membres, invitations, domaines, politique, mots de passe, parcours, sessions, applications,
  clés, seconds facteurs, assurance), exécuté par `scripts/ci/test_lyxal_modules.py`.
* Tests Rust `tests/it/` sur le moteur embarqué : jeton accepté par l'accès SurrealDB puis
  refusé après révocation, verrouillage, réutilisation d'un jeton de renouvellement,
  récupération par le code scellé de l'événement, actions imposées, compte de service, clé
  d'API, rotation ; premier administrateur obligé de configurer un TOTP, TOTP et codes de
  secours (anti-rejeu, usage unique), parcours échoué, passkeys avec l'authentificateur logiciel
  de `webauthn-rs` (second facteur, rejeu refusé, connexion sans mot de passe),
  réauthentification.
* Serveur SurrealDB 3.3.4 réel (`scripts/ci/test_all.sh`) : jeton accepté sur une connexion
  WebSocket, puis plus aucun droit sur **cette même connexion** après révocation.
* `scripts/ci/ci_local.sh`.
