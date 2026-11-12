# Plan d'implémentation — `lyxal_storage`, lot 6 : envoi reprenable

Sixième lot du programme `lyxal_storage` (`implementation_plan.md` à la racine, décision S5).
Un gros fichier peut être envoyé en plusieurs requêtes : après une coupure, le client demande au
serveur où il en est et reprend à cet endroit, sans tout renvoyer. Le protocole est tus 1.0,
standard ouvert pour lequel il existe des clients prêts à l'emploi (navigateur, mobile, ligne de
commande). L'envoi en une seule requête (`PUT`, lot 3) reste inchangé. Aucune ligne de code avant
la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **L1** | Quelle partie du protocole tus met-on en place ? | **Le cœur du protocole et trois extensions : création, abandon, expiration.** C'est ce qu'utilisent les clients courants. Reportés à plus tard (feuille de route) : taille inconnue au départ, envoi en parallèle de plusieurs morceaux, contrôle d'empreinte par morceau |
| **L2** | Où sont gardés les morceaux déjà reçus ? | **Sur le même support que le fichier final** (disque ou S3), et la liste des morceaux **dans la base**. Un envoi survit donc à un redémarrage du serveur et fonctionne avec plusieurs serveurs. Rien n'est gardé en mémoire |
| **L3** | Quand les contrôles du lot 5 (type réel, antivirus, empreinte) sont-ils faits ? | **Une seule fois, à la fin, quand le fichier est complet** : les morceaux sont relus dans l'ordre et passent par exactement le même chemin qu'un envoi simple. Conséquences acceptées : pendant cette étape le fichier occupe deux fois sa place, et un fichier refusé (virus, type interdit) ne l'est qu'à la fin de l'envoi. Les refus connus d'avance (taille, quota, type annoncé, adresse occupée) restent faits dès la création |
| **L4** | Combien de temps un envoi inachevé est-il gardé ? | **24 heures après sa création**, réglable de 1 minute à 7 jours, par installation ou par organisation. Passé ce délai, le worker retire les morceaux. Le délai n'est pas prolongé par l'activité : la règle reste simple et annoncée au client dès la création |
| **L5** | Reprend-on une bibliothèque existante ? | **Non, pas pour le serveur** : les bibliothèques tus en Rust sont jeunes (`fileloft` 0.3) et écrivent sur leur propre stockage, pas sur le nôtre. Le protocole est court ; il est écrit d'après sa spécification, avec `tusd` (serveur de référence) et `fileloft` pour modèles. Les tests suivent la spécification requête par requête ; un client tus indépendant sera utilisé en test s'il en existe un utilisable en Rust |

## 2. Fonctionnement

1. **Création** : le client annonce la taille, le bucket, la clé, le nom et le type. La fiche du
   fichier est créée à l'état `pending`, comme pour un envoi simple, avec le délai de L4. Son
   identifiant est celui de l'envoi.
2. **Morceaux** : chaque requête `PATCH` porte la position où elle écrit. Les octets sont écrits
   sur le support, par parties de 8 Mo au plus, puis chaque partie est inscrite dans la base.
   Une coupure en cours de requête conserve ce qui est déjà reçu.
3. **Position** : la base est la seule vérité. Un index unique (envoi, position) garantit qu'une
   position n'est écrite qu'une fois, même si deux requêtes arrivent en même temps sur deux
   serveurs ; la perdante reçoit un refus et ses octets sont retirés.
4. **Fin** : quand la position atteint la taille annoncée, le fichier est assemblé (L3), contrôlé
   et rendu disponible. Si le serveur s'arrête pendant cette étape, le worker la termine à son
   prochain passage.
5. **Abandon ou expiration** : fiche supprimée.
6. **Retrait des morceaux** : dès qu'un envoi reprenable n'est plus en cours (terminé, abandonné
   ou expiré), la base inscrit, dans la même transaction, le dossier de ses morceaux dans la
   table `storage_reclaim` (lot 2). Le worker le retire du support et n'efface cette ligne
   qu'après y être parvenu : un arrêt du serveur à n'importe quel moment ne laisse aucun morceau
   oublié.

Seul l'appelant qui a créé l'envoi peut le poursuivre, le consulter ou l'abandonner.

## 3. SurrealQL

| Élément | Changement |
| :--- | :--- |
| `storage_settings.upload_ttl_seconds` | nouveau réglage (L4) : 86 400 par défaut, de 60 à 604 800 ; `fn::storage_settings_set` et `fn::storage_settings_effective` |
| `storage_object.resumable` | booléen fixé à la création (`false` par défaut) |
| `storage_upload_part` | nouvelle table : `object`, `offset`, `size`, `name` (nom des octets sur le support), `created_at` ; index unique (`object`, `offset`) ; aucune permission directe hors worker |
| `fn::storage_object_begin` | paramètre `resumable` : exige `declared_size` et applique le délai de L4 |
| `fn::storage_upload_get` | fiche d'un envoi, sa position et sa taille ; réservée à son auteur |
| `fn::storage_upload_part_add` | inscrit une partie ({ object, offset, size, name }) : l'envoi est en cours et non expiré, la position est exactement la position courante, la taille annoncée n'est pas dépassée, 10 000 parties au plus |
| `fn::storage_upload_part_list` | parties d'un envoi dans l'ordre, pour l'assemblage (auteur ou worker) |
| `fn::storage_upload_ready_list` | worker : envois complets non assemblés |
| Événement `storage_object_upload_parts` | quand la fiche d'un envoi reprenable quitte l'état `pending` ou est supprimée : retire les lignes de parties et inscrit le dossier des morceaux (`<chemin du fichier>.parts`) dans `storage_reclaim`, dans la même transaction |

Fonctions Core réutilisées : `fn::validation_object_execute` (règles `record`, `integer`,
`boolean`, `uuid`). Aucune fonction Core manquante.

Erreurs ajoutées (thème `envois`) : `STORAGE_UPLOAD_OFFSET_MISMATCH` (409),
`STORAGE_UPLOAD_EXPIRED` (410), `STORAGE_UPLOAD_INVALID_REQUEST` (400),
`STORAGE_UPLOAD_VERSION_UNSUPPORTED` (412), `STORAGE_UPLOAD_TOO_MANY_PARTS` (400).

## 4. Rust (`lyxal_storage`)

| Fichier | Contenu |
| :--- | :--- |
| `upload.rs` | `StorageService::upload_create`, `upload_status`, `upload_append` (flux d'octets), `upload_terminate`, `upload_complete` (assemblage : les parties sont relues en flux et passent par l'écriture existante, donc par le type réel, l'antivirus et l'empreinte) |
| `models/upload.rs`, `store.rs` | `UploadGetParams`, `UploadPartAddParams`, `UploadStatus`, `UploadPart` ; un wrapper `call_fn` par fonction |
| `backend.rs` | les parties sont rangées sous `<chemin du fichier>.parts/` ; ce dossier est retiré par le chemin existant de `storage_reclaim` (`remove_prefix`) |
| `worker.rs` | `StorageCleanupWorker` termine les envois complets non assemblés (avec l'antivirus configuré) ; le retrait des morceaux passe par `storage_reclaim`, sans code nouveau |
| `error.rs` | `StorageError::UploadOffsetMismatch`, `UploadExpired` |

Aucune nouvelle dépendance. Mémoire bornée à une partie de 8 Mo par requête.

## 5. Hôte

Routes sous `/api/v1/storage/uploads`, hors limite de taille et hors délai global comme les
autres routes de fichiers, avec la même authentification et le même délai d'inactivité :

| Requête | Effet |
| :--- | :--- |
| `OPTIONS /uploads` | version, extensions et taille maximale annoncées |
| `POST /uploads` | crée l'envoi (`Upload-Length`, `Upload-Metadata` : `bucket`, `key`, `filename`, `filetype`) ; `201`, `Location`, `Upload-Expires` |
| `HEAD /uploads/{id}` | `Upload-Offset`, `Upload-Length`, `Cache-Control: no-store` |
| `PATCH /uploads/{id}` | écrit à `Upload-Offset` (`Content-Type: application/offset+octet-stream`) ; `204` et nouvelle position ; la dernière requête rend la fiche disponible ou l'erreur du contrôle |
| `DELETE /uploads/{id}` | abandonne l'envoi ; `204` |

En-têtes tus ajoutés à ceux que la configuration CORS autorise et expose, pour les clients
navigateur. Erreurs au format `LyxalResult`, comme les autres routes.

## 6. Tests

* Banc SurrealQL : création, positions, refus (mauvaise position, dépassement, expiré, autre
  appelant, trop de parties), retrait des parties, écriture directe refusée.
* Module, sur les trois supports (mémoire, disque, S3 de test) : envoi en plusieurs morceaux,
  reprise après coupure, deux requêtes concurrentes sur la même position, assemblage contrôlé
  (type interdit, virus), abandon, expiration, assemblage terminé par le worker, morceaux
  retirés par le worker après un arrêt simulé juste après la fin de l'envoi.
* Hôte : parcours complet par HTTP d'après la spécification tus, en-têtes compris.

## 7. Documents

`crates/lyxal_storage/README.md` et `ROADMAP.md` ; `apps/lyxal-server/README.md` ; ligne 6 du
plan racine passée à « Réalisé » ; `.agents/AGENTS.md` §6 et `docs/14-roadmap/ROADMAP_NOYAU.md`.
Ce plan est supprimé dans la demande de fusion de l'implémentation.
