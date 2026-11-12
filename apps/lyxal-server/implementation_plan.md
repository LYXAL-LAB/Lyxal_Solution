# Plan d'implémentation — `lyxal_storage`, lot 3 : routes d'envoi et de téléchargement (hôte)

Troisième lot du programme `lyxal_storage` (`implementation_plan.md` à la racine). L'hôte expose
les fichiers par HTTP : envoi, téléchargement, fiche, liste et suppression, en flux, sous les
droits de l'appelant. Le crate `lyxal_storage` reçoit deux compléments. S3 est au lot 4, le
contrôle du contenu au lot 5, l'envoi reprenable au lot 6. Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **H1** | Quelles opérations par HTTP dans ce lot ? | **Envoyer, télécharger, lire la fiche, lister, supprimer un fichier.** La gestion des buckets et des réglages reste aux fonctions SurrealQL, appelées par la console comme pour les autres modules |
| **H2** | Un fichier téléchargé s'affiche-t-il dans le navigateur ? | **Non dans ce lot : toujours proposé à l'enregistrement.** Afficher un fichier envoyé par un tiers dans la page de l'application est une porte d'entrée connue pour du code malveillant. L'affichage direct des images et des PDF est inscrit au lot 5, quand le type réel du fichier est contrôlé |
| **H3** | Qui peut appeler ces routes ? | **Toute session valide** (utilisateur, clé d'API, compte de service) ; ce sont ses permissions `storage.*` qui décident, comme partout ailleurs |
| **H4** | Quelle limite pour un envoi ? | **Celle du bucket** (100 Mo par défaut, 5 Go au plus), au lieu de la limite générale de 10 Mo des autres routes. Un envoi ou un téléchargement qui ne transmet plus rien pendant 60 secondes est coupé |

Question du programme reportée au lot 4 : téléchargement par liens signés servis par le support
(Bunny), ou toujours par l'hôte. Elle n'a de sens qu'avec S3.

## 2. Routes (`/api/v1/storage`)

`{bucket}` est la clé du bucket (`storage_bucket:<clé>`), sans ambiguïté entre organisations ;
`{*key}` est la clé du fichier (`plans/2026/a.pdf`).

| Méthode et chemin | Effet | Réponse |
| :--- | :--- | :--- |
| `PUT /buckets/{bucket}/objects/{*key}` | envoie un fichier : le corps de la requête est son contenu | `201`, fiche |
| `GET /buckets/{bucket}/objects/{*key}` | télécharge le fichier, en entier ou sur une plage (`Range`) | `200` ou `206`, contenu |
| `HEAD /buckets/{bucket}/objects/{*key}` | mêmes en-têtes que `GET`, sans contenu | `200` |
| `DELETE /buckets/{bucket}/objects/{*key}` | supprime le fichier | `200`, fiche |
| `GET /buckets/{bucket}/objects?prefix=&limit=&start=` | liste les fichiers disponibles | `200`, `{ items, total }` |
| `GET /buckets/{bucket}/objects/{*key}?metadata` | fiche du fichier, quel que soit son état | `200`, fiche |

* **Envoi** : corps brut (pas de formulaire `multipart`), lu en flux ; `Content-Type` devient le
  type annoncé, `Content-Length` (s'il est présent) la taille annoncée, `X-Lyxal-Filename` (texte
  encodé en pourcent) le nom d'origine, sinon le dernier segment de la clé. Une adresse occupée
  est refusée (`STORAGE_OBJECT_EXISTS`, décision F4).
* **Téléchargement** : `Content-Type`, `Content-Length`, `ETag` (empreinte BLAKE3),
  `Last-Modified`, `Accept-Ranges: bytes`, `Content-Disposition: attachment` avec le nom
  d'origine (H2), `X-Content-Type-Options: nosniff`, `Cache-Control: private, no-store`.
  `If-None-Match` rend `304` ; une seule plage par requête ; `If-Range` respecté.
* **Réponses** : contrat `LyxalResult` (`{ ok, data, error }`) sauf le contenu d'un fichier ;
  erreurs `STORAGE_*` rendues dans la langue de la requête avec leur statut HTTP de la master
  data, sans détail interne.

## 3. Droits

* L'appelant est identifié par son jeton d'accès (`Authorization: Bearer`), vérifié par
  `AccessService::authenticate` comme pour `/auth/*` (H3).
* Chaque requête ouvre une **session SurrealDB au nom de l'appelant** (client de l'hôte cloné,
  `authenticate(jeton)`, comme la publication de l'ingestion) et construit un `StorageService`
  dessus : les fonctions `fn::storage_*` et les permissions des tables décident. L'hôte ne
  recopie aucune règle de droit et n'utilise jamais sa session système pour ces routes.
* Sans service de connexion (clé applicative ou `auth.public_url` absentes) :
  `SERVER_AUTH_DISABLED`. Sans support : `STORAGE_BACKEND_UNKNOWN`.

## 4. Limites (H4)

* Les routes `/storage` sortent de la limite générale du corps (`server.body_limit_bytes`) et du
  délai total d'une requête : la taille est bornée par `max_size` du bucket, vérifiée pendant
  l'écriture par `StorageService::put` (arrêt dès le dépassement).
* Délai d'inactivité de 60 s sur le flux reçu et sur le flux servi
  (`storage.idle_timeout_seconds`, 5 à 600).
* La limite de requêtes simultanées du serveur s'applique toujours.

## 5. Compléments à `lyxal_storage`

| Élément | Changement |
| :--- | :--- |
| `StorageService::open` | la plage demandée est comparée à la taille de la fiche avant la lecture ; plage hors du fichier : `STORAGE_RANGE_NOT_SATISFIABLE` (au lieu d'une erreur du support). Plages `début-fin`, `début-` et `-fin` |
| Erreur ajoutée (thème `fichiers`) | `STORAGE_RANGE_NOT_SATISFIABLE` (416) |
| `StorageError` | variante `RangeNotSatisfiable` |

Aucune fonction SurrealQL nouvelle. Fonctions Core : aucune (les entrées des routes sont
transmises telles quelles aux fonctions `fn::storage_*`, qui les valident par `lyxal_core`).

## 6. Hôte

| Fichier | Contenu |
| :--- | :--- |
| `src/http/storage.rs` | routes du §2 ; session de l'appelant ; en-têtes ; rendu des erreurs `STORAGE_*` (réutilise le rendu de `http/auth.rs`, rendu commun aux deux) |
| `src/http/router.rs` | `/storage` monté hors de la limite de corps et du délai total |
| `src/modules/storage.rs` | les supports (`Arc<Backends>`) sont gardés dans `HostedServices` pour les routes |
| `src/context.rs` | `AppContext.storage` : supports de l'hôte |
| `src/config.rs` | `storage.idle_timeout_seconds` |
| `error/server.surql` | aucun code nouveau |

## 7. Documents

`apps/lyxal-server/README.md` (routes, limites), `crates/lyxal_storage/README.md` et
`ROADMAP.md`, ligne 3 du plan racine passée à « Réalisé ». Ce plan est supprimé dans la demande
de fusion de l'implémentation.

## 8. Tests

* **Hôte, de bout en bout** (base embarquée, support disque temporaire, jetons réels) :
  * envoi puis téléchargement à l'identique ; en-têtes ; `HEAD` ; fiche ; liste ; suppression ;
  * plage d'octets (`206`, `Content-Range`), plage invalide (`416`), `If-None-Match` (`304`) ;
  * fichier de 32 Mo envoyé au-delà de la limite générale de 10 Mo ; envoi plus grand que la
    limite du bucket refusé sans laisser d'octets ;
  * sans jeton (`401`) ; lecteur qui envoie ou supprime (`403`) ; fichier d'une autre
    organisation introuvable (`404`) ; adresse occupée (`409`) ; clé d'API autorisée (H3) ;
  * flux interrompu : aucun fichier disponible ; sans support : `503`.
* **`lyxal_storage`** : plages valides et invalides de `open`.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 9. Checklist (§13)

* Architecture : l'hôte porte le protocole HTTP ; droits et règles restent en SurrealQL, sous la
  session de l'appelant ; aucune règle recopiée.
* Core : aucune extension demandée. Crypto : aucune primitive ajoutée.
* Erreurs : contrat `LyxalResult`, aucun détail interne, aucune erreur silencieuse.
* Zéro dette : aucune route ni paramètre de compatibilité.
