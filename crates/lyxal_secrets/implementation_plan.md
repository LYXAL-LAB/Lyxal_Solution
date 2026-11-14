# Plan d'implémentation — `lyxal_secrets`, lot 5 : routes de l'hôte, révélation, partage à usage unique

Cinquième lot du programme `lyxal_secrets` (`implementation_plan.md` à la racine, décision A2).
Il rend le coffre-fort utilisable depuis l'extérieur du serveur :

* les **routes HTTP** de `lyxal-server` pour tout ce que le coffre-fort sait faire ;
* la **révélation** d'une valeur à une personne (double facteur) ;
* le **partage à usage unique** : un lien qui donne une valeur une fois, puis ne sert plus
  (modèle Bitwarden Send, Infisical Secret Sharing, Doppler Share).

Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **E1** | Étendue des routes | **Toutes les opérations du coffre-fort** sous `/api/v1/secrets` (fiches, valeurs, versions, journal, rotation, accès, demandes, protections, partages), au nom de l'appelant (jeton `Bearer`), comme les routes des fichiers. Les droits restent décidés par la base, l'hôte n'en recopie aucun. **Une valeur ne passe jamais dans une adresse** : seulement dans le corps d'une requête ou d'une réponse `POST`, avec « ne pas garder en cache » |
| **E2** | Révélation à une personne | `POST /secrets/{id}/reveal` : mêmes règles qu'aujourd'hui (secret « révélable », droit de lecture, double facteur récent), journalisée avant toute remise. Un programme lit par la même route avec son jeton |
| **E3** | Que peut-on partager ? | **Une copie** : soit la valeur d'un secret qu'on a le droit de révéler (double facteur), soit un texte saisi (un mot de passe à transmettre à un prestataire, par exemple). Un changement ultérieur du secret ne change pas le partage |
| **E4** | Protection d'un partage | Le lien porte une **clé aléatoire que le serveur ne garde pas** (il ne garde que son empreinte) : la base seule ne permet pas de lire un partage. Par défaut **1 ouverture** (jusqu'à 10) et **24 heures** (7 jours au plus). **Mot de passe facultatif** en plus. Retrait possible à tout moment. **5 essais faux** et le partage est détruit |
| **E5** | Qui peut ouvrir un lien ? | Par défaut **toute personne qui a le lien** (destinataire extérieur). En option, **seulement un membre connecté de l'organisation** |
| **E6** | Qui peut créer un partage ? | Nouvelle permission **`secrets.share.create`**, donnée au rôle `organization_admin`. Chaque ouverture est journalisée et publiée (`secrets.share.opened`), pour que l'auteur soit prévenu |
| **E7** | Cryptographie | **Aucune primitive nouvelle**. Tout passe par `lyxal_crypto` : clé tirée par `OsRng`, scellement `CryptoEngine::seal` avec un contexte propre au partage, empreinte SHA-256 de la clé, mot de passe haché par Argon2id |

## 2. Fonctionnement

### 2.1. Routes de l'hôte (`apps/lyxal-server/src/http/secrets.rs`)

* **Session** : chaque requête ouvre une session SurrealDB au nom de l'appelant (jeton
  contrôlé : signature, révocation, version des droits).
  * `SecretsService::new(appelant, système, trousseau)` : la session système ne sert qu'à
    échanger un ticket de lecture contre l'enveloppe, comme aujourd'hui.
  * Réponses au contrat `LyxalResult` (`{ ok, data, error }`).
* **Valeurs** :
  * **Envoi** en JSON : `{ "value": "texte" }` ou `{ "value_base64": "…" }`, taille bornée par
    les réglages.
  * **Réponse** : `{ "value": … }` en texte quand il est lisible, sinon `value_base64`.
  * **En-têtes** de toute réponse qui porte une valeur : `Cache-Control: no-store`,
    `Pragma: no-cache`.
  * **Journaux** : aucune valeur dans les journaux techniques du serveur (trace des requêtes
    sans corps).
* **Erreurs** : codes `SECRETS_*` de la base, avec leur statut HTTP (master data). Erreurs de
  l'hôte en `SERVER_*`.

| Domaine | Routes (`/api/v1/secrets`) |
| :--- | :--- |
| Réglages | `GET /settings`, `PUT /settings` |
| Fiches | `GET /secrets`, `POST /secrets`, `GET /secrets/{id}`, `PATCH /secrets/{id}`, `POST /secrets/{id}/disable` · `/enable` · `/delete` · `/restore` · `/purge` |
| Valeurs | `POST /secrets/{id}/versions` (écrire), `POST /secrets/{id}/reveal` (lire), `POST /secrets/{id}/propose` (secret protégé) |
| Versions | `GET /secrets/{id}/versions`, `POST /secrets/{id}/labels`, `POST /secrets/{id}/versions/{n}/disable` · `/enable` · `/destroy` |
| Journal | `GET /audit`, `POST /audit/verify` |
| Rotation | `POST /secrets/{id}/rotations` (dont urgence), `GET /secrets/{id}/rotations`, `POST /rotations/{id}/cancel`, `POST /secrets/{id}/check` |
| Clés | `POST /tenant-key/rotate` |
| Accès | `GET /grants`, `POST /grants`, `POST /grants/{id}/revoke`, `POST /access/emergency` |
| Demandes | `GET /requests`, `GET /requests/{id}`, `POST /requests/access`, `POST /requests/change`, `POST /requests/{id}/approve` · `/reject` · `/cancel` · `/apply` |
| Protections | `GET /policies`, `PUT /policies`, `DELETE /policies/{id}` |
| Partages | `GET /shares`, `POST /shares`, `POST /shares/{id}/revoke` ; **ouverture** `POST /shares/{id}/open` (sans jeton, sauf partage réservé à l'organisation) |

### 2.2. Partage à usage unique (`secrets_share`)

1. **Création** (`SecretsService::share_create`).
   * L'auteur donne : un secret (version `current` ou numéro) ou un texte, le nombre
     d'ouvertures, la durée, un mot de passe facultatif, et s'il réserve le lien à
     l'organisation.
   * Pour un secret, la valeur est d'abord **révélée** à l'auteur par le chemin habituel (droits,
     double facteur, journal).
2. **Clé du partage** : le service tire une clé de 32 octets (`OsRng`). Il scelle la copie avec
   cette clé (contexte `with_tenant(<org>, "lyxal_secrets", "secrets_share", <id>, "value")`)
   et ne range que :
   * l'enveloppe ;
   * l'**empreinte** de la clé (SHA-256) ;
   * le hachage du mot de passe (Argon2id), s'il y en a un.
3. **Lien** : la clé n'est rendue qu'une fois, à la création, dans le lien
   (`<id>` + clé en base64url). Elle n'est jamais écrite en base ni dans un journal.
4. **Ouverture** (`POST /shares/{id}/open`, `{ key, passphrase }`).
   * Le service lit le partage par la session système.
   * Il vérifie dans cet ordre : partage actif, non échu, empreinte de la clé, mot de passe,
     appartenance à l'organisation si le lien y est réservé.
   * Ensuite seulement, il consomme une ouverture, atomiquement (`views < max_views`), puis ouvre
     l'enveloppe et rend la valeur.
   * Chaque ouverture est journalisée et publiée.
5. **Échecs** :
   * une clé ou un mot de passe faux compte un essai ; **5 essais faux et le partage est détruit** ;
   * une erreur ne dit jamais si c'est la clé ou le mot de passe qui est faux
     (`SECRETS_SHARE_UNAVAILABLE`).
6. **Fin** :
   * **Épuisé, échu ou retiré** : l'enveloppe est effacée tout de suite (état `consumed`,
     `expired`, `revoked`).
   * **Nettoyage par le worker** : il expire les partages échus et retire les fiches finies
     depuis 30 jours.

## 3. SurrealQL

### Schéma

| Élément | Contenu |
| :--- | :--- |
| `schema/11_secrets_share.surql` | `tenant`, `created_by` (identité ou application), `secret` et `number` (source, ou `NONE` pour un texte), `envelope` (`select NONE`, effacée à la fin), `key_fingerprint` (`select NONE`), `passphrase_hash` (`select NONE`), `max_views` (1 à 10), `views`, `members_only`, `expires_at`, `state` (`active`, `consumed`, `expired`, `revoked`), `failed_attempts`, `created_at`, `last_opened_at`. Droits : l'auteur et `secrets.share.create` voient la fiche, jamais les champs scellés |
| `secrets_settings` | `share_default_ttl` (24 h), `share_max_ttl` (7 jours), `share_max_views` (10) |

### Fonctions (`DEFINE FUNCTION OVERWRITE fn::<nom>($params: object)`, résultat `fn::result_ok` ou `fn::error_result`)

| Fonction | `$params` (**obligatoires**) | Appelant |
| :--- | :--- | :--- |
| `secrets_share_create` | **tenant**, `secret`, `number`, **envelope**, **key_fingerprint**, `passphrase_hash`, `max_views`, `ttl`, `members_only`, `note` | auteur (`secrets.share.create` ; pour un secret, droit de lecture de sa valeur) ; appelé par le service, qui seul scelle |
| `secrets_share_list` | **tenant**, `active_only`, `limit`, `start` | auteur (les siens), `secrets.share.create` |
| `secrets_share_revoke` | **share** | auteur, `secrets.share.create` |
| `secrets_share_load` | **share** | session système : enveloppe, empreinte, hachage, état, organisation, réservé ou non |
| `secrets_share_fail` | **share** | session système : un essai faux de plus ; au 5e, partage détruit |
| `secrets_share_consume` | **share**, `opener` (identité si connecté) | session système : une ouverture consommée, atomiquement ; enveloppe effacée à la dernière |
| `secrets_share_due` | `limit` | worker : partages échus expirés, fiches finies depuis 30 jours retirées |

* **Événements** (`fn::event_publish`, jamais de valeur) : `secrets.share.created`,
  `.opened`, `.revoked`, `.consumed`, `.expired`, `.destroyed`.
* **Erreurs** (`error/partage/`) : `SECRETS_SHARE_NOT_FOUND`, `SECRETS_SHARE_UNAVAILABLE`
  (clé, mot de passe, état ou organisation : un seul code, sans détail), `SECRETS_SHARE_INVALID`
  (nombre d'ouvertures, durée).
* **Permission** (`seeds/secrets_auth.surql`) : `secrets.share.create` (rôle
  `organization_admin`).
* **Fonctions Core réutilisées** : moteur de validation (nouvelle règle : aucune) ;
  `fn::security_audit_entry` (journal).
* **Fonctions Core manquantes** : aucune.

## 4. Rust

| Élément | Contenu |
| :--- | :--- |
| `lyxal_secrets` : modèles | `Share`, `ShareState`, `ShareCreateParams`, `ShareListParams`/`ShareList`, `ShareRefParams`, `ShareLoaded` (interne au crate, enveloppe masquée), `ShareConsumeParams`, `ShareDueReport`, wrappers `store.call_fn` |
| `SecretsService::share_create` | `ShareRequest { tenant, source: Secret { secret, label, number } \| Text(SecretBytes), max_views, ttl, passphrase: Option<SecretString>, members_only, note }` → `ShareCreated { share, key }` : la clé (`SecretString`, base64url) n'est rendue qu'ici |
| `SecretsService::share_open` | `ShareOpen { share, key: SecretString, passphrase: Option<SecretString> }` → `SecretBytes` ; contrôle dans l'ordre du §2.2, comparaison de l'empreinte en temps constant |
| Worker | `secrets_share_due` à chaque passage ; `MaintenanceReport` complété (`shares_expired`, `shares_removed`) |
| `lyxal-server` | `src/http/secrets.rs` (routes du §2.1), réglage du corps maximal des routes du coffre-fort, en-têtes `no-store` ; tests `tests/secrets_http.rs` |

## 5. Tests

* **Banc SurrealQL** :
  * création d'un partage (droits, bornes) ;
  * chargement et consommation par la session système seulement ;
  * consommation atomique jusqu'au maximum, enveloppe effacée à la dernière ;
  * 5 essais faux et le partage est détruit ;
  * retrait, worker ;
  * champs scellés jamais lisibles ;
  * journal et bus.
* **Rust** :
  * un partage de texte puis d'un secret est ouvert une fois, puis refusé ;
  * une clé fausse, puis un mot de passe faux ;
  * un lien réservé à l'organisation ;
  * un partage échu ;
  * aucune valeur, clé ou mot de passe dans un `Debug` ou une erreur.
* **Hôte** (`tests/secrets_http.rs`) :
  * cycle complet par HTTP : créer, écrire, révéler (en-têtes `no-store`), lister, protéger,
    demander, approuver, appliquer, partager, ouvrir ;
  * sans jeton : refus ;
  * aucune valeur dans une adresse ni dans la trace.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 6. Documents

* `README.md` et `ROADMAP.md` du module.
* Ligne 5 du plan racine passée à « Réalisé ».
* `.agents/AGENTS.md` §6.
* Ce plan supprimé à la fusion de l'implémentation.

## 7. Checklist (§13)

* **Core** : aucune extension.
* **Crypto** : aucune primitive nouvelle (E7). Clé du partage en `SecretBytes`, jamais
  journalisée. AAD non vide.
* **Rust** : aucun `panic!`, aucune erreur silencieuse, aucune valeur dans un journal ou un
  `Debug`.
* **Hôte** : aucun droit recopié ; erreurs `SERVER_*` sans détail interne.
* **Zéro dette** : `0.1.0`, aucune migration.
