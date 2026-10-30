# Mandat CTO — audit consolidé et architecture cible de lyxal_crypto

Date : 30 octobre 2026. Révision du plan : **A-R2 — intégration des révisions CTO R1 à R5**. État : **PHASE B AUTORISÉE PAR MANDAT CTO DU 30 OCTOBRE 2026 — L0 INTÉGRÉ ; EXÉCUTION SOUS CONDITIONS DU MANDAT**.

Révision auditée : `0cb758c6f47dfd68c549787fa6eb24a3dd40338d`, crate `0.1.0`.
Ce document est le seul fichier du dépôt créé puis révisé pendant cette phase. Il ne décrit pas des correctifs déjà réalisés. La présente révision ne relance pas l'audit général : les résultats des §3 et §5 sont historiques ; seuls la cohérence de la spécification et ses vecteurs indépendants sont vérifiés. Aucun code ni test du crate n'est exécuté dans cette révision.

## 1. Périmètre audité et position dans le graphe

### 1.1 Autorité, périmètre et exceptions

Références normatives : `.agents/AGENTS.md` §3, §5.2, §5.7, §6 ; `.agents/rules/lyxal_standards_and_checklist.md` §11.3, §12.3, §13 ; compétence `.agents/skills/lyxal-audit/SKILL.md`, notamment son contrôle 2 relatif aux fondations.

Le mandat CTO transmis dans cette conversation autorise la création du présent plan et, après une approbation distincte, une refonte interne à `crates/lyxal_crypto/**`. Il autorise explicitement les ruptures d'API et de format avant la première production. Cette instruction particulière prime ici sur la conservation des signatures figées ; elle n'autorise aucune modification de `.agents`.

La validation conditionnelle ultérieure confirme les orientations, mais demande R1 (protocole complet), R2 (cycle des clés), R3 (limites), R4 (persistance), R5 (types sensibles). **Cette restriction concernait la révision A-R2 ; le mandat de phase B autorise désormais les lots et la modification minimale de Cargo.lock pour les dépendances identifiées.** Le contrat Rust cible est nommé **API V1 de production** ; il utilise le protocole **enc:v2 / AAD V2**. Ces numéros décrivent deux couches distinctes ; aucun changement de version Cargo n'est implicite.

`lyxal_crypto` reste une fondation Rust autonome. Il n'acquiert aucune dépendance vers `lyxal_runtime`, `lyxal_surreal`, SurrealDB, un module métier ou un fournisseur cloud. Aucun schéma, DTO métier, fonction SurrealQL, `LyxalModule`, worker ou événement n'est requis pour ce chantier. Son manifeste technique est `Cargo.toml` ; l'absence de `manifest.toml` de module installable n'est pas un défaut de cette fondation.

Consultation du Core : `crates/lyxal_core/Readme.md` et ses répertoires `functions/validations`, `sanitize`, `security`, `utils`. Il s'agit de primitives SurrealQL ; aucune responsabilité native de manipulation de mémoire secrète, d'AEAD ou de publication atomique de fichier ne doit y être déplacée. Fonctions Core réutilisées : aucune nécessaire. Fonctions métier nouvelles : aucune. Primitive Core manquante : aucune identifiée pour cette mission. Les validations décrites ci-dessous portent sur les protocoles cryptographiques eux-mêmes.

### 1.2 Inventaire inspecté

- Sources : `src/lib.rs`, `cipher.rs`, `context.rs`, `envelope.rs`, `error.rs`, `hash.rs`, `hmac.rs`, `kdf.rs`, `key.rs`, `key_resolver.rs`, `password.rs`.
- Tests : `aes_gcm_vectors.rs`, `encryption.rs`, `envelope_v1_fixtures.rs`, `fuzz_robustness.rs`, `hash_vectors.rs`, `hmac_vectors.rs`, `kdf_vectors.rs`, `key_generation.rs`, `key_resolver.rs`, `negative_tests.rs`, `password_tests.rs`, `proptests.rs`, `rotation_lifecycle.rs`.
- Contrats : `Cargo.toml`, `API_CONTRACT.md`, `SECURITY.md`, `ENVELOPE_FORMAT_V1.md`, `README.md`, `roadmap.md`.
- Contexte en lecture seule : manifestes et lockfile racines ; usages de secrets dans Booking ; configuration et sources locales des dépendances RustCrypto pertinentes.

Architecture actuelle : un moteur générique `CryptoEngine<R: KeyResolver>`, deux voies liées/non liées, des clés encapsulées, des fournisseurs environnement/fichier, un trousseau mutable et des fonctions libres pour hachage, HMAC, HKDF et Argon2. Les primitives sont déléguées à RustCrypto ; la majorité des défauts concerne leurs contrats d'utilisation et leur cycle de vie.

## 2. Synthèse exécutive et verdict

**Verdict actuel : NON CONFORME — écarts P0/P1 bloquant une validation de production.**

La graduation P0/P1/P2 suit la compétence locale d'audit : P0 signifie violation bloquante d'un invariant architectural ou de sécurité, et non nécessairement vulnérabilité distante critique au sens CVSS. La gravité opérationnelle et les conditions d'exploitation sont précisées séparément.

Décisions proposées : conserver les primitives éprouvées ; rendre les secrets et leurs accès explicites ; adopter une enveloppe `enc:v2` et un AAD `lyxal:v2` authentifiant aussi les métadonnées ; supprimer le tenant implicite et les normalisations destructrices ; utiliser des instantanés cohérents de trousseau ; borner les entrées avant allocation et calcul coûteux ; distinguer publication atomique, durabilité et confiance dans le répertoire de stockage.

Ce plan ne qualifie ni l'existant ni la cible non implémentée de « production-ready ». La validation du crate, l'adaptation de ses consommateurs et l'admission d'une infrastructure en production sont trois décisions distinctes.

## 3. Écarts constatés et preuves

Légende : **R** = reproduit avec données exclusivement fictives ; **L** = démontré par lecture du code/configuration ; **H** = hypothèse ou limite non vérifiée. Les lignes réfèrent à la révision auditée.

| ID / niveau | Référence et preuve | Cause et impact | Correction et non-régression prévues |
|---|---|---|---|
| A01 P0, élevée, R | `src/lib.rs:28-31` ; `format!("{:?}", SecretString::new("FAKE-AUDIT-SECRET".into()))` affiche `Zeroizing("FAKE-AUDIT-SECRET")`. `SecretBytes` affiche les octets. §12.3. | Un alias hérite de `Debug` de `Zeroizing`, qui ne masque pas son contenu. Fuite accidentelle dans les logs ; aucune fuite effective en exploitation n'est alléguée. | Structures opaques, `Debug` masqué, pas de `Display` révélateur ni de sérialisation implicite ; tests des deux types, des structures englobantes et des erreurs. |
| A02 P0, élevée, R | `src/key_resolver.rs:254-260` ; ajouter une clé historique avec l'ID actif réussit ; un ciphertext antérieur devient indéchiffrable. §11.3. | `HashMap::insert` remplace sans contrôle. Même risque pour un ID historique ; erreur d'administration pouvant rendre les données inaccessibles. | Rejeter tout ID dupliqué sans muter l'état ; tests doublon actif/historique et invariance du trousseau après erreur. |
| A03 P1, moyenne, R+L | `src/key_resolver.rs:191-225` ; **30 erreurs sur 640 résolutions** dans un essai de 40 démarrages de 16 fournisseurs indépendants, chacun partageant un fichier initialement absent. | `create_new` rend le nom visible avant `write_all`; lecteurs concurrents voient un contenu incomplet. `RwLock` ne synchronise qu'une instance. | Publication d'un fichier entièrement écrit, sans remplacement ; tests multiprocessus, lecteurs concurrents, interruptions à chaque étape. Le nombre observé est propre à cet essai, pas une probabilité générale. |
| A04 P1, moyenne, R | `src/lib.rs:143-151` ; altération d'un octet ou contexte incorrect => `Ok(Current)` si ID actif ; `decrypt_secret` rejette correctement les deux. | Retour anticipé fondé sur une métadonnée non authentifiée. Un outil de migration peut confondre « ID actuel » et « enveloppe valide ». Ce n'est pas un contournement du déchiffrement AES-GCM. | Authentifier avant toute réponse de rotation ; tests `Current` invalide, clé absente/révoquée, contexte incorrect et idempotence. |
| A05 P1, moyenne, L | `src/key_resolver.rs:61-62,149-151` ; chaînes Base64 en `String` ordinaire ; `key.rs:71-80`, `kdf.rs:23-25` créent des tableaux avant leur enveloppement. | Certaines copies sensibles échappent à l'effacement explicite ; persistance exacte en mémoire non mesurée. | Protéger les allocations dès leur création, réduire conversions/copies, auditer erreurs et dépendances ; documenter limites de compilation et mémoire. |
| A06 P1, faible à moyenne, R | `src/password.rs:60-90` ; `needs_rehash("$argon2id$v=19$m=65536,t=3,p=1") == false`. Même résultat avec un sel décodé de cinq octets. | Paramètres seuls contrôlés ; sel/digest non validés. Diagnostic trompeur, sans authentification accordée pour un hash absent. | Type PHC valide et borné ; rehash seulement sur ce type ; tests éléments manquants, sel/digest insuffisants et versions/paramètres. |
| A07 P0 conditionnel, élevée si identifiants métier sensibles à la casse, R | `src/context.rs:46-50,78-83` ; tenants `Acme`/`acme` et records `" id "`/`"id"` produisent le même AAD ; déchiffrement croisé réussi. | Normalisation documentée dans V1 mais non injective sur les identifiants fournis. Exploitabilité réelle dépend du contrat d'identité des consommateurs, non audité exhaustivement. | Contrat V2 exact, rejet des formes interdites sans transformation ; tests négatifs casse, espaces, Unicode et chaque champ du contexte. |
| A08 P1, moyenne conditionnelle, R | `src/lib.rs:84-89,104-107` ; même matériel importé sous `active` et `alias` : modifier uniquement `key_id` laisse le déchiffrement réussir. | Le key ID n'est pas dans l'AAD. Pas de récupération de plaintext sans clé ; altération de provenance et de décision de rotation possible en présence d'alias. | Authentifier version, suite, key ID et mode dans V2 ; test de réétiquetage avec matériel identique. |
| A09 P1, moyenne, R+L | `src/key_resolver.rs:149-157` ; fournisseur strict accepte un fichier `0644` et un lien symbolique vers un fichier de clé fictive. `write_all` puis `flush` sans `sync_all` à 217-218. | Les contrôles de fichiers existants diffèrent de la création 0600. Atomicité/durabilité non assurées par `flush`. Perte lors de panne électrique : L, non reproduite. | Politique de stockage explicite, fichiers réguliers protégés, lecture bornée, contrôles de liens et répertoire de confiance ; synchronisation fichier/répertoire et limites de plateforme. |
| A10 P1, moyenne conditionnelle, L | `src/password.rs:45-50` ; `Argon2::verify_password` reprend les paramètres PHC. Dépendance `argon2 0.5.3`, `lib.rs:230-232` alloue `vec![Block; block_count]`. | Pas de budget local m/t/p avant calcul ; hash hostile/corrompu peut provoquer mémoire/CPU excessifs. Aucun essai destructif avec coût extrême exécuté. | Parser/borner PHC et coûts avant Argon2, bornes de mot de passe ; tests de rejet sans invoquer le calcul coûteux. Admission/concurrence globale à l'hôte. |
| A11 P1, moyenne conditionnelle, L | `src/envelope.rs:71-74`, `hmac.rs:33`, `key_resolver.rs:150`, champs de contexte non bornés. | Décodage/lecture/allocation proportionnels à une entrée hostile sans maximum métier/protocolaire. Le test « giant » n'utilise que 10 000 caractères et ne mesure aucune borne. | Maximums protocolaires explicites et contrôles avant allocation ; tag HMAC hex exactement 64 caractères décodés dans un tableau. |
| A12 P1, moyenne conditionnelle, R | `src/key.rs:17,21`, `error.rs:12-13,24-25` ; erreur de clé contient `FAKE-SECRET\nFORGED-LOG` fourni en entrée. | Réflexion de données arbitraires dans `Debug`/`Display`, risque de contenu sensible et injection de ligne si journalisation naïve. | Erreurs structurées sans reprise de l'entrée ; tests sentinelles et caractères de contrôle sur tous les échecs. |
| A13 P1, disponibilité, L | `src/key.rs:79`, `cipher.rs:18`, `password.rs:33` ; `rand_core 0.6.4/src/os.rs:62-63` panique quand `try_fill_bytes` échoue. | API aléatoire infaillible apparente ; panne CSPRNG => panic plutôt qu'erreur typée. Échec OS non provoqué. | `try_fill_bytes`, sel construit à partir de bytes protégés, erreur `RandomUnavailable`, injection privée de défaillance en test uniquement. |
| A14 P1, garantie mémoire, L | `Cargo.toml` + `cargo tree -e features` : aucune activation `aes/zeroize`, `aes-gcm/zeroize`, `argon2/zeroize`. Argon2 alloue un workspace ordinaire. | La protection de `EncryptionKey` n'étend pas automatiquement l'effacement aux schedules, états GHASH ou 64 Mio de workspace Argon2. | Examiner/activer les features adaptées, workspace Argon2 explicitement possédé et effacé ; périmètre lockfile séparé §7.9. Pas de promesse d'effacement de tous les backends. |
| A15 P2, qualité, L | `tests/envelope_v1_fixtures.rs:45-63,88-98` recalculent le ciphertext avec la bibliothèque et l'AAD en cours. | Faux oracle historique : une évolution coordonnée peut passer sans préserver une enveloppe antérieure. Le test AAD littéral distinct couvre deux cas mais pas l'enveloppe entière. | Fixtures littérales V2 avec provenance, clé/nonce/plaintext/AAD/output exacts ; V1 identifié comme historique et rejeté explicitement par V2. |
| A16 P1, contrat d'outillage, L | `rust-version.workspace = true` => 1.80 ; versions verrouillées de `base64ct 1.8.3`, `zeroize 1.9.0`, `zeroize_derive 1.5.0`, `constant_time_eq 0.4.2`, `cpufeatures 0.3.1` déclarent 1.85. | MSRV annoncé incompatible avec les dépendances verrouillées. Pas de compilation sous 1.80 pendant cet audit. | Déclarer un MSRV local explicite à confirmer (candidat 1.85), tester ce MSRV et le toolchain courant ; aucun changement de la racine. |

### 3.1 Points de conception, sans vulnérabilité confirmée

- HMAC accepte une clé vide : reproduit, comportement correct de la primitive mais API trop permissive pour l'usage applicatif cible. Prévoir une clé HMAC dédiée de 32 octets. Les vecteurs RFC à clés courtes restent vérifiés au niveau interne.
- `sign_hmac_sha256` contient un `expect` dont la condition d'erreur est inatteignable pour HMAC-SHA256 avec la bibliothèque actuelle : écart à la règle locale d'absence d'`expect`, pas preuve d'un panic exploitable. Remplacer par propagation explicite.
- Le test `key_generation.rs:6-28` vérifie une erreur `KeyNotFound` entre IDs différents : il ne prouve pas que deux clés différentes sous le même ID échouent à authentifier. Ajouter ce cas.
- Les modes global et tenant n'autorisent pas la réutilisation du même secret entre domaines dans la cible. L'API actuelle à AAD vide est un risque d'usage, pas une faille intrinsèque d'AES-GCM.
- Rejeu d'une ancienne enveloppe valide au même emplacement, choix d'un faux tenant par un appelant compromis, vol de clé, contrôle total de la mémoire et attaques physiques restent hors de la garantie locale. Aucun test actuel ne prouve une résistance à ces scénarios.
- L'AAD V1 préfixé par longueurs est non ambigu sur les valeurs *déjà normalisées*. Ne pas confondre A07 avec une collision de son encodage.
- Aucun compteur distribué de nonces ni révocation globale ne peut être garanti par une bibliothèque synchrone en mémoire. Pas d'ajout d'un ordonnanceur ni de dépendance runtime pour le simuler.

## 4. Correspondance DTO Rust / SurrealQL

| Fonction SurrealQL | Struct Rust | Champs conformes/absents/supplémentaires/incompatibles |
|---|---|---|
| Sans objet : aucune fonction, table ni requête SurrealQL dans ce crate de fondation | Aucun DTO métier attendu | Sans objet, conformément au contrôle 2 de la compétence d'audit |

Les types proposés sont des contrats Rust natifs. Aucune master data d'erreur SurrealQL ni fonction `$params` n'est créée. `CryptoError` reste le contrat d'erreur local ; un éventuel mapping métier appartient aux couches supérieures.

## 5. Vérifications réalisées et points non vérifiés

### 5.1 Exécution réelle

Environnement de contrôle : Linux x86_64, Rust 1.99.1 ; variables `RUSTUP_HOME=/workspace/.lyxal-tools/rustup`, `CARGO_HOME=/workspace/.lyxal-tools/cargo`, PATH correspondant, `CARGO_BUILD_JOBS=3`, `CARGO_PROFILE_DEV_DEBUG=0`, `CARGO_PROFILE_TEST_DEBUG=0`.

Commande historique depuis la racine : `cargo test --offline --locked -p lyxal_crypto`. **Exécution de l'audit initial : 48 tests réussis, dont 4 doctests, code 0**. Ce résultat n'est pas une nouvelle exécution pendant la révision A-R2 et ne valide pas une implémentation V2. Aucun test de correction cible n'existe encore.

Sondes externes au code du dépôt, compilées contre son rlib, avec clés et secrets fictifs : A01/A02/A04/A06 et A07/A08/A09/A12 reproduits. La sonde concurrente crée puis supprime ses propres fichiers temporaires ; aucune clé existante ni donnée utilisateur n'est lue. Ces sondes sont des preuves d'audit, pas des tests de non-régression livrés. Les futurs tests persistants sont prévus dans le crate.

Résultats synthétiques :

```text
SecretString Debug: Zeroizing("FAKE-AUDIT-SECRET")
SecretBytes Debug: Zeroizing([70, 65, 75, 69])
Wrong-context decrypt rejected: true
Wrong-context reencrypt: Ok(Current)
Tampered reencrypt: Ok(Current)
Old secret decryptable after historical add with active ID: false
Hash without salt/digest needs rehash: false
Distinct caller identities share AAD: true
Cross-normalized decryption accepted: true
Key-ID relabeling accepted with same material: true
Short-salt PHC considered current: true
World-readable key file accepted: true
Symlink key file accepted: true
Concurrent fresh provider failures over 640 calls: 30
```

### 5.2 Dépendances

`cargo tree --offline --locked -p lyxal_crypto -e features` et `-e normal --prefix none` exécutés avec succès. Principales versions de production : AES 0.8.4, AES-GCM 0.10.3, GHASH 0.5.1, POLYVAL 0.6.2, Argon2 0.5.3, password-hash 0.5.0, rand_core 0.6.4/getrandom 0.2.17, zeroize 1.9.0, base64 0.22.1, SHA-2 0.10.9, BLAKE3 1.8.7, HMAC 0.12.1, HKDF 0.12.4.

Lecture officielle de la base RustSec au commit `2295466c4e9df26647fd67d8fa1c705ac2fc7f81`, obtenue via `git ls-remote https://github.com/RustSec/advisory-db.git HEAD`, puis archive de ce SHA sur `codeload.github.com`. Filtrage de 42 noms de paquets du graphe de production ; huit avis candidats trouvés et plages examinées :

| Avis | Paquet / installé | Plage corrigée applicable |
|---|---|---|
| RUSTSEC-2023-0096 | aes-gcm 0.10.3 | >=0.10.3 |
| RUSTSEC-2017-0004 | base64 0.22.1 | >=0.5.2 |
| RUSTSEC-2019-0019 | blake2 0.10.6 | >=0.8.1 |
| RUSTSEC-2020-0146 | generic-array 0.14.7 | >=0.13.3 |
| RUSTSEC-2019-0035 | rand_core 0.6.4 | >=0.4.2 |
| RUSTSEC-2021-0023 | rand_core 0.6.4 | >=0.6.2 |
| RUSTSEC-2021-0100 | sha2 0.10.9 | >=0.9.8 |
| RUSTSEC-2021-0115 | zeroize_derive 1.5.0 | >=1.1.1 |

Aucun de ces avis ne touche les versions de production examinées. Il s'agit d'une consultation ciblée de la base et de ses plages, **pas d'une exécution de cargo-audit**, ni d'une preuve d'absence de vulnérabilités inconnues, de paquets malveillants ou de problèmes dans les dépendances de test.

### 5.3 Non exécuté / non établi

- `cargo audit --version` : commande absente. Un scan automatisé complet, incluant les dépendances de développement, reste requis en phase B.
- Clippy et rustfmt ne figurent pas parmi les composants installés constatés ; aucun succès Clippy/fmt n'est revendiqué ici. Ils sont requis pour la cible.
- Pas de compilation MSRV 1.80/1.85, Windows, macOS, ARM, Miri, sanitizers ni exécution de fuzzing guidé par couverture.
- Pas de panne électrique réelle, démonstration de durabilité après perte de machine, certification, audit constant-time matériel, audit des consommateurs complet ou test de révocation distribuée.
- SurrealDB 3.2.0 : sans objet pour cette fondation ; aucune compatibilité base de données n'est revendiquée.

## 6. Éléments conformes et modèle de menaces cible

### 6.1 Éléments validés dans l'existant

RustCrypto assure AES-256-GCM et la comparaison des tags ; nonces de 12 octets issus d'OsRng ; erreurs d'authentification pour tag/nonce/contexte modifiés ; KeyId limité à l'ASCII et 64 octets ; clé AES non clonable/non sérialisable avec `Debug` masqué ; buffers déchiffrés enveloppés dans `Zeroizing` ; HMAC `verify_slice` ; profil Argon2id m=65536 KiB, t=3, p=1 ; tests de vecteurs et de propriétés effectivement exécutés. Sources : `cipher.rs`, `key.rs`, `context.rs`, `hmac.rs`, `password.rs` et suites correspondantes.

### 6.2 Actifs, adversaires, frontières de confiance

Actifs : clés maître et historiques, plaintexts, dérivés de clés, mots de passe, PHC, intégrité des métadonnées et états de rotation, disponibilité du processus.

Adversaires : fournisseur d'enveloppes/PHC malformés ; lecteur/éditeur du stockage applicatif sans clé ; tenant tentant une substitution ; acteur ayant accès aux logs ; utilisateur local non privilégié sans droit sur le répertoire privé de clés. Un appelant autorisé peut aussi commettre une erreur de configuration. Une compromission complète du processus, de root/administrateur, de la chaîne de compilation ou de l'hôte n'est pas résolue par le crate.

Frontières : entrées non fiables -> parseurs bornés ; identité métier autorisée -> contexte fourni par l'hôte ; fournisseur de clé -> trousseau ; filesystem privé -> clé ; AEAD -> sortie déchiffrée ; sortie d'erreur -> logs. Un parser n'authentifie jamais une enveloppe. Le crate n'autorise pas l'accès métier à un tenant.

| Menace | Garantie locale cible | Responsabilité externe / limite |
|---|---|---|
| Fuite dans les logs/erreurs | `Debug` masqué, pas de `Display`/Serde secret, erreurs sans entrée reflétée | Après `expose_secret`, l'appelant peut copier ou journaliser le secret |
| Substitution tenant/record/field/usage | AAD injectif et exact, cas négatifs, mode global séparé | L'hôte choisit un contexte issu de l'identité authentifiée ; pas d'autorisation implémentée ici |
| Falsification et réétiquetage de clé | AEAD authentifie contenu + nonce + suite/version/key ID/contexte | Rejeu au même contexte non empêché ; révision métier/anti-rollback à l'hôte |
| Réutilisation/collision de nonce | CSPRNG 96 bits, erreur OS propagée, pas de nonce fourni publiquement | Budget cumulatif par matériel de clé sur toutes les machines ; pas de garantie déterministe d'unicité |
| Collision/retrait de clés | IDs non remplaçables, snapshots cohérents, statut decrypt-only/révoqué | Conservation/sauvegarde des historiques, distribution des snapshots, arrêt des anciens processus |
| Course, interruption, corruption fichier | Publication sans remplacement, lecture bornée, contrôles Unix, sync et échec fermé | Répertoire parent privé géré par l'administrateur ; filesystem local validé, pas NFS/SMB implicite |
| Épuisement CPU/RAM | Bornes fixes avant allocation/Argon2, allocations sensibles bornées | Rate limits, quotas, file d'attente, `spawn_blocking` et nombre de calculs concurrents à l'hôte |
| Compromission mémoire/clé | Effacement des buffers possédés et réduction de copies | Pas de résistance au contrôle total du processus, registres/swap/core dumps/backups ; rotation après incident |

Pour q nonces aléatoires sous une même clé, approximation anniversaire p ≈ q(q−1)/2^97. Budget opérationnel proposé : **q <= 2^24**, soit environ 2^-49 de probabilité de collision, cumulée sur tout le matériel identique, indépendamment des IDs. C'est une borne de gestion, pas une certification ni une borne complète de falsification GCM ; taille des messages, volumes et budget de tentatives restent soumis aux recommandations NIST. Rotation avant dépassement ; comptage durable/distribué à l'hôte. Le crate ne prétend pas compter les opérations d'autres instances.

## 7. Plan correctif, architecture cible et contrat API proposé

### 7.1 Flux et découpage

```text
Clés explicites / environnement / fichier privé
                    |
             KeyRingBuilder -> KeyRing immuable / KeyResolver cohérent
                    |
Identité autorisée -> SecretContext exact
                    |
SecretBytes -> CryptoEngine::seal -> EncryptedEnvelope V2 -> encode explicite
Texte hostile -> parse borné V2 -> CryptoEngine::open + contexte -> SecretBytes
                                     |
                          authentifier puis décider la rotation
```

Modules : `secret.rs` (nouveau), `key.rs`, `context.rs`, `envelope.rs`, `key_resolver.rs` (interfaces et snapshots), `providers/{environment,file}.rs` (réorganisation), `cipher.rs` privé, `password.rs`, `hmac.rs`, `kdf.rs`, `hash.rs`, `error.rs`, façade `lib.rs`. Des sous-modules privés de format/IO ne sont créés que s'ils réduisent effectivement la complexité. Le moteur capture **un seul `Arc<KeyRing>` par opération**, via `KeyResolver::snapshot()`, puis effectue toute sélection et résolution dans ce snapshot (§7.10).

### 7.2 Types, invariants, traits et limites

Les signatures qui suivent constituent la proposition à approuver, pas des signatures existantes. Types de résultat `Result<T, CryptoError>`. Les opérations listées comme conservées gardent leur comportement cryptographique ; les APIs remplacées ne reçoivent pas de shim implicite.

| Type | Invariants et traits proposés |
|---|---|
| `SecretBytes` | Champ privé `Zeroizing<Vec<u8>>`, taille <=1 Mio ; construction par transfert d'allocation ; `Debug` => `[REDACTED]`. Pas de `Clone`, `Copy`, `Deref`, `AsRef`, `Display`, Serde ni comparaison automatique. Accès uniquement nommé `expose_secret`. |
| `SecretString` | Champ privé `Zeroizing<String>`, UTF-8, <=1 Mio ; mêmes restrictions ; conversion depuis `SecretBytes` par transfert d'allocation et effacement sur erreur UTF-8. |
| `EncryptionKey` | Exactement 32 octets protégés avant remplissage ; non clonable/non sérialisable, `Debug` masqué. Import explicite ou génération faillible. Aucun export public de clé brute. |
| `HmacKey` | 32 octets protégés, type distinct de la clé AES ; mêmes restrictions. Les types n'empêchent pas un appelant ayant les bytes de réutiliser matériellement une clé : interdiction documentée. |
| `KeyId` | ASCII `[A-Za-z0-9._-]{1,64}`, casse exacte, aucun trim ; non secret ; `Clone`, `Eq`, `Hash`, `Debug`/`Display` permis sur une valeur déjà validée. |
| `SecretContext` | Champs privés, construction tenant explicite ou contexte global explicite ; exactitude des octets et des frontières ; pas de normalisation Unicode/casse/espaces. `Clone`/`Eq` permis ; `Debug` ne révèle pas les identifiants. |
| `EncryptedEnvelope` | Champs privés, suite AES-256-GCM V2 uniquement ; `parse` valide la syntaxe/les tailles, jamais l'authenticité. Pas de constructeur public à payload arbitraire ni de champs mutables. `encode` explicite ; `Debug` réduit à type/version/taille, pas de payload ni de `Display` automatique. |
| `ResolvedKey` | Paire privée cohérente `(KeyId, Arc<EncryptionKey>)`, issue d'une seule sélection de snapshot. Pas de matérialisation d'une copie de clé. |
| `KeyRing` | Snapshot immuable Send+Sync, <=64 IDs incluant tombstones ; une seule clé active, historiques decrypt-only ; IDs révoqués distingués des absents. Les handles partagés ne clonent pas le matériel. Un `StaticKeyResolver` conserve un `Arc<KeyRing>` fixe ; un resolver hôte peut publier un autre snapshot atomiquement. |
| `PasswordHash` | PHC Argon2id validé/borné, buffer protégé ; `Debug` masqué ; export PHC seulement explicite ; pas de Serde/Display/Clone automatique. |
| `PasswordVerification` | `Mismatch` ou `Verified { needs_rehash: bool }`. Pas de succès implicite pour hash malformé/coût excessif. |
| `ReencryptResult` | `Current` signifie authentification réussie sous le contexte demandé et clé active du snapshot ; `Rotated(EncryptedEnvelope)` contient une enveloppe valide vers la clé active. Aucun plaintext dedans. |

Bornes V2 : plaintext/secret <=1 048 576 octets ; payload <=1 048 604 ; texte enveloppé <=1 398 211 octets. Les règles exactes des identifiants, d'Unicode et de rejet sont définies au §7.4 ; aucun comportement dépendant d'un `trim` ou d'une table Unicode implicite n'est laissé à l'implémentation. L'hôte fournit son identité autorisée dans ce contrat ; le crate ne décide pas que deux identités différentes sont équivalentes.

### 7.3 Constructeurs et API publique

| Signature cible | Préconditions / postconditions / erreurs / limites |
|---|---|
| `SecretBytes::new(Vec<u8>) -> Result<Self>` ; `SecretString::new(String) -> Result<Self>` | Transfert de propriété, vérification de taille ; protéger le buffer dès l'entrée, y compris s'il est refusé. N'efface pas les copies préexistantes de l'appelant. |
| `SecretBytes::expose_secret(&self) -> &[u8]` ; `SecretString::expose_secret(&self) -> &str` | Accès volontaire au plaintext, valide pendant l'emprunt. L'appelant devient responsable des copies. |
| `SecretBytes::into_utf8(self) -> Result<SecretString>` | Réutiliser l'allocation ; `InvalidUtf8` sans contenu secret dans l'erreur ; buffer invalide effacé. |
| `SecretString::into_bytes(self) -> SecretBytes` | Transfert de l'allocation sans copie du contenu ; pas de sortie en `Vec`/`String` brut. Conversions et traits sensibles entièrement définis au §7.12. |
| `EncryptionKey::import(SecretBytes) -> Result<Self>` ; `HmacKey::import(SecretBytes) -> Result<Self>` | Exactement 32 octets ; `InvalidKeyLength` sans valeur reflétée ; source effacée après transfert/copie minimale inévitable. |
| `EncryptionKey::generate() -> Result<Self>` ; `HmacKey::generate() -> Result<Self>` | CSPRNG système via `try_fill_bytes`, buffer déjà protégé ; `RandomUnavailable` sur échec. Pas d'aléa configurable publiquement. |
| `KeyId::parse(&str) -> Result<Self>` ; `as_str(&self) -> &str` | Valider avant allocation, aucune normalisation ; `InvalidKeyId` sans input. |
| `SecretContext::with_tenant(tenant,module,resource,record_id,field: &str) -> Result<Self>` | Toutes les valeurs exactes et bornées ; tenant jamais implicite ; `InvalidContextField`/`InputTooLarge`. |
| `SecretContext::global(purpose: &str) -> Result<Self>` | Usage d'infrastructure explicite et non vide. AAD global non vide, distinct de tout contexte tenant. Ne convient pas aux données multi-tenant. |
| `EncryptedEnvelope::parse(&str) -> Result<Self>` ; `encode(&self) -> String` ; `key_id(&self) -> &KeyId` | Syntaxe V2 canonique seulement, taille avant allocation ; version inconnue/V1 => `UnsupportedVersion`, sans fallback. `key_id` est non authentifié jusqu'à `open`. |
| `KeyRingBuilder::new() -> Self` ; `insert(id,key,use_: KeyUse) -> Result<()>` ; `insert_revoked(id: KeyId) -> Result<()>` | `KeyUse::{Active, DecryptOnly}` ; aucun ID existant accepté, aucune seconde active ; échec sans changement du builder ; <=64 IDs. `insert_revoked` restaure un tombstone sans matériel depuis le registre de confiance de l’hôte, refuse doublons/capacité dépassée sans mutation et interdit ensuite réactivation ou réimport de clé sous cet ID. |
| `ResolvedKey::new(id: KeyId, key: Arc<EncryptionKey>) -> Self` ; `KeyRingBuilder::insert_resolved(key: ResolvedKey, use_: KeyUse) -> Result<()>` | Construction explicite pour les resolvers personnalisés ; transfert au builder des clés chargées par les providers sans export brut ; mêmes contrôles de doublon, capacité et état que `insert`. Les deux composants d'une paire ne sont jamais lus par deux appels indépendants. |
| `ResolvedKey::id(&self) -> &KeyId` ; `KeyRing::validate_successor(&self, next: &KeyRing) -> Result<()>` | ID exposé comme métadonnée, aucun byte de clé. Vérification d'une publication successive : mêmes IDs => même matériel ou transition vers révocation, tombstones conservés ; comparaison interne de clés en temps constant avec `subtle`. Ce contrôle doit être appelé par l'hôte dans la section critique de publication (§7.10). |
| `KeyRingBuilder::from_snapshot(&KeyRing) -> Self` ; `activate(&KeyId) -> Result<()>` ; `revoke(&KeyId) -> Result<()>` ; `build(self) -> Result<KeyRing>` | Import d'Arc, pas de bytes copiés ; transitions exactes au §7.10. Révocation retire le matériel du nouveau snapshot et conserve un tombstone. Tout échec de mutation conserve l'état antérieur du builder. |
| `trait KeyResolver: Send + Sync { fn snapshot(&self) -> Result<Arc<KeyRing>, CryptoError>; }` | Une capture cohérente pour **toute** l'opération ; aucune seconde consultation du resolver pendant `seal`, `open` ou rotation. `Arc<T>` peut déléguer ce trait sans copier les clés. |
| `StaticKeyResolver::new(keys: Arc<KeyRing>) -> Self` | `snapshot()` rend un clone de l'Arc du même snapshot, sans IO ni mutation. Les providers environnement/fichier chargent des clés avant construction ; ils ne changent pas le snapshot en cache à l'insu du moteur. |
| `CryptoEngine::new(resolver: R) -> Self` ; `seal(&self, &SecretBytes, &SecretContext) -> Result<EncryptedEnvelope>` | Capturer un snapshot, sélectionner sa paire active, nonce neuf, métadonnées authentifiées ; entrées bornées ; erreurs snapshot/RNG/allocation/AEAD propagées. |
| `CryptoEngine::open(&self, &EncryptedEnvelope, &SecretContext) -> Result<SecretBytes>` | Capturer un snapshot, résoudre uniquement en son sein ; authentification avant plaintext exposé ; `KeyUnavailable`, `KeyRevoked`, `AuthenticationFailed` ou entrée trop grande. Pas de fallback global/tenant/legacy. |
| `CryptoEngine::reencrypt_if_needed(&self, &EncryptedEnvelope, &SecretContext) -> Result<ReencryptResult>` | Un seul snapshot pour source et cible ; résolution/authentification source même si son ID est actif ; rechiffrement avec la cible capturée et nonce neuf, sans appeler une méthode publique qui recapturerait le resolver. `Current` est relatif à ce snapshot, pas à une configuration publiée ultérieurement. |
| `EnvironmentKeyProvider::load(env_var: &str, id: KeyId) -> Result<ResolvedKey>` | Chargement explicite au démarrage, Base64 standard canonique exactement 44 caractères pour 32 bytes ; pas de trim, pas de reload implicite, contenu jamais dans l'erreur. La variable source reste propriété de l'environnement ; le crate ne la supprime pas. |
| `FileKeyProvider::new(path, id, policy) -> Self` ; `load(&self) -> Result<ResolvedKey>` | `KeyGenerationPolicy::{RequireExisting, AllowGenerateDevelopment}` ; publication/lecture selon §7.5 ; aucune génération si fichier existant invalide. Le chargement précède la construction du snapshot. |
| `hash_password(&SecretString) -> Result<PasswordHash>` | Mot de passe <=1024 octets ; politique §7.6 ; minimum de longueur métier hors crate ; `RandomUnavailable`, `InputTooLarge`, erreur Argon2/allocation. |
| `PasswordHash::parse(&str) -> Result<Self>` ; `expose_phc(&self) -> &str` ; `needs_rehash(&self) -> bool` | Validation stricte/budgets avant construction ; PHC invalide => erreur, jamais « conforme ». Export explicitement sensible. |
| `verify_password(&SecretString, &PasswordHash) -> Result<PasswordVerification>` | Comparaison de digest par RustCrypto ; aucune allocation Argon2 hors budget ; mismatch distinct de format/échec moteur. Ne gère ni comptes, ni sessions, ni rate limiting. |
| `sign_hmac_sha256(&HmacKey, data: &[u8]) -> Result<[u8;32]>` ; `verify_hmac_sha256(&HmacKey, data, tag: &[u8]) -> Result<bool>` | Pas de clé vide/courte publiquement ; tag exactement 32 bytes ; mismatch => false, échec moteur => erreur ; comparaison RustCrypto constante pour tags valides de même taille. Coût linéaire de data à l'appelant. |
| Variantes hex HMAC existantes, adaptées au type de clé et à `Result` | Sortie minuscule de 64 caractères ; vérification exactement 64 caractères, sans trim, décodage dans `[u8;32]`, échec de format distinct du mismatch. Le parsing hex n'est pas revendiqué constant-time sur des entrées invalides. |
| `hkdf_sha256(ikm: &SecretBytes, salt: Option<&[u8]>, info: &[u8], len: usize) -> Result<SecretBytes>` | `len` dans 1..=8160, info non vide <=1024 ; IKM borné par SecretBytes et supposé de bonne entropie ; pas une KDF de mot de passe. Sortie protégée avant écriture ; pas de buffer brut exposé par défaut. |
| `sha256`, `sha256_hex`, `blake3`, `blake3_hex`, `Sha256Hasher`, `Blake3Hasher` | Conservation des signatures existantes ; aucune utilisation en remplacement d'Argon2 pour mots de passe ; streaming sans allocation proportionnelle au flux ; `Clone` des hashers acceptable pour données ordinaires. Pas de garantie de redaction des inputs de ces fonctions de hachage génériques. |

Suppressions/remplacements : alias secrets et réexport public `Zeroizing` ; `SecretContext::new` avec tenant `default` ; méthodes `encrypt_unbound`/`decrypt_unbound` à AAD vide ; exposition publique de `cipher` et de nonce manuel ; champs publics et constructeur arbitraire d'enveloppe ; `active_key_id()+resolve()` séparés ; mutation du `CompositeKeyResolver` en service ; `needs_rehash(&str)->bool` ; `hkdf_sha256_32` redondant remplacé par `len=32`. Les tests de vecteurs bas niveau sont déplacés dans des modules unitaires privés pour conserver un oracle sans réouvrir l'API dangereuse.

Erreurs proposées : enum `#[non_exhaustive]` avec `InvalidKeyId`, `InvalidKeyLength`, `InvalidKeyEncoding`, `DuplicateKeyId`, `MissingActiveKey`, `MultipleActiveKeys`, `ActiveKeyRevocation`, `KeySubstitution`, `InvalidSnapshotTransition`, `KeyUnavailable`, `KeyRevoked`, `InvalidContextField(ContextField)`, `InputTooLarge`, `UnsupportedVersion`, `InvalidEnvelope`, `AuthenticationFailed`, `RandomUnavailable`, `InvalidUtf8`, `InvalidPasswordHash`, `PasswordCostExceeded`, `PasswordHashFailed`, `HkdfFailed`, `InvalidTagEncoding`, `KeyStoreUnavailable`, `InsecureKeyFile`, `UnsupportedStorage`, `DurabilityUncertain`, `CleanupFailed`, `AllocationFailed` et échec cryptographique interne. `DurabilityUncertain`, `CleanupFailed` et `Io` portent seulement `IoOperation`/phase statique et `std::io::ErrorKind`. `Debug`/`Display` n'incluent ni plaintext, ni PHC, ni entrée arbitraire, ni chemin ou texte OS libre. Les opérations IO ont des identifiants statiques ; pas de source capturant une chaîne hostile. Les distinctions de clé ne doivent pas être exposées telles quelles à un client HTTP non autorisé : mapping à l'hôte.

### 7.4 R1 — Spécification normative complète du protocole enc:v2

Cette section suffit à une implémentation indépendante de l'enveloppe, de son AAD et de ses règles de rejet. « DOIT » désigne une obligation du protocole proposé. Tous les nombres de taille sont en **octets**, sauf indication contraire. Toutes les bornes sont inclusives. Le nom « AAD V2 / lyxal:v2 » désigne ce schéma ; son préfixe binaire exact est celui indiqué ci-dessous, sans autre préfixe implicite.

#### 7.4.1 Suite, entrée et représentation transport

Suite unique : AES-256-GCM selon NIST SP 800-38D, clé 32 octets, nonce 12 octets, tag complet 16 octets. Aucun tag tronqué, padding de plaintext, compression, KDF implicite ou paramètre négocié. Les bytes de la clé sont utilisés directement par AES-256-GCM. La clé n'est ni un mot de passe ni une chaîne Base64 à interpréter par AES. Plaintext quelconque, y compris vide, de 0 à 1 048 576 octets.

Le transport est la chaîne ASCII exacte :

```text
enc:v2:<key_id>:<payload_base64url>
```

Les deux premiers composants et les trois `:` sont des littéraux sensibles à la casse. `key_id` est défini au §7.4.2. `payload_base64url` utilise uniquement l'alphabet RFC 4648 §5 `A-Z a-z 0-9 - _`, sans `=`, whitespace, saut de ligne, BOM ni terminaison NUL. Les bits inutilisés du dernier caractère DOIVENT être nuls : `encode(decode(s)) == s`. Aucun décodage URL/percent, JSON, Unicode ou transport additionnel n'est réalisé par le crate. Une couche HTTP/JSON peut transporter cette chaîne mais doit transmettre sa valeur exacte à `parse`.

Le payload décodé est exactement :

| Offsets demi-ouverts | Contenu |
|---|---|
| `[0,12)` | nonce de 12 octets |
| `[12,n-16)` | ciphertext, éventuellement vide |
| `[n-16,n)` | tag de 16 octets |

`n` est compris entre 28 et 1 048 604. Le ciphertext a la même longueur que le plaintext. La longueur Base64 sans padding d'un binaire de n octets est `B(n)=ceil(4*n/3)`, calculée avec arithmétique vérifiée. Longueur texte = `8 + len(key_id) + B(n)` : minimum 47, maximum **1 398 211**. Maximum du composant Base64 : **1 398 139**. Aucun ajout après le tag n'est accepté comme extension : il ferait partie d'un autre ciphertext dont le tag doit être vérifié.

#### 7.4.2 Valeurs, identités et champs obligatoires

Tous les champs sont obligatoires dans leur mode. `None`, chaîne vide, tenant implicite, espace ajouté puis supprimé ou encodage de secours sont interdits. Les expressions ci-dessous correspondent à l'intégralité du champ, avec classes **ASCII**, sans option insensible à la casse.

| Champ | Règle exacte | Taille |
|---|---|---|
| key_id | `[A-Za-z0-9._-]{1,64}` | 1..64 |
| tenant | `[A-Za-z0-9_-]{1,128}` | 1..128 |
| module, resource, field | `[a-z][a-z0-9_]{0,63}` chacun | 1..64 chacun |
| purpose global | `[a-z][a-z0-9._-]{0,127}` | 1..128 |
| record_id | UTF-8 strict de valeurs scalaires Unicode ; contraintes ci-dessous | 1..1024 |

`record_id` : séquences UTF-8 surlongues, substituts UTF-16 et bytes invalides interdits ; U+0000..U+001F et U+007F..U+009F interdits partout. Premier/dernier scalaire interdit s'il appartient à la liste figée suivante : U+0009..U+000D, U+0020, U+0085, U+00A0, U+1680, U+2000..U+200A, U+2028, U+2029, U+202F, U+205F, U+3000. Il ne faut pas utiliser une version variable de `trim`/`is_whitespace` pour définir cette liste. Les caractères intérieurs non interdits, dont `:`, espaces ordinaires et Unicode, sont conservés tels quels. Une forme composée et une forme décomposée restent **distinctes** : aucun NFC/NFKC, lowercase, case-folding ou normalisation d'espace. Les séquences de format Unicode non explicitement interdites restent exactes ; elles ne sont pas affichées dans les diagnostics de contexte.

`Acme` et `acme` sont deux tenants différents ; `rec_A` et `rec_a` sont deux records différents. Les champs interdits sont rejetés, jamais transformés. `.`/`..` peuvent être des key IDs mais ne sont jamais des noms de fichier dérivés. L'hôte fournit l'identité autorisée ; le protocole n'implémente aucune autorisation ni interprétation d'un ID SurrealDB.

#### 7.4.3 Encodage binaire exact de l'AAD

Définir `LP(s) = U32BE(len(UTF8(s))) || UTF8(s)`. U32BE est un entier non signé de 4 octets, ordre réseau, aucune représentation décimale, aucun terminateur ni séparateur additionnel. Tous les champs sont bornés avant conversion/allocation. Pour les champs ASCII, UTF8(s) est identique aux bytes ASCII.

Constante `P`, **32 octets**, incluant le NUL final :

```text
ASCII : lyxal:crypto:enc:v2:aes-256-gcm suivi de 00
HEX   : 6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d00
```

Mode tenant, octet `01` :

```text
AAD = P || 01 || LP(key_id) || LP(tenant) || LP(module)
        || LP(resource) || LP(record_id) || LP(field)
```

Mode global, octet `02` :

```text
AAD = P || 02 || LP(key_id) || LP(purpose)
```

Aucun autre mode n'existe. Les octets `01`/`02` sont binaires, pas des chaînes ASCII. En mode global, aucun emplacement vide pour tenant/module/resource/record/field n'est inséré. En mode tenant, aucun purpose global n'est ajouté. L'AAD maximum vaut **1465 octets** en tenant, **233 octets** en global. Les deux domaines ont des ensembles d'encodages disjoints. Les champs LP sont injectifs sur les valeurs validées ; une comparaison par caractères ou un séparateur `:` ne peut pas remplacer les longueurs.

L'enveloppe ne transporte **pas** le contexte : `open` reçoit le contexte autorisé de l'hôte, et reconstruit l'AAD avec le key ID exact de l'enveloppe. Mode et purpose ne sont jamais devinés ni testés successivement jusqu'à un succès. Version et suite sont authentifiées par `P`, key ID par son LP, mode par son octet, identité/usage par les LP suivants. Le préfixe texte est fixe et strictement validé ; il ne peut donc pas diverger du domaine authentifié. Le nonce et le ciphertext sont liés au tag par GCM lui-même. Aucun header variable n'est laissé non authentifié.

#### 7.4.4 Scellement, ouverture et règles de rejet

Scellement : valider les tailles/contexte -> capturer un snapshot -> obtenir sa clé active -> produire un nonce CSPRNG de 12 bytes -> calculer AAD -> AES-GCM -> concaténer nonce/ciphertext/tag -> Base64URL canonique. Échec CSPRNG => erreur, jamais nonce nul ou compteur de secours. Les nonces déterministes des fixtures sont exclusivement des paramètres du calcul de référence et de tests privés, jamais de l'API publique.

Parsing : (1) rejeter taille >1 398 211 avant allocation ; (2) exiger ASCII et exactement quatre composants séparés par trois `:` ; (3) exiger `enc`, version canonique et composants non vides ; (4) version reconnue seule `v2`, ancienne `v1`/autre version numérique canonique => `UnsupportedVersion` ; (5) valider key ID et longueur Base64 avant décodage ; (6) contrôler alphabet, longueur modulo 4 différente de 1, absence de padding et bits terminaux nuls ; (7) décoder dans une allocation bornée ; (8) exiger payload de 28..1 048 604 bytes. `v02`, `V2`, `ENC`, marqueurs de version non numériques ou avec zéros initiaux ne sont pas canoniques et donnent `InvalidEnvelope`. Aucun entier de version non borné n'est alloué/converti ; pour classifier une version inconnue, au plus trois chiffres ASCII après `v`, premier non nul. Autres syntaxes invalides => `InvalidEnvelope`, sans entrée reflétée. Les entrées trop grandes => `InputTooLarge`. Une version inconnue peut être rejetée sans valider son ciphertext ; ce rejet n'est pas une authentification.

Ouverture : exiger enveloppe parsée V2 -> capturer un snapshot -> clé absente/révoquée refusée -> reconstruire AAD exact -> vérifier le tag complet -> rendre seulement alors les bytes déchiffrés protégés. Tag/nonce/ciphertext/key ID/contexte incompatibles donnent `AuthenticationFailed` si la clé est résolue. Ne pas exposer de plaintext partiel ni de source d'erreur contenant les bytes. Une enveloppe parsée, son key ID ou un `encode` réussi **ne prouvent jamais son authenticité**. Rejet et effacement du buffer sensible sur tout échec d'AEAD.

#### 7.4.5 Vecteurs déterministes littéraux et indépendants

Provenance ciblée de la révision A-R2 : calcul de référence avec Python `cryptography 50.0.0`, backend **OpenSSL 4.0.1 (9 juin 2026)**, sans appel, compilation ni exécution de `lyxal_crypto`. Contrôle préalable NIST AES-256-GCM : clé 32 bytes nuls, nonce 12 bytes nuls, plaintext/AAD vides => tag `530f8afbc74536b9a963b4f1c4cb738b`. Chaque résultat ci-dessous a aussi été rouvert avec ce moteur indépendant. Cela ne valide pas une implémentation Rust V2 encore inexistante. Une deuxième implémentation indépendante vérifiera les littéraux avant gel final en L7.

Clé publique de **test uniquement**, commune aux trois cas :

```text
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
```

T1 : mode tenant ; key_id=`k1`, tenant=`Acme`, module=`booking`, resource=`setting`, record_id=`rec_é` avec é=U+00E9 (`c3 a9`, six bytes pour le record complet), field=`password` ; plaintext ASCII `Lyxal V2`.

```text
NONCE_HEX=000102030405060708090a0b
PLAINTEXT_HEX=4c7978616c205632
AAD_LENGTH=91
AAD_HEX=6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0001000000026b310000000441636d6500000007626f6f6b696e670000000773657474696e67000000067265635fc3a90000000870617373776f7264
CIPHERTEXT_HEX=0b7bae7aa9c59429
TAG_HEX=53c1553b0ebca1ea8330528d323cd795
PAYLOAD_HEX=000102030405060708090a0b0b7bae7aa9c5942953c1553b0ebca1ea8330528d323cd795
ENVELOPE=enc:v2:k1:AAECAwQFBgcICQoLC3uueqnFlClTwVU7Dryh6oMwUo0yPNeV
```

T0 : mêmes champs et AAD littéral que T1, plaintext vide, nonce distinct.

```text
NONCE_HEX=0c0d0e0f1011121314151617
PLAINTEXT_HEX=
AAD_LENGTH=91
AAD_HEX=6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0001000000026b310000000441636d6500000007626f6f6b696e670000000773657474696e67000000067265635fc3a90000000870617373776f7264
CIPHERTEXT_HEX=
TAG_HEX=845ec723ee39605093e62576050a3b57
PAYLOAD_HEX=0c0d0e0f1011121314151617845ec723ee39605093e62576050a3b57
ENVELOPE=enc:v2:k1:DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw
```

G1 : mode global ; key_id=`k1`, purpose=`smtp.password`, plaintext ASCII `Lyxal V2`, nonce distinct.

```text
NONCE_HEX=18191a1b1c1d1e1f20212223
PLAINTEXT_HEX=4c7978616c205632
AAD_LENGTH=56
AAD_HEX=6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0002000000026b310000000d736d74702e70617373776f7264
CIPHERTEXT_HEX=5f663871b769337d
TAG_HEX=fd4a1e69ef1af40920d5c5458fcd3efe
PAYLOAD_HEX=18191a1b1c1d1e1f202122235f663871b769337dfd4a1e69ef1af40920d5c5458fcd3efe
ENVELOPE=enc:v2:k1:GBkaGxwdHh8gISIjX2Y4cbdpM339Sh5p7xr0CSDVxUWPzT7-
```

Ces constantes sont des oracles à recopier littéralement dans les tests futurs, jamais à recalculer pour modifier le résultat attendu. Les bytes ASCII `Lyxal V2` n'incluent aucun saut de ligne. Les limites UTF-8 et la terminaison des blocs de documentation ne font pas partie des entrées.

Vecteurs de rejet minimaux : ` enc:v2:...`, `enc:V2:...`, `enc:v02:...`, `enc:v2: k1:...`, composant supplémentaire, payload avec `=`, `+` ou `/`, Base64 de longueur modulo 4 égale à 1, payload décodé de 27 bytes, payload >maximum. Variante non canonique exacte de T0 : remplacer le dernier `w` par `x` dans `DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw` conserve les bytes décodés chez un décodeur permissif mais DOIT être refusé pour bits terminaux non nuls. Pour T1, remplacer le key ID par `k2` alors que k2 contient la même clé DOIT échouer à l'authentification ; changer `Acme` en `acme` ou le mode en global doit également échouer, sans fallback. Deux IDs différents pointant le même matériel ne créent pas deux budgets de nonce (§7.11).

Conserver SHA-256, BLAKE3, HMAC-SHA256, HKDF-SHA256, Argon2id v19 et OsRng. Aucun chiffrement maison ni nouveau protocole négociable. `v2` est une rupture explicite : `ENVELOPE_FORMAT_V1.md` restera historique, et la spécification du présent paragraphe sera extraite en `ENVELOPE_FORMAT_V2.md` seulement en phase B. Aucun adaptateur V1 automatique ni migration de données extérieure.

### 7.5 R4 — Persistance sécurisée, plateformes et défaillances

#### 7.5.1 Matrice de support proposé pour la première production

Cette matrice est une **cible à qualifier**, pas une déclaration de support déjà testé. Aucun backend V2 n'existe encore.

| Profil | Cible officiellement annoncée seulement après les tests de L4/L7 | Autres environnements |
|---|---|---|
| Noyau crypto / snapshots / environnement | Linux x86_64, bibliothèques et features qualifiées | Windows/macOS/ARM : compilation et qualification distinctes avant support officiel |
| Fichier, RequireExisting | Linux x86_64, filesystem local ext4 ou XFS qualifié, répertoire privé de confiance | `UnsupportedStorage` tant que contrôles natifs/ACL/durabilité non qualifiés ; pas d'acceptation permissive sur Windows |
| Fichier, AllowGenerateDevelopment | Même profil Linux ; création persistante réservée au développement | Aucun fallback vers rename/copie/absence de sync |
| NFS/SMB, FUSE, filesystem distribué, overlay/conteneur non qualifié | Aucun support de durabilité revendiqué | Qualification explicite distincte ; un test sur overlay cloud ne qualifie pas ext4/XFS ni la panne électrique |

Les garanties supposent que filesystem, noyau, stockage et contrôleur respectent `sync_all`, hard links atomiques et barrières d'écriture. Le crate ne prouve pas le comportement physique du disque ni la configuration du cache. Refuser les erreurs connues de capacité/sync avec `UnsupportedStorage`/erreur de durabilité ; la qualification de l'environnement et ses options de montage relève de l'opérateur, pas d'une détection magique complète par std.

Le fichier reste utile en développement et pour clé préprovisionnée. La production recommande l'injection sécurisée gérée par l'hôte. `AllowGenerateDevelopment` n'identifie pas automatiquement un déploiement production : l'hôte DOIT interdire ce mode dans sa politique de production. Le chemin est configuré, jamais construit avec un key ID provenant d'une enveloppe.

#### 7.5.2 Frontière de confiance, chemins et permissions

Exiger un chemin absolu normalisé lexicalement : aucun composant `.`/`..`, ni composant final vide ; répertoire parent déjà existant et privé. Le provider ne crée pas d'arborescence et ne répare pas ses permissions. Parent effectif : permissions 0700 ou 0500 pour lecture seule ; génération exige 0700 et droit d'écriture. Propriétaire du fichier identique à celui du parent privé ; modes de fichier acceptés **0600 ou 0400**, jamais droits groupe/autres, bits spéciaux ou droits exécutables. L'opérateur garantit que ce propriétaire correspond au compte de service ou à son provisioning explicitement approuvé. Les UID sont contrôlés via métadonnées Unix ; aucune élévation ni découverte de secret n'est faite.

Refuser symlinks à chaque composant observable, fichier final non régulier, FIFO, socket, périphérique, parent inattendu et identité de fichier incohérente. La lecture compare device/inode et metadata pertinents du chemin avant ouverture, du handle ouvert et du chemin après ouverture ; aucun contenu n'est accepté avant ces contrôles. Permissions/propriétaire sont contrôlés sur le handle, pas uniquement par `exists()`. Les hard links temporaires créés par la publication sont permis : ne pas imposer nlink==1 pendant cette fenêtre.

**Limite assumée** : ces contrôles std ne garantissent pas un parcours sans TOCTOU contre quelqu'un pouvant renommer/modifier les parents ou fabriquer un fichier spécial entre contrôles. Un tel acteur, un autre processus hostile de même UID ou un administrateur sont hors du profil de répertoire de confiance. Le contrat n'annonce donc pas une résistance générale à des ancêtres hostiles. Si l'opérateur ne peut pas établir cette précondition, le provider fichier n'est pas utilisable ; choisir l'injection de clé ou soumettre un backend descripteur-relatif/no-follow avec dépendance OS reconnue et permission de lockfile séparée. Aucun appel bloquant à un FIFO hostile ne doit être qualifié de protection assurée par la variante std.

#### 7.5.3 Lecture et contenu

Contenu accepté : exactement 44 octets ASCII de Base64 standard RFC 4648 §4 canonique, décodant 32 bytes ; éventuellement **un unique LF 0A** final, soit 45 bytes au total. Aucun BOM, CRLF, espace, autre saut de ligne ni trim. La forme canonique générée est 44 bytes **sans LF**. Après décodage, réencodage identique aux 44 bytes requis. Environnement : même Base64, exactement 44 caractères, sans LF.

Lire au plus 46 octets pour détecter l'excès, vérifier la fin réelle et les metadata ; utiliser des buffers protégés dès le premier byte sensible. Le fichier est immuable pendant toute la vie d'une clé. Fichier manquant en strict => `KeyUnavailable` ; vide/tronqué/invalide => erreur de contenu ; aucune de ces erreurs ne déclenche une régénération. Si une génération concurrente réussit à publier entre un constat d'absence et l'essai de publication, charger la clé gagnante selon le même chemin strict.

Avant retour réussi, synchroniser le fichier final et son répertoire selon le profil qualifié : ceci s'applique aussi à un lecteur concurrent pour éviter de rendre une clé uniquement visible mais non encore durable. Le handle d'un fichier préprovisionné doit également permettre cette synchronisation sur la plateforme qualifiée ; sinon erreur explicite, pas présomption de durabilité. Un chargement réussi rend une clé en mémoire ; les changements futurs du fichier ne modifient pas un snapshot déjà construit.

#### 7.5.4 Publication atomique sans remplacement

Protocole sur un seul répertoire et filesystem :

1. Valider plateforme/parent et tenter le chargement d'un final déjà présent. Aucun remplacement d'un final invalide.
2. En développement seulement et si final absent : générer la clé de 32 bytes dans un buffer protégé. Créer un nom temporaire `.lyxal-key-<32 chiffres hex minuscules>` issu de 16 bytes OsRng, indépendant de la clé et des identifiants. `create_new`, mode 0600 ; 8 tentatives maximum en cas de collision, puis erreur. Jamais de nom prédictible contenant du matériel de clé.
3. Écrire les 44 bytes Base64 protégés par `write_all`, puis `sync_all` du temporaire. En cas d'erreur, pas de publication ; abandonner la clé et nettoyer uniquement le fichier créé par cette opération si son identité correspond encore.
4. Faire `hard_link(temp, final)`. Le filesystem assure absence de remplacement du final et apparition d'un lien vers un inode déjà complètement écrit. Un autre processus ne doit jamais voir un final partiellement écrit par cette opération.
5. Succès du lien : synchroniser le répertoire. Échec `AlreadyExists` : ne pas utiliser la clé candidate ; charger et synchroniser le final gagnant, puis abandonner la candidate. Toute autre erreur laisse le final intact et remonte une erreur.
6. Nettoyer le temporaire **de cette opération** après contrôle d'identité, puis synchroniser le répertoire après suppression. Ne pas supprimer les temporaires d'un autre processus, ni un final. Retour de clé seulement après toutes les étapes requises ou chargement réussi du gagnant.

Pas de `rename` susceptible d'écraser, de copie vers le nom final, de verrou process-local présenté comme multiprocessus, de retry sur un contenu partiel ni d'unlock/cache silencieux. Publication atomique signifie qu'un lecteur observe absent ou complet ; elle ne signifie pas à elle seule durabilité, unicité du matériel dans toutes les sauvegardes ou contrôle d'accès contre un administrateur.

#### 7.5.5 Erreurs après publication et récupération

| État / incident | Résultat et état final | Récupération autorisée |
|---|---|---|
| Avant hard_link | Erreur typée, aucune nouvelle clé finale ; temporaire possible | Nettoyage sûr du temporaire propre ; nouvelle tentative de génération en développement seulement si final toujours absent |
| Après hard_link, avant confirmation de sync du répertoire | `DurabilityUncertain`, **aucune clé rendue** ; final complet peut exister | Ne pas supprimer le final ; recharger, valider et synchroniser lors d'une tentative explicite |
| Fichier final durable mais nettoyage temporaire échoue | `CleanupFailed`, publication déjà confirmée, aucune clé rendue par cet appel | Final conservé ; un chargement strict ultérieur peut réussir ; résidu privé à nettoyer par opération d'entretien autorisée |
| Suppression du temporaire faite, sync de nettoyage échoue | `CleanupFailed` avec phase statique ; clé finale déjà synchronisée, résidu après crash possible | Ne pas qualifier la clé finale de corrompue ni régénérer ; relecture stricte possible |
| Final déjà présent mais invalide/insecure | Erreur de contenu/sécurité, jamais écrasement | Intervention opérateur/restauration de la clé correcte, pas génération automatique |
| Final absent après redémarrage | Strict : échec ; développement : nouvelle génération possible | L'hôte vérifie qu'aucune donnée dépendante de la clé perdue n'exige une restauration avant de réutiliser un ID |
| Crash laissant un temporaire seul ou avec final | Temporaire jamais accepté comme final | Pas de promotion automatique ; nettoyage séparé sous politique opérateur, sans toucher des clés extérieures au mandat |

`DurabilityUncertain` et `CleanupFailed` portent une phase IO non secrète et un `ErrorKind`, jamais la clé, le contenu ou un chemin libre. « Relecture réussie » ne garantit pas la récupération de données dont une autre clé a été perdue. Aucune réparation destructive ni suppression de clé historique par ce provider.

#### 7.5.6 Tests de qualification reproductibles (phase B seulement)

- **FS-01** : parent 0700, final 0600 puis 0400, clé littérale fictive connue ; chargement fonctionnel et contrôles sur handle. Cas 0644, groupe/autres, fichier exécutable, mauvais propriétaire simulé par adaptateur/test de privilèges disponible => rejet explicite. Aucune réussite déclarée pour cas UID impossible à exercer.
- **FS-02** : symlink final, symlink parent, FIFO/socket/répertoire, fichier de 0/43/44/45/46 bytes, LF/CRLF/BOM/pad bits ; rejet déterministe sans fuite. Les races malveillantes de parents restent hors profil std et ne sont pas annoncées protégées.
- **FS-03** : 16 **processus** indépendants, départ synchronisé par barrière, 100 rounds sur chemins absents en répertoires privés ; 1600 chargements réussis sans erreur de fichier partiel ; même matériel final démontré par chiffrement/déchiffrement croisé, sans le journaliser ; final jamais écrasé.
- **FS-04** : hooks privés de test aux étapes création, mi-write, write complet, sync-file, link, sync-dir-publication, suppression, sync-dir-cleanup ; interruption enfant à chacune, redémarrage et lecture stricte. Invariant : aucun final partiel accepté ; absent/valide/erreur explicite suivant l'étape.
- **FS-05** : injection déterministe write court, ENOSPC/permission, échec sync et hard_link, `AlreadyExists`, RNG de nom indisponible, collision répétée ; assert phase, état du fichier, absence de cache/clé retournée sur échec, conservation d'un final préexistant.
- **FS-06** : après chaque erreur post-publication, tentative de relecture/sync ; distinguer publication confirmée et incertaine, jamais remplacer le final. Vérifier que les temporaires étrangers ne sont pas supprimés.
- **FS-07** : exécuter la campagne sur ext4 et XFS locaux qualifiés ; annoncer support de chaque filesystem seulement après ses résultats. Tests d'interruption de processus distincts d'une campagne de perte d'alimentation de l'hôte. Un environnement cloud overlay peut seulement démontrer la logique, pas la durabilité physique du profil cible.

### 7.6 Mots de passe et mémoire sensible

Politique de création : Argon2id v19, m=65536 KiB, t=3, p=1, sel aléatoire 16 bytes, digest 32 bytes. Mot de passe de 0 à 1024 bytes : la longueur minimale et le traitement métier du vide appartiennent à l'authentification, pas à cette fondation.

PHC <=512 bytes ; uniquement algorithme argon2id, version 19, paramètres m/t/p exactement une fois chacun, salt décodé 16..=32 bytes, digest exactement 32 bytes ; pas d'extension implicite keyid/data. Coûts de vérification : m entre le minimum Argon2 valide `8*p` et 131072 KiB, t de 1 à 5, p de 1 à 4 ; vérifier les contraintes croisées avant toute allocation. Les profils plus faibles dans cette fenêtre ne sont pas produits, mais peuvent être vérifiés et signalés pour migration après un match. Profils hors fenêtre => erreur explicite, pas essai aveugle.

Rehash : vrai pour profil inférieur à la cible dans au moins un coût, sel <16 (normalement impossible après parse), ou évolution ultérieure de politique autorisée ; faux pour profil cible et profil compatible au moins aussi fort dans tous les coûts. Une différence à la hausse ne provoque pas un downgrade automatique. Profils incomparables (un coût inférieur et un supérieur) : rehash indiqué, impact documenté plutôt que qualifié mathématiquement de renforcement universel. Pas de migration d'algorithme/version non supportée via vérification implicite.

Utiliser, si supporté par les features approuvées, `hash_password_into_with_memory` avec workspace de blocks alloué de façon faillible puis explicitement effacé, sur succès comme erreur. Activer `argon2/zeroize` ne suffit pas à effacer le Vec du chemin alloué par défaut. Entourer sel, sorties et buffers temporaires sensibles avant écriture. Pour AES-GCM, préférer les méthodes in-place avec allocation plaintext protégée dès le début ; lors d'une erreur, effacer ce buffer même si une dépendance y a écrit. Les copies internes, registres, piles déplacées, états HMAC/HKDF et backends matériels doivent être audités mais aucune garantie d'effacement absolu n'est annoncée.

L'hôte doit limiter le nombre de calculs simultanés et exécuter les opérations coûteuses hors d'un thread async critique. Le crate ne lance ni thread ni tâche cachée et ne gère pas les tentatives de connexion.

### 7.7 Lots techniques et ordre d'exécution après approbation

Chaque lot commence par un test reproduisant l'invariant concerné et se termine par ses checks ciblés. Aucun lot de cette liste n'est commencé en phase A.

| Lot | Objectif / décisions / anomalies | Fichiers et API | Dépendances, tests, risques et validation |
|---|---|---|---|
| L0 Contrats | Figer R1–R5, invariants I1–I12, matrice A01–A16/C01–C16 et ruptures ; autonomie fondation | Ce plan maintenant ; `API_CONTRACT.md`, changelog et décisions seulement en phase B | Pas de dépendance nouvelle en phase A ; approbation finale des octets V2, transitions, types et profil de stockage ; permissions §7.14 levées avant sous-lots concernés |
| L1 Secrets/erreurs | A01/A05/A12/A13 ; conteneurs opaques, erreurs sans contenu, génération faillible | `secret.rs`, `key.rs`, `error.rs`, `lib.rs`, tests secrets et RNG ; constructeurs et conversions remplacés | RustCrypto/zeroize/OsRng existants ; compile-fail doctests pour traits interdits ; tests chemins d'erreur et faux CSPRNG privé. Risque : rupture des alias consommateurs, explicitement différée hors crate |
| L2 Identité/format | R1 ; A07/A08/A11 ; contexte exact et V2, parser borné, cipher privé | `context.rs`, `envelope.rs`, `cipher.rs`, fixtures littérales T1/T0/G1, `ENVELOPE_FORMAT_V2.md` | AES-GCM/base64 existants ; C07/C08/C11/C15, tests du §7.4 et propriétés injectivité. V1 rejeté, pas de migration cachée ; features mémoire conditionnées à L6 |
| L3 Trousseau/rotation | R2 ; A02/A04 ; builder, snapshot, succession validée, états et authentification avant Current | `key_resolver.rs`, `lib.rs`, tests rotation/trousseau ; KeyResolver::snapshot et StaticKeyResolver | std Arc et subtle 2.6.1 direct **sous permission lock séparée** ; C02/C04 et tests §7.10. Aucun fallback == ni prétention de révocation distante |
| L4 Providers/fichier | R4 ; A03/A05/A09/A11 ; chargement explicite, publication sans remplacement et reprise §7.5 | `providers/*`, `key_resolver.rs`, tests fichier multiprocessus/failpoints | std + OsRng, pas de bibliothèque OS nouvelle dans la variante de base ; C03/C09, FS-01..FS-07, Linux ext4/XFS à qualifier séparément. Ancêtres hostiles exclus ; toute garantie plus forte revient au CTO |
| L5 PHC/MAC/KDF | A06/A10/A11/A13 ; types hash/HMAC, budgets, rehash, sortie HKDF protégée | `password.rs`, `hmac.rs`, `kdf.rs`, tests RFC/PHC/limites | Versions existantes, feature mémoire conditionnelle L6 ; tests rejet avant calcul, exactitude des tags, info HKDF non vide, limite 8160. Aucun métier d'authentification |
| L6 Dépendances/mémoire | R5 et R3 ; A14/A16 ; features, MSRV, workspace Argon2, schedules et limites honnêtes | `Cargo.toml` du crate, mémoire, tests ; **Cargo.lock racine hors mandat** pour arêtes mémoire/subtle | C14/C16 ; versions inchangées, features aes/aes-gcm/ghash/polyval/argon2 qualifiées ; permission §7.14 préalable aux sous-lots dépendants. Aucun quota global ajouté au crate |
| L7 Assurance/documentation | R1–R5 ; A15 et preuves de tous les lots, matrice complète, fuzzing et profil de déploiement | `tests/**`, `fuzz/**`, README, SECURITY, contrats, roadmap, changelog dans le crate | proptest/tempfile existants ; corpus/lock fuzz internes ; C01..C16 et §7.8 ; seconde vérification indépendante des vecteurs ; budget hôte documenté, non annoncé automatiquement garanti |

Ordre CTO définitif : **L0 → L6a → L1 → L2 → L3 → L4 → L5 → L6b → L7**. L6a configure les versions/features et l’outillage avant les composants dépendants ; L6b vérifie et finalise l’effacement mémoire intégré après L5. L’exception Cargo.lock est accordée exclusivement pour les changements minimaux identifiés ; aucun cargo update général.

### 7.8 Stratégie de validation et critères d'acceptation mesurables

**Tests unitaires/adversariaux.** Chaque erreur publique a au moins un cas négatif ; sentinelles de secrets absentes de `Debug`/`Display` et des chaînes d'erreurs ; déchiffrement avec mauvaise clé de même ID ; chaque composant du contexte et du header altéré ; aucune sortie plaintext sur échec ; aucun doublon modifiant le trousseau ; clés absentes/révoquées ; rotation liée/globale complète et erreurs `Current` ; limites exactes N−1/N/N+1 avant allocation.

**Traits.** Doctests `compile_fail` pour Clone/Copy/Deref/Display/Serialize non autorisés sans ajouter Serde à l'API runtime ; tests de traits avec snippets de compilation adaptés aux dépendances réellement présentes. Test positif des accès explicites et Send+Sync des snapshots. Ne pas confondre absence d'une dépendance Serde dans un snippet avec preuve qu'un trait n'est pas implémenté : inspecter les impls et, si Serde est ajouté uniquement au banc, vérifier sa déclaration reste dans le crate et son lockfile dédié.

**Propriétés.** >=1000 cas par propriété pour roundtrip, encode/parse canonique, différenciation de contextes valides distincts, mutation systématique d'un champ, rotation idempotente, refus des doublons sans mutation et impossibilité de réactivation d'une clé révoquée dans un builder. Exercer Unicode et frontière de longueur dans les record IDs ; pas seulement tenants ASCII de longueurs disjointes. Aucun test probabiliste de deux nonces ne devient une preuve générale d'unicité.

**Concurrence et défaillances.** Au moins 16 processus/instances visant le même chemin absent, 100 rounds : tous les succès utilisent une seule clé finale et déchiffrent les sorties des autres ; aucune lecture de fichier partiel. Failpoints privés compilés uniquement en tests aux étapes create/write/sync/link/sync-dir/cleanup ; processus interrompu à chaque étape, puis reprise. État final attendu : absence ou clé complète validée, jamais acceptation d'une clé partielle ; erreur de durabilité distincte lorsqu'elle est inconnue. Simulations d'erreurs IO reproductibles, tmp orphelin, permission incorrecte, lien symbolique, fichier trop grand, répertoire non sûr et storage non supporté. Des tests de kill ne prouvent pas la résistance à la panne électrique réelle ; cette validation reste une campagne d'infrastructure séparée.

**Fixtures.** Au moins une enveloppe tenant V2 non vide, une vide et une globale ; clés/nonce/AAD/plaintext/output hex/base64 littéraux, provenance conservée ; calcul de référence indépendant ou vérification indépendante avant gel. Vecteurs NIST/RFC existants conservés en tests privés. Aucun ciphertext de référence recalculé par l'implémentation testée. Fixtures V1 étiquetées historiques, tests de rejet explicite par V2.

**Fuzzing réel.** Cibles enveloppe sur bytes arbitraires et UTF-8 invalide, contexte, PHC et séquence de rotation. `fuzz/` possède son propre `[workspace]` et son lockfile dans le crate pour ne pas toucher la racine ; libfuzzer-sys outil de test, pas dépendance crypto de production. Campagne initiale >=30 minutes par cible, max_len enveloppe borné au protocole ; PHC vérifie surtout parsing/budgets, sans lancer en boucle du 128 Mio sur données arbitraires. Corpus de frontières et régressions persisté ; timeout/OOM étudiés et non supprimés par désactivation d'assertions. Le nombre d'heures et la plateforme effectivement exécutés figurent au rapport, sans équivalence à certification.

**Commandes après implémentation**, depuis la racine, avec versions de toolchain et résultats enregistrés :

```sh
cargo test --locked -p lyxal_crypto --all-targets
cargo test --locked -p lyxal_crypto --doc
cargo clippy --locked -p lyxal_crypto --all-targets -- -D warnings
cargo doc --locked -p lyxal_crypto --no-deps
```

Format : invocation rustfmt en `--check` sur les seuls fichiers Rust du crate, sans appliquer `cargo fmt --all` au workspace. Documentation : warnings traités en erreur et revue des exemples. Source propre : `#![forbid(unsafe_code)]`, aucune implémentation locale des primitives, aucun `unwrap/expect/panic` en production ; exceptions de tests clairement séparées. Le code unsafe des dépendances n'est pas interdit par cet attribut : l'inventaire de leurs backends reste requis.

Autres contrôles : toolchain courant et MSRV réellement déclaré compilés ; Linux x86_64 exécuté ; compilation Windows/ARM pour le noyau portable et tests natifs des providers avant annonce de support. `cargo audit` à installer comme outil de contrôle puis scan borné au graphe pertinent y compris dev, DB RustSec figée et datée ; inventaire versions/features/licences, aucune alerte applicable ignorée sans décision explicite. Pas de modification silencieuse du lockfile pour faire passer un contrôle.

**Acceptation** : A01..A16 traités par preuve ou risque explicitement accepté par le CTO ; suite précédente conservée/adaptée sans perdre d'assertion ; tous les critères ci-dessus avec résultats réels ; aucune sortie secrète dans diagnostics ; aucune substitution silencieuse ; `Current` authentifié ; budget PHC avant calcul ; snapshot et révocation documentés ; format V2 littéral gelé après validation ; aucune modification suivie hors du crate. Une campagne non exécutée reste marquée non exécutée et empêche la revendication correspondante.

### 7.9 Décisions extérieures nécessaires et périmètre de phase B

**Point concret hors mandat : `Cargo.lock` racine.** Il ne contient actuellement aucune dépendance zeroize pour les entrées aes/aes-gcm/argon2. Activer leurs features optionnelles ajoute des arêtes dans ce lockfile, même si `zeroize` est déjà présent ailleurs. Ajouter aes/ghash/polyval en dépendances directes pour activer leurs features modifie aussi l'entrée lyxal_crypto ; ajouter subtle 2.6.1 directement pour §7.10 y ajoute une autre arête. Ce n'est pas contournable proprement par `--locked`. La liste des décisions et leur statut est centralisée au §7.14.

Proposition recommandée, soumise à **autorisation séparée** : permettre une mise à jour minimale et revue de `Cargo.lock` exclusivement pour les arêtes/features mémoire et la dépendance directe subtle de ce crate, **sans mise à jour de version**, sans modification du Cargo.toml racine, sans changement d'autres crates. Cette autorisation n'est ni supposée ni incluse automatiquement dans l'approbation de ce plan. Tant qu'elle manque, les parties dépendantes sont bloquées ; ne pas créer de lockfile alternatif utilisé pour prétendre que le workspace officiel a été validé.

Si le backend fichier doit résister à la modification hostile d'ancêtres du chemin, étendre séparément le mandat aux arêtes de dépendance d'une bibliothèque OS reconnue est également nécessaire. La variante de base n'affirme pas cette protection.

**Consommateurs.** La refonte cassera des usages Booking (alias, constructions `SecretString::new`, provider/résolution, accès plaintext) et potentiellement d'autres modules. L'inventaire indicatif existe ; aucune correction ni compilation complète de Booking n'est incluse dans ce mandat. Un guide de migration est livré dans le crate. Toute modification d'un consommateur, des données dev, des clés, de CI globale ou des règles nécessite une tâche/autorisation distincte. Les tests du crate seul ne prouvent pas que le workspace complet ou Booking compile après rupture.

### 7.10 R2 — États, snapshots, publication et rotation

#### 7.10.1 États et transitions autorisées

Chaque ID figure une seule fois dans un snapshot. Il est dans l'un des états suivants, représenté sans champ public mutable :

| État | Matériel dans le snapshot | seal | open | Transition locale autorisée |
|---|---|---|---|---|
| Active | `Arc<EncryptionKey>` | Oui, unique clé de scellement | Oui | Reste active ; devient decrypt-only lorsqu'une autre est activée |
| DecryptOnly | `Arc<EncryptionKey>` | Non | Oui | Active par décision explicite et conservation de son budget ; ou Revoked |
| Revoked | Aucun matériel, tombstone ID seulement | Non | Non, `KeyRevoked` | Revoked seulement ; aucune réactivation ni réimportation de cet ID |
| Absent | Aucun | Non | Non, `KeyUnavailable` | Insertion d'un nouvel ID par le builder, si aucune entrée/tombstone existante |

`insert` avec un ID présent échoue même si les bytes seraient identiques ; il ne modifie jamais l'entrée existante. Seules les opérations de changement d'état explicitement nommées sont possibles. `revoke(active)` échoue avec `ActiveKeyRevocation` ; activer une autre clé puis révoquer l'ancienne dans le builder est autorisé. `activate(active)` et `revoke(revoked)` sont des no-op idempotents ; `activate(revoked)` est une erreur. `revoke(absent)`/`activate(absent)` => `KeyUnavailable`. Les arguments entrants sont abandonnés/effacés selon leur propriété en cas d'erreur ; aucun état déjà construit n'est changé.

Un builder neuf peut être temporairement sans clé active ; `build(self)` ne réussit qu'avec **exactement une active**, <=64 IDs (tombstones compris) et des invariants valides. Une erreur de build ne publie rien ; le builder consommé est abandonné, les clés non partagées sont effacées. Aucun delete/purge public de tombstone : si la capacité est épuisée, erreur explicite. Une nouvelle politique de compaction du registre exige une décision distincte, pas l'oubli automatique d'une révocation.

#### 7.10.2 Construction, cohérence et publication

Construction initiale/restauration : charger le registre de confiance de l’hôte, restaurer ses tombstones via `insert_revoked` sans anciennes clés, charger les clés autorisées -> les insérer une seule fois -> choisir l’active -> `build` -> entourer d’un `Arc`. Aucune lecture d'environnement/fichier au milieu d'un chiffrement. `from_snapshot` copie les métadonnées et partage les Arc existants ; il ne clone pas les bytes des clés. La modification d'un builder ne modifie aucun snapshot existant.

Le trait public `KeyResolver` fournit **`snapshot()` uniquement**, pas une sélection active et une résolution pouvant venir de deux générations différentes. `StaticKeyResolver` rend toujours le même Arc. Un resolver hôte peut conserver l'Arc courant sous `std::sync::RwLock` : lecture brève pour clone de l'Arc, puis libération du verrou ; aucun verrou maintenu pendant Argon2, IO ou AEAD. Le crate n'impose aucune dépendance runtime et n'implémente pas un service de distribution de clés.

Publication par l'hôte : (1) préparer le candidat et les clés nécessaires hors section critique ; (2) prendre le verrou de publication ou utiliser un mécanisme équivalent avec comparaison de révision ; (3) comparer le candidat au snapshot **actuellement** publié via `validate_successor` ; (4) échanger l'Arc une seule fois ; (5) libérer le verrou. Si la génération de départ a changé entre préparation et publication, réexaminer/reconstruire le candidat ; aucune perte silencieuse de tombstone. Une affectation d'Arc non synchronisée n'est pas une publication atomique.

`validate_successor` impose : tout ID ancien conservé, aucune réactivation d'un tombstone, une active valide, et pour toute clé encore matérialisée sous un ID ancien, **mêmes 32 bytes**. La comparaison interne utilise `subtle::ConstantTimeEq`, jamais `==`/Debug/export de clés. Un ID ne peut pas recevoir un autre matériel sous prétexte d'un nouveau snapshot ; une transition vers Revoked peut retirer son matériel. Une construction entièrement indépendante peut satisfaire ses invariants locaux tout en remplaçant une ancienne clé : c'est précisément pourquoi la validation de succession est obligatoire à la frontière de publication. La dépendance directe `subtle 2.6.1`, déjà transitive, nécessite une arête de lockfile autorisée séparément (§7.14).

Le crate ne peut empêcher un hôte hostile de sauter cette vérification ou de réutiliser un ID après redémarrage. La correspondance durable ID/matériel, les budgets et tombstones doivent être restaurés par l'hôte à partir d'un registre de confiance. Cette responsabilité n'est pas présentée comme automatiquement imposée à tous les processus par une structure Rust.

#### 7.10.3 Opérations et échecs

`seal`, `open` et `reencrypt_if_needed` appellent `snapshot()` **exactement une fois**. Un échec de capture remonte sans opération cryptographique et sans fallback à une ancienne capture. Une opération conserve son Arc jusqu'à la fin ; la publication concurrente d'une nouvelle active ne change pas ses clés en cours de calcul.

Rotation : (1) capturer S ; (2) résoudre la source dans S et refuser Absent/Revoked ; (3) reconstruire l'AAD et authentifier source ; (4) si source ID == active de S, rendre `Current`, après effacement du plaintext temporaire ; (5) sinon sélectionner la paire active dans S, produire un nouveau nonce et sceller le plaintext sous cette paire ; (6) effacer le plaintext temporaire et rendre `Rotated`. Ne pas appeler une méthode publique `seal/open` qui recapturerait un autre snapshot : utiliser des helpers privés recevant S. Échec RNG/AEAD/résolution => aucune nouvelle enveloppe livrée ; l'enveloppe source n'est jamais modifiée.

Une publication concurrente S+1 peut donc rendre obsolète la cible de S juste après l'opération ; ce n'est pas une incohérence. `Current` et `Rotated` sont relatifs à S. La migration hôte peut vérifier la révision publiée et refaire un passage ; elle ne doit pas annoncer que toutes les données sont sous « la dernière clé » sur la seule base d'un résultat individuel.

#### 7.10.4 Retrait contrôlé et incident

Séparer trois opérations : sélection d'une active, migration des données, révocation/destruction. Migration hôte : conserver l'ancienne decrypt-only ; écrire le nouveau ciphertext avec transaction/CAS sur la version du record ; si l'enregistrement a changé, ne pas écraser avec un résultat obsolète. Contrôler toutes les partitions/tenants/files, reprises, sauvegardes et données en vol. Un inventaire de key IDs non authentifiés n'est pas une preuve suffisante d'achèvement.

Quand la politique autorise le retrait : publier un snapshot avec ancienne clé Revoked ; distribuer la révocation et stopper/renouveler les anciens processus ; attendre la fin des opérations autorisées en vol ; détruire les sources persistantes et sauvegardes selon politique de rétention, dans une tâche extérieure autorisée. Le crate n'a **aucune API supprimant un fichier de clé historique** ni un coffre externe. Perte de clé non sauvegardée => données non récupérables ; aucune régénération sous le même ID ne répare ces données.

Révocation d'urgence : peut rendre volontairement certaines données non lisibles avant migration ; décision hôte/CTO, pas une branche automatique du moteur. Un Arc encore détenu maintient le matériel vivant. Le dernier détenteur de l'ancienne clé entraîne son effacement local à la destruction ; cela ne prouve ni l'effacement d'autres processus, ni celui du stockage/swap. Une opération commencée sur S peut finir après révocation dans S+1 : l'hôte doit arrêter/annuler les processus si son exigence est l'interdiction immédiate.

Test supplémentaire de restauration : registre fictif durable composé d’IDs/états et de clés des seules entrées non révoquées ; recréer un builder après abandon de tous les snapshots initiaux, importer les tombstones sans matériel, vérifier `KeyRevoked`, refus d’activate/insert et conservation du tombstone. Le crate ne persiste pas ce registre.

Tests R2 : un resolver instrumenté compte une capture par opération ; changement de snapshot entre phases, source révoquée/manquante, absence de fallback, doublons et erreurs préservant le builder, succession avec ID substitué refusée, suppression de tombstone refusée, activation/idempotence et révocation d'active, migration CAS simulée sans IO externe, persistance des budgets lors d'une réactivation et effets explicitement limités d'un ancien Arc. Aucun mécanisme de révocation distribuée n'est simulé comme une garantie réelle.

### 7.11 R3 — Limites des clés : justification et responsabilités

#### 7.11.1 Limites cryptographiques et choix opérationnel

Référence : NIST SP 800-38D §5.2.1.1 (tailles), §8.2.2 et §8.3 (construction aléatoire des IV et budget d'invocations). Avec des IV aléatoires de 96 bits, la politique NIST comprend une limite de `2^32` invocations sous une même clé dans le cadre concerné, cumulée entre les instances/dispositifs ; ce plafond n'est pas un objectif à atteindre. Le protocole limite en outre chaque plaintext à 1 Mio, très en dessous du maximum GCM de `2^39−256` bits. Ces limites ne constituent pas à elles seules une analyse complète du risque de falsification.

Pour q nonces indépendants uniformes de 96 bits, la borne union donne `Pr[collision] <= q(q−1)/2^97` ; l'expression anniversaire exacte est `1−∏(1−i/2^96)` pour i=0..q−1. À `q=2^24`, la borne est strictement inférieure à **2^-49**, soit environ **1,78×10^-15**. À `2^32`, elle est proche de 2^-33 : le choix de 2^24 ménage donc un facteur d'environ 2^16 sur ce seul terme de risque. Ce nombre n'est **pas** une borne globale de sécurité GCM : volumes de blocs, tentatives de falsification, qualité du RNG et secret de la clé contribuent aussi.

`2^24` est retenu comme **budget opérationnel conservateur à faire approuver**, sans prétendre qu'il provient d'un besoin métier déjà mesuré. À 1000 scellements/s sous un même matériel, il est épuisé en environ 4,66 h ; une architecture à forte charge devra prévoir des clés indépendantes/rotations adaptées ou demander une autre politique justifiée. Renommer un ID, recréer un moteur, redémarrer une machine, réactiver une clé decrypt-only ou changer son usage/tenant ne remet jamais le compteur du même matériel à zéro. Les rechiffrements consomment le budget de leur clé cible ; une opération dont le succès n'est pas connu doit être comptée conservativement si un nonce a pu être utilisé.

Budget complémentaire proposé à l'hôte : au plus `2^20` authentifications AEAD échouées par matériel de clé avant blocage/rotation et investigation, avec contrôles d'abus par tenant. C'est un seuil de défense opérationnelle, pas un théorème de sécurité ni une protection interne au crate. Le nombre total de bytes de plaintext scellés est au plus `2^44` (16 Tio) si les deux bornes 2^24 invocations et 1 Mio/message sont respectées ; les payloads ajoutent nonce/tag. La politique hôte doit suivre aussi les volumes et tentatives pour son analyse GCM globale.

#### 7.11.2 Tableau des garanties réellement appliquées

| Contrôle | Appliqué par le crate cible | Responsabilité de l'hôte |
|---|---|---|
| Clé 32 bytes, nonce 12, tag 16 | Oui, types/AEAD ; aucune troncature ni nonce fourni publiquement | Provisionner du matériel aléatoire correct lors d'un import |
| Aléa de chaque scellement | `try_fill_bytes`, erreur propagée ; pas de fallback | Santé OS/VM, pas de duplication défectueuse de RNG ou contrôle complet de l'hôte |
| Taille message/AAD/enveloppe | Oui, bornes vérifiées avant allocation/calcul | Limiter les flux et allocations avant appel |
| Unicité absolue des nonces | **Non**, seulement tirage aléatoire | Ne pas annoncer cette garantie ; gérer le risque et les budgets |
| `q <= 2^24` par matériel global | **Non : aucun compteur durable/distribué dans ce crate** | Admission atomique/durable avant chaque scellement potentiel, agrégation de toutes les instances et alias |
| Échecs AEAD <=2^20 | **Non** | Comptage, rate limiting, investigation, blocage/rotation |
| Budgets à travers restart/restore/rotation | **Non** | Réservation durable, prise en compte d'opérations au résultat inconnu, pas de reset par renommage |
| Choix d'une clé active autorisée à chiffrer | Oui dans un snapshot valide | Ne publier aucune active dont le budget ou la politique d'usage est épuisé |

Pas de compteur local présenté comme une protection distribuée. Le contrat de déploiement de l'hôte DOIT préciser registre de matériel, réservation atomique d'invocations, comportement en partition réseau/échec du registre et procédure d'épuisement. En absence d'admission fiable, il ne peut pas annoncer le respect de ce budget en production ; le crate seul n'a pas les informations pour le certifier. Ces composants ne sont pas ajoutés à `lyxal_crypto` et aucune dépendance runtime n'est introduite.

Validation R3 : vérifier les calculs et unités ; tests de nonce de 12 bytes, erreurs CSPRNG, bornes de taille, aucune option publique de nonce ; contrôle documentaire de l'absence de compteur global ; plan hôte séparé pour budgets et simulation de refus d'une clé épuisée avant publication. Les tests d'uniquité sur quelques échantillons et une constante documentaire ne sont jamais des preuves de respect global.

### 7.12 R5 — Contrat définitif proposé des types sensibles (API V1)

Les signatures de §7.3 sont complétées ici par des invariants obligatoires. Aucun `unsafe` propre n'est autorisé pour contourner Drop ou lire de la mémoire libérée. Des allocations/états internes à RustCrypto restent soumis aux limites documentées ; un type opaque ne rend pas tout le processus opaque.

| Type et représentation privée | Constructeurs / conversions / exposition | Traits autorisés et refusés |
|---|---|---|
| `SecretBytes { inner: Zeroizing<Vec<u8>> }` | `new(Vec<u8>)->Result<Self>` prend propriété et protège avant validation, taille <=1 Mio ; `expose_secret(&self)->&[u8]`, `len`, `is_empty` ; `into_utf8(self)->Result<SecretString>` transfère l'allocation | Debug exactement `SecretBytes([REDACTED])`, Send/Sync/Unpin automatiques si la représentation les satisfait, marqueur ZeroizeOnDrop correctement implémenté ; aucun Clone/Copy/Default/Deref/AsRef/Borrow vers le contenu brut/Display/Eq/Hash/Serde ni conversion personnalisée révélant le contenu, aucune extraction en Vec brut |
| `SecretString { inner: Zeroizing<String> }` | `new(String)->Result<Self>` prend propriété, valide taille <=1 Mio ; UTF-8 garanti par String ; `expose_secret(&self)->&str`, `len` en bytes, `is_empty` ; `into_bytes(self)->SecretBytes` transfère l'allocation | Debug exactement `SecretString([REDACTED])` ; mêmes traits et interdictions que SecretBytes ; pas de conversion à String brut |
| `EncryptionKey { bytes: Zeroizing<[u8;32]> }` | `import(SecretBytes)->Result<Self>` exige 32 bytes ; `generate()->Result<Self>` ; exposition brute **privée au crate** pour opérations cryptographiques/providers, aucun export public | Debug exactement `EncryptionKey([REDACTED])` ; Send/Sync/Unpin, ZeroizeOnDrop ; aucun Clone/Copy/Default/Display/AsRef/Deref/Eq/Hash/Serde, aucune conversion implicite ; les Arc partagent le matériel sans le copier |
| `HmacKey { bytes: Zeroizing<[u8;32]> }` | `import(SecretBytes)->Result<Self>`, `generate()->Result<Self>` ; aucune conversion depuis EncryptionKey, ni inverse ; pas de sortie brute publique | Debug exactement `HmacKey([REDACTED])` ; mêmes restrictions que EncryptionKey |
| `PasswordHash { phc: SecretString }` | `parse(&str)->Result<Self>` vérifie format, budgets et politique avant copie ; `hash_password` construit un hash validé ; `expose_phc(&self)->&str` seul accès au PHC ; `needs_rehash(&self)->bool` uniquement sur valeur valide | Debug exactement `PasswordHash([REDACTED])` ; Send/Sync/Unpin, ZeroizeOnDrop ; aucun Clone/Copy/Default/Display/Deref/AsRef/Eq/Hash/Serde ni conversion implicite ; ne révèle ni sel ni digest par diagnostic |

Les implémentations identitaires automatiques de Rust (`From<T> for T`, `Into<T>` et `Borrow<T> for T`) sont permises : elles ne révèlent pas le contenu. Les restrictions interdisent les implémentations personnalisées de Borrow/AsRef/From/Into/Deref/Display/Clone/Copy/Serde qui exposent ou copient implicitement le contenu brut. Seules les conversions nommées et l’exposition explicite spécifiées sont offertes.

Pour les cinq types, l'interdiction de comparaison automatique couvre explicitement `PartialEq`, `Eq`, `PartialOrd` et `Ord`. Aucun `BorrowMut`/`AsMut` ni accès mutable brut public. Les auto-traits Rust supplémentaires liés à la sûreté de concurrence/unwind peuvent être dérivés de la représentation sans exposer le contenu ; ils ne constituent pas une promesse que Drop sera exécuté dans tous les scénarios.

`SecretBytes::new`/`SecretString::new` peuvent refuser une capacité de buffer supérieure au maximum accepté pour ne pas conserver un gigantesque buffer avec une petite longueur ; la condition cible est `len <= MAX_SECRET_BYTES` **et** `capacity <= MAX_SECRET_BYTES`. Le buffer transféré est effacé même sur refus, mais le coût de son effacement peut dépendre de la capacité excessive déjà allouée par l'appelant : aucune borne rétroactive n'est promise sur une allocation externe. Les parseurs réseau ne reçoivent pas ce buffer possédé arbitraire : ils bornent avant leur propre allocation. Le vide est représentable dans les types génériques ; une clé vide, un PHC vide ou un contexte vide est interdit par leurs constructeurs spécifiques.

`into_utf8` : aucune copie de contenu sur succès ; en cas de `FromUtf8Error`, récupérer le Vec interne, le protéger/effacer et retourner uniquement `InvalidUtf8`. Ne pas rendre `FromUtf8Error` ou ses bytes dans une source/Debug. `into_bytes` conserve l'allocation et sa protection. Pas de méthode `into_inner` publique. Les getters d'exposition sont des emprunts limités par Rust : ils n'exportent pas la propriété mais permettent volontairement à l'appelant de copier, sérialiser ou journaliser ; cette action explicite est hors protection automatique.

Pour que l'ouverture d'un message de taille maximale respecte aussi la borne de capacité du secret : allouer un buffer protégé de taille du ciphertext **hors nonce et tag**, puis utiliser le déchiffrement in-place à tag détaché. Ne pas réutiliser comme SecretBytes le Vec du payload contenant 28 bytes supplémentaires de capacité, ni réallouer un plaintext après coup pour satisfaire le constructeur. Tag et nonce restent des emprunts non secrets de l'enveloppe ; le buffer de sortie est effacé sur échec.

Import de clé : créer un tableau déjà protégé, copier exactement 32 bytes, abandonner/effacer la source possédée sur succès comme échec. Génération : protéger le tableau **avant** `try_fill_bytes` ; effacer un remplissage partiel si RNG échoue. PHC : `parse(&str)` ne peut pas effacer la chaîne empruntée de l'appelant ; son stockage interne est protégé et l'erreur ne contient pas l'entrée. `hash_password` protège également ses buffers temporaires de PHC avant conversion ; pas de `to_string` ordinaire conservant une copie oubliée.

Ces types n'implémentent pas publiquement `Zeroize` pour ne pas laisser une clé utilisée être transformée silencieusement en clé nulle encore utilisable ; l'effacement se fait à destruction de leur représentation et aux frontières internes nécessaires. Le marqueur `ZeroizeOnDrop` n'est pas une preuve d'absence de copies : une vérification des chemins de destruction est requise. Les diagnostics d'autres objets possédant ces types doivent déléguer à leur Debug masqué ou masquer le champ ; aucune implémentation manuelle de diagnostic n'appelle `expose_secret`/`expose_phc`.

Pour les buffers possédés : effacement explicite avant désallocation, y compris capacité allouée selon les garanties de zeroize, erreurs et conversions. Ne pas promettre que déplacement Rust, registres, compilateur, allocateur, dépendances, swap, dumps ou sauvegardes n'ont jamais conservé d'autre copie. Le workspace Argon2 doit être possédé/effacé sur tous les retours ; les fonctionnalités mémoire de ses blocks, AES et GHASH/POLYVAL sont qualifiées par backend, pas simplement cochées dans un manifeste. Aucune vérification ne lit une allocation libérée pour « prouver » cet effacement.

La garantie de destruction suppose l'exécution normale des destructeurs : elle ne couvre pas `mem::forget`, un `ManuallyDrop` de l'appelant, un abort, un processus tué ou une fuite volontaire d'Arc. Ces possibilités du langage/environnement ne sont pas rendues impossibles par le contrat de type et restent explicitement hors de l'assurance d'effacement local.

Tests R5 : sentinelles fictives dans les cinq types et structures englobantes, `format!("{:?}")` et `format!("{:#?}")` sans contenu ; compile-fail ciblés sur traits interdits avec dépendances présentes ; limites longueur/capacité ; import 0/31/32/33 bytes, RNG partiellement rempli en erreur, conversion UTF-8 valide/invalide sans perte d'effacement, PHC malformés/hostiles sans réflexion dans erreurs, et vérification de tous les retours qui abandonnent des secrets. L'absence de fuite dans les tests n'est pas une preuve de non-interférence complète du processus.

### 7.13 Invariants et matrice exhaustive A01–A16 → lots → acceptation

Invariants de sécurité à figer avec l'API : **I1** aucun diagnostic révélateur des types sensibles ; **I2** aucun remplacement de matériel sous un ID existant ; **I3** exactement une active par snapshot publié et une capture par opération ; **I4** aucun plaintext exposé avant authentification ; **I5** `Current` authentifié et relatif au snapshot ; **I6** encodage V2 canonique et contexte injectif/exact ; **I7** rejet des limites avant décodage/calcul ; **I8** fichier final absent ou complet, résultat de durabilité explicite ; **I9** destruction des buffers possédés sans promesse absolue ; **I10** erreurs d'aléa/IO explicites et non secrètes ; **I11** aucun mode global/legacy de secours ; **I12** aucune dépendance vers runtime/DB/métier ni garantie de quota/révocation globale inventée.

| Constat | Lots responsables | Critère mesurable minimal de validation cible |
|---|---|---|
| A01 | L1, L7 | C01 : Debug normal/alternatif des 5 types et englobants ne contient aucune sentinelle ; tests négatifs de traits dangereux |
| A02 | L3 | C02 : restauration après redémarrage via insert_revoked sans clé, réactivation/réimport refusés ; doublons actif/historique/révoqué refusés, état inchangé ; `validate_successor` refuse matériel différent sous même ID et tombstone perdu |
| A03 | L4 | C03 : FS-03, 16 processus ×100 rounds, aucun final partiel ni erreur de course ; déchiffrement croisé de toutes les sorties réussies |
| A04 | L3 | C04 : tag/nonce/contexte erroné sous ID actif => erreur, jamais Current ; une capture instrumentée par appel, zéro fallback |
| A05 | L1, L4, L5, L6 | C05 : inventaire de toutes les allocations sensibles, protection avant remplissage, chemins d'erreur/conversion exercés ; aucune String Base64/PHC ordinaire abandonnée dans les chemins propres |
| A06 | L5 | C06 : PHC sans sel/digest, sel hors limites et digest !=32 refusés à la construction ; `needs_rehash` impossible sur un type invalide |
| A07 | L2 | C07 : Acme/acme et records distincts ont AAD distinct ; cas interdits rejetés sans trim ; >=1000 propriétés incluant UTF-8 et frontières |
| A08 | L2, L3 | C08 : T1 réétiqueté k2 avec matériel identique => AuthenticationFailed ; trois fixtures exactes et modes disjoints |
| A09 | L4 | C09 : FS-01/02/04/05/06 ; droits/liens rejetés, interruptions et phases IO classifiées ; qualification ext4 et XFS séparée avant support annoncé |
| A10 | L5 | C10 : coûts au-dessus du budget rejetés avant entrée dans Argon2 via compteur privé de test ; frontières m/t/p et taille mot de passe exercées |
| A11 | L2, L4, L5 | C11 : limites exactes N−1/N/N+1 pour texte/payload/contexte/fichier/PHC/HMAC hex/HKDF ; preuve de rejet avant allocation proportionnelle non bornée |
| A12 | L1, L7 | C12 : toutes erreurs publiques testées avec sentinelles et contrôles ; aucun input, PHC, chemin ou source libre dans Debug/Display |
| A13 | L1, L4, L5 | C13 : RNG de clé, nonce, nom temporaire, sel injecté en échec => erreur typée, aucun panic ni fallback ; aucun expect/unwrap/panic de production |
| A14 | L6, L7 | C14 : graphe des features effectives, workspace Argon2 effacé sur tous retours, revue des Drop/backends qualifiés ; limites résiduelles décrites ; lot non accepté si lock nécessaire non autorisé |
| A15 | L2, L7 | C15 : T1/T0/G1 AAD/payload/tag/texte littéraux identiques à §7.4.5, contrôlés indépendamment ; aucun attendu recalculé ; V1 explicitement rejeté |
| A16 | L6, L7 | C16 : MSRV local déclaré effectivement compilé avec lock officiel, toolchain courant également ; aucune modification racine pour masquer l'écart |

Les critères supplémentaires R1–R5 sont §7.4 à §7.12 ; l'acceptation globale exige aussi Clippy strict, documentation, fuzzing et contrôles de périmètre §7.8. Un test impossible ou non exécuté reste noté tel quel. Une dérogation n'est pas un test passé : elle doit être signée et nommer le risque accepté avant de qualifier la cible pour la production.

### 7.14 Dépendances, autorisations et arbitrages restants

| Décision | Effet potentiel sur Cargo.lock racine | Autorisation / statut |
|---|---|---|
| Activer zeroize sur aes-gcm 0.10.3, argon2 0.5.3 et les états aes 0.8.4 / ghash 0.5.1 / polyval 0.6.2 qualifiés | Nouvelles arêtes optionnelles zeroize et éventuellement arêtes directes depuis lyxal_crypto ; versions actuellement présentes réutilisées | **Permission racine distincte nécessaire, non accordée** ; pas de mise à jour silencieuse de versions |
| Ajouter dépendance directe subtle 2.6.1 pour comparaison interne des clés lors de validation de succession | Paquet déjà verrouillé transitivement, mais nouvelle arête lyxal_crypto -> subtle | Même permission distincte, explicitement incluse dans la demande minimale ; pas de nouveau protocole crypto |
| Fixer rust-version local, candidat 1.85 | Pas d'arête de dépendance ni changement de version de paquet requis en soi | Inclus seulement dans phase B après validation ; confirmer par compilation, sinon revenir au CTO |
| Fuzz workspace séparé sous le crate, libfuzzer-sys outil de test | Lockfile séparé **dans** le crate ; pas de mutation racine | Création en L7 seulement, pas dans cette révision ; vérifier isolation effective |
| Backend fichier anti-ancêtres-hostiles via bibliothèque OS | Nouvelles dépendances/arêtes, éventuellement autres capacités OS | **Non retenu dans la variante de base** ; nécessite nouveau sous-mandat si cette menace doit être couverte |
| Publication du package en version 1.0.0 | Peut modifier entrée locale et lockfile | Pas incluse automatiquement : « API V1 » est le contrat cible, pas une publication ni un bump Cargo implicite |
| Adaptation Booking/autres consommateurs, CI globale, clés et données dev | Modifications extérieures | Interdit dans ce mandat, autorisation/tâche séparée nécessaire |

Arbitrages proposés à confirmer par le CTO : (a) accepter V2 strict sans support V1 ; (b) accepter le profil fichier Linux x86_64 ext4/XFS avec répertoire privé de confiance, et refuser son usage lorsque les ancêtres ne sont pas de confiance ; (c) retenir les budgets 2^24 scellements et 2^20 échecs comme exigences opérationnelles de l'hôte, non des quotas garantis par le crate ; (d) autoriser séparément les seules arêtes Cargo.lock mémoire/subtle, sans changement de version ; (e) accepter l'incompatibilité des consommateurs jusqu'à leur migration hors mandat. Les orientations a–c sont ici spécifiées, pas laissées à une improvisation d'implémentation ; leur validation finale reste celle demandée par le CTO.

La seule demande d'extension nécessaire pour exécuter intégralement la variante recommandée est une **autorisation explicite distincte de modifier minimalement Cargo.lock pour les arêtes mémoire et subtle listées**, sans toucher au Cargo.toml racine ni mettre à jour les versions. Elle ne vaut pas autorisation de code : phase B requiert toujours son propre accord. En son absence, L6 et la comparaison sécurisée de succession de L3 ne peuvent pas être annoncés complets ; aucun contournement `==`, lockfile parallèle officiel ou désactivation de contrôle n'est proposé.

## 8. Registre des décisions architecturales

| Décision proposée | Alternative évaluée | Justification et conséquence |
|---|---|---|
| D01 Conserver AES-GCM et primitives RustCrypto | Remplacer par un nouvel algorithme | Aucun défaut démontré de ces primitives justifiant une réécriture ; besoins traités par contrats et gestion des états |
| D02 SecretBytes/SecretString opaques | Conserver les alias et masquer dans chaque consommateur | Une protection dispersée laisse A01 ouvert ; rupture explicite autorisée avant production |
| D03 V2 avec header+contexte authentifiés | Réinterpréter silencieusement V1 ou maintenir deux piles par défaut | V1 est figé par son contrat ; nouvelle sémantique => nouvelle version ; aucune donnée production à préserver, moins de downgrade/fallback |
| D04 Identités exactes et tenant obligatoire | trim/lowercase et tenant default | Évite les équivalences implicites ; validation métier/normalisation à une frontière explicite de l'hôte |
| D05 Domaine global explicitement nommé | AAD vide public | Conserve les secrets infrastructure tout en séparant leurs usages et les données tenant |
| D06 Capture unique d'un snapshot et validation de succession | Appels ID/résolution venant de générations différentes ou remplacement d'Arc non validé | Source et cible appartiennent au même snapshot ; comparaison interne constant-time des clés existantes, publication atomique hôte, anciennes références explicitement limitées |
| D07 Publication std sans remplacement sous répertoire privé | Rename qui écrase, retry aveugle sur fichier vide, promesse anti-TOCTOU universelle | Concurrence légitime traitée, contraintes de filesystem explicites ; acteur contrôlant les parents exclu, sans garantie mensongère |
| D08 Bornes fixes versionnées | Allocations/coûts arbitraires ou configuration de politique illimitée | Contrat minimal et testable ; changement substantiel des limites revalidé avant version ultérieure |
| D09 PHC opaque, rehash après validation | bool sur chaîne malformée | État invalide non représentable, mismatch séparé de l'erreur ; pas de logique métier |
| D10 Réutiliser primitives hash et tests corrects | Réécriture générale et nouvelle hiérarchie de services | Le mandat n'exige pas une réécriture gratuite ; aucun nouveau module d'infrastructure non nécessaire |
| D11 Features mémoire et subtle avec permission lock séparée | Modifier la racine en silence, comparer les clés naïvement ou promettre un effacement absolu | Respect du périmètre et des invariants ; parties de L3/L6 conditionnelles tant que non autorisées |
| D12 Budget de 2^24 scellages et 2^20 échecs comme politique hôte | Constante documentaire présentée comme compteur distribué effectif | Calcul de collision explicite, pas de promesse de quota/révocation interprocessus par une bibliothèque en mémoire |
| D13 Contrat sensible fermé, conversions nommées et erreurs sans source libre | Conserver Deref/Clone/Serde implicites pour faciliter les consommateurs | API V1 de production distincte du protocole enc:v2 ; migrations consommateurs hors mandat |

## 9. Risques résiduels, récupération et arrêt de phase A

- Les secrets exposés volontairement et les allocations internes des bibliothèques peuvent être copiés ; zeroize n'efface pas rétroactivement les registres, anciennes copies, swap, dumps, snapshots ou sauvegardes. Sur ARM, notamment, certains backends POLYVAL 0.6.2 contiennent encore un TODO de zeroize : l'activation d'une feature ne suffit pas à annoncer une garantie uniforme.
- Un administrateur ou code ayant le contrôle du processus peut extraire les clés et forger des contextes ; aucune sécurité locale ne remplace l'isolation de l'hôte, sa chaîne de confiance et la gestion de ses dumps.
- Les random nonces ont un risque probabiliste ; quota par matériel de clé et contrôle de volume restent globaux à l'environnement. Aucun compteur local ne garantit à lui seul la sûreté distribuée.
- Un snapshot révoqué n'efface pas un ancien snapshot détenu par un autre processus. L'hôte doit arrêter/renouveler les instances, réconcilier les données migrées, conserver les historiques selon la politique puis détruire les anciennes clés et leurs backups autorisés. Ne jamais supprimer une clé uniquement parce qu'une enveloppe a retourné `Current`.
- Rejeu valide dans le même contexte, anti-rollback, sauvegarde/restauration des données et preuve d'achèvement d'une migration relèvent de transactions/révisions de l'application. Après perte de clé sans sauvegarde, il n'existe pas de récupération cryptographique.
- Les erreurs d'allocation arbitraire de l'hôte ne deviennent pas toutes récupérables ; les allocations contrôlées utilisent des réservations faillibles autant que possible et des limites avant copie. Dépendances et infrastructure restent susceptibles d'OOM/panic externe.
- Les tests de panne simulée ne sont pas une certification de filesystem ni une preuve après coupure électrique. Une qualification indépendante de l'environnement et un audit externe spécialisé restent requis avant un usage critique.
- La surface des dépendances et leurs alertes évolue ; la consultation RustSec datée ne couvre pas le futur ni toutes les vulnérabilités possibles.

**Arrêt obligatoire après la révision A-R2.** Livrables A (audit historique consolidé), B (menaces), C (architecture), D (API V1 / protocole V2 complet), E (lots/tests et matrice exhaustive), F (décisions), G (risques) réunis dans ce document ; R1 à R5 intégrées. Seul `crates/lyxal_crypto/implementation_plan.md` est révisé. Aucune source, test, manifeste, dépendance, clé ou donnée du dépôt n'est modifié ; aucun test ni code du crate exécuté dans cette révision. Aucun commit, push, merge ou déploiement. L'implémentation attend l'approbation explicite du CTO sur cette version finale proposée ; l'exception Cargo.lock mémoire/subtle exige sa propre autorisation distincte.


## 10. Mandat de phase B et clôture de L0

Le CTO autorise les lots L0, L6a, L1–L5, L6b, L7 sans validation intermédiaire obligatoire. Les indications « non accordée », « arrêt A-R2 » et « autorisation séparée nécessaire » des sections historiques documentent le statut antérieur : elles sont levées pour la seule exception Cargo.lock mémoire/subtle expressément identifiée, sans changement de version. Toute extension non prévue reste soumise aux conditions d’arrêt du mandat. Aucun autre crate, manifeste racine, fichier .agents, donnée ou clé extérieure ne sera modifié. Aucun commit/push/merge/déploiement.

L0.1 : insert_revoked et test de restauration ajoutés au contrat. L0.2 : implémentations identitaires standard distinguées des conversions personnalisées dangereuses. L0.3 : ordre L0 → L6a → L1 → L2 → L3 → L4 → L5 → L6b → L7 fixé. L0 relu avant toute édition Rust. Le rapport final sera IMPLEMENTATION_REPORT.md dans le crate ; seuls des résultats effectivement observés y seront déclarés.


## 11. Réception de phase B — état livré

Les lots L0 → L6a → L1 → L2 → L3 → L4 → L5 → L6b → L7 ont été exécutés dans le périmètre autorisé.
Le [rapport de clôture](IMPLEMENTATION_REPORT.md) décrit les 68 tests et 8 doctests réussis sous
Rust 1.85 et le toolchain courant, les campagnes de couverture effectivement retenues,
les preuves RustSec et le diff minimal du verrou. Le fuzzing retenu cumule trente minutes
par cible en trois sessions contrôlées ; les tentatives continues non validées restent tracées.
Les qualifications physiques ext4/XFS/panne électrique et les obligations hôte ne sont
pas déclarées réalisées. Cette clôture ne vaut pas certification ou mise en production.
Aucun autre crate ni fichier .agents modifié, aucun commit/push/merge/déploiement.
**Implémentation livrée pour réception ; attendre la décision CTO.**
