# Plan d'implémentation — `lyxal_storage`, lot 4 : support S3 (Bunny Storage en référence)

Quatrième lot du programme `lyxal_storage` (`implementation_plan.md` à la racine, décision S2).
Les octets d'un bucket peuvent être portés par un service S3 ou compatible, par la même
bibliothèque `object_store` que le disque : écriture, lecture, nettoyage et routes de l'hôte ne
changent pas. Service de référence : Bunny Storage par son API compatible S3. Aucune ligne de
code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Ce que l'on sait de Bunny Storage (documentation du 12 novembre 2026)

* L'API S3 s'active **à la création** de la zone de stockage, pas après. Elle est en aperçu et
  n'existe que dans certaines régions (Francfort, New York, Singapour) : **à vérifier sur le
  compte Lyxal avant l'essai réel** ; une région sans S3 répond `501`.
* Une zone = un bucket S3. Clé d'accès : nom de la zone ; clé secrète : mot de passe de la zone.
  Point d'accès : `https://<région>-s3.storage.bunnycdn.com`, adresses de la forme
  `/<zone>/<clé>` uniquement.
* Pris en charge : écriture, lecture (plages), suppression, `HEAD`, liste, copie, envoi en
  plusieurs parties (10 000 parties au plus, session abandonnée effacée après 10 jours), liens
  signés (7 jours au plus). Non pris en charge : chiffrement côté serveur, versions.
* Limites : 500 requêtes par seconde par zone, 100 connexions par adresse ; au-delà, réponse
  `503 SlowDown` à réessayer.

## 2. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **J1** | Un téléchargement passe-t-il toujours par notre serveur, ou par un lien direct vers Bunny ? | **Toujours par notre serveur dans cette V1.** Les droits sont revérifiés à chaque téléchargement, le comportement est le même sur disque et sur S3, et le fichier reste proposé à l'enregistrement. Contrepartie : le trafic passe par notre serveur. Les liens directs (utiles pour de très gros fichiers ou une diffusion large) sont inscrits à la feuille de route |
| **J2** | Disque et S3 peuvent-ils coexister ? | **Oui : chaque bucket nomme son support** (déjà fixé à sa création, décision G4). Une installation peut garder le disque pour certains buckets et Bunny pour d'autres. Plusieurs services S3 peuvent être déclarés |
| **J3** | Comment teste-t-on S3 ? | **Deux niveaux.** À chaque contrôle automatique : un serveur S3 de test lancé dans les tests, sans dépendre d'Internet. À la livraison du lot, puis à la demande : un essai réel sur une zone Bunny de test, lancé à la main, avec des identifiants que vous fournissez dans les réglages secrets de l'environnement de travail (jamais dans le dépôt ni dans la conversation) |
| **J4** | Que devient un envoi coupé en cours de route sur S3 ? | **Le service S3 l'efface lui-même** (10 jours chez Bunny). La fiche, elle, est retirée par notre nettoyage comme aujourd'hui. Un nettoyage actif de ces restes n'est pas possible proprement avec la bibliothèque retenue ; il est inscrit à la feuille de route |

## 3. `lyxal_storage`

| Élément | Changement |
| :--- | :--- |
| `BackendConfig::S3` | `endpoint`, `region`, `bucket`, `access_key_id`, `secret_access_key` (`SecretString`), `path_style` (vrai par défaut), `allow_http` (faux par défaut ; tests et réseau privé) |
| `Backends::with` | construit le support par `object_store::aws::AmazonS3Builder` ; nouvelles tentatives sur `503` et erreurs passagères (`RetryConfig`) |
| `Cargo.toml` | fonctionnalité `aws` d'`object_store` (HTTP par `reqwest`, TLS `rustls`) |
| `StorageError` | `BackendUnavailable` couvre les erreurs du service (injoignable, identifiants refusés) ; aucun identifiant ni URL signée dans un message d'erreur ou un journal |

Rien ne change dans SurrealQL, dans `StorageService`, dans le worker ni dans les routes : le
support est choisi par le champ `backend` du bucket. Le retrait d'un préfixe liste puis supprime
fichier par fichier (pas de suppression groupée). Aucune fonction Core ; aucune primitive
cryptographique ajoutée : la signature des requêtes S3 est celle d'`object_store`, composant
de transport, comme le TLS (pas de crate crypto importée dans le module).

## 4. Hôte

Supports S3 nommés, à côté du disque :

```text
LYXAL__STORAGE__S3__<NOM>__ENDPOINT            https://de-s3.storage.bunnycdn.com
LYXAL__STORAGE__S3__<NOM>__REGION              de
LYXAL__STORAGE__S3__<NOM>__BUCKET              nom de la zone
LYXAL__STORAGE__S3__<NOM>__ACCESS_KEY_ID       nom de la zone
LYXAL__STORAGE__S3__<NOM>__SECRET_ACCESS_KEY   mot de passe de la zone (variable d'environnement seulement)
LYXAL__STORAGE__S3__<NOM>__PATH_STYLE          true
```

* `<NOM>` est le nom du support (`snake_case`), celui que porte le champ `backend` d'un bucket.
  Un support S3 peut s'appeler `default` s'il n'y a pas de dossier disque ; deux supports du même
  nom : démarrage refusé.
* La clé secrète est refusée dans un fichier de configuration ; elle est tenue en `SecretString`,
  masquée dans les journaux. `lyxal_secrets` la portera quand il existera (feuille de route).
* La sonde de santé écrit, relit et retire son fichier témoin sur chaque support, S3 compris.

## 5. Documents

`crates/lyxal_storage/README.md`, `ROADMAP.md` et `RECHERCHE_SOURCES.md` (Bunny, serveur S3 de
test) ; `apps/lyxal-server/README.md` (configuration S3) ; ligne 4 du plan racine passée à
« Réalisé ». Ce plan est supprimé dans la demande de fusion de l'implémentation.

## 6. Tests

* **Serveur S3 de test dans les tests** (`s3s` et `s3s-fs`, Apache-2.0, dépendances de test
  seulement, sur un dossier temporaire et un port local) : les tests du service et du worker
  déjà joués sur mémoire et disque le sont aussi sur S3 (relecture à l'identique, plage
  d'octets, fichier de 64 Mo en plusieurs parties, échecs nettoyés, fichier altéré détecté,
  fichiers supprimés purgés, organisation purgée, sonde) ; identifiants refusés :
  `STORAGE_BACKEND_UNAVAILABLE`.
* **Hôte** : configuration S3 lue (clé secrète masquée, refusée dans un fichier, noms en
  double refusés) ; envoi et téléchargement de bout en bout sur le serveur S3 de test.
* **Essai réel Bunny** (J3) : test ignoré par défaut, lancé avec `LYXAL_TEST_S3_*` ; envoi,
  lecture partielle, envoi en plusieurs parties, suppression, retrait d'un préfixe, sonde. Son
  résultat est rapporté au CTO ; les octets de test sont retirés à la fin.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 7. Checklist (§13)

* Architecture : le Rust porte le protocole du support ; aucune règle déplacée.
* Core : aucune extension. Crypto : aucune primitive ajoutée ni importée dans le module.
* Secrets : aucun identifiant dans le dépôt, les journaux ou les erreurs ; `SecretString`.
* Zéro dette : aucune option de compatibilité ; licences `object_store` (Apache-2.0), `s3s`
  (Apache-2.0, tests).
