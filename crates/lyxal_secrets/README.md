# `lyxal_secrets` — coffre-fort des secrets applicatifs

Module du Noyau Technique de Lyxal OS : conserve les secrets applicatifs (clés de fournisseurs,
identifiants de canaux, jetons, secrets de signature) et contrôle qui les lit. Les modèles et les
décisions du CTO sont dans [`MODELE_SOURCES.md`](MODELE_SOURCES.md), l'exploitation (sauvegarde,
clé maîtresse, urgence, compromission) dans [`PROCEDURES.md`](PROCEDURES.md), les évolutions dans
[`ROADMAP.md`](ROADMAP.md).

## État actuel

Le **socle SurrealQL** (fiches, versions, étiquettes, états, droits, ticket de lecture, journal
chaîné, événements, clés des organisations), le **service Rust** (scellement et ouverture des
valeurs par `lyxal_crypto`, clés par organisation, lecture tracée avant remise, interface des
autres modules, worker de maintenance, module et sonde de santé) et le **cycle de vie** (alertes
d'échéance, rappel et rotation en quatre étapes sans coupure, rotation d'urgence, essai sans
bascule, rotation planifiée des clés d'organisation) et les **accès avancés** (accès temporaires
par secret ou par dossier, demandes d'accès et de changement approuvées, protections, accès
d'urgence tracé) et le **partage à usage unique** (copie scellée par une clé que seul le lien
porte) sont en place, avec les **routes HTTP** de l'hôte.

SurrealDB 3.3.4 ne chiffre rien et ne déclenche rien sur une lecture : une valeur n'entre dans la
base que scellée (`enc:v2`, AES-256-GCM), la clé reste hors de la base, et la lecture d'une
valeur passe par un ticket tracé au journal avant toute remise.

Manifeste : `lyxal_secrets` 0.1.0, dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`,
`lyxal_auth`. Hébergé par `lyxal-server` (`SecretsModule`, worker de maintenance avec un registre de rotateurs vide, sonde,
routes `/api/v1/secrets/*` au nom de l'appelant : valeurs seulement dans les corps `POST`, réponses
`Cache-Control: no-store`, ouverture d'un partage sans jeton).

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
| `SecretRotator`, `RotatorRegistry` | rotateur d'un module de l'hôte qui sait changer un identifiant chez un service extérieur : `create` (nouvelle valeur), `install`, `test`, `retire` (avant-dernière valeur, au mieux) ; erreurs `RotatorError` (code seul, nouvel essai ou non) ; registre vide par défaut, un rotateur au plus par fiche |
| `RotationRunner` | fait avancer une rotation réservée depuis l'étape atteinte : nouvelle valeur écrite en `pending` par `put`, installation, test, bascule ; valeurs lues par le chemin tracé, le rotateur annoncé comme consommateur ; un échec passe par `fn::secrets_rotation_fail` |
| `SecretsService::share_create`, `share_open` | partage : clé de 32 octets tirée par `OsRng`, copie scellée (contexte lié à l'organisation et à l'empreinte de la clé), empreinte SHA-256, mot de passe haché par Argon2id ; la clé n'est rendue qu'une fois, dans le lien. Ouverture : empreinte comparée en temps constant, mot de passe, organisation si le lien y est réservé, puis ouverture consommée et copie ouverte ; tout refus est `SECRETS_SHARE_UNAVAILABLE` |
| `SecretsService::propose` | nouvelle valeur d'un secret protégé : scellée et écrite en version `proposed` (jamais servie avant l'application), puis demande de changement ouverte au nom de l'appelant |
| `SecretsService::rotate_now`, `check_rotation` | rotation immédiate (dont l'urgence ; sans rotateur, l'urgence coupe la version courante et la rotation échoue aussitôt, `SECRETS_ROTATOR_UNAVAILABLE`) ; essai sans bascule de la valeur en service, outil du worker et de la session système (pas de route HTTP) |
| `SecretsClient` | lecture et écriture des modules de l'hôte par organisation et chemin, session système, module annoncé comme consommateur |
| `SecretsMaintenanceWorker` | `LyxalWorker` : purge à échéance, alertes d'échéance et rappels de rotation, démarrage des rotations dues qu'un rotateur sait faire, rotation des clés d'organisation échues, avancement des rotations réservées, expiration des demandes et retrait des accès finis, expiration des partages, rescellement des versions puis des clés d'organisation, destruction des clés inutilisées ; bilan `MaintenanceReport` |
| `SecretsModule`, `SecretsHealthCheck` | descripteur du module ; sonde : base joignable, clé maîtresse présente, clés scellées par une clé maîtresse absente du trousseau (dégradé), rescellements en attente |
| `SecretsError` | code `SECRETS_*` de la base, ou cause constatée par le service (`SECRETS_CRYPTO_UNAVAILABLE`, `SECRETS_VALUE_TOO_LARGE`, `SECRETS_VALUE_CORRUPTED`, `SECRETS_TENANT_KEY_UNAVAILABLE`) ; jamais de valeur |

Valeurs et clés ne circulent qu'en `SecretBytes` (effacés de la mémoire à la libération) ;
enveloppes et clés scellées dans des types internes au crate, sans `Serialize`, au `Debug`
masqué.

## Tables

| Table | Rôle |
| :--- | :--- |
| `secrets_settings` | réglages de l'installation, surchargés par organisation : versions conservées (10), délai avant purge (30 jours, de 7 à 90), protection contre la purge (irréversible), taille maximale d'une valeur (64 Kio, 1 Mio au plus), visibilité par défaut (`restricted`), alerte avant échéance (30 jours), rotation de la clé d'organisation (365 jours, de 30 à 3650, 0 : désactivée), durée d'un accès temporaire (8 h par défaut, 90 jours au plus), expiration d'une demande sans réponse (7 jours), approbations d'une demande d'accès (1), durée d'un partage (24 h par défaut, 7 jours au plus) et ouvertures (10 au plus) |
| `secrets_secret` | fiche d'un secret, sans valeur : chemin unique par organisation (`notification/smtp/password`), type, description, propriétaire, contact, consommateurs prévus, étiquettes libres, métadonnées, visibilité, échéance, période et prochaine date de rotation, dernière rotation, alertes déjà envoyées, dernier essai sans bascule, état, étiquettes de version |
| `secrets_version` | version : numéro, enveloppe scellée (illisible pour tout utilisateur), identifiant de clé, noms des clés d'une valeur JSON, état |
| `secrets_read_ticket` | ticket de lecture : usage unique, 60 secondes |
| `secrets_audit`, `secrets_audit_head` | journal chaîné par organisation, en ajout seul ; tête de chaîne |
| `secrets_rotation` | rotation d'un secret : état (`started`, `created`, `installed`, `tested`, puis `succeeded`, `failed` ou `cancelled`), urgence, motif, nouvelle et ancienne version, échecs et prochain essai, réservation par un worker, auteur ; une seule en cours par secret |
| `secrets_grant` | accès temporaire en plus des droits `lyxal_auth` : organisation, bénéficiaire (identité ou application), chemin d'un secret ou d'un dossier, opérations (`list`, `read_value`, `write`, `delete`), début et fin, motif, auteur, demande d'origine, urgence, retrait |
| `secrets_request` | demande d'accès (`access`) ou de changement d'un secret protégé (`change` : `value`, `rollback`, `disable`, `delete`, `destroy`) : demandeur, objet, motif, approbations requises et reçues, état (`pending`, `approved`, `rejected`, `cancelled`, `expired`, `applying`, `applied`), échéance ; une demande de changement ouverte par secret |
| `secrets_policy` | protection d'un secret ou d'un dossier : approbations requises (1 à 5), opérations protégées, durée maximale d'un accès demandé |
| `secrets_share` | partage à usage unique : copie scellée (illisible), empreinte de la clé du lien (illisible), hachage du mot de passe facultatif (illisible), source (secret et version, ou texte), ouvertures permises et faites, essais faux, réservé à l'organisation ou non, échéance, état (`active`, `consumed`, `expired`, `revoked`, `destroyed`) |
| `secrets_tenant_key` | clé d'une organisation ou de l'installation, scellée par la clé maîtresse : identifiant, clé maîtresse qui la scelle, état (`active`, une seule par portée ; `decrypt_only` ; `destroyed`, matière effacée) ; identifiant et état lisibles par l'écriture, la liste et les accès temporaires d'écriture de l'organisation, clé scellée illisible, aucune écriture utilisateur |

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
* **Échéances** : le worker signale une seule fois l'échéance proche (délai d'alerte des
  réglages), l'échéance atteinte et la rotation due (`fn::secrets_due_mark`) ; une nouvelle
  échéance ou une nouvelle date de rotation remet ces alertes à zéro. Une clé d'organisation plus
  ancienne que la période de rotation de sa portée est changée par le worker.
* **Rotation** (modèle AWS) : `started` → `created` (la nouvelle valeur est écrite en version
  `pending` ; le worker n'écrit une version qu'à cette étape) → `installed` (activée chez le
  service extérieur) → `tested` → `succeeded` : `current` passe sur la nouvelle version,
  l'ancienne devient `previous`, la prochaine date est recalculée. Jusqu'à la bascule, la valeur en
  service ne change pas. Un échec est réessayé 3 fois (1 min, 10 min, 1 h) à l'étape atteinte,
  puis la rotation échoue et l'étiquette `pending` est retirée. Une seule rotation en cours par
  secret ; le worker la réserve juste avant d'y travailler (jeton renouvelé à chaque étape ; seul son détenteur la fait avancer), elle reprend après un arrêt ou une réservation expirée.
  Annulation par l'écriture. Rotation d'urgence : décision d'une personne (droit d'écriture,
  assurance la plus haute et récente) ou d'un programme qui a le droit d'écriture ; la version
  courante est désactivée tout de suite, avant toute autre étape.
* **Essai sans bascule** : le résultat d'un test de la valeur en service (`ok`, code d'erreur) est
  posé sur la fiche, journalisé et publié.
* **Accès temporaires** : un droit en plus de ceux de `lyxal_auth`, jamais à leur place, pour un
  secret ou un dossier (chemin et `folder` : couvre `<dossier>/…`, jamais `<dossier>-autre/…`),
  des opérations et une durée toujours limitée ; il ne vaut que dans une session de son
  organisation. `fn::secrets_can` et les droits des tables le prennent en compte ; la liste des
  secrets ne montre que ceux qu'il couvre. Réglages, journal, purge, restauration et gestion des
  accès restent réservés aux droits `lyxal_auth`. Accordé et retiré par
  `secrets.access.manage`, jamais à soi-même : on passe par une demande approuvée par un autre, ou
  par l'accès d'urgence.
* **Demandes** : une demande d'accès est accordée (accès créé) dès que le nombre d'approbations
  requis est atteint ; un refus la clôt ; sans réponse, elle expire. On n'approuve jamais sa propre
  demande.
* **Protections** : sur un chemin protégé, remplacer la valeur en service, revenir en arrière,
  désactiver, supprimer ou détruire une version (hors conservation) passe par une demande de
  changement : la nouvelle valeur est écrite en version `proposed` (jamais en service avant),
  approuvée par N gestionnaires des accès, puis appliquée par son auteur avec ses droits.
  L'écriture directe est refusée (`SECRETS_APPROVAL_REQUIRED`), y compris dans les tables. La
  session système, le worker (rotation automatique) et la rotation d'urgence ne sont pas soumis ;
  la première valeur d'un secret non plus.
* **Urgence** : `secrets.access.emergency` (aucun rôle d'office) permet de s'accorder un accès
  d'une heure au plus, ou d'appliquer un changement protégé avant les approbations, avec un
  motif et l'assurance la plus haute et récente ; journalisé et publié.
* **Partages** : une copie (valeur d'un secret qu'on peut révéler, ou texte saisi) scellée par
  une clé aléatoire que seul le lien porte ; la base ne garde que l'enveloppe, l'empreinte de la
  clé et le hachage du mot de passe, effacés dès que le partage n'est plus actif. Ouvertures
  limitées (1 par défaut, 10 au plus), échéance (24 h, 7 jours au plus), mot de passe facultatif,
  ouverture réservée à l'organisation en option ; 5 essais faux détruisent le partage ; une
  erreur d'ouverture ne dit jamais ce qui est faux (`SECRETS_SHARE_UNAVAILABLE`). Seule la
  session système charge, compte et consomme.
* **Journal** : une entrée par opération (réglages, création, modification, états, versions,
  étiquettes, rescellement, lecture, lecture refusée, création, retrait, rescellement et
  destruction des clés d'organisation, alertes d'échéance, rotations et leurs étapes, essais sans
  bascule, accès accordés, retirés et d'urgence, demandes et décisions, protections, partages et leurs
  ouvertures), avec l'auteur, le type de session et l'adresse ; chaque
  entrée porte l'empreinte de la précédente (`fn::security_audit_entry`), le rang est unique par
  organisation, et les champs sont figés. Une entrée modifiée, retirée ou recréée par une session
  système est détectée par `fn::secrets_audit_verify`. Jamais de valeur.
* Les gardes (`DEFINE EVENT`) appliquent les mêmes règles à une écriture directe dans les tables
  (fiches, versions, tickets, rotations, accès, demandes, protections, partages) : date de purge
  tirée des réglages et toujours présente sur un secret supprimé, version jamais supprimée tant
  que son secret existe, auteur et champs de décision égaux à l'appelant, urgence avec
  l'assurance requise, étiquette `pending` réservée au worker, nouvelle version jamais mêlée à un
  changement de fiche, aucun accès accordé à soi-même hors demande approuvée ou urgence.

## Droits (`lyxal_auth`)

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `secrets.secret.list` | organisation | lire les fiches et les versions, sans valeur |
| `secrets.value.read` | organisation | lire une valeur |
| `secrets.secret.write` | organisation | créer, modifier une fiche, ajouter une version, déplacer une étiquette, désactiver, réactiver, démarrer (dont l'urgence) et annuler une rotation |
| `secrets.secret.delete` | organisation | supprimer (douce), détruire une version |
| `secrets.secret.restore` | organisation | restaurer |
| `secrets.secret.purge` | organisation | purger avant la date de purge |
| `secrets.audit.read` | organisation | lire et vérifier le journal |
| `secrets.settings.manage` | organisation | réglages de l'organisation |
| `secrets.installation.manage` | installation | secrets, journal et réglages de l'installation |
| `secrets.access.manage` | organisation | accorder et retirer des accès temporaires, approuver ou refuser les demandes, protéger des secrets |
| `secrets.access.emergency` | organisation | s'accorder un accès d'urgence (1 h au plus) ou appliquer un changement protégé avant les approbations |
| `secrets.share.create` | organisation | créer, lister et retirer des partages à usage unique |
| `secrets.worker` | installation | compte de service : purge à échéance, rescellement, échéances, rotations planifiées et leurs étapes, rotation des clés d'organisation |

`organization_admin` reçoit les permissions d'organisation (dont `secrets.share.create`) sauf `secrets.value.read`,
`secrets.secret.purge` et `secrets.access.emergency`, attribuées explicitement ; `platform_admin` reçoit
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
| Rotation | `secrets_rotation_begin`, `_cancel`, `_get` ; `_claim`, `_step`, `_finish`, `_fail`, `_check_record` (worker ou session système) |
| Accès | `secrets_grant_create`, `_revoke`, `_list`, `secrets_access_emergency` |
| Demandes | `secrets_request_access`, `_change`, `_approve`, `_reject`, `_cancel`, `_apply`, `_get`, `_list` |
| Protections | `secrets_policy_set`, `_delete`, `_list` |
| Partages | `secrets_share_create`, `_list`, `_revoke` ; `_load`, `_fail`, `_consume` (session système) |
| Worker | `secrets_purge_due`, `secrets_due_list`, `secrets_due_mark`, `secrets_access_due`, `secrets_share_due` |

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
`SECRETS_TENANT_KEY_UNAVAILABLE`, `SECRETS_TENANT_KEY_CONFLICT`. `rotation` :
`SECRETS_ROTATION_IN_PROGRESS`, `_NOT_FOUND`, `_STATE_INVALID`, `_TEST_FAILED`,
`SECRETS_ROTATOR_UNAVAILABLE`. `acces` : `SECRETS_GRANT_NOT_FOUND`, `_INVALID`,
`SECRETS_REQUEST_NOT_FOUND`, `_STATE_INVALID`, `_SELF_APPROVAL`, `_ALREADY_DECIDED`,
`SECRETS_CHANGE_IN_PROGRESS`, `SECRETS_APPROVAL_REQUIRED`, `SECRETS_POLICY_NOT_FOUND`.
`partage` : `SECRETS_SHARE_NOT_FOUND`, `_UNAVAILABLE`, `_INVALID`.

## Événements (`lyxal_event`)

`secrets.secret.created`, `.updated`, `.disabled`, `.enabled`, `.deleted`, `.restored`,
`.purged`, `.expiring`, `.expired`, `.rotation_due` ; `secrets.version.created`, `.disabled`,
`.enabled`, `.destroyed`, `.labeled` ; `secrets.rotation.started`, `.succeeded`, `.failed`,
`.cancelled`, `.checked` ; `secrets.access.granted`, `.revoked`, `.emergency` ;
`secrets.request.created`, `.approved`, `.rejected`, `.cancelled`, `.expired`, `.applied` ;
`secrets.policy.updated` ; `secrets.share.created`, `.opened`, `.consumed`, `.expired`,
`.revoked`, `.destroyed`. Charge : organisation, identifiant et chemin du secret, numéro de
version ou étiquettes, échéance, rotation et code d'erreur, auteur ; jamais de valeur.

## Tests

Banc SurrealQL (`tests/*.test.surql`, exécuté par `scripts/ci/test_lyxal_modules.py`) : fiches,
versions, lecture (dont double facteur), journal (dont falsification), droits, réglages,
fonctions internes, clés des organisations et refus journalisés, échéances et rotations, accès, demandes, protections et urgence, partages, sondes de l'audit de clôture ; 245 assertions.

Tests Rust (`tests/it/`, base embarquée, sessions de personnes et de programmes par jetons de
test) : valeur écrite puis relue, 64 Kio acceptés et au-delà refusés, enveloppe recopiée ou
altérée, écritures concurrentes, rotation des clés d'organisation et de la clé maîtresse,
organisation supprimée, fonctionnement sans clé maîtresse, lectures refusées journalisées,
double facteur, consommateurs, sonde, worker arrêté par l'annulation, aucune valeur dans les
`Debug` et les erreurs, rotation complète sans coupure, nouvel essai et échec définitif, reprise
après interruption, urgence avec et sans rotateur, rappel seul sans rotateur, essai sans bascule,
rotation planifiée des clés d'organisation, réservation périmée reprise par un autre worker, arrêt du
worker pendant une rotation, accès temporaires d'une personne et d'un programme, valeur proposée
servie seulement après approbations et application, changement d'urgence, worker des demandes, partages (ouverture épuisée, clé et mot de passe faux,
destruction au cinquième essai, lien réservé à l'organisation, retrait, échéance) ; 42 tests. Hôte :
`apps/lyxal-server/tests/secrets_http.rs` (routes HTTP de bout en bout) et `apps/lyxal-server/tests/secrets.rs`.
