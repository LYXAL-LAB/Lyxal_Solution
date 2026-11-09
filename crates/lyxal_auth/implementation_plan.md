# Plan d'implémentation — `lyxal_auth`, lot 4 (double facteur)

Plan détaillé du lot 4 du programme `lyxal_auth` V1 (`implementation_plan.md` à la racine, §6) :
**double facteur** (codes TOTP d'une application d'authentification, passkeys, codes de
secours), **niveau d'assurance** des sessions (AAL1 / AAL2), **montée en assurance** et
**authentification récente** pour les actions sensibles, double facteur **exigé** par la
politique ou par une organisation. Modèle : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) (Kratos
pour l'AAL et l'AMR, `available_aal`, `highest_available` et `privileged_session_max_age` ;
Keycloak pour l'action imposée `CONFIGURE_TOTP` et la remise à zéro par un administrateur ;
Logto pour l'anti-rejeu TOTP par pas et le double facteur exigé par organisation ; Kanidm et
Rauthy pour les cérémonies passkeys sur `webauthn-rs`). Aucun code avant validation de ce plan
par le CTO (`.agents/AGENTS.md` §3).

Suite : lot 5 (bascule de `lyxal_catalogue` et `lyxal_pipeline_ingestion`), lot 6 (clôture).

## 0. Écarts au plan du programme (à valider)

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | Codes de secours dans une table dédiée `auth_recovery_code` (une ligne par code, empreinte HMAC) et non comme un `auth_credential` de type `recovery_code` | Consommation **atomique** par la base (`UPDATE … WHERE used_at IS NONE`) : deux requêtes simultanées ne peuvent pas utiliser le même code ; aucun secret à déchiffrer pour vérifier |
| E2 | Fonctions découpées selon les cérémonies réelles (§5) au lieu de la liste indicative du programme (`auth_mfa_verify`, `auth_session_step_up`…) | WebAuthn se fait en deux temps (options puis réponse) et la vérification cryptographique est en Rust : SurrealQL reçoit des résultats, jamais des secrets |
| E3 | État des cérémonies passkeys conservé **scellé** dans le parcours (`auth_flow.secret_state`, `enc:v2`, illisible), ce qui demande la fonctionnalité `danger-allow-state-serialisation` de `webauthn-rs` (Q2) | Plusieurs instances de `lyxal-server` sans état partagé en mémoire : l'état doit vivre en base. Il n'est jamais envoyé au client, et son scellement empêche toute modification |

## 1. Périmètre

**Dans le lot 4** :

* **TOTP** (RFC 6238, `lyxal_crypto::totp`) : enrôlement (secret, URI `otpauth://` pour le
  QR code affiché par l'interface), confirmation par un premier code, suppression ;
  vérification avec fenêtre ±1 pas et **anti-rejeu par pas** ;
* **passkeys** (WebAuthn, `webauthn-rs`) : plusieurs par identité (nom libre), en **second
  facteur** après le mot de passe et en **connexion sans mot de passe** (clé découvrable,
  vérification de l'utilisateur exigée, Q3) ; compteur et indicateurs de sauvegarde mis à jour ;
* **codes de secours** : 10 codes (politique) de 10 caractères affichés une seule fois,
  régénération (remplace tous les anciens), usage unique, alerte quand il en reste 2 ou moins ;
* **niveau d'assurance** : `auth_identity.available_aal` recalculé à chaque changement de
  facteur ; AAL et méthodes (`amr`) de la session ; claim `aal` du jeton ;
* **connexion en deux temps** : mot de passe juste et double facteur actif → parcours
  `mfa_required`, aucune session avant le second facteur ;
* **double facteur exigé** : politique de l'installation (`mfa.required`), organisation
  (`auth_organization.mfa_required`, appliqué à l'entrée dans l'organisation), rôle
  (`mfa.required_roles`, Q4) → action imposée `configure_mfa`, enrôlement possible depuis le
  parcours de connexion (sans session) ;
* **montée en assurance** d'une session AAL1 vers AAL2 ;
* **actions sensibles** : changement de mot de passe et d'adresse, gestion des facteurs, clés
  d'API, révocation des autres sessions → AAL la plus haute disponible (`highest_available`) **et**
  authentification récente (`mfa.privileged_max_age_seconds`, 15 min) ;
* **niveau minimal par permission** : `auth_permission.min_aal` (1 par défaut), vérifié par
  `fn::auth_has_permission` — un module peut réserver une permission aux sessions AAL2 ;
* **remise à zéro par un administrateur** (appareil perdu) : suppression des facteurs d'une
  identité par `auth.identity.manage` (ou `auth.member.manage` de son organisation), sessions
  de l'identité révoquées ;
* **alertes de sécurité par e-mail** (Q5) : facteur ajouté ou retiré, codes de secours
  régénérés, code de secours utilisé, mot de passe changé — parcours et gabarits fr / en de
  `lyxal_notification`.

**Hors lot 4** : appareils de confiance (« ne plus demander sur cet appareil »), double facteur
adaptatif, codes par SMS (V2, `ROADMAP.md`) ; bascule des autres modules (lot 5).

## 2. Modèle de données (`schema/`)

| Table | Changement |
| :--- | :--- |
| `auth_credential` | `type` : `password`, `totp`, `passkey` ; `state` (`pending` : TOTP non confirmé, purgé après `flow.ttl_seconds` ; `active`) ; `label` (passkeys) ; `credential_id` (option, identifiant WebAuthn en Base64 URL, **unique pour l'installation**) ; `public_data` : TOTP `{ algorithm, digits, step_seconds, last_step }`, passkey (clé publique sérialisée par `webauthn-rs`, compteur, indicateurs `backup_eligible` / `backup_state`, `aaguid`) ; `secret_data` (scellé, illisible) : secret TOTP. Index unique (`identity`, `type`) remplacé par `slot_key` unique par identité (`password`, `totp`, `passkey:<credential_id>`) |
| `auth_recovery_code` (nouvelle, E1) | `identity` (`REFERENCE`, cascade), `batch` (UUID v7 de la génération), `code_hash` (HMAC-SHA256 avec la clé `code_pepper`, `PERMISSIONS FOR select NONE`), `used_at`, `created_at` ; index unique `code_hash` |
| `auth_flow` | types `login` (état `mfa_required` ajouté), `passkey_login` (`started` → `completed`), `mfa_enrollment` (`started` → `completed`, enrôlement TOTP ou passkey), `step_up` (`started` → `completed`) ; `secret_state` (scellé, illisible, E3) ; `attempts` déjà présent (≤ `mfa.max_attempts`) |
| `auth_identity` | `available_aal` recalculé par `DEFINE EVENT` sur `auth_credential` (2 dès qu'un TOTP ou une passkey **actif** existe ; les codes de secours seuls ne comptent pas) |
| `auth_session` | `aal` 1 ou 2, `amr` `[{ method, at }]` (méthodes : `password`, `totp`, `passkey`, `recovery_code`) ; `authenticated_at` (dernière authentification, pour l'authentification récente) |
| `auth_permission` | `min_aal` (1 ou 2, défaut 1) |
| `auth_required_action` | action `configure_mfa` |
| `auth_policy` | `mfa` : `required`, `methods`, `required_roles` (Q4), `max_attempts` (5), `recovery_code_count` (10), `privileged_max_age_seconds` (900), `passkey_user_verification` (`required`) |
| `auth_login_failure` | `kind` `mfa` (échecs du second facteur par identité, même verrouillage que le mot de passe) |

## 3. Parcours et règles

```text
Connexion (mot de passe juste)
  actions imposées en attente (dont configure_mfa)  → action_required (lot 3, étendu)
  double facteur actif (available_aal = 2)          → mfa_required { methods: [totp, passkey, recovery_code] }
       code TOTP / code de secours / réponse passkey → session AAL2, amr [password, <méthode>]
  sinon                                             → session AAL1

Connexion sans mot de passe (passkey découvrable, vérification de l'utilisateur)
  options (défi) → réponse → identité retrouvée par credential_id → session AAL2, amr [passkey] (Q3)

Montée en assurance (session AAL1, identité AAL2 disponible)
  facteur présenté → session.aal = 2, amr complété, authenticated_at = maintenant, nouveau jeton
```

* **TOTP** : secret de 20 octets (`TotpSecret::generate`, SHA-1, 6 chiffres, 30 s : seuls
  réglages reconnus par toutes les applications), scellé par identité
  (`with_tenant("lyxal_installation", "lyxal_auth", "auth_credential", <id>, "totp")`) ; un pas
  déjà utilisé est refusé (mise à jour conditionnelle `last_step < pas`) ; l'enrôlement n'est
  actif qu'après un premier code juste.
* **Passkeys** : identifiant de partie de confiance (`rp_id`) et origine tirés de
  `auth.public_url` (surcharge `auth.passkey.rp_id`), nom affiché `application.name` ;
  attestation non exigée (`none`, comme Kratos et Logto : la liste des modèles autorisés est un
  sujet V2) ; un `credential_id` déjà enregistré ailleurs est refusé ; compteur qui recule →
  refus et événement (clé clonée).
* **Codes de secours** : 10 codes de 10 caractères (alphabet sans caractères ambigus, `OsRng`,
  ≈ 50 bits), affichés une fois, empreinte HMAC ; régénération = suppression des anciens dans la
  même transaction ; chaque utilisation publie un événement.
* **Tentatives** : un parcours accepte `mfa.max_attempts` essais ; les échecs du second facteur
  sont comptés par identité (`auth_login_failure` `mfa`) et verrouillent comme le mot de passe
  (`AUTH_TOO_MANY_ATTEMPTS`). Même message d'échec pour tous les facteurs (`AUTH_MFA_INVALID`).
* **Double facteur exigé** : si la politique, une organisation de l'identité (à la connexion
  dans cette organisation ou au changement d'organisation active) ou un de ses rôles l'exige et
  que l'identité n'a aucun facteur, l'action `configure_mfa` bloque la session ; l'enrôlement se
  fait depuis le parcours de connexion, puis la session est ouverte en AAL2.
* **Actions sensibles** (`fn::auth_assurance_check`) : session AAL2 si l'identité peut l'atteindre
  (`highest_available`) et dernière authentification de moins de
  `mfa.privileged_max_age_seconds` ; sinon `AUTH_AAL_INSUFFICIENT` ou
  `AUTH_REAUTHENTICATION_REQUIRED`, que l'interface résout par la montée en assurance.
* **Dernier facteur** : quand le double facteur est exigé, retirer le dernier facteur est refusé
  (`AUTH_MFA_LAST_FACTOR`) ; un administrateur peut toujours remettre à zéro (l'action
  `configure_mfa` est alors posée).
* **Niveau minimal par permission** : `fn::auth_has_permission` renvoie faux si
  `session.aal < permission.min_aal` (relu en base à chaque appel, pas depuis le jeton).

## 4. Sessions et jetons

* Le claim `aal` du jeton reflète la session à l'émission ; la base contrôle toujours la valeur
  enregistrée (`$auth.aal`), ce qui rend la montée en assurance effective immédiatement, même
  pour un jeton déjà émis.
* Montée en assurance et changement d'organisation conservent `authenticated_at` de la
  session ; le renouvellement ne le modifie pas (seule une authentification le fait).
* `fn::auth_context` renvoie `aal`, `amr` et `authenticated_at`.

## 5. Fonctions publiques (`functions/mfa/`, `fn::auth_*($params: object)`)

Entrées par le moteur `lyxal_core`, retour `fn::result_ok` / `fn::error_result`, écriture
vérifiée (`AUTH_WRITE_FORBIDDEN`), `COMMENT`. Les fonctions de cérémonie ne reçoivent que des
résultats de vérification calculés en Rust : elles sont réservées à la **session système**.

| Domaine | Fonctions | Appelant |
| :--- | :--- | :--- |
| Facteurs | `auth_mfa_factor_list` (sans secret), `auth_mfa_factor_remove`, `auth_mfa_reset` (administrateur) | identité (actions sensibles) ; administrateur |
| TOTP | `auth_mfa_totp_begin` (secret scellé, `pending`), `auth_mfa_totp_activate`, `auth_mfa_totp_secret_get` (enveloppe scellée), `auth_mfa_totp_step_use` (anti-rejeu) | système |
| Passkeys | `auth_mfa_passkey_save`, `auth_mfa_passkey_find` (par `credential_id`), `auth_mfa_passkey_list_for` (clés autorisées pour une identité), `auth_mfa_passkey_update` (compteur, indicateurs, `last_used_at`), `auth_mfa_passkey_rename` | système ; identité |
| Codes de secours | `auth_mfa_recovery_codes_replace` (empreintes), `auth_mfa_recovery_code_use` (consommation atomique) | système |
| Tentatives | `auth_mfa_failure_check`, `auth_mfa_failure_record`, `auth_mfa_failure_reset` | système |
| Cérémonies | `auth_flow_state_save` / `auth_flow_state_take` (état scellé, lu une seule fois) | système |
| Sessions | `auth_session_step_up` (AAL2, `amr`, `authenticated_at`), `auth_assurance_check` (`{ min_aal: 1 \| 2 \| "highest_available", max_age_seconds }`, utilisable par tout module) | système ; tous |
| Contexte (étendu) | `auth_context` (`amr`, `authenticated_at`), `auth_has_permission` (`min_aal`), `auth_session_open` (AAL, exigences de double facteur) | tous ; système |

## 6. Contrats Rust (`src/`)

* `MfaService` :
  * TOTP par `lyxal_crypto::totp` (`TotpSecret::generate`, `totp_verify` avec fenêtre 1,
    `totp_uri`) ;
  * codes de secours (`OsRng`, HMAC `code_pepper` par `lyxal_crypto::hmac`) ;
  * passkeys par `webauthn-rs` (`Webauthn` construit depuis la configuration de l'hôte,
    `start_passkey_registration` / `finish_…`, `start_passkey_authentication` / `finish_…`,
    `start_discoverable_authentication` pour la connexion sans mot de passe) ;
  * état de cérémonie sérialisé puis scellé par `CryptoEngine::seal` sous
    `with_tenant("lyxal_installation", "lyxal_auth", "auth_flow", <id>, "webauthn_state")`.
* `AccessService` étendu :
  * `LoginOutcome::MfaRequired { flow, methods }` ;
  * `complete_login_mfa(flow, MfaProof)` ;
  * `passkey_login_options` / `passkey_login` ;
  * `step_up_options` / `step_up` ;
  * enrôlement depuis un parcours de connexion (`configure_mfa`).
* `MfaProof` : `Totp(SecretString)`, `RecoveryCode(SecretString)`, `Passkey(PublicKeyCredential)`.
* Résultats nommés (`TotpEnrollment { flow, otpauth_uri: SecretString }`,
  `RecoveryCodes(Vec<SecretString>)`, `PasskeyOptions`) ; `Debug` masqué pour tout secret ;
  aucun `panic!`.
* Dépendance ajoutée : `webauthn-rs` (Q1), avec les fonctionnalités `danger-allow-state-serialisation`
  (E3, Q2) et `conditional-ui` (proposition de passkey dans le champ identifiant). Aucune crate
  cryptographique importée directement par `lyxal_auth`.

## 7. Hôte (`apps/lyxal-server`)

Routes `/api/v1/auth` (🔒 : jeton d'une session interactive ; ✱ : action sensible, §3) :

| Route | Rôle |
| :--- | :--- |
| `POST /flows/{flow}/mfa` | second facteur d'une connexion (`totp`, `recovery_code`, ou réponse passkey) → jetons |
| `POST /flows/{flow}/mfa/passkey/options` | défi passkey pour ce parcours |
| `POST /passkey/login/options`, `POST /passkey/login` | connexion sans mot de passe |
| `GET /mfa` 🔒 | facteurs de l'identité (types, noms, dates, codes de secours restants) |
| `POST /mfa/totp` 🔒✱, `POST /mfa/totp/confirm` 🔒✱, `DELETE /mfa/totp` 🔒✱ | enrôlement, confirmation, suppression |
| `POST /mfa/passkeys/options` 🔒✱, `POST /mfa/passkeys` 🔒✱, `PATCH /mfa/passkeys/{id}` 🔒, `DELETE /mfa/passkeys/{id}` 🔒✱ | ajout, nom, suppression |
| `POST /mfa/recovery-codes` 🔒✱ | génération (codes affichés une seule fois) |
| `POST /session/step-up/options` 🔒, `POST /session/step-up` 🔒 | montée en assurance → nouveau jeton |

* Les routes d'enrôlement acceptent aussi un parcours de connexion en attente de
  `configure_mfa` (champ `flow`) à la place du jeton.
* Les routes ✱ existantes (`/password`, `/address-change`, `DELETE /sessions/{id}`) passent par
  `fn::auth_assurance_check`.
* Configuration : `auth.passkey.rp_id` (facultatif, défaut : hôte de `auth.public_url`).

## 8. Master data (`error/`, préfixe `AUTH_`)

Thème `mfa` : `AUTH_MFA_REQUIRED`, `AUTH_MFA_INVALID` (message unique), `AUTH_MFA_NOT_ENROLLED`,
`AUTH_MFA_ALREADY_ENROLLED`, `AUTH_MFA_METHOD_DISABLED`, `AUTH_MFA_LAST_FACTOR`,
`AUTH_PASSKEY_INVALID`, `AUTH_PASSKEY_TAKEN`, `AUTH_PASSKEY_UNAVAILABLE` (configuration
absente). Thème `sessions` : `AUTH_AAL_INSUFFICIENT`, `AUTH_REAUTHENTICATION_REQUIRED`. Fr et
en, catégorie, statut HTTP, réessayable.

## 9. Événements

`auth.mfa.enrolled`, `auth.mfa.removed` (dont la remise à zéro par un administrateur),
`auth.mfa.recovery_codes_generated`, `auth.mfa.recovery_code_used` (codes restants),
`auth.mfa.failed` (empreinte de l'identité, méthode), `auth.passkey.clone_detected`,
`auth.session.step_up`. Les événements d'alerte (Q5) portent `recipient_email`,
`recipient_locale` et `recipient_name`, comme les événements du lot 3 ; aucun code, secret ni
clé dans une charge utile.

`lyxal_notification` (Q5) :

* consommateur étendu à `auth.mfa.enrolled`, `auth.mfa.removed`,
  `auth.mfa.recovery_codes_generated`, `auth.mfa.recovery_code_used`, `auth.password.changed`
  (ce dernier reçoit `recipient_*` dans sa charge utile) ;
* parcours `auth.security_alert` critique, gabarits fr / en.

## 10. Fonctions Core réutilisées et besoins signalés

Réutilisées : `fn::validation_object_execute` (`enum`, `record`, `required_string`,
`hexadecimal`, `integer`, `uuid_v7`, `array_of_strings`), `fn::sanitize_object_execute`
(`trim`). Aucune fonction Core manquante. Crypto : `totp_generate` / `totp_verify` /
`totp_uri`, `sign_hmac_sha256`, `CryptoEngine::seal` / `open`, `OsRng` ; **aucune extension de
`lyxal_crypto`**. WebAuthn : `webauthn-rs`, décision D3 du programme (version et fonctionnalité : Q1, Q2).

## 11. Tests

* **Banc SurrealQL** :
  * chaque fonction publique ;
  * `available_aal` recalculé (ajout, confirmation, suppression) ;
  * anti-rejeu TOTP (même pas refusé) ;
  * code de secours à usage unique, y compris sur deux consommations simultanées dans une
    transaction ;
  * parcours `mfa_required` (aucune session avant le second facteur, tentatives, verrouillage) ;
  * `configure_mfa` par politique, organisation et rôle ;
  * montée en assurance ;
  * `fn::auth_assurance_check` (AAL, ancienneté) ;
  * `min_aal` d'une permission ;
  * dernier facteur protégé ;
  * remise à zéro par un administrateur (sessions révoquées) ;
  * secrets illisibles ;
  * fonctions système refusées à une identité.
* **Rust** :
  * vecteurs RFC 6238 au travers de `MfaService` ;
  * cérémonies passkeys complètes avec l'authentificateur logiciel de `webauthn-rs`
    (`webauthn-authenticator-rs`, dépendance de test) : enrôlement, second facteur, connexion
    sans mot de passe, compteur qui recule refusé, défi rejoué refusé ;
  * connexion en deux temps de bout en bout ;
  * alerte reçue par le serveur SMTP de test de `lyxal_notification`.
* **Serveur** :
  * routes `/api/v1/auth/mfa*`, `/flows/{flow}/mfa`, montée en assurance ;
  * action sensible refusée puis acceptée après montée en assurance ;
  * jeton de session AAL1 refusé sur une permission `min_aal: 2`.
* `scripts/ci/ci_local.sh` complet ; revue ciblée OWASP ASVS niveau 2 (V2.7, V2.8, V2.9 :
  facteurs hors bande, TOTP, cryptographie de l'authentificateur).

## 12. Fichiers

`crates/lyxal_auth/` :

* `schema/` : `14_auth_credential.surql` étendu, `17_auth_recovery_code.surql`, champs ajoutés
  aux tables existantes ;
* `functions/mfa/`, `events/`, `error/mfa/`, `seeds/` (politique, `min_aal`), `tests/` ;
* `src/` : `services/mfa.rs`, `models/mfa.rs` ;
* `README.md`, `ROADMAP.md`.

`crates/lyxal_notification/` (Q5) : consommateur, seeds (parcours et gabarits), tests, `README.md`.

Hôte : `src/http/auth.rs` (ou `src/http/auth/` découpé), `src/config.rs` (`auth.passkey`),
`README.md`.

Racine : plan du programme (lot 4 réalisé). Ce plan est supprimé une fois exécuté.

## 13. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | Version de `webauthn-rs` : **0.6.2** (actuelle, entièrement en Rust : cryptographie RustCrypto par la crate `crypto-glue` des mêmes auteurs, dont `rsa` encore en version préliminaire 0.10.0-rc ; ≈ 450 crates au total) ou **0.5.5** (lignée plus ancienne et éprouvée, mais exige OpenSSL installé sur la machine de compilation et dans l'image) | **0.6.2** : version maintenue, utilisée par Kanidm, aucune bibliothèque système ; `lyxal_auth` n'importe aucune crate cryptographique directement. Risque connu : `rsa` préliminaire (signatures RS256 de Windows Hello), suivi au lot 6 |
| Q2 | Activer `danger-allow-state-serialisation` de `webauthn-rs` pour conserver l'état des cérémonies en base, scellé (E3) | Oui : indispensable avec plusieurs instances ; l'état n'est jamais exposé ni modifiable |
| Q3 | Une connexion **sans mot de passe** par passkey (vérification de l'utilisateur exigée : empreinte, visage ou code de l'appareil) vaut **AAL2** | Oui : possession de l'appareil + vérification de l'utilisateur = deux facteurs (NIST SP 800-63B rév. 4) ; Kratos la compte AAL1, ce qui imposerait un second facteur en plus de la passkey |
| Q4 | Double facteur **exigé par défaut pour `platform_admin`** (`mfa.required_roles: ["platform_admin"]` dans la politique installée), les autres rôles restant libres | Oui : un compte d'administration de la plateforme ne doit pas reposer sur un seul mot de passe ; réglable dans la politique |
| Q5 | **Alertes de sécurité par e-mail** dès ce lot (facteur ajouté ou retiré, codes de secours régénérés ou utilisés, mot de passe changé), ce qui touche aussi `lyxal_notification` | Oui : pratique de Keycloak et Logto ; un titulaire est prévenu si quelqu'un modifie sa sécurité |
