# `lyxal_auth` — modèle cible composé à partir des projets sources

Synthèse préalable au plan d'implémentation de `lyxal_auth`, version de production. Principe
décidé par le CTO : **on ne réinvente pas la structure**. Le modèle de données et les
fonctionnalités sont repris de projets mûrs, puis transcrits en SurrealDB et Rust selon les
règles Lyxal (`.agents/AGENTS.md`). Aucun de ces projets n'est déployé à côté de Lyxal.

Le crate n'existe pas encore : aucun code avant un `implementation_plan.md` validé par le CTO.

## 1. Sources et analyses détaillées

| Projet | Version analysée | Licence | Ce qu'on reprend | Analyse |
| :--- | :--- | :--- | :--- | :--- |
| Logto | commit `9b4106d` (6 nov. 2026), 79 tables | MPL-2.0 | **Ossature** : organisations, rôles et permissions, applications, politique de connexion, catalogue de connecteurs, événements. Conception reprise, code non traduit ligne à ligne | [`sources/logto.md`](sources/logto.md) |
| Ory Kratos | dernière migration juillet 2026 | Apache-2.0 | Schéma d'identité déclaratif, identifiants uniques, niveaux d'assurance (AAL/AMR), parcours persistés, adresses vérifiables, codes stockés en HMAC | [`sources/kratos_keycloak.md`](sources/kratos_keycloak.md) |
| Keycloak | `main` (78 entités) | Apache-2.0 | Actions imposées (CGU, MFA, mot de passe), anti-force-brute, fédération d'identité, séparation partie secrète / publique des identifiants, typologie d'événements, organisations B2B | [`sources/kratos_keycloak.md`](sources/kratos_keycloak.md) |
| Rauthy | 0.37.3, 54 tables, ~96 000 lignes Rust | Apache-2.0 | **Code Rust** du protocole : autorisation et PKCE, rotation des jetons de renouvellement, rotation des clés de signature (JWKS), cérémonies passkeys, anti-force-brute, fédération amont | [`sources/rauthy_kanidm.md`](sources/rauthy_kanidm.md) |
| Kanidm | 1.13.0-dev | MPL-2.0 | Conception : sessions OAuth2 révoquées en cascade, politiques de compte par groupe, objets de clés par usage | [`sources/rauthy_kanidm.md`](sources/rauthy_kanidm.md) |

Règles de reprise :

* **Apache-2.0** (Kratos, Keycloak, Rauthy) : conception et code réutilisables, avec mention
  d'origine dans le `README.md` et un fichier `NOTICE` quand du code est repris.
* **MPL-2.0** (Logto, Kanidm) : conception (tables, champs, relations, fonctionnalités) reprise ;
  aucune traduction de code ligne à ligne.
* Rien n'est repris de ce qui contredit Lyxal : identifiants aléatoires en texte, listes en CSV,
  secrets en clair protégés par la seule sécurité de la base, `thread_rng`, `unwrap` dans les
  chemins critiques, chiffrement hors `lyxal_crypto` (ChaCha20, AES-CBC), exécution de scripts
  utilisateurs.

## 2. Correspondance des tables (modèle cible)

Préfixe `auth_`. Entités en tables `TYPE NORMAL SCHEMAFULL` ; associations en tables de relation
`TYPE RELATION ... ENFORCED` (décision D5 du CTO, SurrealDB multi-modèle). Colonne
« Origine » : projet dont la conception est reprise.

### 2.1. Identités

| Table Lyxal | Origine | Contenu |
| :--- | :--- | :--- |
| `auth_identity` | Kratos `identities`, Logto `users`, Keycloak `USER_ENTITY` | traits validés par schéma, état (`active`, `inactive`, `locked`), `available_aal`, `external_id`, métadonnées publique et administrateur, `not_before` (révocation globale) |
| `auth_identity_schema` | Kratos schémas, Keycloak User Profile, Logto `custom_profile_fields` | définition des traits : règles `lyxal_core`, obligatoires, identifiants de connexion, adresses de vérification et de récupération, droits par contexte |
| `auth_credential` | Keycloak `CREDENTIAL`, Kratos `identity_credentials` | une ligne par identifiant d'accès (mot de passe, chaque passkey, TOTP, codes de secours) ; partie publique et partie secrète **scellée par `lyxal_crypto`** (`enc:v2`) |
| `auth_credential_identifier` | Kratos | identifiant normalisé (e-mail, téléphone, nom d'utilisateur, `fournisseur:sujet`), **unique par (tenant, type, identifiant)** |
| `auth_address` | Kratos (adresses vérifiables et de récupération) | valeur, canal, vérifiée, statut, usage |
| `auth_pending_address_change` | Kratos | changement d'adresse en attente de vérification (une seule en attente par identité) |

### 2.2. Parcours, codes, sessions

| Table Lyxal | Origine | Contenu |
| :--- | :--- | :--- |
| `auth_flow` | Kratos `selfservice_*_flows`, Keycloak `AUTH_SESSION` | parcours persisté (`login`, `registration`, `settings`, `recovery`, `verification`) : état, AAL demandé, méthode active, contexte, empreinte CSRF, expiration |
| `auth_one_time_code` | Kratos, Logto `passcodes` | code à usage unique **stocké en HMAC** (`lyxal_crypto`), tentatives, utilisation, expiration |
| `auth_session` | Kratos `sessions`, Kanidm, Rauthy `sessions` | empreinte du jeton (jamais en clair), AAL et AMR (méthodes utilisées), expirations absolue et d'inactivité, « se souvenir de moi » |
| `auth_session_device` | Kratos | IP, agent, localisation, dernière activité |
| `auth_refresh_token` | Rauthy `refresh_tokens` | jeton de renouvellement **à usage unique**, rotation, lien session, révocation en cascade |
| `auth_authorization_code` | Rauthy, Logto (`oidc_model_instances` typé) | code d'autorisation avec PKCE, consommé une fois |
| `auth_signing_key` | Rauthy `jwks`, Kanidm objets de clés | clés de signature des jetons, rotation, partie privée scellée par `lyxal_crypto` |

### 2.3. Organisations et droits

| Table Lyxal | Origine | Contenu |
| :--- | :--- | :--- |
| `auth_organization` | Logto `organizations`, Keycloak `ORG` | organisation cliente (entreprise) d'un locataire |
| `auth_organization_domain` | Keycloak `ORG_DOMAIN`, Logto `organization_jit_email_domains` | domaines vérifiés, rattachement automatique par domaine e-mail |
| `auth_member_of` (relation identité → organisation) | Logto `organization_user_relations` | appartenance d'une identité à une organisation |
| `auth_organization_invitation` | Logto `organization_invitations`, Keycloak `ORG_INVITATION` | invitation expirante avec rôles prévus |
| `auth_permission` | Logto `scopes` / `organization_scopes` | permission déclarée par un module (ex. `ingestion:batch:write`) |
| `auth_role` | Logto `roles` / `organization_roles`, Keycloak rôles composites | rôle = ensemble de permissions, global ou modèle d'organisation |
| `auth_role_grants` (relation rôle → permission) | Logto `roles_scopes` / `organization_role_scope_relations` | permissions d'un rôle |
| `auth_role_includes` (relation rôle → rôle) | Keycloak rôles composites | rôles composites, parcourus récursivement |
| `auth_has_role` (relation identité ou adhésion → rôle) | Logto `users_roles` / `organization_role_user_relations` | rôle global (depuis l'identité) ou dans une organisation (depuis l'adhésion : retiré automatiquement quand l'identité quitte l'organisation) |

### 2.4. Applications, fédération, sécurité

| Table Lyxal | Origine | Contenu |
| :--- | :--- | :--- |
| `auth_application` | Logto `applications`, Rauthy `clients` | application cliente (console, mobile, service machine-à-machine) : type, URL de retour, durées de jetons |
| `auth_application_secret` | Logto `application_secrets` | secrets client **hachés** (jamais la valeur), plusieurs par application, expiration |
| `auth_identity_provider` | Keycloak brokering, Rauthy `auth_providers`, Logto `sso_connectors` | fournisseur externe OIDC par locataire ou organisation ; secret client scellé |
| `auth_federated_identity` | Keycloak `FEDERATED_IDENTITY`, Logto `user_sso_identities` | lien identité Lyxal ↔ `fournisseur:sujet` |
| `auth_required_action` | Keycloak required actions | catalogue des actions imposées (CGU, MFA obligatoire, mot de passe à changer, adresse à vérifier) et liste par identité |
| `auth_login_failure` | Keycloak `LOGIN_FAILURE`, Logto `sentinel_activities`, Rauthy `failed_login_counter` | compteurs d'échecs, verrouillages temporaires |
| `auth_policy` | Logto `sign_in_experiences` (découpé), Rauthy `password_policy` | politique par locataire : mot de passe, MFA, verrouillage, durée des codes, méthodes de connexion autorisées |
| `auth_api_key` | Logto `personal_access_tokens`, Rauthy `api_keys` | clés d'accès de service **hachées**, droits limités, expiration |

**Pas de tables locales** pour le courrier (délégué à `lyxal_notification`), les webhooks et
l'audit (événements `auth.*` publiés par `fn::event_publish`, typologie reprise de Keycloak et
Logto), les traductions (`lyxal_i18n`), les purges planifiées (`LyxalWorker`, puis
`lyxal_scheduler`).

## 3. Fonctionnalités et découpage

| Fonctionnalité | Origine | Lot proposé |
| :--- | :--- | :--- |
| Inscription, connexion par mot de passe (Argon2id `lyxal_crypto`), vérification d'adresse, récupération de compte | Kratos, Logto | V1 |
| Organisations, membres, invitations, rôles et permissions par organisation | Logto, Keycloak | V1 |
| Remplacement de `catalogue_session`, `ingestion_session` et de l'accès `lyxal_catalogue_sync` | — | V1 |
| Sessions, niveaux d'assurance (AAL/AMR), sessions privilégiées pour actions sensibles | Kratos | V1 |
| Actions imposées (CGU, MFA obligatoire, changement de mot de passe) | Keycloak | V1 |
| Anti-force-brute, politique de mot de passe | Keycloak, Rauthy, Logto | V1 |
| Applications clientes, secrets hachés, comptes de service et clés d'API | Logto, Rauthy | V1 |
| Jetons d'accès vérifiés par SurrealDB (`DEFINE ACCESS`), renouvellement à usage unique | Rauthy | V1 |
| Double facteur TOTP, passkeys, codes de secours | Logto, Kratos, Rauthy | V1 ou V2 (selon décision crypto §4) |
| Connexion par fournisseur externe (Microsoft, Google, OIDC d'un client) | Keycloak, Rauthy, Logto | V2 |
| Lyxal fournisseur OpenID Connect pour des applications tierces (découverte, JWKS publiques) | Rauthy | V2 (selon décision crypto §4) |
| Appareils de confiance, MFA adaptative, consentement, emprunt d'identité encadré | Logto | V2 |
| SSO entreprise SAML, parcours configurables en arbre, provisionnement SCIM | Logto, Keycloak, Rauthy | V3 |
| Écrans de la console (charte §15) | Logto (console) | lot console dédié |

## 4. Décisions à prendre par le CTO

1. **Extensions cryptographiques** (règle §11.3 : rien sans validation). Les trois analyses
   concluent que `lyxal_crypto` ne couvre pas :
   * la **signature à clé publique des jetons** : Rauthy utilise EdDSA, Kanidm ES256, et la norme
     OpenID Connect impose RS256 aux fournisseurs. Sans elle, Lyxal vérifie ses propres jetons
     (HMAC, déjà disponible) mais ne peut pas en émettre pour des tiers ;
   * le **TOTP** (codes des applications d'authentification), fondé sur HMAC-SHA1 ;
   * les **passkeys** : vérification de signatures ECDSA P-256, Ed25519, RSA, portée par la
     bibliothèque `webauthn-rs` (auditée, utilisée par Kanidm et Rauthy) ;
   * la vérification d'anciens hachages (bcrypt, pbkdf2, scrypt), seulement si l'on importe des
     comptes existants.
2. **Isolation des locataires** : champ `tenant` contrôlé par les `PERMISSIONS` de chaque table
   (modèle Logto transposé), ou un espace SurrealDB (namespace/database) par locataire.
3. **Tables de relation** : décidé — tables `TYPE RELATION` pour les associations (adhésions,
   rôles, rôles composites, permissions des rôles).
4. **Fournisseur OpenID Connect pour des tiers** : en V2 (dépend du point 1) ou plus tard.
5. **Connexions sortantes** : création d'un module `lyxal_connect` (comptes connectés vers des
   services externes), séparé de `lyxal_auth` ; voir [`../lyxal_connect/RECHERCHE_SOURCES.md`](../lyxal_connect/RECHERCHE_SOURCES.md).
   `lyxal_auth` étant en dessous, il garde sa propre configuration des fournisseurs OIDC
   (recommandé, §6 de `AGENTS.md`).
