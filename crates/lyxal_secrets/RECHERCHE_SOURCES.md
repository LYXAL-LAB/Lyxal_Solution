# `lyxal_secrets` — recherche de sources

Étude préalable à la création du crate `lyxal_secrets` (rang 4 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md)) : ce que font les
meilleurs gestionnaires de secrets, offres payantes comprises, ce que SurrealDB 3.3.4 fournit, et
ce que le dépôt possède déjà. Le programme qui en découle est dans
[`implementation_plan.md`](../../implementation_plan.md).

Recherche du 13 novembre 2026. Documentations officielles lues en entier (téléchargées, puis
converties en texte), sauf Google Secret Manager, dont le site n'était pas joignable depuis
l'environnement : ses lignes viennent d'extraits de recherche et sont marquées « extrait ».
Le fonctionnement de SurrealDB a été **essayé** sur un serveur 3.3.4 (moteurs `memory`,
`rocksdb://`, `surrealkv://`).

## 1. Principe d'assemblage

* **Dépendance** : bibliothèque Rust prise telle quelle, licence permissive.
* **Modèle** : fonctionnement d'un produit étudié et transcrit (SurrealQL pour les données et les
  règles, Rust pour le chiffrement) ; aucun code repris d'un projet sous licence BUSL, GPL, AGPL
  ou propriétaire. S'inspirer d'une fonction payante, sans copier de code, est permis.
* Le chiffrement passe exclusivement par `lyxal_crypto` (§11.3) : aucune bibliothèque de
  chiffrement nouvelle n'est nécessaire.

## 2. Produits étudiés

| Produit | Licence | Rôle dans l'étude |
| :--- | :--- | :--- |
| HashiCorp Vault | BUSL 1.1 (Community) ; Enterprise propriétaire | **Modèle** : référence du marché |
| [OpenBao](https://openbao.org) 2.7 | MPL-2.0 (Linux Foundation) | **Modèle** : version libre de Vault, rattrape plusieurs fonctions Enterprise |
| [Infisical](https://infisical.com/docs) | cœur MIT, répertoire `ee/` sous licence commerciale | **Modèle** : plateforme moderne multi-organisations |
| [Doppler](https://docs.doppler.com) | propriétaire (service) | **Modèle** : ergonomie, visibilité restreinte |
| AWS Secrets Manager | propriétaire (service) | **Modèle** : versions par étiquettes, rotation |
| Google Secret Manager | propriétaire (service) | **Modèle** : états de version (extrait) |
| Azure Key Vault | propriétaire (service) | **Modèle** : suppression douce, protection contre la purge |
| Bitwarden Secrets Manager | propriétaire (service) ; clients open source | **Modèle** : comptes machine, journal |
| Akeyless | propriétaire (service) | **Modèle** : clé jamais complète (écarté, voir §6) |
| [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) | CC BY-SA | **Référentiel** : liste de contrôle (§5) |

## 3. Fonctions du marché

Colonne « Où » : **L** libre (Vault Community, OpenBao, offre gratuite), **P** payant (Vault
Enterprise, paliers payants d'Infisical ou Doppler), **S** service cloud. Colonne « Lyxal » :
lot du programme ou feuille de route (FdR).

### 3.1. Stockage et versions

| Fonction | Comportement de référence | Où | Lyxal |
| :--- | :--- | :- | :- |
| Versions | Vault et OpenBao KV v2 : 10 versions gardées par défaut (`max_versions`), la plus ancienne détruite au-delà ; durée de vie d'une version (`delete_version_after`) plafonnée par le réglage général. Infisical : versions en palier Pro | L, P | 1 |
| Écriture conditionnelle | KV v2 `cas` : l'écriture n'aboutit que si la version courante est celle attendue ; `cas=0` = créer seulement ; `cas_required` l'impose | L | 1 |
| Étiquettes de version | AWS : `AWSCURRENT` (toujours présente, lue par défaut), `AWSPENDING`, `AWSPREVIOUS`, jusqu'à 20 ; une étiquette sur une seule version ; revenir en arrière = déplacer l'étiquette | S | 1 |
| États de version | Google : activée, désactivée (réversible), détruite (irréversible) (extrait). Azure : `enabled` appliqué | S | 1 |
| Suppression en plusieurs temps | KV v2 : suppression douce, restauration, destruction d'une version, suppression de tout ; chaque opération a son propre droit | L | 1 |
| Fenêtre de récupération | AWS : 7 à 30 jours (30 par défaut). Azure : 7 à 90 jours (90 par défaut), fixée à la création ; protection contre la purge irréversible une fois activée ; purge = droit distinct | S | 1 |
| Retour à un état passé | Infisical : historique en « commits » par dossier ; annuler un changement ou revenir à un état, le retour étant lui-même un commit (palier Pro) | P | FdR |
| Métadonnées libres | KV v2 `custom_metadata` ; Infisical tags ; Doppler notes | L | 1 |
| Lecture des clés sans valeurs | KV v2 `subkeys` : structure d'un secret JSON, valeurs remplacées par `null` | L | 1 |
| Références entre secrets | Infisical, Doppler : `${env.KEY}` résolu à la lecture ; Doppler laisse le texte si la cible manque (risque signalé par sa documentation) | L | FdR |
| Taille maximale | AWS 64 Kio par valeur ; Azure 25 Ko | S | 1 |

### 3.2. Chiffrement et clés

| Fonction | Comportement de référence | Où | Lyxal |
| :--- | :--- | :- | :- |
| Chiffrement par enveloppe | AWS : clé de données AES-256 neuve à chaque valeur, chiffrée par la clé maîtresse ; contexte lié `{SecretARN, SecretVersionId}` : une valeur copiée ailleurs ne se déchiffre pas | S | 2 |
| Clés par organisation | Infisical : clé racine (environnement ou HSM) → clé interne → **une clé par organisation et par projet** (« isolation cryptographique entre locataires ») ; AES-256-GCM, nonce de 96 bits | L | 2 |
| Rotation de la clé maîtresse | AWS : seules les versions étiquetées sont rechiffrées, les autres restent lisibles par l'ancienne clé. Vault : rotation en ligne, anciennes clés gardées en lecture ; `rewrap` remet un chiffré à niveau sans exposer le clair ; version minimale de déchiffrement | L, S | 2 |
| Organisation « scellable » | OpenBao 2.6 : clés propres par espace, l'espace peut être scellé (clés jetées de la mémoire), y compris contre l'opérateur | L | FdR |
| Clé externe (KMS, HSM) | Infisical Enterprise, OpenBao 2.7 « External Keys » | P, L | FdR |

### 3.3. Accès

| Fonction | Comportement de référence | Où | Lyxal |
| :--- | :--- | :- | :- |
| Refus par défaut, droits par opération | Vault : `create`, `read`, `update`, `patch`, `delete`, `list`, `deny` prioritaire, portée par chemin avec jokers. Azure : lire la valeur ≠ lire les métadonnées ; écrire, supprimer, récupérer, purger, sauvegarder, restaurer sont distincts | L, S | 1 |
| Visibilité « restreinte » | Doppler : valeur jamais relisible par un humain après enregistrement, lisible seulement par un jeton de service ; revenir à une visibilité moins stricte oblige à changer la valeur | S | 1 |
| Accès temporaire | OpenBao 2.3 : expiration d'une politique ou d'un chemin. Infisical : privilège à durée limitée (Advanced) | L, P | 4 |
| Demande d'accès approuvée | Infisical : demande, étapes d'approbation, durée maximale, révocation immédiate (Enterprise) | P | 4 |
| Approbation des changements | Infisical, Doppler : N approbateurs, auto-approbation réglable, contournement d'urgence tracé et notifié | P | 4 |
| Groupes de contrôle | Vault Enterprise, OpenBao 2.7 (libre) : la requête est mise en attente jusqu'à N approbations d'un groupe ; OpenBao ne notifie pas les approbateurs | P, L | 4 |
| Identités machine | Bitwarden : compte machine, droit lecture ou lecture-écriture par projet, jeton montré une fois. Infisical : TTL, nombre d'usages, plages IP | L, S | 1 (par `lyxal_auth`) |
| Remise à usage unique | Vault : réponse enveloppée dans un jeton à usage unique ; s'il a déjà été ouvert, l'ouverture échoue et la documentation demande une alerte. Infisical : lien de partage avec expiration (5 min à 30 j), nombre de vues, mot de passe | L | 5 |

### 3.4. Cycle de vie

| Fonction | Comportement de référence | Où | Lyxal |
| :--- | :--- | :- | :- |
| Expiration | Google : suppression à l'échéance (extrait). Azure : `nbf` et `exp` **informatifs** (la lecture d'un secret expiré fonctionne). OWASP : « vérifier que le secret est encore actif avant de lui faire confiance » | S | 3 |
| Rotation en quatre étapes | AWS : créer la version `AWSPENDING` (idempotent), l'installer chez le service cible, la tester, puis déplacer `AWSCURRENT` (l'ancienne devient `AWSPREVIOUS`) | S | 3 |
| Rotation à deux jeux | Infisical, Doppler, AWS « deux utilisateurs » : deux identifiants valides en alternance, aucune coupure | P, S | 3 |
| Notifier plutôt que tourner | Google : publie « rotation due », la rotation est faite par le consommateur (extrait) | S | 3 |
| Événements | Azure : `SecretNewVersionCreated`, `SecretNearExpiry` (30 j avant), `SecretExpired`. Vault : événements Enterprise seulement | S, P | 3 |
| Rappels et retards | Infisical « Insights », Doppler « Secret Health » | P | 3 |
| Secrets dynamiques | Vault, OpenBao, Infisical (Advanced), Doppler (Enterprise) : identifiant créé à la demande avec bail, détruit à l'échéance | L, P | FdR |
| Synchronisation vers l'extérieur | Vault Enterprise, Infisical : copie vers AWS, Azure, GitHub… | P | FdR |

### 3.5. Journal

| Fonction | Comportement de référence | Où | Lyxal |
| :--- | :--- | :- | :- |
| Journal de chaque lecture | Bitwarden : « accessed a secret » horodaté, conservé sans limite. Doppler ne garde que le premier et le dernier accès d'un acteur | S | 2 |
| Journal bloquant | Vault, OpenBao : si aucune trace ne peut être écrite, la requête est refusée | L | 2 |
| Aucune valeur dans le journal | Vault : valeurs remplacées par un HMAC-SHA256 salé, fonction de comparaison `/sys/audit-hash` | L | 2 |
| Journal infalsifiable | OWASP 2.6 : résistant à la modification et à la suppression | — | 1, 2 |
| Rétention, flux vers un SIEM | Infisical : 30 j (Pro), 90 j (Advanced), flux Datadog ou Splunk (Enterprise) | P | FdR |

## 4. SurrealDB 3.3.4 (essais)

| Capacité | Constat | Usage dans `lyxal_secrets` |
| :--- | :--- | :--- |
| Chiffrement | **Aucun** : ni fonction de chiffrement ou de HMAC en SurrealQL, ni chiffrement des fichiers sur disque (une valeur écrite se retrouve en clair dans les fichiers RocksDB et SurrealKV ; `SURREAL_KEY` « not currently in use »). Le chiffrement de SurrealKV 1.0 est annoncé pour SurrealDB 4 | Tout est scellé en Rust par `lyxal_crypto` avant écriture |
| Champ en écriture seule | `PERMISSIONS FOR select NONE` : un utilisateur peut écrire, jamais relire, ni par `WHERE`, ni par une fonction, ni par `LIVE SELECT` ; la session système de l'hôte le lit | Enveloppe scellée, deuxième barrière |
| Champs figés, valeur calculée | `READONLY`, `VALUE`, `ASSERT` appliqués à tous, système compris | Propriétaire, numéro de version, format `enc:v2:` |
| Déclencheurs | `DEFINE EVENT` s'exécute sans contrôle de droits, `$auth` reste l'auteur ; un `THROW` annule l'écriture | Journal des écritures, verrous |
| Journal en ajout seul | Table `FOR create, update, delete NONE` alimentée par un déclencheur : inviolable pour un utilisateur ; **modifiable par un utilisateur système** | Journal chaîné (`fn::security_audit_entry`) pour détecter une modification |
| Lectures | Aucun déclencheur sur une lecture | Journal des lectures tenu par le service Rust |
| Historique natif (`VERSION`) | Refusé par défaut ; avec `versioned=true`, une valeur supprimée reste lisible pendant la rétention | **Non utilisé** : versions tenues par le module |
| `CHANGEFEED` | Contient les valeurs complètes, champ `select NONE` compris | **Non activé** sur les tables du module |
| Accès `BEARER` | Clé montrée une fois ; une révocation **ne coupe pas** une connexion déjà ouverte ; jeton inutilisable en HTTP | **Non utilisé** : identités machine par `lyxal_auth` (applications, clés d'API) |
| `DEFINE API` | Son corps ignore les permissions | **Non utilisé** pour ouvrir un secret |
| Compte système | Tout compte système (même `VIEWER`) lit les champs `select NONE`, l'export et les fichiers | La vraie protection est le scellement, clé hors base |
| Audit natif | Enterprise seulement | Journal du module |

## 5. Liste de contrôle OWASP (lecture intégrale de la fiche)

| § OWASP | Exigence | Réponse du programme |
| :--- | :--- | :--- |
| 2.3, 6.3 | Moindre privilège, droits fins par objet, limiter qui lit ou écrit | Droits par opération, portée par chemin, visibilité restreinte (lot 1), accès temporaires (lot 4) |
| 2.5 | Réduire le temps en clair, mise à zéro, pas de chaîne immuable | `SecretBytes` / `SecretString` de `lyxal_crypto` (effacés à la libération) |
| 2.6 | Journal résistant à la falsification : qui a demandé quoi, accordé ou refusé, usage, expiration, réutilisation d'un secret expiré, erreurs d'authentification et de droits, mises à jour, administration ; horodatage exact | Journal chaîné de toutes les opérations, lectures et refus compris (lots 1, 2) |
| 2.7 | Création robuste, rotation, révocation, expiration ; vérifier qu'un secret est actif | Génération par `lyxal_crypto` (`OsRng`), expiration appliquée, rotation (lot 3) |
| 2.9 | Sauvegarde chiffrée et testée ; identifiants d'urgence dans un second gestionnaire | Sauvegarde de la base (valeurs scellées) ; clé maîtresse hors base, procédure écrite (lot 6) |
| 2.11 | Métadonnées : création, usage, rotation, suppression (quand, par qui), contact, consommateurs, type | Champs obligatoires de la fiche (lot 1) |
| 6.4 | Surveiller qui, d'où, comment ; une adresse inattendue fait supposer une compromission | Adresse et type de session au journal (lot 2) |
| 7.1 | Chiffrement authentifié (AES-256-GCM) | `lyxal_crypto` `enc:v2` |
| 7.3, 4.2.2 | Clé jamais à côté des secrets, sauf chiffrée elle-même (enveloppe) | Clé maîtresse dans l'environnement de l'hôte ; clés d'organisation scellées par elle (lot 2) |
| 8.3 | Tracer les tentatives d'usage d'un secret révoqué ; jamais de valeur au journal | Refus journalisés, valeurs jamais écrites |
| 9.2 | Révoquer tout de suite, remplacer vite, savoir qui avait accès, quand il a servi, dernière rotation | Désactivation immédiate d'une version, rotation manuelle, requêtes sur le journal |

La fiche ne traite pas du multi-organisations ; l'isolation par organisation vient d'Infisical
(§3.2).

## 6. Sources écartées

| Source | Raison |
| :--- | :--- |
| Reprendre Vault ou OpenBao comme service séparé | Un second serveur à exploiter, desceller et sauvegarder, une seconde gestion des identités ; l'isolation par organisation, les droits `lyxal_auth` et le bus `lyxal_event` seraient à refaire autour. Les deux restent les modèles principaux |
| RustyVault | Dernière version d'octobre 2025, chiffrement maison |
| Petites crates Rust de coffre-fort | Peu maintenues, et le chiffrement doit passer par `lyxal_crypto` |
| Zéro connaissance (Bitwarden, Akeyless) | Le serveur ne pourrait ni tourner ni générer de secrets, ni les remettre aux modules (notifications, connexions) qui en ont besoin |
| Clé découpée (Akeyless DFC) | Demande plusieurs détenteurs de fragments ; hors du périmètre de `lyxal_crypto` |
| Accès `BEARER`, `VERSION`, `CHANGEFEED`, `DEFINE API` de SurrealDB | Voir §4 |

## 7. Ce que le dépôt fournit déjà

| Brique | Où | Usage |
| :--- | :--- | :--- |
| Scellement AES-256-GCM, contexte lié non vide, enveloppe `enc:v2` | `lyxal_crypto` (`CryptoEngine::seal`, `open`, `SecretContext::with_tenant`) | Chaque version |
| Rotation de clé et remise à niveau | `lyxal_crypto` (`KeyRing`, `activate`, `revoke`, `CryptoEngine::reencrypt_if_needed`) | Worker de rescellement |
| Clé maîtresse | Hôte : `LYXAL__CRYPTO__APPLICATION_KEY` (`EnvironmentKeyProvider`) | Racine du trousseau |
| Types effacés de la mémoire | `SecretBytes`, `SecretString` | Valeurs ouvertes |
| Génération, masquage, robustesse d'un secret | `lyxal_core` `fn::security_secret_generate`, `_mask`, `_strength` | Métadonnées, aperçu masqué |
| Journal chaîné et sa vérification | `lyxal_core` `fn::security_audit_entry`, `fn::security_audit_verify` | Journal du module |
| Identités, droits, niveau d'assurance | `lyxal_auth` (`fn::auth_has_permission`, `fn::auth_assurance_check`, applications et clés d'API) | Contrôle de chaque opération ; double facteur exigé pour révéler une valeur |
| Bus d'événements | `lyxal_event` (`fn::event_publish`) | Événements `secrets.*`, sans valeur |
| Solution d'attente | `lyxal_notification` `SecretCodec` (secrets portés par les événements) | Reste en place : secrets en transit, pas en stock |

Modules qui attendent `lyxal_secrets` : `lyxal_notification` (fournisseurs par organisation,
lot V1-e ; secrets de signature des webhooks, V2), `lyxal_connect` (jetons OAuth, à créer),
`lyxal_storage` (identifiants des supports, feuille de route).

## 8. Non vérifié

* Google Secret Manager : site non joignable ; rotation, ETag et destruction différée viennent
  d'extraits.
* Infisical : nom exact de la licence du cœur et frontière précise avec `ee/` ; le partage de
  secret chiffré côté serveur est déduit de son API.
* OpenBao : absence d'événements constatée par l'absence de page, sans déclaration explicite.
* SurrealDB : purge effective du `CHANGEFEED` et des versions après la rétention ; chiffrement de
  SurrealKV 1.0 dans le binaire 3.3.4.
