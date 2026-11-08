# Plan d'implémentation — programme `lyxal_auth` V1 (version de production)

Création du crate du Noyau Technique `lyxal_auth` (rang 1 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](docs/14-roadmap/ROADMAP_NOYAU.md)), découpée en six lots.
Modèle repris des projets sources selon [`crates/lyxal_auth/MODELE_SOURCES.md`](crates/lyxal_auth/MODELE_SOURCES.md)
(Logto, Ory Kratos, Keycloak, Rauthy, Kanidm ; analyses dans `crates/lyxal_auth/sources/`).
Plan placé à la racine comme les lots précédents, supprimé une fois le programme exécuté ;
chaque lot est une PR distincte, exécutée selon ce plan, tout écart étant signalé dans sa PR.

## 0. Décisions du CTO (8 novembre 2026)

| # | Décision |
| :- | :--- |
| D1 | Cœur de l'identité dans Lyxal (SurrealDB + Rust) ; modèle et fonctionnalités repris des projets mûrs ; aucun produit déployé à côté |
| D2 | `lyxal_crypto` étendu : **TOTP** en V1 (lot 1) ; **signature asymétrique** des jetons en V2 (Lyxal fournisseur OIDC pour des tiers) |
| D3 | Passkeys par la bibliothèque `webauthn-rs` (auditée, utilisée par Kanidm et Rauthy), dépendance de `lyxal_auth` |
| D4 | Isolation par champ de locataire contrôlé par les `PERMISSIONS` de chaque table |
| D5 | Liens identité / organisation / rôle en tables `TYPE NORMAL` à identifiant composite (pas de `TYPE RELATION`) |
| D6 | Lyxal fournisseur OpenID Connect pour des tiers : V2 |
| D7 | Module `lyxal_connect` (comptes connectés sortants) créé plus tard, après `lyxal_secrets` ; `lyxal_auth` garde sa propre configuration des fournisseurs de connexion |

## 1. Architecture

### 1.1. Locataire = organisation

Le locataire actuel des modules (`tenant_id` de `lyxal_catalogue`) est l'**entreprise cliente**.
Dans le modèle Logto, c'est l'**organisation** (le « tenant » Logto correspond à une installation
entière). Donc :

* une installation Lyxal (base SurrealDB) héberge plusieurs **organisations** ;
* le **locataire** de toute donnée métier est une organisation : `tenant` = `record<auth_organization>` ;
* une identité peut appartenir à plusieurs organisations ; elle agit dans **une** organisation à
  la fois (organisation active de la session) ;
* les rôles **globaux** (administrateur de la plateforme, comptes de service comme l'agent de
  synchronisation du catalogue) existent hors organisation.

### 1.2. Jetons et application des droits

* À la connexion, `lyxal_auth` crée une **session** (`auth_session`) et émet :
  * un **jeton d'accès** JWT court (15 min), signé HS256 par `lyxal_crypto::hmac` avec une clé
    d'installation scellée (`SecretContext::global("lyxal_auth.access_token")`) ;
  * un **jeton de renouvellement** opaque, à usage unique, stocké en empreinte (rotation à chaque
    usage, révocation de toute la chaîne en cas de réutilisation — modèle Rauthy).
* SurrealDB vérifie le jeton par un accès `DEFINE ACCESS lyxal_auth ON DATABASE TYPE RECORD WITH
  JWT ALGORITHM HS256 KEY ... AUTHENTICATE { ... }` : la clause `AUTHENTICATE` contrôle que la
  session existe, est active et non expirée (**révocation immédiate**), puis `$auth` désigne la
  session.
* Claims : `sub` (identité), `sid` (session), `tenant` (organisation active, absente pour une
  session globale), `permissions` (calculées à l'émission : rôles globaux + rôles dans
  l'organisation active), `aal` (niveau d'assurance), `aud`, `iat`, `exp`, `jti`.
* Les modules ne lisent plus de session propre : ils appellent **`fn::auth_context({})`**
  (identité, organisation, permissions, AAL, session système) et testent les permissions dans
  leurs `PERMISSIONS` (`fn::auth_has_permission({ permission })`).
* Session système (root de l'hôte) : inchangée (`$session.ac == NONE AND $auth == NONE`).

### 1.3. Découpage SurrealQL / Rust / hôte

| Couche | Contenu |
| :--- | :--- |
| SurrealQL (`crates/lyxal_auth`) | tables, règles de données (unicité des identifiants, machine d'état des parcours, calcul AAL, rôles et permissions, verrouillage, actions imposées), fonctions `fn::auth_*`, master data `AUTH_*`, événements `auth.*` |
| Rust (`crates/lyxal_auth/src`) | hachage et vérification des mots de passe (`lyxal_crypto::password`), émission des jetons (`lyxal_crypto::hmac`), génération des codes (`OsRng`), TOTP (`lyxal_crypto`, lot 1), cérémonies passkeys (`webauthn-rs`), `LyxalModule`, store `LyxalSurrealCall`, worker de purge (`LyxalWorker`), sonde de santé |
| Hôte (`apps/lyxal-server`) | routes HTTP `/auth/*` appelant les services Rust ; définition de l'accès `lyxal_auth` au démarrage ; configuration de la clé |

### 1.4. Dépendances

`lyxal_core`, `lyxal_error`, `lyxal_surreal`, `lyxal_crypto`, `lyxal_event`, `lyxal_runtime`.
Aucune dépendance vers un module métier (`AGENTS.md` §6). Les envois de messages (codes, liens)
ne sont pas faits par `lyxal_auth` : voir question Q1.

## 2. Modèle de données (`schema/`, préfixe `auth_`)

Toutes les tables `TYPE NORMAL SCHEMAFULL`, sans suppression physique des identités (état
`deleted` puis purge planifiée), `created_at` / `updated_at` par `VALUE`, identifiants UUID v7.
Origine de chaque table : `MODELE_SOURCES.md` §2.

| Lot | Tables |
| :- | :--- |
| 2 | `auth_organization`, `auth_organization_domain`, `auth_identity_schema`, `auth_identity`, `auth_credential_identifier`, `auth_address`, `auth_organization_member` (id `[organisation, identité]`), `auth_permission`, `auth_role`, `auth_role_permission` (id `[rôle, permission]`), `auth_role_assignment` (id `[identité, rôle, organisation \| NONE]`), `auth_organization_invitation`, `auth_policy` |
| 3 | `auth_credential`, `auth_flow`, `auth_one_time_code`, `auth_session`, `auth_session_device`, `auth_refresh_token`, `auth_login_failure`, `auth_required_action`, `auth_application`, `auth_application_secret`, `auth_api_key`, `auth_signing_key`, `auth_pending_address_change` |
| 4 | (MFA dans `auth_credential` : types `totp`, `passkey`, `recovery_code`) |

Règles transverses :

* **Secrets** : partie secrète des identifiants (`auth_credential.secret_data`), secrets des
  fournisseurs et clés de signature **scellés** par `CryptoEngine::seal` (`enc:v2`, AAD
  `with_tenant` ou `global`) ; mots de passe en PHC Argon2id ; codes, jetons de session et de
  renouvellement, secrets client et clés d'API stockés **en empreinte** (HMAC ou BLAKE3), jamais
  en clair.
* **Identifiants de connexion** : `auth_credential_identifier` unique par (type, identifiant
  normalisé) pour l'installation (un e-mail = une identité), normalisation par `lyxal_core`
  (`fn::sanitize_*`).
* **Permissions déclarées par les modules** : chaque module fournit un seed de ses permissions
  (`ingestion:batch:write`…) et des rôles par défaut ; `lyxal_auth` n'en connaît pas le sens.

## 3. Fonctions publiques (`functions/`, `fn::auth_*($params: object)`)

Entrées par le moteur `lyxal_core`, retour `fn::result_ok` / `fn::error_result`, écritures
vérifiées (`AUTH_WRITE_FORBIDDEN`), < 300 lignes, `COMMENT`.

| Lot | Fonctions |
| :- | :--- |
| 2 | `auth_context`, `auth_has_permission` ; organisations : `auth_organization_create`, `_get`, `_list`, `_update`, `_domain_add`, `_domain_verify` ; identités : `auth_identity_create` (administrateur), `_get`, `_list`, `_update_traits`, `_set_state` ; `auth_identity_schema_save` ; membres : `auth_organization_member_add`, `_remove`, `_list` ; droits : `auth_permission_register` (seed des modules), `auth_role_create`, `_update`, `_permission_set`, `auth_role_assign`, `_unassign`, `auth_identity_permissions` ; invitations : `auth_invitation_create`, `_accept`, `_revoke` ; `auth_policy_get`, `_save` |
| 3 | parcours : `auth_flow_start`, `auth_flow_submit`, `auth_flow_get` ; codes : `auth_code_issue`, `auth_code_verify` ; sessions : `auth_session_create`, `auth_session_refresh`, `auth_session_revoke`, `auth_session_list`, `auth_session_switch_organization` ; `auth_login_failure_record` ; actions imposées : `auth_required_action_list`, `_complete` ; applications et service : `auth_application_create`, `_secret_add`, `_secret_revoke`, `auth_api_key_create`, `_revoke`, `auth_service_token_issue` ; `auth_address_change_request`, `_confirm` |
| 4 | `auth_mfa_totp_enroll`, `_confirm`, `auth_mfa_passkey_register_start`, `_finish`, `auth_mfa_passkey_login_start`, `_finish`, `auth_mfa_recovery_codes_generate`, `auth_mfa_verify`, `auth_session_step_up` |

Les opérations cryptographiques (hachage, vérification, signature, TOTP, WebAuthn) sont faites en
Rust ; SurrealQL ne reçoit que des empreintes ou des résultats de vérification, et porte les règles
(état, unicité, tentatives, verrouillage, AAL).

## 4. Master data (`error/`, préfixe `AUTH_`)

Thèmes et codes (fr/en, catégorie, statut HTTP, réessayable) :

* `identities` : `AUTH_IDENTITY_NOT_FOUND`, `AUTH_IDENTIFIER_TAKEN`, `AUTH_IDENTITY_INACTIVE`,
  `AUTH_IDENTITY_LOCKED`, `AUTH_TRAITS_INVALID` ;
* `credentials` : `AUTH_CREDENTIALS_INVALID` (message unique, sans dire ce qui est faux),
  `AUTH_PASSWORD_POLICY_VIOLATION`, `AUTH_PASSWORD_REUSED`, `AUTH_MFA_REQUIRED`,
  `AUTH_MFA_INVALID`, `AUTH_PASSKEY_INVALID` ;
* `sessions` : `AUTH_SESSION_EXPIRED`, `AUTH_SESSION_REVOKED`, `AUTH_REFRESH_REUSED`,
  `AUTH_AAL_INSUFFICIENT`, `AUTH_TOO_MANY_ATTEMPTS` ;
* `flows` : `AUTH_FLOW_EXPIRED`, `AUTH_FLOW_INVALID_STATE`, `AUTH_CODE_INVALID`,
  `AUTH_CODE_EXPIRED`, `AUTH_REQUIRED_ACTION_PENDING` ;
* `organizations` : `AUTH_ORGANIZATION_NOT_FOUND`, `AUTH_NOT_A_MEMBER`, `AUTH_INVITATION_INVALID`,
  `AUTH_DOMAIN_NOT_VERIFIED` ;
* `access` : `AUTH_PERMISSION_DENIED`, `AUTH_ROLE_NOT_FOUND`, `AUTH_PERMISSION_UNKNOWN`,
  `AUTH_INVALID_PARAMETERS`, `AUTH_WRITE_FORBIDDEN`.

## 5. Événements (`events/`, `fn::event_publish`)

`auth.identity.created`, `auth.identity.state_changed`, `auth.session.created`,
`auth.session.revoked`, `auth.login.failed`, `auth.identity.locked`,
`auth.verification.requested`, `auth.recovery.requested`, `auth.invitation.created`,
`auth.role.assigned`, `auth.role.unassigned`, `auth.mfa.enrolled`, `auth.password.changed`.
Ils servent d'audit (typologie Keycloak et Logto) et de déclencheur des messages (Q1). Aucun
code ni jeton en clair dans une charge utile.

## 6. Lots

| Lot | Contenu | Modules touchés |
| :- | :--- | :--- |
| **1** | `lyxal_crypto` : module `totp` (RFC 6238 / RFC 4226 : HMAC-SHA1 et SHA-256, 6 à 8 chiffres, fenêtre de tolérance, comparaison en temps constant, secret `SecretBytes`, génération par `OsRng`, URI `otpauth://`), vecteurs RFC dans les tests, mise à jour de `API_CONTRACT.md` | `lyxal_crypto` |
| **2** | Squelette du crate (manifest, Cargo, `LyxalModule`, store, README, ROADMAP), tables et fonctions du lot 2, master data, événements, seeds (permissions et rôles de base), banc SurrealQL complet | `lyxal_auth` (nouveau), `apps/lyxal-server` (hébergement) |
| **3** | Authentification par mot de passe et parcours (inscription sur invitation ou par administrateur, connexion, vérification d'adresse, récupération, changement d'adresse), sessions et jetons, accès SurrealDB `lyxal_auth`, anti-force-brute, actions imposées, applications et comptes de service, routes HTTP `/auth/*`, worker de purge | `lyxal_auth`, `apps/lyxal-server` |
| **4** | Double facteur : TOTP, passkeys (`webauthn-rs`), codes de secours, montée en assurance (AAL2) pour les actions sensibles | `lyxal_auth`, `apps/lyxal-server` |
| **5** | Bascule des modules : `lyxal_catalogue` et `lyxal_pipeline_ingestion` déclarent leurs permissions ; suppression de `catalogue_session`, `ingestion_session`, des fonctions `*_session_identity` et de l'accès `lyxal_catalogue_sync` ; leurs `PERMISSIONS` passent par `fn::auth_has_permission` ; agent de synchronisation = compte de service `lyxal_auth` (**rupture coordonnée**, tous les tests mis à jour) | `lyxal_catalogue`, `lyxal_pipeline_ingestion`, `apps/lyxal-server` |
| **6** | Clôture : audit `lyxal-audit` du module, revue de sécurité (liste OWASP ASVS niveau 2 sur l'authentification et les sessions), `ROADMAP_NOYAU.md` et `AGENTS.md` §6 mis à jour, V2 décrite dans `crates/lyxal_auth/ROADMAP.md` | `lyxal_auth`, docs |

V2 (feuille de route du module) : connexion par fournisseur externe (OIDC), Lyxal fournisseur OIDC
(signature asymétrique à ajouter à `lyxal_crypto`), appareils de confiance, MFA adaptative,
consentement, emprunt d'identité encadré, écrans de la console. V3 : SSO SAML, parcours en arbre,
SCIM.

## 7. Tests et critères de production

* **Banc SurrealQL** (`tests/*.test.surql`) : chaque fonction publique, cas nominaux, erreurs,
  identités simulées, permissions (accès refusé à une autre organisation), écritures filtrées.
* **Rust** : vecteurs RFC 6238 (TOTP), tests de cérémonie passkey avec authentificateur logiciel
  de `webauthn-rs`, rotation et réutilisation des jetons de renouvellement, révocation immédiate
  par `AUTHENTICATE`, verrouillage après N échecs, horloge contrôlée.
* **Serveur réel** : connexion de bout en bout sur SurrealDB 3.3.4 (jeton émis par Lyxal accepté
  par l'accès `lyxal_auth`, refusé après révocation).
* **Sécurité** : aucune valeur secrète en clair en base ni dans les journaux et événements ;
  messages d'échec indistincts (pas d'énumération des comptes) ; comparaisons en temps constant.
* Contrôle complet : `scripts/ci/ci_local.sh` à chaque lot.

## 8. Checklist (§13)

* Core : entrées par `fn::validation_object_execute` / `fn::sanitize_object_execute` ; règles
  manquantes (ex. téléphone E.164) signalées au CTO avant usage.
* Crypto : uniquement `lyxal_crypto` (+ extension TOTP du lot 1) ; `webauthn-rs` validé (D3) ;
  `OsRng` seulement ; aucun AAD vide.
* Rust : aucun `panic!`, `unwrap` hors tests ; aucune erreur silencieuse ; secrets en `SecretString`.
* Zéro dette : remplacement complet des sessions des modules au lot 5, sans ancien chemin conservé.
* Licences : mention d'origine Apache-2.0 (Kratos, Keycloak, Rauthy) dans le `README.md` et un
  fichier `NOTICE` pour tout code repris de Rauthy ; Logto et Kanidm (MPL-2.0) en conception seule.

## 9. Questions au CTO

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Envoi des codes et liens (vérification, récupération, invitation) tant que `lyxal_notification` n'existe pas | **A.** Avancer `lyxal_notification` (au moins l'e-mail) avant le lot 3. **B.** `lyxal_auth` publie seulement les événements ; en attendant, seuls les comptes créés par un administrateur (mot de passe initial à changer, action imposée) sont possibles. **C.** Un envoi SMTP provisoire dans l'hôte. | **A** : un parcours de production sans e-mail (vérification, récupération) n'est pas utilisable ; C crée de la dette. `lyxal_notification` consomme les événements `auth.*` (découplage §5.6.1). |
| Q2 | Inscription libre | **A.** Pas d'inscription libre : invitation par une organisation ou création par un administrateur. **B.** Inscription libre configurable par politique. | **A** pour un produit B2B ; B reste possible plus tard par `auth_policy`. |
| Q3 | Unicité des identifiants | **A.** Un e-mail = une identité pour toute l'installation (membre de plusieurs organisations). **B.** Unicité par organisation (comptes distincts). | **A** (modèle Logto) : une personne, un compte, plusieurs entreprises. |
