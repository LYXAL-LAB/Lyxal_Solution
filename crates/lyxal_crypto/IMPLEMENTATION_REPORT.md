# Rapport de clôture — phase B, architecture V2

Mandat CTO du 30 octobre 2026. **Réception technique avec réserves prononcée par le CTO
le 30 octobre 2026. Production : NON AUTORISÉE.** Ce rapport décrit les résultats réels ;
il ne constitue ni certification cryptographique, ni audit indépendant, ni autorisation
de production. La décision courante et les réserves officielles figurent en section 12.
Les avis et mentions d’attente des sections précédentes sont conservés comme historique
antérieur à cette notification ; ils ne remettent pas en attente la réception prononcée.
Base examinée : `0cb758c6f47dfd68c549787fa6eb24a3dd40338d`.

**Historique — avis préalable du 30 octobre 2026 (Europe/Paris) : recommandation de réception avec réserves, suivie de la décision CTO en section 12.**
Les preuves de phase B sont confirmées dans leur portée locale ; les qualifications physiques,
l’intégration des consommateurs et l’admission distribuée des clés ne sont pas acquises.
La section 11 donne les commandes, résultats, matrices de clôture et réserves vérifiés.
**Le module n’est pas autorisé pour la production par ce rapport.**


## 1. Périmètre et décisions réalisées

Les modifications sont limitées à `crates/lyxal_crypto/**` et aux neuf arêtes autorisées
du verrouillage racine. Aucun autre crate, manifeste racine, fichier `.agents`, consommateur,
clé ou donnée extérieure n'a été modifié. Aucun commit, push, merge ou déploiement.
Les installations de toolchains et artefacts de validation appartiennent à l'environnement.

Ordre suivi : **L0 → L6a → L1 → L2 → L3 → L4 → L5 → L6b → L7**.
L0 a précisé le contrat avant les changements Rust : tombstones sans matériel via
`insert_revoked`, distinction des conversions identitaires de Rust et conversions exposantes,
et séparation du lot dépendances/mémoire. Le mandat de phase B remplace les anciennes
mentions historiques d'attente d'autorisation dans le plan ; aucune approbation intermédiaire
n'était requise pour les lots autorisés.

L'ancienne API est remplacée sans compatibilité V1. Le crate reste une fondation autonome :
aucune dépendance runtime, SurrealDB, base de données ou métier. Les primitives restent
RustCrypto ; aucune primitive cryptographique maison, aucun code `unsafe` propre.
Les types sensibles sont opaques, les erreurs ne reflètent pas les entrées, l'aléatoire
est faillible. Le chiffrement utilise un snapshot immuable unique et des métadonnées
liées cryptographiquement. Le fournisseur fichier applique le profil `std` de répertoire
de confiance, sans prétendre résister à un acteur contrôlant les parents ou le processus.

## 2. API publique et protocole livrés

Le [contrat API](API_CONTRACT.md) donne les signatures, erreurs, conversions et obligations
hôte. La version Cargo reste `0.1.0` ; « API V1 de production » désigne le nouveau contrat,
aucune publication 1.0.0 n'est réalisée.

| Domaine | API finale |
|---|---|
| Secrets | SecretBytes, SecretString, accès `expose_secret`, conversions nommées, limites longueur/capacité |
| Clés | EncryptionKey et HmacKey distincts, import exact32 et génération faillible ; KeyId exact |
| Contexte | SecretContext::with_tenant / global ; aucune normalisation implicite |
| Enveloppe | EncryptedEnvelope::parse / encode / key_id ; parsing ne signifie pas authentification |
| Trousseau | KeyRingBuilder, KeyRing, KeyUse, KeyState, ResolvedKey, insert_revoked, validate_successor |
| Résolution | KeyResolver::snapshot et StaticKeyResolver ; aucune résolution séparée ID/matériel |
| Moteur | CryptoEngine::seal, open, reencrypt_if_needed ; Current authentifié ou Rotated |
| Fournisseurs | EnvironmentKeyProvider, FileKeyProvider, KeyGenerationPolicy explicite |
| Passwords | PasswordHash valide, hash_password, verify_password, PasswordVerification |
| MAC/KDF | HmacKey32, HMAC-SHA256 et hex strict, HKDF-SHA256 vers SecretBytes |
| Hash | SHA-256/BLAKE3 one-shot, hex et streaming conservés |

La [spécification V2 complète](ENVELOPE_FORMAT_V2.md) fixe les octets, valeurs interdites,
limites et trois vecteurs littéraux T1/T0/G1. Transport : `enc:v2:<key_id>:<base64url-sans-padding>`.
AES-256-GCM, nonce96 et tag128 ; payload nonce || ciphertext || tag. AAD avec préfixe,
version, suite, identifiant de clé, domaine tenant/global et champs exacts préfixés par
longueurs selon la spécification. Plaintext <=1 048 576 bytes, payload <=1 048 604,
texte <=1 398 211. Encodages non canoniques refusés ; V1 et versions non supportées rejetées.
Les nonces choisis et fonctions AES de bas niveau ne sont pas publics.
Le contrôle indépendant de phase B `python3 tools/check_fixtures.py` réussit également :
OpenSSL 4.0.1 / cryptography 50.0.0, contrôle NIST et trois fixtures, y compris reconstruction
des AAD et comparaison ciphertext/tag/payload/transport ; trace dans validation/independent-fixtures.json.

## 3. Matrice des constats et preuves

« Corrigé localement » ne signifie pas que les obligations de l'hôte ou les qualifications
physiques de stockage ont été réalisées. Les critères Cxx renvoient au plan A-R2.

| Constat | Lot / critère | Correction et preuve livrée |
|---|---|---|
| A01 | L1/L7, C01 | 5 types opaques ; Debug masqué ; secrets_v2, 85 traits interdits et 5 contrôles positifs |
| A02 | L3, C02 | Doublons refusés sans mutation ; rotation_v2 : actif/historique/révoqué, capacité, succession et restart avec tombstones |
| A03 | L4, C03 | Temporaire écrit/synchronisé puis hard_link sans remplacement ; file_v2 : 16 processus ×100 rounds, 1600 résolutions et déchiffrements croisés |
| A04 | L3, C04 | open avant Current ; rotation_v2 : contexte/tag/nonce/clé faux et capture instrumentée unique |
| A05 | L1/L4/L5/L6b, C05 | Allocations possédées protégées, conversions déplacées, temporaires Base64/PHC protégés ; inventaire mémoire ci-dessous |
| A06 | L5, C06 | PasswordHash construit seulement après validation complète ; password_v2 et password_tests : PHC incomplet/sel/digest/version |
| A07 | L2, C07 | Identités exactes, modes distincts ; protocol_v2, encryption, quatre propriétés de 1000 cas chacune dont substitution Unicode |
| A08 | L2/L3, C08 | key_id authentifié ; envelope_v2_fixtures : changement d'ID avec même matériel rejeté |
| A09 | L4, C09 | Droits/types/liens/chemins contrôlés ; file_v2 et injections privées ; ext4/XFS/panne électrique restent non qualifiés |
| A10 | L5, C10 | m/t/p et password bornés avant calcul ; compteur privé prouve que PHC rejeté n'entre pas dans le workspace Argon2 |
| A11 | L2/L4/L5, C11 | Parsing/lecture bornés, frontières de contexte/enveloppe/PHC/HMAC/HKDF ; tests protocol_v2, password_v2, file_v2, mac_kdf_v2, resource_boundaries |
| A12 | L1/L7, C12 | Erreurs structurées sans données libres ; secrets_v2/negative_tests : sentinelles, contrôles et diagnostics |
| A13 | L1/L4/L5, C13 | try_fill_bytes et RandomUnavailable ; injections privées clé AES/HMAC, nonce, nom temporaire et sel |
| A14 | L6a/L6b, C14 | Features zeroize effectives ; workspace Argon2 possédé/effacé ; limites des états internes documentées, aucune promesse absolue |
| A15 | L2/L7, C15 | T1/T0/G1 littéraux indépendants, AAD exacts, NIST/RFC ; aucun attendu d'enveloppe recalculé par l'implémentation testée |
| A16 | L6a/L7, C16 | MSRV local 1.85 ; compilation/tests/doctests/contrats effectifs sous 1.85 et toolchain courant |

| Révision CTO | État implémenté / preuve |
|---|---|
| R1 | Spécification V2 autonome et fixtures ; parsing canonique, métadonnées authentifiées, limites testées |
| R2 | États/succession/snapshot unique/rotation/restauration ; registre durable et publication atomique restent à l'hôte |
| R3 | Budget proposé2^24 justifié par borne collision de nonce <2^-49 ; quota distribué et échecs d'authentification non comptés par le crate |
| R4 | Atomicité/durabilité/nettoyage distincts ; std + répertoire de confiance, limites TOCTOU explicites ; qualifications physiques non exécutées |
| R5 | 5 contrats opaques, exposition nommée, Debug masqué, traits contrôlés et limites d'effacement mémoire explicites |

## 4. Résultats de validation par lot

Le conducteur reproductible est `python3 tools/validate.py` avec Cargo/Rust disponibles
et cache de dépendances préparé. Il utilise `--locked --offline`, uniquement `-p lyxal_crypto`.
Les tests de socket local nécessitent un contexte permettant l'IPC Unix.

| Lot | Résultat réel |
|---|---|
| L0 | Contrats corrigés dans implementation_plan avant code ; aucun consommateur modifié |
| L6a | Versions approuvées conservées ; features existantes ; MSRV1.85 effectif |
| L1 | Diagnostics masqués, conversions sans réallocation, UTF-8 invalide et longueur/capacité, RNG en erreur |
| L2 | Transport canonique, bornes minimum/maximum, contextes exacts, rejetV1, fixtures indépendantes et NIST |
| L3 | Doublons/transitions/tombstones/substitution/capacité ; rotation idempotente et capture unique |
| L4 | Concurrence1600 opérations ; liens/droits/corruption/objets spéciaux ; erreurs et interruptions aux 6 phases |
| L5 | PHC borné avant calcul, mauvais password, rehash, HMAC RFC4231 et HKDF RFC5869, frontières |
| L6b | Protection des buffers et workspace Argon2 ; revue des features et limites des copies |
| L7 | 68 tests réussis, 0 échec ; 8 doctests réussis ; Clippy -Dwarnings, rustfmt, rustdoc -Dwarnings ; campagnes détaillées ci-dessous |

Les mêmes **68 tests** et **8 doctests** passent sous Rust1.85.0 et 1.99.1.
Deux entrées sont marquées ignored dans chaque exécution de tête : il s'agit uniquement
des helpers enfants, effectivement invoqués par leurs tests parents : 1600 lancements
pour la concurrence et6 pour les interruptions. Aucun test de sécurité principal n'est ignoré.
Le banc de contrats compile 5 contrôles positifs et exige 85 échecs E0277 avec serde réellement
présent, sous les deux toolchains ; il distingue un trait absent d'une dépendance absente.
Les 8 doctests comprennent7 compile-fail et1 exemple d'usage exécuté.
Les quatre tests resource_boundaries ajoutent les frontières champ par champ, PHC/sel/digest/coûts, password, HMAC et HKDF.
Les anciens vecteurs AES/HMAC sont déplacés dans les modules privés pour garder les primitives
bas niveau hors API. Le cas3 RFC4231 historiquement étiqueté avec une clé32 est corrigé
pour la clé officielle20 ; le vecteur historique à clé32 est conservé séparément.
Les 4 propriétés exécutent chacune 1000 cas par toolchain. Le test de robustesse effectue
notamment 2000 corruptions d'un bit avec rejet authentifié. Il ne remplace pas le fuzzing.

## 5. Campagnes adversariales et stockage

Les injections privées (inaccessibles à l'API de production) couvrent création, écriture
partielle, synchronisation du fichier, publication, synchronisation du répertoire et
nettoyage. Six enfants sont arrêtés à ces barrières : aucun final partiel accepté ;
après publication, relecture possible d'un final complet. Cela simule un arrêt de processus,
pas une panne électrique. Les erreurs injectées aux barrières ne prouvent pas tous les
comportements d'un pilote retournant EIO à l'intérieur de chaque syscall.
Les 8 collisions de nom sont bornées, le temporaire étranger reste intact, et la panne RNG
n'entraîne aucune substitution. Le ctime n'est pas un invariant de lecture : la suppression
concurrente d'un hardlink temporaire modifie légitimement ce timestamp sans changer la clé.

Cas négatifs : final/parent symlink, répertoire, FIFO, socket Unix, modes0640/0604/0700/04600/0200,
parent public, contenu tronqué/non canonique/trop long ;0400 et0600 valides.
L'essai socket a initialement été bloqué par l'isolation de l'environnement avant appel
au fournisseur ; relance autorisée réussie, puis conducteur complet réussi dans ce contexte.
Aucune modification de la politique du fournisseur n'a masqué cette restriction.

## 6. Fuzzing guidé par couverture

Les quatre cibles `envelope`, `context`, `phc`, `rotation` utilisent cargo-fuzz 0.13.2,
libfuzzer-sys 0.4.13 et nightly 1.101.0 (92b5b8c87, 2026-10-29), instrumentation de couverture
et AddressSanitizer/LeakSanitizer actifs. PHC vérifie le parseur/budget sans lancer Argon2
à chaque entrée. Les seeds comprennent les formats valides, coûts excessifs et données
aux bornes ; rotation exerce les états et invariants de migration.

| Cible | Sessions validées | Secondes libFuzzer cumulées | Exécutions | Pic RSS (Mio) | Sorties |
|---|---|---|---|---|---|
| envelope | 3 ×600 s | 1803 | 78 644 193 | 404 | 0 / 0 / 0 |
| context | 3 ×600 s | 1803 | 706 877 641 | 507 | 0 / 0 / 0 |
| phc | 3 ×600 s | 1803 | 560 786 440 | 550 | 0 / 0 / 0 |
| rotation | 3 ×600 s | 1803 | 25 472 004 | 437 | 0 / 0 / 0 |

Les 12 sessions se terminent normalement, sans alerte sanitizer ni artefact de crash.
Total : 1 371 780 278 exécutions dans les sessions retenues.
La durée est cumulée en trois sessions par cible, avec le même corpus conservé.
Commandes, sorties, empreintes de binaires et statistiques complètes : validation/fuzz-summary.json
et validation/fuzz-<cible>-<session>.{json,log}. Les compteurs de couverture ne sont pas
un pourcentage de couverture ni une preuve d’absence de vulnérabilité.

Une première campagne de 1800 secondes par cible s'est terminée avec un échec de
LeakSanitizer lié à l'interdiction d'inspection ptrace du sandbox. Elle **ne compte pas
comme campagne réussie**, même sans crash d'entrée observé. Les traces sont conservées
séparément ; les artefacts vides correspondants ne sont pas présentés comme bugs de parsing.
Un essai de 1000 exécutions par cible a ensuite réussi dans le contexte d'exécution autorisé,
puis les quatre campagnes continues ont été relancées. Leur collecte finale a été perdue
lors de la reprise de l’environnement : processus retrouvés zombies, code noyau observé 0,
mais absence des statistiques finales et des enregistrements du superviseur. Cette deuxième
tentative **ne compte pas non plus comme campagne validée** ; ses traces sont conservées
sous fuzz-environment-interruption-*.
La campagne retenue utilise trois sessions de 600 secondes par cible, même corpus conservé,
avec résultat sauvegardé après chaque session : trente minutes cumulées, aucune prétention
d’une session continue validée. Le conducteur est `python3 tools/run_fuzz.py --seconds 1800 --segments 3`.
Une première exécution segmentée a été arrêtée avant son premier checkpoint pour corriger
le buffer d’erreur environnement non UTF-8 ; elle est exclue du bilan retenu.
Les sessions retenues utilisent le correctif final, testé sous les deux toolchains.
Les vingt premières minutes ont été sauvegardées ; les dix dernières ont été exécutées
dans un job séparé pour limiter la durée de chaque job d’outillage. Les sessions
inachevées lors de cette séparation sont exclues, sans changement de binaire ou de corpus.
Aucun sanitizer, assertion ou contrôle de sécurité n'a été désactivé et aucun sysctl n'a été modifié.

## 7. Dépendances, MSRV et Cargo.lock

MSRV local `rust-version = "1.85"` ; aucune modification du manifeste racine.
Versions approuvées exactes : aes-gcm0.10.3, aes0.8.4, ghash0.5.1, polyval0.6.2,
argon2 0.5.3 avec zeroize ; déclaration directe de subtle 2.6.1 avec
`default-features = false`. Cargo unifie les features transitives : le graphe effectif
est conservé dans validation/dependency-features.txt.
Les autres exigences du manifeste sont conservées. Les dépendances directes supplémentaires
AES/GHASH/POLYVAL servent à unifier les features d'effacement des versions déjà présentes.
Leur activation existe effectivement dans ces versions, sans remplacement de dépendance.

Le diff racine comporte **9 ajouts, 0 suppression**, seulement :

```diff
 aes 0.8.4:       + zeroize
 aes-gcm 0.10.3:  + zeroize
 argon2 0.5.3:    + zeroize
 ghash 0.5.1:     + zeroize
 polyval 0.6.2:   + zeroize
 lyxal_crypto:    + aes + ghash + polyval + subtle
```

Comparaison structurelle avec HEAD : mêmes packages, versions, sources et checksums ;
autres champs inchangés. Aucun cargo update général. Les workspaces autonomes fuzz et
contrats disposent de leurs verrous internes ; leurs versions runtime partagées ont été
comparées au verrou racine. serde du banc de contrats sert à vérifier l'absence réelle
de sérialisation, sans devenir dépendance de production.

Analyse RustSec avec cargo-audit 0.22.2 et base officielle commit
`2295466c4e9df26647fd67d8fa1c705ac2fc7f81` (1395 avis, consultée le 30 octobre 2026) :
**0 vulnérabilité connue, 0 avertissement**, sans ignore ni base périmée acceptée.
Trois contrôles : projection exacte du verrou racine sur la fermeture crypto/dev/plateformes
(104 packages), verrou fuzz, verrou du banc de contrats. La projection copie les blocs du
verrou officiel ; ce n'est pas un autre verrou ayant servi à compiler. Ce contrôle ciblé
n'est pas un audit RustSec du reste du monorepo. Les avis nouveaux restent à surveiller.

## 8. Inventaire mémoire et garanties démontrées

| État sensible | Protection effective / limite |
|---|---|
| SecretBytes/String | Zeroizing, capacité et longueur bornées ; accès nommé ; conversion d'allocation déplacée ; UTF-8 invalide effacé |
| EncryptionKey/HmacKey | Array32 protégé avant import/génération ; aucune copie publique ou Clone ; Arc pour partage |
| Plaintext AES-GCM | Copie de sortie déchiffrée protégée avant opération ; erreurs détruisent le buffer possédé |
| Nonce | Public et aléatoire ; aucun secret à effacer ni nonce fourni par appelant |
| Clé fichier/env | Octets OS possédés protégés, y compris environnement non UTF-8 ; buffers Base64 protégés ; environnement source/OS hors garantie |
| PHC/sel/digest | PHC possédé et temporaires encodés protégés ; exposer le PHC reste explicite |
| Argon2 | Workspace Vec<Block> fallible entouré de Zeroizing ; coûts contrôlés avant allocation |
| AES/GHASH/POLYVAL | Features zeroize activées sur versions et backend examinés ; pas de certification de toutes architectures |
| HMAC/HKDF | Clé/IKM et sortieHKDF protégés ; états internes/copies des dépendances et registres non intégralement effaçables par le crate |

Les preuves établissent les contrats API, la conformité des vecteurs, les rejets et
invariants testés, la résistance aux courses des scénarios exécutés et la compilation
sur les toolchains annoncées. Elles ne prouvent pas l'absence universelle de défaut.
Aucun diagnostic prévu n'expose directement les types sensibles ; une copie volontaire
par l'appelant via expose_secret/expose_phc reste sous sa responsabilité.
Pas de lecture après libération utilisée comme prétendue preuve d'effacement.

## 9. Risques résiduels et travaux avant production

- L'hôte doit fournir registre durable ID/matériel/tombstones/budgets, intégrité de sa
  restauration, publication verrouillée/CAS après validate_successor, admission et migration transactionnelle.
- Une opération garde son ancien snapshot ; révocation distante ou immédiate non garantie.
  Les 64 IDs incluent les tombstones : aucune compaction automatique ni réutilisation d'ID.
- Budget 2^24 par matériel et budget d'échecs AEAD sont des politiques hôte ; aucun compteur
  distribué automatique. Réserver pour le snapshot réellement utilisé, y compris une rotation possible.
- Anti-rejeu/rollback, autorisation des identités, concurrence Argon2 et limitation globale
  de ressources restent à l'hôte. La borne locale ne limite pas un nombre arbitraire d'appels simultanés.
- Profil fichier std dépend d'ancêtres de confiance : TOCTOU hostile, même UID malveillant,
  ACL/LSM/stockage distant ou processus compromis ne sont pas couverts par les seuls bits Unix.
- Effacement absolu non garanti : pile/registres/OS, swap/dumps, copies dépendantes,
  mem::forget, Arc conservés, abort et kill peuvent conserver des données ou empêcher Drop.
- Ancienne API volontairement rompue ; consommateurs non migrés conformément au mandat.
  Une intégration applicative séparée sera nécessaire avant usage réel. Aucune compilation
  globale du workspace ni validation des consommateurs n’est revendiquée.

**Non exécutés / non qualifiés :** montages ext4 et XFS réels, panne électrique/contrôleur,
NFS/SMB/FUSE, attaques sur parents exclus du modèle, test privilégié de mauvais UID réel,
Windows/macOS/ARM, audit temporel/microarchitectural et Miri. Une session continue unique
de trente minutes avec terminaison vérifiée n’a pas été validée ; les trente minutes
de la campagne retenue sont cumulées en trois sessions, comme indiqué au bilan. L'environnement est overlayfs ;
les tests de crash ne sont pas une qualification physique. Ces absences interdisent
l'annonce d'un backend de production ext4/XFS déjà qualifié.

Aucun arbitrage de version ou modification extérieure n'a été nécessaire. La réception CTO
porte sur l'implémentation livrée et ses preuves ; la qualification du support de stockage
et les obligations hôte restent des conditions de mise en production. Aucun déploiement
n'est effectué. **Arrêt après clôture de phase B ; attendre la décision CTO de réception.**

## 10. Inventaire exhaustif des fichiers

Statuts : A ajout, M modification, D suppression. Les tests supprimés de l’ancienne API
sont remplacés par les suites V2 et les vecteurs déplacés décrits plus haut. Les artefacts
de compilation et corpus générés ignorés ne sont pas des fichiers livrés.

| Statut | Fichier depuis la racine |
|---|---|
| M | `Cargo.lock` |
| M | `crates/lyxal_crypto/API_CONTRACT.md` |
| A | `crates/lyxal_crypto/CHANGELOG.md` |
| M | `crates/lyxal_crypto/Cargo.toml` |
| M | `crates/lyxal_crypto/ENVELOPE_FORMAT_V1.md` |
| A | `crates/lyxal_crypto/ENVELOPE_FORMAT_V2.md` |
| A | `crates/lyxal_crypto/IMPLEMENTATION_REPORT.md` |
| A | `crates/lyxal_crypto/MIGRATION_GUIDE.md` |
| M | `crates/lyxal_crypto/README.md` |
| M | `crates/lyxal_crypto/SECURITY.md` |
| A | `crates/lyxal_crypto/fuzz/.gitignore` |
| A | `crates/lyxal_crypto/fuzz/Cargo.lock` |
| A | `crates/lyxal_crypto/fuzz/Cargo.toml` |
| A | `crates/lyxal_crypto/fuzz/README.md` |
| A | `crates/lyxal_crypto/fuzz/fuzz_targets/context.rs` |
| A | `crates/lyxal_crypto/fuzz/fuzz_targets/envelope.rs` |
| A | `crates/lyxal_crypto/fuzz/fuzz_targets/phc.rs` |
| A | `crates/lyxal_crypto/fuzz/fuzz_targets/rotation.rs` |
| A | `crates/lyxal_crypto/fuzz/seeds/context_global` |
| A | `crates/lyxal_crypto/fuzz/seeds/context_tenant` |
| A | `crates/lyxal_crypto/fuzz/seeds/envelope_t1` |
| A | `crates/lyxal_crypto/fuzz/seeds/phc_excessive` |
| A | `crates/lyxal_crypto/fuzz/seeds/phc_valid` |
| A | `crates/lyxal_crypto/fuzz/seeds/rotation` |
| A | `crates/lyxal_crypto/implementation_plan.md` |
| M | `crates/lyxal_crypto/roadmap.md` |
| M | `crates/lyxal_crypto/src/cipher.rs` |
| A | `crates/lyxal_crypto/src/cipher_vectors.rs` |
| M | `crates/lyxal_crypto/src/context.rs` |
| M | `crates/lyxal_crypto/src/envelope.rs` |
| M | `crates/lyxal_crypto/src/error.rs` |
| M | `crates/lyxal_crypto/src/hash.rs` |
| M | `crates/lyxal_crypto/src/hmac.rs` |
| A | `crates/lyxal_crypto/src/hmac_vectors.rs` |
| M | `crates/lyxal_crypto/src/kdf.rs` |
| M | `crates/lyxal_crypto/src/key.rs` |
| M | `crates/lyxal_crypto/src/key_resolver.rs` |
| M | `crates/lyxal_crypto/src/lib.rs` |
| M | `crates/lyxal_crypto/src/password.rs` |
| A | `crates/lyxal_crypto/src/providers/environment.rs` |
| A | `crates/lyxal_crypto/src/providers/file.rs` |
| A | `crates/lyxal_crypto/src/providers/mod.rs` |
| A | `crates/lyxal_crypto/src/secret.rs` |
| D | `crates/lyxal_crypto/tests/aes_gcm_vectors.rs` |
| M | `crates/lyxal_crypto/tests/encryption.rs` |
| D | `crates/lyxal_crypto/tests/envelope_v1_fixtures.rs` |
| A | `crates/lyxal_crypto/tests/envelope_v2_fixtures.rs` |
| A | `crates/lyxal_crypto/tests/file_v2.rs` |
| M | `crates/lyxal_crypto/tests/fuzz_robustness.rs` |
| D | `crates/lyxal_crypto/tests/hmac_vectors.rs` |
| D | `crates/lyxal_crypto/tests/kdf_vectors.rs` |
| M | `crates/lyxal_crypto/tests/key_generation.rs` |
| M | `crates/lyxal_crypto/tests/key_resolver.rs` |
| A | `crates/lyxal_crypto/tests/mac_kdf_v2.rs` |
| M | `crates/lyxal_crypto/tests/negative_tests.rs` |
| M | `crates/lyxal_crypto/tests/password_tests.rs` |
| A | `crates/lyxal_crypto/tests/password_v2.rs` |
| M | `crates/lyxal_crypto/tests/proptests.rs` |
| A | `crates/lyxal_crypto/tests/protocol_v2.rs` |
| A | `crates/lyxal_crypto/tests/resource_boundaries.rs` |
| D | `crates/lyxal_crypto/tests/rotation_lifecycle.rs` |
| A | `crates/lyxal_crypto/tests/rotation_v2.rs` |
| A | `crates/lyxal_crypto/tests/secrets_v2.rs` |
| A | `crates/lyxal_crypto/tools/check_contracts.py` |
| A | `crates/lyxal_crypto/tools/check_fixtures.py` |
| A | `crates/lyxal_crypto/tools/contracts/.gitignore` |
| A | `crates/lyxal_crypto/tools/contracts/Cargo.lock` |
| A | `crates/lyxal_crypto/tools/contracts/Cargo.toml` |
| A | `crates/lyxal_crypto/tools/contracts/src/lib.rs` |
| A | `crates/lyxal_crypto/tools/run_fuzz.py` |
| A | `crates/lyxal_crypto/tools/validate.py` |
| A | `crates/lyxal_crypto/validation/Cargo.lock.diff` |
| A | `crates/lyxal_crypto/validation/README.md` |
| A | `crates/lyxal_crypto/validation/checks.json` |
| A | `crates/lyxal_crypto/validation/clippy.log` |
| A | `crates/lyxal_crypto/validation/contracts.log` |
| A | `crates/lyxal_crypto/validation/dependency-features.txt` |
| A | `crates/lyxal_crypto/validation/direct-dependencies.json` |
| A | `crates/lyxal_crypto/validation/docs.log` |
| A | `crates/lyxal_crypto/validation/doctests.log` |
| A | `crates/lyxal_crypto/validation/environment.json` |
| A | `crates/lyxal_crypto/validation/fmt.log` |
| A | `crates/lyxal_crypto/validation/fuzz-build.log` |
| A | `crates/lyxal_crypto/validation/fuzz-context-1.json` |
| A | `crates/lyxal_crypto/validation/fuzz-context-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-context-2.json` |
| A | `crates/lyxal_crypto/validation/fuzz-context-2.log` |
| A | `crates/lyxal_crypto/validation/fuzz-context-3.json` |
| A | `crates/lyxal_crypto/validation/fuzz-context-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-envelope-1.json` |
| A | `crates/lyxal_crypto/validation/fuzz-envelope-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-envelope-2.json` |
| A | `crates/lyxal_crypto/validation/fuzz-envelope-2.log` |
| A | `crates/lyxal_crypto/validation/fuzz-envelope-3.json` |
| A | `crates/lyxal_crypto/validation/fuzz-envelope-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-environment-interruption-context.log` |
| A | `crates/lyxal_crypto/validation/fuzz-environment-interruption-envelope.log` |
| A | `crates/lyxal_crypto/validation/fuzz-environment-interruption-phc.log` |
| A | `crates/lyxal_crypto/validation/fuzz-environment-interruption-rotation.log` |
| A | `crates/lyxal_crypto/validation/fuzz-environment-interruption.json` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-context.json` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-context.log` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-envelope.json` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-envelope.log` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-phc.json` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-phc.log` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-rotation.json` |
| A | `crates/lyxal_crypto/validation/fuzz-initial-sandbox-rotation.log` |
| A | `crates/lyxal_crypto/validation/fuzz-job-split-context-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-job-split-envelope-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-job-split-phc-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-job-split-rotation-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-job-split.json` |
| A | `crates/lyxal_crypto/validation/fuzz-permission-context.log` |
| A | `crates/lyxal_crypto/validation/fuzz-permission-envelope.log` |
| A | `crates/lyxal_crypto/validation/fuzz-permission-phc.log` |
| A | `crates/lyxal_crypto/validation/fuzz-permission-rotation.log` |
| A | `crates/lyxal_crypto/validation/fuzz-permission.json` |
| A | `crates/lyxal_crypto/validation/fuzz-phc-1.json` |
| A | `crates/lyxal_crypto/validation/fuzz-phc-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-phc-2.json` |
| A | `crates/lyxal_crypto/validation/fuzz-phc-2.log` |
| A | `crates/lyxal_crypto/validation/fuzz-phc-3.json` |
| A | `crates/lyxal_crypto/validation/fuzz-phc-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-pre-final-code-context-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-pre-final-code-envelope-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-pre-final-code-phc-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-pre-final-code-rotation-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-pre-final-code.json` |
| A | `crates/lyxal_crypto/validation/fuzz-rotation-1.json` |
| A | `crates/lyxal_crypto/validation/fuzz-rotation-1.log` |
| A | `crates/lyxal_crypto/validation/fuzz-rotation-2.json` |
| A | `crates/lyxal_crypto/validation/fuzz-rotation-2.log` |
| A | `crates/lyxal_crypto/validation/fuzz-rotation-3.json` |
| A | `crates/lyxal_crypto/validation/fuzz-rotation-3.log` |
| A | `crates/lyxal_crypto/validation/fuzz-summary.json` |
| A | `crates/lyxal_crypto/validation/independent-fixtures.json` |
| A | `crates/lyxal_crypto/validation/msrv-contracts.log` |
| A | `crates/lyxal_crypto/validation/msrv-doctests.log` |
| A | `crates/lyxal_crypto/validation/msrv-tests.log` |
| A | `crates/lyxal_crypto/validation/rustsec-fuzz.json` |
| A | `crates/lyxal_crypto/validation/rustsec-projection.json` |
| A | `crates/lyxal_crypto/validation/rustsec-projection.lock` |
| A | `crates/lyxal_crypto/validation/rustsec-tools-contracts.json` |
| A | `crates/lyxal_crypto/validation/rustsec.json` |
| A | `crates/lyxal_crypto/validation/scope.json` |
| A | `crates/lyxal_crypto/validation/source-sha256.json` |
| A | `crates/lyxal_crypto/validation/tests.log` |
| A | `crates/lyxal_crypto/validation/tooling-sha256.json` |


## 11. Vérification finale pour réception CTO

### 11.1 Périmètre de cette vérification et traçabilité

Mission de clôture du 30 octobre 2026, sans nouvel audit général ni modification fonctionnelle.
Seul ce rapport est complété. Les résultats historiques ci-dessous sont relus et rapprochés
au code livré ; aucune nouvelle exécution de la suite complète ou du fuzzing n’est revendiquée.
Les fixtures indépendantes, le complément rustfmt et RustSec sont également rejoués pendant
cette clôture. Les sorties brutes complètes de phase B sont conservées dans `validation/`.
Les comptages sont recalculés depuis les journaux, pas déduits d’un résumé antérieur.

Contrôles d’intégrité : **PASS**, 41 empreintes de sources/verrous dans
[source-sha256.json](validation/source-sha256.json), et 7 empreintes d’outillage dans
[tooling-sha256.json](validation/tooling-sha256.json), sans divergence.
Le périmètre comprend 149 fichiers ajoutés, modifiés ou supprimés par rapport à la base Git,
preuves comprises : inventaire exhaustif en section 10 et dans [scope.json](validation/scope.json).
Le fichier `tests/hash_vectors.rs`, non modifié, est néanmoins exercé par la suite.

### 11.2 Outils et commandes réelles

Versions relevées sur les toolchains conservés lors de la clôture :

| Outil | Version |
|---|---|
| rustc / Cargo courants | rustc 1.99.1, commit 58cf8f9c3 (2026-10-13) ; Cargo 1.99.1, commit 5f94df478 |
| MSRV | rustc 1.85.0, commit 4d91de4e4 ; Cargo 1.85.0, commit d73d2caf9 |
| Clippy | 0.1.99, commit 58cf8f9c35 |
| rustfmt | 1.10.0-stable, commit 58cf8f9c35 |
| Fuzzing | cargo-fuzz 0.13.2 ; libfuzzer-sys 0.4.13 ; rustc 1.101.0-nightly, commit 92b5b8c87 (2026-10-29) |
| Python / référence indépendante | Python 3.12.14 ; cryptography 50.0.0 ; OpenSSL 4.0.1 (9 juin 2026) |
| RustSec | cargo-audit 0.22.2 ; base officielle 1395 avis, commit 2295466c4e9df26647fd67d8fa1c705ac2fc7f81 |

Les commandes Cargo enregistrées ajoutent `--offline` aux options demandées : elles exécutent
les mêmes cibles avec le verrou officiel et le cache préparé. Les variantes littérales sans
`--offline` ne sont pas présentées comme des relances distinctes. Leurs vrais argv, durées et
codes de sortie figurent dans [checks.json](validation/checks.json). Le répertoire de travail
est `/workspace/Lyxal_Solution`. Les tests de socket et le fuzzing ont nécessité un contexte
d’exécution permettant l’IPC Unix et la terminaison de LeakSanitizer.

| Contrôle / outil | Commande exacte exécutée | Résultat et nombre | Preuve / réserve |
|---|---|---|---|
| Tests / Cargo 1.99.1 | `cargo test --offline --locked -p lyxal_crypto --all-targets` | 68 PASS, 0 échec, 2 helpers ignored ; code 0 | [tests.log](validation/tests.log) ; source/verrou identiques aux empreintes |
| Doctests / Cargo 1.99.1 | `cargo test --offline --locked -p lyxal_crypto --doc` | 8 PASS (7 compile-fail, 1 usage) ; code 0 | [doctests.log](validation/doctests.log) ; source/verrou identiques aux empreintes |
| Clippy 0.1.99 | `cargo clippy --offline --locked -p lyxal_crypto --all-targets -- -D warnings` | PASS, code 0 ; aucun warning | [clippy.log](validation/clippy.log) ; source/verrou identiques aux empreintes |
| Documentation / Cargo 1.99.1 | `RUSTDOCFLAGS="-D warnings" cargo doc --offline --locked -p lyxal_crypto --no-deps` | PASS, code 0 ; aucun warning | [docs.log](validation/docs.log) ; source/verrou identiques aux empreintes |
| MSRV / Cargo 1.85.0 | `cargo +1.85.0 test --offline --locked -p lyxal_crypto --all-targets` | 68 PASS, 0 échec, 2 helpers ignored ; code 0 | [msrv-tests.log](validation/msrv-tests.log) ; source/verrou identiques aux empreintes |
| Doctests MSRV / Cargo 1.85.0 | `cargo +1.85.0 test --offline --locked -p lyxal_crypto --doc` | 8 PASS ; code 0 | [msrv-doctests.log](validation/msrv-doctests.log) ; source/verrou identiques aux empreintes |
| Contrats / Python 3.12.14, rustc 1.99.1 | `python3 /workspace/Lyxal_Solution/crates/lyxal_crypto/tools/check_contracts.py` | PASS : 5 contrôles positifs et 85 rejets E0277 attendus ; code 0 | [contracts.log](validation/contracts.log) ; source/verrou identiques aux empreintes |
| Contrats MSRV / Python 3.12.14, rustc 1.85.0 | `RUSTUP_TOOLCHAIN=1.85.0 python3 /workspace/Lyxal_Solution/crates/lyxal_crypto/tools/check_contracts.py` | PASS : mêmes 5 contrôles et 85 rejets ; code 0 | [msrv-contracts.log](validation/msrv-contracts.log) ; source/verrou identiques aux empreintes |

Rustfmt : **PASS**, code 0, sur les 37 fichiers Rust `src/`, `tests/` et `fuzz/fuzz_targets/`,
avec rustfmt 1.10.0. La sortie [fmt.log](validation/fmt.log) est vide, conformément au succès ;
le code de sortie est enregistré dans checks.json. Commande complète :

```sh
rustfmt --edition 2021 --check \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/fuzz/fuzz_targets/context.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/fuzz/fuzz_targets/envelope.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/fuzz/fuzz_targets/phc.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/fuzz/fuzz_targets/rotation.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/cipher.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/cipher_vectors.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/context.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/envelope.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/error.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/hash.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/hmac.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/hmac_vectors.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/kdf.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/key.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/key_resolver.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/lib.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/password.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/providers/environment.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/providers/file.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/providers/mod.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/src/secret.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/encryption.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/envelope_v2_fixtures.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/file_v2.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/fuzz_robustness.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/hash_vectors.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/key_generation.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/key_resolver.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/mac_kdf_v2.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/negative_tests.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/password_tests.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/password_v2.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/proptests.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/protocol_v2.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/resource_boundaries.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/rotation_v2.rs \
  /workspace/Lyxal_Solution/crates/lyxal_crypto/tests/secrets_v2.rs
```

Complément rejoué en clôture, **PASS**, code 0, sortie vide :
`rustfmt --edition 2021 --check crates/lyxal_crypto/tools/contracts/src/lib.rs`.
Cela porte à 38 les sources Rust contrôlées dans le périmètre du crate, hors artefacts générés.
Le formatage du reste du workspace est **NON EXÉCUTÉ**.

Fixtures indépendantes : `python3 crates/lyxal_crypto/tools/check_fixtures.py`, **PASS**, code 0,
rejoué en clôture sous Python 3.12.14. Un contrôle NIST et trois vecteurs V2 T1/T0/G1 ;
AAD, ciphertext, tag, payload, transport et réouverture concordent. La sortie correspond à
[independent-fixtures.json](validation/independent-fixtures.json). Ce contrôle OpenSSL est une
vérification d’interopérabilité indépendante de RustCrypto, pas un audit de sécurité externe.

Décompte exhaustif des 68 tests du journal principal (même résultat sous MSRV) :

| Binaire / suite | PASS | Échec | Helpers ignored |
|---|---|---|---|
| `unittests src/lib.rs` | 16 | 0 | 1 |
| `tests/encryption.rs` | 3 | 0 | 0 |
| `tests/envelope_v2_fixtures.rs` | 2 | 0 | 0 |
| `tests/file_v2.rs` | 5 | 0 | 1 |
| `tests/fuzz_robustness.rs` | 2 | 0 | 0 |
| `tests/hash_vectors.rs` | 4 | 0 | 0 |
| `tests/key_generation.rs` | 2 | 0 | 0 |
| `tests/key_resolver.rs` | 2 | 0 | 0 |
| `tests/mac_kdf_v2.rs` | 3 | 0 | 0 |
| `tests/negative_tests.rs` | 2 | 0 | 0 |
| `tests/password_tests.rs` | 1 | 0 | 0 |
| `tests/password_v2.rs` | 3 | 0 | 0 |
| `tests/proptests.rs` | 4 | 0 | 0 |
| `tests/protocol_v2.rs` | 4 | 0 | 0 |
| `tests/resource_boundaries.rs` | 4 | 0 | 0 |
| `tests/rotation_v2.rs` | 8 | 0 | 0 |
| `tests/secrets_v2.rs` | 3 | 0 | 0 |

Les deux helpers ignored sont lancés explicitement en enfants par leurs tests parents ;
ils ne représentent pas deux scénarios de sécurité abandonnés. Les doctests sont séparés
des 68 tests. Les 4 propriétés contiennent chacune 1000 cas ; ces cas ne sont pas comptés
comme 4000 tests unitaires supplémentaires.

### 11.3 Concurrence, injections et dépendances

| Contrôle | Commande réellement porteuse de la preuve | Résultat | Preuve précise et réserve |
|---|---|---|---|
| Multiprocessus | `cargo test --offline --locked -p lyxal_crypto --all-targets` ; également sous `cargo +1.85.0` | PASS | tests.log et msrv-tests.log : `multiprocess_publication_16_workers_100_rounds` ; `tests/file_v2.rs:139` |
| Injection de phases IO | mêmes commandes | PASS, 1 test parent / 6 phases | `providers::file::tests::failures_before_and_after_publication_are_distinct`, `src/providers/file.rs:335` ; tests.log |
| Interruption de processus | mêmes commandes | PASS, 1 test parent / 6 enfants arrêtés | `interrupted_process_never_leaves_an_accepted_partial_final`, `src/providers/file.rs:454` ; tests.log |
| Noms temporaires / RNG | mêmes commandes | PASS | `temporary_name_failures_are_bounded_and_preserve_foreign_files`, `partially_filled_rng_error_is_propagated`, `nonce_rng_failure_has_no_infallible_fallback`, `salt_rng_failure_precedes_expensive_hashing` ; tests.log |
| Features de dépendances | `cargo tree --offline --locked -p lyxal_crypto -e features` | PASS, graphe inspecté | [dependency-features.txt](validation/dependency-features.txt), versions dans [direct-dependencies.json](validation/direct-dependencies.json) |

Chaque suite multiprocessus lance 16 enfants synchronisés sur 100 rounds : 1600 chargements
enfants et 1600 enveloppes, plus 100 chargements de contrôle. Le parent ouvre les 1600 sorties
avec la clé finale gagnante ; les enfants terminent avec succès et aucun temporaire propre
ne subsiste. Ce test est exécuté dans chacune des deux suites de toolchain conservées.
La preuve correspond à cette campagne sur overlayfs ; aucune durabilité physique en découle.
Les commandes de filtrage d’un test particulier ne sont pas présentées comme ayant été
exécutées séparément : leurs résultats viennent des suites complètes ci-dessus.

Les injections IO utilisent des hooks privés après les étapes nommées ; elles ne forcent
pas toutes les erreurs de chaque syscall du noyau. Les échecs RNG sont simulés par un RNG
privé de test ; aucune panne réelle du générateur OS n’a été provoquée. Les arrêts d’enfants
valident la reprise logique et l’acceptation d’un final complet ; ils ne simulent pas la
perte des caches du contrôleur de stockage.

RustSec est rejoué en clôture sur la même base locale, sans téléchargement et sans ignore :

| Commande exacte / cargo-audit 0.22.2 | Résultat | Preuve conservée |
|---|---|---|
| `cargo audit --db /workspace/.lyxal-tools/advisory-db --no-fetch --file /workspace/Lyxal_Solution/crates/lyxal_crypto/validation/rustsec-projection.lock --deny warnings --json` | PASS, code 0 ; 104 packages ; 0 vulnérabilité, 0 warning | [rustsec.json](validation/rustsec.json) ; résultats sécurité et dépendances identiques lors de la relance |
| `cargo audit --db /workspace/.lyxal-tools/advisory-db --no-fetch --file /workspace/Lyxal_Solution/crates/lyxal_crypto/fuzz/Cargo.lock --deny warnings --json` | PASS, code 0 ; 54 packages ; 0 vulnérabilité, 0 warning | [rustsec-fuzz.json](validation/rustsec-fuzz.json) ; résultats sécurité et dépendances identiques lors de la relance |
| `cargo audit --db /workspace/.lyxal-tools/advisory-db --no-fetch --file /workspace/Lyxal_Solution/crates/lyxal_crypto/tools/contracts/Cargo.lock --deny warnings --json` | PASS, code 0 ; 53 packages ; 0 vulnérabilité, 0 warning | [rustsec-tools-contracts.json](validation/rustsec-tools-contracts.json) ; résultats sécurité et dépendances identiques lors de la relance |

Le commit de base est vérifié séparément par
`git -C /workspace/.lyxal-tools/advisory-db rev-parse HEAD` ; l’arbre de cette base est propre.
Avec `--no-fetch`, cargo-audit laisse `database.last-commit` et `last-updated` à null : la
comparaison brute de ces métadonnées avec les anciens JSON a échoué. Le commit Git vérifié,
les 1395 avis, les dépendances, les settings, les vulnérabilités et les warnings concordent.
Cette différence de métadonnées est documentée ; les fichiers de preuve historiques restent intacts.

La projection d’audit est vérifiée indépendamment : fermeture transitive exacte de
`lyxal_crypto` dans le verrou racine, dépendances de tests et plateformes incluses, 104 packages.
Chaque bloc TOML est identique à celui du verrou officiel ; son empreinte correspond à
rustsec-projection.json. La projection n’a servi à aucune compilation.
Une absence d’avis connu est un résultat daté sur ces périmètres ; elle ne couvre ni le
reste du monorepo ni une analyse de vulnérabilités inédites du code propre.

### 11.4 Fuzzing : résultats et limites de la preuve

Chaque session retenue fait `-max_total_time=600 -timeout=10 -rss_limit_mb=2048
-print_final_stats=1`, avec `-max_len=1500000` pour envelope/context et `8192` pour phc/rotation.
L’argv intégral propre à chaque session, le binaire SHA-256, les horaires et le code de sortie
sont dans `validation/fuzz-<cible>-<n>.json`, n=1..3 ; les stdout/stderr complets sont dans
les `.log` correspondants. Ils sont recoupés avec [fuzz-summary.json](validation/fuzz-summary.json).
Les binaires des trois sessions d’une même cible ont la même empreinte enregistrée.
Les journaux confirment les compteurs instrumentés de couverture et `Done ... in 601 seconds`.

| Cible | Durée prévue / validée | Exécutions | Crash / timeout / OOM observés | Limite connue |
|---|---|---|---|---|
| envelope | >=1800 s / 1803 s cumulées (3 ×601 s) | 78 644 193 | 0 / 0 / 0 | Parser et canonicité ; les bytes non UTF-8 sont écartés par le harnais avant l’API `&str` ; pas de fuzzing AEAD hostile complet |
| context | >=1800 s / 1803 s cumulées | 706 877 641 | 0 / 0 / 0 | UTF-8, global et 5 champs séparés par NUL ; pas une preuve d’injectivité exhaustive de l’AAD |
| phc | >=1800 s / 1803 s cumulées | 560 786 440 | 0 / 0 / 0 | Parsing/budgets/rehash ; aucun calcul Argon2 arbitraire par entrée, aucune campagne de charge simultanée |
| rotation | >=1800 s / 1803 s cumulées | 25 472 004 | 0 / 0 / 0 | Scénario à clés fixes et branches pilotées par flags ; entrées >4096 bytes ignorées ; pas un générateur de longues suites arbitraires, ni un test de publication hôte concurrente |

Les 12 codes sont 0, aucune alerte sanitizer ou artefact de crash/timeout/OOM ne figure dans
les traces retenues ; les quatre répertoires `fuzz/artifacts/<cible>/` sont vides au contrôle.
Cela constate zéro événement dans ces sessions, sans garantir l’absence universelle de
crash, de timeout ou d’OOM. Les compteurs de couverture ne sont pas un taux de couverture.
Le fuzzing ne couvre pas les permissions, l’IO fichier ou l’environnement : ces chemins
reposent sur les tests d’intégration et injections séparés.

**Écart à soumettre au CTO :** aucune session continue de 30 minutes avec terminaison
contrôlée n’est validée. La durée cumulée prévue est atteinte pour les quatre cibles ;
chaque session individuelle de 601 s est inférieure à 1800 s. La segmentation est une
réserve explicite de méthode de validation, à ratifier en réception. Les essais courts
1000 itérations, les interruptions d’environnement et les sessions arrêtées avant la fin
sont exclus du total de 1 371 780 278 exécutions. Leurs durées complètes ne sont pas
certifiables en l’absence de sortie finale ; les essais courts ne satisfont pas 30 minutes.
Les échecs de LeakSanitizer des premières tentatives restent des échecs environnementaux
consignés en section 6 ; ils ne deviennent pas des PASS par incorporation aux cumuls.

Corpus conservés au contrôle de clôture :

| Cible | Répertoire généré | Fichiers | Octets | SHA-256 d’inventaire |
|---|---|---|---|---|
| envelope | `fuzz/corpus/envelope/` | 288 | 3568839 | `7361ec0870285c5b0631ea14f7e4daeea06fb9c1677d0f5fccca76ca725623f1` |
| context | `fuzz/corpus/context/` | 218 | 4268 | `1379972fa353e4954708f1add3b66b346ee25be2e37ae752fc63bdd6301649da` |
| phc | `fuzz/corpus/phc/` | 218 | 12763 | `a90687027288d3ba8c23d00818f5cd5886a86a7bdadc08b18104e6aada40007b` |
| rotation | `fuzz/corpus/rotation/` | 77 | 32073 | `64adc104af3253d3f0d706914e7bdd0002f379ea76d80e861e5557f857cf68e2` |

L’empreinte ci-dessus est SHA-256 de la concaténation UTF-8 triée `nom:SHA256(contenu)\n`.
Les six seeds versionnés sont `context_global`, `context_tenant`, `envelope_t1`,
`phc_valid`, `phc_excessive`, `rotation`, dans `fuzz/seeds/`. Les corpus générés et artefacts
sont ignorés par Git, présents dans l’environnement mais non distribués par un simple
checkout : leur archivage externe durable est une réserve de conservation des preuves.
Aucun nouveau cas de régression issu d’un crash n’a été découvert dans les sessions retenues ;
les cas négatifs fixes restent dans les tests et seeds livrés. Aucun corpus ignoré n’est
présenté comme versionné ou sauvegardé hors de cet environnement.

### 11.5 Matrices exhaustives de clôture

PASS signifie ici « correctif local et preuve correspondante confirmés ». Les réserves
ne sont pas converties en tests réussis. Les qualifications extérieures restent NON EXÉCUTÉES.
Les références de tests se trouvent dans tests.log et msrv-tests.log sauf mention contraire.

| Anomalie | Correctif précis | Test / preuve | Résultat | Risque résiduel explicite |
|---|---|---|---|---|
| A01 | src/secret.rs:25,91 ; key.rs:59 ; password.rs:31 : types opaques, Debug masqué | tests/secrets_v2.rs::diagnostics_never_expose_secrets ; password_v2::password_roundtrip_policy_and_redaction ; contracts.log (85 rejets) | PASS local | Exposition explicite, copies et logs effectués par l’appelant hors garantie |
| A02 | src/key_resolver.rs:69,111,201 : doublons, tombstones, validate_successor | rotation_v2::{duplicate_and_failed_transitions_never_mutate, duplicate_historical_material_is_not_replaced, restoring_tombstones_needs_no_destroyed_key, successor_rejects_substitution_and_forgotten_tombstones} | PASS local | Authenticité du registre restauré et CAS de publication à l’hôte |
| A03 | src/providers/file.rs:209 : temporaire complet puis hard_link sans remplacement | file_v2::multiprocess_publication_16_workers_100_rounds ; 1600 enfants par suite | PASS local | Campagne sur overlayfs ; durabilité ext4/XFS non qualifiée |
| A04 | src/lib.rs::reencrypt_if_needed : authentification avant Current, une capture | rotation_v2::{current_requires_authentication_and_wrong_same_id_key_fails, each_operation_captures_exactly_once, complete_rotation_and_retirement} | PASS local | Current relatif au snapshot capturé ; pas une preuve de migration globale |
| A05 | src/secret.rs:50,116 ; providers/environment.rs:10 ; cipher.rs ; password.rs : buffers possédés protégés | secrets_v2::conversions_preserve_allocation_and_reject_invalid_utf8 ; key_resolver::non_unicode_environment_errors_are_redacted_and_invalid_names_fail ; revue mémoire §8 | PASS local | Absence de copies absolue non démontrable ; pile/registres/OS et états internes de dépendances |
| A06 | src/password.rs:37,80 : PasswordHash valide avant needs_rehash | password_v2::{invalid_phc_and_excessive_costs_never_start_hashing, stronger_cost_is_not_automatically_downgraded} ; password_tests::accepted_weak_hash_verifies_and_requests_upgrade | PASS local | Politique métier et persistance du rehash à l’hôte |
| A07 | src/context.rs:43,81,91 : identités exactes et domaines disjoints | encryption::every_context_component_and_domain_is_authenticated ; negative_tests::context_boundaries_and_unicode_identity_are_precise ; proptests::distinct_valid_contexts_reject_substitution (1000 cas) | PASS local | Autorisation des identités par l’hôte ; aucune vérification métier du tenant |
| A08 | src/context.rs:91 ; lib.rs::seal/open : key_id dans AAD | envelope_v2_fixtures::changing_routing_metadata_is_detected_even_with_identical_key_material | PASS local | Alias de matériel ne créent pas un nouveau budget de clé |
| A09 | src/providers/file.rs:90,118,131,137,187 : droits/types/liens/sync/erreurs | file_v2::{strict_mode_symlinks_permissions_and_corruption_fail_closed, special_files_parent_links_and_permission_variants_are_rejected} ; injections §11.3 | PASS local | Qualification physique NON EXÉCUTÉE ; parents de confiance et limites TOCTOU ; pas de résistance au même UID hostile |
| A10 | src/password.rs:80,167 : admission m/t/p et password avant workspace | password::tests::rejected_input_never_enters_workspace_allocation ; resource_boundaries::phc_salt_digest_and_cost_boundaries_do_not_require_hashing | PASS local | Concurrence, admission et rate limits globaux à l’hôte |
| A11 | src/envelope.rs:15 ; context.rs ; providers/file.rs:137 ; password.rs ; hmac.rs ; kdf.rs : limites | protocol_v2::maximum_wire_size_and_minimum_empty_payload_are_exact ; resource_boundaries (4 tests) ; file_v2::key_file_formats_and_private_parent_are_strict | PASS local | Entrées déjà allouées par l’hôte, allocations système et appels concurrents hors budget global local |
| A12 | src/error.rs : erreurs structurées sans contenu libre ; Debug des types sensibles | negative_tests::hostile_input_is_not_reflected_in_diagnostics ; secrets_v2 ; key_resolver::non_unicode_environment_errors_are_redacted_and_invalid_names_fail | PASS local | Tests de sentinelles et revue du schéma ; pas une preuve de tous les diagnostics des applications |
| A13 | src/key.rs:34 ; cipher.rs:8 ; password.rs::hash_with_rng ; providers/file.rs:62 : RNG faillible | key::tests::partially_filled_rng_error_is_propagated ; cipher::rng_tests::nonce_rng_failure_has_no_infallible_fallback ; password::tests::salt_rng_failure_precedes_expensive_hashing ; temporary_name_failures_are_bounded_and_preserve_foreign_files | PASS local | Défaillances injectées ; aucune panne OS réelle provoquée, OOM/abort externes possibles |
| A14 | Cargo.toml : zeroize AES/GHASH/POLYVAL/Argon2 ; password.rs:179 : workspace possédé | dependency-features.txt ; source-sha256.json ; suites sous deux toolchains ; inventaire mémoire §8 | PASS local | Revue statique et sémantique des propriétaires/Drop, sans mesure après libération ; backends ARM et effacement absolu non qualifiés |
| A15 | src/cipher_vectors.rs, hmac_vectors.rs ; tests/envelope_v2_fixtures.rs : constantes indépendantes | NIST AES/SHA, RFC4231, RFC5869 ; three_independent_literal_envelopes_open_exactly ; tools/check_fixtures.py et independent-fixtures.json | PASS local | Interopérabilité et vecteurs, sans certification ni audit externe de sécurité |
| A16 | Cargo.toml : MSRV local 1.85, verrou inchangé en versions | msrv-tests.log (68), msrv-doctests.log (8), msrv-contracts.log (5 contrôles / 85 rejets) | PASS local | MSRV du workspace global et consommateurs non validés par cette mission |

| Exigence | Réalisation / lots | Preuve / résultat | Réserve explicite |
|---|---|---|---|
| R1 | V2 canonique, domaines, AAD/framing et limites ; L2/L7 | PASS local : ENVELOPE_FORMAT_V2.md, tests AAD, protocol_v2, fixtures T1/T0/G1 et contrôle OpenSSL | Toute évolution substantielle future exige une nouvelle validation du protocole ; fuzzing non exhaustif |
| R2 | Snapshots immuables, Active/DecryptOnly/Revoked, succession, restauration ; L0/L3 | PASS local : 8 tests rotation_v2, capture unique et tombstones | Registre durable ID/matériel/états/budgets, tombstones, verrou/CAS et reprise à l’hôte ; pas de révocation rétroactive des anciens Arc |
| R3 | Justification du budget ; L6b/L7 et SECURITY.md | PASS documentaire : q(q−1)/2^97 <2^-49 pour q=2^24 ; distinction crypto/opérationnel explicite | Compteur distribué NON FOURNI et intégration hôte NON EXÉCUTÉE ; la borne nonce n’est pas la borne de sécurité GCM globale |
| R4 | Profil std Linux x86_64, publication/durabilité/nettoyage ; L4/L7 | PASS local : file_v2, injections et arrêts ; qualifications extérieures NON EXÉCUTÉES | Ancêtres de confiance, symlinks seulement observables, TOCTOU résiduel ; ext4/XFS et alimentation à qualifier |
| R5 | 5 types sensibles, conversions nommées, diagnostics et limites mémoire ; L1/L5/L6b | PASS local : secrets_v2, password_v2, traits négatifs et inventaire §8 | Exposition volontaire, copies OS/dépendances, abort, mem::forget et Arc conservés hors effacement garanti |

### 11.6 Périmètre et diff exact du verrouillage

Contrôle du dépôt : **PASS**. La liste courante des 149 chemins est identique à scope.json
et à la section 10. Tous appartiennent à `crates/lyxal_crypto/**` ou au seul `Cargo.lock`
racine. Aucun autre crate, consommateur, `Cargo.toml` racine, fichier `.agents` ou configuration
globale du workspace n’est modifié. Aucun commit, push, merge ou déploiement.
Dans la présente mission de réception, seul IMPLEMENTATION_REPORT.md est modifié ; les
149 chemins décrivent l’ensemble de la phase B, pas 149 nouvelles modifications de clôture.

Diff exact comparé octet pour octet avec [Cargo.lock.diff](validation/Cargo.lock.diff) :

```diff
diff --git a/Cargo.lock b/Cargo.lock
index b7439b17d..ea95e880d 100644
--- a/Cargo.lock
+++ b/Cargo.lock
@@ -36,6 +36,7 @@ dependencies = [
  "cfg-if",
  "cipher",
  "cpufeatures 0.2.17",
+ "zeroize",
 ]
 
 [[package]]
@@ -50,6 +51,7 @@ dependencies = [
  "ctr",
  "ghash",
  "subtle",
+ "zeroize",
 ]
 
 [[package]]
@@ -173,6 +175,7 @@ dependencies = [
  "blake2",
  "cpufeatures 0.2.17",
  "password-hash",
+ "zeroize",
 ]
 
 [[package]]
@@ -1543,6 +1546,7 @@ checksum = "f0d8a4362ccb29cb0b265253fb0a2728f592895ee6854fd9bc13f2ffda266ff1"
 dependencies = [
  "opaque-debug",
  "polyval",
+ "zeroize",
 ]
 
 [[package]]
@@ -2275,16 +2279,20 @@ dependencies = [
 name = "lyxal_crypto"
 version = "0.1.0"
 dependencies = [
+ "aes",
  "aes-gcm",
  "argon2",
  "base64 0.22.1",
  "blake3",
+ "ghash",
  "hex",
  "hkdf",
  "hmac",
+ "polyval",
  "proptest",
  "rand_core 0.6.4",
  "sha2",
+ "subtle",
  "tempfile",
  "thiserror 1.0.69",
  "zeroize",
@@ -2990,6 +2998,7 @@ dependencies = [
  "cpufeatures 0.2.17",
  "opaque-debug",
  "universal-hash",
+ "zeroize",
 ]
 
 [[package]]
```

| Arêtes ajoutées | Nombre | Justification |
|---|---|---|
| aes0.8.4 → zeroize ; aes-gcm0.10.3 → zeroize ; argon2 0.5.3 → zeroize ; ghash0.5.1 → zeroize ; polyval0.6.2 → zeroize | 5 | Activation des features mémoire approuvées, sur les versions déjà verrouillées |
| lyxal_crypto → aes0.8.4, ghash0.5.1, polyval0.6.2 | 3 | Déclarations directes pour unifier les features zeroize des états/schedules transitifs |
| lyxal_crypto → subtle2.6.1 | 1 | Comparaison du matériel dans validate_successor et comparaisons constantes ; déclaration directe sans default-features |

Comparaison TOML complète avec la base Git : mêmes ensembles de packages et mêmes versions,
sources, checksums et autres champs ; seules ces 9 dépendances sont ajoutées, aucune retirée.
Le diff comporte 9 lignes ajoutées, 0 supprimée. **Aucune version non autorisée n’a changé.**
Les verrous autonomes fuzz et contrats sont livrés dans le crate ; ils sont inclus dans
les contrôles d’empreintes et RustSec et n’ont pas été modifiés pendant cette clôture.

### 11.7 Qualifications extérieures et obligations restantes

| Qualification / obligation | État réel | Responsable / condition |
|---|---|---|
| ext4 local qualifié | NON EXÉCUTÉ | Campagne de stockage sur montage réel ; le succès overlayfs ne la remplace pas |
| XFS local qualifié | NON EXÉCUTÉ | Même exigence, qualification indépendante de celle d’ext4 |
| Panne électrique, contrôleur et perte de caches | NON EXÉCUTÉ | Infrastructure ; les 6 arrêts de processus sont des simulations distinctes |
| Hypothèses de répertoire de confiance | DOCUMENTÉES, non attestées pour un hôte réel | Parents absolus précréés, propriétaires administrés, parents0700/0500 et fichiers0600/0400 ; pas d’acteur contrôlant parents, même UID hostile ou processus |
| Registre de clés et tombstones durable | À L’HÔTE ; intégration NON EXÉCUTÉE | Garantir authenticité/intégrité de ID/matériel/états et restauration avant trafic ; ne jamais réutiliser un ID ni oublier un tombstone ; maximum64 IDs dans la lignée |
| Publication concurrente des snapshots | À L’HÔTE ; intégration NON EXÉCUTÉE | Construire hors verrou, validate_successor contre l’actuel et échange Arc dans une section critique/CAS ; journaliser/persister la génération autorisée |
| Budget global AES-GCM | DOCUMENTÉ ; compteur distribué NON FOURNI | <=2^24 scellements par matériel, agrégation de tous les processus/alias/restarts ; réserver pour le snapshot réellement utilisé avant appel, conserver une réservation à issue inconnue |
| Budget d’échecs d’authentification | Politique hôte, NON APPLIQUÉ automatiquement | Proposition <=2^20 échecs AEAD avant blocage/rotation/investigation ; admission globale et métriques |
| Révocation entre processus | Limite DOCUMENTÉE | Le nouveau snapshot refuse une clé Revoked, mais anciens Arc/opérations et autres processus ne sont pas annulés ; arrêt/renouvellement des instances à orchestrer |
| Rechiffrement et suppression des clés | À L’HÔTE ; intégration NON EXÉCUTÉE | Transactions/CAS de données, preuve d’achèvement, rétention/backups ; aucune suppression d’ancienne clé persistante par le crate |
| Audit externe de sécurité / certification | NON EXÉCUTÉ | Aucun rapport tiers spécialisé livré ; la validation architecturale CTO et le contrôle OpenSSL ne valent pas cette qualification |
| Autres limites | NON EXÉCUTÉ | Mauvais UID réel sous privilèges, Windows/macOS/ARM, Miri, audit temporel/microarchitectural, stockage NFS/SMB/FUSE, workspace global et intégration consommateurs |

### 11.8 Synthèse de réception et décision proposée

| Lot | État final vérifié |
|---|---|
| L0 | Livré : insert_revoked sans matériel, traits identitaires distingués, ordre des lots corrigé avant code |
| L6a | Livré : versions/features approuvées, MSRV local, verrou minimal confirmé |
| L1 | Livré : types opaques, erreurs et diagnostics masqués, RNG faillible |
| L2 | Livré : contexte exact, AAD/V2 canonique, limites et fixtures |
| L3 | Livré : snapshots, transitions, tombstones, capture unique, Current authentifié |
| L4 | Livré et PASS local ; qualification physique du stockage en réserve |
| L5 | Livré : PHC/budgets, rehash, HMAC/HKDF et buffers protégés |
| L6b | Livré dans les limites mémoire documentées ; aucune promesse absolue d’effacement |
| L7 | Preuves locales PASS ; fuzzing cumulé conforme en durée, continuité non validée ; qualifications externes en réserve |

Aucun défaut fonctionnel bloquant nouveau n’est mis en évidence par cette vérification
ciblée des preuves. Les résultats locaux A01–A16 et R1–R5 sont confirmés dans les limites
exposées ; aucune acceptation globale des risques ne doit être déduite des seuls PASS.
Aucune autorisation corrective n’est sollicitée et aucun code fonctionnel n’est modifié.

Écarts/réserves à ratifier : campagne de fuzzing fractionnée, tentatives incomplètes exclues,
corpus générés non versionnés, qualifications physiques et intégration hôte/consommateurs
non réalisées. L’option --offline des commandes conservées est explicitée. L’analyse
RustSec est datée et limitée aux fermetures concernées ; ses métadonnées --no-fetch sont
vérifiées par Git séparément. Aucun écart de version ou de périmètre du dépôt n’est constaté.

**Recommandation : réception avec réserves**, portant sur la livraison du crate et de ses
preuves locales. Le CTO doit ratifier le cumul des sessions de fuzzing et affecter les
qualifications de stockage, la conservation durable des preuves et les obligations hôte.
Cette recommandation ne vaut ni réception sans réserve, ni autorisation de production.
**Arrêt de la vérification ; attendre la décision CTO.**


## 12. Notification officielle de réception technique — 30 octobre 2026

### 12.1 Décision CTO et portée

**Décision officielle : RÉCEPTION TECHNIQUE AVEC RÉSERVES. Production : NON AUTORISÉE.**

Le CTO prononce la réception technique avec réserves de l’implémentation V2 de
`lyxal_crypto`. Les lots **L0, L6a, L1, L2, L3, L4, L5, L6b et L7** sont considérés comme
achevés au regard du rapport fourni. Les constats **A01 à A16** sont déclarés traités et
les exigences **R1 à R5** couvertes.

Cette décision repose sur les preuves de validation rapportées par Codex. Elle ne
constitue ni certification cryptographique, ni audit indépendant, ni autorisation de
production. Elle ne transforme aucune qualification non exécutée en qualification acquise.
Les sections 1 à 11, leurs résultats réels, matrices, réserves méthodologiques et traces
sont conservés ; la présente section consigne la décision postérieure et fait référence
pour le statut de réception actuel.

### 12.2 Validations ratifiées

| Validation prise en acte par le CTO | Résultat ratifié / preuve historique |
|---|---|
| Tests Rust et doctests | 68 tests et 8 doctests réussis ; validation/tests.log et doctests.log |
| Toolchains | Rust 1.85 et 1.99.1 validés ; msrv-tests.log, msrv-doctests.log et checks.json |
| Qualité | Clippy strict, rustfmt et documentation validés ; journaux correspondants en validation/ et complément §11.2 |
| Fixtures indépendantes | Validées ; independent-fixtures.json et vérification OpenSSL décrite en §11.2 |
| Concurrence et erreurs | Tests multiprocessus et injections validés localement ; tests.log et §11.3 ; aucune portée physique supplémentaire |
| Fuzzing | 1803 secondes cumulées par cible, en trois sessions ; fuzz-summary.json et douze couples JSON/log ; accepté comme validation initiale |
| Dépendances | Aucune vulnérabilité RustSec connue signalée dans les périmètres contrôlés ; rustsec*.json et §11.3 |
| Verrouillage | Neuf arêtes ajoutées à Cargo.lock, sans changement de version déclaré et confirmé par le contrôle documentaire ; Cargo.lock.diff et §11.6 |
| Périmètre | Aucun changement hors périmètre déclaré et confirmé lors de la clôture ; scope.json et inventaire §10 |

Le CTO **ratifie les campagnes cumulées de fuzzing comme validation initiale**, sans
assimilation à une garantie exhaustive. La réserve méthodologique « cumul à ratifier »
de l’avis précédent est donc levée sur ce point précis. Une campagne continue reste
recommandée au titre de RES-01 ; elle n’a pas été exécutée dans la présente clôture.
Les essais échoués ou interrompus restent exclus des résultats retenus.
Aucun nouveau test du crate ni nouvelle campagne de fuzzing n’est lancé pour consigner
cette notification ; les validations ci-dessus sont les résultats historiques ratifiés.

### 12.3 Réserves officielles RES-01 à RES-05

| Réserve | Contenu officiel / état à la réception | Responsabilité fonctionnelle et suite |
|---|---|---|
| **RES-01 — Fuzzing complémentaire** | OUVERTE. Campagne continue supplémentaire recommandée avant qualification de production ; conservation durable des corpus et résultats. La validation initiale cumulée est acceptée. | Traitement par mission distincte ; responsable nominatif et organisation de l’archivage durable à désigner. Aucun lancement supplémentaire autorisé par cette clôture. |
| **RES-02 — Qualification du stockage** | OUVERTE. Qualifier ext4/XFS et les scénarios de panne électrique sur l’infrastructure cible avant toute revendication correspondante. Aucun de ces essais physiques n’est acquis. | **Infrastructure/exploitation LYXAL OS**, responsable à désigner nominativement. Les essais sur overlayfs et arrêts de processus restent des preuves locales distinctes. |
| **RES-03 — Obligations de l’hôte** | OUVERTE. Vérifier avant exploitation le registre durable ID/matériel, les tombstones, les budgets d’utilisation, la restauration avant trafic, la publication synchronisée des snapshots, la révocation entre processus et les procédures de sauvegarde/récupération. | **Intégrateur de l’hôte LYXAL OS**, responsable à désigner nominativement. Les contrôles distribués et procédures d’exploitation restent à réaliser dans une mission distincte. |
| **RES-04 — Consommateurs** | OUVERTE, HORS MISSION. Adapter les modules utilisant l’ancienne API sous un mandat séparé. Aucune adaptation n’est autorisée ici. | Responsabilités d’intégration à fixer dans le futur mandat ; aucun consommateur modifié dans cette clôture. |
| **RES-05 — Assurance indépendante** | OUVERTE. Audit de sécurité indépendant recommandé avant utilisation de production pour des secrets sensibles. Aucun audit indépendant ou certificat n’est réputé obtenu. | Mission d’assurance à mandater séparément ; auditeur et responsable nominatif non désignés dans la notification. |

Les désignations nominatives restent à effectuer ; aucun nom ou engagement d’un tiers
n’est déduit de la notification. Les hypothèses de répertoire de confiance et les limites
TOCTOU du profil fichier restent celles de SECURITY.md. Les budgets globaux ne sont pas
comptés automatiquement par le crate et les anciens snapshots détenus par d’autres
processus ne sont pas révoqués rétroactivement. Les détails de ces obligations demeurent
en sections 9 et 11.7 ; aucune réserve n’est réputée close par la seule réception du code.

### 12.4 Vérification documentaire du risque de collision de nonce

Hypothèses : nonces de 96 bits **indépendants et uniformes**, sous un même matériel de clé,
avec cumul de toutes les instances, tous les identifiants et tous les redémarrages.
Pour `q` tirages dans un espace de taille `N = 2^96`, l’événement de collision est l’union
des égalités entre les `q(q−1)/2` paires. La borne d’union donne :

```text
Pr[au moins une collision] <= q(q−1) / (2 × 2^96) = q(q−1) / 2^97.

Pour q = 2^24 :
q(q−1) / 2^97
  = (2^48 − 2^24) / 2^97
  = 2^-49 − 2^-73
  = 2^-49 × (1 − 2^-24)
  < 2^-49.
```

Vérification en arithmétique rationnelle exacte (`fractions.Fraction`, Python 3.12.14) :
`Fraction(q*(q-1), 2**97) == Fraction(1, 2**49) - Fraction(1, 2**73)`, et comparaison
strictement inférieure confirmées. La borne vaut exactement
`16777215 / 9444732965739290427392`, soit environ **1,776356733521132 × 10^-15**.
Le seuil `2^-49` vaut environ `1,776356839400250 × 10^-15` ; leur différence positive est
exactement `2^-73`, environ `1,058791184067875 × 10^-22`.
Pour tout `0 <= q <= 2^24`, le même majorant strict s’applique par monotonie du nombre de paires.

**Conclusion : la formulation « strictement inférieure à 2^-49 » est mathématiquement
justifiée sous ces hypothèses. Aucune correction de cette borne n’est nécessaire.**
La quantité `q(q−1)/2^97` est un majorant, pas la probabilité exacte. L’expression exacte
est `1 − produit(i=0..q−1, 1 − i/2^96)`. Ce calcul ne garantit ni la qualité réelle du RNG,
ni l’unicité déterministe des nonces, ni la sécurité globale de GCM : volumes de blocs,
tentatives de falsification et confidentialité de la clé restent pertinents.
Il ne crée aucun compteur distribué d’utilisation et ne modifie pas la politique hôte.
Aucun protocole, nonce, paramètre cryptographique ou code n’est changé par cette vérification.

### 12.5 Clôture et condition de poursuite

La phase B de `lyxal_crypto` est **réceptionnée techniquement avec réserves**. Les réserves
RES-01 à RES-05 seront traitées dans des missions distinctes selon les besoins de
qualification et d’intégration, avec désignation des responsables concernés.

La présente intervention complète exclusivement ce rapport : aucune nouvelle modification
fonctionnelle, de dépendance, de Cargo.lock, d’un autre crate ou de .agents ; aucun commit,
push, merge ou déploiement. L’historique des validations demeure inchangé.

**PRODUCTION NON AUTORISÉE. Arrêt après cette clôture documentaire ; attendre une nouvelle
autorisation CTO avant toute poursuite des travaux.**
