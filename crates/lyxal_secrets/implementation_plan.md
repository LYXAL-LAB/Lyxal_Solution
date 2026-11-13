# Plan d'implémentation — `lyxal_secrets`, lot 3 : cycle de vie

Troisième lot du programme `lyxal_secrets` (`implementation_plan.md` à la racine). Il ajoute ce qui
fait vivre un secret dans le temps : alertes avant l'échéance et à l'échéance, rappel de rotation,
**rotation en quatre étapes sans coupure** (modèle AWS : `createSecret`, `setSecret`, `testSecret`,
`finishSecret`), essai de rotation sans bascule, rotation d'urgence, rotation planifiée des clés
d'organisation. Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

L'expiration est déjà appliquée depuis le lot 1 (un secret expiré est refusé à la lecture).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **C1** | Qui change la valeur d'un secret qui doit tourner ? | Le coffre-fort ne connaît pas les services extérieurs (fournisseur d'e-mail, base de données…). Un module qui sait changer un identifiant chez un service s'inscrit comme **« rotateur »** pour un type de secret ; à l'échéance, le coffre-fort le fait travailler. **Sans rotateur**, le coffre-fort publie seulement « rotation due » et le rappel (modèle Google) : une personne écrit la nouvelle valeur |
| **C2** | Rotation qui échoue | **3 essais** espacés (1 min, 10 min, 1 h), puis rotation marquée en échec et signalée. **La valeur en service n'est jamais retirée** tant que la nouvelle n'a pas réussi son test : aucune coupure |
| **C3** | Rotation d'urgence (fuite soupçonnée) | Une seule action : **la version en service est désactivée aussitôt** (plus aucune lecture), puis la rotation démarre. Sans rotateur, le secret reste inutilisable jusqu'à ce qu'une personne écrive une nouvelle valeur. Droit `secrets.secret.write` et double facteur pour une personne |
| **C4** | Alertes | **Une alerte** quand l'échéance approche (réglage existant `expiry_warning_days`, 30 jours), **une** à l'échéance, **un** rappel par cycle de rotation. Ce sont des événements sur le bus ; leur envoi par e-mail relèvera de `lyxal_notification` |
| **C5** | Rotation automatique des clés d'organisation | **Tous les 365 jours** par défaut (réglage `tenant_key_rotation_days`, de 30 à 3650, ou désactivée) ; même mécanisme que la rotation à la demande du lot 2 |
| **C6** | Essai sans bascule | Une action « vérifier » demande au rotateur de **tester la valeur en service** auprès du service extérieur, sans rien changer ; le résultat est journalisé. Utile pour détecter un identifiant révoqué avant l'échéance |

## 2. Rotation en quatre étapes

```text
rotation_begin ─► création : le rotateur produit la nouvelle valeur ; version écrite en « pending »
               ─► installation : le rotateur l'active chez le service extérieur
               ─► test : le rotateur vérifie qu'elle fonctionne
               ─► rotation_finish : « current » passe sur la nouvelle version,
                  l'ancienne devient « previous » (elle reste valide chez le service
                  jusqu'au cycle suivant : deux jeux valides, aucune coupure)
échec ─► nouvel essai (C2) ; après 3 échecs : rotation_fail, « pending » retirée, current inchangée
```

* Une seule rotation en cours par secret.
* Chaque étape est enregistrée dans `secrets_rotation`, journalisée et publiée. Une rotation
  interrompue (arrêt du serveur) reprend à l'étape atteinte.
* À la réussite : `last_rotated_at` posé, `next_rotation_at` = maintenant + période, alertes remises
  à zéro.

## 3. SurrealQL

### Schéma

| Élément | Contenu |
| :--- | :--- |
| `secrets_secret` (champs ajoutés) | `last_rotated_at`, `expiry_warned_at`, `expired_notified_at`, `rotation_notified_at` (alertes déjà envoyées ; remises à zéro quand l'échéance change ou qu'une nouvelle version devient courante) |
| Table `secrets_rotation` | `secret`, `tenant`, `state` (`started`, `created`, `installed`, `tested`, `succeeded`, `failed`, `cancelled`), `emergency`, `pending_number`, `attempts`, `next_attempt_at`, `last_error` (code, jamais de valeur), `started_by`, `started_at`, `finished_at` ; une seule rotation en cours par secret (index unique) ; droits : lecture comme la fiche, écriture par les fonctions |
| `secrets_settings` (champ ajouté) | `tenant_key_rotation_days` (`NONE` : défaut 365 ; `0` : désactivée ; sinon 30 à 3650) |

### Fonctions (`DEFINE FUNCTION OVERWRITE fn::<nom>($params: object)`, résultat `fn::result_ok` ou `fn::error_result`)

| Fonction | `$params` (**obligatoires**) | `data` | Appelant |
| :--- | :--- | :--- | :--- |
| `secrets_due_list` | `limit` | `{ expiring, expired, rotation_due, tenant_keys_due }` (secrets et portées à traiter) | worker |
| `secrets_due_mark` | **secret**, **kind** (`expiring`, `expired`, `rotation_due`) | `{ marked }` ; publie l'événement correspondant | worker |
| `secrets_rotation_begin` | **secret**, `emergency`, `reason` | rotation `started` ; `SECRETS_ROTATION_IN_PROGRESS` s'il y en a une ; urgence : version courante désactivée | écriture (+ double facteur pour une personne en urgence), worker |
| `secrets_rotation_step` | **rotation**, **step** (`created`, `installed`, `tested`), `pending_number` (pour `created`) | rotation à l'étape suivante | worker, système |
| `secrets_rotation_finish` | **rotation** | rotation `succeeded` ; étiquettes déplacées, dates posées | worker, système |
| `secrets_rotation_fail` | **rotation**, **code**, `retry` | `failed`, ou nouvel essai planifié (`next_attempt_at`) ; `pending` retirée en échec définitif | worker, système |
| `secrets_rotation_cancel` | **rotation**, `reason` | `cancelled`, `pending` retirée | écriture |
| `secrets_rotation_get` | **secret**, `limit` | rotation en cours et historique | liste |
| `secrets_rotation_list_due` | `limit` | rotations à reprendre (essai planifié échu, étape interrompue) | worker |
| `secrets_rotation_check_record` | **secret**, **ok**, `code` | `{ seq }` ; résultat de l'essai sans bascule journalisé et publié | worker, système |

Entrées validées par `fn::validation_object_execute` ; règles du Core : `record`, `enum`, `boolean`,
`integer`, `optional_string`.

### Événements (`fn::event_publish`, jamais de valeur)

`secrets.secret.expiring`, `secrets.secret.expired`, `secrets.secret.rotation_due`,
`secrets.rotation.started`, `secrets.rotation.succeeded`, `secrets.rotation.failed`,
`secrets.rotation.cancelled`, `secrets.rotation.checked`. Charge : organisation, identifiant et
chemin du secret, échéance, numéro de version, code d'erreur.

### Erreurs (`error/rotation/`)

`SECRETS_ROTATION_IN_PROGRESS`, `SECRETS_ROTATION_NOT_FOUND`, `SECRETS_ROTATION_STATE_INVALID`,
`SECRETS_ROTATOR_UNAVAILABLE` (aucun rotateur pour ce secret), `SECRETS_ROTATION_TEST_FAILED`.

## 4. Rust

| Élément | Contenu |
| :--- | :--- |
| `trait SecretRotator` | `fn handles(&self, secret: &SecretRecord) -> bool` (par type de secret ou chemin) ; `async fn create(&self, secret, current: Option<&SecretBytes>) -> Result<SecretBytes, RotatorError>` ; `async fn install(&self, secret, new: &SecretBytes)` ; `async fn test(&self, secret, value: &SecretBytes)` ; `async fn retire(&self, secret, old: &SecretBytes)` (facultatif : invalide l'avant-dernière valeur chez le service) |
| `RotatorRegistry` | rotateurs inscrits par l'hôte ; au plus un par secret |
| `RotationRunner` | déroule les quatre étapes (valeur nouvelle écrite par `SecretsService::put` en `pending`), enregistre chaque étape, gère les essais (C2), reprend une rotation interrompue ; valeurs en `SecretBytes`, jamais journalisées |
| `SecretsService` | `rotate_now(RotateRequest { secret, emergency, reason })`, `check_rotation(secret)` (C6) |
| `SecretsMaintenanceWorker` | en plus : échéances (`secrets_due_list`, `secrets_due_mark`), rotations dues ou à reprendre, rotation planifiée des clés d'organisation (C5) ; `MaintenanceReport` complété (`alerts`, `rotations_succeeded`, `rotations_failed`, `tenant_keys_rotated`) |
| Modèles | `RotationRecord`, `RotationState`, `RotationStepParams`, `RotationFailParams`, `DueList`, `DueMarkParams`, `RotateRequest`, `RotatorError` (code `SECRETS_*`, message sans valeur) |

Aucun rotateur réel n'est livré dans ce lot : ils viendront avec les modules qui parlent aux
services extérieurs (`lyxal_notification` lot V1-e, `lyxal_connect`). Les tests utilisent un
rotateur de test.

## 5. Hôte

`RotatorRegistry` vide créé et passé au worker ; réglage de l'intervalle inchangé (10 minutes).

## 6. Tests

* **Banc SurrealQL** : alertes (échéance proche, échue, rotation due) envoyées une seule fois et
  remises à zéro ; machine d'états de la rotation (ordre des étapes, une seule en cours,
  annulation, échec définitif qui retire `pending`, réussite qui déplace `current` et `previous`) ;
  urgence qui désactive la version courante ; droits ; événements ; journal.
* **Rust** (rotateur de test) : rotation complète sans coupure (l'ancienne valeur reste lisible
  jusqu'à la bascule) ; test qui échoue trois fois → échec, valeur en service intacte ; reprise
  après interruption ; urgence ; secret sans rotateur → seulement l'événement « rotation due » ;
  essai sans bascule ; rotation planifiée des clés d'organisation ; aucune valeur dans les journaux.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 7. Documents

`README.md`, `ROADMAP.md`, ligne 3 du plan racine passée à « Réalisé » ; ce plan supprimé à la
fusion de l'implémentation.

## 8. Checklist (§13)

* Core : aucune extension.
* Crypto : aucune primitive nouvelle ; les valeurs produites par un rotateur sont scellées par le
  chemin du lot 2.
* Rust : aucun `panic!`, aucune erreur silencieuse ; aucune valeur dans un journal, une erreur ou
  un `Debug`.
* Zéro dette : `0.1.0`, aucune migration.
