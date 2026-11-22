# Plan d'implémentation — programme courrier, agendas et contacts, lot 4 (socle courrier)

Plan détaillé du lot 4 du programme courrier, agendas et contacts (`implementation_plan.md` à la
racine, §4.4, §4.5, §5 et décisions **P2**, **P4**, **P5**, **P15**, **C9** à **C11** du lot 2) :
création de `lyxal_mail_proto` (lecture MIME), du modèle de données de `lyxal_mail` (domaines,
adresses, alias, comptes, boîtes, messages, quotas, droits, erreurs, événements) et du
**chiffrement au repos des messages** (niveau A).

| Brique | Ce que c'est, en clair | Premier lot qui s'en sert vraiment |
| :--- | :--- | :--- |
| Domaines, comptes, adresses, alias | Qui reçoit du courrier, à quelle adresse, dans quelle organisation | lot 5 (refus d'un destinataire inconnu dès `RCPT TO`) |
| Boîtes et messages | Dossiers, numéros IMAP (UID), numéros de modification, drapeaux, fils de discussion | lots 5 (remise), 8 (IMAP), 12 (JMAP) |
| Contenu chiffré | Le message brut (`.eml`) rangé par `lyxal_storage`, chiffré avec une clé propre au fichier | dès ce lot (dépôt d'essai), puis 5, 8, 12 |
| Lecture MIME | Ce que le serveur extrait d'un message : en-têtes utiles, structure des parties | lots 5, 8 (`BODYSTRUCTURE`), 12 |

Ce lot ne contient **aucun protocole** : pas de SMTP, d'IMAP, de POP3 ni de JMAP. Il pose les
données et les règles que ces protocoles appelleront. Le seul chemin d'écriture d'un message est
le service Rust de dépôt (`MailIngest`), exercé par les tests et utilisé tel quel par la remise du
lot 5 et par `APPEND` au lot 8.

Touche : `crates/lyxal_mail_proto` (nouveau, `AGPL-3.0-only`), `crates/lyxal_mail` (SurrealQL et
Rust), `crates/lyxal_storage` (bucket chiffré, compteurs), `crates/lyxal_secrets` (clés de
fichiers par organisation), `apps/lyxal-groupware` (modules hébergés, configuration),
`apps/lyxal-server` (ordre des modules), `Cargo.toml` racine, documents. `lyxal_booking/` n'est pas
touché. Aucune ligne de code avant la validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Méthode : constats faits **par lecture** du dépôt (`crates/lyxal_storage`, `crates/lyxal_secrets`,
`crates/lyxal_crypto` dont `STREAM_FORMAT_V1.md` et `src/stream.rs`, `crates/lyxal_auth`,
`crates/lyxal_core` dont les catalogues `fn::validation_step_catalog` et
`fn::sanitize_step_catalog`, `apps/lyxal-groupware`, plan du lot 2 dans l'historique Git), des
mesures du lot 0 (`RECHERCHE_SOURCES.md`, « Mesures SurrealDB »), de deux fichiers de Mox au
commit figé `b32f0de` lus sur GitHub (`store/account.go`, `store/threads.go`) et de l'index
crates.io (version, licence et dépendances de `mail-parser`). La copie triée de Stalwart
(`.sources/`) n'est pas présente dans cet espace de travail : ce que ce plan dit du modèle `email`
de Stalwart vient des études du lot 0 et est marqué « non vérifié » (§20). **Rien n'a été
compilé ni exécuté.**

**Règle de provenance (programme §4.1, P2)** : le code porté ou transposé de Stalwart et de Mox ne
va que dans `lyxal_mail_proto` et `lyxal_mail` (`AGPL-3.0-only`) ; les évolutions de
`lyxal_storage` et de `lyxal_secrets` sont écrites pour Lyxal et restent sous `MIT OR Apache-2.0`.
Ce lot **ne porte aucun fichier** de Stalwart : il en reprend le modèle (P4, voie B) et celui de
Mox (MIT) ; chaque reprise de modèle est inscrite dans `SOURCES.md` (« modèle »).

## Bilan de réutilisation (`AGENTS.md` §3, §5.7)

**Fonctions `lyxal_core` réutilisées** (toutes vérifiées dans le dépôt) :

| Besoin | Fonction ou règle du Core |
| :--- | :--- |
| Entrées des fonctions publiques | moteur unique `fn::validation_object_execute`, `fn::sanitize_object_execute` (règles des catalogues ci-dessous) |
| Domaine | `domain` (`fn::validation_domain`, sous-domaines permis), `fn::sanitize_domain` |
| Adresse, partie locale | `email` (`fn::validation_email`, 254 au plus), `fn::sanitize_email`, `fn::sanitize_email_local`, `lowercase` |
| Nom de dossier | `normalize_unicode`, `trim`, `remove_control_chars` (nettoyage) ; `max_length`, `regex` (caractères interdits `/`, `*`, `%`) (validation) |
| Mots-clés IMAP / JMAP | `lowercase` ; `ascii`, `max_length`, `regex` (syntaxe « atom » d'IMAP), `array_unique`, `array_length` |
| Identifiants, bornes | `record`, `record_exists`, `uuid`, `integer`, `non_negative_number`, `enum`, `boolean`, `datetime`, `bytes` |
| Journal sans donnée personnelle | `fn::security_redact_email` (messages d'erreur internes, jamais dans un événement) |

**Fonctions métier nouvelles** : 45 fonctions `fn::mail_*` (§8), dont 38 publiques ; dans
`lyxal_storage`, 4 fonctions, 4 champs et une table de plus (§11) ; dans `lyxal_secrets`, une famille de clés
par usage (§12).

**Fonctions Core éventuellement manquantes** (signalées, **non ajoutées**, décision **M10**) :

* conversion d'un nom de domaine international en forme ASCII (`IDNA`, U-label → A-label) : aucune
  fonction ni règle de catalogue ; impossible proprement en SurrealQL ;
* validation d'une partie locale UTF-8 (RFC 6531, `SMTPUTF8`) : `fn::validation_email` repose sur
  `string::is_email`, dont l'acceptation de l'UTF-8 n'est pas vérifiée.

**`lyxal_crypto`** : aucune extension. Le lot utilise `StreamKey`, `StreamEncryptor`,
`StreamDecryptor`, `stream_ciphertext_len`, `CryptoEngine`, `SecretContext::with_tenant`
(lot 2a, `API_CONTRACT.md`) et `hash::blake3`. L'adaptateur asynchrone qui les appelle est écrit
dans `lyxal_storage` (décision C11 du lot 2 : `lyxal_crypto` reste sans `tokio`).

## 0. Écarts au plan du programme

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | `lyxal_secrets` est modifié (le programme ne citait que `lyxal_storage`) | La clé de chaque fichier est scellée par une clé de l'organisation : ces clés appartiennent au coffre-fort (une responsabilité, un propriétaire, §5.1) (M2) |
| E2 | Aucun fichier `migrations/0001_initial.surql` : le schéma est dans `schema/`, comme tous les modules du dépôt (aucun manifeste ne déclare de migration, constaté) | En pré-production, le schéma déclaratif réécrit en place tient lieu de migration unique (§0.3) |
| E3 | Le drapeau « chiffré » réservé (P15) est porté par le **contenu** (`mail_content.protection`) et rendu dans chaque vue de message, pas recopié sur chaque fiche de message | Une copie de message partage le même contenu : c'est le contenu qui est chiffré (M15) |
| E4 | Aucun événement par message au lot 4 ; `mail.message.received` arrive avec la remise SMTP (lot 5) | Aucun consommateur avant le lot 5 ; un événement par écriture doublerait la file des événements pour rien (M16) |
| E5 | `lyxal-groupware` héberge en plus `lyxal_auth`, `lyxal_secrets`, `lyxal_storage` et `lyxal_scheduler` | Écart E6 du lot 3 : chaque module ajouté au manifeste de `lyxal_mail` est ajouté à l'hôte dans le même lot (M13) |
| E6 | Livraison en **quatre demandes de fusion** sous ce plan (4a à 4d, §17) | `lyxal_storage` et `lyxal_secrets` sont relus à part ; la lecture MIME est du Rust pur ; le schéma se relit avant le service |

## 1. Périmètre

**Dans le lot 4** :

* `crates/lyxal_mail_proto` : nouveau paquet `AGPL-3.0-only`, Rust pur sans base ; lecture d'un
  message par `mail-parser` et projection en types Lyxal (enveloppe, structure MIME avec
  positions, clés de fil, sujet de base) (§13) ;
* `crates/lyxal_mail` (SurrealQL) : réglages, domaines, comptes, adresses et alias, boîtes,
  contenus, messages, pierres tombales, quotas, droits, erreurs `MAIL_*`, événements, garde des
  écritures directes, banc `tests/*.test.surql` (§6 à §10) ;
* `crates/lyxal_mail` (Rust) : `MailStore` (un appel typé par fonction), `MailIngest` (dépôt d'un
  message : lecture MIME, écriture chiffrée, inscription), `MailContent` (lecture en flux, plage),
  `MailMaintenance` (contenus abandonnés et libérés, pierres tombales, comptes à purger),
  `MailModule`, `MailHealthCheck` (§14) ;
* `crates/lyxal_storage` : bucket chiffré, clé scellée de chaque fichier, lecture d'une plage
  déchiffrée, empreinte sur le chiffré, compteurs de volume tenus à l'écriture, rescellement après
  rotation (§11) ;
* `crates/lyxal_secrets` : clés d'organisation par usage (`secrets`, `files`), scellement et
  ouverture d'une clé de fichier pour un module de l'hôte (§12) ;
* `apps/lyxal-groupware` : modules hébergés, configuration du stockage et de la clé maîtresse,
  tâche planifiée `mail.maintenance` (§15).

**Ce que fait un lot 4 fusionné, concrètement** : un administrateur d'organisation déclare un
domaine de courrier (déjà vérifié dans `lyxal_auth`), crée le compte de courrier d'un membre
(adresse principale et six dossiers créés ensemble), ajoute des adresses et des alias. Un test
dépose un vrai message : il est lu, chiffré, rangé par `lyxal_storage`, inscrit avec son UID, son
numéro de modification, son fil et ses compteurs ; il se relit en entier ou par plage, se déplace,
se copie, change de drapeaux, s'efface ; les changements se relisent depuis un numéro de
modification, effacements compris. Rien n'est encore joignable par le réseau.

**Hors lot 4** (lot prévu entre parenthèses) : protocoles (5, 6, 8, 9, 10, 12) ; règles
d'acceptation d'un destinataire au-delà de la résolution d'adresse, adresse « attrape-tout »,
liste de blocage (5) ; alias vers des adresses extérieures, listes de diffusion, réécriture SRS
(6) ; droits partagés sur une boîte (ACL, RFC 4314) et boîtes partagées (8) ; index de recherche,
texte des pièces jointes (9) ; aperçu d'un message, compteurs de fils par dossier, blobs JMAP
envoyés à part (12) ; niveaux B et C du chiffrement (12 bis et plus tard) ; alias à la
SimpleLogin (13).

## 2. Point de départ (constats)

| Élément | État constaté |
| :--- | :--- |
| `lyxal_mail` | Squelette Rust (`lyxal_mail::net`), manifeste sans ressource, aucune dépendance Lyxal |
| `lyxal_mail_proto` | N'existe pas ; inscrit « à créer » dans `AGENTS.md` §6 |
| `lyxal_storage` | Fiche `storage_object` (bucket, clé, auteur, nom d'origine, taille, type réel, BLAKE3 du contenu, état) ; écriture en flux par parties de 8 Mo, antivirus dans le même passage ; **aucun chiffrement** ; quota recompté en relisant les fiches à chaque écriture quand un quota est réglé (« quelques dizaines de milliers de fichiers par organisation », README §1) ; dépendances Rust `lyxal_surreal`, `lyxal_runtime`, `lyxal_crypto` |
| `lyxal_secrets` | Clé maîtresse ; une clé par organisation (`secrets_tenant_key`, état `active` / `decrypt_only` / `destroyed`), reconstruite à chaque opération, jamais gardée en mémoire ; rotation et rescellement par la maintenance ; aucune interface publique pour sceller une valeur d'un autre module avec la clé d'organisation |
| `lyxal_crypto` | Chiffrement en flux v1 (`STREAM_FORMAT_V1.md`) : en-tête de 47 octets, segments de 64 Kio, clé par fichier scellée par `enc:v2` ; synchrone ; budget recommandé de 2^24 scellements par clé |
| `lyxal_auth` | `auth_organization_domain` : domaine vérifié par un enregistrement TXT ; `fn::auth_has_permission({ permission, tenant })` ; permissions déclarées par seed avec `app_password: true` pour les mots de passe d'application ; rôles `organization_member`, `organization_admin`, `platform_admin` |
| `lyxal-groupware` | Héberge le socle, `lyxal_event` et `lyxal_mail` (`build.rs`) ; aucune configuration de stockage ni de clé maîtresse |
| Mesures du lot 0 | À 1 000 000 de messages : pages par curseur, synchronisation, drapeau et remise tiennent les seuils ; pagination par décalage, `count()` et `GROUP BY` à la demande sont à proscrire ; correspondance séquence ↔ UID à garder dans la session IMAP |
| `mail-parser` | 1.0.1 (2 novembre 2026), `Apache-2.0 OR MIT` ; dépendances `encodify` 1.0, `hashify` 0.3, `memchr`, `simdutf8` (toutes `Apache-2.0 OR MIT` ou `MIT OR Apache-2.0`), `encoding_rs` et `serde` facultatives (index crates.io, constaté le 20 novembre 2026) |

## 3. Chemin d'un message, de bout en bout

```text
MailIngest::deliver(compte, dossier, octets, date, drapeaux)        (Rust, lyxal-groupware)
 1. lyxal_mail_proto::mime::parse            enveloppe, structure, clés de fil (en mémoire, budget du lot 3)
 2. fn::mail_content_begin                   droits, taille, quota → contenu `pending` + clé de stockage
 3. StorageService::put (session système)    type réel, antivirus, chiffrement (StreamKey), BLAKE3 du chiffré
    └─ fn::storage_object_begin / _commit    bucket `lyxal-mail` de l'organisation, fichier `available`
 4. fn::mail_content_attach (session système) contenu `stored`, lié au fichier
 5. fn::mail_message_create                  UID, numéro de modification, fil, drapeaux, compteurs, quota
```

Les étapes 2 et 5 se font sous la session de l'appelant (l'utilisateur, ou le compte de service
au lot 5) ; les étapes 3 et 4 sous la session système de l'hôte, **après** le contrôle des droits
par `lyxal_mail`. Aucun utilisateur ne reçoit de droit `storage.*` sur le bucket du courrier.
Une panne entre deux étapes laisse un contenu `pending` que la maintenance retire avec son fichier
(§14). Ordre de remise réservé au lot 5 (antivirus → anti-spam → filtres → index → chiffrement) :
les étapes du lot 5 s'insèrent entre 1 et 2 ; le chiffrement reste la dernière.

## 4. Modèle des boîtes (à figer dans ce lot)

### 4.1. Besoins des protocoles

| Besoin | IMAP4rev2 (RFC 9051) et extensions | JMAP courrier (RFC 8620, 8621) |
| :--- | :--- | :--- |
| Identifiant d'un message | UID par dossier, strictement croissant, jamais réutilisé tant que `UIDVALIDITY` ne change pas | `Email.id` stable dans tout le compte |
| Validité des UID | `UIDVALIDITY` par dossier ; doit changer si un dossier est recréé sous le même nom | — |
| Synchronisation | `CONDSTORE` / `QRESYNC` (RFC 7162) : `MODSEQ` par message, `HIGHESTMODSEQ` par dossier, UID effacés depuis un numéro (`VANISHED`) | `state` par type et par compte ; `Email/changes` : créés, modifiés, **détruits** depuis un état |
| Drapeaux | `\Seen`, `\Answered`, `\Flagged`, `\Deleted`, `\Draft` ; mots-clés libres | `keywords` (`$seen`, `$answered`, `$flagged`, `$draft`, libres) |
| Dossiers | Nom hiérarchique, délimiteur, `SPECIAL-USE` (RFC 6154), abonnement | `Mailbox` : `parentId`, `name`, `role`, `sortOrder`, compteurs |
| Fils | `THREAD` (RFC 5256, facultatif) | `threadId` **immuable** par message |
| Appartenance | Une copie = un nouveau message dans le dossier cible | `mailboxIds` ; le serveur annonce `maxMailboxesPerEmail` (RFC 8621 §1.3.1, de mémoire) |
| Quotas | `QUOTA` (RFC 9208) : ressources `STORAGE`, `MESSAGE` | `Quota` (RFC 9425) |

### 4.2. Choix (décisions M5 à M8)

1. **Un message appartient à un seul dossier** (modèle de Mox, `store/account.go` ; modèle du banc
   du lot 0). JMAP annonce `maxMailboxesPerEmail = 1` ; les « libellés » (Proton, Gmail) sont des
   mots-clés (`ROADMAP.md`, « Dossiers et libellés »). Une copie crée une nouvelle fiche qui
   **partage le même contenu** (aucun octet recopié, aucun nouveau scellement). L'identifiant d'une
   fiche est ordonné par dossier et UID (`mail_message:⟨<clé du dossier>_<10^10 + UID>⟩`) : un
   déplacement inscrit une **nouvelle fiche** (nouvel UID, donc nouvel identifiant) dans le dossier
   cible et retire l'ancienne, avec sa pierre tombale dans le dossier source, dans la même
   transaction, sous **un numéro de modification par message déplacé** (commun à la pierre tombale
   et à la nouvelle fiche) ; l'identifiant JMAP stable est `email_id` (UUID v7), gardé par un
   déplacement, nouveau pour une copie — décision P1 du CTO du 21 novembre 2026.
2. **Numéro de modification unique par compte** (Mox : `SyncState.LastModSeq` par compte). Chaque
   écriture d'un compte prend le numéro suivant ; un dossier garde le plus haut numéro de ses
   messages (`HIGHESTMODSEQ`), un message le sien (`MODSEQ`). Le même compteur sert d'état JMAP
   (`Email`, `Mailbox`, `Thread`). Contrepartie : toutes les écritures d'un compte passent par
   la fiche du compte (contention mesurée en 4c, §16).
3. **`UIDVALIDITY` tirée d'un compteur du compte** (Mox : `NextUIDValidity`) : un dossier recréé
   sous un ancien nom reçoit une valeur plus grande ; renommer garde la valeur. UID et
   `UIDVALIDITY` tiennent sur 32 bits non signés (1 à 4 294 967 295) ; un dossier dont `uid_next`
   atteindrait la borne refuse toute nouvelle entrée (`MAIL_MAILBOX_UID_EXHAUSTED`).
4. **Drapeaux système en booléens** (index et compteurs), **mots-clés en minuscules, triés**
   (Mox) ; `\Recent` n'existe plus en IMAP4rev2 et n'est pas stocké.
5. **Fils** (modèle de Mox `store/threads.go` et de l'étude Stalwart) : à l'inscription, le
   message rejoint le fil du premier ancêtre trouvé dans le compte par `In-Reply-To` puis
   `References` (du plus proche au plus lointain), ou d'un message de même `Message-ID` ; sinon un
   nouveau fil (`thread` = UUID v7). Le sujet de base (RFC 5256 §2.1) doit être égal, sauf pour un
   avis de non-remise. **Jamais de fusion de fils après coup** : `threadId` est immuable en JMAP.
   Un enfant arrivé avant son parent ouvre son propre fil (limite connue, notée `thread_orphan`).
6. **Compteurs tenus à l'écriture**, dans la transaction : par dossier `total`, `unseen`, `size`,
   `uid_next`, `highest_modseq` ; par compte `message_count`, `used_bytes`, `modseq`,
   `uid_validity_next`. Aucun `count()` ni `GROUP BY` à la demande (mesures du lot 0).
7. **Pages par curseur** (date et identifiant, ou plage d'UID), jamais par décalage `START`.
8. **Effacements** : une pierre tombale (`mail_tombstone`) par message effacé ou déplacé hors d'un
   dossier, et par dossier supprimé, avec son numéro de modification. Conservée
   `tombstone_retention_days` (30 jours par défaut, M17) ; au-delà, le plancher du compte
   (`changes_floor`) avance et une synchronisation plus ancienne est refusée
   (`MAIL_CHANGES_TOO_OLD` : IMAP refait une synchronisation complète, JMAP rend
   `cannotCalculateChanges`).
9. **Numéros de séquence IMAP** : tenus par la session IMAP en mémoire (lot 8), jamais en base.

### 4.3. Ce que la base garde du contenu (M8)

En clair dans la base (niveau A ne protège que les fichiers, C10) : l'**enveloppe** (date,
sujet, adresses de `From`, `Sender`, `Reply-To`, `To`, `Cc`, `Bcc`, `Message-ID`, `In-Reply-To`,
`References`), le **sujet de base**, la **structure MIME** (types, paramètres, noms de fichiers,
tailles, nombre de lignes des parties texte, positions dans le fichier) et `has_attachment`. Ce
sont les données dont IMAP (`ENVELOPE`, `BODYSTRUCTURE`) et JMAP ont besoin pour lister sans
ouvrir le fichier. **Ni corps, ni texte des pièces jointes, ni aperçu** : l'aperçu JMAP est
décidé au lot 12, l'index au lot 9. Enveloppe et structure sont **facultatives** dans le schéma :
un contenu chiffré pour l'utilisateur (niveaux B et C) pourra s'inscrire sans elles ; au lot 4,
elles sont exigées pour un contenu `platform`.

## 5. Chiffrement au repos (niveau A)

### 5.1. Ce qui est chiffré, ce qui ne l'est pas

| Donnée | Lieu | Chiffrée au niveau A |
| :--- | :--- | :-: |
| Message brut (`.eml`), pièces jointes comprises (elles sont dans le `.eml`) | `lyxal_storage` (disque ou S3) | **oui** (`lyxal_crypto::stream`, une clé par fichier) |
| Clé du fichier | fiche `storage_object.content_key` | scellée (`enc:v2`, clé « fichiers » de l'organisation) |
| Enveloppe, structure MIME, drapeaux, dossiers, adresses, compteurs | SurrealDB | non (limite acceptée par C10) |
| Futur index plein texte (lot 9) | SurrealDB ou moteur du lot 9 | non (C10 ; à revoir au lot 9) |

### 5.2. Hiérarchie des clés (M1, M2)

```text
clé maîtresse du coffre-fort (LYXAL__SECRETS__MASTER_KEY, existante)
   └── clé « fichiers » de l'organisation (secrets_tenant_key, usage `files`, nouvelle famille)
          └── clé du fichier (StreamKey, 32 octets tirés par OsRng, une par message)
                 scellée par enc:v2, rangée dans storage_object.content_key (illisible)
                 └── segments de 64 Kio du .eml (AES-256-GCM, format v1)
```

* **Où chiffrer (C11, M1)** : dans `lyxal_storage`, par une option **« bucket chiffré »** fixée à
  la création du bucket. Un seul endroit, réutilisé tel quel par les agendas (lot 16) et les
  contacts (lot 19). `lyxal_mail` ne voit jamais une clé.
* **Usage séparé (M2)** : la clé qui scelle les clés de fichiers n'est pas celle qui scelle les
  secrets de `lyxal_secrets`. Raisons : budget de 2^24 scellements par clé (`SECURITY.md` du
  crypto) consommé à un message près par le courrier ; rotations indépendantes ; un compromis de
  l'une n'ouvre pas l'autre.
* **Contexte de scellement** de la clé d'un fichier :
  `SecretContext::with_tenant(<organisation>, "lyxal_storage", "storage_object", <clé de la fiche>, "content_key")` ;
  le même contexte sert d'identité au flux chiffré (données associées du format v1) : un fichier
  recopié sous une autre fiche ou une autre organisation ne s'ouvre pas.
* **Rotation** : la clé « fichiers » d'une organisation change selon la période de
  `secrets_settings` (365 jours par défaut) ; l'ancienne passe en `decrypt_only` ; la maintenance
  de `lyxal_storage` rescelle les clés de fichiers par lots (`fn::storage_object_rekey_list`,
  `fn::storage_object_rekey`), **sans réécrire aucun fichier** ; puis `lyxal_secrets` détruit
  l'ancienne clé (fonction existante). À 50 000 messages par an et par compte, une organisation de
  100 comptes consomme 5 millions de scellements par an : la rotation annuelle tient le budget.
* **Effacement définitif** : la purge d'une fiche efface sa clé scellée ; les octets restés dans
  une sauvegarde du support deviennent illisibles sans une sauvegarde de la base du même moment.
* **Sans clé maîtresse** : l'écriture dans un bucket chiffré est refusée
  (`STORAGE_ENCRYPTION_UNAVAILABLE`, à réessayer) ; jamais de repli en clair (M1). La sonde de
  `lyxal-groupware` est alors « dégradée ».

### 5.3. Écriture et lecture en flux (dans `lyxal_storage`)

* **Écriture** : le flux clair passe dans l'ordre par la reconnaissance du type réel et
  l'antivirus (tous deux sur le clair), puis par `StreamEncryptor` (un segment de 64 Kio en mémoire
  au plus, `SecretBytes`), puis par l'empreinte BLAKE3 et l'écriture par parties de 8 Mo. La fiche
  reçoit la taille claire (`size`), la taille stockée (`stored_size` =
  `stream_ciphertext_len(size)`), la clé scellée et son identifiant de clé (`content_key_id`).
* **Empreinte (M3)** : sur un bucket chiffré, `blake3` est l'empreinte **du chiffré**. Une
  empreinte du clair rangée en base permettrait à qui lit la base de confirmer qu'un fichier
  connu s'y trouve. L'intégrité du clair est garantie par l'authentification des segments ;
  `StorageService::verify` compare l'empreinte des octets stockés.
* **Lecture d'une plage** (partie d'un message pour IMAP `BODY[1.2]<0.1000>`, plage HTTP) :
  `StreamDecryptor::plan_range` donne les segments à lire ; seuls ceux-là sont lus et déchiffrés.
  Un segment en échec interrompt le flux par une erreur (`STORAGE_INTEGRITY_FAILED`), jamais par une
  fin normale (règle 11 du §11.3) : l'appelant ferme la connexion.
* **Déduplication** : impossible (une clé par fichier) ; le courrier ne la demande pas.

### 5.4. Recherche et niveaux B / C

Le niveau A ne change rien à la recherche : l'index (lot 9) lit le clair **avant** le
chiffrement (ordre de remise du lot 5) et vit en base, non chiffré (C10). Pour les niveaux B et
C, le champ `mail_content.protection` dira que le serveur ne lit pas le contenu : enveloppe,
structure et index pourront manquer, et aucune fonction de ce lot ne suppose leur présence
au-delà de la validation à l'inscription.

## 6. Schéma SurrealQL (`crates/lyxal_mail/schema/`)

Toutes les tables : `TYPE NORMAL SCHEMAFULL`, champ `tenant` (`record<auth_organization>`,
`REFERENCE ON DELETE CASCADE`, `READONLY`), `created_at` (`READONLY`), `updated_at`. Une
organisation supprimée emporte toutes ses données de courrier ; ses fichiers partent avec son
bucket (mécanisme existant de `lyxal_storage`). Permissions : `fn::mail_can` (§7).

| Fichier | Table | Champs principaux | Index |
| :--- | :--- | :--- | :--- |
| `01_mail_settings.surql` | `mail_settings` | `tenant` (absent : installation), `scope_key`, `max_message_bytes` (50 Mio par défaut, borné par la taille maximale du stockage), `default_quota_bytes` (aucun par défaut), `tombstone_retention_days` (30 ; 7 à 365), `max_mailboxes_per_account` (1 000), `max_addresses_per_account` (100), `max_keywords_per_message` (50) | `scope_key` unique |
| `02_mail_domain.surql` | `mail_domain` | `name` (forme ASCII, minuscules, `READONLY`), `auth_domain` (`record<auth_organization_domain>`, `REFERENCE ON DELETE REJECT`, `READONLY`), `state` (`active`, `disabled`), `subaddress_separator` (`+` par défaut, ou aucun) | `name` unique ; `(tenant, name)` |
| `03_mail_account.surql` | `mail_account` | `identity` (`option<record<auth_identity>>`, `REFERENCE ON DELETE UNSET`), `state` (`active`, `disabled`, `deleting`), `primary_address`, `quota_bytes` (surcharge facultative), compteurs `message_count`, `used_bytes`, `modseq`, `uid_validity_next`, `changes_floor`, `quota_exceeded_at` | `(tenant, identity)` unique ; `state` |
| `04_mail_address.surql` | `mail_address` | `domain` (`record<mail_domain>`, `REFERENCE ON DELETE CASCADE` ; la fonction refuse un domaine non vide), `local_part` (minuscules), `address` (calculée, `READONLY`), `kind` (`account` ou `alias`), `account` (pour `account`), `targets` (`array<record<mail_account>>`, 1 à 50, comptes de la même organisation, pour `alias`), `state` | `address` unique ; `(account)` ; `(domain, local_part)` |
| `05_mail_mailbox.surql` | `mail_mailbox` | `account`, `parent` (`option<record<mail_mailbox>>`), `name` (segment), `path` (chemin complet, `/`), `role` (`inbox`, `drafts`, `sent`, `junk`, `trash`, `archive` ou aucun), `subscribed`, `sort_order`, `uid_validity`, `uid_next`, `modseq` (dernier changement du dossier lui-même), `highest_modseq`, `total`, `unseen`, `size` | `(account, path)` unique ; `(account, role)` unique ; `(account, parent)` |
| `06_mail_content.surql` | `mail_content` | `account`, `key` (`<compte>/<UUID v7>.eml`, sans donnée personnelle), `object` (`option<record<storage_object>>`, `REFERENCE`), `state` (`pending`, `stored`), `size`, `protection` (`platform` seul accepté au lot 4 ; réservé `openpgp`, `client`), `key_fingerprint` (aucune au lot 4), `refs` (fiches de messages qui le lisent), `expires_at` (`pending`) | `key` unique ; `(state, expires_at)` |
| `07_mail_message.surql` | `mail_message` | `account`, `mailbox`, `content` (`record<mail_content>`, `REFERENCE ON DELETE CASCADE` : un contenu n'est supprimé qu'à zéro lecteur, ou avec son organisation), `uid`, `modseq`, `create_modseq`, `thread` (UUID), `thread_orphan`, `received_at` (date interne IMAP), `sent_at`, `size`, `seen`, `answered`, `flagged`, `deleted`, `draft`, `keywords`, `message_id`, `base_subject`, `envelope` (objet typé, facultatif), `structure` (objet `FLEXIBLE`, facultatif), `has_attachment` | `(mailbox, uid)` unique ; `(mailbox, received_at)` ; `(mailbox, modseq)` ; `(mailbox, seen)` ; `(account, modseq)` ; `(account, thread)` ; `(account, message_id)` |
| `08_mail_tombstone.surql` | `mail_tombstone` | `account`, `kind` (`message`, `mailbox`), `mailbox` (clé du dossier, en texte : le dossier peut avoir disparu), `uid`, `object` (identifiant de l'objet détruit), `modseq` | `(mailbox, modseq)` ; `(account, modseq)` ; `created_at` |

Détails :

* **Garde des écritures directes** (`events/mail_guards.surql`, sur le modèle de
  `storage_object_update_guard`) : `tenant`, `account`, `uid`, `create_modseq`, `content`,
  `thread` immuables ; `uid` et `modseq` seulement posés par les fonctions ; une écriture
  directe qui contourne les compteurs est refusée (`THROW "MAIL_WRITE_FORBIDDEN"`). Le compte
  d'un dossier, le dossier d'un message et le compte d'un contenu appartiennent à la même
  organisation (vérifié à la création).
* **`mail_domain.auth_domain`** doit être un domaine **vérifié** de la même organisation (M9) ;
  son retrait dans `lyxal_auth` est refusé tant qu'un domaine de courrier le référence.
* **`mail_account.identity`** : l'identité doit être membre de l'organisation à la création. Son
  retrait de l'organisation coupe l'accès (les droits sont par organisation) sans toucher au
  compte ; la suppression de l'identité met le compte en `deleting` (événement de garde), et la
  maintenance le purge (M12).
* **`envelope`** : sous-champs déclarés (`date`, `subject`, `from`, `sender`, `reply_to`, `to`,
  `cc`, `bcc`, `in_reply_to`, `references`), adresses `{ name, address, group }` ; 1 000
  adresses au plus par champ. **`structure`** : arbre déclaré `TYPE object FLEXIBLE` (profondeur et
  nombre de parties bornés par `lyxal_mail_proto`, §13).
* **`mail_content.refs`** est tenu par `fn::mail_message_create`, `_copy` et `_expunge` ; à zéro, le
  contenu est libéré (§8.6) et son fichier supprimé par `fn::storage_object_delete`, **dans la
  même transaction** que la suppression du contenu (aucun fichier orphelin).

Volume par message (ordre de grandeur, non mesuré) : de 1 à 4 Kio en base selon les adresses et
la structure ; à mesurer au banc (4c).

## 7. Droits

| Permission | Portée | `app_password` | Rôles | Donne |
| :--- | :--- | :-: | :--- | :--- |
| `mail.mailbox.access` | organisation | oui | `organization_member`, `organization_admin` | lire et écrire **son propre** compte : dossiers, messages, drapeaux, dépôt, quota |
| `mail.domain.manage` | organisation | non | `organization_admin` | domaines, comptes, adresses, alias, réglages de l'organisation ; **jamais** le contenu des boîtes (M11) |
| `mail.installation.manage` | installation | non | `platform_admin` | réglages de l'installation |
| `mail.worker` | installation | non | aucun (compte de service) | résolution d'adresse, dépôt dans tout compte, maintenance |

Contrôle unique `fn::mail_can({ action, tenant, account })`, utilisé par les permissions des
tables et par les fonctions (modèle `fn::storage_can`) : session système → oui ; `worker` →
`mail.worker` ; `manage` → `mail.domain.manage` (ou `mail.installation.manage` sans `tenant`) ;
`mailbox` → `mail.mailbox.access` **et** `account.identity` = identité de la session. Une fiche
invisible est « introuvable ». Lire le contenu d'un membre exigera une délégation explicite (ACL,
lot 8), jamais le seul rôle d'administrateur.

## 8. Fonctions SurrealQL (`crates/lyxal_mail/functions/`)

Contrat commun : `DEFINE FUNCTION OVERWRITE fn::mail_<action>($params: object)`, entrées par le
moteur du Core (§5.7.8), `language` (`fr` par défaut), retour `fn::result_ok` /
`fn::error_result`, `COMMENT`, moins de 300 lignes, écriture principale vérifiée
(`MAIL_WRITE_FORBIDDEN`), listes paginées par curseur avec ordre total terminé par l'identifiant.
Paramètres obligatoires en gras. Droits : **G** gestion, **B** boîte (propriétaire), **W**
compte de service, **S** session système.

### 8.1. Réglages, domaines

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `mail_settings_get` | `tenant` | `{ own, effective }` | G, B (lecture des limites) |
| `mail_settings_set` | `tenant`, champs du §6, `clear` | réglages | G |
| `mail_domain_create` | **auth_domain**, `subaddress_separator` | domaine | G |
| `mail_domain_get` | **domain** | domaine et `{ addresses }` (compteur tenu) | G |
| `mail_domain_list` | `tenant`, `after`, `limit` (50, 200 au plus) | `{ items, next }` par nom | G |
| `mail_domain_update` | **domain**, `state`, `subaddress_separator` | domaine | G |
| `mail_domain_delete` | **domain** | `{ deleted }` ; refus s'il porte une adresse (`MAIL_DOMAIN_NOT_EMPTY`) | G |

### 8.2. Comptes

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `mail_account_create` | **identity**, **domain**, **local_part**, `quota_bytes` | compte, adresse principale et six dossiers (`INBOX`, `Drafts`, `Sent`, `Junk`, `Trash`, `Archive`, rôles posés, M18) créés ensemble | G |
| `mail_account_get` | `account` (par défaut : celui de la session) | compte, quota effectif | G, B |
| `mail_account_list` | `tenant`, `state`, `after`, `limit` | `{ items, next }` | G |
| `mail_account_update` | **account**, `state` (`active`, `disabled`), `quota_bytes`, `clear` | compte | G |
| `mail_account_delete` | **account** | compte `deleting` ; adresses retirées tout de suite ; purge par la maintenance | G |
| `mail_quota_get` | `account` | `{ used_bytes, message_count, quota_bytes }` (ressources `STORAGE` et `MESSAGE`) | G, B |

### 8.3. Adresses et alias

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `mail_address_create` | **domain**, **local_part**, **kind**, `account` ou `targets` | adresse | G |
| `mail_address_update` | **address**, `state`, `targets` | adresse | G |
| `mail_address_delete` | **address** | `{ deleted }` ; l'adresse principale d'un compte ne se retire pas (`MAIL_ADDRESS_IS_PRIMARY`) | G |
| `mail_address_list` | `domain` ou `account`, `after`, `limit` | `{ items, next }` | G ; B pour son compte |
| `mail_address_resolve` | **address** | `{ accounts: [compte], address }` : partie locale en minuscules, sous-adresse retirée (`jean+factures` → `jean`), alias développé, comptes `active` seulement ; `MAIL_RECIPIENT_UNKNOWN` sinon | W, S |

### 8.4. Dossiers

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `mail_mailbox_create` | **name**, `parent`, `role`, `subscribed` | dossier (`uid_validity` du compteur du compte) | B |
| `mail_mailbox_get` | **mailbox** | dossier et compteurs | B |
| `mail_mailbox_list` | `account` | dossiers du compte, compteurs compris (lecture directe, aucun calcul) | B |
| `mail_mailbox_update` | **mailbox**, `name`, `parent`, `role`, `subscribed`, `sort_order` | dossier ; renommage : chemins des sous-dossiers réécrits dans la transaction ; `INBOX` ne se renomme pas au lot 4 | B |
| `mail_mailbox_delete` | **mailbox**, `remove_messages` (faux par défaut) | `{ deleted, expunged }` ; refus si sous-dossiers, si `INBOX`, ou si non vide sans `remove_messages` (au-delà de 5 000 messages : `MAIL_MAILBOX_TOO_LARGE`, vidage par lots d'abord) | B |

### 8.5. Messages

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `mail_message_create` | **content**, **mailbox**, **received_at**, `sent_at`, `seen`…`draft`, `keywords`, `message_id`, `in_reply_to`, `references`, `base_subject`, `is_report`, `envelope`, `structure`, `has_attachment` | message (`uid`, `modseq`, `thread`) ; quota contrôlé ; `mail.quota.exceeded` au premier refus | B, W |
| `mail_message_get` | **message** | message, avec `protection` du contenu | B |
| `mail_message_list` | **mailbox**, `before` (`{ received_at, id }`) ou `uid_min` / `uid_max`, `limit` (50, 1 000 au plus), `fields` (`summary` ou `full`) | `{ items, next }` par date décroissante, ou par UID croissant | B |
| `mail_message_changes` | **account** ou **mailbox**, **since** (numéro de modification), `limit` (1 000, 5 000 au plus) | `{ changed: [{ id, mailbox, uid, modseq, drapeaux, keywords }], removed: [{ kind, mailbox, uid, object, modseq }], highest_modseq, more }` ; `MAIL_CHANGES_TOO_OLD` sous le plancher | B |
| `mail_message_flags_set` | **messages** (500 au plus), `add`, `remove`, `replace` (drapeaux et mots-clés), `unchanged_since` | `{ updated: [{ id, uid, modseq }], conflicts: [id] }` (`CONDSTORE`) ; compteurs du dossier | B |
| `mail_message_move` | **messages** (500 au plus), **mailbox** | `{ moved: [{ id (nouvelle fiche), from, from_uid, uid, modseq }] }` ; ancienne fiche retirée, pierres tombales à la source, `email_id` gardé (décision P1 du CTO du 21 novembre 2026) | B |
| `mail_message_copy` | **messages** (500 au plus), **mailbox** | `{ copied: [{ source, id, uid }] }` ; contenu partagé, quota compté | B |
| `mail_message_expunge` | **mailbox**, `messages` (sinon tous les `\Deleted` du dossier, 500 par appel) | `{ expunged: [{ id, uid, modseq }], more }` ; contenus libérés | B |
| `mail_thread_get` | **thread** | `{ messages: [id] }` par date de réception | B |

### 8.6. Contenus (chemin de dépôt) et maintenance

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `mail_content_begin` | **account**, **size**, `protection` (`platform`) | `{ content, key, bucket_name, max_size }` ; taille, quota, état du compte contrôlés ; délai d'abandon 1 h | B, W |
| `mail_content_attach` | **content**, **object** | contenu `stored` ; le fichier doit être `available`, dans le bucket `lyxal-mail` de l'organisation, à la clé du contenu, de même taille claire (lu par `fn::storage_object_get`) | W, S |
| `mail_content_open` | **message** | `{ object, size, protection }` pour la lecture par le service | B, W |
| `mail_content_expire` | `limit` (100) | `{ expired }` : contenus `pending` hors délai retirés, leur fichier supprimé (`fn::storage_object_delete`) s'il existe | W, S |
| `mail_tombstone_purge` | `limit` (1 000) | `{ purged }` ; `changes_floor` des comptes avancé | W, S |
| `mail_account_purge_step` | `limit` (500) | `{ accounts, messages, done }` : messages, contenus et fichiers d'un compte `deleting` retirés par lots, puis le compte | W, S |

Fonctions internes (non publiques, `COMMENT` « interne ») : `fn::mail_can`,
`fn::mail_settings_effective`, `fn::mail_modseq_next` (avance le compteur du compte),
`fn::mail_thread_assign`, `fn::mail_counters_apply`, `fn::mail_content_release`,
`fn::mail_write_refusal` (garde). Le dépôt de six dossiers et de l'adresse principale tient dans
`fn::mail_account_create` (moins de 300 lignes, découpé si besoin).

**Cohérence et concurrence** : chaque fonction est une seule instruction, donc une seule
transaction ; deux écritures concurrentes dans un même compte se heurtent sur la fiche du compte
(compteur de modifications) ; le service Rust rejoue une écriture refusée pour conflit de
transaction, trois fois au plus (modèle de `SecretsService::put`), jamais une écriture refusée
pour une autre cause.

## 9. Erreurs `MAIL_*` (`crates/lyxal_mail/error/<thème>/`)

Forme `IF !record::exists(error_definition:<CODE>) THEN ( CREATE … ) END;`, `module: "mail"`,
traductions `fr` / `en`, statut HTTP et caractère « à réessayer » comme `lyxal_storage`.

| Thème | Codes |
| :--- | :--- |
| `parametres` | `MAIL_INVALID_PARAMETERS` (champs du rapport du Core dans `details.fields`) |
| `permissions` | `MAIL_PERMISSION_DENIED`, `MAIL_WRITE_FORBIDDEN` |
| `domaines` | `MAIL_DOMAIN_NOT_FOUND`, `MAIL_DOMAIN_EXISTS`, `MAIL_DOMAIN_NOT_VERIFIED`, `MAIL_DOMAIN_DISABLED`, `MAIL_DOMAIN_NOT_EMPTY` |
| `comptes` | `MAIL_ACCOUNT_NOT_FOUND`, `MAIL_ACCOUNT_EXISTS`, `MAIL_ACCOUNT_NOT_MEMBER`, `MAIL_ACCOUNT_DISABLED`, `MAIL_ACCOUNT_DELETING` |
| `adresses` | `MAIL_ADDRESS_NOT_FOUND`, `MAIL_ADDRESS_EXISTS`, `MAIL_ADDRESS_IS_PRIMARY`, `MAIL_ADDRESS_LIMIT`, `MAIL_ALIAS_TARGET_INVALID`, `MAIL_RECIPIENT_UNKNOWN` |
| `dossiers` | `MAIL_MAILBOX_NOT_FOUND`, `MAIL_MAILBOX_EXISTS`, `MAIL_MAILBOX_HAS_CHILDREN`, `MAIL_MAILBOX_NOT_EMPTY`, `MAIL_MAILBOX_TOO_LARGE`, `MAIL_MAILBOX_PROTECTED`, `MAIL_MAILBOX_ROLE_TAKEN`, `MAIL_MAILBOX_LIMIT`, `MAIL_MAILBOX_UID_EXHAUSTED` |
| `messages` | `MAIL_MESSAGE_NOT_FOUND`, `MAIL_MESSAGE_TOO_LARGE`, `MAIL_MESSAGE_MALFORMED`, `MAIL_MESSAGE_BATCH_TOO_LARGE`, `MAIL_CHANGES_TOO_OLD`, `MAIL_KEYWORD_LIMIT` |
| `contenus` | `MAIL_CONTENT_NOT_FOUND`, `MAIL_CONTENT_STATE_INVALID`, `MAIL_CONTENT_UNAVAILABLE` (à réessayer : stockage ou clés absents), `MAIL_CONTENT_CORRUPTED` |
| `quotas` | `MAIL_QUOTA_EXCEEDED` |

39 codes. Les erreurs du service Rust (`MailError`) reprennent ces codes ou ceux de
`lyxal_storage` qu'il propage ; aucune adresse, aucun sujet dans un message d'erreur rendu.

## 10. Événements (`events/mail_events.surql`)

Publiés par `fn::event_publish` dans la transaction de la mutation, résultat vérifié (`THROW` en
cas d'échec, §5.6.1). **Charges utiles sans donnée personnelle** : identifiants d'enregistrement
et compteurs seulement ; ni adresse, ni nom de domaine, ni sujet.

| Type | Quand | Charge utile |
| :--- | :--- | :--- |
| `mail.domain.created` | domaine créé | `domain_id`, `tenant` |
| `mail.domain.deleted` | domaine supprimé | `domain_id`, `tenant` |
| `mail.account.created` | compte créé | `account_id`, `tenant` |
| `mail.account.deleted` | compte purgé (fin de `deleting`) | `account_id`, `tenant` |
| `mail.address.created` | adresse ou alias créé | `address_id`, `account_id` (aucun pour un alias), `kind`, `tenant` |
| `mail.address.deleted` | adresse ou alias retiré | `address_id`, `kind`, `tenant` |
| `mail.quota.exceeded` | premier dépôt refusé pour quota depuis le dernier passage sous le quota | `account_id`, `tenant`, `quota_bytes`, `used_bytes` |

Producteur seul : `lyxal_mail` ne connaît aucun consommateur ; aucun abonnement dans ce lot.
`lyxal_storage` continue de publier `storage.object.created` / `.deleted` pour chaque fichier du
courrier (clé et nom de fichier sans donnée personnelle : `message.eml`) ; volume noté au §19.

## 11. Évolutions de `lyxal_storage` (4a)

| Élément | Changement |
| :--- | :--- |
| `storage_bucket.encrypted` | booléen fixé à la création (`READONLY`) ; un bucket chiffré refuse toute écriture sans service de clés |
| `storage_object` | nouveaux champs `stored_size`, `content_key` (enveloppe `enc:v2`, illisible hors session système et worker, comme l'enveloppe de `secrets_version`), `content_key_id` (lisible : rotation) ; `blake3` du chiffré sur un bucket chiffré (M3) |
| `storage_usage` (nouvelle table) | volume et nombre de fichiers par portée et par bucket, tenus par `begin`, `commit`, `delete`, `purge` dans leur transaction ; le quota lit ces compteurs au lieu de relire les fiches (M4) ; contrôle de cohérence par `fn::storage_usage_verify` (worker) |
| Fonctions | `fn::storage_object_rekey_list`, `fn::storage_object_rekey` (rescellement après rotation, worker), `fn::storage_usage_verify`, `fn::storage_object_key_get` (enveloppe d'une fiche, session système et worker seulement) |
| Rust | `StorageService::with_file_keys(FileKeys)` ; adaptateur asynchrone `EncryptingWriter` / `DecryptingReader` sur `StreamEncryptor` / `StreamDecryptor` ; `put` et `open` (plage comprise) passent par lui pour un bucket chiffré ; `StorageCleanup` ajoute le rescellement par lots |
| Erreurs | `STORAGE_ENCRYPTION_UNAVAILABLE` (à réessayer) ; un segment altéré rend `STORAGE_INTEGRITY_FAILED` (existant) |
| Dépendances | `lyxal_secrets` (manifeste et Cargo, M2) ; aucune crate cryptographique (contrôle `check_crypto_dependencies.py`) |

Les buckets non chiffrés et leurs routes HTTP gardent leur comportement ; `lyxal-server`
n'active le service de clés que pour les buckets chiffrés.

## 12. Évolutions de `lyxal_secrets` (4a)

* `secrets_tenant_key.purpose` (`secrets` ou `files`, `READONLY`) : une clé `active` par
  organisation **et par usage** ; contexte de scellement de la clé complété par l'usage ;
  `secrets_settings.files_key_rotation_days` (365, de 30 à 3 650, 0 : désactivée).
* `FileKeys` (Rust, public) : `seal(tenant, &StreamKey, &SecretContext) -> SealedFileKey` et
  `open(tenant, &SealedFileKey, &SecretContext) -> StreamKey`, session système ; la clé de
  l'organisation est reconstruite à chaque appel et jamais gardée (règle actuelle du module, M19
  pour un éventuel cache). Une clé `files` est créée à la première écriture de l'organisation.
* Maintenance : rotation échue des clés `files` ; destruction d'une clé `files` en
  `decrypt_only` seulement quand `lyxal_storage` n'en a plus aucune fiche
  (`fn::storage_object_rekey_list` vide pour cette clé, lu par `fn::secrets_tenant_key_destroy`
  au travers d'un paramètre `in_use` fourni par l'hôte : `lyxal_secrets` ne lit aucune table de
  `lyxal_storage`).
* Aucun changement de `lyxal_crypto` ; aucune valeur hors de `SecretBytes` / `StreamKey`.

## 13. `lyxal_mail_proto` au lot 4 (4b)

Paquet `crates/lyxal_mail_proto`, `license = "AGPL-3.0-only"`, `publish = false`, avec
`SOURCES.md` et `LICENSES/` ; Rust pur (pas de base, pas de `tokio`) ; dépendance
`mail-parser = "1.0.1"` (`default-features = false`, `encoding_rs` activé pour les jeux de
caractères hérités ; options à confirmer à la compilation). Au lot 4, **un seul module** :

```rust
pub mod mime {
    pub struct MimeLimits { pub max_depth: u8, pub max_parts: u16, pub max_addresses: u16 }   // 20, 1 000, 1 000
    pub struct ParsedMessage {
        pub envelope: Envelope,            // date, sujet, adresses, Message-ID, In-Reply-To, References
        pub structure: BodyPart,           // arbre : type, paramètres, disposition, nom, positions, tailles, lignes
        pub thread: ThreadKeys,            // Message-ID et ancêtres normalisés (sans <>), du plus proche au plus lointain
        pub base_subject: Option<String>,  // RFC 5256 §2.1
        pub sent_at: Option<OffsetDateTime>,
        pub has_attachment: bool,
        pub is_report: bool,               // multipart/report : avis de non-remise, pas de rapprochement par sujet
    }
    pub fn parse(raw: &[u8], limits: &MimeLimits) -> Result<ParsedMessage, MimeError>;
}
```

* `parse` ne rejette presque rien (un message reçu se garde même mal formé, comme le font
  Stalwart et Mox) : `MimeError` seulement pour un message vide, sans séparateur d'en-tête
  lisible, ou au-delà des limites (`MAIL_MESSAGE_MALFORMED`).
* Positions (`header_offset`, `body_offset`, `end_offset`) en octets du message brut : elles
  servent la lecture d'une partie par plage (§5.3) et `BODYSTRUCTURE` au lot 8.
* Sujet de base : par `mail-parser` s'il l'offre (`thread_name`, **non vérifié**), sinon écrit
  pour Lyxal d'après la RFC 5256 §2.1.
* Tests : messages du corpus de `mail-parser` (s'il est publié dans le paquet, non vérifié) et
  messages écrits pour Lyxal (jeux de caractères, `multipart` imbriqués, en-têtes repliés,
  pièces jointes, messages tronqués) ; propriétés `proptest` (aucune panique, positions dans les
  bornes) ; cible de fuzzing `cargo fuzz` préparée, lancée au lot 21.
* Non inclus au lot 4 : syntaxes SMTP, IMAP, Sieve, rapports, JMAP (lots 5 à 12).
* Rust porté à 1.98 et `mail-parser` 1.0.1, décision du CTO du 21 novembre 2026.

## 14. `lyxal_mail` en Rust (4d)

| Élément | Rôle |
| :--- | :--- |
| `models/` | `XxxParams` / `XxxResult` de chaque fonction (`SurrealValue`, structures nommées) : `DomainCreateParams` / `Domain`, `AccountCreateParams` / `AccountCreated`, `AddressCreateParams` / `Address`, `AddressResolveParams` / `ResolvedRecipient`, `MailboxCreateParams` / `Mailbox`, `MessageCreateParams` / `MessageCreated`, `MessageListParams` / `MessagePage`, `MessageChangesParams` / `MessageChanges`, `FlagsSetParams` / `FlagsSetResult`, `MoveParams` / `MoveResult`, `CopyParams` / `CopyResult`, `ExpungeParams` / `ExpungeResult`, `ContentBeginParams` / `ContentReservation`, `QuotaGetParams` / `Quota`… ; types `MailRecordId`, `MailDatetime` (`models/types.rs`) ; `Envelope`, `BodyPart` convertis depuis `lyxal_mail_proto` |
| `MailStore` | `LyxalSurrealCall` ; un wrapper d'une ligne par fonction : `pub async fn message_create(&self, params: MessageCreateParams) -> Result<MessageCreated, LyxalSurrealError> { self.call_fn("mail_message_create", params).await }` ; deux magasins : celui de l'appelant et celui de la session système |
| `MailIngest` | `deliver(store_appelant, compte, dossier, octets: Bytes, date, drapeaux)` : étapes du §3 ; réservation mémoire (`MemoryBudget`, lot 3) de la taille du message ; nettoyage du fichier si l'inscription échoue ; rejeu sur conflit (§8) |
| `MailContent` | `open(store_appelant, message, plage)` → flux d'octets clairs (`lyxal_storage`, session système, après `fn::mail_content_open`) ; erreur de segment propagée, jamais une fin normale |
| `MailMaintenance` | une opération `run` interrompue entre deux éléments (modèle `StorageCleanup`) : `mail_content_expire`, `mail_tombstone_purge`, `mail_account_purge_step` ; bilan `MaintenanceReport` ; exécutée par `lyxal_scheduler` (tâche `mail.maintenance` déclarée par l'hôte, toutes les 10 min) |
| `MailModule` | `LyxalModule` du module (remplace le `ManifestModule` du lot 3), workers des écoutes inchangés |
| `MailHealthCheck` | base joignable ; service de clés présent ; bucket chiffré écrivable (fichier témoin via la sonde de `lyxal_storage`) ; contenus `pending` en retard |
| `MailError` | code `MAIL_*` ou `STORAGE_*` propagé ; `is_retryable()` ; aucun contenu, aucune adresse |

Dépendances nouvelles du crate : `lyxal_mail_proto`, `lyxal_surreal`, `lyxal_runtime`,
`lyxal_storage`, `lyxal_error`, `bytes`, `futures` (déjà au workspace, à confirmer). Aucune crate
cryptographique. Le module `net` du lot 3 est inchangé.

Manifeste `lyxal_mail` : dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`,
`lyxal_storage` ; `[resources]` : 8 schémas, 6 fichiers de fonctions, 9 fichiers d'erreurs, 2
fichiers d'événements (gardes, publications), seed `seeds/mail_auth.surql` (permissions et rôles).

## 15. Hôte `lyxal-groupware` (4d)

* `build.rs` et modules : ajout, dans l'ordre des dépendances, de `lyxal_auth`, `lyxal_secrets`,
  `lyxal_storage`, `lyxal_scheduler` (déjà installés par `lyxal-server` sur une base partagée :
  release retrouvée, hook non rejoué) ; `MailModule` à la place du `ManifestModule`.
* Configuration : clé maîtresse du coffre-fort (`LYXAL__SECRETS__MASTER_KEY`, même valeur que
  `lyxal-server`), supports de stockage (mêmes supports nommés que `lyxal-server` : disque partagé
  ou S3) ; démarrage refusé si un bucket chiffré existe sans clé maîtresse configurée
  (`GROUPWARE_CONFIG_INVALID`, existant ou à créer).
* Tâche `mail.maintenance` (handler Rust, exécutée par un nœud de `lyxal-groupware` seulement,
  mécanisme « tâche `handler` réservée par l'hôte qui a son code » déjà en place).
* `lyxal-server` : ordre de `build.rs` corrigé (`lyxal_secrets` avant `lyxal_storage`) ; aucun
  module AGPL lié (`check_agpl_isolation.py`).

## 16. Banc de tests

**SurrealQL** (`crates/lyxal_mail/tests/*.test.surql`, `scripts/ci/test_lyxal_modules.py`) :
`reglages`, `domaines`, `comptes`, `adresses`, `dossiers`, `messages`, `synchronisation`,
`contenus`, `droits`, `organisations`. Chaque fonction publique est appelée ; cas nominaux et
erreurs ; sessions système, compte de service, administrateur, membre propriétaire, autre membre
(introuvable), membre d'une autre organisation (introuvable) ; écriture filtrée →
`MAIL_WRITE_FORBIDDEN` ; écriture directe refusée par les gardes. Points précis : UID strictement
croissants et jamais réutilisés après effacement ; `UIDVALIDITY` plus grande pour un dossier
recréé sous le même nom ; numéros de modification croissants dans le compte ; compteurs égaux au
contenu réel après chaque scénario ; pages par curseur sans doublon ni manque à égalité de date ;
`unchanged_since` ; déplacement (nouvelle fiche, même `email_id`, nouvel UID, pierre tombale) ; copie (contenu
partagé, `refs`) ; effacement du dernier message d'un contenu → fichier supprimé dans la même
transaction ; plancher et `MAIL_CHANGES_TOO_OLD` ; fils (réponse, références, sujet différent,
avis de non-remise, enfant avant parent) ; résolution (casse, sous-adresse, alias, compte
désactivé) ; quota et événement unique ; seeds rejouables ; isolement entre organisations.
`lyxal_storage` et `lyxal_secrets` : bancs existants complétés (bucket chiffré, compteurs,
rescellement, clés par usage).

**Rust** :

* `lyxal_mail_proto` : §13.
* `lyxal_storage` (`tests/it/`) : bucket chiffré sur mémoire, disque et S3 de test (`s3s-fs`) ;
  fichier relu à l'identique ; octets stockés différents du clair et commençant par `LXS1` ;
  plages à cheval sur des segments ; segment altéré, fichier tronqué, fiche recopiée → erreur
  au bon segment ; antivirus sur le clair ; rescellement après rotation puis destruction de
  l'ancienne clé ; compteurs de volume égaux aux fiches ; 64 Mo sans dépasser la mémoire prévue.
* `lyxal_mail` (`tests/it/`, base embarquée et serveur SurrealDB 3.3.4 réel en `ws://`) :
  dépôt de bout en bout (parse, chiffrement, inscription) ; lecture entière et d'une partie ;
  panne simulée entre chaque étape du §3 puis maintenance → aucun fichier ni contenu orphelin ;
  dépôts concurrents dans un même compte et un même dossier (rejeu sur conflit, UID uniques) ;
  suppression d'une identité → compte purgé ; suppression d'une organisation → plus rien.
* **Mesures** (`scripts/bench/mailbox/`, étendu, hors CI) : remise par `fn::mail_message_create`
  avec les permissions de table sous une session de membre (le lot 0 mesurait une session
  authentifiée sans fonction de permission) ; quatre clients dans un même compte (contention du
  compteur de modifications) ; changements depuis un numéro de modification avec pierres
  tombales ; coût d'un scellement de clé de fichier par message. Seuils : ceux de la décision C5
  du lot 0.
* `lyxal-groupware` : démarrage avec clé maîtresse et stockage, sonde, tâche de maintenance, deux
  hôtes (installation des modules partagés une seule fois).

`scripts/ci/ci_local.sh` vert avant chaque demande de fusion ; `cargo deny check licenses`
(arbre de `mail-parser`).

## 17. Découpage en demandes de fusion

| PR | Contenu | Touche | Taille estimée |
| :- | :--- | :--- | :-: |
| **4a** | Bucket chiffré, compteurs de volume, rescellement ; clés par usage et `FileKeys` | `lyxal_storage`, `lyxal_secrets`, `lyxal-server` (ordre) | M |
| **4b** | `lyxal_mail_proto` : lecture MIME, limites, tests, `SOURCES.md` | `lyxal_mail_proto`, `Cargo.toml`, `deny.toml` si besoin | S |
| **4c** | Schéma, fonctions, gardes, erreurs, événements, seeds, banc SurrealQL ; mesures | `lyxal_mail` (SurrealQL) | M à L |
| **4d** | Service Rust, module, sonde, maintenance ; hôte ; tests de bout en bout ; documents | `lyxal_mail` (Rust), `lyxal-groupware` | M |

Ordre : 4a et 4b en parallèle, puis 4c, puis 4d. Chaque demande de fusion compile, passe la CI et
laisse le dépôt cohérent (4c installe un module sans service Rust : aucun appelant hors des tests,
admis pour un schéma déclaratif comme `lyxal_base`). Taille totale : **L** (6 000 à 12 000 lignes,
tests compris), conforme au programme.

## 18. Documents mis à jour

`crates/lyxal_mail/README.md` (état actuel : modèle, fonctions, droits, erreurs, événements),
`ROADMAP.md` (lot 4 retiré, points reportés : aperçu, ACL, IDN, attrape-tout), `SOURCES.md`
(modèles Mox `store/account.go`, `store/threads.go` ; étude Stalwart `email` ; `mail-parser`) ;
`crates/lyxal_mail_proto/{README,ROADMAP,SOURCES}.md` (nouveaux) ; `crates/lyxal_storage`
`README.md` et `ROADMAP.md` (chiffrement, compteurs) ; `crates/lyxal_secrets/README.md` (clés par
usage) ; `apps/lyxal-groupware/README.md` (modules, configuration) ; `.agents/AGENTS.md` §6 et
`docs/14-roadmap/ROADMAP_NOYAU.md` (`lyxal_mail_proto` créé ; `lyxal_mail` : socle) ;
`implementation_plan.md` racine (lot 4 réalisé). Ce plan est supprimé après la fusion de 4d.

## 19. Risques

| Risque | Ce qu'il faut savoir |
| :--- | :--- |
| **Modèle figé trop tôt** | UID, numéros de modification, fils et « un message = un dossier » conditionnent IMAP et JMAP. Un mauvais choix se paie aux lots 8 et 12 ; en pré-production le schéma reste réécrivable (§0), mais pas le code des protocoles bâti dessus |
| **Contention du compteur de compte** | Toutes les écritures d'un compte touchent sa fiche ; le lot 0 n'a pas mesuré plusieurs écrivains dans un même compte. Mesure en 4c ; repli : compteur par dossier et journal des changements du compte (modèle de Stalwart) |
| **Permissions de table à l'échelle** | `fn::mail_can` est évalué par ligne lue ; une synchronisation de 5 000 messages l'évalue 5 000 fois. Mesure en 4c ; repli : contrôle une fois par fonction puis lecture sous une session système du service (à décider alors) |
| **Clés à chaque lecture** | Ouvrir un message = reconstruire la clé de l'organisation (une lecture en base, une ouverture `enc:v2`) puis ouvrir la clé du fichier. Coût à mesurer (lecture de centaines de messages par une session IMAP) ; un cache en mémoire est une décision (M19) |
| **Volume des événements** | `lyxal_storage` publie deux événements par message (création, suppression) : la file des événements double à la remise. Mesure en 4d ; une option « bucket sans événements » serait une évolution de `lyxal_storage` à décider |
| **Perte de clé** | Clé maîtresse ou clé « fichiers » perdue = courrier de l'organisation illisible ; la sauvegarde des clés (procédures de `lyxal_secrets`) devient vitale pour le courrier |
| **Partage du stockage entre hôtes** | `lyxal-groupware` et `lyxal-server` doivent voir les mêmes supports (disque partagé ou S3) et la même clé maîtresse : à écrire dans les procédures d'exploitation |
| **Messages hors norme** | `mail-parser` est tolérant ; un message très imbriqué ou énorme coûte de la mémoire (bornée par la taille maximale et le budget du lot 3) ; fuzzing au lot 21 |
| **Types refusés du stockage** | Les types refusés par défaut (exécutables) s'appliquent au type reconnu d'un `.eml` ; un message qui commencerait par une signature d'exécutable serait refusé. Improbable (un `.eml` commence par des en-têtes), testé en 4d |

## 20. Ce qui n'a pas pu être vérifié

* Modèle `email` de Stalwart (fils, état JMAP, appartenance à plusieurs dossiers) : copie triée
  absente de cet espace de travail ; repris des études du lot 0, à relire en 4c.
* `mail-parser` 1.0.1 : présence de `thread_name`, des positions de parties, d'une limite
  d'imbrication, comportement des options (`encoding_rs`) ; corpus de tests dans le paquet.
* Acceptation de l'UTF-8 par `string::is_email` (SurrealDB 3.3.4).
* `maxMailboxesPerEmail` (RFC 8621 §1.3.1) et numéros de RFC cités : de mémoire, à revérifier.
* Évaluation des permissions de table sous une session de membre et contention à plusieurs
  écrivains : non mesurées (§16).
* Le message d'erreur exact de SurrealDB 3.3.4 pour un `REFERENCE ON DELETE REJECT` (retrait d'un
  domaine `lyxal_auth` référencé) et sa traduction en code Lyxal ; l'ordre des suppressions en
  cascade à la purge d'une organisation quand `mail_domain.auth_domain` est en `REJECT` (à
  essayer en 4c ; repli : refus porté par une garde de `lyxal_mail` qui laisse passer la purge).

## 21. Décisions du CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **M1** | Où chiffrer le contenu des messages (C11) ? Chiffrement obligatoire ? | Option **« bucket chiffré » de `lyxal_storage`**, réutilisée par les agendas et les contacts. Chiffrement **obligatoire** pour le courrier : sans clé maîtresse, le dépôt est refusé (à réessayer), jamais rangé en clair |
| **M2** | Quelle clé scelle les clés de fichiers ? | Une clé « fichiers » par organisation dans `lyxal_secrets`, **distincte** de celle des secrets (budget, rotation, cloisonnement) ; `lyxal_storage` dépend de `lyxal_secrets` (manifeste et Cargo), sans dépendance inverse |
| **M3** | Empreinte d'un fichier chiffré | BLAKE3 **du chiffré** : aucune empreinte du clair en base |
| **M4** | Quotas d'organisation à l'échelle du courrier | Compteurs de volume tenus à l'écriture dans `lyxal_storage` (point de sa feuille de route), faits en 4a ; sans eux, un quota d'organisation relit des millions de fiches à chaque message |
| **M5** | Un message dans un ou plusieurs dossiers ? | **Un seul dossier** (Mox), `maxMailboxesPerEmail = 1` en JMAP ; libellés = mots-clés ; copie = nouvelle fiche sur le même contenu |
| **M6** | Numéro de modification par dossier ou par compte ? | **Par compte** (Mox) : sert IMAP `CONDSTORE` / `QRESYNC` et l'état JMAP avec un seul compteur ; contention mesurée en 4c, repli décrit au §19 |
| **M7** | Règle des fils | `In-Reply-To`, `References`, `Message-ID`, sujet de base égal (sauf avis de non-remise) ; identifiant **immuable**, **aucune fusion** après coup ; enfant avant parent : fil à part, accepté |
| **M8** | Ce qui reste en clair en base | Enveloppe, structure MIME, sujet de base ; **ni corps, ni aperçu, ni texte des pièces jointes** (aperçu au lot 12, index au lot 9) ; enveloppe et structure facultatives dans le schéma (niveaux B et C) |
| **M9** | Vérification des domaines de courrier | Réutiliser les domaines **vérifiés** de `lyxal_auth` (`auth_organization_domain`) ; aucune vérification propre au courrier |
| **M10** | Domaines internationaux et adresses UTF-8 | Lot 4 en **ASCII seulement** (domaine en forme A-label, partie locale ASCII). Conversion IDNA et parties locales UTF-8 : besoin d'extension de `lyxal_core` **signalé**, à instruire avant le lot 5 (`SMTPUTF8`) |
| **M11** | L'administrateur d'une organisation peut-il lire les boîtes des membres ? | **Non** : il gère comptes, adresses et quotas, jamais le contenu. Accès à la boîte d'autrui par délégation explicite (ACL, lot 8) ; un accès d'urgence tracé, s'il est voulu, sera un plan à part |
| **M12** | Départ d'un membre, suppression d'une identité | Retrait de l'organisation : accès coupé, compte **gardé** jusqu'à sa suppression par l'administrateur. Suppression de l'identité : compte purgé (état `deleting`, puis maintenance) |
| **M13** | Modules hébergés par `lyxal-groupware` | Ajouter `lyxal_auth`, `lyxal_secrets`, `lyxal_storage`, `lyxal_scheduler` ; l'hôte reçoit la clé maîtresse et la configuration des supports de stockage (mêmes valeurs que `lyxal-server`) |
| **M14** | Un message remis à plusieurs comptes : un contenu ou plusieurs ? | **Un contenu par compte** : quotas exacts, suppression d'un compte sans effet sur les autres ; le partage n'existe qu'entre copies d'un même compte |
| **M15** | Drapeau « chiffré » réservé (P15) | Champ `mail_content.protection` (`platform` seul accepté au lot 4 ; `openpgp` et `client` réservés) et `key_fingerprint`, rendus dans chaque vue de message |
| **M16** | Événements par message au lot 4 | **Aucun** : `mail.message.received` arrive au lot 5 avec la remise SMTP ; le lot 4 publie domaines, comptes, adresses et dépassement de quota |
| **M17** | Durée de conservation des effacements (synchronisation) | **30 jours** par défaut, réglable de 7 à 365 ; au-delà, resynchronisation complète (IMAP) ou `cannotCalculateChanges` (JMAP) |
| **M18** | Valeurs par défaut | Message de **50 Mio** au plus ; aucun quota de compte par défaut (réglé par l'organisation) ; six dossiers créés avec le compte, **noms anglais** et rôles `SPECIAL-USE` (les logiciels affichent leurs propres noms traduits) |
| **M19** | Cache en mémoire des clés « fichiers » | **Pas de cache** au lot 4 (règle actuelle de `lyxal_secrets`) ; mesure en 4c ; un cache court, effacé à l'expiration, ne viendrait que sur nouvelle décision |
| **M20** | Découpage | Quatre demandes de fusion 4a à 4d sous ce plan (§17) |

## 22. Complément : vitesse et contrat d'adhésion (4e, avant 4d)

Les mesures de 4c (à leur date ; état actuel : README, « Mesures ») montrent que les seuils C5 ne sont pas tenus :
dépôt à 11 par seconde, page de 50 messages en 1,85 s sous la session d'un membre, conflits du
compteur par compte. Ce complément est livré avant 4d, en deux demandes de fusion.

| Décision | Contenu |
| :- | :--- |
| **P1** | Identifiants ordonnés `mail_message:[dossier, uid]` (lectures bornées aux lignes rendues, permissions de table conservées) ; exécuteur par événement écarté — décision du CTO du 21 novembre 2026. Réalisé (4e-3) : clé texte de largeur fixe `<clé du dossier>_<10^10 + UID>` (le moteur de `lyxal_core` ne lit pas un identifiant tableau), vue par date `mail_message_date` sur le même modèle ; un déplacement inscrit une nouvelle fiche et retire l'ancienne ; règle de lecture par fiche allégée (organisation et titulaire recopiés sur les fiches, session lue par chemins, même portée que `fn::mail_can`), `fn::mail_can` une fois par appel. Essais : un membre ne lit jamais le compte d'un autre, par plages d'identifiants comprises ; mesures de la page de 50 sous la session d'un membre à 2 000, 20 000 et 100 000 messages (README, « Mesures »). |
| **P2** | Moteur de `lyxal_core` accéléré (`fn::validation_object_execute`, `fn::sanitize_object_execute`, `fn::security_object_execute`, `fn::utils_engine_*`, et le tri `fn::utils_collection_sort_by` en temps n log n) sans changer son contrat ; mesures avant / après dans le README de `lyxal_core`. Aucune validation propre au courrier (§5.7.8). |
| **P3** | Compteur unique par compte (M6) gardé ; contention remesurée après P1 et P2 (4 écrivains). Repli du §19 (compteur par dossier et journal du compte) seulement si la mesure reste mauvaise, sur nouvelle décision. |
| **P4** | Contrat public `fn::auth_organization_member_check({ organization, identity })` dans `lyxal_auth` (adhésion active ou non, sous les droits de l'appelant) ; `fn::mail_account_create` l'utilise au lieu de lire `auth_member_of`. |

Découpage : **4e-1** `lyxal_core` (P2) ; **4e-2** `lyxal_auth` et `lyxal_mail` (P1, P3, P4),
puis 4d.

Validé par le CTO le 21 novembre 2026 (décisions P1 à P4 telles que recommandées).

Décisions complémentaires du CTO (22 novembre 2026, telles que recommandées) :

| Décision | Contenu |
| :- | :--- |
| **P5** | `lyxal_auth` : révoquer une clé d'API ou un mot de passe d'application révoque aussitôt les sessions qui en sont issues ; une session issue d'une clé ou d'un mot de passe d'application n'expire jamais après lui. La règle de lecture par ligne de `lyxal_mail` couvre ainsi ces cas. |
| **P6** | La règle de lecture par ligne de `lyxal_mail` reprend des règles de validité de session de `lyxal_auth` (coût) : écart accepté, consigné dans les README des deux modules ; toute évolution de ces règles dans `lyxal_auth` met à jour celle de `lyxal_mail` dans le même changement. |
| **P7** | Débit de dépôt et contention du compteur par compte (M6) traités au lot 5 (compteur par dossier, contrôle des paramètres du dépôt allégé). |

## Checklist (`.agents/rules/lyxal_standards_and_checklist.md` §13)

* [ ] **Architecture** : modèle et règles dans `lyxal_mail` ; chiffrement dans `lyxal_storage` ;
  clés dans `lyxal_secrets` ; aucun cycle (`lyxal_storage` → `lyxal_secrets`, `lyxal_mail` →
  `lyxal_storage`, `lyxal_auth`) ; aucun code AGPL dans un crate permissif.
* [ ] **Core** : entrées par `fn::validation_object_execute` / `fn::sanitize_object_execute` ;
  besoins IDNA et UTF-8 signalés (M10), rien d'ajouté.
* [ ] **SurrealQL** : `fn::mail_<action>($params: object)`, `fn::result_ok` / `fn::error_result`,
  `COMMENT`, moins de 300 lignes, écritures vérifiées (`MAIL_WRITE_FORBIDDEN`), gardes, pages par
  curseur avec ordre total, compteurs tenus, banc complet.
* [ ] **Rust** : `XxxParams` / `XxxResult`, wrappers `store.call_fn`, aucun `panic!`, aucun
  `raw_query()` métier, aucun secret exposé, aucune tâche hors `lyxal_scheduler` ou `LyxalWorker`.
* [ ] **Erreurs** : 39 codes `MAIL_*` en master data ; `STORAGE_ENCRYPTION_UNAVAILABLE` ;
  aucune erreur silencieuse.
* [ ] **Événements** : `fn::event_publish` vérifié ; charges sans donnée personnelle ; aucun
  consommateur connu.
* [ ] **Cryptographie** : uniquement `lyxal_crypto` (flux v1, `enc:v2`) ; contexte jamais vide ;
  aucune extension ; aucune crate crypto hors `lyxal_crypto`.
* [ ] **Chiffrement des boîtes** : niveau A appliqué ; `protection` réservé ; aucun contrat ne
  suppose le contenu lisible au-delà de l'inscription `platform`.
* [ ] **Zéro dette** : schéma unique réécrit en place ; versions `0.1.0` ; `ManifestModule` du lot 3
  remplacé ; plan supprimé après fusion ; `ROADMAP.md` tenue.
* [ ] **Provenance** : `SOURCES.md` des deux crates ; aucune partie `LicenseRef-SEL`.
* [ ] **Validation CTO** : ce plan, décisions M1 à M20.

Validé par le CTO le 21 novembre 2026 (décisions M1 à M20 telles que recommandées).
