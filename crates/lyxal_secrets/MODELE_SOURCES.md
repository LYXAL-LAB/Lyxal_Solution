# `lyxal_secrets` — modèle et sources

Produits dont `lyxal_secrets` reprend un fonctionnement, capacités de SurrealDB retenues ou
écartées, et décisions du CTO qui fixent la conception du module. L'état du module est décrit par
son [`README.md`](README.md), ses évolutions par sa [`ROADMAP.md`](ROADMAP.md), son exploitation
par [`PROCEDURES.md`](PROCEDURES.md).

Documentations officielles lues le 13 novembre 2026 ; fonctionnement de SurrealDB essayé sur un
serveur 3.3.4.

## 1. Principe d'assemblage

* **Modèle** : fonctionnement d'un produit étudié et transcrit (SurrealQL pour les données et les
  règles, Rust pour le chiffrement). Aucun code repris d'un projet sous licence BUSL, GPL, AGPL
  ou propriétaire ; s'inspirer d'une fonction payante sans copier de code est permis.
* **Chiffrement** : exclusivement `lyxal_crypto` (§11.3), sans bibliothèque nouvelle.
* **Dépendances ajoutées** : aucune bibliothèque de chiffrement ; `base64` (encodage du lien de
  partage), déjà présente dans le dépôt.

## 2. Modèles retenus, par fonction

| Fonction de `lyxal_secrets` | Modèle | Ce qui en est repris |
| :--- | :--- | :--- |
| Versions, numéro suivant obligatoire, 10 versions gardées | Vault et OpenBao KV v2 (`max_versions`, `cas`) | Une écriture ne remplace jamais une autre ; destruction de la plus ancienne au-delà du nombre gardé |
| Étiquettes `current`, `previous`, `pending` | AWS Secrets Manager | Lecture par défaut sur `current`, retour arrière par déplacement d'étiquette, 20 étiquettes au plus |
| États de version (active, désactivée, détruite) | Google Secret Manager | Désactivation réversible, destruction irréversible |
| Suppression douce, restauration, purge, protection contre la purge | Azure Key Vault | Délai de 7 à 90 jours, protection irréversible, purge = droit distinct |
| Noms des clés d'un JSON sans les valeurs | Vault KV v2 `subkeys` | Champ `keys` d'une version |
| Clé par organisation scellée par une clé maîtresse | Infisical | Isolation cryptographique entre organisations ; effacer une organisation efface sa clé |
| Contexte de scellement lié | AWS (contexte `{ARN, version}`) | Une enveloppe recopiée ailleurs ne s'ouvre pas |
| Rescellement après rotation de clé | Vault `rewrap` | Rescellement de toutes les versions gardées, puis destruction de l'ancienne clé |
| Droits par opération, refus par défaut | Vault (politiques), Azure (lire ≠ lister) | Permissions `lyxal_auth` par opération |
| Visibilité restreinte | Doppler | Un humain écrit sans relire, sauf secret « révélable » avec double facteur |
| Journal avant toute remise, sans valeur | Vault, OpenBao (journal bloquant) | Ticket de lecture journalisé dans la même transaction |
| Journal infalsifiable | OWASP 2.6 | Chaînage par `fn::security_audit_entry` de `lyxal_core` |
| Alertes d'échéance | Azure (`SecretNearExpiry`, `SecretExpired`) | Événements `secrets.secret.expiring`, `.expired` |
| Notifier plutôt que tourner | Google Secret Manager | Rappel `rotation_due` quand aucun rotateur n'existe |
| Rotation en quatre étapes, deux jeux valides | AWS (création, installation, test, bascule) | `pending` → test → `current`, l'ancienne reste `previous` |
| Accès temporaire par chemin | OpenBao 2.3, Infisical (privilège à durée limitée) | Accès en plus des droits, toujours limité dans le temps |
| Demandes d'accès et de changement, N approbateurs | Infisical, Doppler, groupes de contrôle Vault / OpenBao | Auto-approbation interdite, contournement d'urgence tracé et publié |
| Partage à usage unique | Vault (réponse enveloppée), Infisical (lien avec expiration et mot de passe), Bitwarden Send | Clé dans le lien seulement, ouvertures et durée limitées |
| Liste de contrôle | OWASP Secrets Management Cheat Sheet | Moindre privilège, effacement en mémoire, journal, métadonnées, révocation (§2.3 à 9.2) |

## 3. SurrealDB 3.3.4

| Capacité | Constat | Décision |
| :--- | :--- | :--- |
| Chiffrement | Aucun : ni fonction SurrealQL, ni chiffrement des fichiers sur disque | Tout est scellé en Rust avant écriture |
| `PERMISSIONS FOR select NONE` sur un champ | Écriture sans relecture, y compris par `WHERE`, tri ou fonction ; la session système lit | Enveloppes, clés scellées, empreintes, hachages |
| `DEFINE EVENT` | Exécuté dans la transaction ; un `THROW` annule l'écriture | Gardes de toutes les tables, journal, publication |
| Historique natif (`VERSION`), `CHANGEFEED` | Gardent les valeurs, champs `select NONE` compris | **Non activés** : une version détruite disparaît vraiment |
| Accès `BEARER`, `DEFINE API` | Révocation sans effet sur une connexion ouverte ; corps hors permissions | **Non utilisés** : identités machine par `lyxal_auth` |
| Compte système | Lit tout, export compris | La vraie protection est le scellement, clé hors base |

## 4. Sources écartées

| Source | Raison |
| :--- | :--- |
| Vault ou OpenBao comme service séparé | Second serveur à exploiter, desceller et sauvegarder ; identités, organisations et bus à refaire autour |
| RustyVault, petites crates de coffre-fort | Peu maintenues ; chiffrement maison ; le chiffrement doit passer par `lyxal_crypto` |
| Zéro connaissance (Bitwarden, Akeyless) | Le serveur ne pourrait ni tourner ni remettre les secrets aux modules |
| Clé découpée (Akeyless DFC) | Hors du périmètre de `lyxal_crypto` |

## 5. Décisions du CTO

| Programme | Décisions |
| :--- | :--- |
| Programme V1 (13 nov. 2026) | **K1** une clé par organisation ; **K2** rescellement de toutes les versions ; **V1** visibilité restreinte par défaut ; **V2** 10 versions ; **V3** suppression douce de 30 jours, protection contre la purge ; **V4** secret expiré refusé à la lecture ; **A1** approbations et accès temporaires dans la V1 ; **A2** partage à usage unique dans la V1 ; **M1** identités machine par `lyxal_auth` ; **H1** historique natif non activé ; **B1** aucune bascule de module dans ce programme |
| Lot 2 | **R1** clé maîtresse propre au coffre-fort (`LYXAL__SECRETS__MASTER_KEY`) |
| Lot 3 | **C1** rotateurs inscrits par les modules, sinon rappel ; **C2** 3 nouveaux essais, valeur en service jamais retirée ; **C3** urgence : version courante coupée ; **C4** une alerte par échéance ; **C5** rotation des clés d'organisation tous les 365 jours ; **C6** essai sans bascule |
| Lot 4 | **D1** portée : secret ou dossier ; **D2** accès toujours limité dans le temps ; **D3** `secrets.access.manage`, pas d'auto-approbation ; **D4** N approbations, un refus clôt, 7 jours ; **D5** changements protégés appliqués par l'auteur ; **D6** `secrets.access.emergency`, 1 heure ; **D7** événements |
| Lot 5 | **E1** routes HTTP au nom de l'appelant ; **E2** révélation avec double facteur ; **E3** copie d'un secret ou d'un texte ; **E4** clé dans le lien seulement ; **E5** ouverture par toute personne qui a le lien, ou réservée à l'organisation ; **E6** `secrets.share.create` ; **E7** aucune primitive nouvelle |
| Lot 6 | **F1** aucun accès à soi-même hors demande approuvée ou urgence ; **F2** vérification de la clé d'un partage par HMAC-SHA256 de `lyxal_crypto` ; **F3** procédures dans `PROCEDURES.md` |
