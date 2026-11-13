# Plan d'implémentation — `lyxal_secrets`, lot 2 : chiffrement et service Rust

Deuxième lot du programme `lyxal_secrets` (`implementation_plan.md` à la racine, décisions K1 à B1).
Il ajoute le crate Rust : clés par organisation, scellement et ouverture des valeurs par
`lyxal_crypto`, lecture tracée avant remise, interface pour les autres modules, rescellement après
rotation de clé, purge à échéance, module et sonde de santé, hébergement par l'hôte. Aucune ligne de
code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions du CTO (13 novembre 2026)

R2 à R6 validées selon les recommandations. **R1 révisée après relecture, à valider de nouveau** :
la clé applicative de l'hôte est partagée avec `lyxal_auth` (clés de signature, secrets du double
facteur) et `lyxal_notification` ; la retirer après avoir rescellé les seules clés du coffre-fort
rendrait leurs données illisibles. Le coffre-fort a donc sa propre clé maîtresse.

| N° | Question | Décision |
| :- | :--- | :--- |
| **R1** (révisée) | Clé maîtresse du coffre-fort et sa rotation | **Une clé maîtresse propre au coffre-fort**, distincte de la clé applicative partagée : `LYXAL__SECRETS__MASTER_KEY` et son identifiant, par variable d'environnement seulement. Pour la changer, l'ancienne est fournie à côté (`LYXAL__SECRETS__PREVIOUS_MASTER_KEY`), en lecture seule ; le worker rescelle les clés des organisations, la sonde annonce la fin, puis on retire l'ancienne. La clé applicative de l'hôte n'est pas touchée |
| **R2** | Quand créer la clé d'une organisation ? | **À la première valeur écrite** pour cette organisation (aucune clé inutile) |
| **R3** | Rotation d'une clé d'organisation | **Sur demande** dans ce lot (permission `secrets.settings.manage`) : nouvelle clé active, l'ancienne ne sert plus qu'à relire, le worker rescelle toutes les versions, puis l'ancienne est détruite. La rotation **planifiée** (tous les N jours) arrive au lot 3 avec le cycle de vie |
| **R4** | Valeur JSON | Si la valeur est un objet JSON, **les noms de ses clés** sont enregistrés (jamais les valeurs) pour qu'un écran montre la structure ; sinon rien |
| **R5** | Serveur démarré sans clé maîtresse du coffre-fort | Le serveur **démarre**, le module est **dégradé** (sonde de santé) et toute écriture ou lecture de valeur est refusée (`SECRETS_CRYPTO_UNAVAILABLE`) ; les fiches restent consultables. Même comportement que le stockage sans support configuré |
| **R6** | Lecture refusée | **Journalisée** (OWASP 8.3) : qui, quel secret, quel code de refus, par la session système au nom de l'appelant |

## 2. Clés

```text
clé maîtresse du coffre-fort (LYXAL__SECRETS__MASTER_KEY ; ancienne clé en lecture seule pendant une rotation)
   └── clé de chaque organisation : 32 octets tirés par rand_core::OsRng dans un SecretBytes,
       scellés par la clé maîtresse et rangés dans secrets_tenant_key
          └── chaque version : scellée par la clé de son organisation
```

* Contexte de la clé d'organisation : `SecretContext::with_tenant(<organisation> ou
  "lyxal_installation", "lyxal_secrets", "secrets_tenant_key", <identifiant de clé>, "key")`.
* Contexte d'une version (fixé au lot 1) : `with_tenant(<organisation>, "lyxal_secrets",
  "secrets_version", "<clé du secret>:<numéro>", "value")`.
* Trousseau d'une organisation : construit à chaque opération (`KeyRingBuilder`,
  `StaticKeyResolver`, `CryptoEngine`) à partir de ses clés `active` et `decrypt_only`, ouvertes par
  la clé maîtresse ; aucune clé d'organisation n'est gardée en mémoire au-delà de l'opération.
* `EncryptionKey` n'exporte jamais sa matière : la clé d'organisation est donc tirée comme
  `SecretBytes` (`rand_core::OsRng`, §11.3 règle 7, comme `lyxal_auth`), scellée, puis importée par
  `EncryptionKey::import` à chaque ouverture.
* Uniquement des fonctions STABLE de `lyxal_crypto` : `EncryptionKey::import`,
  `KeyId::parse`, `KeyRingBuilder::insert` / `insert_revoked` / `build`, `StaticKeyResolver`,
  `CryptoEngine::seal` / `open` / `reencrypt_if_needed`, `SecretBytes`, `SecretContext`.
  Aucune dépendance de chiffrement ajoutée.
* Suppression d'une organisation : ses clés partent avec elle (`REFERENCE ON DELETE CASCADE`).

## 3. SurrealQL ajouté

| Élément | Contenu |
| :--- | :--- |
| Table `secrets_tenant_key` | `tenant`, `scope_key`, `key_id` (`KeyId`, unique), `wrapped` (clé scellée `enc:v2`, effacée à la destruction), `state` (`active`, `decrypt_only`, `destroyed`), `created_at`, `retired_at`, `destroyed_at` ; une seule clé `active` par portée (index unique) ; **aucun accès utilisateur** (`PERMISSIONS NONE`) |
| `fn::secrets_tenant_key_ring` | clés `active` et `decrypt_only` d'une portée (session système) |
| `fn::secrets_tenant_key_create` | première clé, ou nouvelle clé active à la rotation (l'ancienne passe en `decrypt_only`) ; une création concurrente est refusée par l'index et relue (session système) |
| `fn::secrets_tenant_key_rotate` | demande de rotation par une personne (`secrets.settings.manage`) ; journalisée |
| `fn::secrets_tenant_key_rewrap` | clé rescellée par la nouvelle clé maîtresse (session système) |
| `fn::secrets_tenant_key_destroy` | ancienne clé détruite quand plus aucune version ne l'utilise (session système) |
| `fn::secrets_rewrap_list` | versions scellées par une clé `decrypt_only`, clés d'organisation scellées par une ancienne clé maîtresse (worker) |
| `fn::secrets_audit_denied` | entrée `secret.read` au résultat `denied` (code de refus), au nom de l'appelant (session système) |
| Erreurs | `SECRETS_CRYPTO_UNAVAILABLE`, `SECRETS_VALUE_TOO_LARGE`, `SECRETS_VALUE_CORRUPTED` (une enveloppe ne s'ouvre pas : altérée ou mauvaise clé), `SECRETS_TENANT_KEY_UNAVAILABLE` |
| Journal | création, rotation, rescellement et destruction de clé ; aucune clé ni valeur |

## 4. Crate Rust `lyxal_secrets`

Dépendances : `lyxal_surreal`, `lyxal_runtime`, `lyxal_crypto`, `async-trait`, `surrealdb`,
`thiserror`, `tokio`, `tracing`, `serde_json` (lecture des noms de clés d'une valeur JSON),
`rand_core` (tirage des clés d'organisation, déjà utilisé par `lyxal_crypto` et `lyxal_auth`).
Aucune autre bibliothèque.

| Fichier | Contenu |
| :--- | :--- |
| `models/` | `XxxParams` et résultats de chaque fonction SurrealQL (`SurrealValue`, identifiants en texte `table:clé`) : `SecretRecord`, `SecretVersion`, `VersionAdded`, `ReadTicket`, `ReadEnvelope`, `TenantKey`, `RewrapList`, `AuditList`, `AuditReport`… ; enveloppes et clés scellées dans des types `pub(crate)` sans `Serialize`, `Debug` masqué |
| `store.rs` | `SecretsStore` (`LyxalSurrealCall`) : un appel d'une ligne par fonction |
| `keys.rs` | `TenantKeys` : création à la première écriture, trousseau d'une organisation, rotation, rescellement par la clé maîtresse |
| `service.rs` | `SecretsService` : sur deux sessions, celle de l'appelant (droits, journal) et la session système (enveloppe, clés) |
| `client.rs` | `SecretsClient` : interface des autres modules de l'hôte (session système, nom du module annoncé comme consommateur) |
| `worker.rs` | `SecretsMaintenanceWorker` (`LyxalWorker`, `CancellationToken`) : purge à échéance, rescellement après rotation, destruction des anciennes clés |
| `module.rs`, `health.rs` | `SecretsModule` (`LyxalModule`), `SecretsHealthCheck` (`ModuleHealthCheck`) : clé maîtresse présente, base joignable, rescellements en attente |
| `error.rs` | `SecretsError` : code `SECRETS_*` de la base, ou cause locale (chiffrement indisponible, valeur trop grande, enveloppe illisible) |

**Écriture d'une valeur** (`SecretsService::put`) : fiche lue avec les droits de l'appelant ;
taille contrôlée (réglage `max_value_bytes`) ; clé d'organisation obtenue (créée si besoin) ; valeur
scellée pour le numéro suivant ; `fn::secrets_version_add`. Sur `SECRETS_VERSION_CONFLICT`, relecture et
nouveau scellement, trois essais au plus ; avec un numéro attendu fourni par l'appelant, aucun
nouvel essai (écriture conditionnelle).

**Lecture d'une valeur** (`SecretsService::reveal`, `SecretsClient::read`) :
`fn::secrets_read_begin` (session de l'appelant, ticket tracé) → `fn::secrets_read_envelope` (session
système) → ouverture par le trousseau de l'organisation → `SecretBytes`, effacé de la mémoire à la
libération. Un refus est journalisé (R6). Une enveloppe qui ne s'ouvre pas donne
`SECRETS_VALUE_CORRUPTED`, journalisé, jamais une valeur vide.

**Rescellement** (worker, par lots) : versions d'une clé `decrypt_only` →
`reencrypt_if_needed` → `fn::secrets_version_reseal` (même valeur, même contexte, la clé attendue
protège d'une course) ; quand plus rien n'utilise l'ancienne clé, elle est détruite. Clés
d'organisation scellées par l'ancienne clé maîtresse → rescellées par la nouvelle.

## 4 bis. Contrats

### SurrealQL (`DEFINE FUNCTION OVERWRITE fn::<nom>($params: object)`, résultat `fn::result_ok` ou `fn::error_result`)

| Fonction | `$params` (**obligatoires**) | `data` | Appelant |
| :--- | :--- | :--- | :--- |
| `secrets_tenant_key_ring` | `tenant` | `{ items: [{ key_id, wrapped, state }] }` (états `active`, `decrypt_only`) | système, worker |
| `secrets_tenant_key_create` | **key_id**, **wrapped**, `tenant`, `replaces` (clé active attendue ; absente : première clé), `requested_by` (`auth_identity:…`) | `{ key_id, state, retired }` ; conflit : `SECRETS_TENANT_KEY_CONFLICT` | système, worker |
| `secrets_tenant_key_rotate_allowed` | `tenant` | `{ allowed, requested_by }` | personne avec `secrets.settings.manage` |
| `secrets_tenant_key_rewrap` | **key_id**, **expected_master_key_id**, **wrapped** | `{ key_id, master_key_id }` | système, worker |
| `secrets_tenant_key_destroy` | **key_id** | `{ key_id, destroyed }` ; encore utilisée : `SECRETS_TENANT_KEY_CONFLICT` | système, worker |
| `secrets_rewrap_list` | **master_key_id** (clé maîtresse active), `limit` (≤ 1000) | `{ versions: [{ secret, tenant, number, key_id, envelope }], keys: [{ key_id, tenant, wrapped, master_key_id }], unused: [key_id] }` | système |
| `secrets_audit_denied` | **secret**, **code**, **session_kind**, `actor`, `application`, `session`, `consumer`, `version` | `{ seq }` | système |

`fn::secrets_audit_write` (interne) accepte `on_behalf: { actor, application, session, session_kind }`,
pris en compte pour la session système seulement.

### Rust (`models/`, `#[derive(SurrealValue)]`, identifiants en texte `table:clé`)

| Type | Champs |
| :--- | :--- |
| `TenantRef` | `tenant: Option<String>` |
| `TenantKeyRing` / `TenantKeyEntry` (`pub(crate)`, `Debug` masqué) | `items: Vec<TenantKeyEntry>` ; `key_id: String`, `wrapped: String`, `state: TenantKeyState` (`Active`, `DecryptOnly`) |
| `TenantKeyCreateParams` (`pub(crate)`) | `tenant: Option<String>`, `key_id: String`, `wrapped: String`, `replaces: Option<String>`, `requested_by: Option<String>` |
| `TenantKeyCreated` | `key_id: String`, `state: String`, `retired: Option<String>` |
| `RotateAllowed` | `allowed: bool`, `requested_by: Option<String>` |
| `TenantKeyRewrapParams` (`pub(crate)`) | `key_id`, `expected_master_key_id`, `wrapped` |
| `TenantKeyDestroyParams` / `TenantKeyDestroyed` | `key_id` / `key_id`, `destroyed: bool` |
| `RewrapListParams` / `RewrapList` (`pub(crate)`) | `master_key_id`, `limit: Option<i64>` / `versions: Vec<RewrapVersion>`, `keys: Vec<RewrapKey>`, `unused: Vec<String>` |
| `AuditDeniedParams` | `secret`, `code`, `session_kind`, `actor`, `application`, `session`, `consumer`, `version: Option<i64>` |
| Lot 1, déjà en SurrealQL | `SettingsGetParams`, `SettingsSetParams`, `SecretCreateParams`, `SecretUpdateParams`, `SecretRefParams`, `SecretListParams`, `VersionAddParams` (`secret`, `number`, `envelope`, `key_id`, `keys`, `stage`), `VersionRefParams`, `VersionLabelParams`, `VersionResealParams`, `ReadBeginParams` (`secret`, `label`, `number`, `consumer`), `ReadTicketRef` (`ticket`), `AuditListParams`, `AuditVerifyParams`, `PurgeDueParams` ; résultats `SecretRecord`, `SecretVersion`, `VersionAdded`, `LabelsResult`, `ReadTicket` (`ticket`, `secret`, `number`, `key_id`, `expires_at`), `ReadEnvelope` (`pub(crate)` : `envelope`, `key_id`, `number`, `context`), `AuditList`, `AuditReport`, `PurgeReport` — mêmes champs que les fonctions du lot 1 (README) |

### Service

| Méthode | Entrée | Sortie |
| :--- | :--- | :--- |
| `SecretsService::put` | `PutValue { secret, value: SecretBytes, expected_version: Option<i64>, stage: Stage }` | `VersionAdded` |
| `SecretsService::reveal` | `RevealRequest { secret, label: Option<String>, number: Option<i64> }` | `RevealedValue { number, value: SecretBytes }` (`Debug` masqué) |
| `SecretsService::rotate_tenant_key` | `tenant: Option<String>` | `TenantKeyCreated` |
| `SecretsClient::read` | `ClientRead { tenant, path, label: Option<String> }` (le module s'annonce comme consommateur) | `RevealedValue` |
| `SecretsClient::write` | `ClientWrite { tenant, path, value: SecretBytes, stage: Stage }` | `VersionAdded` |
| `SecretsMaintenanceWorker` | intervalle, taille de lot | `MaintenanceReport { purged, resealed, rewrapped, destroyed_keys }` |

## 5. Hôte

* `apps/lyxal-server/src/modules/secrets.rs` : trousseau maître du coffre-fort (clé active et, pendant
  une rotation, ancienne clé en lecture seule) lu par `EnvironmentKeyProvider` dans
  `LYXAL__SECRETS__MASTER_KEY` et `LYXAL__SECRETS__PREVIOUS_MASTER_KEY` ; `SecretsModule`, worker,
  sonde ; `SecretsClient` rendu aux modules qui en auront besoin (aucun ne l'utilise dans ce
  programme, décision B1).
* Configuration : `secrets.master_key_id` et `secrets.previous_master_key_id` ; les clés elles-mêmes
  par variables d'environnement seulement (une clé dans un fichier de configuration arrête le
  démarrage). La clé applicative partagée (`crypto.application_key`) est inchangée.
* Pas de route HTTP dans ce lot (lot 5).

## 6. Tests

* **Banc SurrealQL** : clés d'organisation (aucun accès utilisateur, une seule active, rotation,
  destruction), refus journalisés, liste de rescellement.
* **Rust** (base en mémoire puis serveur SurrealDB 3.3.4) :
  * valeur écrite puis relue à l'identique ; valeur de 64 Kio acceptée, au-delà refusée ;
  * enveloppe recopiée vers un autre secret, une autre version ou une autre organisation : refusée ;
  * enveloppe altérée : `SECRETS_VALUE_CORRUPTED` ;
  * écritures concurrentes : aucune perdue, numéros consécutifs ;
  * rotation de la clé d'organisation puis rescellement complet, ancienne clé détruite, valeurs
    toujours lisibles ;
  * rotation de la clé maîtresse du coffre-fort (ancienne clé fournie) puis rescellement des clés
    d'organisation ; la clé applicative de l'hôte et les données de `lyxal_auth` restent lisibles ;
  * organisation supprimée : ses secrets ne s'ouvrent plus ;
  * sans clé maîtresse : `SECRETS_CRYPTO_UNAVAILABLE`, module dégradé, fiches consultables ;
  * aucune valeur ni clé dans les journaux, les erreurs et les `Debug` ;
  * lecture refusée journalisée ; humain sans double facteur refusé ;
  * worker arrêté proprement par l'annulation.
* **Hôte** : démarrage avec et sans clé, sonde de santé, rejeu des ressources.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 7. Documents

`README.md` et `ROADMAP.md` du module, README de l'hôte (variables de clé), `.agents/AGENTS.md` §6
(« scellement Rust : lot 2 » retiré), ligne 2 du plan racine passée à « Réalisé ». Ce plan est
supprimé dans la demande de fusion de l'implémentation.

## 8. Checklist (§13)

* Core : aucune extension.
* Crypto : fonctions STABLE de `lyxal_crypto` seulement ; aucun AAD vide ; tirage par
  `rand_core::OsRng` ; valeurs et clés en `SecretBytes` ; aucune primitive ni dépendance
  ajoutée. La hiérarchie de clés est celle validée (K1).
* Rust : aucun `panic!`, `unwrap` ni erreur silencieuse ; `raw_query` absent ; wrappers d'une ligne.
* Zéro dette : `0.1.0`, aucune migration.
