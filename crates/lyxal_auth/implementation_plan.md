# Plan du lot 6 — `lyxal_auth` : audit de clôture et corrections

Programme : `implementation_plan.md` à la racine (lot 6 : clôture). Ce plan rassemble les
résultats de l'audit de clôture (skill `lyxal-audit`, revue OWASP ASVS 4.0.3 niveau 2 sur
l'authentification, les sessions et le contrôle des droits, analyse des dépendances) et les
corrections proposées. Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Résultat de l'audit

Verdict : **NON CONFORME** tant que S1 n'est pas corrigé (faille exploitable), puis conforme
avec réserves une fois S1 à S5 traités.

Contrôles exécutés :

| Contrôle | Preuve | Résultat |
| :--- | :--- | :--- |
| Manifeste, dépendances, cycles | 45 ressources présentes, aucun `.surql` oublié, aucun cycle | conforme |
| SurrealQL (signatures, retours, COMMENT, taille, permissions, événements, seeds, codes) | 144 fonctions `fn::auth_*($params: object)` commentées (la plus longue : 94 lignes) ; 30 tables avec permissions ; 26 publications d'événements vérifiées ; 66 erreurs idempotentes ; tous les codes émis définis | conforme, sauf Q1 et Q2 ci-dessous |
| SurrealDB 3.3.4 | `surreal validate` sur les 61 fichiers (code 0) ; banc : 16 fichiers, 331 assertions, 0 échec sur serveur 3.3.4 | conforme |
| DTO Rust ↔ SurrealQL | 74 appels `call_fn` : 0 champ en trop, 0 incompatible | conforme ; champs facultatifs non exposés (C6) |
| Rust (transport, panics, erreurs silencieuses, worker) | `clippy -D warnings` sans avertissement ; aucun `unwrap`/`expect`/`panic!` en production ; aucun `tokio::spawn` | conforme, sauf C2 à C5 |
| Cryptographie | aucune crate crypto directe ; `OsRng` seul ; aucun contexte vide | conforme |
| CI locale (`scripts/ci/ci_local.sh`) | toutes les vérifications passées (lot 5) | conforme |

### 1.1 Sécurité (revue ASVS niveau 2)

Condition commune : S1 à S3 passent par une connexion SurrealDB directe avec le jeton d'accès
(accès `lyxal_auth_a|b`, console). La conception la prévoit ; l'API HTTP seule n'y expose rien.

| ID | Sévérité | Constat (vérifié dans le code) |
| :--- | :--- | :--- |
| **S1** | **P0** | Un administrateur d'organisation peut modifier tous les champs d'une identité membre de son organisation (`schema/04_auth_identity.surql`, `FOR update` sans permission par champ) et ses identifiants de connexion (`schema/05_auth_credential_identifier.surql`, `value` modifiable). Il remplace l'e-mail de la victime par le sien, reçoit le code de récupération, fixe le mot de passe, remet `available_aal` à 0 ou enrôle son propre facteur : **prise de contrôle du compte**, y compris d'un `platform_admin` membre de l'organisation |
| **S2** | P1 | Une identité dont l'e-mail correspond à une invitation en attente peut créer elle-même son adhésion et le rôle prévu, **sans le jeton d'invitation** (`schema/13_auth_relations.surql`, `fn::auth_invitation_pending`). Combiné à S1 : entrée dans une autre organisation |
| **S3** | P1 | Clés d'API créées ou réactivées directement en base (`schema/11_auth_application.surql`, `auth_api_key` : `FOR create, update` au titulaire) : contourne la réauthentification et l'AAL ; `revoked_at` remis à `NONE` |
| **S4** | P1 | Code de récupération à 6 chiffres : 5 essais par code mais codes illimités (chaque demande en crée un), essais comptés par lecture puis écriture (non atomique) → force brute possible |
| **S5** | P1 | Suspendre une organisation ne coupe pas les sessions de ses membres (l'état de l'organisation n'est contrôlé ni par `fn::auth_session_valid` ni au renouvellement) |
| **S6** | P1 | Derrière un proxy inverse, toutes les connexions ont la même adresse IP : 50 échecs bloquent la connexion de tous pendant 15 min |
| S7 | P2 | Énumération des comptes par la récupération (réponses et temps différents selon que le compte existe) |
| S8 | P2 | Une action imposée « changer le mot de passe » est acceptée avant le second facteur |
| S9 | P2 | Vérification du mot de passe actuel (`/password`, `/address-change`) non comptée par l'anti-force-brute ; contrôle puis enregistrement d'échec non atomiques à la connexion |
| S10 | P2 | La session système est déduite de l'absence d'authentification : une connexion invitée SurrealDB serait traitée comme système |
| S11 | P2 | Durées par défaut au-delà du niveau 2 : session absolue 30 j, inactivité 12 h (ASVS : 12 h ou 30 min d'inactivité) |
| S12 | P2 | Jetons : `aud` / `iss` non vérifiés ; réponses porteuses de jetons sans `Cache-Control: no-store` ; jetons des liens en `?token=` (visibles dans les journaux) |
| S13 | P2 | Aucun contrôle contre les mots de passe divulgués (ASVS 2.1.7) |
| S14 | P2 | Créations de parcours sans limite (`/recovery`, `/passkey/login/options`) : remplissage de la base, envois d'e-mails |
| S15 | P2 | Révoquer le secret d'un compte de service laisse ses sessions valides jusqu'à 15 min |

Vérifié sans problème : pas de fixation de session, aucun rejeu (renouvellement, TOTP, codes de
secours, défis passkeys), connexion en deux temps sans contournement, changement d'organisation
contrôlé, clés d'API bornées par les droits du propriétaire, `fn::auth_service_session_open`
réservée à la session système, aucun secret dans les journaux.

### 1.2 Conformité (hors sécurité)

| ID | Sévérité | Constat |
| :--- | :--- | :--- |
| Q1 | P1 | 22 `string::lowercase` locaux sur des empreintes dans 17 fonctions, au lieu de la règle `lowercase` de `lyxal_core` (§5.7.8) |
| Q2 | P1 | `auth_permission_register` / `_update` : longueur des descriptions contrôlée localement ; aucune règle Core ne borne la longueur des valeurs d'un objet (primitive manquante, §5.7.7) |
| Q3 | P2 | 15 `THROW "AUTH_*"` qui annulent une écriture multiple : côté Rust, `call_fn` les traite en erreur de base, l'hôte répond `SERVER_DATABASE_UNAVAILABLE` et le code métier est perdu |
| Q4 | P2 | Codes définis jamais émis : `AUTH_REGISTRATION_CLOSED`, `AUTH_ADDRESS_CHANGE_PENDING`, `AUTH_REQUIRED_ACTION_PENDING` |
| Q5 | P2 | Commentaires historiques (« lot 3 », « écart E1 du lot 4 »…) dans 7 fichiers SurrealQL, dont un COMMENT persisté |
| Q6 | P2 | Purge des organisations et identités `deleted` annoncée dans les commentaires, ni faite ni inscrite à la feuille de route |
| Q7 | P2 | `RECHERCHE_SOURCES.md` : mémo de recherche antérieur aux décisions (document historique) ; passages périmés dans `MODELE_SOURCES.md` et `sources/` |
| C2–C4 | P2 | Valeurs par défaut silencieuses sur une donnée stockée ou signée : permissions du jeton absentes → `[]`, historique des mots de passe absent → vide, paramètres TOTP absents → SHA1/6/30 s |
| C5 | P2 | Le worker de purge ne teste pas l'annulation entre deux paquets |
| C1 | P2 | `Debug` dérivé sur 20 structures portant des empreintes (`identifier_hash` = BLAKE3 de l'e-mail, retrouvable par dictionnaire) |
| C6 | P2 | Champs facultatifs non exposés en Rust : `language` (messages toujours en français), `min_aal` à l'enregistrement d'une permission, `client` de l'inscription, `limit`, `session_retention_days` |

### 1.3 Dépendances (`cargo audit`)

| Alerte | Origine | Correction |
| :--- | :--- | :--- |
| `ammonia` (3), `rustls` (4), `rustls-webpki` (1), `quinn-proto` (3) | SurrealDB, `lettre`, `reqwest` | mise à jour compatible (`cargo update`) |
| `hickory-proto` 0.25 (2) | `hickory-resolver` (vérification DNS des domaines) | passage à `hickory-resolver` 0.26 (une alerte sans correctif connu : boucle sur une réponse DNSSEC, chemin non utilisé) |
| `rsa` (Marvin, RUSTSEC-2023-0071) : 0.10.0-rc.19 par `webauthn-rs`, 0.9.10 par SurrealDB (`jsonwebtoken`) | aucune version corrigée | non atteint : l'attaque vise les opérations à clé privée ; `webauthn-rs` ne fait que vérifier des signatures (clé publique) et Lyxal signe ses jetons en HMAC |
| `crypto-bigint` 0.5, `quick-xml` 0.39, `surrealdb-core` 3.3.5 (`reblessive`) | SurrealDB 3.3.5 | corrigé seulement par SurrealDB 4.0 : changement de version majeure, à traiter dans un chantier dédié (Q-D) |

## 2. Corrections proposées

### 2.1 Sécurité

* **S1** :
  * `auth_credential_identifier` : `FOR create, update, delete` réservés à la session système et à
    `auth.identity.manage` ; les fonctions publiques restent le seul chemin pour un administrateur
    d'organisation.
  * Champs de sécurité de `auth_identity` (`available_aal`, `not_before`, `permissions_version`,
    `state`, `last_login_at`) : `PERMISSIONS FOR update NONE` (écrits par les fonctions de la
    session système ou par `auth.identity.manage` seulement).
  * `fn::auth_identity_update_traits` par un administrateur d'organisation : refusée pour une
    identité membre d'une autre organisation ou détentrice d'un rôle d'installation ; un nouvel
    e-mail ne devient identifiant qu'après vérification (parcours de changement d'adresse
    existant).
  * Tests : chaque étape du scénario refusée sous une session d'administrateur d'organisation.
* **S2** : suppression des branches d'auto-création dans les permissions de `auth_member_of` et
  `auth_has_role` ; l'invitation n'est acceptée que par `fn::auth_invitation_accept` (jeton).
* **S3** : `auth_api_key` en `FOR create, update NONE` hors `auth.identity.manage` ; création et
  révocation par `fn::auth_api_key_create` / `_revoke` seulement.
* **S4** : au plus 3 codes de récupération actifs par identité et 1 envoi par minute ; essais
  comptés par une écriture conditionnelle atomique avant la comparaison ; échecs aussi comptés par
  identité et adresse IP, comme à la connexion.
* **S5** : `fn::auth_session_valid` refuse une session dont l'organisation active n'est pas
  `active` ; suspendre une organisation incrémente la version des droits de ses membres et
  révoque les sessions de ses comptes de service.
* **S6** : configuration `server.trusted_proxies` (liste d'adresses) ; l'adresse du client est
  lue dans `X-Forwarded-For` seulement si la connexion vient d'un proxy de confiance (Q-C).
* **S7** : code factice émis pour une adresse inconnue (même réponse, même travail).
* **S8** : actions imposées traitées après le second facteur.
* **S9** : `check_current_password` passe par l'anti-force-brute ; enregistrement de l'échec
  atomique avec le contrôle du seuil.
* **S10** : la session système est reconnue par un marqueur positif (utilisateur SurrealDB de
  niveau racine) ; le serveur refuse de démarrer si SurrealDB accepte les invités.
* **S11** : nouvelles valeurs par défaut de la politique (Q-A).
* **S12** : vérification de `aud` et `iss` ; `Cache-Control: no-store` sur les réponses porteuses
  de jetons ; jetons des liens dans le fragment (`#token=`).
* **S13** : contrôle contre une liste locale de mots de passe divulgués (Q-B).
* **S14** : limite par adresse IP sur la création de parcours non authentifiés.
* **S15** : révoquer un secret révoque les sessions de service ouvertes avec lui.

### 2.2 Conformité et dépendances

* Q1 : empreintes nettoyées par `fn::sanitize_object_execute` (règle `lowercase`, `each` pour les
  listes).
* Q2 : extension du Core (Q-E) puis contrôle par la règle ; plus de condition locale.
* Q3 : `lyxal_surreal` reconnaît une erreur levée dont le message commence par un code de module
  (`<PRÉFIXE>_…`) et la renvoie en erreur métier ; l'hôte répond avec ce code (Q-F).
* Q4 à Q7, C1 à C6 : corrections directes (codes retirés ou émis, commentaires réécrits, purge des
  `deleted` inscrite à `ROADMAP.md`, `RECHERCHE_SOURCES.md` fusionné dans `MODELE_SOURCES.md`
  puis supprimé, valeurs stockées exigées, annulation testée entre deux paquets, `Debug` masqué,
  champs facultatifs exposés).
* Dépendances : `cargo update` compatible ; `hickory-resolver` 0.26.
* Documentation : `README.md`, `ROADMAP.md`, `docs/14-roadmap/ROADMAP_NOYAU.md`, `AGENTS.md` §6
  (lyxal_auth livré), `docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md` (tables
  `TYPE RELATION` de `lyxal_auth`, décision D5).

### 2.3 Fonctions Core

* Réutilisées : `fn::validation_object_execute`, `fn::sanitize_object_execute` (règles
  `lowercase`, `each`, `hexadecimal`, `object_values_type`).
* Manquante (Q-E) : borne de longueur des valeurs d'un objet.

### 2.4 Contrats modifiés (rupture coordonnée, §0.3)

| Élément | Avant | Après |
| :--- | :--- | :--- |
| Écriture directe de `auth_credential_identifier`, champs de sécurité d'`auth_identity`, `auth_api_key`, adhésion par invitation | permise selon les cas | fonctions publiques seulement |
| `fn::auth_session_valid` | ignore l'état de l'organisation | refuse une organisation non active |
| Liens envoyés par e-mail | `?token=` | `#token=` |
| Configuration de l'hôte | — | `server.trusted_proxies` |
| Erreurs levées par `THROW "<CODE>"` | `SERVER_DATABASE_UNAVAILABLE` | erreur métier avec ce code |

Tous les appelants du dépôt (catalogue, ingestion, notification, hôte, tests) sont mis à jour dans
le même changement.

## 3. Questions au CTO

| N° | Question | Recommandation |
| :--- | :--- | :--- |
| Q-A | Durées par défaut des sessions interactives | Inactivité 30 min (repoussée à chaque renouvellement), absolue 12 h ; chaque organisation peut les durcir, pas les allonger |
| Q-B | Mots de passe divulgués | Liste locale embarquée (100 000 mots de passe les plus courants), sans appel réseau ; un service externe pourra être ajouté plus tard |
| Q-C | Adresse du client derrière un proxy | Liste `server.trusted_proxies` dans la configuration ; vide par défaut (adresse de la connexion) |
| Q-D | Alertes corrigées seulement par SurrealDB 4.0 | Hors lot 6 : chantier dédié « passage à SurrealDB 4.0 » sur tout le workspace, avec son propre plan |
| Q-E | Borne de longueur des valeurs d'un objet (primitive Core manquante) | Ajouter une option `max_length` à la règle existante `object_values_type` de `lyxal_core` |
| Q-F | Codes levés par `THROW` | Reconnaissance des codes de module dans `lyxal_surreal` (un seul endroit, utile à tous les modules) |

## 4. Ordre d'exécution

1. S1, S2, S3 (permissions des tables, banc SurrealQL sous sessions d'administrateur
   d'organisation).
2. S4, S5, S7, S8, S9, S14, S15 (fonctions et services).
3. S6, S10, S11, S12, S13 (hôte, politique, jetons).
4. Q1 à Q7, C1 à C6, dépendances, documentation.
5. `scripts/ci/ci_local.sh`, `cargo audit`, nouvelle passe de l'audit ; ce plan supprimé dans la
   PR d'implémentation.
