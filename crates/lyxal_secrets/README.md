# `lyxal_secrets` — coffre-fort des secrets applicatifs

Module du Noyau Technique de Lyxal OS : conserve les secrets applicatifs (clés de fournisseurs,
identifiants de canaux, jetons, secrets de signature) et contrôle qui les lit. Les sources et
l'étude des produits du marché sont dans [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md), le
programme en cours dans [`implementation_plan.md`](../../implementation_plan.md) à la racine, les
évolutions dans [`ROADMAP.md`](ROADMAP.md).

## État actuel

Le **socle SurrealQL** (fiches, versions, étiquettes, états, droits, ticket de lecture, journal
chaîné, événements, clés des organisations) et le **service Rust** (scellement et ouverture des
valeurs par `lyxal_crypto`, clés par organisation, lecture tracée avant remise, interface des
autres modules, worker de maintenance, module et sonde de santé) sont en place.

SurrealDB 3.3.4 ne chiffre rien et ne déclenche rien sur une lecture : une valeur n'entre dans la
base que scellée (`enc:v2`, AES-256-GCM), la clé reste hors de la base, et la lecture d'une
valeur passe par un ticket tracé au journal avant toute remise.

Manifeste : `lyxal_secrets` 0.1.0, dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`,
`lyxal_auth`. Hébergé par `lyxal-server` (`SecretsModule`, worker de maintenance, sonde).

## Clés

```text
clé maîtresse du coffre-fort (LYXAL__SECRETS__MASTER_KEY ; ancienne clé en lecture seule pendant une rotation)
   └── clé de chaque organisation : 32 octets tirés par rand_core::OsRng (SecretBytes),
       scellés par la clé maîtresse et rangés dans secrets_tenant_key
          └── chaque version : scellée par la clé de son organisation
```

* La clé maîtresse est propre au coffre-fort, distincte de la clé applicative partagée de
  l'hôte (`MasterKeys` : clé active et, pendant une rotation, l'ancienne en `DecryptOnly`).
* La clé d'une organisation (ou de l'installation) est créée à la première valeur écrite ; son
  identifiant (`<organisation>-<16 chiffres hexadécimaux>`) figure dans chaque enveloppe.
  Contexte de scellement : `SecretContext::with_tenant(<organisation> ou "lyxal_installation",
  "lyxal_secrets", "secrets_tenant_key", <identifiant de clé>, "key")`.
* Contexte de scellement d'une version : `SecretContext::with_tenant(<organisation> ou
  "lyxal_installation", "lyxal_secrets", "secrets_version", "<clé du secret>:<numéro>",
  "value")`. Une enveloppe recopiée vers un autre secret, une autre version ou une autre
  organisation ne s'ouvre pas (`SECRETS_VALUE_CORRUPTED`).
* Le trousseau d'une organisation est reconstruit à chaque opération (`EncryptionKey::import`,
  `KeyRingBuilder`, `StaticKeyResolver`, `CryptoEngine`) depuis ses clés `active` et
  `decrypt_only` ; aucune clé d'organisation n'est gardée en mémoire au-delà de l'opération.
* **Rotation de la clé d'une organisation** (sur demande, droit `secrets.settings.manage`) :
  nouvelle clé active, l'ancienne ne sert plus qu'à relire ; le worker rescelle toutes les
  versions (`reencrypt_if_needed`, puis `fn::secrets_version_reseal`), puis détruit l'ancienne.
* **Rotation de la clé maîtresse** : la nouvelle est fournie comme clé active, l'ancienne à côté
  en lecture seule ; le worker rescelle les clés des organisations
  (`fn::secrets_tenant_key_rewrap`) ; la sonde annonce la fin, puis l'ancienne est retirée.
* Une organisation supprimée emporte ses clés et ses secrets (`REFERENCE ON DELETE CASCADE`).
* Sans clé maîtresse, le module est dégradé : les fiches restent consultables, aucune valeur
  n'est écrite ni lue (`SECRETS_CRYPTO_UNAVAILABLE`).

## Service Rust

| Élément | Rôle |
| :--- | :--- |
| `SecretsStore` | un appel typé d'une ligne par fonction `fn::secrets_*` (`call_fn`) ; ceux qui transportent une enveloppe ou une clé scellée sont internes au crate |
| `SecretsService::put` | fiche lue avec les droits de l'appelant, taille contrôlée (`max_value_bytes`), noms des clés d'une valeur JSON objet (jamais les valeurs), valeur scellée pour le numéro suivant, `fn::secrets_version_add` ; une écriture concurrente (`SECRETS_VERSION_CONFLICT` ou conflit de transaction) est relue et rescellée, trois essais au plus ; avec `expected_version` (dernier numéro connu), aucun nouvel essai |
| `SecretsService::reveal` | `fn::secrets_read_begin` (session de l'appelant, ticket tracé) → `fn::secrets_read_envelope` (session système) → ouverture → `SecretBytes` ; un refus de la base ou une enveloppe illisible est journalisé au nom de l'appelant (`fn::secrets_audit_denied`) |
| `SecretsService::rotate_tenant_key` | droit contrôlé par `fn::secrets_tenant_key_rotate_allowed` (session de l'appelant), nouvelle clé rangée par la session système |
| `SecretsClient` | lecture et écriture des modules de l'hôte par organisation et chemin, session système, module annoncé comme consommateur |
| `SecretsMaintenanceWorker` | `LyxalWorker` : purge à échéance, rescellement des versions puis des clés d'organisation, destruction des clés inutilisées ; bilan `MaintenanceReport` |
| `SecretsModule`, `SecretsHealthCheck` | descripteur du module ; sonde : base joignable, clé maîtresse présente, clés scellées par une clé maîtresse absente du trousseau (dégradé), rescellements en attente |
| `SecretsError` | code `SECRETS_*` de la base, ou cause constatée par le service (`SECRETS_CRYPTO_UNAVAILABLE`, `SECRETS_VALUE_TOO_LARGE`, `SECRETS_VALUE_CORRUPTED`, `SECRETS_TENANT_KEY_UNAVAILABLE`) ; jamais de valeur |

Valeurs et clés ne circulent qu'en `SecretBytes` (effacés de la mémoire à la libération) ;
enveloppes et clés scellées dans des types internes au crate, sans `Serialize`, au `Debug`
masqué.

## Tables

| Table | Rôle |
| :--- | :--- |
| `secrets_settings` | réglages de l'installation, surchargés par organisation : versions conservées (10), délai avant purge (30 jours, de 7 à 90), protection contre la purge (irréversible), taille maximale d'une valeur (64 Kio, 1 Mio au plus), visibilité par défaut (`restricted`), alerte avant échéance (30 jours) |
| `secrets_secret` | fiche d'un secret, sans valeur : chemin unique par organisation (`notification/smtp/password`), type, description, propriétaire, contact, consommateurs prévus, étiquettes libres, métadonnées, visibilité, échéance, période de rotation, état, étiquettes de version |
| `secrets_version` | version : numéro, enveloppe scellée (illisible pour tout utilisateur), identifiant de clé, noms des clés d'une valeur JSON, état |
| `secrets_read_ticket` | ticket de lecture : usage unique, 60 secondes |
| `secrets_audit`, `secrets_audit_head` | journal chaîné par organisation, en ajout seul ; tête de chaîne |
| `secrets_tenant_key` | clé d'une organisation ou de l'installation, scellée par la clé maîtresse : identifiant, clé maîtresse qui la scelle, état (`active`, une seule par portée ; `decrypt_only` ; `destroyed`, matière effacée) ; aucun accès utilisateur |

Aucune table n'a de `CHANGEFEED` ni d'historique natif : une version détruite disparaît vraiment.

## Règles

* **États d'un secret** : `active` ↔ `disabled` ; → `deleted` (suppression douce, date de purge
  posée) ; `deleted` → état d'avant (restauration) ou purge. Purge anticipée : permission
  `secrets.secret.purge`, refusée si l'organisation ou l'installation a activé la protection
  contre la purge (même pour la session système).
* **Versions** : numéro suivant obligatoire (`SECRETS_VERSION_CONFLICT` sinon : aucune écriture
  n'en écrase une autre) ; `enabled` ↔ `disabled` ; `destroyed` (enveloppe effacée,
  irréversible), refusé sur une version étiquetée. Au-delà du nombre de versions conservées,
  les plus anciennes sans étiquette sont détruites.
* **Étiquettes** : `current` (lue par défaut, jamais retirée), `previous` (posée quand `current`
  change), `pending` (rotation), étiquettes libres ; 20 au plus. Retour arrière : déplacer
  `current`.
* **Enveloppe** : jamais lisible par un utilisateur (`SELECT`, `WHERE`, `LIVE`, fonctions) ;
  remplacée seulement par le rescellement après une rotation de clé (session système ou worker),
  ou effacée à la destruction.
* **Lecture d'une valeur** : `fn::secrets_read_begin` contrôle les droits et l'état, puis crée un
  ticket ; sa création écrit l'entrée `secret.read` du journal dans la même transaction. Seule la
  session système échange le ticket contre l'enveloppe et son contexte de scellement
  (`fn::secrets_read_envelope`). Un humain ne lit qu'un secret `revealable`, avec le niveau
  d'assurance le plus haut et une authentification récente (`fn::auth_assurance_check`) ; un
  programme lit avec `secrets.value.read`, et seulement s'il figure parmi les consommateurs prévus
  quand la fiche en liste : identifiant de son application (`auth_application:…`, d'après
  `fn::auth_context`), ou nom du module annoncé par la session système.
* **Journal** : une entrée par opération (réglages, création, modification, états, versions,
  étiquettes, rescellement, lecture, lecture refusée, création, retrait, rescellement et
  destruction des clés d'organisation), avec l'auteur, le type de session et l'adresse ; chaque
  entrée porte l'empreinte de la précédente (`fn::security_audit_entry`), le rang est unique par
  organisation, et les champs sont figés. Une entrée modifiée, retirée ou recréée par une session
  système est détectée par `fn::secrets_audit_verify`. Jamais de valeur.
* Les gardes (`DEFINE EVENT`) appliquent les mêmes règles à une écriture directe dans les tables :
  date de purge tirée des réglages, version jamais supprimée tant que son secret existe.

## Droits (`lyxal_auth`)

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `secrets.secret.list` | organisation | lire les fiches et les versions, sans valeur |
| `secrets.value.read` | organisation | lire une valeur |
| `secrets.secret.write` | organisation | créer, modifier une fiche, ajouter une version, déplacer une étiquette, désactiver, réactiver |
| `secrets.secret.delete` | organisation | supprimer (douce), détruire une version |
| `secrets.secret.restore` | organisation | restaurer |
| `secrets.secret.purge` | organisation | purger avant la date de purge |
| `secrets.audit.read` | organisation | lire et vérifier le journal |
| `secrets.settings.manage` | organisation | réglages de l'organisation |
| `secrets.installation.manage` | installation | secrets, journal et réglages de l'installation |
| `secrets.worker` | installation | compte de service : purge à échéance, rescellement |

`organization_admin` reçoit les permissions d'organisation sauf `secrets.value.read` et
`secrets.secret.purge`, attribuées explicitement ; `platform_admin` reçoit
`secrets.installation.manage` ; `secrets.worker` n'est attribuée à aucun rôle.

## Fonctions publiques (`fn::secrets_*($params: object)`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages | `secrets_settings_get`, `secrets_settings_set` |
| Fiches | `secrets_secret_create`, `_update`, `_get`, `_list`, `_disable`, `_enable`, `_delete`, `_restore`, `_purge` |
| Versions | `secrets_version_add`, `_list`, `_label`, `_disable`, `_enable`, `_destroy`, `_reseal` |
| Lecture | `secrets_read_begin`, `secrets_read_envelope` (session système) |
| Journal | `secrets_audit_list`, `secrets_audit_verify`, `secrets_audit_denied` (session système) |
| Clés | `secrets_tenant_key_ring`, `_create`, `_rewrap`, `_destroy`, `secrets_rewrap_list` (session système ou worker) ; `secrets_tenant_key_rotate_allowed` (droit de réglage) |
| Worker | `secrets_purge_due` |

Toutes renvoient `fn::result_ok` ou `fn::error_result` ; entrées validées par
`fn::validation_object_execute` de `lyxal_core` ; écritures vérifiées (`SECRETS_WRITE_FORBIDDEN`).

## Erreurs (`SECRETS_*`)

`parametres` : `SECRETS_INVALID_PARAMETERS`. `permissions` : `SECRETS_PERMISSION_DENIED`,
`SECRETS_WRITE_FORBIDDEN`. `secrets` : `SECRETS_SECRET_NOT_FOUND`, `_EXISTS`, `_STATE_INVALID`,
`_DISABLED`, `_DELETED`, `_EXPIRED`, `SECRETS_PURGE_PROTECTED`. `versions` :
`SECRETS_VERSION_NOT_FOUND`, `_CONFLICT`, `_STATE_INVALID`, `_LABELED`, `SECRETS_LABEL_INVALID`,
`SECRETS_ENVELOPE_INVALID`. `lecture` : `SECRETS_REVEAL_FORBIDDEN`,
`SECRETS_CONSUMER_NOT_ALLOWED`, `SECRETS_READ_TICKET_INVALID`. `cles` :
`SECRETS_CRYPTO_UNAVAILABLE`, `SECRETS_VALUE_TOO_LARGE`, `SECRETS_VALUE_CORRUPTED`,
`SECRETS_TENANT_KEY_UNAVAILABLE`, `SECRETS_TENANT_KEY_CONFLICT`.

## Événements (`lyxal_event`)

`secrets.secret.created`, `.updated`, `.disabled`, `.enabled`, `.deleted`, `.restored`,
`.purged` ; `secrets.version.created`, `.disabled`, `.enabled`, `.destroyed`, `.labeled`.
Charge : organisation, identifiant et chemin du secret, numéro de version ou étiquettes, auteur ;
jamais de valeur.

## Tests

Banc SurrealQL (`tests/*.test.surql`, exécuté par `scripts/ci/test_lyxal_modules.py`) : fiches,
versions, lecture (dont double facteur), journal (dont falsification), droits, réglages,
fonctions internes, clés des organisations et refus journalisés ; 125 assertions.

Tests Rust (`tests/it/`, base embarquée, sessions de personnes et de programmes par jetons de
test) : valeur écrite puis relue, 64 Kio acceptés et au-delà refusés, enveloppe recopiée ou
altérée, écritures concurrentes, rotation des clés d'organisation et de la clé maîtresse,
organisation supprimée, fonctionnement sans clé maîtresse, lectures refusées journalisées,
double facteur, consommateurs, sonde, worker arrêté par l'annulation, aucune valeur dans les
`Debug` et les erreurs ; 17 tests. Hôte : `apps/lyxal-server/tests/secrets.rs`.
