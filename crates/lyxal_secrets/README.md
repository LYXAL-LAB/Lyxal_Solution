# `lyxal_secrets` — coffre-fort des secrets applicatifs

Module du Noyau Technique de Lyxal OS : conserve les secrets applicatifs (clés de fournisseurs,
identifiants de canaux, jetons, secrets de signature) et contrôle qui les lit. Les sources et
l'étude des produits du marché sont dans [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md), le
programme en cours dans [`implementation_plan.md`](../../implementation_plan.md) à la racine, les
évolutions dans [`ROADMAP.md`](ROADMAP.md).

## État actuel

Le **socle SurrealQL** est en place (lot 1) : fiches, versions, étiquettes, états, droits, ticket
de lecture, journal chaîné, événements. Le scellement des valeurs par `lyxal_crypto` (service
Rust, clés par organisation) arrive au lot 2 : d'ici là, aucune valeur réelle n'est écrite.

SurrealDB 3.3.4 ne chiffre rien et ne déclenche rien sur une lecture : une valeur n'entre dans la
base que scellée (`enc:v2`, AES-256-GCM), la clé reste hors de la base, et la lecture d'une
valeur passe par un ticket tracé au journal avant toute remise.

Manifeste : `lyxal_secrets` 0.1.0, dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`,
`lyxal_auth`. Hébergé par `lyxal-server` (`ManifestModule`, aucun code Rust à ce stade).

## Tables

| Table | Rôle |
| :--- | :--- |
| `secrets_settings` | réglages de l'installation, surchargés par organisation : versions conservées (10), délai avant purge (30 jours, de 7 à 90), protection contre la purge (irréversible), taille maximale d'une valeur (64 Kio, 1 Mio au plus), visibilité par défaut (`restricted`), alerte avant échéance (30 jours) |
| `secrets_secret` | fiche d'un secret, sans valeur : chemin unique par organisation (`notification/smtp/password`), type, description, propriétaire, contact, consommateurs prévus, étiquettes libres, métadonnées, visibilité, échéance, période de rotation, état, étiquettes de version |
| `secrets_version` | version : numéro, enveloppe scellée (illisible pour tout utilisateur), identifiant de clé, noms des clés d'une valeur JSON, état |
| `secrets_read_ticket` | ticket de lecture : usage unique, 60 secondes |
| `secrets_audit`, `secrets_audit_head` | journal chaîné par organisation, en ajout seul ; tête de chaîne |

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
  étiquettes, rescellement, lecture), avec l'auteur, le type de session et l'adresse ; chaque
  entrée porte l'empreinte de la précédente (`fn::security_audit_entry`), le rang est unique par
  organisation, et les champs sont figés. Une entrée modifiée, retirée ou recréée par une session
  système est détectée par `fn::secrets_audit_verify`. Jamais de valeur.
* Les gardes (`DEFINE EVENT`) appliquent les mêmes règles à une écriture directe dans les tables :
  date de purge tirée des réglages, version jamais supprimée tant que son secret existe.

Contexte de scellement d'une version (lot 2) : `SecretContext::with_tenant(<organisation> ou
"lyxal_installation", "lyxal_secrets", "secrets_version", "<clé du secret>:<numéro>", "value")`.

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
| Journal | `secrets_audit_list`, `secrets_audit_verify` |
| Worker | `secrets_purge_due` |

Toutes renvoient `fn::result_ok` ou `fn::error_result` ; entrées validées par
`fn::validation_object_execute` de `lyxal_core` ; écritures vérifiées (`SECRETS_WRITE_FORBIDDEN`).

## Erreurs (`SECRETS_*`)

`parametres` : `SECRETS_INVALID_PARAMETERS`. `permissions` : `SECRETS_PERMISSION_DENIED`,
`SECRETS_WRITE_FORBIDDEN`. `secrets` : `SECRETS_SECRET_NOT_FOUND`, `_EXISTS`, `_STATE_INVALID`,
`_DISABLED`, `_DELETED`, `_EXPIRED`, `SECRETS_PURGE_PROTECTED`. `versions` :
`SECRETS_VERSION_NOT_FOUND`, `_CONFLICT`, `_STATE_INVALID`, `_LABELED`, `SECRETS_LABEL_INVALID`,
`SECRETS_ENVELOPE_INVALID`. `lecture` : `SECRETS_REVEAL_FORBIDDEN`,
`SECRETS_CONSUMER_NOT_ALLOWED`, `SECRETS_READ_TICKET_INVALID`.

## Événements (`lyxal_event`)

`secrets.secret.created`, `.updated`, `.disabled`, `.enabled`, `.deleted`, `.restored`,
`.purged` ; `secrets.version.created`, `.disabled`, `.enabled`, `.destroyed`, `.labeled`.
Charge : organisation, identifiant et chemin du secret, numéro de version ou étiquettes, auteur ;
jamais de valeur.

## Tests

Banc SurrealQL (`tests/*.test.surql`, exécuté par `scripts/ci/test_lyxal_modules.py`) : fiches,
versions, lecture (dont double facteur), journal (dont falsification), droits, réglages et
fonctions internes ; 108 assertions.
