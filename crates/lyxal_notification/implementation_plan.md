# Plan d'implémentation — `lyxal_notification`, lot 6 : notifications push

Sixième lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées ; lots 1 à 5 livrés). Ce lot ajoute le canal **push** : les
notifications qui apparaissent sur l'écran d'un navigateur (**Web Push**), d'un téléphone Android
(**Firebase Cloud Messaging**) ou d'un iPhone (**Apple Push Notification service**). Il étend
`lyxal_crypto` comme le CTO l'a validé (K8) : signatures ES256 et RS256, chiffrement Web Push.
Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **G1** | Où sont rangés les appareils | Comme adresses de l'abonné (`notification_endpoint`, canal `push`, services `webpush`, `fcm`, `apns`), inscrites **par la personne elle-même** depuis son navigateur ou son application (session `lyxal_auth`), au plus 10 par personne. Le jeton de l'appareil (et, pour Web Push, l'adresse du service et les clés du navigateur) est **scellé** (`enc:v2`) comme les adresses du lot 4 : seul le worker le lit. Un gestionnaire voit seulement le type d'appareil et sa date d'inscription. |
| **G2** | Identifiants des services | Intégrations du canal `push`, identifiants dans `lyxal_secrets` (décision D2) : **Web Push** : paire de clés VAPID (P-256) et contact (`mailto:` ou `https:`) ; la clé publique est donnée aux navigateurs par une route de l'hôte. **FCM** : fichier du compte de service Google (identifiant du projet, adresse du compte, clé privée RSA). **APNs** : clé `.p8` (ES256), identifiant de la clé, de l'équipe et de l'application, production ou bac à sable. Une route de l'hôte génère une paire VAPID neuve (clé privée rangée directement dans le coffre, jamais montrée). |
| **G3** | Cryptographie (K8) | Ajouts à `lyxal_crypto`, par `ring`, sous types opaques au `Debug` masqué : **signature ES256** (clé P-256 importée ou générée par `OsRng` ; jetons VAPID et APNs) ; **signature RS256** (clé RSA importée ; jeton du compte de service Google, échangé contre un jeton d'accès) ; **chiffrement Web Push** RFC 8291 (`aes128gcm` : échange de clés ECDH P-256 éphémère, HKDF-SHA256, AES-128-GCM), avec les vecteurs de test de la RFC. Rien d'autre (pas de vérification de ces signatures, pas d'autre courbe). |
| **G4** | Contenu d'une notification push | Titre, texte, lien (règles du lot 5 : chemin de l'application ou HTTPS), icône, données libres ; **4 Kio au plus** une fois chiffré (limite de Web Push), texte tronqué proprement au-delà. Une étape push d'un parcours `sensitive` est **refusée** : le contenu traverse les serveurs de Google ou d'Apple. Préférences et heures calmes du canal `push` appliquées. |
| **G5** | Appareils invalides | Retirés automatiquement quand le service le dit (Web Push 404 / 410, FCM `UNREGISTERED` / `INVALID_ARGUMENT` sur le jeton, APNs 410 `Unregistered` / `BadDeviceToken`) ; un appareil retiré ne fait pas échouer l'étape si un autre appareil a reçu la notification. Événement `notification.endpoint.removed` (identifiants seulement). |
| **G6** | Appels aux services | FCM et APNs : adresses officielles fixes (APNs en HTTP/2). Web Push : l'adresse donnée par le navigateur doit être **HTTPS** et appartenir à un service push connu (Google, Mozilla, Microsoft, Apple), et passe par le client protégé du lot 4 (contrôle des adresses résolues, aucune redirection). Jetons d'accès FCM et APNs gardés en mémoire jusqu'à leur échéance (APNs : renouvelé toutes les 50 minutes). |

## 2. Modèle (SurrealQL, réécrit en place)

| Table | Changement |
| :--- | :--- |
| `notification_endpoint` | canal `push`, services `webpush`, `fcm`, `apns` ; plateforme (`web`, `android`, `ios`) ; jeton scellé ; pour Web Push, clés du navigateur scellées (`p256dh`, `auth`) |
| `notification_integration` | canal `push`, fournisseurs `webpush`, `fcm`, `apns` (réglages non secrets : contact VAPID, identifiant du projet, de l'équipe, de l'application, environnement APNs) |
| `notification_workflow.steps` | type `push` (refusé pour un parcours `sensitive`) |
| `notification_template` | champs push : titre, texte, lien, icône, données |
| `notification_message` | canal `push` (`to` : type d'appareil, jamais le jeton) |

## 3. Fonctions publiques (`fn::notification_*($params: object)`)

| Fonction | Rôle | Accès |
| :--- | :--- | :--- |
| `notification_my_device_register` | inscription d'un appareil de la personne (valeurs scellées par l'hôte) ; une même inscription renvoyée met l'appareil à jour au lieu d'en créer un autre | session de la personne |
| `notification_my_device_list`, `_delete` | ses appareils (sans jeton) | session de la personne |
| `notification_device_list` | appareils d'un abonné (type et date seulement) | `notification.read` |
| `notification_device_remove` (worker) | appareil retiré sur réponse du service (G5) | `notification.worker` |
| `notification_job_claim` (étendue) | étape push : appareils scellés de l'abonné, intégration de chaque service | `notification.worker` |
| `notification_integration_*` (étendues) | fournisseurs push | `notification.manage` |

## 4. Erreurs (`error/push/`)

`NOTIFICATION_DEVICE_INVALID` (inscription mal formée, service push inconnu),
`NOTIFICATION_DEVICE_LIMIT` (plus de 10 appareils), `NOTIFICATION_DEVICE_NOT_FOUND`,
`NOTIFICATION_PUSH_TOO_LARGE`.

## 5. Rust et hôte

* `lyxal_crypto` (G3) : `EcdsaP256SigningKey` (`import_pkcs8`, `generate`, `public_key_uncompressed`,
  `sign_es256`), `RsaSigningKey` (`import_pkcs8`, `sign_rs256`), `webpush_encrypt(ua_public,
  auth_secret, plaintext)` ; contrat de l'API, règles §11.3 et contrôles `crypto_checks.sh` mis à
  jour ; vecteurs RFC 8291 et essais croisés avec une vérification indépendante en test.
* `PushProvider` : `WebPushProvider` (jeton VAPID, chiffrement, en-têtes `TTL`, `Urgency`),
  `FcmProvider` (jeton d'accès OAuth du compte de service, API HTTP v1), `ApnsProvider` (jeton
  ES256, HTTP/2, en-têtes `apns-topic`, `apns-push-type`).
* Worker du canal `push`, sur la file commune ; retrait des appareils invalides (G5).
* Hôte : routes `POST /api/v1/notification/my/devices` (inscription, scellement),
  `GET /api/v1/notification/push/vapid-key` (clé publique de l'intégration Web Push),
  `POST /api/v1/notification/integrations/{intégration}/vapid` (paire VAPID neuve rangée dans le
  coffre, droit de gestion).
* Dépendance : `ring` déjà présente dans `lyxal_crypto` ; fonction `http2` de `reqwest` pour APNs.

## 6. Tests

* Banc SurrealQL : inscription (personne seule, valeurs scellées exigées, limite, mise à jour
  d'une inscription existante, service push inconnu refusé), lecture sans jeton, droits,
  étape push d'un parcours sensible refusée, préférences et heures calmes, retrait d'un appareil.
* Rust : cryptographie (vecteurs RFC 8291, ES256 et RS256 vérifiés par une implémentation
  indépendante en test seulement) ; chaque service contre un faux service local (requête, en-têtes,
  jetons, réponses, appareil invalide retiré) ; de bout en bout : déclenchement → trois appareils
  (web, Android, iPhone) ; un appareil invalide retiré, les autres servis.
* Hôte : inscription par la personne, clé VAPID publique, génération d'une paire VAPID.
* `scripts/ci/ci_local.sh` vert ; **essais réels** ajoutés à la liste : navigateur (Chrome,
  Firefox, Safari), téléphone Android, iPhone (bac à sable puis production).

## 7. Documents

`README.md` (canal push, inscription des appareils, mise en service de chaque service),
`ROADMAP.md` (V1-e terminée, essais réels), README de l'hôte, contrat de `lyxal_crypto`. Ce plan
est supprimé une fois exécuté.

## 8. Checklist (§13)

* `lyxal_core` pour toutes les entrées ; aucune primitive nouvelle.
* `lyxal_crypto` : seulement les ajouts G3 validés par K8 ; aucune crate cryptographique dans le
  module ; `OsRng` pour toute génération.
* Aucun jeton d'appareil ni clé en clair en base, dans un événement ou dans les journaux ;
  écritures vérifiées ; une seule migration ; versions `0.y.z`.
